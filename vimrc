scriptencoding utf-8

"------------------------------------------------------------------------------
" Personal Vim settings file
"------------------------------------------------------------------------------

set nocompatible
filetype off

call plug#begin('~/.vim/bundle')
" List of plugins
" utils
Plug 'kien/ctrlp.vim'
Plug 'tpope/vim-repeat'
Plug 'tomtom/tlib_vim'
Plug 'MarcWeber/vim-addon-mw-utils'
Plug 'garbas/vim-snipmate'
Plug 'christoomey/vim-tmux-navigator'
Plug 'neomake/neomake'
Plug 'scrooloose/nerdtree'
Plug 'bling/vim-airline'
" Git helpers
Plug 'tpope/vim-fugitive'
Plug 'airblade/vim-gitgutter'
Plug 'Xuyuanp/nerdtree-git-plugin'
call plug#end()

filetype on
filetype plugin on
filetype indent on

let g:SuperTabDefaultCompletionType = "context"
let g:SuperTabContextDefaultCompletionType = "<c-n>"

"
"-----------------------------------------------------------------------
" terminal setup
"-----------------------------------------------------------------------

" Extra terminal things
if (&term =~ "xterm") && (&termencoding == "")
    set termencoding=utf-8
endif

if &term =~ "xterm"
    " use xterm titles
    if has('title')
        set title
    endif

    " change cursor colour depending upon mode
    if exists('&t_SI')
        let &t_SI = "\<Esc>]12;lightgoldenrod\x7"
        let &t_EI = "\<Esc>]12;grey80\x7"
    endif
endif


"------------------------------------------------------------------------------
" Settings
"------------------------------------------------------------------------------

" Don't be compatible to Vi
set nocompatible

" Make backspace delete mostly everything
set backspace=indent,eol,start

" Show the command we're currently writing
set showcmd

" Highlight matching parens
set showmatch

" Wrap on these
set whichwrap+=<,>,[,]

" Update rate 250ms instead of 4sec, better for GitGutter
set updatetime=250

" Enable syntax highlighting
syntax on

" Set colorscheme used
" Try to load a nice colourscheme
if has("eval")
    fun! LoadColourScheme(schemes)
        let l:schemes = a:schemes . ":"
        while l:schemes != ""
            let l:scheme = strpart(l:schemes, 0, stridx(l:schemes, ":"))
            let l:schemes = strpart(l:schemes, stridx(l:schemes, ":") + 1)
            try
                exec "colorscheme" l:scheme
                break
            catch
            endtry
        endwhile
    endfun

    if has('gui')
        call LoadColourScheme("inkpot:night:rainbow_night:darkblue:elflord")
    else
        if has("autocmd")
            autocmd VimEnter *
                        \ if &t_Co == 88 || &t_Co == 256 |
                        \     call LoadColourScheme("inkpot:darkblue:elflord") |
                        \ else |
                        \     call LoadColourScheme("darkblue:elflord") |
                        \ endif
        else
            if &t_Co == 88 || &t_Co == 256
                call LoadColourScheme("inkpot:darkblue:elflord")
            else
                call LoadColourScheme("darkblue:elflord")
            endif
        endif
    endif
endif

"colorscheme inkpot
"colorscheme mydesert

" 1 height windows
set winminheight=1

" tabstop
set tabstop=8
set shiftwidth=8
set noexpandtab

" Nice window title
if has('title') && (has('gui_running') || &title)
    set titlestring=
    set titlestring+=%f\                                              " file name
    set titlestring+=%h%m%r%w                                         " flags
    set titlestring+=\ -\ %{v:progname}                               " program name
    set titlestring+=\ -\ %{substitute(getcwd(),\ $HOME,\ '~',\ '')}  " working directory
endif

" Include $HOME in cdpath
if has("file_in_path")
    let &cdpath=','.expand("$HOME").','.expand("$HOME").'/work'
endif


