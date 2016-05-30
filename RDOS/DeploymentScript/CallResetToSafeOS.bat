@REM Script to Call ResetToSafeOS.bat
@setlocal ENABLEEXTENSIONS ENABLEDELAYEDEXPANSION

call :FINDDRVLTR
echo %SafeOSLTR%
%SafeOSLTR%:\ResetToSafeOS.cmd
goto :EOF

:FINDDRVLTR
FOR /F "delims=" %%G IN ('echo list volume ^| DISKPART ^| findstr /i /c:SafeOS') do (

	 for /f "tokens=1,2,3,4,5,6,7,8,9,10,11,12" %%a in ('echo %%G') do (
	 
		if /i "%%d"=="SafeOS" set "SafeOSLTR=%%c" & goto :FINDDRVLTR
		if "%%d" NEQ "" goto :FINDDRVLTR

	)
)
:FINDDRVLTR

@endlocal