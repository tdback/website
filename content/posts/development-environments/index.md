+++
title = 'Development Environments With Emacs, Nix, and Direnv'
description = 'The last development environment you will ever need.'
date = '2025-02-09T19:59:55-05:00'
draft = false
+++

Recently I decided to fire up Emacs, [declare bankruptcy](https://www.emacswiki.org/emacs/DotEmacsBankruptcy) on my old config, and [rewrite it again from scratch](https://github.com/tdback/emacs.d). I thought I would share how I use Emacs alongside Nix to create seamless, reproducible development environments for hacking on projects.

# Setting Things Up
The secret sauce here is [direnv](https://direnv.net/). `direnv` allows us to load and unload environment variables depending on the current directory. When paired with Nix, we can automatically handle the environment variables for per-project dependencies specified in our `flake.nix` or `shell.nix` files.

Setting up `direnv` integration with Nix and Emacs is straightforward. Let's write some code!

## Home Manager
The easiest way to setup `direnv` in Nix is via its module in [Home Manager](https://github.com/nix-community/home-manager).

We'll enable [nix-direnv](https://github.com/nix-community/nix-direnv) in our configuration to replace `direnv`'s  builtin implementation of `use_nix` and `use_flake`. Unlike the builtin implementation, `nix-direnv` can cache our Nix environment and prevent Nix's garbage collector from cleaning up our build dependencies.

Adding the following to your home-manager configuration will get `nix-direnv` up and running in your user environment:
```nix
# Allow home-manager to manage our shell.
programs.bash.enable = true;

programs.direnv = {
  enable = true;
  enableBashIntegration = true;
  nix-direnv.enable = true;
};
```

If you use a shell other than `bash`, you can check the current [Home Manager options](https://home-manager-options.extranix.com/?query=programs.direnv.enable&release=release-24.11) for integrating with your shell of choice.

## Emacs
[emacs-direnv](https://github.com/wbolster/emacs-direnv) is a package that provides `direnv` integration for Emacs. It can be installed from [MELPA](https://melpa.org/#/direnv) with `use-package`. We'll enable the global minor mode to automatically update the Emacs environment when the active buffer changes:
```elisp
(use-package direnv
  :ensure t
  :config
  (direnv-mode))
```

Alternatively, we can install it manually:
```
M-x package-install RET direnv RET
```

And enable the global minor mode on startup in `~/.emacs.d/init.el`:
```elisp
(direnv-mode)
```

# An Example Project
Let's create a new project that will setup a development environment for working with Rust. In our example `flake.nix` file, we'll include an overlay to pull in the latest stable Rust toolchain and `rust-analyzer` for LSP support in Emacs:
```nix
{
  inputs.nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
  inputs.rust-overlay.url = "github:oxalica/rust-overlay";

  outputs =
    {
      nixpkgs,
      rust-overlay,
      ...
    }:
    let
      supportedSystems = [ "x86_64-linux" ];
      eachSystem = nixpkgs.lib.genAttrs supportedSystems;
    in
    {
      devShells = eachSystem (
        system:
        let
          overlays = [ (import rust-overlay) ];
          pkgs = import nixpkgs {
            inherit system overlays;
          };
        in
        {
          default =
            with pkgs;
            mkShell {
              buildInputs = with pkgs; [
                rust-analyzer
                rust-bin.stable.latest.default
              ];
            };
        }
      );
    };
}
```

With just one line of shell code from our project's root directory, `direnv` will know to automatically load our Nix flake:
```bash
echo "use flake" >> .envrc && direnv allow
```

To load the Nix environment, all we have to do now is navigate to the directory in Emacs. When `direnv` loads the environment, it will automatically download all of our specified packages in `flake.nix` and update the respective Emacs variables `process-environment` and `exec-path` so that packages from our flake started within Emacs use the correct `$PATH` with the proper environment variables set (even when using the daemon).

Compare this to working on the example project without `direnv`: we would first have to navigate to the project in our shell, manually run `nix develop` (or `nix-shell` if we are not using flakes) to pull in the toolchain and LSP, and then start Emacs from the shell to ensure those packages work properly.

Emacs will even display a helpful message in the minibuffer when `direnv` updates your environment variables. Here's a snippet from my `*Messages*` buffer of `direnv` loading a Nix environment when I navigate to one of my projects:
```
direnv: +AR +AR_FOR_TARGET +AS +AS_FOR_TARGET +CC +CC_FOR_TARGET +CONFIG_SHELL +CXX +CXX_FOR_TARGET +HOST_PATH +IN_NIX_SHELL +LD +LD_FOR_TARGET +NIX_BINTOOLS +NIX_BINTOOLS_FOR_TARGET +NIX_BINTOOLS_WRAPPER_TARGET_HOST_x86_64_unknown_linux_gnu +NIX_BINTOOLS_WRAPPER_TARGET_TARGET_x86_64_unknown_linux_gnu +NIX_BUILD_CORES +NIX_CC +NIX_CC_FOR_TARGET +NIX_CC_WRAPPER_TARGET_HOST_x86_64_unknown_linux_gnu +NIX_CC_WRAPPER_TARGET_TARGET_x86_64_unknown_linux_gnu +NIX_CFLAGS_COMPILE +NIX_ENFORCE_NO_NATIVE +NIX_HARDENING_ENABLE +NIX_LDFLAGS +NIX_LDFLAGS_FOR_TARGET +NIX_STORE +NM +NM_FOR_TARGET +OBJCOPY +OBJCOPY_FOR_TARGET +OBJDUMP +OBJDUMP_FOR_TARGET +RANLIB +RANLIB_FOR_TARGET +READELF +READELF_FOR_TARGET +SIZE +SIZE_FOR_TARGET +SOURCE_DATE_EPOCH +STRINGS +STRINGS_FOR_TARGET +STRIP +STRIP_FOR_TARGET +__structuredAttrs +buildInputs +buildPhase +builder +cmakeFlags +configureFlags +depsBuildBuild +depsBuildBuildPropagated +depsBuildTarget +depsBuildTargetPropagated +depsHostHost +depsHostHostPropagated +depsTargetTarget +depsTargetTargetPropagated +doCheck +doInstallCheck +dontAddDisableDepTrack +mesonFlags +name +nativeBuildInputs +out +outputs +patches +phases +preferLocalBuild +propagatedBuildInputs +propagatedNativeBuildInputs +shell +shellHook +stdenv +strictDeps +system ~PATH ~XDG_DATA_DIRS (~/Projects → ~/Projects/fasten)
```

And here's the snippet of `direnv` unloading the Nix environment when I navigate outside of the project:
```
direnv: ~PATH ~XDG_DATA_DIRS -AR -AR_FOR_TARGET -AS -AS_FOR_TARGET -CC -CC_FOR_TARGET -CONFIG_SHELL -CXX -CXX_FOR_TARGET -HOST_PATH -IN_NIX_SHELL -LD -LD_FOR_TARGET -NIX_BINTOOLS -NIX_BINTOOLS_FOR_TARGET -NIX_BINTOOLS_WRAPPER_TARGET_HOST_x86_64_unknown_linux_gnu -NIX_BINTOOLS_WRAPPER_TARGET_TARGET_x86_64_unknown_linux_gnu -NIX_BUILD_CORES -NIX_CC -NIX_CC_FOR_TARGET -NIX_CC_WRAPPER_TARGET_HOST_x86_64_unknown_linux_gnu -NIX_CC_WRAPPER_TARGET_TARGET_x86_64_unknown_linux_gnu -NIX_CFLAGS_COMPILE -NIX_ENFORCE_NO_NATIVE -NIX_HARDENING_ENABLE -NIX_LDFLAGS -NIX_LDFLAGS_FOR_TARGET -NIX_STORE -NM -NM_FOR_TARGET -OBJCOPY -OBJCOPY_FOR_TARGET -OBJDUMP -OBJDUMP_FOR_TARGET -RANLIB -RANLIB_FOR_TARGET -READELF -READELF_FOR_TARGET -SIZE -SIZE_FOR_TARGET -SOURCE_DATE_EPOCH -STRINGS -STRINGS_FOR_TARGET -STRIP -STRIP_FOR_TARGET -__structuredAttrs -buildInputs -buildPhase -builder -cmakeFlags -configureFlags -depsBuildBuild -depsBuildBuildPropagated -depsBuildTarget -depsBuildTargetPropagated -depsHostHost -depsHostHostPropagated -depsTargetTarget -depsTargetTargetPropagated -doCheck -doInstallCheck -dontAddDisableDepTrack -mesonFlags -name -nativeBuildInputs -out -outputs -patches -phases -preferLocalBuild -propagatedBuildInputs -propagatedNativeBuildInputs -shell -shellHook -stdenv -strictDeps -system (~/Projects/fasten → ~/Projects)
```
