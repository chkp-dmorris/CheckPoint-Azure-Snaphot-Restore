# Azure-Snaphot
Used to Restore Azure Snapshots for Check Point Gateways or Check Point Smart Centers

Requirements:
- Snapshot export from a Check Point VM
  https://docs.microsoft.com/en-us/azure/virtual-machines/linux/snapshot-copy-managed-disk
   NOTE: Machine must be turned off to complet this step
 
 - Snapshot export. There are a few options
     - Copy between subscriptions (Default for this script)
     - AZ copy between subscriptions- https://docs.microsoft.com/en-us/azure/storage/common/storage-use-azcopy-v10
     - Download and uploade VHD to the new account- https://docs.microsoft.com/en-us/azure/virtual-machines/windows/disks-upload-vhd-to-managed-disk-powershell
     
- Check Point plan version for the original image.
  The details for this is best captured by getting the customer Deployment template from their deployed image under Export Template for their VM and getting the values from the    plan field.
      Example;
         "plan": {
                      "name": "mgmt-byol",
                      "product": "check-point-cg-r8040",
                      "publisher": "checkpoint"
      SK123564 may need to be followed if you don't have this information. This SK will provide you the powershell steps to find this information	- https://supportcenter.checkpoint.com/supportcenter/portal?eventSubmit_doGoviewsolutiondetails=&solutionid=sk123564    
      
Pre-configured Azure resources needed:

- Resource Group
- Vnet
- Source subnet
- Public IP (optional)


