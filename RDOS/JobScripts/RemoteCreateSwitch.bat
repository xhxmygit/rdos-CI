
rem XXX [nicElementName] [switchName]

pushd d:\vmadmin
vmadmin createswitch %2 & vmadmin setupswitch "%~1" %2
echo 4
popd