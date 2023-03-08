func! clj#plugin_manager#update() abort
	if clj#core#enable_full_power()
		" Update Lua plugins (managed using lazy.nvim)
		Lazy update
	endif

	" Update Vim plugins (managed using vim-plug)
	PlugUpdate --sync
	" Generate vim-plug snapshot file.
	" `!` means: overwrite existing without asking.
	PlugSnapshot! ~/.vim/vim-plug-snapshot.vim
endf
