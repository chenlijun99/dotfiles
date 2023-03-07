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

call plug#end()

if clj#core#enable_full_power()
	exe 'luafile' expand('<sfile>:p:h') . "/main.lua"
endif

" set modeline
" vim: foldlevel=0 foldmethod=marker
