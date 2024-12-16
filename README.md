# Open Security Operations Center

This script is intended for IT technicians looking to streamline the deployment of Open Source Security Operations Center (SOC) tools.

### By running the commands compiled in this script, it will effortlessly install and configure TheHive, Cortex, Wazuh, and MISP on an Ubuntu 24.04 server.


- 🐝 TheHive4: A platform for Incident Management.

- 🧠 Cortex: Automate threat intelligence and response with Analyzers.

- 🛡️ Wazuh: Powerful Open Source Security Information and Event Management System.

- 🗂️ MISP: Your own Cyber Threat Intelligence platform.


See how it works here:

[![IMAGE ALT TEXT](http://img.youtube.com/vi/N1ylCzaRsMg/0.jpg)](https://youtu.be/N1ylCzaRsMg "Github - OpenSOC Project (TheHive, Cortex, WAZUH and MISP)")



***If you have a personalized digital certificate, it will also help you deploy that certificate to TheHive.***


After installing everything, these are the ports used by each application:

TheHive: 9000 - http://\<IP\>:9000  | if SSL is enabled:  https://\<IP\>:7443

Cortex: 9001 - http://\<IP\>:9001

Wazuh: 9443 - https://\<IP\>:9443

MISP: 443 - https://\<IP\>

***These are the credentials made available after the Installation:***

TheHive: admin:secret

Cortex: (setup by the user during first login)

WAZUH: admin:P+sswordCyber2025		
		
MISP: 443 - admin@admin.test:(generated during setup)




**Warning**
It is recommended to run this script in a virtual machine and take a snapshot of the VM before running it.




***Trouble Shooting MISP installation***

If you get a few errors during the MISP installation process, exit the script and run the following commands:
- pecl uninstall brotli simdjson zstd
- rm -rf /var/www/MISP /var/www/.cache
- mysql -u root -e "DROP DATABASE misp;"
- mysql -u root -e "DROP USER 'misp'@'localhost';"
- mysql -u root -e "FLUSH PRIVILEGES;"


In case the password for MISP doesn't show up, please run the following command to generate a new password for the default user account:

- /var/www/MISP/app/Console/cake user change_pw admin@admin.test P+sswordCyber2025

(This project was originally a fork from nusantara's T-Guard Project)
