## Hurryup Agent Install Usage

1. ubuntu_server_release.zip 사용자 home 디렉토리에 압축 해제합니다.
    ```
    unzip ubuntu_server_release.zip -d ubuntu_server_release
    ```
2. 디렉토리 내부로 이동합니다.
    ```
    cd ubuntu_server_release
    ```
3. install.sh 권한을 755로 설정합니다.
    ```
    sudo chmod 755 installer.sh
    ```
4. 관리자 권한으로 installer.sh를 실행 시킵니다.
    ```
    sudo ./installer.sh -i
    ```
5. 서비스 동작 상태를 확인합니다.
    ```
    sudo systemctl status HurryupAM
    ```