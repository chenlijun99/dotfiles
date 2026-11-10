# Declarative user-level Codex skills.
#
# Keep third-party sources pinned here and expose only the selected skill
# directories through Home Manager's Codex module. Local skills follow the
# dotfiles editable setting.
{...}: {
  flake.modules.homeManager.clj-codex = {
    config,
    lib,
    pkgs,
    ...
  }: let
    mattpocockSkillsSrc = pkgs.fetchFromGitHub {
      owner = "mattpocock";
      repo = "skills";
      rev = "c55ee46073ed923f86ce59a5eb3b6d895095d1b7";
      hash = "sha256-L3CpIT2DeI+fUFl9fcygojtQo2DzEen69rMD1XqR1vM=";
    };

    mkSkills = root: paths:
      lib.mapAttrs (_name: relativePath: "${root}/${relativePath}") paths;

    mattpocockSkills = mkSkills "${mattpocockSkillsSrc}/skills" {
      grill-me = "productivity/grill-me";
      grilling = "productivity/grilling";
      handoff = "productivity/handoff";
      setup-matt-pocock-skills = "engineering/setup-matt-pocock-skills";
      grill-with-docs = "engineering/grill-with-docs";
      domain-modeling = "engineering/domain-modeling";
      to-spec = "engineering/to-spec";
      to-tickets = "engineering/to-tickets";
      tdd = "engineering/tdd";
      codebase-design = "engineering/codebase-design";
      diagnosing-bugs = "engineering/diagnosing-bugs";
      implement = "engineering/implement";
      research = "engineering/research";
      prototype = "engineering/prototype";
      wayfinder = "engineering/wayfinder";
      triage = "engineering/triage";
      teach = "productivity/teach";
    };
    codexConfigDir =
      if config.home.preferXdgDirectories
      then "${config.xdg.configHome}/codex"
      else ".codex";
  in {
    config = lib.mkIf config.clj.programs.codex.enable {
      programs.codex.skills = mattpocockSkills;

      # programs.codex.skills inspects sources in builds without checkout access.
      home.file = {
        "${codexConfigDir}/skills/review-session".source =
          config.lib.clj.linkDotfile "src/vim/local_plugins/review_session/skills/review-session";
        "${codexConfigDir}/skills/clj-review-session".source =
          config.lib.clj.linkDotfile "src/nixos/modules/ai/codex/skills/clj-review-session";
        "${codexConfigDir}/skills/clj-code-review".source =
          config.lib.clj.linkDotfile "src/nixos/modules/ai/codex/skills/clj-code-review";
        "${codexConfigDir}/skills/clj-implement-review-loop".source =
          config.lib.clj.linkDotfile "src/nixos/modules/ai/codex/skills/clj-implement-review-loop";
      };
    };
  };
}
