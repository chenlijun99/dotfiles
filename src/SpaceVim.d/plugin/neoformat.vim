augroup fmt
	autocmd!
	autocmd BufWritePre *.c,*.cpp Neoformat
augroup END
