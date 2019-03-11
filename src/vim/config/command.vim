command! -n=1 RefactorWord :execute "%s/" . expand("<cword>") . "/". expand("<args>") . "/gc"

