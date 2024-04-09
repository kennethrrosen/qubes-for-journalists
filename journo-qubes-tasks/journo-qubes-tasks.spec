# or, build your own RPM
# tar czf qubes-for-journalists-0.1.tar.gz qubes-for-journalists/
# mv qubes-for-journalists-0.1.tar.gz ~/rpmbuild/SOURCES/
# rpmbuild -ba qubes-for-journalists.spec


Name: qubes-for-journalists
Version: 0.1
Release: 1
Summary: A suite of tools and configurations for journalists using Qubes OS

Group: Applications/System
Vendor: Kenneth R. Rosen
License: GPL
URL: https://www.kennethrrosen.com/

Source0: %{name}-%{version}.tar.gz

BuildArch: noarch
Requires: python3, qubesadmin

%description
A suite of tools, including a task manager and various configurations, tailored for journalists using Qubes OS. Integrates with Qubes OS Salt management for easy deployment of journalist-focused configurations and templates.

%prep
%setup -q

%build
# Placeholder for any build steps (compilation, etc.)

%install
rm -rf %{buildroot}
# Install Python scripts
mkdir -p %{buildroot}/usr/bin
mkdir -p %{buildroot}/usr/lib/python3.8/site-packages/qubesadmin/journo-tools
cp journo-qubes-tasks/journo-qubes-tasks* %{buildroot}/usr/bin/
cp journo-qubes-tasks/journo-qubes-tasks-gui.py %{buildroot}/usr/lib/python3.8/site-packages/qubesadmin/journo-tools/

# Install Salt scripts
mkdir -p %{buildroot}/srv/salt/qujourno
cp -r salt/* %{buildroot}/srv/salt/qujourno/

%files
%defattr(-,root,root,-)
/usr/bin/journo-qubes-tasks
/usr/bin/journo-qubes-tasks-gui
/usr/lib/python3.8/site-packages/qubesadmin/journo-tools/journo-qubes-tasks-gui.py
/srv/salt/qujourno/*

%changelog
* Tue Apr 4 2024 Kenneth R. Rosen <kennethrrosen@proton.me> - 0.1-1
- Initial release of qubes-for-journalists package
