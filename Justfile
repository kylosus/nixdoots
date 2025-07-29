hostname := `uname -n` 

nix_args := "--verbose --option eval-cache false --impure"

switch:
    sudo nixos-rebuild switch --flake .#{{ hostname }} {{ nix_args }}

switch-home:
    home-manager switch --flake .#{{ `id -un` }}@{{ hostname }} {{ nix_args }}

test:
    sudo nixos-rebuild test --flake .#{{ hostname }} {{ nix_args }}

upgrade:
    nix flake update
    just test
    git add flake.lock
    git commit -m "Updated dependencies" -S
    git push
    just switch

update:
    git pull
    just switch

fmt:
    nix fmt .

tree tree_hostname=hostname:
    nix-tree --derivation .#nixosConfigurations.{{ tree_hostname }}.config.system.build.toplevel --impure
