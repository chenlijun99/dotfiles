let g:mapleader = "\<Space>"
let g:maplocalleader = ','

if ! clj#core#enable_full_power()
	echo "Incompatible with full power config! Consider upgrading to a recent Neovim."
endif

" Source core config files
for f in globpath(expand('<sfile>:p:h'), 'core/**/*.vim', 0, 1)
    exe 'source' f
endfor

" Start plugin configuration
call plug#begin('~/.local/share/nvim/plugins')

" Source all vim plugin config files
for f in globpath(expand('<sfile>:p:h'), 'plugin/**/*.vim', 0, 1)
    exe 'source' f
endfor

Plug '~/.vim/local_plugins/shell'
Plug '~/.vim/local_plugins/plugin_manager'

call plug#end()

" Automatically install missing plugins on startup
" https://github.com/junegunn/vim-plug/wiki/extra#automatically-install-missing-plugins-on-startup
autocmd! VimEnter *
  \  if len(filter(values(g:plugs), '!isdirectory(v:val.dir)'))
  \|   PlugInstall --sync | q
  \| endif

if clj#core#enable_full_power()
	exe 'luafile' expand('<sfile>:p:h') . "/main.lua"
endif

" set modeline
" vim: foldlevel=0 foldmethod=marker
