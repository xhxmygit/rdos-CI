param(
    [string] $xml,
    [string] $xsl,
    [string] $output
)

$xslt = New-Object System.Xml.Xsl.XslCompiledTransform
$xsltSetting = New-Object System.Xml.Xsl.XsltSettings
$xsltSetting.EnableScript = $True
$xslt.Load($xsl,$xsltSetting,$null)
$xslt.Transform($xml,$output)


