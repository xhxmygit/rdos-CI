@echo off
REM Usage: DeployRDOS [PathToVHD] [DriverLTR] [ServerName]
REM Prerequisite: copy all script and dll to c:\scripts
REM Prerequisite: 
REM Author: weyao@microsoft.com

@setlocal ENABLEEXTENSIONS ENABLEDELAYEDEXPANSION
:CheckParam
if "%1" == "" goto :USAGE
SET VHDPath=%1
if "%2" == "" goto :USAGE
SET VHDLetter=%2
SET ServerName=%3
REM default to use same Sever Name as safe OS
if "%3" == "" for /f  %%a in ('hostname') do set ServerName=%%a 

:Start
CALL :GetOSVersion
REM Mount target VHD

SET ISRDOS="0"
IF "!OSVersion!"=="BL" (
	powershell mount-diskimage %VHDPath%
	if %ERRORLEVEL% neq "0" (
		SET ISRDOS="1"
		vhdctrl -m %VHDPath%
	)
) ELSE (
	SET ISRDOS="1"
	vhdctrl -m %VHDPath%
)

set "VHDVolume="
call :FINDVHDVOLUME
echo %VHDVolume%
REM Assign letter to vdisk (TODO, either fixed disk layout or dynamic detect VHD volume needed
(echo select volume %VHDVolume% && echo assign letter=%VHDLetter%)|diskpart

REM Prepare for generate Unattended.xml, inject step to turn-off firewall in stage 'Specialized', its bad to turndown firewall tatally consider to narrow down the hole
rename %VHDLetter%:\Windows\panther\unattend\TargetUnattend-SecondPart.xml TargetUnattend-SecondPart_bak.xml
copy %~dp0TargetUnattend-SecondPart.xml %VHDLetter%:\Windows\panther\unattend /Y

rename %VHDLetter%:\Windows\panther\unattend\TargetUnattend-ThirdPart.xml TargetUnattend-ThirdPart_bak.xml
copy %~dp0TargetUnattend-ThirdPart.xml %VHDLetter%:\Windows\panther\unattend /Y

REM Onine target preparation
cmd /c %VHDLetter%:\onlinetargetprep.cmd %VHDLetter% %ServerName% 0

REM Unmount the RDOS VHD

IF "!OSVersion!"=="BL" (
	if %ISRDOS%=="1" (
		vhdctrl -um %VHDPath%
	) ELSE (
		powershell dismount-diskimage %VHDPath%
	)
) ELSE (
	vhdctrl -um %VHDPath%
)
REM Edit boot configuration
cmd /c %~dp0setVHDBCD.cmd %VHDPath%

REM Done configuration and restart
shutdown /r /t 10
goto :EOF

:USAGE
echo Usage: DeployRDS.bat [PathToVHD] [DriverLTR] [ServerName]
echo Example: todo..
:ENDUSAGE
goto :EOF

:FINDVHDVOLUME
FOR /F "delims=" %%G IN ('echo list volume ^| DISKPART ^| findstr /i /c:Windows') do (

	 for /f "tokens=1,2,3,4,5,6,7,8,9,10,11,12" %%a in ('echo %%G') do (
	 
		if /i "%%d"=="Windows" set "VHDVolume=%%b"
	)
)
:DONEFINDVHDVOLUME

:GetOSVersion
SET OSVersion=
VER | FINDSTR /L "6.0." > NUL
IF %ERRORLEVEL% EQU 0 SET OSVersion=LH
VER | FINDSTR /L "6.1." > NUL
IF %ERRORLEVEL% EQU 0 SET OSVersion=R2
VER | FINDSTR /L "6.2." > NUL
IF %ERRORLEVEL% EQU 0 SET OSVersion=W8
VER | FINDSTR /L "6.3." > NUL
IF %ERRORLEVEL% EQU 0 SET OSVersion=BL
:DONE GetOSVersion

@endlocal
