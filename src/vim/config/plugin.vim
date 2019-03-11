call plug#begin('~/.vim/bundle')

execute 'source' . pluginFilesDir . '/general.vim'
execute 'source' . pluginFilesDir . '/language_services.vim'
execute 'source' . pluginFilesDir . '/debug.vim'

let pluginFiles = split(globpath(languageSpecificPluginFilesDir, '*.vim'), '\n')
for pluginFile in pluginFiles
	execute 'source' pluginFile
endfor
call plug#end()

" required by plugin manager
filetype plugin indent on
" enables syntax highlighting
syntax on

" set modeline 
" vim: foldlevel=0 foldmethod=marker
