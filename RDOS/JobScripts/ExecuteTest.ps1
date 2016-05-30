param(
    [string]$TestCategory,
    $paramHT
)

#TODO:
function PringUsage()
{
    
}
    
#Import modules
Import-Module .\ConfigFactory.psm1 -Force

#Mandatory Params
$CommonParams = @("NETUSER","NETUSER_PWD","TestLisaDir","RESTSVCURL")
CheckParam($paramHT, $CommonParams)
$NETUSER=$paramHT["NETUSER"]
$NETUSER_PWD = $paramHT["NETUSER_PWD"]
$TestLisaDir = $paramHT["TestLisaDir"]
$RESTSVCURL = $paramHT["RESTSVCURL"]

#Optional Params
$dbgLevel= GetParameter $paramHT "dbgLevel" 5
$lisaDbglevel= GetParameter $paramHT "lisaDbgLevel" 10

[array]$HVServers = $paramHT["HVServers"] 
[array]$Hostnames = $paramHT["HostNames"]
$TestMatrix = $paramHT["TestMatrix"]

$HVServerReq = 0#How many server are required
Switch($TestCategory)
{
    "Feature" {
        $HVServerReq = 1
    }

    "LocalDiskStress" {
        $HVServerReq = 1
    }
        
    "RebootStress" {
        $HVServerReq = 1
    }

    "XStoreStress" {
        $HVServerReq = 1
    }

    "XStoreTrim" {
        $HVServerReq = 1
    }

    "NetworkStress" {
        CheckParam($paramHT, @("testMode"))
        $testMode=$paramHT["testMode"]
        if($testMode.StartsWith("INTER-"))
        {
            $HVServerReq = 2
        }else{
            $HVServerReq = 1
        }
    }
    default {
        PrintUsage
    }
}

$errorPref = $ErrorActionPreference
$ErrorActionPreference = "silentlycontinue"

# Get test machine resources
$NeedReleaseHVServer = $false

# If specified $Hostnames, will request HVServerByName 
if($Hostnames)
{
    if(!($Hostnames.Count -eq $HVServerReq))
    {
        Write-Host "The number of host specified by Hostnames is less than $HVServerReq required by given test. Abort test execution."
        exit 1
    }

    foreach($hname in $Hostnames)
    {
        $HVServer = RequestHVServerByName $RESTSVCURL $hname 3
        if(!$HVServer)
        {
            Write-Host "Request HVServer failed, abort ExecuteTest"
            exit 1
        }
    
        #Refresh RDOS build if necessary
        #Todo: use start-job
        if(![String]::IsNullOrEmpty($RDOSVHDDIRSRC)){
            $invokeResult = RefreshRDOSBuild $NETUSER $NETUSER_PWD $RDOSVHDDIRSRC $HVServer
            if(!$invokeResult){
                Write-Host "Refresh RDOS build failed, abort ExecuteTest"
                exit 1
            }
        }
        $HVServers+=$HVServer
        $HVServer = $null
    }
}

#Otherwise, just request HVServer 
while(!$HVServers -or ($HVServers.Count -lt $HVServerReq))
{        
    $HVServer = RequestHVServer $RESTSVCURL 300
    if(!$HVServer)
    {
        Write-Host "Request HVServer failed, abort ExecuteTest"
        exit 1
    }
    
    #Refresh RDOS build if necessary
    #Todo: use start-job
    if(![String]::IsNullOrEmpty($RDOSVHDDIRSRC)){
        $invokeResult = RefreshRDOSBuild $NETUSER $NETUSER_PWD $RDOSVHDDIRSRC $HVServer
        if(!$invokeResult){
            Write-Host "Refresh RDOS build failed, abort ExecuteTest"
            exit 1
        }
    }
    $HVServers+=$HVServer
    $NeedReleaseHVServer = $true
    $HVServer = $null
}

foreach ($server in $HVServers)
{
    $server | Add-Member -NotePropertyName InitVMVHDRoot -NotePropertyValue $server.VMVHDRoot
    $server | Add-Member -NotePropertyName InitVmadminRoot -NotePropertyValue $server.vmadminRoot
}

$paramHT["HVServers"] = $HVServers
$testConfigs = GenerateTestConfig $TestCategory $paramHT

$baseRdosDir = Resolve-Path ..
$resultLogDir = "$baseRdosDir\TestResults\$env:BUILD_NUMBER"
del $baseRdosDir\LastTestResult -Recurse -Force -ErrorAction SilentlyContinue

[int] $count = 0

foreach($testconfig in $testConfigs)
{
    # Execute test
    $fileName = "config-$TestCategory$count.xml"
    $testConfig|Out-File .\AutoRDOS\auto_rdos\$fileName -Encoding utf8 -Force

    pushd .\AutoRDOS\auto_rdos
    & .\auto_rdos.ps1 $fileName -dbgLevel $dbgLevel -lisaDbgLevel $lisaDbglevel -logDir "$resultLogDir\$TestCategory$count"
    popd

    #find testresult

    #rerun failed test

    $count++;
}

Copy-Item $resultLogDir $baseRdosDir\LastTestResult -Recurse

#Release resource
if ($NeedReleaseHVServer){
    foreach($HVServer in $HVServers){
        ReleaseHVServer $RESTSVCURL $HVServer.HostName
    }
}

$ErrorActionPreference = $errorPrefs
