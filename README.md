# rockylinux-terraform
Install Rocky Linux on a local machine with Libvirt and Terraform

Read my [blog post](https://blog.mosibi.nl/all/2020/06/07/terraform-centos8-libvirt.html) on creating a CentOS 8 system using Terraform and the libvirt provider. Although the blog post describes Centos 8, everything also applies to Rocky Linux.

tl;dr

```lang=shell
terraform init
terraform plan
terraform apply --auto-approve --var 'vm_count=4'
```
