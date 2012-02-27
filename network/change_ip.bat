@echo off
cmd /c netsh interface ip set address name="wan" source=static addr=58.68.226.227 mask=255.255.255.128 gateway=58.68.226.129 gwmetric=1
cmd /c netsh interface ip set dns name="wan" source=static addr=202.106.0.20
cmd /c netsh interface ip add dns name="wan" addr=202.106.196.115 index=2
echo -------------------------------------------------
echo Current ip address:
ipconfig /all
echo -------------------------------------------------
