#!/usr/bin/env python3
import json
import subprocess

def get_terraform_output():
    output = subprocess.check_output(["terraform", "output", "-json"])
    return json.loads(output)

def build_inventory():
    tf_output = get_terraform_output()
    hosts = tf_output["nginx_ips"]["value"]

    inventory = {
        "nginx": {
            "hosts": hosts,
            "vars": {
                "ansible_user": "ec2-user",
                "ansible_ssh_private_key_file": "/users/hosha/devops.pem"
            }
        }
    }

    print(json.dumps(inventory))

if __name__ == "__main__":
    build_inventory()