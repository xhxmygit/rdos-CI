param(
    [string] $RDOSHost,
    [string] $RDOSHostAdmin,
    [string] $RDOSHostAdminPwd
)

Push-Location
cd .\rdos\JobScripts
.\PAEXEC.exe \\$RDOSHost -u $RDOSHost\$RDOSHostAdmin -p "$RDOSHostAdminPwd" -c ".\SetHyperVDefaultPath.bat"
Pop-Location
