+++
title = 'Switching To Hugo: Part Two'
description = 'The technical details of hosting my website.'
date = '2024-12-18T07:31:05-05:00'
draft = false
+++

*This post is part two in a two-part series on switching my website to
[Hugo](https://gohugo.io). It covers the technical details of hosting my
website. For an explanation as to why I made the switch, read
[part one](/posts/switching-to-hugo-one/).*

# Hosting my website
My website is hosted on [caddy](https://caddyserver.com), a popular HTTPS
server and reverse proxy. Caddy automatically obtains and renews TLS
certificates for my domains, which makes TLS certificate management a breeze.
The caddy server runs on one of my home servers, which itself runs NixOS.

## Configuring a web server on NixOS
[NixOS](https://nixos.org) allows for reproducible and declarative system
configurations, which makes the process of configuring and deploying a web
server quite trivial. One benefit of running my website on NixOS - aside from
the fact that NixOS is my distribution of choice - is that I can copy the
configuration down to any of my NixOS systems and have it work exactly the
same, regardless of the server it's running on. This alleviates the headache of
dependency management and reduces setup times down to just
`nixos-rebuild switch`, should I have the need to move my website to different
hardware. The [nix flake for my system
configurations](https://codeberg.org/tdback/nix-config) is tracked in a remote
repository with `git`, making configuration changes a single `git pull` away.

The following module defined in `modules/services/proxy/default.nix` enables
the caddy service using the `caddy` package found in
[nixpkgs](https://search.nixos.org/packages?channel=24.11&query=caddy),
and opens up both TCP ports 80 and 443 to accept inbound HTTP/S traffic.
```nix
{ pkgs, ... }:
{
  services.caddy = {
    enable = true;
    package = pkgs.caddy;
  };

  networking.firewall.allowTCPPorts = [ 80 443 ];
}
```

Then, in a separate module defined in `modules/services/web/default.nix`, I've
created a caddy virtual host entry for my domain name. By pairing the
`file_server` and `root` directives together in caddy, I can spin up a web
server and host the content found in `/var/www/tdback.net/` on the NixOS
server. I've also enabled both gzip and zstd support for compressing web server
responses.

```nix
{ ... }:
{
  services.caddy.virtualHosts = {
    "tdback.net".extraConfig = ''
      root * /var/www/tdback.net/
      encode zstd gzip
      file_server
    '';
  };
}
```

The server is made publicly accessible using [IPv6rs](https://ipv6.rs), which
is a wonderful service I plan to cover in future blog posts. A few DNS host A
and AAAA records are required to properly resolve queries for
https://tdback.net to my web server's IPv6 address (including requests made to
the server using IPv4!) but that's pretty much it in regards to the server
configuration.

## Writing and managing content
The following is a nix flake I've written to create a development environment
on my desktop for managing the content and generation of my website.

```nix
{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { ... }@inputs:
    inputs.flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import inputs.nixpkgs { inherit system; };
      in
      {
        devShells.default = pkgs.mkShell {
          buildInputs = with pkgs; [
            hugo
          ];

          shellHook = ''
            SITE="$HOME/projects/tdback.net"

            new-post() {
              hugo new "posts/$1/index.md"
              $EDITOR "$SITE/content/posts/$1/index.md"
            }

            del-post() {
              POST="$SITE/content/posts/$1"
              [ -d $POST ] && rm -r $POST
            }
          '';
        };
      });
}
```

When I run the command `nix develop` in my terminal, nix automatically creates
a new shell environment, pulls down the `hugo` command from the specific
revision of nixpkgs found in `flake.lock`, and defines the functions specified
in the `shellHook` attribute.

By storing this flake and my website's source code in a git repository, I can
clone the repo down to an entirely separate machine - for instance my laptop -
and have an entirely reproducible shell environment for working on my website.

I also have the added bonus of being able to completely blow away the temporary
shell environment when I exit out of the terminal or type `C-d` (the same as
`exit`). This means that `hugo` and any functions or environment variables
defined in the `shellHook` attribute are *only available when I'm in the
temporary shell environment*, thus reducing the clutter of programs, their
dependencies, environment variables, and function definitions.

## Deployment of the site
When I make a change to the website, the entire site can be regenerated and
deployed to the NixOS server by running the following one-liner:

```bash
hugo && rsync -avz --delete public/ hive:/var/www/tdback.net/
```

I've placed this command in a shell script to make deployments as simple as
typing `./deploy.sh`. This results in near-zero downtime between changes: a
simple refresh of the page on a client's device will load the newest version of
the site.

Happy hacking!
