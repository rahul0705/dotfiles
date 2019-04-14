" ========================================
" Vim plugin configuration
" ========================================
"
" This file contains the list of plugin installed using vundle plugin manager.
" Once you've updated the list of plugin, you can run vundle update by issuing
" the command :BundleInstall from within vim or directly invoking it from the
" command line with the following syntax:
" vim --noplugin -u vim/vundles.vim -N "+set hidden" "+syntax on" +BundleClean! +BundleInstall +qall
" Filetype off is required by vundle
filetype off

set rtp+=~/.vim/bundle/Vundle.vim
call vundle#begin()

" let Vundle manage Vundle (required)
Bundle 'VundleVim/Vundle.vim'

" Vim Theme
Plugin 'chriskempson/base16-vim'

" Vim status line
Plugin 'vim-airline/vim-airline'
Plugin 'vim-airline/vim-airline-themes'

" Git integrations
Plugin 'tpope/vim-fugitive'
Plugin 'mhinz/vim-signify'

" Personal Wiki
Plugin 'vimwiki/vimwiki'

" Utility
Plugin 'andreshazard/vim-logreview'
Plugin 'godlygeek/tabular'
Plugin 'plasticboy/vim-markdown'
Plugin 'ntpeters/vim-better-whitespace'
Plugin 'scrooloose/nerdcommenter'
Plugin 'jeffkreeftmeijer/vim-numbertoggle'
Plugin 'nathanaelkane/vim-indent-guides'
Plugin 'scrooloose/syntastic'
Plugin 'pearofducks/ansible-vim'
Plugin 'edkolev/tmuxline.vim'

call vundle#end()

" Filetype plugin indent on is required by vundle
filetype plugin indent on
