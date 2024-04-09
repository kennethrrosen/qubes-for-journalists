#
# Reuses code from The Qubes OS Project, https://www.qubes-os.org/
#
# Copyright (C) 2022  unman <unman@thirdeyesecurity.org> ***EDITED BY KRR
#
# Reuses code from qvm-template.py
# Copyright (C) 2019  WillyPillow <wp@nerde.pw>
#
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU Lesser General Public License as published by
# the Free Software Foundation; either version 2.1 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU Lesser General Public License for more details.
#
# You should have received a copy of the GNU Lesser General Public License along
# with this program; if not, write to the Free Software Foundation, Inc.,
# 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.

"""Tool for managing Journo Qubes Tasks."""

import argparse
import collections
import configparser
import datetime
import enum
import fcntl
import fnmatch
import functools
import glob
import itertools
import operator
import os
import re
import rpm
import subprocess
import sys
import typing
import qubesadmin

from qubesadmin.tools.qvm_template import is_match_spec
from qubesadmin.tools.qvm_template import qrexec_popen
from qubesadmin.tools.qvm_template import qubes_release
from qubesadmin.tools.qvm_template import Template as Package

DATE_FMT = '%Y-%m-%d %H:%M:%S'
LOCK_FILE = '/var/tmp/qvm-task.lck'
UPDATEVM = str('global UpdateVM')
PACKAGE_NAME_PREFIX = 'journo-qubes-'
##REPO_FILE = ['/etc/yum.repos.d/3isec-dom0.repo'] ##NEED TO UPDATE TO INCLUDE OWN REPO


class AlreadyRunning(Exception):
    """Another qvm-task is already running"""


def get_parser() -> argparse.ArgumentParser:
    formatter = argparse.ArgumentDefaultsHelpFormatter
    parser_main = qubesadmin.tools.QubesArgumentParser(
        description=__doc__, formatter_class=formatter)
    parser_main.register(
        'action', 'parsers', qubesadmin.tools.AliasedSubParsersAction)
    subparsers = parser_main.add_subparsers(
        dest='command', description='Command to run.')

    def parser_add_command(cmd, help_str):
        return subparsers.add_parser(
            cmd,
            formatter_class=formatter,
            help=help_str,
            description=help_str)

    parser_install = parser_add_command('install',
        help_str='Install tasks.')
    parser_list = parser_add_command('list',
        help_str='List Tasks.')
    parser_info = parser_add_command('info',
        help_str='Display details about Task.')
    parser_dict = parser_add_command('dict',
        help_str='Return dict of details about Task.')
    parser_install.add_argument('pkgs', nargs='*', metavar='PATTERN')
    for parser_x in [parser_list, parser_info, parser_dict]:
        parser_x.add_argument('--all', action='store_true',
            help='Show all tasks (default).')
        parser_x.add_argument('tasks', nargs='*')

    parser_search = parser_add_command('search',
        help_str='Search template details for the given string.')
    parser_search.add_argument('--all', action='store_true',
        help=('Search also in the template description and URL. In addition,'
            ' the criterion are evaluated with OR instead of AND.'))
    parser_search.add_argument('tasks', nargs='*', metavar='PATTERN')

    return parser_main


parser = get_parser()


class TaskState(enum.Enum):
    """Enum representing the state of a task."""
    INSTALLED = 'installed'
    AVAILABLE = 'available'

    def title(self) -> str:
        """Return a long description of the state. Can be used as headings."""
        # pylint: disable=invalid-name
        TASK_TITLES = {
            TaskState.INSTALLED: 'Installed Tasks',
            TaskState.AVAILABLE: 'Available Tasks',
        }
        return TASK_TITLES[self]


