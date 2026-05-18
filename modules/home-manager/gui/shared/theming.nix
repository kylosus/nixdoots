{
  config,
  params,
  pkgs,
  lib,
  ...
}: let
  dunstrcText = ''
    [global]
      follow = keyboard
      font = monospace 10
      format = "<b>%s</b>\n%b"
      frame_width = 2
      geometry = "500x50-15+15"
      hide_duplicates_count = yes
      horizontal_padding = 6
      icon_position = left
      idle_threshold = 0
      ignore_newline = no
      line_height = 3
      markup = yes
      max_icon_size = 80
      padding = 6
      plain_text = no
      separator_color = frame
      separator_height = 2
      shrink = no
      stack_duplicates = yes
      word_wrap = yes
      frame_color = "{color1}"

    [urgency_low]
      background = "{background}"
      foreground = "{foreground}"
      frame_color = "{color8}"

    [urgency_normal]
      background = "{background}"
      foreground = "{foreground}"
      frame_color = "{color1}"

    [urgency_critical]
      background = "{color1}"
      foreground = "{foreground}"
      frame_color = "{color3}"
  '';

  makoConfigText = ''
    font=monospace 10
    width=500
    height=110
    margin=15
    padding=6
    border-size=2
    border-radius=0
    icons=1
    max-icon-size=80
    anchor=top-right
    default-timeout=5000

    background-color={background}
    text-color={foreground}
    border-color={color1}
    progress-color=over {color2}

    [urgency=low]
    border-color={color8}

    [urgency=normal]
    border-color={color1}

    [urgency=critical]
    background-color={color1}
    text-color={foreground}
    border-color={color3}
  '';

  # Daemons launched with explicit -conf/--config paths into ~/.cache/wal don't
  # auto-reload when the rendered files change
  postWalScript = ''
    #!/bin/sh
    ${pkgs.systemd}/bin/systemctl --user --no-block try-restart dunst.service polybar.service 2>/dev/null || true

    ${pkgs.systemd}/bin/systemctl --user --no-block try-restart mako.service waybar.service 2>/dev/null || true

    if command -v hyprctl >/dev/null 2>&1; then
      hyprctl reload 2>/dev/null || true
    fi

    exit 0
  '';

  # Any change to template/hook content invalidates this hash, which flips
  # the unit Description and makes sd-switch restart pywal on hm switch.
  templatesHash = builtins.hashString "sha256" (dunstrcText + makoConfigText + postWalScript);
in {
  programs.pywal = {
    enable = true;
    package = pkgs.pywal16;
  };

  home.file = {
    # dunst -conf <path>
    ".config/wal/templates/dunstrc".text = dunstrcText;

    # mako --config <path>
    ".config/wal/templates/mako-config".text = makoConfigText;

    # Post-wal hook to signal daemons to reload on palette change
    # TODO: there should be a better way...
    ".config/wal/hooks/post-wal.sh" = {
      executable = true;
      text = postWalScript;
    };
  };

  # Template hash to force reload on home-manager switch
  systemd.user.services.pywal = {
    Unit = {
      Description = "pywal: render wallpaper palette and deploy theming [templates:${templatesHash}]";
      PartOf = ["${config.host.session.target}"];
      After = ["${config.host.session.target}"];
    };
    Service = {
      Type = "oneshot";
      ExecStart = "${config.programs.pywal.package}/bin/wal -a 90 -i ${params.wallpaper}";
      ExecStartPost = "${config.xdg.configHome}/wal/hooks/post-wal.sh";
      RemainAfterExit = true;
    };
    Install.WantedBy = ["${config.host.session.target}"];
  };
}
