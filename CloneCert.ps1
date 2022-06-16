# Script to clone a certificate
$cert_original = Get-PfxCertificate -FilePath .\originalcert.pfx
$export_password = ConvertTo-SecureString -String "SecretStr1ng-123." -Force -AsPlainText
$cert_cloned = New-SelfSignedCertificate -CloneCert $cert_original -CertStoreLocation "Cert:\CurrentUser\My\"
$cert_cloned | Export-PfxCertificate -FilePath $cloned -Password $export_password
