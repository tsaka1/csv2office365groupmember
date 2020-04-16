$csvfile = Read-Host "CSVƒtƒ@ƒCƒ‹–¼‚ð“ü‚ê‚Ä‚­‚¾‚³‚¢"
$emails = Import-Csv -Path $csvfile | Select-Object email

If ($false -eq $?) {
    exit
}

$gmail = Read-Host "Group Address‚ð“ü‚ê‚Ä‚­‚¾‚³‚¢"

$credential = Get-Credential

If ($false -eq $?) {
    exit
}

Connect-AzureAD -Credential $credential

If ($false -eq $?) {
    Disconnect-AzureAD
    exit
}

$group = Get-AzureADMSGroup -Filter "Mail eq `'$gmail`'"

If ($false -eq $?) {
    Disconnect-AzureAD
    exit
}

foreach ($e in $emails) {
    Write-Host $e.email
    $User = (Get-AzureADUser -ObjectId $e.email)
    # $User | FT DisplayName,UserPrincipalName
    Add-AzureAdGroupMember -ObjectId $group.Id -RefObjectId $User.ObjectId
}

Disconnect-AzureAD
