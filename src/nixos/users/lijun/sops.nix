{config, ...}: {
  sops.defaultSopsFile = ./secrets.yaml;
  sops.age.keyFile = "${config.home.homeDirectory}/.config/sops/age/keys.txt";
  sops.secrets = {
    GEMINI_API_KEY = {};
  };
}
