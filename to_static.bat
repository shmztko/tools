@echo off

set NETWORK_NAME="ローカル エリア接続"

set IP=
set SUBNET_MASK=
set DEFAULT_GATEWAY=
set PRIMARY_DNS=
set SECONDARY_DNS=

rem 固定IPの設定
netsh interface ip set address %NETWORK_NAME% static %IP% %SUBNET_MASK% %DEFAULT_GATEWAY%
rem プライマリDNSの設定
netsh interface ip set dns %NETWORK_NAME% static %PRIMARY_DNS%
rem セカンダリDNSの設定
netsh interface ip add dns %NETWORK_NAME% %SECONDARY_DNS%