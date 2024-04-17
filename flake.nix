{
  description = "Process Compose Zombie Docker Container Demonstration";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    process-compose.url = "github:F1bonacc1/process-compose";
    flake-parts.url = "github:hercules-ci/flake-parts";
    arion.url = "github:hercules-ci/arion?rev=6a1f03329c400327b3b2e0ed5e1efff11037ba67";
  };
  outputs = inputs@{ self, nixpkgs, flake-parts, ... }:
    flake-parts.lib.mkFlake { inherit inputs; } {
      systems =
        [ "x86_64-linux" "aarch64-linux" "aarch64-darwin" "x86_64-darwin" ];
      perSystem = { config, self', inputs', pkgs, system, ... }:
        let
          inputs = [ pkgs.nil pkgs.postgresql pkgs.docker-compose inputs'.process-compose.packages.process-compose ] ;
        in {
          packages = let
            arion = inputs'.arion.packages.default;          
            postgres-image = pkgs.dockerTools.pullImage {
              imageName = "timescale/timescaledb";
              imageDigest = "sha256:eb8a3142384e8fd93ebd311783b297a04398ca61902b41233912a1a115279b69";
              sha256 = "sha256-zJ6HTYhxO7h+brEQOoJgDbHp74JfFe0Jcsfnz8MCFHM=";
              finalImageName = "timescaledb";
              finalImageTag = "2.14.1-pg16";
            };          
            in {
            arion = let
              arion-compose-definiton = arion.build {
                modules = [
                  {
                    project.name = "process-compose-bug";
                    services = {
                      postgres = {
                        build.image = pkgs.lib.mkForce postgres-image;
                        service = {
                          tty = true;
                          stop_signal = "SIGINT";
                          ports = [
                            "5432:5432"
                          ];
                          command = "postgres -c shared_buffers=1024MB -c effective_cache_size=2048MB";
                          environment = {
                            POSTGRES_PASSWORD = "postgrespassword";
                            POSTGRES_DB = "default";
                          };
                        };
                      };
                    };
                  }
                ];
              };

            in pkgs.writeShellApplication {
              name = "postgres-arion";
              runtimeInputs = [ inputs'.arion.packages.default ];
              text = ''
                arion --prebuilt-file ${arion-compose-definiton} up --build --force-recreate -V --always-recreate-deps --remove-orphans
              '';
            };

            default = pkgs.writeShellApplication {
              name = "process-compose-bug";
              runtimeInputs = inputs;
              text = ''
                process-compose -f ${./process-compose.yml}
              '';
            };
          };
          devShells = {
            default = pkgs.mkShell {
              buildInputs = inputs;
            };
          };
        };
    };
}
