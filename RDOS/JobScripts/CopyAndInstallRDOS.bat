@echo off
rem XXX [username] [password] [SRC] [DST]

REM it's possible for net use to fail for multiple connection, but that doesn't break copy vhd
@echo on
net use %3 /user:%1 %2	
xcopy /Y %3 %4 

@setlocal ENABLEEXTENSIONS ENABLEDELAYEDEXPANSION

call :FINDRDOSVHD %4
echo %RDOSVHD%
call c:\DeploymentScript\DeployRDOS.bat %4\%RDOSVHD% u
goto :EOF

:FINDRDOSVHD
FOR /F "delims=" %%G IN ('dir %1 ^| findstr /i /c:target.vhd') do (

	 for /f "tokens=1,2,3,4,5,6,7,8,9,10,11,12" %%a in ('echo %%G') do (
	 
		set "RDOSVHD=%%e" & goto :FINDDRVLTR
		
	)
)
:FINDRDOSVHD

@endlocal