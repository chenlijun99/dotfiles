" How we use which-key (https://github.com/folke/which-key.nvim)
" 
" For individual mapping in Lua files, just use NeoVim APIs and write an
" appropriate description in the "desc" option.
"
" For mapping set via vimscript, record the description in the which_key_map*
" global variables.
"
" For mapping groups, record their name in the which_key_map global variables.
"
" At the end, when configuring which-key, the information saves in these
" global variables will be passed to which-key.
"
" NOTE: this works well for static global mappings because which-key is
" lazyloaded (and thus lazyly configured), which means that by the time it is
" configured the which_key_map global variables will be fully filled.
" Even without lazy loading, since plugins config files are sourced in 
" alphabetic order (are they really?), it would still work (probably).
"
" For dynamic mappings (e.g. filetype dependent mappings), which-key will still 
" show them, but we but unfortunately there is no way to set a name for vimscript 
" mappings. But it's good enough.
let g:which_key_map =  {}
let g:which_key_map.m = { 'group_name': '+misc' }
let g:which_key_map.b = { 'group_name': '+buffer' }

let g:which_key_map_g =  {}

let g:which_key_map_global_next =  {}
let g:which_key_map_global_previous =  {}
