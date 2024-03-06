set nocompatible              " be iMproved, required
filetype off                  " required

" set the runtime path to include Vundle and initialize
set rtp+=~/.vim/bundle/Vundle.vim
call vundle#begin()

Plugin 'VundleVim/Vundle.vim'
Plugin 'tpope/vim-fugitive'
Plugin 'airblade/vim-gitgutter'
Plugin 'vim-airline/vim-airline'
Plugin 'pangloss/vim-javascript'
Plugin 'bronson/vim-trailing-whitespace'
Plugin 'morhetz/gruvbox'
Plugin 'lstwn/broot.vim'
Plugin 'christoomey/vim-tmux-navigator'
Plugin 'tpope/vim-surround'
Plugin 'vim-syntastic/syntastic'

call vundle#end()            " required
filetype plugin indent on    " required

" ***** vim-airline *****
let g:airline#extensions#tabline#enabled = 1 " enable buffer tabls at the top of the window
let g:airline#extensions#tabline#buffer_nr_show = 1 " show buffer number in the top tabs

" ***** gruvbox *****
autocmd vimenter * ++nested colorscheme gruvbox

" ***** vim-javascript *****
let g:javascript_plugin_jsdoc = 1 " Enable syntax highlighting for JSDoc blocks

" ***** broot *****
let g:broot_default_conf_path = expand('~/.config/broot/conf.hjson')
let g:broot_replace_netrw = 1 " use broot instead of vim file browser (netrw)
let g:loaded_netrwPlugin = 1
nnoremap <silent> <leader>e :BrootWorkingDir<CR>
nnoremap <silent> - :BrootCurrentDir<CR>

" ***** Syntastic *****
set statusline+=%#warningmsg#
set statusline+=%{SyntasticStatuslineFlag()}
set statusline+=%*

let g:syntastic_always_populate_loc_list = 1
let g:syntastic_auto_loc_list = 0 " don't automatically show location list
let g:syntastic_check_on_open = 1 " check for errors when opening a file
let g:syntastic_check_on_wq = 0 " don't check errors when doing write-quit
let g:syntastic_javascript_checkers = [ 'eslint' ]
let g:syntastic_javascript_eslint_generic = 1
let g:syntastic_javascript_eslint_exec = '/bin/ls' " temporary ensure eslint check is available
let g:syntastic_javascript_eslint_exe = '' " use bin dir for current project
let g:syntastic_javascript_eslint_args = '-f compact' " ensure eslint output format is correct for syntactic

" ***** General settings *****

set number " always show line numbers
set nowrap " do not wrap long lines
set laststatus=2   " Always show the statusline
set tabstop=4
set softtabstop=0
set expandtab
set shiftwidth=4
"set smarttab
set smartindent
set shell=/bin/zsh
set incsearch " Show search result while typing
set hlsearch " Highlight search results
set background=dark

syntax enable

" double j will return to normal mode from visual mode
imap jj <Esc>
