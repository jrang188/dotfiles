{
  # Desktop client only — connects to the remote gateway running on the
  # Kubernetes cluster (configured in-app), so no local backend/gateway
  # service is needed here.
  programs.hermes-agent = {
    enable = true;
    desktop.enable = true;
  };
}
