# rtk from upstream. nixpkgs 26.05 ships 0.41.0, which silently caps
# `git log` at 50 commits, rejects `find -not`, and rewrites `head -N` despite
# exclude_commands. Controls: scripts/test-rtk.sh (RTK=<built rtk> before a
# switch). From 1.0 the linked engine crate is BUSL-1.1 with a use grant for
# the shipped binary.
{pkgs}:
pkgs.rtk.overrideAttrs (finalAttrs: old: {
  version = "1.0.1";
  src = pkgs.fetchFromGitHub {
    owner = "rtk-ai";
    repo = "rtk";
    tag = "v${finalAttrs.version}";
    hash = "sha256-8nf2q6SGupoOqaf97TdD37lSCj7cMNfYGwX+42mWz1k=";
  };
  cargoDeps = pkgs.rustPlatform.fetchCargoVendor {
    inherit (finalAttrs) pname version src;
    hash = "sha256-WoBuQ+Meml4wXSp8bQTckjvjriKsSOs0vSijWo0frq8=";
  };
  # proxy/ declares its own binary; the CLI is the rtk package.
  cargoBuildFlags = ["-p" "rtk"];
  cargoTestFlags = ["-p" "rtk"];
  # 1.0 tests pipe a body through `rtk curl` and run the jq-based hook scripts.
  nativeCheckInputs = old.nativeCheckInputs ++ [pkgs.curl pkgs.jq];
  meta = old.meta // {license = with pkgs.lib.licenses; [asl20 bsl11];};
})
