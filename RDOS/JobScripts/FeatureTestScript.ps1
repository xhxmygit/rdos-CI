param(
    [string]$NETUSER = "redmond\lislab",
    [string]$NETUSER_PWD = "LisRocks!",
    [string]$TestLisaDir = "..\lisablue",
    [string]$SRCLISADIR = "\\wssgfsc\SHOSTC\rdos\Jenkins\AutoRDOS",
    [string]$DSTLISADIR = "AUTORDOS",
    [string]$RESTSVCURL = "http://rdoswebapi.azurewebsites.net",
    [bool]$run = $false,
    $dbgLevel = 11,
    $lisaDbglevel = 11,
    $HVServer,#If ommit $HVServer, test script will request&release HVServer
    [string]$RDOSVHDDIRSRC,#if specified, will refresh RDOS build on $HVServer
    $TestMatrix = @(@{"DistroVHDDir"="\\wssgfsc\SHOSTC\VHD\Prepared\CentosVIC"; "TestVMSizes"=@("XS","S")})
)
            
#Import modules
$MNs = Get-Module
foreach($MN in $MNs)
{
    if($($MN.Name) -eq "ConfigFactory")
    {
        Remove-Module -Name $($MN.Name)
    }
}
Import-Module .\ConfigFactory.psm1

$errorPref = $ErrorActionPreference
$ErrorActionPreference = "silentlycontinue"

# Get test machine resources
$NeedReleaseHVServer = $false
$retry = 0
while([String]::IsNullOrEmpty($HVServer))
{    
    $HVServer = RequestHVServer $RESTSVCURL
    if(!$HVServer)
    {
        $retry++
        Write-Debug "Failed to get HVServer! $retry times"
        if($retry -lt 3){
            sleep 30
            continue
        }
        else{
            exit 1
        }
    }
    
    #Refresh RDOS buidl
    if(![String]::IsNullOrEmpty($RDOSVHDDIRSRC)){
        $RDOSVHDDriver = $HVServer.RDOSVHDDir
        $tempFolderName = (get-date).ToShortDateString().Replace('/','_')
        $RDOSVHDDIRDST = Join-Path $RDOSVHDDriver -ChildPath $tempFolderName
        while(Test-Path $RDOSVHDDIRDST)
        {
            $fdsuffix = 0
            $tempFolderName_1 = "$tempFolderName_$dfsuffix"
            $RDOSVHDDIRDST = Join-Path $RDOSVHDDriver -ChildPath $tempFolderName_1
        }
        & .\InstallRDOS.ps1 $HVServer.HostName $HVServer.UserName $HVServer.Password $RDOSVHDDIRSRC $RDOSVHDDIRDST $NETUSER $NETUSER_PWD
       if($LASTEXITCODE -ne 0) {
            Write-Host "Install RDOS failed"
            exit 1  
        }
    }
    $NeedReleaseHVServer = $true
}

$RDOSHOST = $HVServer.HostName
$RDOSHOSTADMIN = $HVServer.UserName
$RDOSHOSTADMIN_PWD = $HVServer.Password
$DSTVHDDIR = $HVServer.VMVHDRoot
write-host "HostName: $RDOSHOST"

$testConfigs = @();
#Generate config file
foreach($testItem in $TestMatrix)
{
    $distroVHDDir = $testItem.DistroVHDDir
    Write-Host "Trying to find DistroInfo from $distroVHDDir"
    $distroInfo = DiscoverDistroInfo $distroVHDDir $NETUSER $NETUSER_PWD
    if(!$distroInfo){
        Write-Host "Failed to find distro info from $distroVHDDir"
        continue
    }else{

        foreach($testVMSize in $testItem.TestVMSizes)
        {
            $testInfo = CreateTestInfo "Featre-$testVMSize" "Feature.xsl" ".\Feature.ps1" "xml\RDOS_WS2012.xml"
            $testConfig = GenFeatureTestConfig $TestLisaDir $testInfo $testVMSize $distroInfo $HVServer
            $testConfigs += $testConfig
        }  
        # Copy VHD
        Remove-Item -Force .\remotecmd.bat
        
        $SRCVHDFILE = (Get-ChildItem -Path $distroVHDDir -Recurse -File $distroInfo.baseVhd).FullName
        $DSTVHDDIR = $HVServer.vmVhdRoot
        echo "net use $distroVHDDir /user:$NETUSER $NETUSER_PWD" | Out-File remotecmd.bat -Encoding ascii
        echo "xcopy /Y /S $SRCVHDFILE $DSTVHDDIR\" | Out-File remotecmd.bat -Append ascii

        #if($run){
            & .\PAExec.exe \\$RDOSHOST -u $RDOSHOSTADMIN -p $RDOSHOSTADMIN_PWD -c .\remotecmd.bat
        #}      
    }
}

[int] $count = 0
foreach($testconfig in $testConfigs)
{
    
    # Execute test
    $fileName = "config-feature$count.xml"
    $count++;
    $testConfig|Out-File .\AutoRDOS\auto_rdos\$fileName -Encoding utf8 -Force
    #if($run){
    pushd .\AutoRDOS\auto_rdos
    $
    & .\auto_rdos.ps1 $fileName -dbgLevel $dbgLevel -lisaDbgLevel $lisaDbglevel
    popd
    #}
}


#Release resource
if ($NeedReleaseHVServer){
    if (![String]::IsNullOrEmpty($RDOSHOST)){
        echo "Release test rdos host: $RDOSHOST"
        $RELURL = "$RESTSVCURL/api/HVServer?HostName=$RDOSHOST"
        echo $RELURL
        #http://connect.microsoft.com/PowerShell/feedback/details/836732/tcp-connection-hanging-in-close-wait-when-using-invoke-restmethod-with-put-or-delete#
        Invoke-WebRequest $RELURL -Method PUT
        if(!$?) {echo "Release RDOSHOST failed"}
    }
}

$ErrorActionPreference = $errorPref


