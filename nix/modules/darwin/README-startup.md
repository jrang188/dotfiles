# Startup Applications in nix-darwin

This module configures applications to automatically start during login using nix-darwin's `launchd.agents` option.

## Overview

nix-darwin provides `launchd.agents` for per-user startup services that start when you log in. This is the idiomatic way to handle startup applications in nix-darwin.

## Configuration

The `startup.nix` module contains:

```nix
launchd.agents = {
  kdeconnect = {
    serviceConfig = {
      Label = "org.kde.kdeconnect";
      RunAtLoad = true;
      KeepAlive = true;
      ProgramArguments = [
        "/usr/bin/open"
        "/Applications/kdeconnect-indicator.app"
      ];
      StandardOutPath = "/tmp/kdeconnect.log";
      StandardErrorPath = "/tmp/kdeconnect.log";
    };
  };
};
```

## Key Options

- **`Label`**: Unique identifier for the service (required)
- **`RunAtLoad`**: Start when user logs in (true/false)
- **`KeepAlive`**: Restart if the process dies (true/false)
- **`ProgramArguments`**: Array of command and arguments to run
- **`StandardOutPath`**: Path for stdout logging
- **`StandardErrorPath`**: Path for stderr logging

## Management

### Apply Changes

```bash
darwin-rebuild switch
```

### View Services

```bash
launchctl list | grep kdeconnect
```

### Check Logs

```bash
tail -f /tmp/kdeconnect.log
```

## Best Practices

1. Use descriptive labels that include your domain
2. Configure logging for debugging
3. Test services manually before adding to startup
4. Use `KeepAlive = true` for persistent services
5. Use `KeepAlive = false` for one-time scripts
