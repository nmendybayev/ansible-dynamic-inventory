# Terraform - Ansible Integration Project

## In this project, I will create two AWS EC2 instances, then I will use a dynamic 'inventory.py' file to pass EC2s' IPs to Ansible, which will configure Nginx servers on the created EC2 machines. 

### Prerequisites:
1. Terraform installed
2. Ansible installed
3. Pre-provisioned VPC with an Internet Gateway (IGW) and at least one subnet (in us-east-1)
4. Pre-provisioned SSH key pair named 'devops'
5. Good understanding of Terraform, Ansible, and SSH

### Project structure:
```
.
├── README.md
├── ansible.cfg
├── inventory.py
├── main.tf
├── nginx.yaml
├── roles
│   └── nginx
│       └── tasks
│           └── main.yaml
```
### Files functionality:
'main.tf'      – creates two EC2 instances and a Security Group
'nginx.yaml'   – Ansible playbook that installs Nginx on the EC2 instances
'inventory.py' – dynamic inventory (used instead of inventory.ini), written in Python
'main.yaml'    – task file used by the nginx role to install and start Nginx
'ansible.cfg'  – Ansible configuration file that specifies 'inventory.py' as the inventory source

### Commands to implement/destroy the project:

OPTIONAL:

terraform init
terraform validate
terraform fmt
terraform plan

REQUIRED:

chmod +x inventory.py                     # make inventory file executable
chmod 400 path-to-key-pair/devops.pem     # make SSH key-pair only for reading

TO PROVISION AND CONFIGURE:

terraform apply -auto-approve
ansible-playbook nginx.yaml

TO DESTROY:

terraform destroy -auto-approve

### Need to know:

File 'main.tf' contain the commented lines:

```
# provisioner "local-exec" {
#   command = "ansible-playbook -i ./inventory.py --private-key ${local.private_key_path} nginx.yaml"
#   }
```

'if uncomment them, it will allow you to run whole code with only one command 'terraform apply -auto-approve'.'

In general, I recommend keeping those lines commented out and running Terraform and Ansible separately during development and testing. Once all issues are resolved and everything works as expected, you can uncomment the lines and use terraform apply -auto-approve to provision and configure the EC2 instances in a single step.


# Deliverables:
Once all commands ran, you should expect following message, this is an example:

```
Apply complete! Resources: 3 added, 0 changed, 0 destroyed.

Outputs:

nginx_ips = [
  "34.238.240.98",
  "54.205.87.225",
]
```

Then you 