# Caddy Installation

```sh
sudo apt update
sudo apt install -y debian-keyring debian-archive-keyring apt-transport-https
curl -1sLf 'https://dl.cloudsmith.io/public/caddy/stable/gpg.key' | sudo gpg --dearmor -o /usr/share/keyrings/caddy.gpg
curl -1sLf 'https://dl.cloudsmith.io/public/caddy/stable/debian.deb.txt' | sudo tee /etc/apt/sources.list.d/caddy.list
sudo apt update
sudo apt install -y caddy
```

---

### Create file on machine or instance:

> sudo nano /etc/caddy/Caddyfile

#### File content: 

```
{
    email jaipal.gritblaster.in@gmail.com  
}

# Redirect non-www → www
asianglassbeads.com {
    redir https://www.asianglassbeads.com{uri} permanent
}

# Main canonical site
www.asianglassbeads.com {
    reverse_proxy 127.0.0.1:5173
}
```
---

#### Caddyfile (1-Month Browser Caching)

> sudo nano /etc/caddy/Caddyfile
```sh
{
    email jaipal.gritblaster.in@gmail.com
}

asianglassbeads.com, www.asianglassbeads.com {

    # Redirect non-www → www
    @nonwww {
        host asianglassbeads.com
    }
    redir @nonwww https://www.asianglassbeads.com{uri} permanent

    reverse_proxy 127.0.0.1:5173

    # Cache static assets in browser for 1 month
    header {
        Cache-Control "public, max-age=2592000, immutable"  
    }
    # update max-age = time in sec (as per time requirment) 

    # Never cache API / admin
    @nocache {
        path /api/* /admin/*
    }
    header @nocache {
        Cache-Control "no-store"
    }
}

```
###  Summery Caddyfile (1-Month Browser Caching)
```
 Static assets cached for 30 days
 Faster repeat page loads
 Lower server load
 Safe for production
 API & admin routes never cached

| Feature         | Status                  |
| --------------- | ----------------------  |
| HTTPS           | ✅                      |
| TLS 1.3         | ✅                      |
| HTTP/2          | ✅                      |
| HTTP/3          | ✅                      |
| Auto SSL        | ✅                      |
| Browser Caching | ✅ (after config above) |
| Reverse Proxy   | ✅                      |
```
---


### To Validate file

```sh
sudo caddy validate --config /etc/caddy/Caddyfile
```
---

#### Firewall rules:

```sh
sudo ufw allow 80
sudo ufw allow 443
sudo ufw reload
```
---

#### Check Status of Caddy

```sh
sudo systemctl restart caddy
sudo systemctl status caddy
```
---
### Check if not working the again restart caddy after few minutes
```sh
sudo systemctl restart caddy  # use this command twise or more
sudo systemctl reload caddy   # use this command twise or more
```

### View Log:

```sh
sudo journalctl -u caddy -f
```
------------

Shows the current running status of the Caddy service, with admin permissions, directly in the terminal without scrolling mode.

```sh
sudo systemctl status caddy --no-pager
```
What you will see in output
```
caddy.service - Caddy
     Loaded: loaded (/usr/lib/systemd/system/caddy.service; enabled; preset: enabled)
     Active: active (running) since Mon 2025-12-15 07:02:02 UTC; 30min ago
       Docs: https://caddyserver.com/docs/
   Main PID: 4110 (caddy)
      Tasks: 8 (limit: 4667)
     Memory: 9.2M (peak: 11.6M)
        CPU: 419ms
     CGroup: /system.slice/caddy.service
             └─4110 /usr/bin/caddy run --environ --config /etc/caddy/Caddyfile

```
---
## Caddy enable by defalt features 
```
| Feature                | Status     |
| ---------------------- | ---------  |
| HTTPS                  | ✅ Enabled |
| TLS 1.3                | ✅ Enabled |
| HTTP/2                 | ✅ Enabled |
| HTTP/3 (QUIC)          | ✅ Enabled |
| Automatic Cert Renewal | ✅ Enabled |
```
