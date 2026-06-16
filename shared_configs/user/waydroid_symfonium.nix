{ config, pkgs, ... }:

{
  # Waydroid - Android in a container (single app mode: Symfonium)
  virtualisation.waydroid.enable = true;
  virtualisation.waydroid.package = pkgs.waydroid-nftables;

  # GPU adjustments for NVIDIA RTX 4070 (disable GBM/mesa, use SwiftShader)
  systemd.tmpfiles.rules = [
    "d /var/lib/waydroid 0755 root root -"
  ];
  systemd.services.waydroid-pre-config = {
    description = "Write Waydroid GPU base props";
    before = [ "waydroid-container.service" ];
    wantedBy = [ "waydroid-container.service" ];
    script = ''
      cat > /var/lib/waydroid/waydroid_base.prop << 'EOF'
ro.hardware.gralloc=default
ro.hardware.egl=swiftshader
EOF

      # Bind mount /mnt to Android's Music directory so Symfonium finds it
      if [ -f /var/lib/waydroid/waydroid.cfg ]; then
        sed -i '/^mounts =/d' /var/lib/waydroid/waydroid.cfg
        sed -i '/^\[waydroid\]/a mounts = /mnt:/data/media/0/Music' /var/lib/waydroid/waydroid.cfg
      else
        mkdir -p /var/lib/waydroid
        printf '%s\n' '[waydroid]' 'mounts = /mnt:/data/media/0/Music' > /var/lib/waydroid/waydroid.cfg
      fi
    '';
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
    };
  };

  # Set single-app mode for Symfonium after container starts
  systemd.services.waydroid-single-app = {
    description = "Set Waydroid single app mode for Symfonium";
    after = [ "waydroid-container.service" ];
    bindsTo = [ "waydroid-container.service" ];
    script = ''
      ${pkgs.waydroid-nftables}/bin/waydroid prop set persist.waydroid.single_app app.symfonik.music.player
      ${pkgs.waydroid-nftables}/bin/waydroid shell am broadcast -a android.intent.action.MEDIA_SCANNER_SCAN_FILE -d file:///storage/emulated/0/Music 2>/dev/null || true
    '';
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
    };
  };
}
