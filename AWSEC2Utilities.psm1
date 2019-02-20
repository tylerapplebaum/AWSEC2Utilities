$Regions = Get-AWSRegion | Select-Object -ExpandProperty Region
$UserInfo = Get-STSCallerIdentity -ProfileName $ProfileName -Region $Regions[0] #Not region specific, choose the first one.


Function Get-EC2ImagesGlobal {
[CmdletBinding()]
  param(
  [Parameter(HelpMessage="Check if the AWS PowerShell module is loaded")]
  [ValidateScript({If (Get-Module -Name AWSPowerShell) {$True} Else {$False}})]
  [bool]$AWSModuleLoaded,
  
  [Parameter(HelpMessage="Specify the AWS API user profile name")]
  [ValidateNotNullOrEmpty()]
  [string]$ProfileName
  )
$ImagesArr = New-Object System.Collections.ArrayList
    ForEach ($Region in $Regions) {
        $Images = Get-EC2Image -ProfileName $ProfileName -Region $Region -Owner $UserInfo.Account
            ForEach ($Image in $Images) {
                [void]$ImagesArr.Add($Image)
            } #End ForEach
    } #End ForEach
Return $ImagesArr
} #End Get-EC2ImagesGlobal

Function Get-EC2InstancesGlobal {
[CmdletBinding()]
  param(
  [Parameter(HelpMessage="Check if the AWS PowerShell module is loaded")]
  [ValidateScript({If (Get-Module -Name AWSPowerShell) {$True} Else {$False}})]
  [bool]$AWSModuleLoaded,
  
  [Parameter(HelpMessage="Specify the AWS API user profile name")]
  [ValidateNotNullOrEmpty()]
  [string]$ProfileName
  )
$InstancesArr = New-Object System.Collections.ArrayList
    ForEach ($Region in $Regions) {
        Write-Verbose "Checking region $Region for EC2 instances"
        $Instances = Get-EC2Instance -ProfileName $ProfileName -Region $Region | Select-Object -ExpandProperty Instances
            ForEach ($Instance in $Instances) {
                $InstanceProperties = @{
                    "InstanceID" = $Instance.InstanceID
                    "InstanceType" = $Instance.InstanceType
                    "Platform" = $Instance.Platform
                    "PrivateIPAddress" = $Instance.PrivateIPAddress
                    "PublicIPAddress" = $Instance.PublicIPAddress
                    "SecurityGroups" = $Instance.SecurityGroups
                    "SubnetId" = $Instance.SubnetId
                    "VpcId" = $Instance.VpcId
                    "Region" = $Region
                    "Tags.Key" = $Instance.Tags.Key
                    "Tags.Value" = $Instance.Tags.Value
                    "CoreCount" = $Instance.CpuOtions.CoreCount
                    "LaunchTime" = $Instance.LaunchTime
                    "State" = $Instance.State
                    "StateReason" = $Instance.StateReason
                    "Architecture" = $Instance.Architecture
                    "ImageId" = $Instance.ImageId
                    "Licenses" = $Instance.Licenses
                }
                $InstancePropertiesObj = New-Object PSObject -Property $InstanceProperties
                $InstancesArr.Add($InstancePropertiesObj) | Out-Null #Add the object to the array
            } #End ForEach    
    } #End ForEach
Return $InstancesArr
} #End Get-EC2InstancesGlobal