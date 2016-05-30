@echo off
REM
REM 	Copyright (c) 1012 Microsoft Corporation
REM
REM Abstract:
REM 	Machine setup script #2 of 2.
REM
REM Usage:
REM 	setup_SAFE2.cmd
REM
REM Author:
REM    weyao
REM

@setlocal ENABLEEXTENSIONS ENABLEDELAYEDEXPANSION
CALL :GetOSVersion
IF "!OSVersion!" NEQ "BL" (
	if not exist %SystemDrive%\Drivers\vhddisk md %SystemDrive%\Drivers\vhddisk
	call devcon install .\vhddisk.inf root\vhddiskprt
)
xcopy /y vhdctrl.exe %windir%\system32
xcopy /y vhdum.dll %windir%\system32
xcopy /y rdbcapi.dll %windir%\system32
REM sfpcopy.exe bcdedit.exe %windir%\system32\bcdedit.exe
xcopy /y ResetToSafeOS.cmd %windir%\system32
xcopy /y ResetToSafeOS.cmd %SystemDrive%\
xcopy /y setVHDBCD.cmd %windir%\system32
xcopy /y setVHDBCD.cmd %SystemDrive%\

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
