{
  config,
  pkgs,
  lib,
  ...
}: {
  options.host.audio = {
    name = lib.mkOption {
      default = "wireplumber";
      type = lib.types.enum ["wireplumber"];
      description = "Audio server to use";
    };

    cmd = {
      mute = lib.mkOption {
        type = lib.types.str;
        description = "Shell command for muting/unmuting audio.";
      };

      micMute = lib.mkOption {
        type = lib.types.str;
        description = "Shell command for muting/unmuting microphone.";
      };

      volumeUp = lib.mkOption {
        type = lib.types.str;
        description = "Shell command for increasing volume.";
      };

      volumeDown = lib.mkOption {
        type = lib.types.str;
        description = "Shell command for decreasing volume.";
      };

      play = lib.mkOption {
        type = lib.types.str;
        description = "Shell command for playing audio.";
      };

      pause = lib.mkOption {
        type = lib.types.str;
        description = "Shell command for pausing audio.";
      };

      next = lib.mkOption {
        type = lib.types.str;
        description = "Shell command for skipping to the next track.";
      };

      previous = lib.mkOption {
        type = lib.types.str;
        description = "Shell command for skipping to the previous track.";
      };

      playPause = lib.mkOption {
        type = lib.types.str;
        description = "Shell command for toggling play/pause.";
      };
    };
  };

  config = {
    services.playerctld = {
      enable = true;
    };

    home.packages = with pkgs; [
      playerctl
    ];

    # # Uh
    # assertions = [
    #   {
    #     assertion = config.services.pipewire.enabled;
    #     message = "Pipewire needs to be enabled for audio controls to work.";
    #   }
    # ];

    host.audio = {
      cmd = {
        mute = "${lib.getBin pkgs.wireplumber}/bin/wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle";
        micMute = "${lib.getBin pkgs.wireplumber}/bin/wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle";
        volumeUp = "${lib.getBin pkgs.wireplumber}/bin/wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%+";
        volumeDown = "${lib.getBin pkgs.wireplumber}/bin/wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-";

        play = "${lib.getExe pkgs.playerctl} play";
        pause = "${lib.getExe pkgs.playerctl} pause";
        next = "${lib.getExe pkgs.playerctl} next";
        previous = "${lib.getExe pkgs.playerctl} previous";
        playPause = "${lib.getExe pkgs.playerctl} play-pause";
      };
    };
  };
}
