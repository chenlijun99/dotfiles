let g:which_key_map.l = { 'name' : '+intellisense' }

Plug 'neoclide/coc.nvim', {'tag': '*', 'do': { -> coc#util#install()}}

" Use tab for trigger completion with characters ahead and navigate.
" Use command ':verbose imap <tab>' to make sure tab is not mapped by other plugin.
inoremap <silent><expr> <TAB>
      \ pumvisible() ? "\<C-n>" :
      \ <SID>check_back_space() ? "\<TAB>" :
      \ coc#refresh()
inoremap <expr><S-TAB> pumvisible() ? "\<C-p>" : "\<C-h>"

function! s:check_back_space() abort
  let col = col('.') - 1
  return !col || getline('.')[col - 1]  =~# '\s'
endfunction

" Use <c-space> for trigger completion.
inoremap <silent><expr> <c-space> coc#refresh()

" Use <cr> for confirm completion, `<C-g>u` means break undo chain at current position.
" Coc only does snippet and additional edit on confirm.
inoremap <expr> <cr> pumvisible() ? "\<C-y>" : "\<C-g>u\<CR>"

" Use `[c` and `]c` for navigate diagnostics
nmap <silent> [c <Plug>(coc-diagnostic-prev)
nmap <silent> ]c <Plug>(coc-diagnostic-next)

" Remap keys for gotos
let g:which_key_map_g.d = 'Goto definition'
nmap <silent> gd <Plug>(coc-definition)
let g:which_key_map_g.y = 'Goto type definition'
nmap <silent> gy <Plug>(coc-type-definition)
let g:which_key_map_g.i = 'Goto implementation'
nmap <silent> gi <Plug>(coc-implementation)
let g:which_key_map_g.r = 'References'
nmap <silent> gr <Plug>(coc-references)

let g:which_key_map_g['#'] = 'which_key_ignore'
let g:which_key_map_g['*'] = 'which_key_ignore'
let g:which_key_map_g.D = 'which_key_ignore'
let g:which_key_map_g['%'] = 'which_key_ignore'
let g:which_key_map_g.x = 'which_key_ignore'

" Use K for show documentation in preview window
nnoremap <silent> K :call <SID>show_documentation()<CR>

function! s:show_documentation()
  if &filetype == 'vim'
    execute 'h '.expand('<cword>')
  else
    call CocAction('doHover')
  endif
endfunction

" Highlight symbol under cursor on CursorHold
autocmd CursorHold * silent call CocActionAsync('highlight')

" Remap for rename current word
let g:which_key_map.l.rn = 'rename'
nmap <leader>lrn <Plug>(coc-rename)

" Remap for format selected region
let g:which_key_map.l.f = 'format'
vmap <leader>lf  <Plug>(coc-format-selected)
nmap <leader>lf  <Plug>(coc-format-selected)

augroup mygroup
  autocmd!
  " Setup formatexpr specified filetype(s).
  autocmd FileType typescript,json setl formatexpr=CocAction('formatSelected')
  " Update signature help on jump placeholder
  autocmd User CocJumpPlaceholder call CocActionAsync('showSignatureHelp')
augroup end

" Remap for do codeAction of selected region, ex: `<leader>aap` for current paragraph
let g:which_key_map.l.la = 'codeaction'
vmap <leader>la  <Plug>(coc-codeaction-selected)
nmap <leader>la  <Plug>(coc-codeaction-selected)

" Remap for do codeAction of current line
let g:which_key_map.l.lac = 'codeaction (current line)'
nmap <leader>lac  <Plug>(coc-codeaction)
" Fix autofix problem of current line
let g:which_key_map.l.lqf = 'autofix (current line)'
nmap <leader>lqf  <Plug>(coc-fix-current)

" Use `:Format` for format current buffer
command! -nargs=0 Format :call CocAction('format')

" Use `:Fold` for fold current buffer
command! -nargs=? Fold :call CocAction('fold', <f-args>)

" Using CocList
" Show all diagnostics
let g:which_key_map.l.l = { 'name': '+list' }
let g:which_key_map.l.l.a = 'diagnostics'
nnoremap <silent> <leader>lla  :<C-u>CocList diagnostics<cr>
" Manage extensions
let g:which_key_map.l.l.e = 'extensions'
nnoremap <silent> <leader>lle  :<C-u>CocList extensions<cr>
" Show commands
let g:which_key_map.l.l.c = 'commands'
nnoremap <silent> <leader>llc  :<C-u>CocList commands<cr>
" Find symbol of current document
let g:which_key_map.l.l.o = 'outline'
nnoremap <silent> <leader>llo  :<C-u>CocList outline<cr>
" Search workspace symbols
let g:which_key_map.l.l.s = 'workspace symbols'
nnoremap <silent> <leader>lls  :<C-u>CocList -I symbols<cr>
" Do default action for next item.
let g:which_key_map.l.l.j = 'next'
nnoremap <silent> <leader>llj  :<C-u>CocNext<CR>
" Do default action for previous item.
let g:which_key_map.l.l.k = 'previous'
nnoremap <silent> <leader>llk  :<C-u>CocPrev<CR>
" Resume latest coc list
let g:which_key_map.l.l.p = 'resume'
nnoremap <silent> <leader>llp  :<C-u>CocListResume<CR>

let s:coc_extensions = [
			\ 'coc-dictionary',
			\ 'coc-json',
			\ 'coc-snippets',
			\ 'coc-tag',
			\]

function! InstallCocExtensions()
	for extension in s:coc_extensions
		call coc#add_extension(extension)
	endfor
endfunction

autocmd User CocNvimInit call InstallCocExtensions()

" Use <C-l> to trigger snippet expand.
imap <C-l> <Plug>(coc-snippets-expand)
" Use <C-j> to select text for visual text of snippet.
vmap <C-j> <Plug>(coc-snippets-select)
" Use <C-j> to jump to forward placeholder, which is default
let g:coc_snippet_next = '<c-j>'
" Use <C-k> to jump to backward placeholder, which is default
let g:coc_snippet_prev = '<c-k>'
imap <C-j> <Plug>(coc-snippets-expand-jump)
