" Taken from https://vim.fandom.com/wiki/Pasting_code_with_syntax_coloring_in_emails
function! MyToHtmlForDrawio(line1, line2)
  " make sure to generate in the correct format
  if exists('g:html_use_css')
    let l:old_html_use_css = g:html_use_css
  endif
  let g:html_use_css = 0

  " don't include line number
  if exists('g:html_number_lines')
    let l:old_html_number_lines = g:html_use_css
  endif
  let g:html_number_lines = 0

  " Tree-sitter doesn't work with TOhtml, so we have to enable syntax
  let l:old_syntax = &l:syntax
  setlocal syntax=ON

  " Call TOhtml
  exec a:line1.','.a:line2.'TOhtml'

  " Apparently for draw.io to happily format our HTML:
  " * only the body must be included. Otherwise draw.io inserts many blank
  " lines first
  " * all the content must be one line. Otherwise for each newline draw.io
  " inserts a newline, resulting in each line of code being separated by an
  " additional new line.

  " Find start of `<body>` 
  /<body
  " Start selection
  normal V
  " Jump to `</body>`
  /<\/body>
  " Compress all lines into one line
  normal J
  " Copy compressed line
  yank

  " Remove the buffer generated by TOhtml
  bwipeout!

  " restore old setting
  let &l:syntax = l:old_syntax
  if exists('l:old_html_use_css')
	  let g:html_use_css = l:old_html_use_css
  else
	  unlet g:html_use_css
  endif
  if exists('l:old_html_number_lines')
	  let g:html_number_lines = l:old_html_number_lines
  else
	  unlet g:html_number_lines
  endif
endfunction
command! -range=% MyToHtmlForDrawio :call MyToHtmlForDrawio(<line1>,<line2>)
