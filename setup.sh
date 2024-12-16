#!/bin/bash
#
# Author: Nuno Filipe Romao Pereira (philip17rc)
# License: Gnu General Public License v2
# Script version 1.0
# First version Date: 14-December-2024
#
# This script is meant to help new IT professionals with basic Linux knowledge, to setup their own Open Source Security Operations Center.
# These are the capabilities that are included in this script:
# - TheHive for Incident Management
# - Cortex with Analyzers
# - Wazuh as their primary Security Information and Event Management system
# - MISP for their Cyber Threat Intelligence Platform.
#
# Keep defending the cyberspace


while true; do
    OPTION=$(whiptail --title "Open Security Operations Center Project" --menu "Choose an option:" 20 65 10 \
                    "1" "Update System and Install Prerequisites" \
					"2" "Install TheHive (Incident Management Platform)" \
                    "3" "Install Cortex (Analyzers)" \
                    "4" "Install Wazuh (SIEM)" \
                    "5" "Install MISP" \
					"6" "Integrate TheHive<->Cortex" \
					"7" "Integrate TheHive<->MISP" \
					"8" "Enable SSL on TheHive" \
					"9" "Show Info"					3>&1 1>&2 2>&3) 
    
    case $OPTION in
    1)
		sudo apt-get update -y
		sudo apt-get upgrade -y
		sudo apt-get install wget curl nano git unzip -y

		# Install Docker and Portainer in the environment
		# Add Docker's official GPG key:
		sudo apt-get update
		sudo apt-get install ca-certificates curl
		sudo install -m 0755 -d /etc/apt/keyrings
		sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
		sudo chmod a+r /etc/apt/keyrings/docker.asc

		# Add the repository to Apt sources:
		echo \
		  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \
		  $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
		  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
		sudo apt-get update
				
		sudo apt-get install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin -y			
		sudo docker pull portainer/portainer-ce:latest
		sudo docker run -d -p 9111:9000 --restart always -v /var/run/docker.sock:/var/run/docker.sock portainer/portainer-ce:latest
		sudo docker network create elastic
		sudo docker pull elasticsearch:7.17.21
		sudo docker run -d  --name elasticsearch --net elastic -p 9200:9200 -p 9300:9300 -e "discovery.type=single-node" elasticsearch:7.17.21
		sudo docker update --restart always elasticsearch
				
		sudo systemctl enable docker.service && sudo systemctl enable containerd.service
		
		whiptail --title "Pre-requisites" --msgbox "You may connect to http://<IP>:9111 and setup your admin account in Portainer." 10 50
		;;
	
	2)
	
		echo "deb https://debian.cassandra.apache.org 41x main" | sudo tee -a /etc/apt/sources.list.d/cassandra.sources.list
		curl https://downloads.apache.org/cassandra/KEYS | sudo apt-key add -
		sudo apt-get update -y
		
		sudo apt remove python3 -y
		sudo apt-get install software-properties-common -y
		sudo add-apt-repository ppa:deadsnakes/ppa
		sudo apt update
		sudo apt install python3.11 -y
		
		cp /usr/bin/python3 /usr/bin/python3.bak
		rm /usr/bin/python3
		ln -s /usr/bin/python3.11 /usr/bin/python3
		sudo apt install cassandra -y
		
		sudo cqlsh localhost 9042 -e "UPDATE system.local SET cluster_name = 'thp' where key='local';"
		nodetool flush
		rm /usr/bin/python3
		ln -s /usr/bin/python3.12 /usr/bin/python3
		
		sudo sed -i 's/Test Cluster/thp/g' /etc/cassandra/cassandra.yaml
		
		sudo systemctl restart cassandra
		sudo systemctl enable cassandra	
		
		sudo mkdir -p /opt/thp_data/files/thehive
		curl https://raw.githubusercontent.com/TheHive-Project/TheHive/master/PGP-PUBLIC-KEY | sudo apt-key add -
		echo 'deb https://deb.thehive-project.org release main' | sudo tee -a /etc/apt/sources.list.d/thehive-project.list
		sudo apt-get update
		sudo apt install thehive4 -y
		sed -i 's#// hostname#hostname#g' /etc/thehive/application.conf
		sed -i 's#\["ip1", "ip2"\]#\["127.0.0.1"\]#g' /etc/thehive/application.conf
		sudo chown -R thehive:thehive /opt/thp_data/files/thehive		
		sudo systemctl start thehive
		sudo systemctl enable thehive
		whiptail --title "TheHive" --msgbox "You may connect to TheHive on http://<IP>:9000 and setup your organization." 10 50
		;;
   
    3)
        sudo apt install cortex -y
		sudo sed -i 's/#play.http.secret.key/play.http.secret.key/g' /etc/cortex/application.conf
		sudo sed -i 's/#keepalive/keepalive/g' /etc/cortex/application.conf
		sudo sed -i 's/#pagesize/pagesize/g' /etc/cortex/application.conf
		sudo sed -i 's/#nbshards/nbshards/g' /etc/cortex/application.conf
		sudo sed -i 's/#nbreplicas/nbreplicas/g' /etc/cortex/application.conf
		sudo systemctl start cortex
		sudo systemctl enable cortex
		whiptail --title "Cortex" --msgbox "You may connect to Cortex on http://<IP>:9001 and setup your organization. Make sure elasticsearch is enabled in Docker." 10 50
        ;;
    4)
        sudo curl -sO https://packages.wazuh.com/4.9/wazuh-install.sh
		sudo sed -i 's/http_port=443/http_port=9443/g' ./wazuh-install.sh
		sudo sed -i 's/server.port: 443/server.port: 9443/g' ./wazuh-install.sh
		sudo sed -i 's/9200/9201/g' ./wazuh-install.sh
		sudo sed -i 's/9300/9301/g' ./wazuh-install.sh
		sudo bash wazuh-install.sh -a
		
		sudo curl -so wazuh-passwords-tool.sh https://packages.wazuh.com/4.9/wazuh-passwords-tool.sh
		sudo sed -i 's/9200/9201/g' ./wazuh-passwords-tool.sh
		sudo bash wazuh-passwords-tool.sh -u admin -p P+sswordCyber2025
		sudo rm wazuh-install.sh
		whiptail --title "WAZUH" --msgbox "You may connect to WAZUH on https://<IP>:9443" 10 50
        ;; 

    5)
        sudo wget https://raw.githubusercontent.com/MISP/MISP/refs/heads/2.5/INSTALL/INSTALL.ubuntu2404.sh
		#sudo pecl channel-update pecl.php.net &>> $logfile
		#sudo pecl install brotli &>> $logfile
		#sudo pecl install simdjson &>> $logfile
		#sudo pecl install zstd &>> $logfile
		clear
		echo "Make sure in the next step you insert the correct IP address or Fully Qualified Domain Name."
		echo "Access to MISP's web interface will be done with the whatever you define bellow."
		echo "If using a FQDN, make sure your DNS record points the MISP entry to this server."
		read -p "Enter the IP of FQDN of your server: " replacement_string
		sudo sed -i "s/MISP_DOMAIN='misp.local'/MISP_DOMAIN='${replacement_string}'/g" INSTALL.ubuntu2404.sh
		sudo sed -i "s/9001/9003/g" INSTALL.ubuntu2404.sh
		sudo bash ./INSTALL.ubuntu2404.sh
		echo "Please take note of the admin password before proceding..."
		read -p "Press [Enter] to continue" filler
        ;;
	6)
		whiptail --title "TheHive<->Cortex Integration" --msgbox "Before continuing, make sure you have an API key from Cortex to paste in the next section!\nUse the Cortex web interface to generate a new API key." 10 50
		clear
		sudo sed -i '/# Enable Cortex connector/,/## MISP configuration/ s#//##g' /etc/thehive/application.conf
		sudo sed -i '/URL of Cortex instance/s/http:localhost/http:\/\/localhost/g' /etc/thehive/application.conf
		sudo sed -i '/URL of Cortex instance/s/https:localhost/https:\/\/localhost/g' /etc/thehive/application.conf
		clear
		read -p "Please enter Cortex API key: " cortex_api
		sudo sed -i "/Cortex API key/s/\"[^\"]*\"/\"$cortex_api\"/g" /etc/thehive/application.conf
		sudo systemctl restart cortex
		sudo systemctl restart thehive
		clear
		;;
	7)
		whiptail --title "TheHive<->MISP Integration" --msgbox "Before continuing, make sure you have an API key from MISP to paste in the next section!\nUse the MISP web interface to generate a new API key." 10 50
		clear
		sudo sed -i '/# Enable MISP connector/,/# Define maximum size of attachments (default 10MB)/ s#//##g' /etc/thehive/application.conf
		sudo sed -i '/URL or MISP/s/http:localhost/https:\/\/localhost/g' /etc/thehive/application.conf
		sudo sed -i '/URL or MISP/s/https:localhost/https:\/\/localhost/g' /etc/thehive/application.conf
		clear
		read -p "Please enter MISP API key: " misp_api
		sudo sed -i "/MISP API key/s/\"[^\"]*\"/\"$misp_api\"/g" /etc/thehive/application.conf
		sudo sed -i '/MISP API key/,$s/wsConfig {}/wsConfig {ssl.loose.acceptAnyCertificate=true}/g' /etc/thehive/application.conf
		sudo systemctl restart thehive
		clear
		;;
	8)
		whiptail --title "TheHive certificate" --msgbox "Make sure thehive certificate has the following names:\nthehive.crt and thehive.key respectively.\nIn the next menu indicate the directory where the certificates are located." 50 30
		read -p "Insert the directory where the certificates are: " cert_dir
		openssl pkcs12 -export -in $cert_dir/thehive.crt -inkey $cert_dir/thehive.key -out $cert_dir/thehive.p12 -name thehive
		keytool -importkeystore -srckeystore $cert_dir/thehive.p12 -srcstoretype PKCS12 -destkeystore $cert_dir/thehive.jks -deststoretype JKS
		sudo cp $cert_dir/thehive.jks /etc/thehive/
		echo "play.server.https.port = 7443" >> /etc/thehive/application.conf
		echo "play.server.https.keyStore.path = \"/etc/thehive/thehive.jks\"" >> /etc/thehive/application.conf
		read -p "Please repeat one last time the Keystore password: " cert_pass
		echo "play.server.https.keyStore.password = \"$cert_pass\"" >> /etc/thehive/application.conf
		echo "play.server.https.keyStore.type = \"JKS\"" >> /etc/thehive/application.conf
		echo "play.server.http.port = 9000" >> /etc/thehive/application.conf
		echo "play.server.https.enabled = true" >> /etc/thehive/application.conf
		systemctl restart thehive
		;;
    9)
		message="Ports for each service and credentials:\n
		TheHive: 9000 - admin:secret\n
		TheHive w/SSL: 7443 - admin:secret\n
		Cortex: 9001 - (setup by the user during first login)\n
		Wazuh: 9443 - admin:P+sswordCyber2025\n
		MISP: 443 - admin@admin.test:(generated during setup)\n"
        whiptail --title "Information" --msgbox "$message"  20 80
		;;
    
esac
    # Give option to go back to the previous menu or exit
    if (whiptail --title "Exit" --yesno "Do you want to exit the script?" 8 78); then
        break
    else
        continue
    fi
done
