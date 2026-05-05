# Company Password Vault

Self-hosted Vaultwarden deployment — Bitwarden-compatible, zero-knowledge, encrypted password management for the team.

## Architecture

```
User Device (Bitwarden app/extension) → HTTPS → Vaultwarden → SQLite
```

## Local Development

### Prerequisites

- Docker Desktop installed
- Git

### Setup

1. Copy the environment template:

```bash
cp .env.example .env
```

2. Generate an admin token:

```bash
openssl rand -hex 32
```

3. Paste the token into `.env`:

```
ADMIN_TOKEN=<paste-generated-token-here>
```

4. Start the stack:

```bash
docker compose up -d
```

5. Access the vault:

- Vault UI: `https://localhost` (accept the self-signed cert warning)
- Admin panel: `https://localhost/admin` (append `?token=<ADMIN_TOKEN>` if not prompted)

### Admin Panel Configuration

Once logged into `/admin`:

1. **General Settings** — Confirm `DOMAIN` is set correctly
2. **Invitations** — Set to `true`, sign-ups disabled
3. **Security** — Enable:
   - Master password policy: min 14 chars, complexity required
   - Password hint: disallowed
   - Vault timeout: 5 minutes
   - Login rate limiting: 5 attempts / 5 minutes
4. **Organization** — Create your company org and collections
5. Apply settings and restart the container if needed

### User Onboarding (Invite-Only)

1. In the admin panel, go to **Users → Invite User**
2. Enter the user's email
3. User receives an invite link, sets their own master password, and enables 2FA
4. User is added to the appropriate Organization collections

## Railway Deployment

### Step 1: Push to GitHub

```bash
git init
git add .
git commit -m "Initial Vaultwarden deployment setup"
git remote add origin <your-github-repo-url>
git push -u origin main
```

### Step 2: Create Railway Project

1. Go to [railway.app](https://railway.app) and sign in
2. Click **New Project → Deploy from GitHub repo**
3. Select your repository

### Step 3: Configure Environment Variables

In the Railway dashboard, set these variables on the service:

| Variable | Value |
|---|---|
| `ADMIN_TOKEN` | Your 64+ character random token |
| `SIGNUPS_ALLOWED` | `false` |
| `INVITATIONS_ALLOWED` | `true` |
| `DOMAIN` | Your Railway URL (e.g., `https://vault-abc123.up.railway.app`) |
| `WEBSOCKET_ENABLED` | `true` |
| `DATA_FOLDER` | `/data` |
| `PASSWORD_HINTS_ALLOWED` | `false` |
| `VAULT_TIMEOUT_MINUTES` | `5` |
| `LOGIN_RATELIMIT_MAX_BURST` | `10` |
| `LOGIN_RATELIMIT_SECONDS` | `300` |
| `LOGIN_RATELIMIT_COUNT` | `5` |

### Step 4: Add Persistent Volume

1. In Railway, go to **Volumes → Add Volume**
2. Mount path: `/data`
3. Size: 1 GB (enough for 10+ users)

### Step 5: Deploy

Railway automatically builds and deploys. Once running:

- Visit `https://<your-project>.up.railway.app`
- Access admin at `https://<your-project>.up.railway.app/admin?token=<ADMIN_TOKEN>`

## Security Checklist

- [x] Public sign-ups disabled
- [x] Invitation-only access
- [x] Admin token set (64+ random characters)
- [x] Password hints disabled
- [x] Vault auto-lock after 5 minutes
- [x] Login rate limiting enabled
- [ ] **Enable mandatory TOTP 2FA** (configure in Organization policies after setup)
- [ ] **Configure SMTP** (for automated invite emails)
- [ ] **Set up automated backups** (see below)

## Backups

### Manual Backup

```bash
docker cp vaultwarden:/data/db.sqlite3 ./backup_$(date +%Y%m%d).sqlite3
```

### Automated Backup (Railway)

The `scripts/backup.sh` script is included in the container. To run it on a schedule:

1. Railway supports cron jobs — configure a scheduled job to run:
   ```
   bash /scripts/backup.sh
   ```
2. Or mount a volume at `/backups` and download periodically

### Restore from Backup

```bash
docker cp backup_YYYYMMDD.sqlite3 vaultwarden:/data/db.sqlite3
docker restart vaultwarden
```

## Organization Structure

Recommended collections for the team:

| Collection | Purpose |
|---|---|
| Infrastructure | Servers, routers, firewalls, VPN |
| Cloud Services | M365, Google Workspace, AWS, Azure |
| Business Apps | CRM, ERP, accounting, HR |
| Communications | Email, Slack, Teams |
| Social & Marketing | Social media accounts, marketing tools |
| Vendor Portals | Vendor logins, licensing |
| Personal | Private vault per user (not shared) |

## Password Generation Policy

| Type | Length | Characters |
|---|---|---|
| Standard | 16 | Upper, lower, numbers, symbols |
| Server Admin | 24 | Upper, lower, numbers, symbols |
| Passphrase | 6 words | EFF wordlist, separator `-` |

## Troubleshooting

### Cannot connect to localhost
```bash
docker compose logs caddy
docker compose logs vaultwarden
```

### Admin panel not loading
Ensure `ADMIN_TOKEN` is set in `.env` and append `?token=<value>` to the URL.

### Certificate warning in browser
Expected for local development — Caddy generates a self-signed cert. Click "Advanced → Proceed."

### Database locked error
Only one process should access the SQLite file. Stop any other containers touching `/data`.
