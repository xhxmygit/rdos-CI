# Define test categories
Set-Variable FeatureTest "Feature" -Option ReadOnly -Scope Script
Set-Variable RebootStressTest "RebootStress" -Option ReadOnly -Scope Script
Set-Variable LocalDiskStressTest "LocalDiskStress" -Option ReadOnly -Scope Script
Set-Variable XStoreStressTest "XStoreStress" -Option ReadOnly -Scope Script
Set-Variable XStoreTrimTest "XStoreTrim" -Option ReadOnly -Scope Script
Set-Variable NetworkStressTest "NetworkStress" -Option ReadOnly -Scope Script

<#
    Generate config file for different TestCategory
    Return: On success, return an array of test configs
#>
function GenerateTestConfig($TestCategory, $paramHT)
{
    #Mandatory Params
    $CommonParams = @("NETUSER","NETUSER_PWD","TestLisaDir","RESTSVCURL", "HVServers", "ArpServerIP")
    $checked = CheckParam($paramHT, $CommonParams)
    $NETUSER=$paramHT["NETUSER"]
    $NETUSER_PWD = $paramHT["NETUSER_PWD"]
    $TestLisaDir = $paramHT["TestLisaDir"]
    $RESTSVCURL = $paramHT["RESTSVCURL"]
    [array]$HVServers = $paramHT["HVServers"] 
    $ArpServerIP = $paramHT["ArpServerIP"]
    $TestMatrix = $paramHT["TestMatrix"]
    $XSVhdMode= GetParameter $paramHT "vhdMode" $null
    $FeatureTestCases = GetParameter $paramHT "TestCases" $null
    
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
                # Set different VHD root for each test to avoid violation, so that multiple test can run on the same RDOS host in parallel
                $desVmAdminDirName = $distroInfo.DistroName + "-$TestCategory-$testVMSize"
                if ($XSVhdMode){
                    $desVmAdminDirName += "-$XSVhdMode"
                }
                foreach($server in $HVServers)
                {
                    $server.VMVHDRoot = [IO.Path]::Combine($server.InitVMVHDRoot, $distroInfo.DistroName)
                    $server.vmadminRoot = [IO.Path]::Combine($server.InitVmadminRoot, $desVmAdminDirName)
                }
                Switch($TestCategory)
                {
                    "$FeatureTest"{
                        $testname = "Feature-$testVMSize"
                        $testInfo = CreateTestInfo -testName $testname -testTemplate "Feature.xsl" -testScript ".\Feature.ps1" -baseXml "xml\RDOS_WS2012.xml" -cases $FeatureTestCases
                        $testConfig = GenFeatureTestConfig $TestLisaDir $testInfo $testVMSize $distroInfo $HVServers $ArpServerIP
                        $testConfigs += $testConfig
                        break;
                    }

                    "$RebootStressTest"{
                        $RebootTestParams = @("timeout","REBOOT_COUNT","XStoreURL", "XStoreAccountName", "XStoreContainer", "XStoreAccessKey")
                        $checkResult = CheckParam($paramHT, $RebootTestParams)
                        if(!$checkResult)
                        {
                            Write-Host "Missing parameter for RebootTest"
                        }
                        $RebootTimeout = $paramHT["timeout"]
                        $Reboot_Count =$paramHT["REBOOT_COUNT"]
                        $XStoreURL = $paramHT["XStoreURL"]
                        $XStoreAccountName = $paramHT["XStoreAccountName"]
                        $XStoreContainer = $paramHT["XStoreContainer"]
                        $XStoreAccessKey = $paramHT["XStoreAccessKey"]

                        $testname = "XStoreReboot-$testVMSize"
                        $testInfo = CreateTestInfo -testName $testname -testTemplate "XStoreReboot.xsl" -testScript ".\XStoreReboot.ps1" -timeout $RebootTimeout -testParams @{"REBOOT_COUNT"=$Reboot_Count}
                        $testConfig = GenRebootTestConfig $TestLisaDir $testInfo $testVMSize $distroInfo $XStoreURL $XStoreAccountName $XStoreContainer $XStoreAccessKey $HVServers $ArpServerIP
                        $testConfigs += $testConfig
                        break;
                    }

                    "$LocalDiskStressTest"{
                        $localDiskTestParams = @("timeout","IOZONE_PARAMS","XStoreURL", "XStoreAccountName", "XStoreContainer", "XStoreAccessKey")
                        $checkResult = CheckParam($paramHT, $localDiskTestParams)
                        if(!$checkResult)
                        {
                            Write-Host "Missing parameter for LocalDiskStressTest"
                        }
                        $Timeout = $paramHT["timeout"]
                        $IOZone_Params =$paramHT["IOZONE_PARAMS"]
                        $XStoreURL = $paramHT["XStoreURL"]
                        $XStoreAccountName = $paramHT["XStoreAccountName"]
                        $XStoreContainer = $paramHT["XStoreContainer"]
                        $XStoreAccessKey = $paramHT["XStoreAccessKey"]

                        $testname = "LocalDisk-$testVMSize"
                        $testInfo = CreateTestInfo -testName $testname -testTemplate "LocalDisk.xsl" -testScript ".\LocalDisk.ps1" -timeout $Timeout -testParams @{"IOZONE_PARAMS"=$IOZone_Params}
                        $testConfig = GenLocalDiskTestConfig $TestLisaDir $testInfo $testVMSize $distroInfo $XStoreURL $XStoreAccountName $XStoreContainer $XStoreAccessKey $HVServers $ArpServerIP
                        $testConfigs += $testConfig
                        break;
                    }

                     "$XStoreStressTest"{
                        $xstoreDiskTestParams = @("vhdMode", "timeout","IOZONE_PARAMS","XStoreURL", "XStoreAccountName", "XStoreContainer", "XStoreAccessKey")
                        $checkResult = CheckParam($paramHT, $xstoreDiskTestParams)
                        if(!$checkResult)
                        {
                            Write-Host "Missing parameter for XStoreDiskStressTest"
                        }
                        $vhdMode = $paramHT["vhdMode"]
                        $Timeout = $paramHT["timeout"]
                        $IOZone_Params =$paramHT["IOZONE_PARAMS"]
                        $XStoreURL = $paramHT["XStoreURL"]
                        $XStoreAccountName = $paramHT["XStoreAccountName"]
                        $XStoreContainer = $paramHT["XStoreContainer"]
                        $XStoreAccessKey = $paramHT["XStoreAccessKey"]

                        $testname = "XStoreDisk-$testVMSize-Option$vhdMode"
                        $testInfo = CreateTestInfo -testName $testname -testTemplate "XStoreDisk.xsl" -testScript ".\XStoreDisk.ps1" -vhdMode $vhdMode -timeout $Timeout -testParams @{"IOZONE_PARAMS"=$IOZone_Params}
                        $testConfig = GenXSDiskTestConfig $TestLisaDir $testInfo $testVMSize $distroInfo $XStoreURL $XStoreAccountName $XStoreContainer $XStoreAccessKey $HVServers $ArpServerIP
                        $testConfigs += $testConfig
                        break;
                    }
					
                     "$XStoreTrimTest"{
                        $xstoreTrimTestParams = @("vhdMode", "timeout","XStoreURL", "XStoreAccountName", "XStoreContainer", "XStoreAccessKey")
                        $checkResult = CheckParam($paramHT, $xstoreTrimTestParams)
                        if(!$checkResult)
                        {
                            Write-Host "Missing parameter for XStoreTrimTest"
                        }
                        $vhdMode = $paramHT["vhdMode"]
                        $Timeout = $paramHT["timeout"]
                        $XStoreURL = $paramHT["XStoreURL"]
                        $XStoreAccountName = $paramHT["XStoreAccountName"]
                        $XStoreContainer = $paramHT["XStoreContainer"]
                        $XStoreAccessKey = $paramHT["XStoreAccessKey"]

                        $testname = "XStoreTrim-$testVMSize-Option$vhdMode"
                        $testInfo = CreateTestInfo -testName $testname -testTemplate "XStoreTrim.xsl" -testScript ".\XStoreTrim.ps1" -vhdMode $vhdMode -timeout $Timeout
                        $testConfig = GenXSTrimTestConfig $TestLisaDir $testInfo $testVMSize $distroInfo $XStoreURL $XStoreAccountName $XStoreContainer $XStoreAccessKey $HVServers $ArpServerIP
                        $testConfigs += $testConfig
                        break;
                    }
					
                    "$NetworkStressTest"{
                        $networkTestParams = @("testMode", "iperfThreads", "iperfSeconds", "TARGET_SSHKEY", "MIMICARP_SERVER_SSHKEY" , "XStoreURL", "XStoreAccountName", "XStoreContainer", "XStoreAccessKey")
                        $checkResult = CheckParam($paramHT, $networkTestParams)
                        if(!$checkResult)
                        {
                            Write-Host "Missing parameter for NetworkStressTestParams"
                        }
                        $testMode = $paramHT["testMode"]
                        $iperfThreads = $paramHT["iperfThreads"]
                        $iperfSeconds =$paramHT["iperfSeconds"]
                        $TARGET_SSHKEY =$paramHT["TARGET_SSHKEY"]
                        $iperfSeconds =$paramHT["iperfSeconds"]
                        $MIMICARP_SERVER_SSHKEY = $paramHT["MIMICARP_SERVER_SSHKEY"]
                        $XStoreURL = $paramHT["XStoreURL"]
                        $XStoreAccountName = $paramHT["XStoreAccountName"]
                        $XStoreContainer = $paramHT["XStoreContainer"]
                        $XStoreAccessKey = $paramHT["XStoreAccessKey"]
                        
                        $testname = "NetworkStress-$testMode-$testVMSize"
                        $testInfo = CreateTestInfo -testName $testname -testTemplate "NetworkStress.xsl" -testScript ".\NetworkStress.ps1" -testMode $testMode -iperfThreads $iperfThreads -iperfSeconds $iperfSeconds -testParams @{"TARGET_SSHKEY"=$TARGET_SSHKEY;"MIMICARP_SERVER_SSHKEY"=$MIMICARP_SERVER_SSHKEY}
                        $testConfig = GenNetworkTestConfig $TestLisaDir $testInfo $testVMSize $distroInfo $XStoreURL $XStoreAccountName $XStoreContainer $XStoreAccessKey $HVServers $ArpServerIP
                        $testConfigs += $testConfig
                        break;
                    }
                }

                # Copy VHD for each test distro and test size on each test host
                foreach($HVServer in $HVServers){
                    if(!$HVServer){
                        Write-Host "Param:HVServers is empty."
                        return $null
                    }        
                    $RDOSHOST = $HVServer.HostName
                    $RDOSHOSTADMIN = $HVServer.UserName
                    $RDOSHOSTADMIN_PWD = $HVServer.Password
                    $DSTVHDDIR = $HVServer.VMVHDRoot
                    write-host "HostName: $RDOSHOST"
                
                    $SRCVHDFILE = (Get-ChildItem -Path $distroVHDDir -Recurse -File $distroInfo.baseVhd).FullName
                    $DSTVHDDIR = $HVServer.vmVhdRoot
                    $DSTVHDFILE= [IO.Path]::Combine($DSTVHDDIR, $distroInfo.baseVhd)

                    $remoteBatch = $desVmAdminDirName + '.bat'
                    if (Test-Path .\$remoteBatch){
                        Remove-Item -Force .\$remoteBatch
                    }

                    $vmadminRoot = $server.vmadminRoot
                    echo "if not exist $vmadminRoot\ mkdir $vmadminRoot" | Out-File $remoteBatch -Encoding ascii
                    echo "copy /Y $vmadminRoot\..\vmadmin* $vmadminRoot" | Out-File $remoteBatch -Append ascii

                    echo "net use $distroVHDDir /user:$NETUSER $NETUSER_PWD" | Out-File $remoteBatch -Append ascii
                    echo "if not exist $DSTVHDDIR\ mkdir $DSTVHDDIR" | Out-File $remoteBatch -Append ascii
                    echo "if not exist $DSTVHDFILE goto copyvhd" | Out-File $remoteBatch -Append ascii
                    echo ":loop" | Out-File $remoteBatch -Append ascii
                    # Check whether the existing vhd file is written to by another process, if so, use ping to wait 5 seconds and then check again
                    echo "2>nul (>>$DSTVHDFILE (call )) && (goto:eof) || (ping 127.0.0.1 -n 5 >nul & goto loop)" | Out-File $remoteBatch -Append ascii
                    echo ":copyvhd" | Out-File $remoteBatch -Append ascii
                    echo "xcopy /Y /S $SRCVHDFILE $DSTVHDDIR\" | Out-File $remoteBatch -Append ascii
                    
                    write-host "Copying VHD $SRCVHDFILE to $DSTVHDDIR\ on $RDOSHOST..."
                    & .\PAExec.exe \\$RDOSHOST -u $RDOSHOSTADMIN -p $RDOSHOSTADMIN_PWD -c .\$remoteBatch > "$remoteBatch.log"
                }  
            }
            # Copy sshkey to lisa working folder, copy once for each test distro
            $retryCount = 3
            $LisaSSHKEYDir = ".\autordos\lisablue\ssh\"

            while ($retryCount -ge 0)
            {
                net use $distroVHDDir /user:$NETUSER $NETUSER_PWD | Out-Null

                $PathToSSHKEY = (Get-ChildItem -Path $distroVHDDir -Recurse -File $distroInfo.sshkey).FullName

			    write-Host "Copy $PathToSSHKEY $LisaSSHKEYDir -force"
			    copy $PathToSSHKEY $LisaSSHKEYDir -force
                if ($?)
                {
                    break
                }
                $retryCount -= 1
            }
        }
    }
    return $testConfigs;
}


