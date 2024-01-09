# terraform init
# terraform plan
# terraform apply --auto-approve
# terraform output public_ip_address
# terraform upgrade
# terraform refresh
# terraform validate
# terraform fmt
# terraform show
# terraform graph
# rm -rf terraform.tfsate*
# 

# Find Terraform Azure Regiuon
#   terraform apply -var 'region=East US 2'
#   terraform apply -var 'region=Australia East' --auto-approve
#   https://github.com/claranet/terraform-azurerm-regions/blob/master/REGIONS.md
#   az account list-locations -o table

# update Windows Image 
# id = data.azurerm_image.workstation.id
# az vm image list -f "Windows-10" --all
# az vm image list --publisher MicrosoftWindowsDesktop --offer Windows-10 --all --output table > win10.txt
# gensecond: see https://docs.microsoft.com/en-us/azure/virtual-machines/windows/generation-2

# Disable Azure Network Watcher - https://learn.microsoft.com/en-us/azure/network-watcher/network-watcher-create?tabs=portal
#   Remove -NetworkWatcherRG ; az network watcher configure --locations 'eastus' --enabled 'false'
#   Remove -NetworkWatcherRG ; az network watcher configure --locations 'Australia East' --enabled 'false'


# Guacamole Installe - https://github.com/MysticRyuujin/guac-install
# https://techcommunity.microsoft.com/t5/fasttrack-for-azure/deploying-apache-guacamole-on-azure/ba-p/3269613
# https://dev.to/pacroy/create-your-own-azure-bastion-with-guacamole-and-save-100-a-month-3fld
# https://github.com/ariesyous/guacamole-aws
# https://www.youtube.com/watch?v=gsvS2M5knOw


# Install Biginfo
# https://wmatthyssen.com/2019/09/11/powershell-bginfo-automation-script-for-windows-server-2012-r2/
# https://github.com/EvotecIT/PowerBGInfo/tree/master?tab=readme-ov-file
# https://evotec.xyz/powerbginfo-powershell-alternative-to-sysinternals-bginfo/


# watch -t -n 5 "cat <log file> | grep -e VMWS -e WSAPICLI -e $(date +%Y-%m-%d) | tail -15"
# https://discuss.hashicorp.com/t/what-is-the-best-practice-to-run-a-user-provided-ps1-script-as-cloud-init-script-on-a-windows-vm-module/12781




## What is the best method to run a intilization script inside Azure Windows VM using Terraform
/*

Azure Community - https://azure.microsoft.com/en-gb/support/community/
Terraform Discussion - https://discuss.hashicorp.com/latest
HashiCorp Twitter - https://twitter.com/HashiCorp/
Terraform Discord - https://discord.gg/X6zn8Yu


- Cloudinit is the way to do it for support Linux machines, but this isn't avaiable for Windows.check "
    - Run Bash scripts - https://brad-simonin.medium.com/learning-how-to-execute-a-bash-script-from-terraform-for-aws-b7fe513b6406
    - Learning how to execute a Bash script from Terraform - https://brad-simonin.medium.com/learning-how-to-execute-a-bash-script-from-terraform-for-aws-b7fe513b6406
    - Quickstart: Create a lab in Azure DevTest Labs using Terraform - https://learn.microsoft.com/en-us/azure/devtest-labs/quickstarts/create-lab-windows-vm-terraform

- There doesn't seem to be a proper supported method to do this which is so stupid;
- What is the best practice to run a user-provided .ps1 script as “cloud init script” on a Windows VM module? 
    - https://discuss.hashicorp.com/t/what-is-the-best-practice-to-run-a-user-provided-ps1-script-as-cloud-init-script-on-a-windows-vm-module/12781
- Options include 
    - Run scripts in your Windows VM by using action AZ Run Commands - https://learn.microsoft.com/en-gb/azure/virtual-machines/windows/run-command
    - Use Ansible
    - Use Data provider
    - Customer Data
        https://stackoverflow.com/questions/65630540/startup-script-in-azure-like-metadata-startup-script-in-gcp
    - Use template_file

            data "template_file" "script" {
            template = file("${path.module}/scripts/createfolder.ps1")
            }
    - Use local exec - https://developer.hashicorp.com/terraform/language/resources/provisioners/local-exec
    - Use remote-exec  - https://developer.hashicorp.com/terraform/language/resources/provisioners/remote-exec
    - Use WinRM
    - Using VM extensions
        - https://jackstromberg.com/2018/11/using-terraform-with-azure-vm-extensions/
        - What is the best practice to run a user-provided .ps1 script as “cloud init script” on a Windows VM module? - https://discuss.hashicorp.com/t/what-is-the-best-practice-to-run-a-user-provided-ps1-script-as-cloud-init-script-on-a-windows-vm-module/12781
        - Run Powershells cripts - https://techcommunity.microsoft.com/t5/itops-talk-blog/how-to-run-powershell-scripts-on-azure-vms-with-terraform/ba-p/3827573
        - VM Extensions - https://github.com/microsoft/ITOpsTalk/tree/main/Azure_VM_Extension_Terraform
        - How to run Powershel Commands - # https://www.cloudappie.nl/run-powershell-commands-terraform-configuration/
        - # How to run PowerShell scripts on Azure VMs with Terraform - https://techcommunity.microsoft.com/t5/itops-talk-blog/how-to-run-powershell-scripts-on-azure-vms-with-terraform/ba-p/3827573
    - terraform-provider-azurerm/examples/virtual-machines/windows
/vm-joined-to-active-directory/
        - https://github.com/hashicorp/terraform-provider-azurerm/tree/main/examples/virtual-machines/windows/vm-joined-to-active-directory
        - https://github.com/hashicorp/terraform-provider-azurerm/tree/main/examples/virtual-machines/windows/vm-custom-extension
        - /terraform-provider-azurerm/examples/virtual-machines/windows/vm-joined-to-active-directory
        - https://github.com/paulbouwer/terraform-azure-quickstarts-samples/tree/master/active-directory-new-domain-ha-2-dc
        - https://github.com/alfonsof/terraform-azure-examples
*/

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "example" {
  name     = "example-resources"
  location = "Australia East"
}

