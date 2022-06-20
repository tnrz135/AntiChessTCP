% Organizes all the pieces in one file

:- multifile(is_valid_move/7).
:- multifile(nothing_blocking_range/5).
:- multifile(eat_move/9).

:- dynamic(moves/8). % moves(StartX, StartY, EndX, EndY, Player, EatenX, EatenY, EatenPiece)

:- ["bishop.pl", "king.pl", "pawn.pl", "queen.pl", "rook.pl", "piecesCommon.pl", "knight.pl"].

% moves the piece from X1,Y1 to X2,Y2
move(X1,Y1,X2,Y2,Player) :-
    other_player(Player,NextPlayer),
    (
        (% eating move
            tile(_,NextPlayer,X2,Y2),
            retract(tile(EatenPiece,_,X2,Y2)), % remove the piece in the destination
            IsEnPassant = false,
            IsEating = true
        );
        (% En passant white eat black
            Y1 = 5,
            Player = white,
            tile(pawn,white,X1,5),
            tile(pawn,black,X2,5),
            not(tile(_,black,X2,Y2)),!,
            retract(tile(pawn,black,X2,5)),
            YEaten = 5,
            IsEnPassant = true
        );
        (% En passant black eats white
            Y1 = 4,
            Player = black,
            tile(pawn,black,X1,4),
            tile(pawn,white,X2,4),
            not(tile(_,white,X2,Y2)),!,
            retract(tile(pawn,white,X2,4)),
            YEaten = 4,
            IsEnPassant = true
        );
        (% non eating move
            not(tile(_,_,X2,Y2)), 
            IsEnPassant = false, 
            IsEating = false,
            EatenPiece = nil
        )        
    ),
    retract(tile(Piece,Player,X1,Y1)), % remove the moving piece
    (
        ( % promotion (if there is promotion, no need to assert the moving piece)
            Piece = pawn,
            (
                (
                    Player = black,
                    Y2 is 1,!
                );
                (
                    Player = white,
                    Y2 is 8
                )
            ),
            IsPromotion = true
        );
        ( % no promotion
            assert(tile(Piece,Player,X2,Y2)),
            IsPromotion = false % add the piece in the destination
        )
    ),% update moves
    (
        (
            IsEnPassant = true,!,
            asserta(moves(X1,Y1,X2,Y2,Player,X2,YEaten,pawn))
        );
        (
            IsEating = true,
            IsPromotion = false,!,
            asserta(moves(X1,Y1,X2,Y2,Player,X2,Y2,EatenPiece))
        );
        (
            IsPromotion = true,!,
            asserta(moves(X1,Y1,nil,nil,Player,X2,Y2,EatenPiece))
        );
        (
            asserta(moves(X1,Y1,X2,Y2,Player,nil,nil,nil))
        )
    ).

% Ctrl-Z
undo_last_move:-
    retract(moves(X1,Y1,X2,Y2,Player,XEaten,YEaten,EatenPiece)),!, % remove the last move from the moves stack
    other_player(Player,NextPlayer),
    (
        ( % promotion
            X2 = nil,
            Y2 = nil,!,
            assert(tile(pawn,Player,X1,Y1)),
            (
                ( % no eating
                    EatenPiece = nil,!
                );
                ( % eating
                    assert(tile(EatenPiece,NextPlayer,XEaten,YEaten))
                )    
            )
        );
        ( % no promotion
            tile(Piece,Player,X2,Y2),
            retract(tile(Piece,Player,X2,Y2)),
            assert(tile(Piece,Player,X1,Y1)),
            (
                ( %no eating
                    XEaten = nil,
                    YEaten = nil,
                    EatenPiece = nil,!
                );
                ( % eating
                    assert(tile(EatenPiece,NextPlayer,XEaten,YEaten))
                )
            )
        )
    ).

% get the list of valid moves (eating or not)
anti_chess_valid_move(X1,Y1,X2,Y2,IsEating,Player) :-
    member(X1,["a","b","c","d","e","f","g","h"]),
    member(X2,["a","b","c","d","e","f","g","h"]),
    member(Y1,[1,2,3,4,5,6,7,8]),
    member(Y2,[1,2,3,4,5,6,7,8]),
    tile(Piece,Player,X1,Y1), % check if the player has a piece there
    is_valid_move(X1,Y1,X2,Y2,Player,IsEating,Piece). % get the valid moves for each piece

% get the list of valid moves 
anti_chess_valid_move(Player, Moves) :-
    findall(X1-Y1-X2-Y2, anti_chess_valid_move(X1,Y1,X2,Y2,yes,Player), EatingMoves), % get all eating moves
    (
        (
            length(EatingMoves,0),!, % if no eating moves get non-eating moves
            findall(X1-Y1-X2-Y2, anti_chess_valid_move(X1,Y1,X2,Y2,no,Player),Moves)
        );
        (
            Moves = EatingMoves % there are eating moves
        )
    ).

% get the list of valid moves from X1-Y1
anti_chess_valid_move(X1,Y1,Player, Moves) :-
    findall(X2-Y2, anti_chess_valid_move(_,_,X2,Y2,yes,Player), EatingMoves), % get all eating moves
    findall(X2-Y2, anti_chess_valid_move(X1,Y1,X2,Y2,yes,Player), OurEatingMoves),
    (
        (
            length(EatingMoves,0),!, % if no eating moves get non-eating moves
            findall(X2-Y2, anti_chess_valid_move(X1,Y1,X2,Y2,no,Player),Moves)
        );
        (
            Moves = OurEatingMoves % there are eating moves
        )
    ).