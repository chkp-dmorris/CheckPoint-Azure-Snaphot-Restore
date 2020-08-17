#Script was written by Dan Morris on August 17th 2020
#With some help from Microsoft Documents at 
#https://docs.microsoft.com/en-us/azure/virtual-machines/scripts/virtual-machines-windows-powershell-sample-create-vm-from-snapshot

#The script as is only. 


#******** Variable section ********#
#  Ensure all fields are populated #


##Provide the subscription Id
#Field may not bee needed
$subscriptionId = 'yourSubscriptionId'

##Provide the name of your  resource group where the snapshot is located. 
#Soure Snapshot. If your are importing a customer Snapshot you can add it to a Resource Group
$resourceGroupNameSnapshot ='Dan-MGMT-R80.040-testing'

##Provide the name of your new resource group
$resourceGroupName ='Dan-R80.40-MGMT-Snapshot'

##Provide the name of the snapshot that will be used to create OS disk
$snapshotName = 'Snapshot-test'

##Provide the name of the OS disk that will be created using the snapshot
$osDiskName = 'MGMT-Snapshot'

##Choose between Standard_LRS and Premium_LRS based on your scenario. Standard is defaulf for most Check Point deployments
# Comment out one
$diskType = 'Standard_LRS'   #Default
#$diskType = 'Premium_LRS'

##Provide the name of an existing virtual network where virtual machine will be created
$virtualNetworkName = 'myVnet'


##Provide publicIp for the new VM
#Create or set existing Public IP
#Public IP may already be attached to a network interface. This field may not be needed.
$publicIp = 'myPublicIP'

##Provide Name of the new NIC for the new VM
$nicName = 'mgmtnic'

##Provide the name of the virtual machine you want to created
$virtualMachineName = 'Dan-R80-Snapshot-MGMT'

##Provide the size of the virtual machine
#e.g. Standard_DS3_v2
#Get all the vm sizes in a region using below script:
#e.g. Get-AzVMSize -Location westus
$virtualMachineSize = 'Standard_DS3_v2'


##Set Check point Plan.
#The details for this is best captured by getting the customer Deployment template from their deployed image under Export Template for their VM and 
#getting the values from the plan field.
#Example;
#    "plan": {
#                "name": "mgmt-byol",
#                "product": "check-point-cg-r8040",
#                "publisher": "checkpoint"
#SK123564 may need to be followed if you don't have this information. This SK will provide you the powershell steps to find this information	
	
$publisher = 'checkpoint'
$product = 'check-point-cg-r8040'
$name = 'mgmt-byol'


####### Apply section ######
#NOTE- Some fields may need to be updated to reflect the enviroment #

##Set the context to the subscription Id where Managed Disk will be created
##May not be needed
#Select-AzSubscription -SubscriptionId $SubscriptionId

##Get Snapshot name 
$snapshot = Get-AzSnapshot -ResourceGroupName $resourceGroupNameSnapshot -SnapshotName $snapshotName


##Used to copy the Snapshot to the new Resource Group. This can be commented out if not needed
$diskConfig = New-AzDiskConfig -Location $snapshot.Location -SourceResourceId $snapshot.Id -CreateOption Copy

##Used to create a new Managed disk from a Snapshot. If a managed Disk is created you can then set the Managed Disk Id
##Comment out one
$disk = New-AzDisk -Disk $diskConfig -ResourceGroupName $resourceGroupName -DiskName $osDiskName 			#Create a new managed Disk
#$disk= Get-AzDisk -ResourceGroupName $resourceGroupName -DiskName $osDiskName #Find a Managed Disk 		#Find a Managed Disk if alreadt in the Resource Group


##Initialize virtual machine configuration to create an image
$VirtualMachine = New-AzVMConfig -VMName $virtualMachineName -VMSize $virtualMachineSize

##Attaches a Managed Disk Resource Id to a virtual machine. 
$VirtualMachine = Set-AzVMOSDisk -VM $VirtualMachine -ManagedDiskId $disk.Id -CreateOption Attach -linux -StorageAccountType $diskType

##Create a public IP for the VM or get an existing public ip you would like to use.
##Comment out one

#$publicIp = New-AzPublicIpAddress -Name ($VirtualMachineName.ToLower()+'_ip') -ResourceGroupName $resourceGroupName -Location $snapshot.Location -AllocationMethod Dynamic  #Create a new Public IP
$myPublicIP = Get-AzPublicIpAddress -Name $publicIp -ResourceGroupName $ResourceGroupName	#Find an existing Public IP

##Get the virtual network where virtual machine will be hosted
$vnet = Get-AzVirtualNetwork -Name $virtualNetworkName -ResourceGroupName $resourceGroupName


## Create NIC in the first subnet of the virtual network
## Comment one out
#$nic = New-AzNetworkInterface -Name ($VirtualMachineName.ToLower()+'_nic') -ResourceGroupName $resourceGroupName -Location $snapshot.Location -SubnetId $vnet.Subnets[0].Id -PublicIpAddressId $publicIp.Id  
$nic = Get-AzNetworkInterface -name $nicName -ResourceGroupName $resourceGroupName	#To find an existing Interface and us it

##Adding Nic to Machine
$VirtualMachine = Add-AzVMNetworkInterface -VM $VirtualMachine -Id $nic.Id

##Set and Azure Plan before apploying the vm
Set-AzVMPlan -VM $VirtualMachine -Publisher $publisher -Product $product -name $name

#Create the virtual machine with Managed Disk
New-AzVM -VM $VirtualMachine -ResourceGroupName $resourceGroupName -Location $snapshot.Location