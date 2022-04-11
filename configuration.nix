# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, inputs, ... }:
with pkgs;
let
  system = "x86_64-linux";
  # R-with-my-packages = rWrapper.override{ packages = with rPackages; [ ggplot2 dplyr xts ]; };
  RStudio-with-my-packages = rstudioWrapper.override{ packages = with rPackages; [ ggplot2 dplyr xts ]; };
in
{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
    ];

  nix = {
    package = pkgs.nix_2_4; # Potential attributes are nix_2_4 nixFlakes nixUnstable
    extraOptions = ''
      experimental-features = nix-command flakes
    '';
  };

  nixpkgs.config = {
    packageOverrides = pkgs: {
	    release2105 = import inputs.release2105 {
        config = config.nixpkgs.config;
        inherit system;
      };
      unstable = import inputs.unstable {
        config = config.nixpkgs.config;
        inherit system;
      };
      # unstable = import <nixos-unstable> {
      #   config = config.nixpkgs.config;
      # };
      # steam = pkgs.steam.override {
      #   nativeOnly = true;
      # };
    };
  };

  # Storage optimization.
  nix.autoOptimiseStore = true;

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # Enable NTFS-3G support
  boot.supportedFilesystems = [ "ntfs" ];

  # networking.hostName = "nixos"; # Define your hostname.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

  # Set user.
   users.users.ryan = {
     createHome = true;
     isNormalUser = true;
     extraGroups =
       [
         "wheel" "libvirtd" "qemu-libvirtd"
         "audio" "video" "networkmanager"
         "vglusers"
       ];
     group = "users";
     home = "/home/ryan";
     uid = 1000;
   };
  # "lxd"

  # Set your time zone.
  time.timeZone = "Asia/Colombo";

  # Disable automatic refresh of ClamAV signatures database (do this manually).
  services.clamav = {
     daemon.enable = false;
    updater.enable = false;
  };

  # Comm utils
  services.teamviewer.enable = false;

  # Enable virtualization.
  virtualisation.libvirtd.enable = true;
  boot.extraModprobeConfig = "options kvm_amd nested=1"; # Nested virtualization (requires AMD-V).
#   virtualisation.lxd.enable = true;
  virtualisation.docker.enable = true;
  virtualisation.docker.enableNvidia = true;
  # boot.kernelModules = [ "kvm-amd" "kvm-intel" ]; # Only needed if kvm-amd/intel is not set in hardware-configuration.nix AFAIK.

  # Allow proprietary packages
  nixpkgs.config.allowUnfree = true; # Had to export bash env var for flakes since this didn't work
