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

NeoBundle 'scrooloose/nerdtree' " File system navigation inside vim, :NERDTree
NeoBundle 'sheerun/vim-polyglot' " Syntax and indentation for all
NeoBundle 'tokorom/xcode-actions.vim' " Control Xcode without leaving vim, :XcodeAction...
NeoBundle 'brow/vim-xctool' " xctool from vim. Define a JSON array of command line arguments in .xctool-args, use with :make
NeoBundle 'ngmy/vim-rubocop' " Ruby code quality checking, :RuboCop
NeoBundle 'motemen/git-vim' " Git commands from vim, but I mainly use it for my custom status line 
NeoBundle 'airblade/vim-gitgutter' " Show git diff in sign column
NeoBundle 'haya14busa/incsearch.vim'
NeoBundle 'scrooloose/syntastic' " Compiler/interpreter error/warning display
NeoBundle 'bling/vim-airline' " Better tabs
NeoBundle 'ervandew/supertab' " Insert mode completions with tab key
NeoBundle 'guns/ultisnips' " Code snippets
NeoBundle 'tpope/vim-endwise' " Automatically end code blocks in some languages
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

" Show line numbers
set nu

" Clean trailing whitespace characters in code and text files
autocmd FileType txt,c,cpp,java,php,swift,js,css,py,rb,feature autocmd BufWritePre <buffer> :%s/\s\+$//e

" Indentation configuration
set expandtab
set shiftwidth=2
set softtabstop=2

" Ctrl + C for deleting buffer without closing split
nnoremap <C-c> :bp\|bd #<CR>

" \x where x is a number to move to window #x
let i = 1
while i <= 9
  execute 'nnoremap <Leader>' . i . ' :' . i . 'wincmd w<CR>'
  let i = i + 1
endwhile

" Set colors
syntax enable
set background=dark
colorscheme default

" Fix for gitgutter
highlight clear SignColumn
