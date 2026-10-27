self: super: {
  etsi-tetra-codec-sq5bpf = (super.callPackage ./etsi-tetra-codec-sq5bpf {});
  libosmocore-sq5bpf = (super.callPackage ./libosmocore-sq5bpf {});
  osmo-tetra-sq5bpf = (super.callPackage ./osmo-tetra-sq5bpf {});
  telive = (super.callPackage ./telive {});
  tetra-kit = (super.callPackage ./tetra-kit {});
  sdrplay = (super.callPackage ./sdrplay {});
  gr-sdrplay = (super.gnuradio3_7Packages.callPackage ./gr-sdrplay {});
  gr-sdrplay3 = (super.gnuradio3_9Packages.callPackage ./gr-sdrplay3 {});
  sdr-trunk = (super.callPackage ./sdr-trunk {});
}
