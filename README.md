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
| Available | ✓ | Come on in! |
| In a Meeting | ⛔ | In a meeting, please wait |
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
  "icon": "✓",
  "color": "green"
}
```

## TRMNL Plugin Template

Use this markup in your TRMNL custom plugin:

```liquid
{% assign settings = trmnl.plugin_settings.custom_fields_values %}
{% assign theme_setting = settings.theme_mode %}

{% assign s_name    = name    | default: settings.default_status %}
{% assign s_message = message | default: "" %}
{% assign s_icon    = icon    | default: "" %}
{% assign s_color   = color   | default: "gray" %}

{% assign is_busy = false %}
{% if s_color == "red" or s_color == "orange" %}
  {% assign is_busy = true %}
{% endif %}

{% assign bg_class = "" %}
{% assign text_class = "color--black" %}
{% assign border_class = "border--black" %}

{% if theme_setting contains 'Dark' or (theme_setting contains 'Auto' and is_busy) %}
  {% assign bg_class = "bg--black" %}
  {% assign text_class = "color--white" %}
  {% assign border_class = "border--white" %}
{% endif %}

<div class="layout layout--center {{ bg_class }} {{ text_class }}" style="padding: 32px;">
  <div class="column">
    
    <div class="content--s weight--bold mb--m" style="letter-spacing: 3px;">
      {{ settings.office_owner | upcase }}
    </div>

    <div class="item item--full-width item--center border--none">
      <div class="column">
        <div class="weight--bold" style="font-size: 72px; line-height: 1;">
          {% if s_icon != "" %}{{ s_icon }} {% endif %}{{ s_name | upcase }}
        </div>
      </div>
    </div>

    {% if s_message != "" %}
      <div class="hr mt--l mb--l {{ border_class }}" style="opacity: 0.3;"></div>
      <div class="content--l weight--regular">
        {{ s_message }}
      </div>
    {% endif %}
    
    <div class="content--s mt--xl" style="opacity: 0.5;">
      {{ "now" | date: "%I:%M %p" }}
    </div>

  </div>
</div>
```

### Form Fields (YAML)

```yaml
- keyname: office_owner
  name: Room Owner
  field_type: string
  default_value: "CHELSEA'S OFFICE"
- keyname: default_status
  name: Default Status
  field_type: select
  options:
    - Available
    - In a Meeting
    - Deep Focus
    - On a Call
    - Break
    - Away
  default_value: "Available"
- keyname: theme_mode
  name: Theme Behavior
  field_type: select
  options:
    - Auto-Invert (Red/Orange = Black)
    - Always Light
    - Always Dark
  default_value: "Auto-Invert (Red/Orange = Black)"
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
