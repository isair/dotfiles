"
" NeoBundle
"
if !1 | finish | endif

if has('vim_starting')
  set nocompatible
  set runtimepath+=~/.vim/bundle/neobundle.vim/
endif

call neobundle#begin(expand('~/vim/bundle/'))

NeoBundleFetch 'Shougo/neobundle.vim'

NeoBundle 'vim-ruby/vim-ruby'
NeoBundle 'airblade/vim-gitgutter'
NeoBundle 'haya14busa/incsearch.vim'
NeoBundle 'scrooloose/syntastic' " Compiler/interpreter error/warning display
NeoBundle 'bling/vim-airline' " Better tabs
NeoBundle 'tpope/vim-fugitive' " Use Git from Vim
NeoBundle 'guns/ultisnips' " Code snippets
NeoBundle 'ngmy/vim-rubocop'
call neobundle#end()

filetype plugin indent on
NeoBundleCheck

"
" Clang stuff
"

" Disable auto completion, always <c-x> <c-o> to complete
let g:clang_complete_auto = 0 
let g:clang_use_library = 1
let g:clang_periodic_quickfix = 0
let g:clang_close_preview = 1

" For Objective-C, this needs to be active, otherwise multi-parameter
" methods won't be completed correctly
let g:clang_snippets = 1

" Snipmate does not work anymore, ultisnips is the recommended plugin
let g:clang_snippets_engine = 'ultisnips'
				
" This might change depending on your installation
let g:clang_exec = '/usr/local/bin/clang'
let g:clang_library_path = '/usr/local/lib/libclang.dylib'

"
" Non-Plugin stuff
"
autocmd FileType c,cpp,java,php,py,txt autocmd BufWritePre <buffer> :%s/\s\+$//e

" Show line numbers
set nu

" Clean trailing whitespace characters in code files
autocmd FileType c,cpp,java,php,swift,js,css autocmd BufWritePre <buffer> :%s/\s\+$//e

" Set color scheme to Solarized
syntax enable
set background=dark
colorscheme solarized