def qrexec_payload(args: argparse.Namespace, app: qubesadmin.app.QubesBase,
                   spec: str, refresh: bool) -> str:
    """Return payload string for the ``qubes.Template*`` qrexec calls.
    :param args: Arguments received by the application. Specifically,
        ``args.{enablerepo,disablerepo,repoid,releasever,repo_files}`` are used
    :param app: Qubes application object
    :param spec: Package spec to query (refer to ``<package-name-spec>`` in the
        DNF documentation)
    :param refresh: Whether to force refresh repo metadata
    :return: Payload string
    :raises: Parser error if spec equals ``---`` or input contains ``\\n``
    """
    _ = app  # unused

    if spec == '---':
        parser.error("Malformed template name: argument should not be '---'.")

    def check_newline(string, name):
        if '\n' in string:
            parser.error(f"Malformed {name}:" +
                         " argument should not contain '\\n'.")

    payload = ''
    payload += '--refresh\n'
    args.releasever = qubes_release()
    check_newline(args.releasever, '--releasever')
    payload += f'--releasever={args.releasever}\n'
    check_newline(spec, 'template name')
    payload += spec + '\n'
    payload += '---\n'
    for path in args.repo_files:
        with open(path, 'r', encoding='utf-8') as fd:
            payload += fd.read() + '\n'
    return payload


def qrexec_repoquery(
        args: argparse.Namespace,
        app: qubesadmin.app.QubesBase,
        spec: str = '*',
        refresh: bool = False) -> typing.List[Package]:
    """Query template information from repositories.
    :param args: Arguments received by the application. Specifically,
        ``args.{enablerepo,disablerepo,repoid,releasever,repo_files,updatevm}``
        are used
    :param app: Qubes application object
    :param spec: Package spec to query (refer to ``<package-name-spec>`` in the
        DNF documentation). Defaults to ``*``
    :param refresh: Whether to force refresh repo metadata. Defaults to False
    :raises ConnectionError: if the qrexec call fails
    :return: List of ``Package`` objects representing the result of the query
    """
    payload = qrexec_payload(args, app, spec, refresh)
    proc = qrexec_popen(args, app, 'qubes.TemplateSearch')
    proc.stdin.write(payload.encode('UTF-8'))
    proc.stdin.close()
    stdout = proc.stdout.read(1 << 20).decode('ascii', 'strict')
    proc.stdout.close()
    stderr = proc.stderr.read(1 << 10).decode('ascii', 'strict')
    proc.stderr.close()
    if proc.wait() != 0:
        for line in stderr.rstrip().split('\n'):
            print(f"[Qrexec] {line}", file=sys.stderr)
        raise ConnectionError("qrexec call 'qubes.TemplateSearch' failed.")
    name_re = re.compile(r'\A[A-Za-z0-9._+][A-Za-z0-9._+-]*\Z')
    evr_re = re.compile(r'\A[A-Za-z0-9._+~]*\Z')
    date_re = re.compile(r'\A\d{4}-\d{1,2}-\d{1,2} \d{1,2}:\d{1,2}\Z')
    licence_re = re.compile(r'\A[A-Za-z0-9._+()][A-Za-z0-9._+()-]*\Z')
    result = []
    # FIXME: This breaks when \n is the first character of the description
    for line in stdout.split('|\n'):
        # Note that there's an empty entry at the end as .strip() is not used.
        # This is because if .strip() is used, the .split() will not work.
        if line == '':
            continue
        entry = line.split('|')
        try:
            # If there is an incorrect number of entries, raise an error
            # Unpack manually instead of stuffing into `Package` right away
            # so that it's easier to mutate stuff.
            name, epoch, version, release, reponame, dlsize, \
            buildtime, licence, url, summary, description = entry

            # Ignore packages that are not tasks
            if not name.startswith(PACKAGE_NAME_PREFIX):
                continue
            name = name[len(PACKAGE_NAME_PREFIX):]

            # Check that the values make sense
            if not re.fullmatch(name_re, name):
                raise ValueError
            for val in [epoch, version, release]:
                if not re.fullmatch(evr_re, val):
                    raise ValueError
            if not re.fullmatch(name_re, reponame):
                raise ValueError
            dlsize = int(dlsize)
            # First verify that the date does not look weird, then parse it
            if not re.fullmatch(date_re, buildtime):
                raise ValueError
            buildtime = datetime.datetime.strptime(buildtime, '%Y-%m-%d %H:%M')
            # XXX: Perhaps whitelist licenses directly?
            if not re.fullmatch(licence_re, licence):
                raise ValueError
            # Check name actually matches spec
            if not is_match_spec(PACKAGE_NAME_PREFIX + name,
                                 epoch, version, release, spec)[0]:
                continue

            result.append(Package(name, epoch, version, release, reponame,
                                   dlsize, buildtime, licence, url, summary,
                                   description))
        except (TypeError, ValueError):
            raise ConnectionError("qrexec call 'qubes.TemplateSearch' failed:"
                                   " unexpected data format.")
    return result


