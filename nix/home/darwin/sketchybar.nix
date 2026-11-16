{
  config,
  pkgs,
  ...
}:
let
  inherit (config.home) homeDirectory;
in
{
  # sketchybar is Home Manager managed (binary, Lua runtime, SbarLua module and
  # launchd agent). It used to be the Homebrew formula started by `brew services`,
  # whose plist hardcoded PATH=/opt/homebrew/bin:… — that PATH is what silently
  # broke every `aerospace`/`nowplaying-cli`/`SwitchAudioSource` shell-out.
  #
  # The wrapper generated here builds PATH from `extraPackages` and injects
  # LUA_CPATH/LUA_PATH for SbarLua, so the runtime is fully declared below.
  # Anything the Lua config shells out to with a bare name MUST be listed in
  # `extraPackages`, or it fails with exit 127 in the bar's error log.
  programs.sketchybar = {
    enable = true;
    configType = "lua";
    sbarLuaPackage = pkgs.sbarlua;

    extraPackages = with pkgs; [
      aerospace
      nowplaying-cli
      switchaudio-osx
    ];
  };

  # The Lua tree is linked out-of-store on purpose. Two runtime contracts make a
  # read-only store config dir impossible:
  #   1. helpers/init.lua runs `make`, writing helpers/**/bin/* on startup.
  #   2. items/apple.lua, items/widgets/cpu.lua and items/widgets/wifi.lua exec
  #      $CONFIG_DIR/helpers/**/bin/* directly.
  # With a store copy both fail silently and the CPU/network widgets and the
  # Apple menu disappear. This reproduces the previous stow symlink, so edits in
  # the repo are picked up without a rebuild.
  #
  # `programs.sketchybar.config` is deliberately NOT used: its source type routes
  # through `lib.pathIsDirectory` at eval time, which cannot see through a store
  # symlink, so it links `<config>/sketchybarrc` instead of the directory.
  xdg.configFile."sketchybar".source =
    config.lib.file.mkOutOfStoreSymlink "${homeDirectory}/dotfiles/sketchybar";

  # Home Manager writes the log paths (see `programs.sketchybar.service`) but
  # never creates the directory; launchd silently drops stdio without it.
  home.file."Library/Logs/sketchybar/.keep".text = "";

  # The Homebrew plist set LANG explicitly and the generated one does not.
  launchd.agents.sketchybar.config.EnvironmentVariables.LANG = "en_US.UTF-8";
}
