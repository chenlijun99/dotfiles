# Vim config

## Structure

```
.
├── after
│   ├── ftplugin # ftplugins files executed after everything
│   │   └── ...
│   └── plugin # Vimscript files executed after everything
│       └── ...
├── autoload
│   ├── clj
│   │   └── core.vim
│   ├── FreeEasy      # custom autoload VimScript functions
│   │   └── shell.vim
│   ├── plug.vim      # vim plug
│   └── plug.vim.old  # vim plug old
├── config
│   ├── core # Core config modules. Always executed if `.vim`. Executed only on Neovim if `*.lua`.
│   │   └── which_key.vim
│   ├── main.lua # Additional config entry point. Executed only on Neovim
│   ├── main.vim # Actual config entry point. Always executed
│   └── plugin  # All the external plugins, both Vimscript plugins and Lua plugins
│       └── ...
├── ftplugin # Custom ftplugins
│   └── ...
├── local_plugins # My private tiny Vim plugins
│   └── ...
├── init.vim  # Vim/NeoVim config entry point. Simply executes `main.vim`
├── lazy-lock.json
├── lua # Lua modules accessible in Neovim via `require()`
│   └── clj # My custom lua modules. Use clj as prefix to ensure no module name conflict in `require()`.
│       ├── plugin -> ../../config/plugin # System link used so that lazy.nvim can find the Lua plugin modules 
│       └── ...
├── plugin # Vimscritp files that are always executed
│   ├── settings.vim # Core settings file where I set most vim options
│   └── ...
├── projects # Project specific config for "nvim-projectconfig"
│   └── ...
├── README.md # This README.md
├── snippets # Custom snipplets
│   └── ...
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
