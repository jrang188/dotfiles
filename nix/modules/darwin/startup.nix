{ ... }:
{
  # Configure applications to start automatically on login
  launchd.agents = {
    # Start KDE Connect indicator (nightly build)
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
}
