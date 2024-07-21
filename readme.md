# Infra

Infrastructure as code using HashiCorp stack.

## How to use 

*This is only a temporary instruction.*

### Create a ssh key

Create an ssh key pair, for example, called `terraform_rsa`. This will be used to access the VMs.

```bash
ssh-keygen -t rsa -b 4096 
```


###  Config VMs 

You will need to install Docker and setup ssh keys for the VMs. 
You can use the script inside the `scripts` folder to do that. It will install docker and create an User named `terraform`. You will need to provide the ssh key you created before.

```bash
./scripts/config-vm.sh <path-to-ssh-key>
```

### Terraform

You will need to have Terraform installed. You can download it [here](https://www.terraform.io/downloads.html).

Take a look at the `variables.tf` and see what variables you need to set. You can create a `terraform.tfvars` file and set the variables there.

After that, you can run the following commands to create the infrastructure.

```bash
terraform init 
terraform apply
```





 