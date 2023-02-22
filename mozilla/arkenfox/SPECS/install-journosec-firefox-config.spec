Name:           install_journoSEC_config
Version:        1.0
Release:        1%{?dist}
Summary:        JournoSEC Firefox configuration files
License:        GPL
URL:            https://github.com/journoQUBES/install_journoSEC_config
Source0:        Source0: /home/user/Documents/GitHub/journoQUBES/mozilla/arkenfox/install-journosec-firefox-config-1.0/SOURCES/install-journosec-firefox-config-1.0.tar.gz


BuildArch:      noarch

Requires:       firefox

%description
This package contains the JournoSEC Firefox configuration files, including the user.js and user-overrides.js files.

%prep
%autosetup

%install
python3 setup.py install --root $RPM_BUILD_ROOT

%files
%defattr(-,root,root,-)
%doc README.md
/opt/install_journoSEC_config
/usr/bin/move_user_js

%changelog
* Mon Feb 20 2023 Kenneth R Rosen <kennethrrosen@proton.me> 1.0-1
- Initial release

