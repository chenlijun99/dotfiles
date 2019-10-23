Plug 'mattn/emmet-vim', { 'for' : ['html','javascript', 'php', 'markdown'] }
let g:user_emmet_leader_key = ',e'

autocmd! FileType html,javascript,php,markdown
			\ let g:which_key_map_local.e = { 'name' : '+emmet' }

