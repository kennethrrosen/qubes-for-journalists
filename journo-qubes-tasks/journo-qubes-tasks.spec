Name: jouro-qubes-task-manager
Version: 0.1
Release: 1
Summary: Qubes task manager for journalists, based on the Invisible Things Lab (Unman) task manager

Group:	Qubes
Vendor:	Kenneth R. Rosen
License: GPL
URL: http://www.kennethrrosen.com/

Source0:  journo-qubes-task

AutoReq:  no

BuildArch: x86_64

Requires:  python3

%description
Journo-Qubes task manager

%install
rm -rf %{buildroot}
mkdir -p %{buildroot}/usr/bin
mkdir -p %{buildroot}/usr/lib/python3.8/site-packages/qubesadmin/tools
mkdir -p %{buildroot}/usr/lib/python3.8/site-packages/qubesadmin/tools/__pycache__
cp -rv %{SOURCE0}/journo-qubes-task*  %{buildroot}/usr/bin
cp %{SOURCE0}/journo-qubes_task.py %{buildroot}/usr/lib/python3.8/site-packages/qubesadmin/tools


%post

%pre

%preun

%postun

%files
%defattr(-,root,root,-)
/usr/bin/journo-qubes-task
/usr/bin/journo-qubes-task-gui
/usr/lib/python3.8/site-packages/qubesadmin/tools/journo-qubes_task.py
/usr/lib/python3.8/site-packages/qubesadmin/tools/__pycache__/journo-qubes_task.cpython-38.*
