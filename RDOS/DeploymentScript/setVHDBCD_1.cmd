@echo off
setlocal ENABLEDELAYEDEXPANSION

if "%1" == "" goto usage
for /F "tokens=3,* delims= " %%i in ('bcdedit /create /d "%~nx1" /application osloader') do (
        set _ENTRY=%%i
        echo Entry: !_ENTRY!
        bcdedit /set !_ENTRY! device vhd=[%~d1]%~pnx1
        bcdedit /set !_ENTRY! osdevice vhd=[%~d1]%~pnx1
        bcdedit /set !_ENTRY! path \Windows\System32\winload.exe
        bcdedit /set !_ENTRY! inherit {bootloadersettings}
        bcdedit /set !_ENTRY! testsigning on
        bcdedit /set !_ENTRY! nointegritychecks on
        bcdedit /set !_ENTRY! systemroot \Windows
        bcdedit /set !_ENTRY! nx OptOut
        bcdedit /set !_ENTRY! debug on
        bcdedit /set !_ENTRY! ems on
        bcdedit /set !_ENTRY! hypervisordebug on
        bcdedit /set !_ENTRY! hypervisorlaunchtype auto
        bcdedit /displayorder !_ENTRY! /addLast
        bcdedit /set {bootmgr} default !_ENTRY!
        bcdedit /enum !_ENTRY!
)
goto end

:usage
echo Usage: %~nx0 VHD

:end
endlocal