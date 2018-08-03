" ================ Vimwiki ===========================

set nocompatible    " Use Vim settings, rather then Vi settings
syntax on           " Turn on syntax highlighting
filetype plugin on  " Enable loading the plugin files for specific file types

" Create a single Wiki in ~/vimwiki/ and use markdown syntax and .md extensions
let g:vimwiki_list = [{'path': '~/vimwiki/', 'syntax': 'markdown', 'ext': '.md'}]
