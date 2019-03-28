Plug 'sbdchd/neoformat', { 'on': ['Neoformat'] }
augroup fmt
  autocmd!
  autocmd BufWritePre *.c,*.cpp,*.cxx,*.h,*.hpp Neoformat
augroup END

Plug 'sgur/vim-editorconfig'
