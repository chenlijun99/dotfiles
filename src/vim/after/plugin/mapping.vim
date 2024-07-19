" enter normal mode by pressing keys of homerow
inoremap jk <Esc>

" in-line scrolling, unless when doing <count>j or <count>k
nnoremap <expr> j v:count ? 'j' : 'gj'
nnoremap <expr> k v:count ? 'k' : 'gk'

" when jumping always put cursor at center of screen
nnoremap <c-d> <c-d>zz
nnoremap <c-u> <c-u>zz

" H jump to start-of-line
" L jump to end-of-line
" Should work even on wrappped lines
noremap <silent><expr> H &l:wrap ? 'g^' : '^'
noremap <silent><expr> L &l:wrap ? 'g$BE' : 'g_'

" when pasting in selection mode, don't overwrite register content with
" selected text
" Copied from https://vim.fandom.com/wiki/Replace_a_word_with_yanked_text#Alternative_mapping_for_paste
xnoremap <silent> p p:let @+=@0<CR>:let @"=@0<CR>
xnoremap <silent> P P:let @+=@0<CR>:let @"=@0<CR>

nnoremap <c-]> g<c-]>
vnoremap <c-]> g<c-]>

let g:which_key_map.w =  'Save all'
nnoremap <silent> <leader>w :wa<cr>
" Fix compulsive saving habit
ca w smile
ca wa smile

let g:which_key_map.s = { 'group_name': '+split' }
let g:which_key_map.s.v = "Vertical"
nnoremap <silent> <leader>sv :vsplit<cr>
let g:which_key_map.s.h = "Horizontal"
nnoremap <silent> <leader>sh :split<cr>
let g:which_key_map.s.v = "Vertical new"
nnoremap <silent> <leader>sV :vnew<cr>
let g:which_key_map.s.h = "Horizontal new"
nnoremap <silent> <leader>sH :new<cr>

" Source https://vi.stackexchange.com/a/38170
let g:which_key_map.m.h = "Diff windows"
nnoremap <silent> <leader>md :windo diffthis<cr>
let g:which_key_map.m.h = "Diff off"
nnoremap <silent> <leader>mD :diffoff!<cr>


let g:which_key_map.t = { 'group_name': '+tab' }
let g:which_key_map.t.n = "New"
nnoremap <silent> <leader>to :tabnew<cr>
let g:which_key_map.t.c = "Close"
nnoremap <silent> <leader>tc :tabclose<cr>
let g:which_key_map.t.v = "Next"
nnoremap <silent> <leader>tn :tabnext<cr>
let g:which_key_map.t.h = "Previous"
nnoremap <silent> <leader>tN :tabprevious<cr>

let g:which_key_map.m.c =  'configure vimrc'
nnoremap <silent> <leader>mc :vsplit $MYVIMRC<cr>
let g:which_key_map.m.C = 'update vimrc'
nnoremap <silent> <leader>mC :source $MYVIMRC<cr>

" Source https://stackoverflow.com/a/42071865
"let g:which_key_map.b.c = 'Close all other buffers'
"nnoremap <silent> <leader>bc :%bd \|e#<CR>

" sudo write
command! W :w !sudo tee %
