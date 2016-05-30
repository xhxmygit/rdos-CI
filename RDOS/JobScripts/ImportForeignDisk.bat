set "DISKNUM="
set RETRYCOUNT=3
:GETDISKNUM
for /f "delims=" %%G in ('echo list disk ^| diskpart ^| findstr /i /r "Disk.*Foreign"') do (
	for /f "tokens=1,2,3,4,5,6,7,8" %%a in ('echo %%G') do (
		set DISKNUM=%%b & goto IMPORTDISK
	)
)

if not %RETRYCOUNT% == 0 (
	set /a RETRYCOUNT=%RETRYCOUNT%-1
	goto GETDISKNUM
)
goto :EOF

:IMPORTDISK
if not "%DISKNUM%" == "" (
	echo select disk %DISKNUM%
	echo import
	echo exit
)|diskpart
	