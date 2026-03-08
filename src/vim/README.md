# Vim config

## Profiles

The configuration supports two profiles that control which plugins are loaded:

| Profile | Description |
|---------|-------------|
| `minimal` | Core editing, navigation, git, fuzzy find. Suitable for remote servers. |
| `full` | Everything in `minimal` plus LSP, completion, AI, debugger, treesitter, language-specific tooling, etc. |

### How the active profile is resolved

At startup the profile is determined by the first match in this priority order:

1. **`$VIM_CLJ_PROFILE` environment variable** — set this for a one-off or session-level override.
2. **`~/.local/state/nvim/profile`** — the persisted profile written by `:CljSetProfile`.
3. **Default: `minimal`** — if neither of the above is present.

### Switching profiles

Use the `:CljSetProfile` command to persist a choice (takes effect on the next restart):

```
:CljSetProfile minimal
:CljSetProfile full
```

Tab-completion is supported. The command writes the profile name to
`~/.local/state/nvim/profile`.

For a one-time override without persisting:

```sh
VIM_CLJ_PROFILE=full nvim
```

### Testing profiles with NVIM_APPNAME

`NVIM_APPNAME` changes the application name Neovim uses for all `stdpath()`
lookups (config, data, state, …), giving you a fully isolated environment.
To reuse my existing config under a different name, first create a symlink:

```sh
ln -s ~/.config/nvim ~/.config/nvim-test
```

Then launch with a profile override:

```sh
# Isolated one-off test
NVIM_APPNAME=nvim-test VIM_CLJ_PROFILE=full nvim
```

The symlink is required so that Neovim finds the config. Without it, Neovim
starts with an empty config.

### Nix integration

The profile can be set declaratively through the NixOS / home-manager option:

```nix
clj.programs.neovim.profile = "full";   # or "minimal"
```

The preset modules already set sensible defaults:

* `clj-preset-minimal` → `"minimal"` (default)
* `clj-preset-full` → `"full"`

When the profile is set via Nix, home-manager writes the value to
`~/.local/state/nvim/profile` as a managed file. The `$VIM_CLJ_PROFILE`
environment variable still takes precedence over the Nix-managed file.

The Nix profile also gates which system packages are installed: the full
dev toolchain (language servers, formatters, linters, tree-sitter, etc.)
is only installed when `profile = "full"`.

---

## Structure

```
.
├── after
│   ├── ftplugin # ftplugins files executed after everything
│   │   └── ...
│   └── plugin # Vimscript files executed after everything
│       └── ...
├── autoload
│   ├── clj
│   │   └── core.vim
│   ├── FreeEasy      # custom autoload VimScript functions
│   │   └── shell.vim
│   ├── plug.vim      # vim plug
│   └── plug.vim.old  # vim plug old
├── config
│   ├── core # Core config modules. Always executed if `.vim`. Executed only on Neovim if `*.lua`.
│   │   └── which_key.vim
│   ├── main.lua # Additional config entry point. Executed only on Neovim
│   ├── main.vim # Actual config entry point. Always executed
│   └── plugin  # All the external plugins, both Vimscript plugins and Lua plugins
│       └── ...
├── ftplugin # Custom ftplugins
│   └── ...
├── local_plugins # My private tiny Vim plugins
│   ├── profile       # Profile system (detection, CljSetProfile command, Lua module)
│   └── ...
├── init.vim  # Vim/NeoVim config entry point. Simply executes `main.vim`
├── lazy-lock.json
├── lua # Lua modules accessible in Neovim via `require()`
│   └── clj # My custom lua modules. Use clj as prefix to ensure no module name conflict in `require()`.
│       ├── plugin -> ../../config/plugin # System link used so that lazy.nvim can find the Lua plugin modules 
│       └── ...
├── plugin # Vimscritp files that are always executed
│   ├── settings.vim # Core settings file where I set most vim options
│   └── ...
├── projects # Project specific config for "nvim-projectconfig"
│   └── ...
├── README.md # This README.md
├── snippets # Custom snipplets
│   └── ...
└── spell
```

### Structure of the `config/plugin` directory

```
.
├── *.vim # Vimscript plugins that will be used both in Vim and NeoVim
├── *.lua # Lua plugins that will be used only in NeoVim
└── <folder> 
    ├── init.lua # See point 1.
    └── 0-init.vim # See point 2.
```

1. `init.lua`: `init.lua` in subfolders are necessary because of some limitation of  `lazy.nvim`. See [Lazy does not detect modules in subfolders](https://github.com/folke/lazy.nvim/issues/139).
2. `0-init.vim`: We source files in lexicographic order. A file `0-init.vim` is surely sourced first, thanks to the initial `0`. We use this file to do some initialization (e.g. define some global variables).

### Profile guards in plugin files

VimScript plugins check the profile via:

```vim
if !clj#profile#is_full()
    finish
endif
```

Lua plugins check via:

```lua
local profile = require("clj.profile")
if not profile.is("full") then return {} end
```

For groups with mixed membership the `init.lua` conditionally includes imports:

```lua
local profile = require("clj.profile")
local specs = {
    { import = "clj.plugin.always.loaded" },  -- minimal + full
}
if profile.is("full") then
    vim.list_extend(specs, {
        { import = "clj.plugin.full.only" },
    })
end
return specs
```