def locked(func):
    @functools.wraps(func)
    def wrapper(*args, **kwargs):
        with open(LOCK_FILE, 'w', encoding='ascii') as lock:
            try:
                fcntl.flock(lock.fileno(), fcntl.LOCK_EX | fcntl.LOCK_NB)
            except OSError:
                raise AlreadyRunning(
                    f"Cannot get lock on {LOCK_FILE}. Perhaps another instance "
                    f"of qvm-task is running?")
            try:
                return func(*args, **kwargs)
            finally:
                os.remove(LOCK_FILE)
    return wrapper


@locked


def install(args: argparse.Namespace) -> None:
    pkgs_to_install = [PACKAGE_NAME_PREFIX + pkg for pkg in args.pkgs ]
    install_list = " ".join(pkgs_to_install)
    update_cmd = "sudo qubes-dom0-update "
    try:
        child = subprocess.Popen(update_cmd + install_list,shell=True)
        output = child.communicate()[0]
    except Exception as e:  # pylint: disable=broad-except
        print('ERROR: ' + str(e), file=sys.stderr)
        return 1

    return 0


def list_tasks(args: argparse.Namespace,
                   app: qubesadmin.app.QubesBase, command: str) -> None:
    """Command that lists tasks.
    :param args: Arguments received by the application.
    :param app: Qubes application object
    :param command: If set to ``list``, display a listing similar to ``dnf
        list``. If set to ``info``, display detailed template information
        similar to ``dnf info``. Otherwise, an ``AssertionError`` is raised.
    """
    task_list = []

    def append_list(data, status, install_time=None):
        _ = install_time # unused
        task_list.append((status, data.name))

    def append_info(data, status, install_time=None):
        task_list.append((status, data, install_time))

    def list_to_human_output(tpls):
        outputs = []
        for status, grp in itertools.groupby(tpls, lambda x: x[0]):
            def convert(row):
                return row[1:]
            outputs.append((status, list(map(convert, grp))))
        return outputs

    def info_to_human_output(tpls):
        outputs = []
        for status, grp in itertools.groupby(tpls, lambda x: x[0]):
            output = []
            for _, data, install_time in grp:
                output.append(('Name', ':', data.name))
                output.append(('Summary', ':', data.summary))
                # Only show "Description" for the first line
                title = 'Description'
                for line in data.description.splitlines():
                    output.append((title, ':', line))
                    title = ''
                output.append((' ', ' ', ' ')) # empty line
            outputs.append((status, output))
        return outputs

    def info_to_dict(pkgs):
        outputs = {}
        for status, grp in itertools.groupby(pkgs, lambda x: x[0]):
            for _, data, install_time in grp:
                outputs[data.name]  = {
                    'summary' : data.summary ,
                    'description' : data.description
                    }
        return outputs

    if command == 'list':
        append = append_list
    elif command == 'info':
        append = append_info
    elif command == 'dict':
        append = append_info
    else:
        assert False, 'Unknown command'

    def check_append(name, evr):
        return not args.tasks or \
            any(is_match_spec(name, *evr, spec)[0]
                for spec in args.tasks)

    args.all = True

    if args.all :
        if args.tasks:
            query_res_set: typing.Set[Package] = set()
            for spec in args.tasks:
                query_res_set |= set(qrexec_repoquery(
                    args, app, PACKAGE_NAME_PREFIX + spec))
            query_res = list(query_res_set)
        else:
            query_res = qrexec_repoquery(args, app)
    if args.all:
        # Spec should already be checked by repoquery
        for data in query_res:
            append(data, TaskState.AVAILABLE)
        query_res = qrexec_repoquery(args, app)
    if len(task_list) == 0:
        parser.error('No matching tasks to list')
    elif command == 'dict':
            task_list = info_to_dict(task_list)
            return task_list
    else:
        if command == 'info':
            task_list = info_to_human_output(task_list)
        elif command == 'list':
            task_list = list_to_human_output(task_list)
        for status, grp in task_list:
            print(status.title())
            qubesadmin.tools.print_table(grp)


