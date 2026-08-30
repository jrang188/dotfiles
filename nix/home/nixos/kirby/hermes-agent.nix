{
  # Desktop client only — connects to the remote gateway running on the
  # Kubernetes cluster (configured in-app), so no local backend/gateway
  # service is needed here.
  #
  # TEMPORARILY DISABLED: build fails with a hash mismatch fetching
  # node-v43.4.1-headers.tar.gz for the Electron renderer's native deps.
  # Re-enable once upstream (hermes-agent v2026.8.27 / nixpkgs) fixes it.
  # programs.hermes-agent = {
  #   enable = false;
  #   desktop.enable = true;
  # };
}
