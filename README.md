# rockylinux-terraform
Install Rocky Linux on a local machine with Libvirt and Terraform

Read my [blog post](https://blog.mosibi.nl/all/2020/06/07/terraform-centos8-libvirt.html) on creating a CentOS 8 system using Terraform and the libvirt provider. Although the blog post describes Centos 8, everything also applies to Rocky Linux.

tl;dr

```lang=shell
terraform init
terraform plan
terraform apply --auto-approve --var 'vm_count=4'
```

## Get information about the installed virtual machines
After the installation for each virtual machine, the ip address is show. If you need more information, use the command `terraform show`.

For example:

```lang=shell
terraform show -json | jq '.values.root_module.resources[] | select(.type == "libvirt_domain") | .values.name + " " + .values.network_interface[].addresses[]' 
```
