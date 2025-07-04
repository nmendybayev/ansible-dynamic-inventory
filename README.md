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

To streamline the process of provisioning and configuring you can add this code to 'main.tf' and then you be able to run only 'terraform apply -auto-approve' command:

```
# Null resource to wait for SSH availability on each EC2 instance before proceeding

resource "null_resource" "wait_for_ssh" {
  count = 2

  # Remote-exec provisioner runs commands on the remote EC2 instance via SSH

  provisioner "remote-exec" {
    inline = [
      "echo SSH is up on ${aws_instance.nginx[count.index].public_ip}"
    ]

    connection {
      type        = "ssh"
      user        = "ec2-user"
      private_key = file(local.private_key_path)
      host        = aws_instance.nginx[count.index].public_ip
      timeout     = "5m"
    }
  }

  # Local-exec provisioner runs a shell script on the local machine running Terraform

  provisioner "local-exec" {
    command = <<EOT
      for i in {1..60}; do
        ssh -o StrictHostKeyChecking=no -o ConnectTimeout=5 -i "${local.private_key_path}" ec2-user@${aws_instance.nginx[count.index].public_ip} "echo 'SSH OK'" && exit 0
        echo "Waiting for SSH on ${aws_instance.nginx[count.index].public_ip}... ($i/60)"
        sleep 5
      done
      echo "ERROR: SSH not ready on ${aws_instance.nginx[count.index].public_ip} after 5 minutes"
      exit 1
    EOT
  }

  # This resource depends on the EC2 instances being created first

  depends_on = [aws_instance.nginx]
}

# Running ansible playbook after SSH is ready on all instances

resource "null_resource" "run_ansible" {

  # This resource depends on the null-resource being created first

  depends_on = [null_resource.wait_for_ssh]

  # runs Ansible dynamic playbook
  
  provisioner "local-exec" {
    command = "ansible-playbook -i ./inventory.py nginx.yaml"
  }
}

```

In general, I recommend running Terraform and Ansible separately during development and testing. Once all issues are resolved and everything works as expected, you can add the following code to the 'main.tf' and use 'terraform apply -auto-approve' to provision and configure the EC2 instances in a single step.


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

Then you have to check your IPs in an internet browser to see the NGINX welcome page.

## That is all. It was a project where we used dynamic inbentory file to configure VMs. 