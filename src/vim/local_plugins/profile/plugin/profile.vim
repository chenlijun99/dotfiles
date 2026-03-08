" Profile management user commands.
"
" Active profile is resolved at startup (in priority order):
"   1. $VIM_CLJ_PROFILE environment variable
"   2. stdpath('state')/profile file  (~/.local/state/nvim/profile)
"   3. Default: 'minimal'
"
" Use :CljSetProfile <profile> to persist a profile choice.
" The change takes effect on the next restart.

let s:valid_profiles = ['minimal', 'full']

command! -nargs=1 -complete=customlist,<SID>ProfileComplete CljSetProfile
			\ call s:SetProfile(<f-args>)

function! s:ProfileComplete(ArgLead, CmdLine, CursorPos)
	return filter(copy(s:valid_profiles), {_, v -> v =~ '^' . a:ArgLead})
endfunction

function! s:SetProfile(profile) abort
	if index(s:valid_profiles, a:profile) < 0
		echohl ErrorMsg
		echom 'Unknown profile: "' . a:profile . '". Valid profiles: '
					\ . join(s:valid_profiles, ', ')
		echohl None
		return
	endif

	if has('nvim')
		let l:state_dir = stdpath('state')
	else
		let l:state_dir = expand('~/.local/state/nvim')
	endif

	if !isdirectory(l:state_dir)
		call mkdir(l:state_dir, 'p')
	endif

	call writefile([a:profile], l:state_dir . '/profile')
	echom "Vim profile set to '" . a:profile . "'. Restart Neovim to apply."
endfunction
