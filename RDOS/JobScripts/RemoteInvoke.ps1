$passwordString = 'PA$$word!!'
$username = 'Administrator'
$computer = weyao-acer
$pwd = ConvertTo-SecureString -Force -AsPlainText $passwordString
$cred = New-Object System.Management.Automation.PSCredential($username, $pwd)
Invoke-WmiMethod -ComputerName weyao-acer -Credential $cred -Class win32_process -name create -ArgumentList