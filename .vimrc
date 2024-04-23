set nocompatible              " be iMproved, required
filetype off                  " required

" set the runtime path to include Vundle and initialize
set rtp+=~/.vim/bundle/Vundle.vim
call vundle#begin()

Plugin 'VundleVim/Vundle.vim'
Plugin 'tpope/vim-fugitive'
Plugin 'airblade/vim-gitgutter' " adds deleted, added, modified indicators for each line in the left gutter
Plugin 'vim-airline/vim-airline' " nice looking status bar with useful information
Plugin 'vim-airline/vim-airline-themes' " set of themes for airline
Plugin 'pangloss/vim-javascript' " adds support for various JavaScript related features
Plugin 'bronson/vim-trailing-whitespace' " highlights trailing whitespace in files
Plugin 'morhetz/gruvbox' " color theme
Plugin 'lstwn/broot.vim' " adds support for using Broot as a file navigator in vim
Plugin 'christoomey/vim-tmux-navigator' " allow for better tmux integration
Plugin 'tpope/vim-surround'
Plugin 'vim-syntastic/syntastic'

call vundle#end()            " required
filetype plugin indent on    " required

" ***** vim-airline *****
let g:airline#extensions#tabline#enabled = 1 " enable buffer tabs at the top of the window
let g:airline#extensions#tabline#buffer_nr_show = 1 " show buffer number in the top tabs
let g:airline#extensions#tabline#formatter = 'unique_tail_improved' " change how buffer names are formatted
let g:airline_powerline_fonts = 1 " automatically populate the g:airline_symbols dictionary with the powerline symbols
let g:airline_theme='base16_gruvbox_dark_hard'

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
let g:syntastic_javascript_eslint_exec = '/bin/ls' " temporary ensure eslint checker is available
let g:syntastic_javascript_eslint_exe = '$(yarn bin)/eslint' " use bin in current project
let g:syntastic_javascript_eslint_args = '-f compact' " ensure format is correct for Syntactic

" ***** General Config *****
set number " always show line numbers
set nowrap " do not wrap long lines
set laststatus=2 " always show the statusline
set tabstop=4 " number of spaces a tab character will render as
set softtabstop=0
set expandtab " use spaces when pressing the tab key
set shiftwidth=4
set smartindent " automatically indent C-like programs
set shell=/bin/zsh
set incsearch " show search results while typing
set hlsearch " highlight search results
set background=dark
set tags=.tags

syntax enable

" ***** Key Bindings *****
imap jj <Esc> " double j will return to normal mode from insert mode

" ***** Spell Checking *****
augroup spellCheckingByFileType
    autocmd!
    autocmd ColorScheme gruvbox hi SpellBad ctermfg=red
    autocmd FileType md,markdown setlocal spell spelllang=en_us
    autocmd BufRead,BufNewFile *.md,COMMIT_EDITMSG setlocal spell spelllang=en_us
augroup END
