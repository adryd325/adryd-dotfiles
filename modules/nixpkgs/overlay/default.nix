self: super: {  
  etsi-tetra-codec-sq5bpf = (super.callPackage ./etsi-tetra-codec-sq5bpf {});
  libosmocore-sq5bpf = (super.callPackage ./libosmocore-sq5bpf {});
  osmo-tetra-sq5bpf = (super.callPackage ./osmo-tetra-sq5bpf {});
  telive = (super.callPackage ./telive {});
  qdmr = (super.callPackage ./qdmr {});
}
