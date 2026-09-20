# Declarative user-level Codex skills.
#
# Keep third-party sources pinned here and expose only the selected skill
# directories through Home Manager's Codex module.
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
      setup-matt-pocock-skills = "engineering/setup-matt-pocock-skills";
      grill-with-docs = "engineering/grill-with-docs";
      domain-modeling = "engineering/domain-modeling";
      to-spec = "engineering/to-spec";
      to-tickets = "engineering/to-tickets";
      tdd = "engineering/tdd";
      codebase-design = "engineering/codebase-design";
      code-review = "engineering/code-review";
      diagnosing-bugs = "engineering/diagnosing-bugs";
      implement = "engineering/implement";
      research = "engineering/research";
      prototype = "engineering/prototype";
      wayfinder = "engineering/wayfinder";
      triage = "engineering/triage";
      teach = "productivity/teach";
    };
    localSkills = {
    };
    skills = mattpocockSkills // localSkills;
  in {
    config = lib.mkIf config.clj.programs.codex.enable {
      programs.codex.skills = skills;
    };
  };
}
