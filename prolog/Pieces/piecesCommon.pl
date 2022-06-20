% A file with shared stuff between all the pieces

% char artimatics
next_char("a","b").
next_char("b","c").
next_char("c","d").
next_char("d","e").
next_char("e","f").
next_char("f","g").
next_char("g","h").
next_char("h",no).

%switch between players
other_player(black,white):-!.
other_player(_,black).

%tile(Piece,Player,X,Y), represents a tile on the board, an empty tile does not have a "tile fact"
:- dynamic(tile/4).

%moves(X1,Y1,X2,Y2,Player,XE,YE,EatenPiece),  shows the prev moves for alpha beta and en passant
:- dynamic(moves/8).