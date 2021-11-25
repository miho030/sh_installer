#!/bin/bash

#-----------------------------------------------
rasp_file="./armv7_32bit/HurryUp_Agent"
ubuntu_file="./ubuntu/HurryUp_Agent"
check_raspberry_comm=$(uname -a | grep raspberrypi | awk '{print $2}')
check_ubuntu_comm=$(uname -a | grep Ubuntu | awk '{print $2}')


agent_install_path="/usr/local/bin/"
agent_install_all_path="/usr/local/bin/$agent_file"

current_dir=$(pwd)
current_agent_dir="$current_dir/$agent_file"

log_dir_path="/var/log/hurryup/"
log_manager_path="/var/log/hurryup/AgentManager/"
log_and_setupfile_path="/var/log/hurryup/Agent/"
service_file_path="/etc/systemd/system/HurryupAM.service"



#-----------------------------------------------
# Simple interface and usage

if [ -z $1 ]; then
        echo ""
        echo "<  HurryUp SEDR solution Agent installer v0.2  >"
        echo "[INFO]   <Usage> $0 -h"
        echo ""
fi


usage()
{
        echo ""
        echo "#==========================================#"
        echo "     HurryUp-SEDR Agent Installer  v0.1     "
        echo "                                            "
        echo "                            Team HurryUp    "
        echo "#==========================================#"
        echo ""
        echo "<Usage>  :
                                install   : $0 -i
                                uninstall : $0 -u"

        echo ""
        echo ""
        echo "<options>"
        echo "          -h, --help       :   show this message"
        echo "          -i, --install    :   install Hurryup agent program"
        echo "          -u, --uninstall  :   uninstall Hurryup agent program"
        echo "          -e, --enable     :   enable HurryupAM agent to system service"
        echo "          -d, --disable    :   disable HurryupAM agent to system service"
        echo ""
        exit 1
}


#-----------------------------------------------
# Check Os platform name and load several agent file.
if [ $check_raspberry_comm == "raspberrypi" ]; then
	echo "[INFO] Checking OS platform name.  ->  $check_raspberry_comm"
	agent_file=$rasp_file
else
	if [ $check_ubuntu_comm == "Ubuntu" ]; then
		echo "[INFO] Checking OS platform name.  -> $check_ubuntu_comm"
		agent_file=$ubuntu_file
fi
	

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
function enable_service(){
        # Check service file
        if [ -f "$service_file_path" ]; then
                systemctl enable HurryupAM
                echo "[INFO] Successfully enable HurryupAM.service."
                systemctl start HurryupAM
                echo "[INFO] Successfully start HurryupAM.service."
        else
                echo "[WARN] HurrupAM.service not found!"
                make_service
                echo "[INFO] Create Hurryup service."
                systemctl enable HurryupAM
                echo "[INFO] Successfully enabl HurryupAM.service."
                systemctl start HurryupAM
                echo "[INFO] Successfully start HurryupAM.service."
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
                echo "[INFO] Successfully install $agent_file.  ->   $agent_install_path "
        fi


        # Check log directory
        if [ -d "$log_dir_path" ]; then
                echo "[+] hurryup log directory already created.  -> $log_dir_path"
        else
                mkdir $log_dir_path
                echo "[INFO] Successfully create hurryup log directory.  ->  $log_dir_path"
                mkdir $log_manager_path
                echo "[INFO] Successfully create AgentManager log directory.  ->  $log_manager_path"
                mkdir $log_and_setupfile_path
                echo "[INFO] Successfully create Agent log directory  ->  $log_and_setupfile_path"
        fi

        # Check service file and execute it.
        enable_service
}


#-----------------------------------------------
function uninstall(){

        echo ""
        echo "[WARN] This operation might lose all data gnerated of Agent program of the Hurryup solution !!"
        echo ""
        echo "Do you uninstall Hurryup Agent program? <y/n> : "

        while true; do
                read -p "Do you uninstall Hurryup Agent program? <y/n> : " user_answer
                case user_answer in
                y)      systemctl disable HurrupAM
                        service_file_path
                        rm -rf $agent_install_path
                        rm -rf $log_dir_path
                        ;;
                n)      exit 1
                        ;;
                *) echo "Please enter your answer 'yes or no' <y/n>"
                        ;;
                esac
        done

        #inform about delete
        echo "[INFO] Successfully disable system service.  ->  $service_file_path"
        echo "[INFO] Successfully delete system service file.  ->  $HurryupAM.service"
        echo "[INFO] Successfully delete Hurryup agent file.  ->  $agent_install_all_path"
        echo "[INFO] Successfully delete Hurryup log files.
                        ->      $log_manager_path
                                $log_manager_path
                                $log_dir_path"

        echo ""
        echo "[INFO] Complete deleted Hurryup Agent program."
        exit 1
}


#-----------------------------------------------
function disable_servise(){
        if [ -f "$service_file_path" ]; then
                systemctl disable HurryupAM
                echo "[INFO] Successfully disable HurryupAM.service."
        else
                echo "[WARN] HurryupAM.service not found !"
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

