# Ansible Deployment for TasklistApp

This directory contains Ansible playbooks and configuration for deploying the TasklistApp to a local VM via SSH.

## Prerequisites

1. **SSH Access to WSL VM**
   - SSH server running on WSL on port 2222
   - SSH key-based authentication configured

## SSH Setup Details

### 1. Key Generation
```bash
# On Windows (PowerShell)
ssh-keygen -t ed25519 -f $HOME\.ssh\id_ed25519_wsl
```

### 2. Copy Public Key to WSL
```bash
# On Windows (PowerShell)
type $HOME\.ssh\id_ed25519_wsl.pub | ssh -p 2222 siseko@localhost "mkdir -p ~/.ssh && cat >> ~/.ssh/authorized_keys"
```

### 3. Set Correct Permissions in WSL
```bash
chmod 700 ~/.ssh
chmod 600 ~/.ssh/authorized_keys
```

## Testing SSH Connection
```bash
ssh -i C:\Users\Wipro\.ssh\id_ed25519_wsl siseko@localhost -p 2222
```

## Running the Playbook Locally

1. Install Ansible:
```bash
sudo apt-get update && sudo apt-get install -y ansible
```

2. Run the playbook:
```bash
ansible-playbook -i inventory.ini deploy_vm.yml
```

## GitHub Actions Integration

The `.github/workflows/deploy-vm.yml` workflow will automatically:
1. Check out the repository
2. Install Ansible
3. Run the playbook to deploy the application

## Troubleshooting

- **Permission denied (publickey)**: Verify the SSH key permissions and that the public key is in `~/.ssh/authorized_keys` on the WSL VM.
- **Connection refused**: Ensure the SSH server is running on WSL and port 2222 is forwarded correctly.
- **Playbook fails**: Check Ansible logs for specific error messages and verify Docker is running on the target VM.
