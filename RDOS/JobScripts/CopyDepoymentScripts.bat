@REM Copy DeploymentScritps from \\wssgfsc\shostc\RDOS\DeploymentScript to SafeOS
net use %3 /user:%1 %2	
del /S /Q %4
xcopy /Y %3 %4