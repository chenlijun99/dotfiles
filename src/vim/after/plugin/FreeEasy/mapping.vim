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
" Should work even on wrappped lines
noremap H g^
" Since there is no version of `g_` that works on wrapped line,
" I first jump to the end using g$ and then go back to the first non-blank
" character using BE
" The only case it doesn't work is when a word is chopped due to wrapping.
" in which case we go at the end of the end, which is at the next line.
noremap L g$BE

" when pasting in selection mode, don't overwrite register content with
" selected text
" Copied from https://vim.fandom.com/wiki/Replace_a_word_with_yanked_text#Alternative_mapping_for_paste
xnoremap <silent> p p:let @+=@0<CR>:let @"=@0<CR>
xnoremap <silent> P P:let @+=@0<CR>:let @"=@0<CR>

nnoremap <c-]> g<c-]>
vnoremap <c-]> g<c-]>

let g:which_key_map.m.c =  'configure vimrc'
nnoremap <silent> <leader>mc :vsplit $MYVIMRC<cr>
let g:which_key_map.m.C = 'update vimrc'
nnoremap <silent> <leader>mC :source $MYVIMRC<cr>

" sudo write
command! W :w !sudo tee %
