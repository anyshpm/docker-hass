# Home Assistant with Telegram Patch

这是一个修改过的 Home Assistant Docker 镜像,添加了对 Telegram Bot 代理的支持。

## 功能特点

- 基于官方 Home Assistant 镜像
- 添加了 Telegram Bot 代理支持
- 支持通过环境变量配置代理

## 使用方法

```bash
docker run -d --name homeassistant -e TELEGRAM_HTTPS_PROXY=socks5://127.0.0.1:1080   anyshpm/homeassistant:latest
```

## Docker Compose 示例

```yaml
version: '3.8'
services:
  homeassistant:
    image: anyshpm/homeassistant:latest
    environment:
      - TELEGRAM_HTTPS_PROXY=socks5://127.0.0.1:1080
```

