_: {
  # Desktop environment and related services
  services = {
    # Enable the X11 windowing system.
    # You can disable this if you're only using the Wayland session.
    xserver.enable = true;

    # Enable the GNOME Desktop Environment.
    # services.xserver.displayManager.gdm.enable = true;
    # services.xserver.desktopManager.gnome.enable = true;

    # Enable the KDE Plasma Desktop Environment.
    desktopManager.plasma6.enable = true;

    # Enable the COSMIC login manager
    displayManager.cosmic-greeter.enable = true;

    # Enable the COSMIC desktop environment
    desktopManager.cosmic.enable = true;
    system76-scheduler.enable = true;

    # Configure keymap in X11
    xserver.xkb = {
      layout = "us";
      variant = "";
    };

    # Enable CUPS to print documents.
    printing.enable = true;

    # Enable sound with pipewire.
    pulseaudio.enable = false;
    pipewire = {
      enable = true;
      alsa.enable = true;
      alsa.support32Bit = true;
      pulse.enable = true;
      # If you want to use JACK applications, uncomment this
      #jack.enable = true;

      # use the example session manager (no others are packaged yet so this is enabled by default,
      # no need to redefine it in your config for now)
      #media-session.enable = true;
    };

    # Enable touchpad support (enabled default in most desktopManager).
    # services.xserver.libinput.enable = true;

    # List services that you want to enable:

    # Enable the OpenSSH daemon.
    openssh.enable = true;
  };
  security.rtkit.enable = true;
}
