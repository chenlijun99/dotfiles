{...}: {
  flake.modules.homeManager.clj-opencode = {
    config,
    pkgs,
    lib,
    ...
  }: {
    options.clj.programs.opencode.enable = lib.mkEnableOption "opencode configuration" // {default = true;};

    config = lib.mkIf config.clj.programs.opencode.enable {
      programs.opencode = {
        enable = true;
        skills = {
          # Source: https://github.com/mattpocock/skills/blob/main/skills/productivity/grilling/SKILL.md
          "grill-me" = ''
            ---
            name: grill-me
            description: A relentless interview to sharpen a plan or design.
            ---
            Interview me relentlessly about every aspect of this plan until we reach a shared understanding. Walk down each branch of the design tree, resolving dependencies between decisions one-by-one. For each question, provide your recommended answer.

            Ask the questions one at a time, waiting for feedback on each question before continuing. Asking multiple questions at once is bewildering.

            If a *fact* can be found by exploring the codebase, look it up rather than asking me. The *decisions*, though, are mine — put each one to me and wait for my answer.

            Do not enact the plan until I confirm we have reached a shared understanding.
          '';
        };
      };
      home.persistence.${config.clj.impermanence.persistDir} = {
        directories = [
          ".local/share/opencode"
          ".config/opencode/package.json"
          ".config/opencode/package-lock.json"
          ".config/opencode/node_modules"
        ];
      };
    };
  };
}
