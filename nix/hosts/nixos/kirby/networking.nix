{ pkgs, ... }:
{
  # Networking configuration
  networking.networkmanager = {
    enable = true;
    dns = "none"; # Prevent NetworkManager from overriding DNS
    plugins = with pkgs; [
      networkmanager-openvpn # openvpn manager
    ];
  };

  # Use local DNS proxy (dnscrypt-proxy2)
  networking.nameservers = [
    "127.0.0.1"
    "::1"
  ];

  # Encrypted DNS using dnscrypt-proxy2 with AdGuard DNS
  services.dnscrypt-proxy2 = {
    enable = true;
    settings = {
      ipv6_servers = true;
      require_dnssec = true;

      # Use AdGuard DNS over HTTPS via IPv6
      server_names = [ "adguard-dns-doh-ipv6" ];

      sources.public-resolvers = {
        urls = [
          "https://raw.githubusercontent.com/DNSCrypt/dnscrypt-resolvers/master/v3/public-resolvers.md"
          "https://download.dnscrypt.info/resolvers-list/v3/public-resolvers.md"
        ];
        cache_file = "/var/cache/dnscrypt-proxy/public-resolvers.md";
        minisign_key = "RWQf6LRCGA9i53mlYecO4IzT51TGPpvWucNSCh1CBM0QTaLn73Y7GFO3";
      };
    };
  };
}
