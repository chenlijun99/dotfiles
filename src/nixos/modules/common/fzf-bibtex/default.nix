# Actually I don't need it anymore.
# Just keep here in case it becomes useful in the future.
{
  pkgs,
  lib,
  ...
}: (
  pkgs.buildGoModule {
    name = "fzf-bibtex";
    src = pkgs.fetchFromGitHub {
      owner = "chenlijun99";
      repo = "fzf-bibtex";
      rev = "2bb1ee67b63495b6432b51ad72c5ba99e54adc60";
      sha256 = "sha256-SbymnejoBoxEPrr1n4xaAElPkbNLk38dqaZ5p50NrC8=";
    };
    vendorHash = "sha256-vnF0MXqtGjPG0pomHEsgc/HwxLGjnZMB1yUFoHSq3vs=";

    buildInputs = with pkgs; [
      bibtool
    ];

    meta = with lib; {
      description = " a BibTeX source for fzf";
      mainProgram = "";
      homepage = "https://github.com/chenlijun99/fzf-bibtex";
      license = licenses.bsd3;
      platforms = platforms.unix;
      maintainers = [];
    };
  }
)