function GenFeatureTestConfig([string]$lisaRootDir, $testInfo, $vmSize, $distroInfo, $HVServers, $ArpServerIP)
{
    $lisaRootEle = GenLisaRootDirElement $lisaRootDir
    $vmSizesEle = GenVMSizesElement
    $mimicArpServerEle = GenMiMicARPServerElement $ArpServerIP
    $testsEle = GenFeatureTestsEle $testInfo $vmSize
    $distrosEle = GenDistrosEle $distroInfo
    $hvServersEle = GenHVServersEle $HVServers
    [string]$content = @"
<?xml version="1.0" encoding="utf-8"?>
<config>
    <global>
        $lisaRootEle
        $vmSizesEle
        $mimicArpServerEle
    </global>
    $testsEle
    $distrosEle
    $hvServersEle
</config>
"@
    return $content
}

function GenRebootTestConfig([string]$lisaRootDir, $testInfo, $vmSize, $distroInfo, $xstoreUrl, $xstoreAN, $xstoreContainer, $xstoreAK, $HVServers, $ArpServerIP)
{
    $lisaRootEle = GenLisaRootDirElement $lisaRootDir
    $vmSizesEle = GenVMSizesElement
    $mimicArpServerEle = GenMiMicARPServerElement $ArpServerIP
    $xstoreEle = GenXStoreEle $xstoreUrl $xstoreAN $xstoreContainer $xstoreAK
    $testsEle = GenRebootTestsEle $testInfo $vmSize
    $distrosEle = GenDistrosEle $distroInfo
    $hvServersEle = GenHVServersEle $HVServers
    [string]$content = @"
<?xml version="1.0" encoding="utf-8"?>
<config>
    <global>
        $lisaRootEle
        $vmSizesEle
        $xstoreEle
        $mimicArpServerEle
    </global>
    $testsEle
    $distrosEle
    $hvServersEle
</config>
"@
    return $content
}

