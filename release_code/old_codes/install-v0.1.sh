#!/bin/bash

#-----------------------------------------------
agent_file="HurryUp_Agent"
agent_install_path="/usr/local/bin/hurryup/"
agent_install_all_path="/usr/local/bin/hurryup/$agent_file"

current_dir=$(pwd)
current_agent_dir="$current_dir/$agent_file"

log_dir_path="/var/log/hurryup/"
log_manager_path="/var/log/hurryup/AgentManager/"
log_and_setupfile_path="/var/log/hurryup/Agent/"
service_file_path="/etc/systemd/system/HurryupAM.service"
#-----------------------------------------------

# Simple interface
echo ""
echo "#==========================================#"
echo "     HurryUp-SEDR Agent Installer  v0.1     "
echo "                                            "
echo "                  BoB 10th, Team HurryUp    "
echo "#==========================================#"
echo ""
echo ""

usage()
{
        echo "<Usage>  :
                    install   : $0 -i
                    uninstall : $0 -u"

		echo ""
        echo ""
        echo "<options>"
        echo " 		-h, --help       :   show this message"
        echo "		-i, --install    :   install Hurryup agent program"
        echo "		-u, --uninstall  :   uninstall Hurryup agent program"
        echo "		-e, --enable     :   enable HurryupAM agent to system service"
        echo "		-d, --disable    :   disable HurryupAM agent to system service"
        exit 1
}
#-----------------------------------------------
# make HurryupAM.service file and execute
function make_service(){
                if [ -f "$service_file_path" ]; then
        echo "[+] Agent service has been already registed. -> $service_file_path"
        else
        echo "
[Unit]
Description=BoB10 HurryUp Agent Manager Server

[Service]
ExecStart=/usr/local/bin/HurryUp_Agent_Manager
WorkingDirectory=/your/working/dir
Restart=on-failure

[Install]
WantedBy=multi-user.target " >> /etc/systemd/system/HurryupAM.service


        echo "[INFO] Successfully regist Hurryup-AM.service -> $service_file_path"
        fi
}
#-----------------------------------------------
function install(){
	# Check /usr/local/bin directory.
	if [ -d "$agent_install_path" ]; then
			echo "[+] hurryup directory already created."
	else
			echo "[INFO] Successfully create hurryup directory.  -> $agent_install_path"
			mkdir /usr/local/bin/hurryup
	fi


	# Copy Agent file to /usr/local/bin directory
	if [ -e "$agent_install_all_path" ]; then
			echo "[+] $agent_file already installed.  ->  $agent_install_path !"
	else
			cp -r $current_agent_dir $agent_install_path
			echo "[INFO] Successfully install $agent_file  ->   $agent_install_path "
	fi


	# Check log directory
	if [ -d "$log_dir_path" ]; then
			echo "[+] hurryup log directory already created.  -> $log_dir_path"
	else
			mkdir $log_dir_path
			mkdir $log_manager_path
			mkdir $log_and_setupfile_path
			echo "[INFO] Successfully create hurryup log directory.  ->  $log_dir_path"
	fi
}
#-----------------------------------------------
function uninstall(){
        echo "uninstall test"
}
#-----------------------------------------------
function enable_service(){
        # Check service file
        if [ -f "$service_file_path" ]; then
                systemctl enable HurryupAM
                echo "[INFO] Successfully enable HurryupAM.service."
        else
                echo "[WARN] HurrupAM.service not found!"
                make_service
                echo "[INFO] Create Hurryup service."
                systemctl enable HurryupAM
                echo "[INFO] Successfully enabl HurryupAM.service"
        fi
}
#-----------------------------------------------
function disable_servise(){
        if [ -f "$service_file_path" ]; then
                systemctl disable HurryupAM
                echo "[INFO] Successfully disable HurryupAM.service."
        else
                echo "[WARN] HurryupAM.service not found!"
        fi
}
#-----------------------------------------------
while getopts hiued opts; do
	case $opts in
	h) usage
		;;
	\?) usage
		;;
	i) install
		;;
	u) uninstall
		;;
	e) enable_service
		;;
	d) disable_servise
		;;

	esac
done
