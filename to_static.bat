@echo off

set NETWORK_NAME="���[�J�� �G���A�ڑ�"

set IP=
set SUBNET_MASK=
set DEFAULT_GATEWAY=
set PRIMARY_DNS=
set SECONDARY_DNS=

rem �Œ�IP�̐ݒ�
netsh interface ip set address %NETWORK_NAME% static %IP% %SUBNET_MASK% %DEFAULT_GATEWAY%
rem �v���C�}��DNS�̐ݒ�
netsh interface ip set dns %NETWORK_NAME% static %PRIMARY_DNS%
rem �Z�J���_��DNS�̐ݒ�
netsh interface ip add dns %NETWORK_NAME% %SECONDARY_DNS%