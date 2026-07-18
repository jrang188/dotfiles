_: {
  # Add ability to used TouchID for sudo authentication
  security.pam.services.sudo_local = {
    enable = true;
    touchIdAuth = true;
    reattach = true;
  };
}
