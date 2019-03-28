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

let g:which_key_map.m.c =  'configure vimrc'
nnoremap <silent> <leader>mc :vsplit $MYVIMRC<cr>
let g:which_key_map.m.C = 'update vimrc'
nnoremap <silent> <leader>mC :source $MYVIMRC<cr>

let g:which_key_map.m.u = { 'name': '+Utils' }
let g:which_key_map.m.u.a = 'Anki'
nnoremap <silent> <leader>mua :edit /home/chenlijun/.my-utils/Anki/scratchpad.tex<cr>

" sudo write
command! W :w !sudo tee %
