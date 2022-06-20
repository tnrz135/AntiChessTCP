:- multifile(tile/4).
:- multifile(moves/8).

:- dynamic(tile/4).
:- dynamic(moves/8).

:- ["Pieces/pieces.pl"].

% checks if player/ai won
win(Player,Won):-
    anti_chess_valid_move(Player,Res),
    (
        (
            length(Res,0),!, %in anti-chess you win if there are no moves to play
            Won = yes
        );
        (
            Won = no
        )
    ).

% puts all the pieces in their default places
init_board :-
    % white
    assert(tile(pawn,white,"a",2)),
    assert(tile(pawn,white,"b",2)),
    assert(tile(pawn,white,"c",2)),
    assert(tile(pawn,white,"d",2)),
    assert(tile(pawn,white,"e",2)),
    assert(tile(pawn,white,"f",2)),
    assert(tile(pawn,white,"g",2)),
    assert(tile(pawn,white,"h",2)),

    assert(tile(rook,white,"a",1)),
    assert(tile(rook,white,"h",1)),

    assert(tile(knight,white,"b",1)),
    assert(tile(knight,white,"g",1)),

    assert(tile(bishop,white,"c",1)),
    assert(tile(bishop,white,"f",1)),

    assert(tile(queen,white,"d",1)),
    assert(tile(king,white,"e",1)),


    % black
    assert(tile(pawn,black,"a",7)),
    assert(tile(pawn,black,"b",7)),
    assert(tile(pawn,black,"c",7)),
    assert(tile(pawn,black,"d",7)),
    assert(tile(pawn,black,"e",7)),
    assert(tile(pawn,black,"f",7)),
    assert(tile(pawn,black,"g",7)),
    assert(tile(pawn,black,"h",7)),

    assert(tile(rook,black,"a",8)),
    assert(tile(rook,black,"h",8)),

    assert(tile(knight,black,"b",8)),
    assert(tile(knight,black,"g",8)),

    assert(tile(bishop,black,"c",8)),
    assert(tile(bishop,black,"f",8)),

    assert(tile(queen,black,"d",8)),
    assert(tile(king,black,"e",8)).

% cleans the board
clean :-
    retractall(tile(_,_,_,_)),
    retractall(moves(_,_,_,_,_,_,_,_)).