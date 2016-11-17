set nocompatible

" vim-plug

call plug#begin('~/.vim/plugged')

Plug 'tpope/vim-sensible' " Sensible defaults
Plug 'altercation/vim-colors-solarized'
Plug 'scrooloose/nerdtree' " File system navigation inside vim, :NERDTree
Plug 'kien/ctrlp.vim' " Fuzzy file finder
Plug 'jeetsukumaran/vim-buffergator' " Better buffer management
Plug 'sheerun/vim-polyglot' " Syntax and indentation for all
Plug 'tokorom/xcode-actions.vim' " Control Xcode without leaving vim, :XcodeAction...
Plug 'brow/vim-xctool' " xctool from vim. Define a JSON array of command line arguments in .xctool-args, use with :make
Plug 'motemen/git-vim' " Git commands from vim, but I mainly use it for my custom status line
Plug 'airblade/vim-gitgutter' " Show git diff in sign column
Plug 'haya14busa/incsearch.vim'
Plug 'scrooloose/syntastic' " Compiler/interpreter error/warning display
Plug 'bling/vim-airline' " Better tabs
Plug 'ervandew/supertab' " Insert mode completions with tab key
Plug 'tpope/vim-endwise' " Automatically end code blocks in some languages
Plug 'rizzatti/dash.vim' " Dash (code docs) support
Plug 'wkentaro/conque.vim' " shell inside vim buffer

call plug#end()

" CtrlP setup
let g:ctrlp_custom_ignore = {
  \ 'dir':  '\v[\/](\.(git|hg|svn)|\_site)$',
  \ 'file': '\v\.(exe|so|dll|class|png|jpg|jpeg)$',
\}
let g:ctrlp_working_path_mode = 'r'

nmap <leader>p :CtrlP<cr>
nmap <leader>bb :CtrlPBuffer<cr>
nmap <leader>bm :CtrlPMixed<cr>
nmap <leader>bs :CtrlPMRU<cr>

" Buffergator setup
let g:buffergator_viewport_split_policy = 'R'
let g:buffergator_suppress_keymaps = 1

nmap <leader>jj :BuffergatorMruCyclePrev<cr>
nmap <leader>kk :BuffergatorMruCycleNext<cr>
nmap <leader>bl :BuffergatorOpen<cr>

" Syntastic setup
function! StrTrim(txt)
  return substitute(a:txt, '^\n*\s*\(.\{-}\)\n*\s*$', '\1', '')
endfunction

let g:syntastic_javascript_eslint_exec = StrTrim(system('npm-which eslint'))
let g:syntastic_javascript_checkers = ['eslint']

set statusline+=%#warningmsg#
set statusline+=%{SyntasticStatuslineFlag()}
set statusline+=%*

let g:syntastic_always_populate_loc_list = 1
let g:syntastic_auto_loc_list = 1
let g:syntastic_check_on_open = 1
let g:syntastic_check_on_wq = 0

" Airline setup
let g:airline#extensions#tabline#enabled = 1
let g:airline#extensions#tabline#fnamemod = ':t'

" \d to search word under cursor in Dash
nmap <silent> <leader>d <Plug>DashSearch

" Show relative line numbers
set relativenumber

" Clean trailing whitespace characters in code and text files
autocmd FileType txt,c,h,m,mm,cpp,java,php,swift,js,json,css,py,rb,feature autocmd BufWritePre <buffer> :%s/\s\+$//e

" Indentation configuration
set expandtab
set shiftwidth=2
set softtabstop=2

" Allow modified buffers to be hidden
set hidden

" Ctrl + C for deleting buffer without closing split
nnoremap <C-c> :bp\|bd #<CR>

" \t for opening a new buffer
nmap <leader>t :enew<cr>

" Ctrl + S to open sidebar (NERDTree)
nnoremap <C-s> :NERDTree<CR>

" \x where x is a number to move to window #x
let i = 1
while i <= 9
  execute 'nnoremap <Leader>' . i . ' :' . i . 'wincmd w<CR>'
  let i = i + 1
endwhile

" Set colors
let g:solarized_termcolors=256
syntax enable
set background=dark
colorscheme solarized

" MacVim
set guifont=Monaco:h13

" Fix for gitgutter
highlight clear SignColumn

" Highlight background of lines longer than 80 characters
highlight OverLength ctermbg=darkred ctermfg=white guibg=#592929
match OverLength /\%>80v.\+/

" Don't expand tabs for Makefile
autocmd FileType make setlocal noexpandtab

" eclim + supertab
let g:SuperTabDefaultCompletionType = 'context'