function GenLocalDiskTestConfig([string]$lisaRootDir, $testInfo, $vmSize, $distroInfo, $xstoreUrl, $xstoreAN, $xstoreContainer, $xstoreAK, $HVServers, $ArpServerIP)
{
    $lisaRootEle = GenLisaRootDirElement $lisaRootDir
    $vmSizesEle = GenVMSizesElement
    $mimicArpServerEle = GenMiMicARPServerElement $ArpServerIP
    $xstoreEle = GenXStoreEle $xstoreUrl $xstoreAN $xstoreContainer $xstoreAK
    $testsEle = GenLocalDiskTestsEle $testInfo $vmSize
    $distrosEle = GenDistrosEle $distroInfo
    $hvServersEle = GenHVServersEle $HVServers
    [string]$content = @"
<?xml version="1.0" encoding="utf-8"?>
<config>
    <global>
        $lisaRootEle
        $vmSizesEle
        $xstoreEle
        $mimicArpServerEle
    </global>
    $testsEle
    $distrosEle
    $hvServersEle
</config>
"@
    return $content
}

function GenXSDiskTestConfig([string]$lisaRootDir, $testInfo, $vmSize, $distroInfo, $xstoreUrl, $xstoreAN, $xstoreContainer, $xstoreAK, $HVServers, $ArpServerIP)
{
    $lisaRootEle = GenLisaRootDirElement $lisaRootDir
    $vmSizesEle = GenVMSizesElement
    $mimicArpServerEle = GenMiMicARPServerElement $ArpServerIP
    $xstoreEle = GenXStoreEle $xstoreUrl $xstoreAN $xstoreContainer $xstoreAK
    $testsEle = GenXStoreDiskTestsEle $testInfo $vmSize
    $distrosEle = GenDistrosEle $distroInfo
    $hvServersEle = GenHVServersEle $HVServers
    [string]$content = @"
<?xml version="1.0" encoding="utf-8"?>
<config>
    <global>
        $lisaRootEle
        $vmSizesEle
        $xstoreEle
        $mimicArpServerEle
    </global>
    $testsEle
    $distrosEle
    $hvServersEle
</config>
"@
    return $content
}

