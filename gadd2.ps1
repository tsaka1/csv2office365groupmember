Param( [switch]$renew)

$csvfile = Read-Host "CSV�t�@�C���������Ă�������"
$emails = Import-Csv -Path $csvfile | Select-Object email

If ($false -eq $?) {
    exit
}

$gmail = Read-Host "Group Address�����Ă�������"

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

  Write-Host "�ȉ��̃����o�[���폜���܂�"
  foreach ($d in $members){
    Write-Host $d.DisplayName
    Remove-AzureAdGroupMember -ObjectId $group.Id -MemberId $d.ObjectId
  }
  Write-Host "�ȉ��̃A�J�E���g��ǉ����܂�"
}

foreach ($e in $emails) {
    Write-Host $e.email
    $User = (Get-AzureADUser -ObjectId $e.email)
    # $User | FT DisplayName,UserPrincipalName
    Add-AzureAdGroupMember -ObjectId $group.Id -RefObjectId $User.ObjectId
}

Disconnect-AzureAD
