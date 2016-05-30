@echo off
REM Reset the default OS to the SafeOS, and boot back to it.
REM by gulu

SETLOCAL ENABLEEXTENSIONS ENABLEDELAYEDEXPANSION
set "list="
set i=1
for /f "tokens=2" %%a in ('bcdedit /enum OSLOADER /v ^| findstr osdevice') do (
	set _dev=%%a
	if /i "!_dev:~0,4!" == "vhd=" (
		set j=1
		for /f "tokens=2" %%a in ('bcdedit /enum OSLOADER /v ^| findstr identifier') do (
			if "!i!" == "!j!" set "list=!list! %%a"
			set /a j=j+1
		)
	)
	if /i "!_dev:~0,5!" == "file=" (
		set j=1
		for /f "tokens=2" %%b in ('bcdedit /enum OSLOADER /v ^| findstr identifier') do (
			if "!i!" == "!j!" set "list=!list! %%b"
			set /a j=j+1
		)
	)
	if /i "!_dev!" == "unknown" (
		set j=1
		for /f "tokens=2" %%c in ('bcdedit /enum OSLOADER /v ^| findstr identifier') do (
			if "!i!" == "!j!" set "list=!list! %%c"
			set /a j=j+1
		)
	)
	set /a i=i+1
)
if not "%list%" == "" (
	for %%i in (%list%) do (
		echo bcdedit /delete %%i
		bcdedit /delete %%i
	)
)

echo shut down in 10 seconds...
timeout /t 10 > nul
shutdown /f /r /t 0
setlocal
