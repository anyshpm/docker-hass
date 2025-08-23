# 🏠 Home Assistant with Telegram Proxy Patch

[![Docker Image](https://img.shields.io/badge/docker-anyshpm%2Fhomeassistant-blue?logo=docker)](https://hub.docker.com/r/anyshpm/homeassistant)
[![Home Assistant](https://img.shields.io/badge/Home%20Assistant-2025.4.1-blue?logo=home-assistant)](https://www.home-assistant.io/)
[![License](https://img.shields.io/badge/license-MIT-green.svg)](LICENSE)
[![Maintainer](https://img.shields.io/badge/maintainer-Anyshpm%20Chen-orange)](mailto:anyshpm@anyshpm.com)

A modified Home Assistant Docker image with built-in Telegram proxy support for seamless bot communication in restricted network environments.

## ✨ Features

- 🏠 **Based on Official Image**: Built on `homeassistant/home-assistant`
- 🤖 **Telegram Bot Proxy**: Automatic proxy support for Telegram Bot API
- 🔧 **Environment Configuration**: Easy proxy setup via environment variables
- 🚀 **Drop-in Replacement**: Compatible with existing Home Assistant setups
- 🔒 **Secure**: Maintains all original Home Assistant security features

## 🚀 Quick Start

### Using Docker Run

```bash
docker run -d \
  --name homeassistant \
  --restart=unless-stopped \
  -e TELEGRAM_HTTPS_PROXY=socks5://127.0.0.1:1080 \
  -p 8123:8123 \
  -v /path/to/config:/config \
  anyshpm/homeassistant:latest
```

### Using Docker Compose

```yaml
version: '3.8'
services:
  homeassistant:
    image: anyshpm/homeassistant:latest
    container_name: homeassistant
    restart: unless-stopped
    ports:
      - "8123:8123"
    volumes:
      - /path/to/config:/config
      - /etc/localtime:/etc/localtime:ro
    environment:
      - TELEGRAM_HTTPS_PROXY=socks5://127.0.0.1:1080
    privileged: true
    network_mode: host
```

## ⚙️ Configuration

### Environment Variables

| Variable | Description | Example Values | Required |
|----------|-------------|----------------|----------|
| `TELEGRAM_HTTPS_PROXY` | Proxy URL for Telegram API requests | `socks5://127.0.0.1:1080`<br>`http://proxy.example.com:8080` | No |
| `telegram_https_proxy` | Alternative lowercase variable name | Same as above | No |

### Supported Proxy Types

- **SOCKS5**: `socks5://host:port`
- **HTTP**: `http://host:port`
- **HTTPS**: `https://host:port`
- **With Authentication**: `socks5://username:password@host:port`

## 🎯 Use Cases

### 1. **Restricted Networks**
Perfect for users in regions where Telegram API access is limited or blocked.

### 2. **Corporate Environments**
Ideal for deployment in corporate networks that require proxy for external communications.

### 3. **Privacy-Focused Setups**
For users who want to route Telegram bot traffic through VPN or privacy proxies.

### 4. **Development & Testing**
Useful for developers testing Telegram bot integrations in various network conditions.

## 📋 Requirements

- **Docker**: Version 20.10 or higher
- **Docker Compose**: Version 2.0 or higher (if using docker-compose)
- **Network Access**: Connectivity to your proxy server
- **Storage**: Minimum 2GB free space for Home Assistant data

## 🔨 Building from Source

### Prerequisites
```bash
git clone https://github.com/yourusername/docker-hass.git
cd docker-hass
```

### Build the Image
```bash
docker build -t your-registry/homeassistant:custom .
```

### Build with Custom Base Version
```bash
docker build --build-arg HA_VERSION=2025.4.2 -t your-registry/homeassistant:custom .
```

## 🔍 How It Works

This image applies a patch to the Python Telegram Bot library within Home Assistant that:

1. **Intercepts Proxy Configuration**: Modifies `_httpxrequest.py` to check for environment variables
2. **Automatic Detection**: If no proxy is explicitly configured, checks `TELEGRAM_HTTPS_PROXY`
3. **Fallback Support**: Also supports lowercase `telegram_https_proxy` variable
4. **Transparent Operation**: Works seamlessly with existing Home Assistant Telegram integrations

## 🚨 Troubleshooting

### Common Issues

#### ❌ **Telegram Bot Not Responding**
```bash
# Check if proxy is correctly set
docker logs homeassistant | grep -i telegram

# Verify proxy connectivity
docker exec homeassistant wget -e use_proxy=yes -e https_proxy=$TELEGRAM_HTTPS_PROXY https://api.telegram.org
```

#### ❌ **Proxy Connection Failed**
```bash
# Test proxy from container
docker exec homeassistant curl --proxy $TELEGRAM_HTTPS_PROXY https://api.telegram.org

# Check proxy server logs
# Verify proxy credentials if using authentication
```

#### ❌ **Home Assistant Won't Start**
```bash
# Check container logs
docker logs homeassistant

# Verify volume permissions
sudo chown -R 1000:1000 /path/to/config
```

### Debug Mode

Enable verbose logging:
```yaml
logger:
  default: info
  logs:
    telegram: debug
    telegram.bot: debug
```

## 📚 Examples

### Example 1: Basic Setup with SOCKS5 Proxy
```bash
docker run -d \
  --name ha-telegram \
  -e TELEGRAM_HTTPS_PROXY=socks5://192.168.1.100:1080 \
  -p 8123:8123 \
  -v $(pwd)/config:/config \
  anyshpm/homeassistant:latest
```

### Example 2: Complete Docker Compose with Proxy
```yaml
version: '3.8'
services:
  homeassistant:
    image: anyshpm/homeassistant:latest
    container_name: homeassistant
    restart: unless-stopped
    ports:
      - "8123:8123"
    volumes:
      - ./config:/config
      - /etc/localtime:/etc/localtime:ro
    environment:
      - TZ=America/New_York
      - TELEGRAM_HTTPS_PROXY=socks5://vpn-server:1080
    depends_on:
      - vpn-proxy
    
  vpn-proxy:
    image: serjs/go-socks5-proxy
    container_name: socks5-proxy
    ports:
      - "1080:1080"
    environment:
      - PROXY_USER=username
      - PROXY_PASSWORD=password
```

### Example 3: Home Assistant Configuration
```yaml
# configuration.yaml
telegram_bot:
  - platform: polling
    api_key: "YOUR_BOT_TOKEN"
    allowed_chat_ids:
      - 123456789

notify:
  - name: telegram
    platform: telegram
    chat_id: 123456789
```

## 🤝 Contributing

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🙏 Acknowledgments

- [Home Assistant](https://www.home-assistant.io/) - The amazing home automation platform
- [Python Telegram Bot](https://python-telegram-bot.org/) - The Telegram Bot API wrapper
- Community contributors who helped improve this project

## 📞 Support

- **Issues**: [GitHub Issues](https://github.com/yourusername/docker-hass/issues)
- **Discussions**: [GitHub Discussions](https://github.com/yourusername/docker-hass/discussions)
- **Email**: [anyshpm@anyshpm.com](mailto:anyshpm@anyshpm.com)

---

**⭐ If this project helped you, please consider giving it a star!**
