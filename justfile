default:
  @just --list

rebuild-pre:
  @git add --intent-to-add .

rebuild: rebuild-pre && rebuild-post
  scripts/rebuild.sh

update:
  @nix flake update

rebuild-post:

iso:
  # If we dont remove this folder, libvirtd VM doesnt run with the new iso...
  rm -rf result
  nix build '.#nixosConfigurations.iso.config.system.build.isoImage' && ln -sf result/iso/*.iso latest.iso
