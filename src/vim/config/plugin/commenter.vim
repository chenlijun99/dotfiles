let g:which_key_map.c = { 'group_name' : '+comment' }
Plug 'scrooloose/nerdcommenter' , { 'on' : '<Plug>NERDCommenterToggle' }
let g:NERDCreateDefaultMappings = 0

let g:which_key_map.c.c = 'toggle'
nmap <leader>cc <Plug>NERDCommenterToggle
vmap <leader>cc <Plug>NERDCommenterToggle
