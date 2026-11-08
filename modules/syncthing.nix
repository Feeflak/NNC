{
  flake.nixosModules.syncthing =
    {
      config,
      lib,
      ...
    }:
    let
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
              name = "photos";
            };
            folders.iphone = {
              path = "/home/f/sync/photos";
              label = "photos";
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
