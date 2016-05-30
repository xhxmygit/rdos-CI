param(
    [string] $RDOSHost,
    [string] $RDOSHostAdmin,
    [string] $RDOSHostAdminPwd,
    [string] $RDOSVHDDIRSRC,
    [string] $RDOSVHDDIRDST,
    [string] $NETUSER = "redmond\lislab",
    [string] $NETUSERPwd = "LisRocks!"
)

# Copy Deployment Script to RDOSHost
$CurrentDir = Get-Location
Net use "\\$RDOSHost\c`$" /user:"$RDOSHost\$RDOSHostAdmin" "$RDOSHostAdminPwd"
if(Test-Path "\\$RDOSHost\c`$\DeploymentScript"){
   Remove-Item -Recurse -Force "\\$RDOSHost\c`$\DeploymentScript"
}
Copy-Item -Recurse -Force "$CurrentDir\RDOS\DeploymentScript" -destination "\\$RDOSHost\c`$\DeploymentScript"

# Copy RDOS VHD and Install
Push-Location
cd .\rdos\JobScripts
& .\PAExec.exe \\$RDOSHost -u $RDOSHost\$RDOSHostAdmin -p "$RDOSHostAdminPwd" -c ".\CopyAndInstallRDOS.bat" $NETUSER $NETUSERPwd $RDOSVHDDIRSRC $RDOSVHDDIRDST
Pop-Location
# Wait for install to complete
$count=0
while($count -le 30){
  sleep 30
  $count+=1
  ping $RDOSHost -n 1
  if($LASTEXITCODE -eq 1) {break}
};
write-host "WaitRebooting"; 
$count=0;
while($count -le 30){
  sleep 30;
  $count+=1;
  ping $RDOSHost -n 1;
  if($LASTEXITCODE -eq 0) {
    .\RDOS\JobScripts\PAEXEC.exe \\$RDOSHost -u $RDOSHost\$RDOSHostAdmin -p "$RDOSHostAdminPwd" whoami ;
    If($LASTEXITCODE -eq 0){break};
  }
};
if($count -ge 30){exit 1}

sleep 30
# Import foreign disk
Push-Location
cd .\rdos\JobScripts
.\PAEXEC.exe \\$RDOSHost -u $RDOSHost\$RDOSHostAdmin -p "$RDOSHostAdminPwd" -c ".\ImportForeignDisk.bat"
Pop-Location
