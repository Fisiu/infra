# Infrastructure as Code - Homelab

Ansible and Terraform/OpenTofu configurations for homelab infrastructure management.

## Structure

```
.
├── ansible/
│   ├── ansible.cfg
│   ├── compose-configs/
│   ├── inventory/
│   ├── playbooks/
│   ├── requirements.yml
│   └── roles/
└── terraform/
    ├── REAME.md
    ├── main.tf
    ├── modules/
    ├── outputs.tf
    ├── providers.tf
    └── variables.tf
```

## Setup

```bash
# 1. Create directory structure
mkdir -p ansible/{inventory/group_vars/all,playbooks,roles/docker-compose-app/{tasks,templates,defaults},compose-configs/cloudflare-tunnel}
mkdir -p terraform
curl -s https://www.toptal.com/developers/gitignore/api/terraform > terraform/.gitignore

# 2. Install Ansible collections
cd ansible
ansible-galaxy install -r requirements.yml

# 3. Create vault password file
echo "your-vault-password" > ansible/.vault_pass
chmod 600 ansible/.vault_pass

# 4. Encrypt vault file
ansible-vault encrypt ansible/inventory/group_vars/all/vault.yml

# 5. Update inventory with your actual host IP and credentials

# 6. Run the initial setup (creates ansible user, installs Docker)
cd ansible
ansible-playbook playbooks/system-setup.yml -K

# 7. Switch to ansible user in inventory
# Change ansible_user from your current user to 'ansible' in inventory/hosts.yml

# 8. Run application deployments
ansible-playbook playbooks/my-appliaction.yml

# 9. Or run everything with site.yml (after switching to ansible user)
ansible-playbook playbooks/site.yml
```

## Adding New Applications

1. Create new directory: `compose-configs/myapp/`
2. Add `vars.yml` with app-specific variables
3. Add `docker-compose.yml.j2` template
4. Create playbook: `playbooks/deploy-myapp.yml`
5. Reference the `docker-compose-app` role with appropriate vars

## Useful Commands

```bash
# From ansible directory:
ansible-vault edit inventory/group_vars/all/vault.yml
ansible-vault view inventory/group_vars/all/vault.yml
ansible-vault rekey inventory/group_vars/all/vault.yml
ansible-playbook playbooks/site.yml --syntax-check
ansible-playbook playbooks/site.yml --check
ansible-playbook playbooks/site.yml --tags "docker"
ansible-playbook playbooks/site.yml --limit debian-server

# From project root:
ansible-playbook -i ansible/inventory/hosts.yml ansible/playbooks/site.yml
ansible-playbook -i ansible/inventory/hosts.yml ansible/playbooks/site.yml --syntax-check
```

## Terraform/OpenTofu Usage

OpenTofu is used to provision and manage infrastructure components such as virtual machines and LXC containers. The configuration is modularized for reusability.

### Setup and Deployment

1.  **Initialize OpenTofu**: Navigate to the `terraform/` directory and initialize the backend and modules.
    ```bash
    cd terraform
    tofu init
    ```
2.  **Review Plan**: Generate an execution plan to see what actions OpenTofu will perform.
    ```bash
    tofu plan
    ```
3.  **Apply Changes**: Apply the planned changes to create or update infrastructure.
    ```bash
    tofu apply
    ```

### Modules

The `opentofu/modules/` directory contains reusable OpenTofu configurations:

*   `lxc/`: Configuration for deploying LXC containers.
*   `nas-s3/`: Configuration for network-attached storage or S3-compatible storage setup.
*   `vm/`: Configuration for provisioning virtual machines, including cloud-init user data.

### Variables

Sensitive variables or environment-specific configurations should be managed in `terraform/terraform.tfvars` (which is gitignored) or passed via environment variables.

### Useful OpenTofu Commands

```bash
# From opentofu directory:
tofu fmt                      # Format OpenTofu configuration files
tofu validate                 # Validate the configuration files
tofu destroy                  # Destroy the managed infrastructure (use with caution!)
tofu show                     # Show the current state or a plan file
tofu graph                    # Generate a visual graph of the OpenTofu configuration
```
