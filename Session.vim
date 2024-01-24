let SessionLoad = 1
if &cp | set nocp | endif
let s:so_save = &g:so | let s:siso_save = &g:siso | setg so=0 siso=0 | setl so=-1 siso=-1
let v:this_session=expand("<sfile>:p")
silent only
silent tabonly
cd ~/.fgfs/Aircraft/A320-family
if expand('%') == '' && !&modified && line('$') <= 1 && getline(1) == ''
  let s:wipebuf = bufnr('%')
endif
let s:shortmess_save = &shortmess
if &shortmess =~ 'A'
  set shortmess=aoOA
else
  set shortmess=aoO
endif
badd +228 Nasal/FMGC/FCU.nas
badd +84 Nasal/FMGC/FMGC-b.nas
badd +3201 Models/FlightDeck/a320.flightdeck.xml
badd +1059 Nasal/FMGC/FMGC.nas
badd +784 A320-main.xml
argglobal
%argdel
edit Nasal/FMGC/FCU.nas
let s:save_splitbelow = &splitbelow
let s:save_splitright = &splitright
set splitbelow splitright
wincmd _ | wincmd |
vsplit
1wincmd h
wincmd w
let &splitbelow = s:save_splitbelow
let &splitright = s:save_splitright
wincmd t
let s:save_winminheight = &winminheight
let s:save_winminwidth = &winminwidth
set winminheight=0
set winheight=1
set winminwidth=0
set winwidth=1
exe 'vert 1resize ' . ((&columns * 159 + 159) / 319)
exe 'vert 2resize ' . ((&columns * 159 + 159) / 319)
argglobal
balt A320-main.xml
setlocal fdm=marker
setlocal fde=0
setlocal fmr={{{,}}}
setlocal fdi=#
setlocal fdl=0
setlocal fml=1
setlocal fdn=20
setlocal fen
let s:l = 228 - ((29 * winheight(0) + 28) / 57)
if s:l < 1 | let s:l = 1 | endif
keepjumps exe s:l
normal! zt
keepjumps 228
normal! 026|
wincmd w
argglobal
if bufexists(fnamemodify("Nasal/FMGC/FCU.nas", ":p")) | buffer Nasal/FMGC/FCU.nas | else | edit Nasal/FMGC/FCU.nas | endif
balt Nasal/FMGC/FMGC.nas
setlocal fdm=indent
setlocal fde=0
setlocal fmr={{{,}}}
setlocal fdi=#
setlocal fdl=0
setlocal fml=1
setlocal fdn=20
setlocal fen
21
normal! zo
25
normal! zo
32
normal! zo
34
normal! zo
35
normal! zo
38
normal! zo
43
normal! zo
46
normal! zo
21
normal! zc
51
normal! zo
228
normal! zo
229
normal! zo
230
normal! zo
let s:l = 231 - ((121 * winheight(0) + 28) / 57)
if s:l < 1 | let s:l = 1 | endif
keepjumps exe s:l
normal! zt
keepjumps 231
normal! 013|
wincmd w
2wincmd w
exe 'vert 1resize ' . ((&columns * 159 + 159) / 319)
exe 'vert 2resize ' . ((&columns * 159 + 159) / 319)
tabnext 1
if exists('s:wipebuf') && len(win_findbuf(s:wipebuf)) == 0
  silent exe 'bwipe ' . s:wipebuf
endif
unlet! s:wipebuf
set winheight=1 winwidth=20
let &shortmess = s:shortmess_save
let &winminheight = s:save_winminheight
let &winminwidth = s:save_winminwidth
let s:sx = expand("<sfile>:p:r")."x.vim"
if filereadable(s:sx)
  exe "source " . fnameescape(s:sx)
endif
let &g:so = s:so_save | let &g:siso = s:siso_save
doautoall SessionLoadPost
unlet SessionLoad
" vim: set ft=vim :
