
require 'api/ncurses'
sleep =: 6!:3

l_tetrimino =. 2 3 $ 1 0 0 1 1 1
i_tetrimino =. 1 1 1 1
t_tetrimino =. 2 3 $ 0 1 0 1 1 1
b_tetrimino =. 2 2 $ 1 1 1 1 

drawGame=: 3 : 0
matrix =. >{.}.y
win =. >{.y
cols =. }. $ matrix
rows =. {. $ matrix
for_row. i.rows do.
  for_col. i.cols do.
     value =. (<row, col) { matrix
NB.smoutput value, row, col
     wattr_on_ncurses_ win;(COLOR_PAIR_ncurses_ (value+1));0
     mvwprintw_1_ncurses_ win; row; (2*col); (('  '))
  end.
end.
)
mainblock=: 3 : 0

l_tetrimino =. 2 3 $ 0 1 0 1 1 1
game =:  30 20 $ 0
NB.game =:  4 4 $ 0
noecho_ncurses_''.
vin =. initscr_ncurses_''
start_color_ncurses_''
init_pair_ncurses_ 1;COLOR_YELLOW_ncurses_;COLOR_RED_ncurses_
init_pair_ncurses_  2;COLOR_BLUE_ncurses_;COLOR_YELLOW_ncurses_
init_pair_ncurses_ 3;COLOR_BLUE_ncurses_;COLOR_WHITE_ncurses_
vin =. newwin_ncurses_ 12 40 0 0

cbreak_ncurses_''
nodelay_ncurses_ vin ;'1'
keypad_ncurses_ vin;'1'
scrollok_ncurses_ vin;'1'
k=:0
j=:1
while. 1 do.
game =: (,l_tetrimino) ((+&(k,j))&.> ( ,((i.2) (<@,"0)/  i.3)))} game
drawGame vin; game
NB. wmove_ncurses_ vin;k;j
wrefresh_ncurses_  vin
c=.wgetch_ncurses_ vin 
if. c = KEY_UP_ncurses_ do.
   game =: (,l_tetrimino*0) ((+&(k,j))&.> ( ,((i.2) (<@,"0)/  i.3)))} game
   k =. k + 1
elseif. c = KEY_RIGHT_ncurses_ do.
   game =: (,l_tetrimino*0) ((+&(k,j))&.> ( ,((i.2) (<@,"0)/  i.3)))} game
   j =. j + 1
elseif. 1 do. 
   NB.game =: (,l_tetrimino*0) ((+&(k,j))&.> ( ,((i.2) (<@,"0)/  i.3)))} game
   NB.k =. k + 1
end.
unget_wch_ncurses_ c
game =: (,l_tetrimino) ((+&(k,j))&.> ( ,((i.2) (<@,"0)/  i.3)))} game
sleep 0.4
end.
delwin_ncurses_  vin
endwin_ncurses_'' 
)

mainblock''