function GenXSTrimTestConfig([string]$lisaRootDir, $testInfo, $vmSize, $distroInfo, $xstoreUrl, $xstoreAN, $xstoreContainer, $xstoreAK, $HVServers, $ArpServerIP)
{
    $lisaRootEle = GenLisaRootDirElement $lisaRootDir
    $vmSizesEle = GenVMSizesElement
    $mimicArpServerEle = GenMiMicARPServerElement $ArpServerIP
    $xstoreEle = GenXStoreEle $xstoreUrl $xstoreAN $xstoreContainer $xstoreAK
    $testsEle = GenXStoreTrimTestsEle $testInfo $vmSize
    $distrosEle = GenDistrosEle $distroInfo
    $hvServersEle = GenHVServersEle $HVServers
    [string]$content = @"
<?xml version="1.0" encoding="utf-8"?>
<config>
    <global>
        $lisaRootEle
        $vmSizesEle
        $xstoreEle
        $mimicArpServerEle
    </global>
    $testsEle
    $distrosEle
    $hvServersEle
</config>
"@
    return $content
}

function GenNetworkTestConfig([string]$lisaRootDir, $testInfo, $vmSize, $distroInfo, $xstoreUrl, $xstoreAN, $xstoreContainer, $xstoreAK, $HVServers, $ArpServerIP)
{
    $lisaRootEle = GenLisaRootDirElement $lisaRootDir
    $vmSizesEle = GenVMSizesElement
    $mimicArpServerEle = GenMiMicARPServerElement $ArpServerIP
    $xstoreEle = GenXStoreEle $xstoreUrl $xstoreAN $xstoreContainer $xstoreAK
    $testsEle = GenNetworkTestsEle $testInfo $vmSize
    $distrosEle = GenDistrosEle $distroInfo
    $hvServersEle = GenHVServersEle $HVServers
    [string]$content = @"
<?xml version="1.0" encoding="utf-8"?>
<config>
    <global>
        $lisaRootEle
        $vmSizesEle
        $xstoreEle
        $mimicArpServerEle
    </global>
    $testsEle
    $distrosEle
    $hvServersEle
</config>
"@
    return $content
}