" Show tabs and trailing whitespace visually
"if v:version >= 700
"	set list listchars=tab:>-,trail:.,extends:>,nbsp:_
"else
"	set list listchars=tab:>-,trail:.,extends:>
"endif
if (&termencoding == "utf-8") || has("gui_running")
    if v:version >= 700
        if has("gui_running")
            set list listchars=tab:»·,trail:·,extends:…,nbsp:‗
        else
            " xterm + terminus hates these
            set list listchars=tab:»·,trail:·,extends:>,nbsp:_
        endif
    else
        set list listchars=tab:»·,trail:·,extends:…
    endif
else
    if v:version >= 700
        set list listchars=tab:>-,trail:.,extends:>,nbsp:_
    else
        set list listchars=tab:>-,trail:.,extends:>
    endif
endif

set fillchars=fold:-

" If possible, try to use a narrow number column.
if v:version >= 700
    try
        setlocal numberwidth=4
    catch
    endtry
endif

" Filter expected errors from make
if has("eval") && v:version >= 700
    if hostname() == "sestord14"
        let &makeprg="nice -n7 clearmake 2>&1"
    elseif hostname() == "sestord32"
        let &makeprg="nice -n7 clearmake 2>&1"
    else
        let &makeprg="nice -n7 make -j2 2>&1"
    endif

    " ignore libtool links with version-info
    let &errorformat="%-G%.%#libtool%.%#version-info%.%#,".&errorformat

    " ignore doxygen things
    let &errorformat="%-G%.%#Warning: %.%# is not documented.,".&errorformat
    let &errorformat="%-G%.%#Warning: no uniquely matching class member found for%.%#,".&errorformat
    let &errorformat="%-G%.%#Warning: documented function%.%#was not declared or defined.%.%#,".&errorformat

    " paludis things
    let &errorformat="%-G%.%#test_cases::FailTest::run()%.%#,".&errorformat
    let &errorformat="%-G%.%#%\\w%\\+/%\\w%\\+-%[a-zA-Z0-9.%\\-_]%\\+:%\\w%\\+::%\\w%\\+%.%#,".&errorformat
    let &errorformat="%-G%.%#Writing VDB entry to%.%#,".&errorformat
    let &errorformat="%-G%\\(install%\\|upgrade%\\)_TEST> %.%#,".&errorformat

    " catch internal errors
    let &errorformat="%.%#Internal error at %.%# at %f:%l: %m,".&errorformat
endif

"-----------------------------------------------------------------------
" completion
"-----------------------------------------------------------------------
"set dictionary=/usr/share/dict/words

" NeoMake
autocmd! BufWritePost * Neomake
" NerdTree
"autocmd vimenter * NERDTree
autocmd StdinReadPre * let s:std_in=1
autocmd VimEnter * if argc() == 0 && !exists("s:std_in") | NERDTree | endif
autocmd bufenter * if (winnr("$") == 1 && exists("b:NERDTree") && b:NERDTree.isTabTree()) | q | endif
map <C-n> :NERDTreeToggle<CR>

" Nice statusbar
set laststatus=2
set statusline=
set statusline+=%2*%-3.3n%0*\                " buffer number
set statusline+=%f\                          " file name
if has("eval")
    let g:scm_cache = {}
    fun! ScmInfo()
        let l:key = getcwd()
        if ! has_key(g:scm_cache, l:key)
            if (isdirectory(getcwd() . "/.git"))
                let g:scm_cache[l:key] = "[" . substitute(readfile(getcwd() . "/.git/HEAD", "", 1)[0],
                            \ "^.*/", "", "") . "] "
            else
                let g:scm_cache[l:key] = ""
            endif
        endif
        return g:scm_cache[l:key]
    endfun
    set statusline+=%{ScmInfo()}             " scm info
