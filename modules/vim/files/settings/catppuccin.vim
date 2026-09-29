set termguicolors

if !empty(globpath(&runtimepath, 'colors/catppuccin_mocha.vim'))
    colorscheme catppuccin_mocha
endif

let g:airline_theme = 'catppuccin_mocha'