#   inputs.release2105.config.allowUnfree = true;

  # The global useDHCP flag is deprecated, therefore explicitly set to false here.
  # Per-interface useDHCP will be mandatory in the future, so this generated config
  # replicates the default behaviour.
  networking.useDHCP = false;
  networking.interfaces.enp34s0.useDHCP = true;
  networking.interfaces.wlp3s0f0u8.useDHCP = true;

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Wi-Fi
  # networking.wireless.iwd.enable = true;
  networking.networkmanager = {
    # wifi.backend = "iwd";
    enable = true;
  };
  programs.nm-applet.enable = true;
  # programs.light.enable = true;
  programs.steam.enable = true;
  
  # programs.volctl.enable = true; # Invalid
  # networking.networkmanager.wifi.backend = "iwd";
  # networking.networkmanager.enable = true;

  # Select internationalisation properties.
  # i18n.defaultLocale = "en_US.UTF-8";
  # console = {
  #   font = "Lat2-Terminus16";
  #   keyMap = "us";
  # };

  # Enable the X11 windowing system.
  services.xserver.enable = true;

  # Enable X11 forwarding.
  # Enable the OpenSSH daemon.
  # programs.ssh.setXAuthLocation = true;
  services.openssh.enable = true;
  services.openssh.forwardX11 = true;
  # services.openssh.startWhenNeeded = true;
  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ 631 5901 80 443 ];

  # Enable NVIDIA drivers
  services.xserver.videoDrivers = [ "nvidia" ];
  hardware.opengl = {
    enable = true;
    extraPackages = with pkgs; [
       libGL
    ];
    setLdLibraryPath = true;
  };
  hardware.opengl.driSupport32Bit = true;
  # hardware.opengl.setLdLibraryPath = true;

  # Enable the Plasma 5 Desktop Environment.
  # services.xserver.displayManager.sddm.enable = true;
  # services.xserver.desktopManager.plasma5.enable = true;
  # Enable dwm
  services.xserver.windowManager.dwm.enable = true;
  services.gvfs = {
    enable = true;
    package = lib.mkForce pkgs.gnome3.gvfs;
  };

  # Misc services
  # services = {
    # fstrim.enable = true; # SSD only
    # openssh.enable = true; # Redundant
    # xserver.enable = true; # Redundant
    # compton.enable = true; # Consider picom instead
    # compton.shadow = true;
    # compton.inactiveOpacity = "0.8";
    # printing.enable = true; # Not needed
  # };

  # Enabke Iorri nix-shell extension daemon,
  # services.lorri.enable = true; # Make sure to run 'systemctl --user daemon-reload' or 'reboot' after this!

  # Configure keymap in X11
  # services.xserver.layout = "us";
  # services.xserver.xkbOptions = "eurosign:e";

  # Enable CUPS to print documents.
  # services.printing.enable = true;

  # Enable sound.
  sound.enable = true;
  hardware.pulseaudio.package = pkgs.pulseaudioFull;
  hardware.pulseaudio.enable = true;
  # hardware.pulseaudio.support32Bit = true;
  nixpkgs.config.pulseaudio = true;

  # Paprefs fix.
  programs.dconf.enable = true; # + gnome3.dconf

  # Enable touchpad support (enabled default in most desktopManager).
  # services.xserver.libinput.enable = true;

  # Define a user account. Don't forget to set a password with ‘passwd’.
  # users.users.jane = {
  #   isNormalUser = true;
  #   extraGroups = [ "wheel" ]; # Enable ‘sudo’ for the user.
  # };

  # Overlay setup
  services.emacs.package = pkgs.emacsGcc;
  # services.emacs.enable = true; # Optional emacs daemon/server mode.

  # Overlay configuration
  nixpkgs.overlays = [
    (import (builtins.fetchGit {
      url = "https://github.com/nix-community/emacs-overlay.git";
      ref = "master";
      rev = "13bd8f5d68519898e403d3cab231281b1fbd0d71"; # change the revision as needed
     }))

    # Wine
    (self: super: {
      wine = super.wineWowPackages.stableFull;
    })
  
    # dwm
    (self: super: {
      dwm = super.dwm.overrideAttrs (oa: rec {
        patches = [
          # (builtins.fetchurl https://example.com/patch2.patch)
          # ./path/to/my-dwm-patch.patch
          (super.fetchpatch {
            # url = "https://dwm.suckless.org/patches/systray/dwm-systray-6.3.diff";
            # sha256 = "1plzfi5l8zwgr8zfjmzilpv43n248n4178j98qdbwpgb4r793mdj";
            # url = "https://dwm.suckless.org/patches/systray/dwm-systray-6.0.diff";
            # sha256 = "1k95j0c9gzz15k0v307zlvkk3fbayb9kid68i27idawg2salrz54";
           url = "https://dwm.suckless.org/patches/systray/dwm-systray-6.2.diff";
           sha256 = "19m7s7wfqvw09z9zb3q9480n42xcsqjrxpkvqmmrw1z96d2nn3nn"; 
          })
          (super.fetchpatch {
           url = "https://dwm.suckless.org/patches/swaptags/dwm-swaptags-6.2.diff";
           sha256 = "11f9c582a3xm6c7z4k7zmflisljmqbcihnzfkiz9r65m4089kv0g"; 
          })   
        ];
        # configFile = super.writeText "config.h" (builtins.readFile ./dwm-config.h);
        # postPatch = oa.postPatch or "" + "\necho 'Using own config file...'\n cp ${configFile} config.def.h";
      });
      st = super.st.overrideAttrs (oa: rec {
        # ligatures dependency
        # buildInputs = oa.buildInputs ++ [ harfbuzz ];
        patches = [
          # ./path/to/my-dwm-patch.patch
          # ligatures patch
          # (fetchpatch {
          #   url = "https://st.suckless.org/patches/ligatures/0.8.3/st-ligatures-20200430-0.8.3.diff";
          #   sha256 = "67b668c77677bfcaff42031e2656ce9cf173275e1dfd6f72587e8e8726298f09";
          # })
        ];
        # configFile = super.writeText "config.h" (builtins.readFile ./st-config.h);
        # postPatch = "${oa.postPatch}\ncp ${configFile} config.def.h\n";
      });
    })
  ];

  fonts.fonts = with pkgs; [
    source-code-pro
  ];

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  # Do not forget to add an editor to edit configuration.nix! The Nano editor is also installed by default.
  environment.systemPackages = with pkgs; [
    vim wget firefox kate httrack silver-searcher btop postgresql_14 postgresql14Packages.postgis postgresql14Packages.timescaledb ccache fd ripgrep ripgrep-all git docker yt-dlp obs-studio gron go-org groff direnv elinks fbida texmacs ghostwriter ffmpeg paprefs gnome3.dconf gparted unetbootin audacity emscripten wasmer nvidia-docker pyspread inkscape neovim calibre root sageWithDoc nyxt nomacs maim yacreader tigervnc aria ghostscript nix-du zgrviewer graphviz google-chrome tor-browser-bundle-bin

    # Package packs
    RStudio-with-my-packages

    # Flakes
    inputs.blender.packages.x86_64-linux.blender_3_1
    inputs.poetry2nix.packages.x86_64-linux.poetry2nix
	  release2105.dos2unix
	  # release2105.google-chrome

    # Security
    clamav

    # Editors
    apostrophe # Markdown

    # Web Dev
    unstable.deno
    unstable.flyctl
    # go_1_17
    unstable.go_1_18
    sass
    ungoogled-chromium

    #Sys Dev
    nixos-option

    # VPS
    mosh

    # Weird stuff
    eaglemode
    lagrange

    # Compiler tooling
    smlnj

    # Spellcheck
    aspell
    hunspell hunspellDicts.en_US

    # Virtualisation
    libguestfs
    virt-manager
    vagrant
    # unstable.lxd
    x11docker
    xorg.xdpyinfo
    xclip

    # Xorg tools
    xorg.xmessage

    # Steam tools
    protontricks

    # Programming utils
    bintools-unwrapped # Tools for manipulating binaries (linker, assembler, etc.)

    # SDKs
    #cudnn_cudatoolkit_11_2 # NVIDIA CUDA Deep Neural Network library (CUDA 11.2 + cuDNN 8.1.1 for TensorFlow 2.7.0 compat)
    git-lfs # Git extension for versioning large files
    gcc # GNU Compiler Collection, version 10.3.0 (wrapper script)
    gnumake # A tool to control the generation of non-source files from sources
    mdk # GNU MIX Development Kit (MDK)
    racket # A programmable programming language
    mozart2 # An open source implementation of Oz 3
    chicken # A portable compiler for the Scheme programming language
    renpy # Ren'Py Visual Novel Engine
    nwjs-sdk # An app runtime based on Chromium and node.js

    # Source code explorer & deps
    # tomcat10 opengrok
    universal-ctags
    hound # Lightning fast code searching made easy

    # SDL2 SDK
    SDL2 # SDL2_ttf SDL2_net SDL2_gfx SDL2_mixer SDL2_image smpeg2 guile-sdl2

    # Games
    vkquake

    # Desktop environment utils
    xfce.thunar
    xfce.thunar-volman
    polkit_gnome
    pavucontrol
    dmenu
    feh
    tmux
    volctl
    okular
    konsole
    guake
    picom
    gnome.zenity
    # xpra # Buggy
    virtualgl
    autokey
    xautomation
    xdotool
    libnotify
    dunst

    # Emacs deps
    libtool
    libvterm-neovim
    texlive.combined.scheme-full	

    # Sys utils
    st
    xterm
    # yaft # Buggy
    mlterm
    imagemagick
    lsix
    flex
    bison
    tree
    p7zip
    parallel
    desktop-file-utils # Command line utilities for working with .desktop files
    xdg-utils # A set of command line tools that assist applications with a variety of desktop integration tasks
    nethogs # A small 'net top' tool, grouping bandwidth by process
    file # A program that shows the type of files
    grub2_efi # Bootloader (not activated)
    exfatprogs # GParted exFAT support
    gptfdisk # Set of partitioning tools for GPT disks
    pciutils # Provides lspci
    k4dirstat # Sums up disk usage for directory trees
    aria # Download manager
    qbittorrent # Torrent manager
    xorriso # ISO file editor (reasons for using this over cdrkit/cdrtools: https://wiki.osdev.org/Mkisofs)
    cdrtools # Provides mkisofs
    syslinux # Provides isohybrid which should NOT be used with ISOs that have been pre-treated with it like the Ubuntu ISOs
    libsForQt5.kalarm # KDE alarm
    ifmetric # Networking
    lshw # Hardware config intro
    hwinfo # Hardware detection tool from openSUSE
    bat # A cat(1) clone with syntax highlighting and Git integration
    zip # Compressor/archiver for creating and modifying zipfiles
    unrar
    
    # DB utils
    dbeaver # Universal SQL Client for developers, DBA and analysts. Supports MySQL, PostgreSQL, MariaDB, SQLite, and more.

    # KDE utils
    libsForQt5.ark # Archive manager
    calligra # Office stuff

    # Media players
    vlc # Video
    lightspark # Flash

    # Media fetcher
    hakuneko

    # Misc file utils & other deps for a certain game.
    # unzip xdelta cabextract
    # mangohud vkBasalt gamemode
    # switcheroo-control # Only needed for dual GPU setups.

    # Kernel headers
    linuxHeaders

    # Android MTP
    jmtpfs

    # Java
    #jdk
    #oraclejdk8
    adoptopenjdk-hotspot-bin-16
    
    # Python 3
    (let
      my-python-packages = python-packages: with python-packages; [
        requests
        psycopg2
        #tensorflowWithCuda
        flask flask_wtf flask_mail flask_login flask_assets flask-sslify flask-silk flask-restx flask-openid flask-cors flask-common flask-bcrypt flask-babel flask-api flask-admin flask_sqlalchemy flask_migrate
        fire
        typer
        pytest
        poetry
        poetry2conda
        nixpkgs-pytools
        rope
        inkex
        pyzmq
        # Sci-Comp Tools
        jupyterlab pytorch scikit-learn numba jax jaxlib transformers tokenizers fasttext numpy scipy sympy matplotlib pandas scikitimage statsmodels scikits-odes traittypes xarray
        pip
        pyside2
        pyside2-tools
        shiboken2
        virtualenv
        virtualenvwrapper
        pillow
        virtual-display
        EasyProcess
        # Web-Dev Tools
        fastapi sqlalchemy sqlalchemy-utils sqlalchemy-migrate sqlalchemy-jsonfield sqlalchemy-i18n sqlalchemy-citext alembic ColanderAlchemy
        # General tools
        pipx
      ];
      python-with-my-packages = python39.withPackages my-python-packages;
    in
    python-with-my-packages)

    # (let 
    #   my-python2-packages = python2-packages: with python2-packages; [ 
    #     requests
    #     pygame_sdl2
    #   ];
    #   python2-with-my-packages = python27.withPackages my-python2-packages;
    # in
    # python2-with-my-packages)

    # ML Tools
    fasttext
    libtorch-bin

    # Conda
    conda

    # Rust
    rustup
    cargo-generate
    watchexec
    cargo-watch
    crate2nix
    wasm-pack

    # C++
    cppzmq
    uncrustify
    cmake
    ninja
    conan

    # Vulkan
    vulkan-tools
    glslang
    glm
    vulkan-tools-lunarg
    vulkan-loader
    vulkan-headers
    vulkan-validation-layers
    spirv-tools
    spirv-cross
    spirv-headers
    spirv-llvm-translator
    mangohud

    # Coq
    coq
    coqPackages.mathcomp

    # GIMP
    gimp
    gimpPlugins.gap

    # Octave
    (let
      my-octave-packages = octave-packages: with octave-packages; [
        general
        symbolic
      ];
      octave-with-my-packages = octave.withPackages my-octave-packages;
    in
    octave-with-my-packages)

    # Node
    nodejs-16_x
    nodePackages.pnpm
    nodePackages.node-gyp
    nodePackages.node-gyp-build

    # VS Code
    vscode-fhs

    # (vscode-with-extensions.override {
    #   # When the extension is already available in the default extensions set.
    #   vscodeExtensions = with vscode-extensions; [
    #     vscodevim.vim
    #     chenglou92.rescript-vscode
    #     ms-vscode.cpptools
    #     ms-python.python
    #     vscode-extensions.jnoortheen.nix-ide
    #     vscode-extensions.arrterian.nix-env-selector
    #     vscode-extensions.asvetliakov.vscode-neovim
    #   ]
    #   # Concise version from the vscode market place when not available in the default set.
    #   ++ vscode-utils.extensionsFromVscodeMarketplace [
    #     {
    #       name = "typescript-notebook";
    #       publisher = "donjayamanne";
    #       version = "2.0.6";
    #       #rev = "d3c419b635ba2c88179cef3ebf0ecf58563f2410"; # The usual way to get this seems to be putting a random string here ("0000000000000000000000000000000000000000000000000000") and let nix complain about it, and it will tell you the actual computed value.
    #       sha256 = "0zmm5im77mr6qj1qkp60jr7nxwbjkd9g6xf3xa41jsi5gmf8a1cz";
    #     }
    #   ];
    # })

    # TBI
    # pgadmin # openssl issue here (good chance to test sed & awk).
    # discord / betterdiscordctl
    # element-desktop
    # kaldi

    # Same trick as Python for these packages (anything that has a 'Full' version should work similarly)!
    # vscode-with-extensions

    # Overlays
    emacsGcc
    wine
  ];

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  # services.openssh.enable = true;

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "21.11"; # Did you read the comment?
}
