#!/bin/bash

echo "Update repos"
sudo apt update

echo "Upgrade packeges"
sudo apt upgrade -y

echo "Install ansible"
sudo apt install -y ansible jq wget unzip

echo "Check ansible version"
ansible --version

echo "Add user ansible"
groupadd devops -g 1001
useradd -u 1001 -g devops -d /home/devops -s /bin/bash -c "Usuario devops - ansible" -m devops
echo "devops:devops" | chpasswd

echo "Configure ansible user password-less sudo access"
echo "ansible ALL=(ALL) NOPASSWD:ALL" | sudo tee /etc/sudoers.d/devops


echo "Setup VIM editor"
ansible-playbook --extra-vars "ansible_sudo_pass=${sudoPass}" config-vim.yaml

# Set URL latest version Terraform
# For exclude alpha version add  egrep -v 'rc|beta|alpha'
LATEST_TERRAFORM=$(curl -sL https://releases.hashicorp.com/terraform/index.json | jq -r '.versions[].builds[].url' | sort -t. -k 1,1n -k 2,2n -k 3,3n -k 4,4n | egrep -v 'rc|beta|alpha' | egrep 'linux.*amd64' |tail -1)
#ZIP_TERRAFORM=$(curl -sL https://releases.hashicorp.com/terraform/index.json | jq -r '.versions[].builds[].url' | sort -t. -k 1,1n -k 2,2n -k 3,3n -k 4,4n | egrep -v 'rc|beta|alpha' | egrep 'linux.*amd64' |tail -1 |awk -F "/" '{print $NF}')


# Set URL latest version Packer
LATEST_PACKER=$(curl -sL https://releases.hashicorp.com/packer/index.json | jq -r '.versions[].builds[].url' | egrep 'linux.*amd64' |tail -1)

echo "Install IaC Tools"
ansible-playbook --extra-vars "ansible_sudo_pass=${sudoPass} latest_terraform=${LATEST_TERRAFORM} latest_packer=${LATEST_PACKER}" iac-tools.yaml
#ansible-playbook --extra-vars "ansible_sudo_pass=${sudoPass} latest_terraform=${LATEST_TERRAFORM} zip_terraform=${ZIP_TERRAFORM} latest_packer=${LATEST_PACKER}" iac-tools.yaml
