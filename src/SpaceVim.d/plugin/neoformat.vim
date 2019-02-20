augroup fmt
	autocmd!
	autocmd FileType c,cpp Neoformat
augroup END

" don't run clang-format when no .clang-format file is present
let g:neoformat_c_clangformat = {
			\ 'exe': 'clang-format',
			\ 'args': ['-fallback-style=none'],
			\ 'stdin': 1,
			\ }

let g:neoformat_cpp_clangformat = {
			\ 'exe': 'clang-format',
			\ 'args': ['-fallback-style=none'],
			\ 'stdin': 1,
			\ }
