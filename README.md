# Open Security Operations Center

This script is intended for IT technicians looking to streamline the deployment of Open Source Security Operations Center (SOC) tools.

### By running the commands compiled in this script, it will effortlessly install and configure TheHive, Cortex, Wazuh, and MISP on an Ubuntu 24.04 server.


- 🐝 TheHive4: A platform for Incident Management.

- 🧠 Cortex: Automate threat intelligence and response with Analyzers.

- 🛡️ Wazuh: Powerful Open Source Security Information and Event Management System.

- 🗂️ MISP: Your own Cyber Threat Intelligence platform.


See how it works here:

[![IMAGE ALT TEXT](http://img.youtube.com/vi/N1ylCzaRsMg/0.jpg)](https://youtu.be/N1ylCzaRsMg "Github - OpenSOC Project (TheHive, Cortex, WAZUH and MISP)")


# Installation:

## Check if installed as it will be needed.
```
# sudo apt-get update
# sudo apt-get install wget whiptail -y
```

## Download and run
```
# wget https://raw.githubusercontent.com/philip17rc/OpenSOC/refs/heads/main/setup.sh
# chmod +x setup.sh
# sudo bash setup.sh
```

## Post-Installation 

***If you have a personalized digital certificate, it will also help you deploy that certificate to TheHive.***

After installing everything, these are the ports and credentials used by each application:


|  Service  |              Endpoint                   |      Username      |      Password           |
| --------- | --------------------------------------- | ------------------ | ----------------------- |
| Portainer | `http://$IP:9111`                       |            (setup at first loggin)
| TheHive   | `http://$IP:9000` or `https://$IP:7443` |     admin          |          secret         |
| Cortex    | `http://$IP:9001`                       |            (setup at first loggin)           |
| Wazuh     | `https://$IP:9443`                      |     admin          |  P+sswordCyber2025      |
| MISP      | `https://$IP:443`                       |  admin@admin.test  | (setup at first loggin) |


***The above credentials are made available after the Installation:***



** Warning **
It is recommended to run this script in a virtual machine and take a snapshot of the VM before running it.




## Trouble Shooting MISP installation***

If you get a few errors during the MISP installation process, exit the script and run the following commands:
- pecl uninstall brotli simdjson zstd
- rm -rf /var/www/MISP /var/www/.cache
- mysql -u root -e "DROP DATABASE misp;"
- mysql -u root -e "DROP USER 'misp'@'localhost';"
- mysql -u root -e "FLUSH PRIVILEGES;"


In case the password for MISP doesn't show up, please run the following command to generate a new password for the default user account:

- /var/www/MISP/app/Console/cake user change_pw admin@admin.test P+sswordCyber2025

(This project was originally a fork from nusantara's T-Guard Project)