<#Internal#>
function GenLisaRootDirElement([string]$lisaRootDir)
{
    [string]$content = "<lisaRootDir>$lisaRootDir</lisaRootDir>"
    return $content
}

function GenVMSizesElement()
{
    [string]$content = "<vmSizes>
            <vmSize>
                <sizeName>XS</sizeName>
                <cpus>1</cpus>
                <memory>768</memory>
            </vmSize>
            <vmSize>
                <sizeName>S</sizeName>
                <cpus>1</cpus>
                <memory>1792</memory>
            </vmSize>
            <vmSize>
                <sizeName>M</sizeName>
                <cpus>2</cpus>
                <memory>3584</memory>
            </vmSize>
            <vmSize>
                <sizeName>L</sizeName>
                <cpus>4</cpus>
                <memory>7168</memory>
            </vmSize>
            <vmSize>
                <sizeName>XL</sizeName>
                <cpus>8</cpus>
                <memory>14336</memory>
            </vmSize>
        </vmSizes>"
    return $content
}

function GenXStoreEle($url, $accountName, $container, $accessKey)
{
    [string] $content = "<XStore>
            <url>$url</url>
            <accountName>$accountName</accountName>
            <container>$container</container>
            <accessKey>$accessKey</accessKey>
        </XStore>"
    return $content
}

function GenMiMicARPServerElement($arpServerIP)
{
    [string] $content = "<mimicArpServer>
            <hostname>$arpServerIP</hostname>
            <username>root</username>
            <sshKey>lisa_id_rsa.ppk</sshKey>
        </mimicArpServer>"
    return $content;
}

function GenFeatureTestsEle($testInfo, [string] $vmSize)
{
    $testname = $testInfo.testName
    $testTemplate = $testInfo.testTemplate
    $testScript = $testInfo.testScript
    $baseXml = $testInfo.baseXml
    $cases = $testInfo.cases
    [string] $content = "<tests>
        <test>
            <testName>$testName</testName>
            <testTemplate>$testTemplate</testTemplate>
            <testScript>$testScript</testScript>
            <vmSize>$vmSize</vmSize>
            <baseXml>$baseXml</baseXml>
            <customizeTestCases>
                <testName>ReadHostKVPDataOnGuest</testName>
                <modifyParam>
                    <oldParam>Value=SERVER_NAME</oldParam>
                    <newParam>Value=<valueOf key=`"hvServer`" /></newParam>
                </modifyParam>
            </customizeTestCases>"
    if ($cases){
        $casesEle = GenFeatureTestCasesEle $cases
        $content += "
            $casesEle"
    }
    $content += "
        </test>
    </tests>"
    return $content;
}

function GenFeatureTestCasesEle($cases)
{
    $content = "<cases>"
    foreach ($case in $cases){
        $content += "
                <case>$case</case>"
    }
    $content += "
            </cases>"
    return $content
}

function GenRebootTestsEle($testInfo, [string] $vmSize)
{
    $testname = $testInfo.testName
    $testTemplate = $testInfo.testTemplate
    $testScript = $testInfo.testScript
    $timeout = $testInfo.timeout
    $testParams = $testInfo.testParams
    $rebootCount = $testParams["REBOOT_COUNT"]


    [string] $content = "<tests>
        <test>
            <testName>$testName</testName>
            <testTemplate>$testTemplate</testTemplate>
            <testScript>$testScript</testScript>
            <vmSize>$vmSize</vmSize>
            <timeout>$timeout</timeout>
            <testParams>
                <param>REBOOT_COUNT=$rebootCount</param>
            </testParams>
        </test>
    </tests>"
    return $content;
}

