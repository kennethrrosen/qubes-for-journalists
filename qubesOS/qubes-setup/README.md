#### Example Basic Qube Configurations

TKTKTKT overview

``````
(clockvm)-------------------------------------------------------+
                                                                |
(updates)-----------+                                           |
                    |                                           |
{private-*}--[sys-firewall-anon]--[sys-tor]--[sys-firewall]--[sys-net]
                                      |             |
(dvm-anon)----------------------------+             |
                                                    |
(dvm-cleanet)---------------------------------------+
                                                    |
{work-*}--------------------------------------------+
``````

tktktktkt explainer

#### Example Intermediate Qube Configurations

TKTKTKT overview

``````
(clockvm)-------------------------------------------------------+
                                                                |
(updates)-----------+                                           |
                    |                                           |
{private-*}--[sys-firewall-anon]--[sys-tor]--[sys-firewall]--[sys-net]
                                      |             |
(dvm-anon)----------------------------+             |
                                                    |
(dvm-cleanet)---------------------------------------+
                                                    |
{work-*}--------------------------------------------+
``````

#### Example Advanced Qube Configurations

TKTKTKT overview, include split-proton-vms

``````
(clockvm)-------------------------------------------------------+
                                                                |
(updates)-----------+                                           |
                    |                                           |
{private-*}--[sys-firewall-anon]--[sys-tor]--[sys-firewall]--[sys-net]
                                      |             |
(dvm-anon)----------------------------+             |
                                                    |
(dvm-cleanet)---------------------------------------+
                                                    |
{work-*}--------------------------------------------+
``````
tktktktkt explainer
