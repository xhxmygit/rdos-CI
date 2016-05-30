@echo off
REM
REM 	Copyright (c) 1012 Microsoft Corporation
REM
REM Abstract:
REM 	Machine setup script #1 of 2. Reboot required.
REM
REM Usage:
REM 	setup_SAFE1.cmd
REM
REM Author: 
REM    gulu
REM

@setlocal ENABLEEXTENSIONS ENABLEDELAYEDEXPANSION
set "SysLtr=C"
if "%1" NEQ "" (
	set "SysLtr=%1"
) else (
	CALL :GetOSVersion
	IF "!OSVersion!"=="" Echo This version of OS is not supported by this script. & exit /b 1
	echo OSVersion=!OSVersion!

	IF /i NOT "!OSVersion!" == "LH" (
	   Echo Checking system partition....
	   call :ExposeSystemPartition
		if "%SysLtr%" == "" echo Failed to identify system partition and assign a drive letter. & exit /b 1
	)
)

label %systemdrive% SafeOS
bcdedit /set {current} description "SafeOS-!OSVersion!
echo.
call bcdedit /set testsigning on
echo.
echo takeown /F %SysLtr%:\bootmgr
call takeown /F %SysLtr%:\bootmgr
if %errorlevel% GEQ 1 echo Failed to take down %SysLtr%:\bootmgr & exit /b 1
echo.
echo icacls %SysLtr%:\bootmgr /grant %USERDOMAIN%\%USERNAME%:F
call icacls %SysLtr%:\bootmgr /grant %USERDOMAIN%\%USERNAME%:F
if %errorlevel% GEQ 1 echo Failed get ownership of %SysLtr%:\bootmgr, or %SysLtr%:\bootmgr doest not exist. & exit /b 1
echo.
echo attrib -h -r -s %SysLtr%:\bootmgr
call attrib -h -r -s %SysLtr%:\bootmgr
if %errorlevel% GEQ 1 echo Failed to change attribute of %SysLtr%:\bootmgr & exit /b 1
echo.
echo xcopy /y bootmgr %SysLtr%:\bootmgr
call xcopy /y bootmgr %SysLtr%:\bootmgr
if %errorlevel% GEQ 1 echo Failed to copy bootmgr to replace %SysLtr%:\bootmgr & exit /b 1
echo.
@endlocal
echo shutdown in 10 seconds ...
timeout /t 10 >nul
shutdown -r -t 0



:GetOSVersion
SET OSVersion=
VER | FINDSTR /L "6.0." > NUL
IF %ERRORLEVEL% EQU 0 SET OSVersion=LH
VER | FINDSTR /L "6.1." > NUL
IF %ERRORLEVEL% EQU 0 SET OSVersion=R2
VER | FINDSTR /L "6.2." > NUL
IF %ERRORLEVEL% EQU 0 SET OSVersion=W8
VER | FINDSTR /L "6.3." > NUL
IF %ERRORLEVEL% EQU 0 SET OSVersion=BLUE
goto :EOF



:ExposeSystemPartition
set "SystemVolume="
call :FindSystemVolume
if "!SystemVolume!" NEQ "" (
    set "VolumeDriveLetter="
    call :QueryVolumeDriveLetter !SystemVolume!
	echo VolumeDriveLetter = !VolumeDriveLetter!
    if "!VolumeDriveLetter!" == "" (
        ( echo select volume %SystemVolume% && echo assign letter=z) | DISKPART
		if %errorlevel% GEQ 1 echo Failed to assign letter to volume !VolumeDriveLetter! & exit /b 1
		set "SysLtr=Z"
	) else (
		set "SysLtr=!VolumeDriveLetter!"
	)
) else (
   echo Cannot identify system partition.
)
goto :EOF

:FindSystemVolume
set "SystemVolume="
FOR /F "delims=" %%G IN ('echo list volume ^| DISKPART ^| findstr /i /c:System') do (

	 for /f "tokens=1,2,3,4,5,6,7,8,9,10,11,12" %%a in ('echo %%G') do (
	 
		if /i "%%l"=="System" set "SystemVolume=%%b" & goto :DoneFindSystemVolume
		if "%%l" NEQ "" goto :DoneFindSystemVolume

		if /i "%%k"=="System" set "SystemVolume=%%b" & goto :DoneFindSystemVolume
		if "%%k" NEQ "" goto :DoneFindSystemVolume

		if /i "%%j"=="System" set "SystemVolume=%%b" & goto :DoneFindSystemVolume
		if "%%j" NEQ "" goto :DoneFindSystemVolume

		if /i "%%i"=="System" set "SystemVolume=%%b" & goto :DoneFindSystemVolume
		if "%%i" NEQ "" goto :DoneFindSystemVolume

		if /i "%%h"=="System" set "SystemVolume=%%b" & goto :DoneFindSystemVolume
		if "%%h" NEQ "" goto :DoneFindSystemVolume

	)
)
:DoneFindSystemVolume
goto :EOF

:QueryVolumeDriveLetter
set "VolumeDriveLetter="
for /f "tokens=4" %%a in ('^( echo select volume %1 ^&^& echo detail partition ^) ^| diskpart ^| findstr /r /c:"Volume [^^#]"' ) do (
	set "tempLtr=%%a"
	if "!tempLtr:~1,1!" == "" set "VolumeDriveLetter=%%a"
)
if %errorlevel% GEQ 1 echo Failed to query drive letter for volume %1 with using diskpart command. & exit /b 1
goto :EOF
