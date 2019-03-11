autocmd! BufEnter * execute printf("setlocal tags+=~/.vim/tags/%s/", &filetype)
