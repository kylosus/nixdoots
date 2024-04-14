{hardware, lib, ...}: {
  hardware.nvidia.prime.offload.enable = lib.mkForce true;
  hardware.nvidia.forceFullCompositionPipeline = lib.mkForce true;
}
