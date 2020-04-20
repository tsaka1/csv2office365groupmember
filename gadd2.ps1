Param( [switch]$renew)

$csvfile = Read-Host "CSVファイル名を入れてください"
$emails = Import-Csv -Path $csvfile | Select-Object email

If ($false -eq $?) {
    exit
}

$gmail = Read-Host "Group Addressを入れてください"

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


If ($renew) {
  $members = Get-AzureADGroupMember -All 1 -ObjectId $group.Id

  Write-Host "以下のメンバーを削除します"
  foreach ($d in $members){
    Write-Host $d.DisplayName
    Remove-AzureAdGroupMember -ObjectId $group.Id -MemberId $d.ObjectId
  }
  Write-Host "以下のアカウントを追加します"
}

foreach ($e in $emails) {
    Write-Host $e.email
    $User = (Get-AzureADUser -ObjectId $e.email)
    # $User | FT DisplayName,UserPrincipalName
    Add-AzureAdGroupMember -ObjectId $group.Id -RefObjectId $User.ObjectId
}

Disconnect-AzureAD
