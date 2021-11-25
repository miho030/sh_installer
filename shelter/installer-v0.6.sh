#!/bin/bash

#-----------------------------------------------
rasp_file="./Agent/armv7_32bit/HurryUp_Agent"
ubuntu_file="./Agent/ubuntu/HurryUp_Agent"
rasp_manager_file="./Manager/armv7_32bit/HurryUp_Agent_Manager"
ubuntu_manager_file="./Manager/ubuntu/HurryUp_Agent_Manager"

check_raspberry_comm=$(uname -a | grep raspberrypi | awk '{print $2}')
check_ubuntu_comm=$(uname -a | grep Ubuntu | awk '{print $2}')

agent_install_path="/usr/local/bin/"

log_dir_path="/var/log/hurryup/"
log_manager_path="/var/log/hurryup/manager/"
log_and_setupfile_path="/var/log/hurryup/agent/"
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
Restart=on-failure

[Install]
WantedBy=multi-user.target " >> $service_file_path


        echo "[INFO] Successfully regist HurryupAM.service -> $service_file_path"
        chmod 755 service_file_path
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
                echo "[INFO] Successfully enable HurryupAM.service."
                systemctl start HurryupAM
                echo "[INFO] Successfully start HurryupAM.service."
        fi
}


#-----------------------------------------------
function install(){




        # Check Os platform name and load several agent file.
        if [ $check_raspberry_comm == "raspberrypi" ]; then
                echo "[INFO] Checking OS platform name.  ->  $check_raspberry_comm"
                agent_file=$rasp_file
                manager_file=$rasp_manager_file
        else
                if [ $check_ubuntu_comm == "ubuntu" ]; then
                        echo "[INFO] Checking OS platform name.  ->  $check_ubuntu_comm"
                        agent_file=$ubuntu_file
                        manager_file=$ubuntu_manager_file
                fi
        fi

        # Setup agent, manager file directory according to OS platform
        agent_install_all_path="/usr/local/bin/$agent_file"
        manager_install_path="/usr/local/bin/$manager_file"


        # Copy Agent file to /usr/local/bin directory
        if [ -e "$agent_install_all_path" ]; then
                echo "[+] $agent_file already installed.  ->  $agent_install_path"
        else
                chmod 755 $agent_file
                cp -r $agent_file $agent_install_path
                echo "[INFO] Successfully install $agent_file.  ->   $agent_install_path"
        fi

        # Copy Manager file to /usr/local/bin directory
        if [ -e "$manager_install_path" ]; then
                echo "[+] $manager_file already installed.  ->  $manager_install_path"
        else
                chmod 755 $manager_file
                cp -r $manager_file $agent_install_path
                echo "[INFO] Successfully install $manager_file.  ->  $manager_install_path"
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

        systemctl stop HurryupAM
        systemctl disable HurrupAM
        rm -rf $service_file_path
        rm -rf $agent_install_path

        echo ""
        echo "#-------------------------------------------------------------------------"
        systemctl stop HurryupAM
        echo "[INFO] Successfully stop HurryupAM service
        systemctl disable HurryupAM
        echo "[INFO] Successfully disable HurryupAM service.  ->  $service_file_path"
        rm -rf $service_file_path
        echo "[INFO] Successfully delete stop service file.  ->  $service_file_path"
        rm -rf $agent_file
        echo "[INFO] Successfully delete Hurryup agent file.  ->  $agent_install_all_path"
        rm -rf $manager_file
        echo "[INFO] Successfully delete Hurryup manager file  ->  $agent_manager_file"
        rm -rf $log_dir_path
        echo "[INFO] Successfully delete Hurryup log files.
                                        ->      $log_manager_path
                                                $log_manager_path
                                                $log_dir_path"

        echo "#-------------------------------------------------------------------------"
        echo ""
        echo "[INFO] Complete deleted Hurryup Agent program."
}


#-----------------------------------------------
function disable_servise(){
        if [ -f "$service_file_path" ]; then
                systemctl stop HurryupAM
                echo "[INFO] Successfully stop HurryupAM.service."
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


#-----------------------------------------------
