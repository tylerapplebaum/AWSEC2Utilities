$Regions = Get-AWSRegion | Select-Object -ExpandProperty Region
$UserInfo = Get-STSCallerIdentity -ProfileName $ProfileName -Region $Regions[0]
$InstancesArr = New-Object System.Collections.ArrayList

ForEach ($Region in $Regions) {
    Get-EC2Image -ProfileName $ProfileName -Region $Region -Owner $UserInfo.Account
}

ForEach ($Region in $Regions) {
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
                "Tags" = $Instance.Tags
                "State" = $Instance.State
                "StateReason" = $Instance.StateReason
                "Architecture" = $Instance.Architecture
                "ImageId" = $Instance.ImageId
                "Licenses" = $Instance.Licenses
            }
            $InstancePropertiesObj = New-Object PSObject -Property $InstanceProperties
            $InstancesArr.Add($InstancePropertiesObj) | Out-Null #Add the object to the array
        }    
}