function GenLocalDiskTestsEle($testInfo, [string] $vmSize)
{
    $testname = $testInfo.testName
    $testTemplate = $testInfo.testTemplate
    $testScript = $testInfo.testScript
    $timeout = $testInfo.timeout
    $testParams = $testInfo.testParams
    $IOZoneParams = $testParams["IOZONE_PARAMS"]


    [string] $content = "<tests>
        <test>
            <testName>$testName</testName>
            <testTemplate>$testTemplate</testTemplate>
            <testScript>$testScript</testScript>
            <vmSize>$vmSize</vmSize>
            <timeout>$timeout</timeout>
            <testParams>
                <param>IOZONE_PARAMS='$IOZoneParams'</param>
            </testParams>
        </test>
    </tests>"
    return $content;
}

function GenXStoreDiskTestsEle($testInfo, [string] $vmSize)
{
    $testname = $testInfo.testName
    $testTemplate = $testInfo.testTemplate
    $testScript = $testInfo.testScript
    $vhdMode = $testInfo.vhdMode
    $timeout = $testInfo.timeout
    $testParams = $testInfo.testParams
    $IOZoneParams = $testParams["IOZONE_PARAMS"]


    [string] $content = "<tests>
        <test>
            <testName>$testName</testName>
            <testTemplate>$testTemplate</testTemplate>
            <testScript>$testScript</testScript>
            <vmSize>$vmSize</vmSize>
            <vhdMode>$vhdMode</vhdMode>
            <timeout>$timeout</timeout>
            <testParams>
                <param>IOZONE_PARAMS='$IOZoneParams'</param>
            </testParams>
        </test>
    </tests>"
    return $content;
}

function GenXStoreTrimTestsEle($testInfo, [string] $vmSize)
{
    $testname = $testInfo.testName
    $testTemplate = $testInfo.testTemplate
    $testScript = $testInfo.testScript
    $vhdMode = $testInfo.vhdMode
    $timeout = $testInfo.timeout


    [string] $content = "<tests>
        <test>
            <testName>$testName</testName>
            <testTemplate>$testTemplate</testTemplate>
            <testScript>$testScript</testScript>
            <vmSize>$vmSize</vmSize>
            <vhdMode>$vhdMode</vhdMode>
            <timeout>$timeout</timeout>
        </test>
    </tests>"
    return $content;
}

function GenNetworkTestsEle($testInfo, [string] $vmSize)
{
    $testname = $testInfo.testName
    $testTemplate = $testInfo.testTemplate
    $testScript = $testInfo.testScript
    $testMode = $testInfo.testMode
    $iperfThreads = $testInfo.iperfThreads
    $iperfSeconds = $testInfo.iperfSeconds
    $testParams = $testInfo.testParams
    $TARGET_SSHKEY = $testParams["TARGET_SSHKEY"]
    $MIMICARP_SERVER_SSHKEY = $testParams["MIMICARP_SERVER_SSHKEY"]
    [int]$timeout = [INT]::Parse($iperfSeconds) + 600
    [string] $content = "<tests>
        <test>
            <testName>$testName</testName>
            <testMode>$testMode</testMode>
            <testTemplate>$testTemplate</testTemplate>
            <testScript>$testScript</testScript>
            <timeout>$timeout</timeout>
            <vmSize>$vmSize</vmSize>
            <iperfThreads>$iperfThreads</iperfThreads>
            <iperfSeconds>$iperfSeconds</iperfSeconds>
            <testParams>
                <param>TARGET_SSHKEY=$TARGET_SSHKEY</param>
                <param>MIMICARP_SERVER_SSHKEY=$MIMICARP_SERVER_SSHKEY</param>
            </testParams>
        </test>
    </tests>"
    return $content;
}


function GenDistrosEle($distroInfo)
{
    $distroName = $distroInfo.distroName
    $baseVhd = $distroInfo.baseVhd
    $sshkey = $distroInfo.sshKey
    $comPort = $distroInfo.comPort
    [string] $content = "<distros>
        <distro>
            <distroName>$distroName</distroName>
            <baseVhd>$baseVhd</baseVhd>
            <sshKey>$sshKey</sshKey>"
    if(![String]::IsNullOrEmpty($comPort))
    {
        $content += "
            <comPort>$comPort</comPort>"
    }
    
    $content += "
        </distro>
    </distros>";
    return $content;
}

