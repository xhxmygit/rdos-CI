@echo off
rem CopyRDOSVHD [username] [password] [SRC] [DST]

REM it's possible for net use to fail for multiple connection, but that doesn't break copy vhd
@echo on
net use %3 /user:%1 %2	
xcopy /Y %3 %4