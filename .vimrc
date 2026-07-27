set viminfo='10,\"100,:20,%,n~/.viminfo
set visualbell				" Silence the bell, use a flash instead
set cinoptions=:.5s,>1s,p0,t0,(0,g2	" :.5s = indent case statements 1/2 shiftwidth
					" >1s = indent 1 shiftwidth
					" p0 = indent function definitions 0 spaces
					" t0 = indent function return type 0 spaces
					" (0 = indent from unclosed parantheses
					" g2 = indent C++ scope resolution 2 spaces

set cinwords=if,else,while,do,for,switch,case	
set formatoptions=tcq	" t=text, c=comments, q=format with "gq" 
set cindent				" indent on cinwords
set shiftwidth=4		" set shiftwidth to 4 spaces
set tabstop=4
set softtabstop=4
set autoindent
set number
filetype indent on
set modeline
set showmatch			" Show matching brackets/braces/parantheses.
"set background=dark 	" set background to dark
"set showcmd				" Show (partial) command in status line.
set autowrite			" Automatically save before commands like :next and :make
set autoindent
syntax on
map <F6>  :cn<CR>  
map <F7>  :cp<CR>  
map <F8>  :bn<CR>  
map <F5>  :make  
map <F4>  :Rex<CR>  
map <F3>  :grep <C-r><C-w> *<CR>  
map <F2>  =G<CR>  
map <F9>  :wq<CR>
set foldmethod=indent   "fold based on indent
set foldnestmax=10      "deepest fold is 10 levels
set nofoldenable        "dont fold by default
set foldlevel=1         "this is just what i use
"set wrap!
ab as- #author:sassiz
ab #a- #author: ------
ab im- import
ab if- if(){<CR>}
ab for- for(i=0; i<0; i++){<CR>}
ab while- while(){<CR>}
ab switch- switch(){<CR>case:<CR>break;<CR>default:;<CR>}
ab i- #include<> 
ab d- #define 
ab p- printf("\n");
ab cc- /* */
ab ccs- /*author:SASSIZ<CR>*Hack is the life!*/
ab r- return
ab fun- int function()<CR>{<CR>} 
ab all- #include<stdio.h><CR>int main()<CR>{<CR>printf("Hello World\n");<CR>} 
ab make- all:<CR>$(CC) -o %<CR>clean:<CR> 
"runtime! ftplugin/man.vim
let @c="a /*  */"
"hi Comment  term=bold ctermfg=DarkBlue guifg=#80a0ff gui=bold
"colo darkblue
function! ResCur()
	if line("'\"") <= line("$")
		normal! g`"
		return 1
	endif
endfunction

augroup resCur
	autocmd!
	autocmd BufWinEnter * call ResCur()
augroup END