function GenHVServersEle($HVServers)
{
    [string] $content = "<hvServers>"
    foreach($HVServer in $HVServers){
        $hostname = $HVServer.HostName
        $username = $HVServer.UserName
        $password = $HVServer.Password
        $switchName = $HVServer.SwitchName
        $vmadminRoot = $HVServer.VMAdminRoot
        $vmRoot = $HVServer.VMRoot
        $vmVhdRoot = $HVServer.VMVHDRoot
        $vmSnapshotRoot = $HVServer.VMSnapshotRoot

        $content += "
        <hvServer>
            <hostname>$hostname</hostname>
            <username>$username</username>
            <password>$password</password>
            <switchName>$switchName</switchName>
            <vmadminRoot>$vmadminRoot</vmadminRoot>
            <vmRoot>$vmRoot</vmRoot>
            <vmVhdRoot>$vmVhdRoot</vmVhdRoot>
            <vmSnapshotRoot>$vmSnapshotRoot</vmSnapshotRoot>
        </hvServer>"
    }
    
    $content += "
    </hvServers>"
    return $content
}

<#
    Function to request a random RDOS test server from REST service, default to retry 3 times in case network unstable
#>
function RequestHVServer([string] $RESTSVCURL, [int] $retry = 3)
{
    $REQURL =  "$RESTSVCURL/api/HVServer?Lock=True"
    Write-Host "Request Server URL: $REQURL"

    while ($true)
    {
        $oldErrorActionPreference = $ErrorActionPreference
        $ErrorActionPreference = 'SilentlyContinue'
        $response = Invoke-RestMethod $REQURL -Headers @{"Accept"="Application/xml"} -ErrorVariable restError
        $ErrorActionPreference = $oldErrorActionPreference
        if (!$response) {
            if (--$retry -le 0){
                Write-Host "Cannot get HVServer!."
                return $null
            }
            Write-Host "Request HVServer failed($($restError[0].Message)), retry left: $retry"
            sleep 60
        } else {
            $hvServer = $response.HVServer
            Write-Host "Get HVServer: $($hvServer.HostName)"
            return $hvServer
        }
    } 
}

<#
    Function to request a random RDOS test server from REST service, default to retry 3 times in case network unstable
#>
function RequestHVServerByName([string] $RESTSVCURL, [string] $hostname, [int] $retry = 3)
{
    $HVServer = $null
    $REQURL =  "$RESTSVCURL/api/HVServer?HostName=$hostname"
    Write-Host "Request Server URL: $REQURL"

    while([String]::IsNullOrEmpty($HVServer))
    {
        $response = Invoke-RestMethod $REQURL -Headers @{"Accept"="Application/xml"}
        if(!$?) { 
            Write-Host "No HVServer available!"
            $retry--
            if($retry -ge 0){
                Write-Host "Cannot get HVServer!."
                return $null;   
            }else{
                Write-Host "Request HVServer failed, retry left: $retry"
                continue
            }            
        }else{
            write-Host "Get HVServer!"
            $HVServer = $response.HVServer
            return $HVServer
        }
    } 
}

<#
    Function to release a RDOS test server from REST service, default to retry 3 times in case network unstable
#>
function ReleaseHVServer([string] $restSvcUrl, [string] $rdosHost, [int] $retry = 3)
{
    Write-Host "Release test RDOS host: $rdosHost"
    $relUrl = "$restSvcUrl/api/HVServer?HostName=$rdosHost"
    Write-Host $relUrl

    while ($true)
    {
        #http://connect.microsoft.com/PowerShell/feedback/details/836732/tcp-connection-hanging-in-close-wait-when-using-invoke-restmethod-with-put-or-delete#
        Invoke-WebRequest $relUrl -Method Put
        if (!$?) {
            if (--$retry -le 0){
                Write-Host "Cannot release HVServer!."
                return
            }
            Write-Host "Release HVServer failed, retry left: $retry"
            sleep 1
        } else {
            Write-Host "Released HVServer!"
            return
        }
    } 
}

<#
    Function to release a random RDOS test server
#>
function ReleaseHVServer([string] $RESTSVCURL, [string] $RDOSHOST)
{
    write-host "Release test rdos host: $RDOSHOST"
    $RELURL = "$RESTSVCURL/api/HVServer?HostName=$RDOSHOST"
    write-debug $RELURL
    #http://connect.microsoft.com/PowerShell/feedback/details/836732/tcp-connection-hanging-in-close-wait-when-using-invoke-restmethod-with-put-or-delete#
    Invoke-WebRequest $RELURL -Method PUT
    if(!$?) {write-host "Release RDOSHOST failed"}
}

function CreateDistroInfo([string]$distroName, [string]$baseVhd, [string]$sshkey, [string]$comPort)
{
    $properties = @{'distroName'=$distroName;'baseVhd'=$baseVhd;'sshKey'=$sshkey;'comPort'=$comPort};
    $object = New-Object -TypeName PSObject -Prop $properties
    return $object
}

