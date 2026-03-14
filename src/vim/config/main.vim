let g:mapleader = "\<Space>"
let g:maplocalleader = ','

" Prepend the profile local plugin before plug#begin so its autoload/
" functions are available when plugin/*.vim files are sourced.
execute 'set rtp^=' . expand('~/.vim/local_plugins/profile')

" Source core config files
for f in globpath(expand('<sfile>:p:h'), 'core/**/*.vim', 0, 1)
    exe 'source' f
endfor

" Start plugin configuration
" Use stdpath('data') so the plugin directory respects NVIM_APPNAME
" stdpath is not available in Vim. Vim always shares vim-plug plugins with the
" default NVIM_APPNAME.
if has('nvim')
	call plug#begin(stdpath('data') . '/plugins')
else
	call plug#begin('~/.local/share/nvim/plugins')
endif

" Source all vim plugin config files
for f in globpath(expand('<sfile>:p:h'), 'plugin/**/*.vim', 0, 1)
    exe 'source' f
endfor

Plug '~/.vim/local_plugins/large_file'
Plug '~/.vim/local_plugins/long_line'
Plug '~/.vim/local_plugins/shell'
Plug '~/.vim/local_plugins/plugin_manager'
Plug '~/.vim/local_plugins/profile'

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
