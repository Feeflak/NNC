{
  flake.homeModules.general = {
    programs = {
      fish = {
        enable = true;
        shellAliases = {
          bsudo = "sudo -sE";
          pages = "z ~/git/pages/src/content/docs/";
          readHost = "set -g host (cat /etc/nixos/host.txt)";
          addToDict = " nim r --hints:off /etc/nixos/NNC/utils/addToDict.nim";
          syncTodo = "pushd ~/git/todo/;git pull;git add -A;git commit -m 'Update';git push;clear;popd";
          todo = "/etc/nixos/NNC/utils/todo/target/debug/todo ";
          orun = "set -x OCAMLRUNPARAM b; dune build; dune exec";
          q = "qalc -c -i";
          helium = "nix run github:AlvaroParker/helium-nix";
          # zen = "nix run github:youwen5/zen-browser-flake";
          onUpdate = "sudo /etc/nixos/onUpdate.sh";
          rebuild = "readHost ; cd /etc/nixos/NNC/ ; git add '*'; sudo nix run .#write-flake --access-tokens github.com=$GITHUB_TOKEN ; sudo nixos-rebuild switch --upgrade --flake .#$host";
          updateNix = "cd /etc/nixos/NNC/; git pull ; rebuild ; sudo nix flake update --access-tokens github.com=$GITHUB_TOKEN ; flatpak update -y ; onUpdate ; cleanup; nix-store --optimise ; syncTodo";
          config = "ne /etc/nixos/NNC/modules";
          configSystem = "sudo -E -s nvim /etc/nixos/flake.nix";
          updateAllSubmodules = "git submodule update --init --recursive";
          ne = "neovide";
          rem_vim = "nix run --refresh github:FilipRuman/NNC?dir=nvf/selfcontained";
          sudoNvim = "sudo -E -s nvim";
          cleanup = "sudo nix-collect-garbage --delete-older-than 14d";
          cleanupAll = "sudo nix-collect-garbage -d";
          godot = "steam-run ~/Documents/godot/godot.x86_64";
          tauriRun = "sudo npm run tauri dev";
          espSetup = "nix --experimental-features 'nix-command flakes' develop github:mirrexagon/nixpkgs-esp-dev#esp-idf-full ; fish";
          espRun = "sudo -s -E idf.py --port /dev/ttyUSB0 flash monitor";
          notes = "ne ~/Nextcloud/Notes/";
        };
        interactiveShellInit = ''
          starship init fish | source
          starship preset bracketed-segments -o ~/.config/starship.toml
          starship preset nerd-font-symbols -o ~/.config/starship.toml

          zoxide init fish | source
          set -g fish_greeting ""
          clear
        '';
        functions = {
          y = {
            body = ''
              set tmp (mktemp -t "yazi-cwd.XXXXXX")
              yazi $argv --cwd-file="$tmp"
              if read -z cwd < "$tmp"; and [ -n "$cwd" ]; and [ "$cwd" != "$PWD" ]
                builtin cd -- "$cwd"
              end
              rm -f -- "$tmp"
            '';
          };

          # record.body = ''
          #   set ts (date +%F_%H-%M-%S)
          #
          #   pactl load-module module-combine-sink \
          #     sink_name=combined \
          #     slaves=alsa_output.pci-0000_15_00.6.analog-stereo
          #
          #   pactl load-module module-loopback \
          #     source=alsa_input.usb-MV-SILICON_fifine_Microphone_20190808-00.mono-fallback \
          #     sink=combined
          #
          #   sleep 1
          #
          #   wf-recorder --audio=combined.monitor -f "$HOME/Videos/recording_$ts.mp4"
          # '';
        };
        shellAbbrs = {

          rt = "recording_tool";
          rtp = "recording_tool proj";
          rtt = "recording_tool transcode";
          rnm = ''
            set cmd '<>';
            recording_tool manim-note "<>" "$cmd"
          '';
          fetch = "nix-shell -p fastfetch --run 'fastfetch'; nix-shell -p dysk --run 'dysk'; nixos-version ; sudo nix profile history --profile /nix/var/nix/profiles/system";
          ncdu = "nix-shell -p ncdu --run 'sudo ncdu /'";
          disk = "dysk; ncdu";
          dysk = "sudo nix run nixpkgs#dysk";
          a = "y /run/media/f/";
          vm = "~/vms/run.sh";
          nixCargo = "nix-shell --run 'cargo run'";
          token = "set -x GITHUB_TOKEN";
          iph = "mkdir /tmp/iphone && ifuse /tmp/iphone";
          record_audio = "
ffmpeg \
        -f pulse -i alsa_output.pci-0000_15_00.6.analog-stereo.monitor \
        -c:a flac \
        -compression_level 0 \
        output.flac
                                                ";
        };
      };

      starship.enable = true;
      zoxide.enable = true;
    };
  };
}
