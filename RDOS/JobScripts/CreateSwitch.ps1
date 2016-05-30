param(
    [string] $RDOSHost,
    [string] $RDOSHostAdmin,
    [string] $RDOSHostAdminPwd,
    [string] $switchName,
    [string] $nicElementName
)

if ([String]::IsNullOrEmpty($nicElementName) -and [String]::IsNullOrEmpty($switchName))
{
    Write-Host "No NIC or switch name has been specified, do nothing."
}

#Query nicElementName using webapi if not specified

#Copy RDOS VHD and Install
Push-Location
cd .\rdos\JobScripts
& .\PAExec.exe \\$RDOSHost -u $RDOSHost\$RDOSHostAdmin -p "$RDOSHostAdminPwd" -c ".\RemoteCreateSwitch.bat" $nicElementName $switchName
Pop-Location

 