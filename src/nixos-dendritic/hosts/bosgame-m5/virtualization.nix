# Virtualisation settings for bosgame-m5
# Split into two concerns:
#   • VM *guest* settings  — only active when you run `nixos-rebuild build-vm`
#   • KVM *host* settings  — improve the real machine as a hypervisor
{...}: {
  flake.modules.nixos.clj-host-bosgame-m5-virtualization = {lib, ...}: {
    # ── VM guest overrides (nixos-rebuild build-vm) ────────────────────────
    virtualisation.vmVariant = {
      users.users.lijun = {
        hashedPassword = lib.mkForce null;
        password = "test";
      };
      home-manager.users.lijun.clj.dotfiles.editable = lib.mkForce false;
      # Kanata runs on the host; disable it in the guest to avoid double-mapping
      # of key events (which is why shortcuts feel unresponsive in the VM).
      clj.kanata.enable = false;

      # QEMU memory / CPU.
      # -m N is a *maximum*, not a hard reservation. QEMU allocates physical
      # pages lazily, so the host does not lose this RAM at VM start. The
      # virtio-balloon device (included by default) can reclaim guest pages
      # when the host is under pressure.
      virtualisation.memorySize = lib.mkDefault 16384; # 16GiB
      virtualisation.cores = lib.mkDefault 16;

      # Root disk size (default is only 1 GB).
      virtualisation.diskSize = lib.mkDefault 131072; # 128 GiB

      # 9P packet size for the /nix/store virtfs mount.
      # Default is 16 KiB; raising to 128 KiB significantly reduces RTTs and
      # speeds up app launches (which stat/open many files from /nix/store).
      virtualisation.msize = 131072;

      # GPU acceleration via VirGL + Venus (Vulkan command stream passthrough).
      #
      # virtio-vga-gl       – VGA-compatible paravirtual GPU with virglrenderer.
      #                       "vga" variant acts as the primary display device
      #                       (no separate -vga flag needed).
      # blob=on             – enables blob resource sharing (guest ↔ host memfd/
      #                       DMA-buf), zero-copy on the render critical path.
      # hostmem=4G          – host memory pool for blob resources (GPU textures,
      #                       framebuffers, etc.). Required when blob=on or venus=on.
      # venus=on            – Vulkan native protocol: the guest Mesa Venus driver
      #                       passes raw Vulkan command streams to the host instead
      #                       of translating them through OpenGL. This is closer in
      #                       spirit to DRM native context (lower-level than VirGL
      #                       OpenGL translation) and works with the current QEMU.
      #                       NOTE: True DRM native context (drm_native_context=on)
      #                       is an even lower-level approach that passes raw DRM/KMS
      #                       commands through the host kernel driver. It requires
      #                       QEMU patches from the Dmitry Osipenko patchset (v12,
      #                       May 2025 on qemu-devel) which are not yet in QEMU
      #                       10.2.x. When those patches land in nixpkgs-unstable,
      #                       switch to:
      #                         -device virtio-vga-gl,blob=on,hostmem=4G,drm_native_context=on
      #
      # -machine type=q35   – PCIe-based machine (vs the QEMU default "pc"/i440fx).
      #                       NixOS's qemuBinary hardcodes -machine accel=kvm:tcg;
      #                       QEMU merges multiple -machine flags, so adding
      #                       type=q35 here promotes the bus to PCIe. VirtIO
      #                       devices get PCIe MSI/MSI-X which lowers interrupt
      #                       latency for the GPU and network.
      #
      # -display gtk,gl=on  – host GTK window with EGL/GL, required for virglrenderer.
      # grab-on-hover=on    – keyboard & mouse are grabbed automatically when the
      #                       cursor enters the VM window.
      #                       Press Ctrl+Alt+G to release the grab.
      #                       Press F11 to toggle full-screen (recommended: put the
      #                       VM on a dedicated KDE virtual desktop and run it
      #                       full-screen for the most natural experience).
      #
      virtualisation.qemu.options = [
        "-machine type=q35"
        "-device virtio-vga-gl,blob=on,hostmem=4G,venus=on"
        "-display gtk,gl=on,grab-on-hover=on"
      ];

      # Load the virtio-gpu kernel driver during early boot so the display is
      # available from the first console frame.
      boot.initrd.kernelModules = ["virtio_gpu"];
    };

    # ── KVM host optimisations (real machine) ─────────────────────────────

    # KSM: kernel same-page merging — the host kernel periodically scans and
    # merges identical RAM pages across processes and VMs. Especially effective
    # when host and guest both run NixOS (shared store pages).
    hardware.ksm.enable = true;

    # Nested virtualisation: allows KVM to run inside the VM guest (useful for
    # testing NixOS VMs inside this VM).
    boot.extraModprobeConfig = "options kvm_amd nested=1";

    # libvirt + QEMU for managing VMs via virt-manager / virsh.
    # swtpm provides a virtual TPM (needed for Windows 11, etc.).
    # UEFI/OVMF firmware is now bundled with QEMU automatically.
    virtualisation.libvirtd = {
      enable = true;
      qemu.swtpm.enable = true;
    };

    # SPICE USB redirection: pass USB devices from host into VMs.
    virtualisation.spiceUSBRedirection.enable = true;
  };
}
