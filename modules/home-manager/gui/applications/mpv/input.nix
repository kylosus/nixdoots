{
  lib,
  pkgs,
  ...
}: {
  home.packages = with pkgs; [anime4k];

  programs.mpv.bindings = let
    command = "no-osd change-list glsl-shaders set";
    shaderPath = lib.getBin pkgs.anime4k;
    mkShaders = names: lib.concatStringsSep ":" (map (x: shaderPath + "/" + x) names);

    fast_a = mkShaders [
      "Anime4K_Clamp_Highlights.glsl"
      "Anime4K_Restore_CNN_M.glsl"
      "Anime4K_Upscale_CNN_x2_M.glsl"
      "Anime4K_AutoDownscalePre_x2.glsl"
      "Anime4K_AutoDownscalePre_x4.glsl"
      "Anime4K_Upscale_CNN_x2_S.glsl"
    ];

    fast_b = mkShaders [
      "Anime4K_Clamp_Highlights.glsl"
      "Anime4K_Restore_CNN_Soft_M.glsl"
      "Anime4K_Upscale_CNN_x2_M.glsl"
      "Anime4K_AutoDownscalePre_x2.glsl"
      "Anime4K_AutoDownscalePre_x4.glsl"
      "Anime4K_Upscale_CNN_x2_S.glsl"
    ];

    fast_c = mkShaders [
      "Anime4K_Clamp_Highlights.glsl"
      "Anime4K_Upscale_Denoise_CNN_x2_M.glsl"
      "Anime4K_AutoDownscalePre_x2.glsl"
      "Anime4K_AutoDownscalePre_x4.glsl"
      "Anime4K_Upscale_CNN_x2_S.glsl"
    ];

    fast_aa = mkShaders [
      "Anime4K_Clamp_Highlights.glsl"
      "Anime4K_Restore_CNN_M.glsl"
      "Anime4K_Upscale_CNN_x2_M.glsl"
      "Anime4K_Restore_CNN_S.glsl"
      "Anime4K_AutoDownscalePre_x2.glsl"
      "Anime4K_AutoDownscalePre_x4.glsl"
      "Anime4K_Upscale_CNN_x2_S.glsl"
    ];

    fast_bb = mkShaders [
      "Anime4K_Clamp_Highlights.glsl"
      "Anime4K_Restore_CNN_Soft_M.glsl"
      "Anime4K_Upscale_CNN_x2_M.glsl"
      "Anime4K_AutoDownscalePre_x2.glsl"
      "Anime4K_AutoDownscalePre_x4.glsl"
      "Anime4K_Restore_CNN_Soft_S.glsl"
      "Anime4K_Upscale_CNN_x2_S.glsl"
    ];

    fast_ca = mkShaders [
      "Anime4K_Clamp_Highlights.glsl"
      "Anime4K_Upscale_Denoise_CNN_x2_M.glsl"
      "Anime4K_AutoDownscalePre_x2.glsl"
      "Anime4K_AutoDownscalePre_x4.glsl"
      "Anime4K_Restore_CNN_S.glsl"
      "Anime4K_Upscale_CNN_x2_S.glsl"
    ];
  in {
    "CTRL+1" = ''${command} "${fast_a}"; show-text "Anime4K: Mode A (Fast)"'';
    "CTRL+2" = ''${command} "${fast_b}"; show-text "Anime4K: Mode B (Fast)"'';
    "CTRL+3" = ''${command} "${fast_c}"; show-text "Anime4K: Mode C (Fast)"'';
    "CTRL+4" = ''${command} "${fast_aa}"; show-text "Anime4K: Mode A+A (Fast)"'';
    "CTRL+5" = ''${command} "${fast_bb}"; show-text "Anime4K: Mode B+B (Fast)"'';
    "CTRL+6" = ''${command} "${fast_ca}"; show-text "Anime4K: Mode C+A (Fast)"'';
    "CTRL+0" = ''no-osd change-list glsl-shaders clr ""; show-text "GLSL shaders cleared"'';
  };
}
