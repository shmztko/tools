@echo off
rem DHCPの設定
set NETWORK_NAME="ローカル エリア接続"
netsh interface ip set address %NETWORK_NAME% dhcp