def search(args: argparse.Namespace, app: qubesadmin.app.QubesBase) -> None:
    """Command that searches task details for given patterns.
    :param args: Arguments received by the application.
    :param app: Qubes application object
    """
    # Search in both installed and available tasks
    query_res = qrexec_repoquery(args, app)

    # pylint: disable=invalid-name
    WEIGHT_NAME_EXACT = 1 << 4
    WEIGHT_NAME = 1 << 3
    WEIGHT_SUMMARY = 1 << 2
    WEIGHT_DESCRIPTION = 1 << 1
    WEIGHT_URL = 1 << 0

    WEIGHT_TO_FIELD = [
        (WEIGHT_NAME_EXACT, 'Name'),
        (WEIGHT_NAME, 'Name'),
        (WEIGHT_SUMMARY, 'Summary'),
        (WEIGHT_DESCRIPTION, 'Description'),
        (WEIGHT_URL, 'URL')]

    search_res_by_idx: \
        typing.Dict[int, typing.List[typing.Tuple[int, str, bool]]] = \
        collections.defaultdict(list)
    for keyword in args.tasks:
        for idx, entry in enumerate(query_res):
            needle_types = \
                [(entry.name, WEIGHT_NAME), (entry.summary, WEIGHT_SUMMARY)]
            if args.all:
                needle_types += [(entry.description, WEIGHT_DESCRIPTION),
                                 (entry.url, WEIGHT_URL)]
            for key, weight in needle_types:
                if fnmatch.fnmatch(key, '*' + keyword + '*'):
                    exact = keyword == key
                    if exact and weight == WEIGHT_NAME:
                        weight = WEIGHT_NAME_EXACT
                    search_res_by_idx[idx].append((weight, keyword, exact))

    if not args.all:
        keywords = set(args.tasks)
        idxs = list(search_res_by_idx.keys())
        for idx in idxs:
            if keywords != set(x[1] for x in search_res_by_idx[idx]):
                del search_res_by_idx[idx]

    def key_func(x):
        # ORDER BY weight DESC, list_of_needles ASC, name ASC
        idx, needles = x
        weight = sum(t[0] for t in needles)
        name = query_res[idx][0]
        return -weight, needles, name

    search_res = sorted(search_res_by_idx.items(), key=key_func)

    def gen_header(needles):
        fields = []
        weight_types = set(x[0] for x in needles)
        for weight, field in WEIGHT_TO_FIELD:
            if weight in weight_types:
                fields.append(field)
        exact = all(x[-1] for x in needles)
        match = 'Exactly Matched' if exact else 'Matched'
        keywords = sorted(list(set(x[1] for x in needles)))
        return ' & '.join(fields) + ' ' + match + ': ' + ', '.join(keywords)

    last_header = ''
    for idx, needles in search_res:
        # Print headers
        cur_header = gen_header(needles)
        if last_header != cur_header:
            last_header = cur_header
            # XXX: The style is different from that of DNF
            print('===', cur_header, '===')
        print(query_res[idx].name, ':', query_res[idx].summary)


def main(args: typing.Optional[typing.Sequence[str]] = None,
         app: typing.Optional[qubesadmin.app.QubesBase] = None) -> int:
    """Main routine of **qvm-task**.
    :param args: Override arguments received by the application. Optional
    :param app: Override Qubes application object. Optional
    :return: Return code of the application
    """
    # do two passes to allow global options after command name too
    p_args, args = parser.parse_known_args(args)
    p_args = parser.parse_args(args, p_args)

    if not p_args.command:
        parser.error('A command needs to be specified.')

    p_args.repo_files = REPO_FILE
    if app is None:
        app = qubesadmin.Qubes()

    p_args.updatevm = app.updatevm

    try:
        if p_args.command == 'install':
            install(p_args)
        elif p_args.command == 'list':
            list_tasks(p_args, app, 'list')
        elif p_args.command == 'info':
            list_tasks(p_args, app, 'info')
        elif p_args.command == 'dict':
            list_tasks(p_args, app, 'dict')
        elif p_args.command == 'search':
            search(p_args, app)
        else:
            parser.error(f'Command \'{p_args.command}\' not supported.')
    except Exception as e:  # pylint: disable=broad-except
        print('ERROR: ' + str(e), file=sys.stderr)
        app.log.debug(str(e), exc_info=sys.exc_info())
        return 1

    return 0


if __name__ == '__main__':
    sys.exit(main())