resource "azurerm_virtual_network" "example" {
  name                = "example-network"
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name
  address_space       = ["10.0.0.0/16"]
}

resource "azurerm_subnet" "example" {
  name                 = "example-subnet"
  resource_group_name  = azurerm_resource_group.example.name
  virtual_network_name = azurerm_virtual_network.example.name
  address_prefixes     = ["10.0.1.0/24"]
}

resource "azurerm_public_ip" "example" {
  name                = "example-publicip"
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name
  allocation_method   = "Dynamic"
}

resource "azurerm_network_interface" "example" {
  name                = "example-nic"
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.example.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.example.id
  }
}

resource "azurerm_windows_virtual_machine" "example" {
  name                = "example-vm"
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name
  network_interface_ids = [
    azurerm_network_interface.example.id,
  ]
  size           = "Standard_DS1_v2"
  admin_username = "adminuser"
  admin_password = "Password1234!"
  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    # id = data.azurerm_image.workstation.id
    # az vm image list -f "Windows-10" --all
    # az vm image list --publisher MicrosoftWindowsDesktop --offer Windows-10 --all --output table > win10.txt
    # gensecond: see https://docs.microsoft.com/en-us/azure/virtual-machines/windows/generation-2

    publisher = "MicrosoftWindowsDesktop"
    offer     = "Windows-10"
    sku       = "win10-22h2-pron"
    version   = "latest"
  }
}

# he file provisioner is used to copy files or directories from the machine executing the terraform apply to the newly created resource.  The file provisioner can connect to the resource using either ssh or winrm connections.
# Azure example 
# - https://gist.github.com/devops-school/07e858558ed7cff74f4343e0501860f9
# - https://www.devopsschool.com/blog/terraform-create-azure-windows-vm-with-file-remote-exec-local-exec-provisioner/
# https://developer.hashicorp.com/terraform/language/resources/terraform-data
# https://developer.hashicorp.com/terraform/language/resources/provisioners/connection
# "winrm quickconfig -q
# winrm set winrm/config/service '@{AllowUnencrypted="true"}'
# winrm set winrm/config/service/auth '@{Basic="true"}'
# Start-Service WinRM
# # set-service WinRM -StartupType Automatic
# Set-NetFirewallProfile -Profile Domain,Public,Private -Enabled false"

  resource "null_resource" "copy_file" {
  connection {
    type     = "winrm"
    # type = "ssh"

    host     = azurerm_windows_virtual_machine.example.public_ip_address
    user     = "adminuser"
    password = "Password1234!"
    insecure = true
    port = 5985
    https = false
    timeout = "1m"
  }

  provisioner "file" {
    source      = "nuke.sh"
    destination = "c:/windows/temp/nuke.sh"
  }
}

/*

  provisioner "file" {
    source      = "script.ps1"
    destination = "C:\\temp\\script.ps1"
    connection {
      type     = "winrm"
      user     = "adminuser"
      password = "Password1234!"
    }
  }
}


  provisioner "remote-exec" {
    inline = [
     # "powershell -File C:\\temp\\script.ps1",
      "powershell -Command "Install-Module PowerBGInfo -Force -Verbose"",
      "powershell -Command "Install-Module PowerBGInfo -Scope CurrentUser"",
      "powershell -Command "New-BGInfo -MonitorIndex 0 {
    # Lets add computer name, but lets use builtin values for that
    New-BGInfoValue -BuiltinValue HostName -Color Red -FontSize 20 -FontFamilyName 'Calibri'
    # Lets add user name, but lets use builtin values for that
    New-BGInfoValue -BuiltinValue FullUserName -Name "FullUserName" -Color White
    New-BGInfoValue -BuiltinValue CpuName
    New-BGInfoValue -BuiltinValue CpuLogicalCores
    New-BGInfoValue -BuiltinValue RAMSize
    New-BGInfoValue -BuiltinValue RAMSpeed

    # Lets add Label, but without any values, kind of like section starting
    New-BGInfoLabel -Name "Drives" -Color LemonChiffon -FontSize 16 -FontFamilyName 'Calibri'

    # Lets get all drives and their labels
    foreach ($Disk in (Get-Disk)) {
        $Volumes = $Disk | Get-Partition | Get-Volume
        foreach ($V in $Volumes) {
            New-BGInfoValue -Name "Drive $($V.DriveLetter)" -Value $V.SizeRemaining
        }
    }
} -FilePath $PSScriptRoot\Samples\PrzemyslawKlysAndKulkozaurr.jpg -ConfigurationDirectory $PSScriptRoot\Output -PositionX 100 -PositionY 100 -WallpaperFit Center
""
      "powershell -Command "Set-ExecutionPolicy Bypass -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; iex ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))"",
    ]
    connection {
      type     = "winrm"
      user     = "adminuser"
      password = "Password1234!"
    }
  }
}
*/

