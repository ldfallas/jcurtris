
require 'api/ncurses'
sleep =: 6!:3
seconds_from_start =: 6!:1

l_tetrimino =. 2 3 $ 1 1 1 1 0 0 
j_tetrimino =. 2 3 $ 1 1 1 0 0 1 
i_tetrimino =. 4 1 $ 2 2 2 2
t_tetrimino =. 2 3 $ 3 3 3 0 3 0
b_tetrimino =. 2 2 $ 4 4 4 4 
z_tetrimino =. 2 3 $ 5 5 0 0 5 5 
s_tetrimino =. 2 3 $ 0 5 5 5 5 0 

NB. initialize random number generator 
NB. with current seconds as seed
9!:1 (". 6!:0 'ss') 

tetriminos =: l_tetrimino;j_tetrimino;i_tetrimino; b_tetrimino;t_tetrimino;z_tetrimino;s_tetrimino

can_put_in_matrix =: 3 : 0
 NB. Unpack the arguments
 tetrimino =. 0&< > 0 { y
 tetrimino_width =. 1 { $ tetrimino
 tetrimino_height =. 0 { $ tetrimino
 ypos =. > 1 { y
 xpos =. > 2 { y
 game =. > 3 { y
 game_width  =. 1 { $ game
 game_height =. 0 { $ game

 NB. Verify field boundaries
 is_inside =. (xpos >: 0) *. (ypos >: 0) *. ( (xpos+tetrimino_width - 1) < game_width) *. ((ypos+tetrimino_height - 1) < game_height)

 NB. Check if we hit an occupied cell
 hits =. 0
 if. is_inside do.
   positions =. , ((i.@(0&{)@$)(<@,"0)/(i.@(1&{)@$)) tetrimino
   hits =. +/ , *&tetrimino ($tetrimino) $ ((+&(ypos,xpos))&.> positions){ game
 end.

 is_inside *. (hits = 0)  
)

remove_full_rows =: 3 : 0
  row_width =. 1 { $ y
  rows =. 0 { $ y
   
  bin_game =. >&0 y
  full_rows =. -.@=&row_width +/"1 bin_game
  full_row_count =. +/ full_rows
  padding =. ((rows - full_row_count), row_width) $ 0
  padding , full_rows # y
)



put_in_matrix =: 3 : 0
 NB. unpack argumets
 tetrimino =. > 0 { y
 i =. > 1 { y
 j =. > 2 { y
 game =. > 3 { y

 NB. calculate target positions 
 positions =. , ((i.@(0&{)@$)(<@,"0)/(i.@(1&{)@$)) tetrimino

 NB. combine tetrimino with target section
 tetrimino =. +&tetrimino ($tetrimino) $ ((+&(i,j))&.> positions) { game
  
 NB. change matrix
 (,tetrimino) ((+&(i,j))&.> positions)} game
)


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

rotate =: |.@|:

mainblock=: 3 : 0

NB. setup current tetrimino
current =.  (?@$ tetriminos) {:: tetriminos
NB. setup game field
game =:  20 10 $ 0

NB. setup ncurses settings
noecho_ncurses_''.
vin =. initscr_ncurses_''
start_color_ncurses_''
NB. Initialize colors
init_pair_ncurses_  1;COLOR_BLUE_ncurses_;COLOR_BLACK_ncurses_
init_pair_ncurses_  2;COLOR_BLUE_ncurses_;COLOR_YELLOW_ncurses_
init_pair_ncurses_ 3;COLOR_BLUE_ncurses_;COLOR_WHITE_ncurses_
init_pair_ncurses_ 4;COLOR_BLUE_ncurses_;COLOR_GREEN_ncurses_
init_pair_ncurses_ 5;COLOR_BLUE_ncurses_;COLOR_MAGENTA_ncurses_
init_pair_ncurses_ 6;COLOR_BLUE_ncurses_;COLOR_BLUE_ncurses_
init_pair_ncurses_ 7;COLOR_BLUE_ncurses_;COLOR_CYAN_ncurses_
init_pair_ncurses_ 8;COLOR_YELLOW_ncurses_;COLOR_RED_ncurses_
vin =. newwin_ncurses_ 25 50 0 0

cbreak_ncurses_''
nodelay_ncurses_ vin ;'1'
curs_set_ncurses_ 0
keypad_ncurses_ vin;'1'
scrollok_ncurses_ vin;'1'

NB. Define start position
k=:0
j=:1

timestamp =. seconds_from_start'' 
automove=.2
needs_refresh =. 1
NB. Game loop
while. 1 do.
   c =. wgetch_ncurses_ vin 
   if. c = KEY_UP_ncurses_ do.
      game =: put_in_matrix (current*_1);k;j;game
      current =. rotate current
      needs_refresh =. 1
   elseif. c = KEY_RIGHT_ncurses_ do.
      game_tmp =. put_in_matrix (current*_1);k;j;game
      if. can_put_in_matrix current;k;(j + 1);game_tmp do.
         game =: game_tmp
         j =. j + 1
         needs_refresh =. 1
      end.
   elseif. c = KEY_LEFT_ncurses_ do.
      game_tmp =. put_in_matrix (current*_1);k;j;game
      if. can_put_in_matrix (current);k;(j - 1);game_tmp do.
         game =: game_tmp
         j =. j - 1
         needs_refresh =. 1
      end.
   elseif. 1 do. 
      if. ((seconds_from_start'') - timestamp) < 0.1 do.
         continue.
      else.
         timestamp =. seconds_from_start'' 
      end.
   
      if. automove = 0 do.
         game =: put_in_matrix (current*_1);k;j;game
         if. can_put_in_matrix (current);(k+1);j;game do.
            k =. k + 1
         else.
           game =: put_in_matrix (current);k;j;game
           k =. 0
           j =. 0
           if. can_put_in_matrix current;k;j;game do.
              current =. (?@$ tetriminos) {:: tetriminos
           else.
             mvwprintw_1_ncurses_ vin; 0; 0; ' Game over '
             nodelay_ncurses_ vin ;'0'
             wgetch_ncurses_ vin 
             exit''
          
           end.
         end.
         automove =. 2
         needs_refresh =. 1
      else.
          automove =. automove - 1
      end.
   end.
   unget_wch_ncurses_ c
   if. needs_refresh do.
      game =: put_in_matrix (current);k;j;game
      game =: remove_full_rows game
      drawGame vin; game
      wrefresh_ncurses_  vin
      needs_refresh =. 0
   end.
end.
delwin_ncurses_  vin
endwin_ncurses_'' 
)

mainblock''

