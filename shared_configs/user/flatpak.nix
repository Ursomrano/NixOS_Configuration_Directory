{ config, pkgs, ... }:
let
  grep = pkgs.gnugrep;
  desiredFlatpaks = [ 
  	"com.fightcade.Fightcade"
	"com.bambulab.BambuStudio"
  ];
  desiredFlatpaksStr = builtins.concatStringsSep " " desiredFlatpaks;
in {
  system.userActivationScripts.flatpakManagement = {
  	text = ''
    		PATH=$PATH:${pkgs.flatpak}/bin

    		flatpak remote-add --if-not-exists flathub \
		https://dl.flathub.org/repo/flathub.flatpakrepo
    			installedFlatpaks=$(flatpak list --app --columns=application)

    		for installed in $installedFlatpaks; do
      			if ! echo "${desiredFlatpaksStr}" \
			| ${pkgs.gnugrep}/bin/grep -q $installed; then
        			echo "Removing $installed because it's not in the desiredFlatpaks list."
        			flatpak uninstall -y --noninteractive $installed
      			fi
    		done

    		for app in ${desiredFlatpaksStr}; do
      			echo "Ensuring $app is installed."
      			flatpak install -y --noninteractive flathub $app || true
    		done

    		flatpak uninstall --unused -y
    		flatpak update -y
  	'';
  };
}
