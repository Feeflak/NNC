{
  flake.nixosModules.syncthing = { config, lib, pkgs, ... }:
    let
      cfg = config.services.syncthing;
      userGroup = config.users.users.f.group;
      deviceId = config.custom.secrets.values.SYNCTHING_IPHONE_ID;
    in
    {
      config = {
        services.syncthing = {
          enable = true;
          user = "f";
          group = userGroup;
          dataDir = "/home/f/.local/share/syncthing";
          configDir = "/home/f/.config/syncthing";
          openDefaultPorts = true;

          settings = lib.mkIf (deviceId != "") {
            devices.iphone = {
              id = deviceId;
              name = "iphone";
            };
            folders.iphone = {
              path = "/home/f/iphone";
              label = "iPhone";
              devices = [ "iphone" ];
            };
          };
        };

        custom.secrets.required = [ "SYNCTHING_IPHONE_ID" ];

        systemd.tmpfiles.rules = [
          "d /home/f/iphone 0755 f ${userGroup} -"
        ];
      };
    };
}
