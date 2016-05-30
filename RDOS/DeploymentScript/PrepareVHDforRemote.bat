@echo off
REM Usage: PrepareVHDforRemtoe.bat [PathToVHD] [DriverLTR] 
REM Description: Add task to configure firewall to allow remote connection and change default password 
REM Author: weyao@microsoft.com

@setlocal ENABLEEXTENSIONS ENABLEDELAYEDEXPANSION
:CheckParam
if "%1" == "" goto :USAGE
SET VHDPath=%1
if "%2" == "" goto :USAGE
SET VHDLetter=%2

:Start
CALL :GetOSVersion
REM Mount target VHD
IF "!OSVersion!"=="BL" powershell mount-diskimage %VHDPath%
IF "!OSVersion!"=="W8" vhdctrl -m %VHDPath%

set "VHDVolume="
call :FINDVHDVOLUME
echo VHDVolume is %VHDVolume%
REM Assign letter to vdisk (TODO, either fixed disk layout or dynamic detect VHD volume needed
(echo select volume %VHDVolume% && echo assign letter=%VHDLetter%)|diskpart

REM Prepare for generate Unattended.xml, inject step to turn-off firewall in stage 'Specialized', its bad to turndown firewall tatally consider to narrow down the hole
rename %VHDLetter%:\Windows\panther\unattend\TargetUnattend-SecondPart.xml TargetUnattend-SecondPart_bak.xml
copy TargetUnattend-SecondPart.xml %VHDLetter%:\Windows\panther\unattend /Y

rename %VHDLetter%:\Windows\panther\unattend\TargetUnattend-ThirdPart.xml TargetUnattend-ThirdPart_bak.xml
copy TargetUnattend-ThirdPart.xml %VHDLetter%:\Windows\panther\unattend /Y

REM Unmount the RDOS VHD
IF "!OSVersion!"=="BL" powershell dismount-diskimage %VHDPath%
IF "!OSVersion!"=="W8" vhdctrl -um %VHDPath%
goto :EOF

:USAGE
echo Usage: PrepareVHDforRemote.bat [PathToVHD] [DriverLTR]
echo Example: todo..
:ENDUSAGE

:FINDVHDVOLUME
FOR /F "delims=" %%G IN ('echo list volume ^| DISKPART ^| findstr /i /c:Windows') do (

	 for /f "tokens=1,2,3,4,5,6,7,8,9,10,11,12" %%a in ('echo %%G') do (
	 
		if /i "%%d"=="Windows" set "VHDVolume=%%b" & goto :DONEFINDVHDVOLUME
		if "%%d" NEQ "" goto :DONEFINDVHDVOLUME

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
