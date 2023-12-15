# Check list of ciphersuites in txt file against https://ciphersuite.info
$ciphersuites = Get-Content .\ciphersuites.txt
foreach($ciphersuite in $ciphersuites){
    try{
        $response = Invoke-RestMethod -UseBasicParsing -Uri "https://ciphersuite.info/api/cs/$($ciphersuite)"
        "Ciphersuite $ciphersuite is considered: $($response.($ciphersuite).security)"
    }catch{
        Write-Warning "Something went wrong when trying to query data for ciphersuite $ciphersuite..."
    }
}
