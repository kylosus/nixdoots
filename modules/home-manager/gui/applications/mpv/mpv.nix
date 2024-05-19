{
  pkgs,
  config,
  lib,
  ...
}: {
  imports = [
    ./input.nix
  ];

  programs.mpv = {
    enable = true;
    scripts = with pkgs.mpvScripts;
      [
        # mpv-discord
        mpv-webm
        # chapterskip
        # statusline
        quality-menu
      ]
      ++ [pkgs.mpv-discordRPC];

    # TODO: will this work?
    scriptOpts = {
      # chapterskip = "prologue;ending;preview";
    };

    # The real stuff
    ###Thanks,###
    ##https://iamscum.wordpress.com/guides/videoplayback-guide/mpv-conf/
    ##And years of changing random shit here and there##
    config = {
      ###General###
      #hwdec=nvdec-copy
      #hwdec=auto-copy
      #hwdec-codecs=all
      #profile=gpu-hq
      #gpu-api=vulkan
      #hwdec=no
      #vo=gpu
      #gpu-context=x11vk
      #spirv-compiler=shaderc

      ###GPU###
      profile = "high-quality";
      # https://github.com/mpv-player/mpv/wiki/GPU-Next-vs-GPU
      vo = "gpu-next";
      #gpu-api=vulkan
      #hwdec=no

      # Fixes some things
      ao = "pulse";

      ###Misc###
      #save-position-on-quit=yes
      cache = true;
      demuxer-max-bytes = "2GiB";
      demuxer-readahead-secs = "1800";

      ###Tweaks###
      cursor-autohide = "100";
      keep-open = "no";

      ###Priority###
      slang = "en,eng";
      alang = "ja,jp,jpn";

      ###Audio###
      volume-max = 100;
      audio-file-auto = "fuzzy";
      audio-exclusive = "yes";
      #audio-delay=+0.084 # For TV
      # af="acompressor=ratio=4,lournorm"

      ###Subs###
      demuxer-mkv-subtitle-preroll = "yes";
      sub-ass-vsfilter-blur-compat = "no";
      # Don't select subs with the same language as the audio
      subs-with-matching-audio = "no";
      sub-fix-timing = "yes";
      sub-auto = "fuzzy";

      # Yellow subs stuff
      #sub-gauss=0.6
      #sub-gray=yes

      # Sub overrides for the default Arial for .srt subtitles (or .ass if you force it)
      #sub-font=Andika New Basic Bold
      #sub-font=FOT-Greco Std
      sub-font-size = 52;
      sub-blur = 0.2;
      sub-border-color = "0.0/0.0/0.0/1.0";
      sub-border-size = "3.0";
      sub-color = "1.0/1.0/1.0/1.0";
      sub-margin-x = 100;
      sub-margin-y = 50;
      sub-shadow-color = "0.0/0.0/0.0/0.25";
      sub-shadow-offset = 0;
      # sub-ass-override = "force";

      ###Screenshot###
      screenshot-format = "png";
      screenshot-high-bit-depth = "yes";
      screenshot-png-compression = "1";
      screenshot-jpeg-quality = "100";
      screenshot-directory = "${config.xdg.userDirs.pictures}/mpv/";
      screenshot-template = "%f-%wH.%wM.%wS.%wT-#%#00n";

      ###Dither###
      dither-depth = "auto";
      dither = "fruit";
      #dither=error-diffusion # Experimental; for high-end GPU's
      error-diffusion = "sierra-lite"; # Fast/decent results

      ###Deband###
      # This shit broke
      deband = "yes";
      deband-iterations = "4";
      deband-threshold = "50";
      deband-range = "24";
      #Dynamic Grain (More = More dynamic grain)
      #Set it to "0" in case you prefer the static grain shader or don't like grain
      deband-grain = "16";

      ###Grain & Resizer###
      # Luma
      #glsl-shader="~/.config/mpv/shaders/noise_static_luma.hook"

      # Chroma
      #glsl-shader="~/.config/mpv/shaders/noise_static_chroma.hook"

      # Ravu
      #glsl-shader="~/.config/mpv/shaders/ravu-r4.hook"
      # glsl-shader="~/.config/mpv/shaders/ravu-r4.hook"

      ###Resizer###
      #scale=ewa_lanczossharp
      #dscale=mitchell
      #cscale=sinc
      #cscale-window=blackman
      #cscale-radius=3

      scale = "ewa_lanczossharp";
      #cscale=ewa_lanczossharp
      # scale-blur="0.981251";

      ###Playlist###
      prefetch-playlist = "yes";

      ###Interpolation###
      #blend-subtitles=yes
      #video-sync=display-resample
      #interpolation=yes
      #tscale=box
      #tscale-window=sphinx
      #tscale-radius=1.0
      #tscale-clamp=0.0

      #deinterlance=auto
    };
  };
}
