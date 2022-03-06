let g:which_key_map =  {}
let g:which_key_map_local =  {}
let g:which_key_map_g =  {}
let g:which_key_map_global_next =  {}
let g:which_key_map_global_previous =  {}
let g:which_key_map.m = { 'name': '+misc' }
let g:which_key_map.b = { 'name': '+buffer' }

if clj#core#enable_full_power()
	lua <<EOF
	which_key_map =  {}
	which_key_map_local =  {}
	which_key_map_g =  {}
	which_key_map_global_next =  {}
	which_key_map_global_previous =  {}
	which_key_map.m = {}
	which_key_map.b = {}
EOF
endif
