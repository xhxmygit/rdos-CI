@if "%_echo%"=="" echo off
@
setlocal enableextensions enabledelayedexpansion
@
if "%1"=="" goto usage
@
set MOUNTLTR=%1
@
@REM -------------------------------------------------------------------------
@REM Load registry hives for manipulation.
@REM -------------------------------------------------------------------------
@
echo Loading registry hives
reg load HKLM\%MOUNTLTR%software %MOUNTLTR%:\Windows\system32\config\software >nul
@
echo Removing the Legal Notice Registry Keys
reg delete hklm\%MOUNTLTR%software\Microsoft\Windows\CurrentVersion\Policies\System /v legalnoticecaption /f > nul
reg delete hklm\%MOUNTLTR%software\Microsoft\Windows\CurrentVersion\Policies\System /v legalnoticetext /f > nul


REM added pageheap for some executeable for host
reg.exe add "hklm\%MOUNTLTR%software\microsoft\windows nt\currentversion\image file execution options\osdiag.exe" /v "GlobalFlag" /t REG_DWORD /d 0x2000100 /f
reg.exe add "hklm\%MOUNTLTR%software\microsoft\windows nt\currentversion\image file execution options\osdiag.exe" /v "PageHeapFlags"  /t REG_DWORD /d 0x3 /f
reg.exe add "hklm\%MOUNTLTR%software\microsoft\windows nt\currentversion\image file execution options\blobstorageproxy.exe" /v "GlobalFlag"  /t REG_DWORD /d 0x2000100 /f
reg.exe add "hklm\%MOUNTLTR%software\microsoft\windows nt\currentversion\image file execution options\blobstorageproxy.exe" /v "PageHeapFlags"  /t REG_DWORD /d 0x3 /f
reg.exe add "hklm\%MOUNTLTR%software\microsoft\windows nt\currentversion\image file execution options\rdmonitoragent.exe" /v "GlobalFlag"  /t REG_DWORD /d 0x2000100 /f
reg.exe add "hklm\%MOUNTLTR%software\microsoft\windows nt\currentversion\image file execution options\rdmonitoragent.exe" /v "PageHeapFlags"  /t REG_DWORD /d 0x3 /f

@
@REM -------------------------------------------------------------------------
@REM Unload registry hives
@REM -------------------------------------------------------------------------
@
echo Unloading registry hives
reg unload HKLM\%MOUNTLTR%software >nul
@
@
goto cleanup
@
:usage
echo Offline Prep
echo.
echo OfflineTargetPrep.cmd VhdMountLtr
echo.
echo     VhdMountLtr  - Drive letter where the VHD is mounted, without the ':'
echo.
@
:cleanup
@
endlocal
