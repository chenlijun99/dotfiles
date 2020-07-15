" Language servers
if executable('ccls')
	call coc#config('languageserver', {
				\ 'ccls': {
				\ 	"command": "ccls",
				\ 	"filetypes": [
				\ 		"c",
				\ 		"cpp",
				\ 		"objc",
				\ 		"objcpp"
				\ 	],
				\ 	"rootPatterns": [
				\ 		".ccls",
				\ 		"compile_commands.json",
				\ 		".vim/",
				\ 		".git/",
				\ 		".hg/"
				\ 	],
				\ 	"initializationOptions": {
				\ 		"cache": {
				\ 			"directory": "/tmp/ccls"
				\ 		}
				\ 	}
				\ }
				\})
elseif executable('clangd')
	call coc#config('languageserver', {
				\ "clangd": {
				\ 	"command": "clangd",
				\ 	"rootPatterns": ["compile_flags.txt", "compile_commands.json"],
				\ 	"filetypes": ["c", "cc", "cpp", "c++", "objc", "objcpp"]
				\ }
				\})
endif