endif
set statusline+=%h%1*%m%r%w%0*               " flags
set statusline+=\[%{strlen(&ft)?&ft:'none'}, " filetype
set statusline+=enc:%{&encoding},            " encoding
set statusline+=fenc:%{&fileencoding},       " fileencoding
set statusline+=%{&fileformat}]              " file format
if filereadable(expand("$VIM/vimfiles/plugin/vimbuddy.vim"))
    set statusline+=\ %{VimBuddy()}          " vim buddy
endif
set statusline+=%=                           " right align
set statusline+=%2*0x%-8B\                   " current char
set statusline+=%-14.(%l,%c%V%)\ %<%P        " offset

" Search down into subfolders
" Provide tab-completion for all file-related tasks
set path+=**

set wildmenu
set wildignore+=*.o,*~,.lo
set suffixes+=.in,.a,.1

" Syntax when printing
set popt+=syntax:y

" Enable folds
if has("folding")
    set foldenable
    set foldmethod=indent
    set foldlevelstart=99
endif

" More reasonable syntax highlighting for .h files
let c_syntax_for_h = 1

" Change which character is used for <MapLead> in keybindings
let mapleader = ","

" No freakin' menus, scrollbars or buttons in GUI
set guioptions-=m
set guioptions-=T
set guioptions-=l
set guioptions-=L
set guioptions-=r
set guioptions-=R

" Set nice font when in GUI
set guifont=Terminus\ 12,\ Bitstream\ Vera\ Sans\ Mono\ 10,\ Monospace\ 12

" Enable filetype settings
if has("eval")
    filetype on
    filetype indent on
    filetype plugin on
endif

" Securemodelines verbose setting
let g:secure_modelines_verbose = 0

" Make right mouse button extend selection when pressed
set mousemodel=extend

" Show full tags when doing search completion
set showfulltag

" Speed up macros
set lazyredraw

" No annoying error noises
set noerrorbells
set visualbell t_vb=
if has("autocmd")
    autocmd GUIEnter * set visualbell t_vb=
endif

" Command-line uses two screen lines
set cmdheight=2

" Do clever indent things. Don't make a # force column zero.
set autoindent
set smartindent
inoremap # X<BS>#

set isprint=@,128-255	" Print extended chars on screen
set so=3		" Keep cursor in center of screen

set history=50
set ruler

set incsearch
set ignorecase
set smartcase
set infercase
set hlsearch

"------------------------------------------------------------------------------
" Keymappings
"------------------------------------------------------------------------------

" Indent entire file
fun IndentFile()
    let oldLine=line('.')
    normal(gg=G)
    execute ':' . oldLine
endfun

nnoremap <silent> <F8> :Tlist<CR>
nnoremap <silent> n nzz
nnoremap <silent> N Nzz
nnoremap <silent> * *zz
nnoremap <silent> # #zz

map -- :call IndentFile()<cr>

" Don't deselect visual selection when indenting
vnoremap < <gv
vnoremap > >gv

" Make Shift-[JK] behave like Page(Up|Down)
noremap <S-J> <PageDown>
noremap <S-K> <PageUp>

" Buffer navigation
map <C-H> :bp<CR>
map <C-L> :bn<CR>
map! <C-H> :bp<CR>
map! <C-L> :bn<CR>

" Navigate splits
let g:tmux_navigator_no_mappings = 1
nnoremap <silent> <C-h> :TmuxNavigateLeft<cr>
nnoremap <silent> <C-j> :TmuxNavigateDown<cr>
nnoremap <silent> <C-k> :TmuxNavigateUp<cr>
nnoremap <silent> <C-l> :TmuxNavigateRight<cr>

imap <C-h> <C-o>h
imap <C-j> <C-o>j
imap <C-k> <C-o>k
imap <C-l> <C-o>l

" q: sucks
nmap q: :q

" Split the line
nmap <Leader>n \i<CR>

"------------------------------------------------------------------------------
" autocmds
"------------------------------------------------------------------------------


