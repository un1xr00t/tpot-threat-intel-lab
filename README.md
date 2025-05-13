
# 🛡️ T-Pot Honeypot Setup on Linode

This guide walks you through setting up the **T-Pot honeypot platform** on a Linode VPS using the most recent working version, plus how to pull logs from Elasticsearch/Kibana via CLI.

---

## ⚙️ Requirements

- Linode VPS (Ubuntu 22.04 recommended)
- At least 4 vCPUs, 8GB RAM, 128GB storage
- Public IP & root access
- Git, curl, Docker, Docker Compose

---

## 🧰 Step 1: System Update & Tools

```bash
sudo apt update && sudo apt upgrade -y
sudo apt install git curl ufw docker.io docker-compose -y
```

---

## 🧱 Step 2: Clone the T-Pot Repository

```bash
git clone https://github.com/telekom-security/tpotce.git
cd tpotce/iso/installer/
```

> ✅ Credit: GitHub user **[@tpotce](https://github.com/telekom-security/tpotce)**

---

## 🛠️ Step 3: Run the T-Pot Installer

```bash
sudo ./install.sh
```

- Choose **"Standard"** or your preferred profile during install.
- Reboot when prompted.

---

## 🌐 Step 4: Configure UFW and Ports

```bash
sudo ufw allow 64297:64299/tcp
sudo ufw allow 22/tcp
sudo ufw enable
```

---

## 🔍 Step 5: Access Kibana

- Open browser: `http://YOUR_SERVER_IP:64297`
- Default creds:
  - **Username**: `admin`
  - **Password**: (set during install)


## 🧾 Optional: Enable SSH Port Forwarding

If needed for analysis or testing:
```bash
ssh -L 64297:localhost:64297 -L 64298:localhost:64298 user@YOUR_SERVER_IP
```

---

## 🙌 Credits

- **T-Pot GitHub Repo**: [https://github.com/telekom-security/tpotce](https://github.com/telekom-security/tpotce)
- Installer maintained by: `tpotce`

---

## 📎 Notes

- If the installer fails initially, try rebooting and running it again.
- All honeypot data is viewable in Kibana (`64297`) or accessible via CLI (port `64298`).

---

## 📎 Included Scripts

Two scripts are provided in this repo to enhance log collection and session analysis:

### 1. `tpotsummary.sh`

Summarizes recent session activity across T-Pot services.

**Usage:**
```bash
sudo ./tpotsummary.sh
```

---

### 2. `cowrielogs.sh`

Parses and summarizes sessions from Cowrie honeypot logs.

**Usage:**
```bash
sudo ./cowrielogs.sh
# Add --commands-only to filter only sessions where commands were run
bash cowrielogs.sh --commands-only
```

Make sure the script has execute permissions:
```bash
chmod +x tpotsummary.sh cowrielogs.sh
```

These tools make it easier to inspect and respond to attacker behavior quickly from the terminal.

---
