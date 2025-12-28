# Office Status Dashboard

A Phoenix LiveView application for managing office availability status, designed for TRMNL e-ink displays.

**Live at:** https://office-status.fly.dev/

## Features

- 🖥️ **Real-time dashboard** with large, touch-friendly status buttons
- 🔄 **TRMNL integration** - POSTs status updates to TRMNL displays automatically
- ✏️ **Editable messages** - click the message text to customize
- 🌙 **Modern dark UI** with glassmorphism effects and animated gradients
- 📱 **Mobile responsive** - control status from any device

## Status Presets

| Status | Icon | Default Message |
|--------|------|-----------------|
| Available | 🟢 | Come on in! |
| In a Meeting | 🔴 | In a meeting, please wait |
| Deep Focus | 🎧 | Deep work mode - check back later |
| On a Call | 📞 | On a call |
| Break | ☕ | Taking a break, back soon |
| Away | 🚶 | Away from desk |

## API

```bash
curl https://office-status.fly.dev/api/status
```

Returns:
```json
{
  "status": "ok",
  "name": "Available",
  "message": "Come on in!",
  "icon": "🟢",
  "color": "green"
}
```

## Local Development

```bash
# Install dependencies
mix setup

# Start server
mix phx.server
```

Visit http://localhost:4000

## Deployment

Deployed on [Fly.io](https://fly.io) with:
- 2 machines in San Jose (auto-stop/auto-start)
- Postgres database
- GitHub Actions for auto-deploy on push

```bash
fly deploy
```

## Configuration

TRMNL webhook URL is configured in `lib/office_status/trmnl.ex`.