if has("eval")
    " Work out include guard text
    fun! IncludeGuardText()
        let l:p = substitute(substitute(getcwd(), "/trunk", "", ""), '^.*/', "", "")
        let l:t = substitute(expand("%"), "[./]", "_", "g")
        return substitute(toupper("_GUARD_" . l:t), "-", "_", "g")
    endfun

    " Make include guards
    fun! MakeIncludeGuards()
        norm gg
        /^$/
        norm 2O
        call setline(line("."), "#ifndef " . IncludeGuardText())
        norm o
        call setline(line("."), "#define " . IncludeGuardText() . " 1")
        norm o
        norm G
        norm O
        call setline(line("."), "#endif")
    endfun
    noremap <Leader>ig :call MakeIncludeGuards()<CR>

    " Make include guards
    fun! MakeModeLineC()
        norm G
        norm o
        call setline(line("."), '/* vim: set sw=4 sts=4 et foldmethod=syntax : */')
    endfun
    noremap <Leader>im :call MakeModeLineC()<CR>

    " Linenumbers if size is right...
    fun! <SID>WindowWidth()
        setlocal number
        setlocal relativenumber
    endfun

    function HasteUpload() range
        echo system('echo '.shellescape(join(getline(a:firstline, a:lastline), "\n")).'| haste | xsel -ib')
    endfunction

    function! FixLastSpellingError()
        normal! mm[s1z=`m
    endfunction
    nnoremap <leader>sp :call FixLastSpellingError()<CR>

    function! CommitMessages()
        let g:git_ci_msg_user = substitute(system("git config --get user.name"), '\n$', '', '')
        let g:git_ci_msg_email = substitute(system("git config --get user.email"), '\n$', '', '')

        nmap D oSigned-off-by: <C-R>=printf("%s <%s>", g:git_ci_msg_user, g:git_ci_msg_email)<CR><CR><ESC>
        nmap R oReviewed-by: <C-R>=printf("%s <%s>", g:git_ci_msg_user, g:git_ci_msg_email)<CR><ESC>
        nmap T oReviewed-and-Tested-by: <C-R>=printf("%s <%s>", g:git_ci_msg_user, g:git_ci_msg_email)<CR><ESC>
        nmap F oAcked-by: <C-R>=printf("%s <%s>", g:git_ci_msg_user, g:git_ci_msg_email)<CR><ESC>
        iab #D Signed-off-by: <C-R>=printf("%s <%s>", g:git_ci_msg_user, g:git_ci_msg_email)<CR>
        iab #R Reviewed-by: <C-R>=printf("%s <%s>", g:git_ci_msg_user, g:git_ci_msg_email)<CR>
        iab #T Reviewed-and-Tested-by: <C-R>=printf("%s <%s>", g:git_ci_msg_user, g:git_ci_msg_email)<CR>
        iab #F Acked-by: <C-R>=printf("%s <%s>", g:git_ci_msg_user, g:git_ci_msg_email)<CR>
    endf
    autocmd BufWinEnter COMMIT_EDITMSG,*.diff,*.patch,*.patches.txt,mutt* call CommitMessages()


    " Force active window to the top of the screen without losing its
    " size.
    fun! <SID>WindowToTop()
        let l:h=winheight(0)
        wincmd K
        execute "resize" l:h
    endfun

    map <F2> :call TrimWhiteSpace()<CR>
    map! <F2> :call TrimWhiteSpace()<CR>

    " Removes trailing spaces
    function TrimWhiteSpace()
        %s/\s*$//
        ''
    :endfunction

endif

"-----------------------------------------------------------------------
" autocmds
"-----------------------------------------------------------------------

"autocmd BufWritePre * :%s/\s\+$//e

" content creation
if has("autocmd")
    augroup content
        autocmd!

        autocmd InsertLeave * set nopaste
        autocmd VimResized * exe "normal! \<c-w>="
        "autocmd BufRead,BufNewFile  *.c,*.h,*.asm,*.S,*.s,*.lnk,*.bb,*.bbappend setlocal expandtab ts=4 sts=4 sw=4
        autocmd BufRead,BufNewFile  *.txt setlocal expandtab ts=8 sts=8 sw=8
        autocmd BufRead,BufNewFile  Makefile,*.mk setlocal noexpandtab ts=8 sts=8 sw=8
        autocmd BufRead,BufNewFile  *.pcon setlocal ts=4 noexpandtab sts=4 sw=4
        autocmd BufRead,BufNewFile  *.yaml setlocal ts=4 expandtab sts=4 sw=4

        autocmd BufNewFile *.py 0put ='# vim: set ts=8 sw=4 sts=4 et tw=80 fileencoding=utf-8 :' |
                    \ 0put ='#!/usr/bin/python' | set sw=4 sts=4 et tw=80 fenc=utf-8|
                    \ norm G

        autocmd BufNewFile *.h,*.hh call MakeIncludeGuards() | $put ='' |
                    \ call MakeModeLineC() |
                    \ set sw=4 sts=4 et tw=80 | norm G

        autocmd BufNewFile *.c call setline(1, '#include "' .
                    \ substitute(expand("%:t"), ".c$", ".h", "") . '"') |
                    \ $put ='' |
                    \ call MakeModeLineC() |
                    \ set ts=8 sw=8 sts=8 noet tw=80 | norm G

        autocmd BufNewFile *.cc call setline(1, '#include "' .
                    \ substitute(expand("%:t"), ".cc$", ".hh", "") . '"') |
                    \ $put ='' |
                    \ call MakeModeLineC() |
                    \ set sw=4 sts=4 et tw=80 | norm G

        "        autocmd BufNewFile *.c call setline(1, '#include "' .
        "                    \ substitute(expand("%:t"), ".c$", ".h", "") . '"') |
        "                    \ $put ='' |
        "                    \ $put ='/* vim: set sw=4 sts=4 et foldmethod=syntax : */' |
        "                    \ set sw=4 sts=4 et tw=80 | norm G

    augroup END
endif

if has("autocmd") && has("eval")
    augroup roxell
        autocmd!

        " When entering a buffer; show linenumbers if size is right
        autocmd BufEnter * :call <SID>WindowWidth()

        " Always do a full syntax refresh
        autocmd BufEnter * syntax sync fromstart

        " For help files, move them to the top window and make <Return>
        " behave like <C-]> (jump to tag)
        autocmd FileType help :call <SID>WindowToTop()
        autocmd FileType help nmap <buffer> <Return> <C-]>

        " Arduino-thingies
        autocmd BufRead *.pde :set filetype=c

        " Poky-thingies
        autocmd BufRead *.bbclass :set filetype=python

        " Detect procmailrc
        autocmd BufRead *procmailrc :set filetype=procmail
        autocmd BufRead *tex :set filetype=tex

        " Ehm.....
        autocmd BufRead *.txt setlocal linebreak

    augroup END
endif

"------------------------------------------------------------------------------
" Script / Plugin settings
"------------------------------------------------------------------------------

" Spell checker settings
"let spell_root_menu  = '-'
"let spell_auto_type  = "tex,mail,html,cvs"
"let spell_insert_mode  = 0
""let spell_language_list  = "svenska,english,british"
""let vimspell_default_language  = "british"
"let spellling="en_gb"
"set spell

set tags=tags,TAGS;/

" Settings minibufexpl.vim
let g:miniBufExplModSelTarget = 1
let g:miniBufExplWinFixHeight = 1
"let g:miniBufExplMapWindowNavVim = 1
"let g:miniBufExplMapWindowNavArrows = 1
"let g:miniBufExplMapCTabSwitchBuffs = 1
"let g:miniBufExplForceSyntaxEnable = 1


"------------------------------------------------------------------------------
" Final commands
"------------------------------------------------------------------------------

command! MakeTags !ctags -R .

" Don't highlight searches when just having entered Vim
au VimEnter * nohls

"-----------------------------------------------------------------------
" vim: set shiftwidth=4 softtabstop=4 expandtab tw=120                 :
