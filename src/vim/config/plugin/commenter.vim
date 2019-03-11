let g:which_key_map.c = { 'name' : '+comment' }
Plug 'scrooloose/nerdcommenter' , { 'on' : '<Plug>NERDCommenterToggle' }

nmap <leader>cc <Plug>NERDCommenterToggle
vmap <leader>cc <Plug>NERDCommenterToggle
let g:which_key_map.c.c = 'toggle'
