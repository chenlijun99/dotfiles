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
noremap <silent><expr> L &l:wrap ? 'g$' : 'g_'

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
let g:which_key_map.s.V = "Vertical new"
nnoremap <silent> <leader>sV :vnew<cr>
let g:which_key_map.s.H = "Horizontal new"
nnoremap <silent> <leader>sH :new<cr>
let g:which_key_map.s.t = "Tab"
nnoremap <silent> <leader>st :tabnew<cr>
let g:which_key_map.s.T = "Tab new"
nnoremap <silent> <leader>sT :tab split<cr>

" Source https://vi.stackexchange.com/a/38170
let g:which_key_map.m.h = "Diff windows"
nnoremap <silent> <leader>md :windo diffthis<cr>
let g:which_key_map.m.h = "Diff off"
nnoremap <silent> <leader>mD :diffoff!<cr>


let g:which_key_map.t = { 'group_name': '+tab' }
let g:which_key_map.t.o = "New"
nnoremap <silent> <leader>to :tabnew<cr>
let g:which_key_map.t.s = "New (split)"
nnoremap <silent> <leader>ts :tab split<cr>
let g:which_key_map.t.c = "Close"
nnoremap <silent> <leader>tc :tabclose<cr>
let g:which_key_map.t.n = "Next"
nnoremap <silent> <leader>tn :tabnext<cr>
let g:which_key_map.t.h = "Previous"
nnoremap <silent> <leader>tN :tabprevious<cr>
let g:which_key_map.t["1"] = "Tab 1"
nnoremap <silent> <leader>t1 1gt
let g:which_key_map.t["2"] = "Tab 2"
nnoremap <silent> <leader>t2 2gt
let g:which_key_map.t["3"] = "Tab 3"
nnoremap <silent> <leader>t3 3gt
let g:which_key_map.t["4"] = "Tab 4"
nnoremap <silent> <leader>t4 4gt
let g:which_key_map.t["5"] = "Tab 5"
nnoremap <silent> <leader>t5 5gt
let g:which_key_map.t["6"] = "Tab 6"
nnoremap <silent> <leader>t6 6gt
let g:which_key_map.t["7"] = "Tab 7"
nnoremap <silent> <leader>t7 7gt
let g:which_key_map.t["8"] = "Tab 8"
nnoremap <silent> <leader>t8 8gt
let g:which_key_map.t["9"] = "Tab 9"
nnoremap <silent> <leader>t9 9gt
let g:which_key_map.t["<tab>"] = "Alternate tab"
nnoremap <silent> <leader>t<tab> g<tab>

let g:which_key_map.m.c =  'configure vimrc'
nnoremap <silent> <leader>mc :vsplit $MYVIMRC<cr>
let g:which_key_map.m.C = 'update vimrc'
nnoremap <silent> <leader>mC :source $MYVIMRC<cr>

" Source https://stackoverflow.com/a/42071865
"let g:which_key_map.b.c = 'Close all other buffers'
"nnoremap <silent> <leader>bc :%bd \|e#<CR>

" sudo write
command! W :w !sudo tee %
