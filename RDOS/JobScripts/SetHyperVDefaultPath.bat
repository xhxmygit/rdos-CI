set "DISKLABEL="
set RETRYCOUNT=3
:GETVOLLABEL
for /f "delims=" %%G in ('echo list vol ^| diskpart ^| findstr /i /r "Volume.*Stripe"') do (
	for /f "tokens=1,2,3,4,5,6,7,8" %%a in ('echo %%G') do (
		set DISKLABEL=%%c & goto SETHYPERVPATH
	)
)

:RETRY
if not %RETRYCOUNT% == 0 (
	set /a RETRYCOUNT=%RETRYCOUNT%-1
	goto GETVOLLABEL
)
goto :EOF

:SETHYPERVPATH
if "%DISKLABEL%" == "Stripe " (
	goto RETRY
)

pushd d:\vmadmin
if not "%DISKLABEL%" == "" (
	vmadmin setvhdroot "%DISKLABEL:~0,1%:\Hyper-V\Virtual Hard Disks"
	vmadmin setroot "%DISKLABEL:~0,1%:\Hyper-V"
)
popd
	