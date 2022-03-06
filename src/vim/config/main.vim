let g:mapleader = "\<Space>"
let g:maplocalleader = ','

" Source core config files
for f in globpath(expand('<sfile>:p:h'), 'core/**/*.vim', 0, 1)
    exe 'source' f
endfor

" Start plugin configuration
call plug#begin('~/.vim/bundle')

" Source all vim plugin config files
for f in globpath(expand('<sfile>:p:h'), 'plugin/**/*.vim', 0, 1)
    exe 'source' f
endfor

" Source all lua plugin config files
if has('nvim-0.5.0')
	lua Plug = require 'vim_plug'
	for f in globpath(expand('<sfile>:p:h'), 'plugin/**/*.lua', 0, 1)
		exe 'luafile' f
	endfor
endif

call plug#end()

" Handle lua plugins
if has('nvim-0.5.0')
	lua Plug.after_plug_end()
endif

" set modeline 
" vim: foldlevel=0 foldmethod=marker