<#  
    Generate DistroInfo based on ImageInfo.xml from VHD dir
#>
function DiscoverDistroInfo([string] $imageDir, [string] $netuser, [string]$netuser_pwd)
{
    $errorPref = $ErrorActionPreference
    $ErrorActionPreference = "silentlycontinue"
    net use $imageDir /user:$netuser $netuser_pwd 
    $ErrorActionPreference = $errorPref

    $filePath = join-path $imageDir ImageInfo.xml
    if(Test-Path $filePath)
    {
        $xmlData = [xml](Get-Content $filePath)
        $distroName = $xmldata.ImageInfo.DistroInfo.DistroName
        $VHDName = $xmldata.ImageInfo.PreparedForFCRDOS.VHDName
        $sshkey = $xmlData.ImageInfo.PreparedForFCRDOS.PrivateKey
        $comPort = $xmlData.ImageInfo.PreparedForFCRDOS.ComPort
        $distroInfo = CreateDistroInfo $distroName $VHDName $sshkey $comPort
        
        return $distroInfo
    }else
    {
        return false;
    }
}

function CreateTestInfo($testName, $testTemplate, $testScript, $baseXml, $vhdMode, $timeout, $testMode, $iperfThreads, $iperfSeconds, $testParams, $cases)
{
    $properties = @{'testName'=$testName;'testTemplate'=$testTemplate;'testScript'=$testScript;'baseXml'=$baseXml; 'vhdMode'=$vhdMode; 'testMode'=$testMode; 'iperfThreads'=$iperfThreads; 'iperfSeconds'=$iperfSeconds; 'timeout'=$timeout;'testParams'=$testParams; 'cases'=$cases}
    $object = New-Object -TypeName PSObject -Property $properties
    return $object
}

<#
    Copy VHD from $RDOSVHDDIRSRC to $HVServer.RDOSVHDDir's subdirectory, temporary folder 
    is named with current datetime, and append numbered suffix if still exists.
    For example: 5_28_2014_0, 5_28_2014_1
#>
function RefreshRDOSBuild($NETUSER, $NETUSER_PWD, $RDOSVHDDIRSRC, $HVServer)
{
    if(![String]::IsNullOrEmpty($RDOSVHDDIRSRC)){
        $RDOSVHDDriver = $HVServer.RDOSVHDDir
        $tempFolderName = (get-date).ToShortDateString().Replace('/','_')
        $RDOSVHDDIRDST = Join-Path $RDOSVHDDriver -ChildPath $tempFolderName
        $fdsuffix = 0
        while(Test-Path $RDOSVHDDIRDST)
        {            
            $tempFolderName_1 = "$tempFolderName_$dfsuffix"
            $RDOSVHDDIRDST = Join-Path $RDOSVHDDriver -ChildPath $tempFolderName_1
            $fdsuffix++
        }
        Write-Host "RDOS VHD copy to directory: $RDOSVHDDIRDST"
        & .\InstallRDOS.ps1 $HVServer.HostName $HVServer.UserName $HVServer.Password $RDOSVHDDIRSRC $RDOSVHDDIRDST $NETUSER $NETUSER_PWD
       if($LASTEXITCODE -ne 0) {
            Write-Host "Install RDOS failed"
            return $false
        }
        Write-Host "RDOS build has been refreshed"
        return $true
    }
    return $false
}

<#
    Check hashtable $paramHT contain all required parameter named in $paraNames
#>
function CheckParam($paramHT, $paramNames){
    foreach($paramName in $paramNames){
        $paramValue = $paramHT[$paramName]
        #Write-Host $paramValue
        if (!$paramValue)
        {
            Write-Host "Can't find a parameter with name: $paramName in param hashtable"
            return $false
        }
    }
    return $true
}

<#
    Look for parameter with name:$paramName in $paramHT, and if not find, assign $defautlValue
#>
function GetParameter($paramHT, $paramName, $defaultValue)
{
    if($paramHT.Contains($paramName)){
        return $paramHT[$paramName]
    }
    return $defaultValue
}

Export-ModuleMember -Function RequestHVServer
Export-ModuleMember -Function RequestHVServerByName
Export-ModuleMember -Function ReleaseHVServer
Export-ModuleMember -Function GenHVServersEle
Export-ModuleMember -Function GenFeatureTestConfig
Export-ModuleMember -Function GenerateTestConfig

Export-ModuleMember -Function DiscoverDistroInfo
Export-ModuleMember -Function CreateDistroInfo
Export-ModuleMember -Function CreateTestInfo
Export-ModuleMember -Function RefreshRDOSBuild
Export-ModuleMember -Function CheckParam
Export-ModuleMember -Function GetParameter
Export-ModuleMember -Variable FeatureTest

