#!/bin/bash
#======================================================================================================
# 목적 : BoB 10기 Hurryup Team의 SEDR-Agent, SEDR-Agent_Manager 구동을 위함.
# 내용 : /usr/local/bin 디렉터리에 로그를 수집하는 Agent 구동 파일 2개를 이동시키며,
#        이동 시킨 파일을 link한 서비스 파일(HurrypupAM.service) 1개를 생성하여 /etc/system/systemd/
#        경로에 저장하고 서비스에 등록 및 실행한다.
#
# Copyright 2021 all reserved Team Hurryup
# Author : Lee Joon Sung
#======================================================================================================





#------------------------------------------------------------------------------------------------------
# check privelige
if [ "$EUID" -ne 0 ];then 
        echo ""
        echo "<  HurryUp SEDR solution Agent installer v0.2  >"
        echo "[WARN] root 권한으로 스크립트를 실행하여 주십시오."
	exit
fi

#------------------------------------------------------------------------------------------------------
# Agent, Agent_Manager direction
agent_file="./Agent/HurryUp_Agent"
manager_file="./Manager/HurryUp_Agent_Manager"

# Agent, Agent_Manager file install path
agent_install_path="/usr/local/bin/"

# log directory direction
log_dir_path="/var/log/hurryup/"
log_manager_path="/var/log/hurryup/manager/"
log_and_setupfile_path="/var/log/hurryup/agent/"

# service file install direction
service_file_path="/etc/systemd/system/HurryupAM.service"

# install & delete options
agent_install_path="/usr/local/bin/HurryUp_Agent"
manager_install_path="/usr/local/bin/HurryUp_Agent_Manager"

#------------------------------------------------------------------------------------------------------
# Simple interface and usage
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
        echo "          -h     :   show this message (usage help page)"
        echo "          -i     :   install Hurryup agent program"
        echo "          -u     :   uninstall Hurryup agent program"
        echo "          -e     :   enable HurryupAM agent to system service"
        echo "          -d     :   disable HurryupAM agent to system service"
        echo ""
        exit 1
}


# check the option from input command. if options are not available, just print help page.
if [ -z $1 ]; then
        echo ""
        echo "<  HurryUp SEDR solution Agent installer v0.2  >"
        usage
        echo ""
        exit 1
fi

#------------------------------------------------------------------------------------------------------
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

        chmod 755 $service_file_path
        echo "[INFO] Successfully regist HurryupAM.service -> $service_file_path"
        fi
}

#------------------------------------------------------------------------------------------------------
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

#------------------------------------------------------------------------------------------------------
function install(){

        # Copy Agent file to /usr/local/bin directory
        if [ -e "$agent_install_path" ]; then
                echo "[+] $agent_install_path already installed.  ->  $agent_install_path"
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
                cp -r $manager_file $manager_install_path
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

#------------------------------------------------------------------------------------------------------
function uninstall(){

        echo ""
        echo "[WARN] This operation might lose all data gnerated of Agent program of the Hurryup solution !!"
        echo ""


        echo ""
        echo "#-------------------------------------------------------------------------"
        
        # stop & disable & delete HurryupAM service
        systemctl stop HurryupAM
        echo "[INFO] Successfully stop HurryupAM service"
        systemctl disable HurryupAM
        echo "[INFO] Successfully disable HurryupAM service.  ->  $service_file_path"
        rm -rf $service_file_path
        echo "[INFO] Successfully delete HurryupAM service file.  ->  $service_file_path"

        # delete Agent & Agent_manager file
        rm -rf $agent_install_path
        echo "[INFO] Successfully delete Hurryup agent file.  ->  $agent_install_path"
        rm -rf $manager_install_path
        echo "[INFO] Successfully delete Hurryup manager file  ->  $manager_install_path"
        rm -rf $log_dir_path
        echo "[INFO] Successfully delete Hurryup log files.
                                        ->      $log_manager_path
                                                $log_manager_path
                                                $log_dir_path"

        echo "#-------------------------------------------------------------------------"
        echo ""
        echo "[INFO] Complete deleted Hurryup Agent program."

}

#------------------------------------------------------------------------------------------------------
function disable_servise(){
        if [ -f "$service_file_path" ]; then
                systemctl stop HurryupAM
                echo "[INFO] Successfully stop HurryupAM.service."
                systemctl disable HurryupAM
                echo "[INFO] Successfully disable HurryupAM.service."
        else
                echo "[WARN] HurryupAM.service not found. It seems already deleted or not installed !"
        fi
}

#------------------------------------------------------------------------------------------------------
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

#------------------------------------------------------------------------------------------------------
