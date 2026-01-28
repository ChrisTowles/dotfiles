# Docker Installation (Ubuntu/Pop!_OS)

## Install Docker Engine

```bash
# Remove old versions
sudo apt remove docker docker-engine docker.io containerd runc
sudo apt autoremove


# Install dependencies
sudo apt-get update
sudo apt-get install ca-certificates curl

# Add Docker's GPG key
sudo install -m 0755 -d /etc/apt/keyrings
sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
sudo chmod a+r /etc/apt/keyrings/docker.asc

# Add Docker repository
echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu $(. /etc/os-release && echo "${UBUNTU_CODENAME:-$VERSION_CODENAME}") stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

# Install Docker
sudo apt-get update
sudo apt-get install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
```

## Post-Install Setup

```bash
# Add your user to docker group (avoid sudo for docker commands)
sudo usermod -aG docker $USER

# Apply group changes (or log out and back in)
newgrp docker
```

## Verify Installation

```bash
docker --version 
docker compose version
```

## Setup

  Check status:
  ```bash
  systemctl status docker
```
  Start Docker if not running:

  ```bash
  sudo systemctl start docker
```
  Enable auto-start on boot:

  ```bash
  sudo systemctl enable docker
  ```

  Verify it's enabled:
  ```bash
  systemctl is-enabled docker
```
  You can also run `docker ps` as a quick check - if Docker is running, it will show containers (or an empty list). If
  not running, you'll get a connection error.