let mapleader=","

" enter normal mode by pressing keys of homerow
inoremap jk <Esc>
cnoremap jk <c-c>

" in-line scrolling
noremap j gj
noremap k gk

" when jumping always put cursor at center of screen
nnoremap <c-d> <c-d>zz
nnoremap <c-u> <c-u>zz

" H jump to start-of-line
" L jump to end-of-line
noremap H ^
noremap L g_

" when pasting in selection mode, don't overwrite register content with
" selected text
vnoremap p "_dP

nnoremap <c-]> g<c-]>
vnoremap <c-]> g<c-]>

" edit vimrc
nnoremap <leader>ev :vsplit $MYVIMRC<cr>
nnoremap <leader>sv :source $MYVIMRC<cr>

" edit general settings
nnoremap <leader>eV :vsplit ~/.vim/config/settings.vim<cr>
nnoremap <leader>sV :source ~/.vim/config/settings.vim<cr>

" edit keymapping
nnoremap <leader>ek :vsplit ~/.vim/config/keymapping.vim<cr>
nnoremap <leader>sk :source ~/.vim/config/keymapping.vim<cr>

" edit ftplugin for current filetype
nnoremap <leader>ef :execute printf("vsplit ~/.vim/after/ftplugin/%s.vim", &filetype)<cr>
nnoremap <leader>sf :execute printf("source ~/.vim/after/ftplugin/%s.vim", &filetype)<cr>

" edit snippets for current filetype
nnoremap <leader>es :execute printf("vsplit ~/.vim/snippets/%s.snip", &filetype)<cr>
nnoremap <leader>ss :execute printf("source ~/.vim/snippets/%s.snip", &filetype)<cr>

" edit plugins
nnoremap <leader>eP :execute printf("vsplit %s/%s.vim",g:pluginFilesDir, 'general')<cr>
nnoremap <leader>sP :execute printf("vsplit %s/%s.vim",g:pluginFilesDir, 'general')<cr>
nnoremap <leader>ep :execute printf("vsplit %s/%s.vim",g:languageSpecificPluginFilesDir, &filetype)<cr>
nnoremap <leader>sp :execute printf("source %s/%s.vim",g:languageSpecificPluginFilesDir, &filetype)<cr>

" sudo write
command! W :w !sudo tee %
