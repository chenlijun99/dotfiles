let g:which_key_map.p =  { 'name' : '+panel' }
if clj#core#enable_full_power()
	lua <<EOF
	which_key_map.p =  {}
EOF
endif
