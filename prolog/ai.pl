:- ["Pieces/pieces.pl", "board.pl"].

% white - min player, black - min player

% calculates the heuristic value
h(Value):-
    (
        ( % a player won
            (
                win(white,yes),!,
                Value = -100
            );
            (
                win(black,yes),!,
                Value = 100
            ),!
        );
        ( % no player had won
            piecesValue(white,PiecesValueWhite),
            piecesValue(black,PiecesValueBlack),
            pawnsMovedValue(white,PawnsMovedValueWhite),
            pawnsMovedValue(black,PawnsMovedValueBlack),
            ValueWhite is PiecesValueWhite + PawnsMovedValueWhite,
            ValueBlack is PiecesValueBlack + PawnsMovedValueBlack,
            Value is ValueBlack - ValueWhite
        )
    ).

% calculate the value that the moved pawns add to h
pawnsMovedValue(black, Value) :-
    (
        (
            not(tile(pawn,black,"c",7)),!,
            Value = 1
        );
        (
            not(tile(pawn,black,"d",7)),!,
            Value = 1
        );
        (
            not(tile(pawn,black,"e",7)),!,
            Value = 1
        );
        (
            not(tile(pawn,black,"f",7)),!,
            Value = 1
        );
        (
            Value = 0
        )
    ).

% calculate the value that the moved pawns add to h
pawnsMovedValue(white, Value) :-
    (
        (
            not(tile(pawn,white,"c",2)),!,
            Value = 1
        );
        (
            not(tile(pawn,white,"d",2)),!,
            Value = 1
        );
        (
            not(tile(pawn,white,"e",2)),!,
            Value = 1
        );
        (
            not(tile(pawn,white,"f",2)),!,
            Value = 1
        );
        (
            Value = 0
        )
    ).
    

% calculate the value of the pieces lost
piecesValue(Player, Value) :-
    findall(X-Y,tile(queen,Player,X,Y), Queens),
    length(Queens, NQueens), 
    EatenQueens is 1 - NQueens,
    
    findall(X-Y,tile(king,Player,X,Y), Kings), 
    length(Kings, NKings), 
    EatenKings is 1 - NKings,
    
    findall(X-Y,tile(pawn,Player,X,Y), Pawns), 
    length(Pawns, NPawns), 
    EatenPawns is 8 - NPawns,
    
    findall(X-Y,tile(rook,Player,X,Y), Rooks), 
    length(Rooks, NRooks), 
    EatenRooks is 2 - NRooks,
    
    findall(X-Y,tile(bishop,Player,X,Y), Bishops), 
    length(Bishops, NBishops), 
    EatenBishops is 2 - NBishops,
    
    findall(X-Y,tile(knight,Player,X,Y), Knights), 
    length(Knights, NKnights), 
    EatenKnights is 2 - NKnights,

    Value is 9 * EatenQueens + 5 * EatenRooks + 3 * EatenBishops + 3 * EatenKnights + 2 * EatenKings + 1 * EatenPawns.

% alpha beta algorithem acording to the one in the course book, figure 24.5, page 585
alphabeta(Player, Alpha, Beta, X1-Y1-X2-Y2, D, Val):-
    anti_chess_valid_move(Player,MovesList),!,
    NewD is D - 1,
    (
        (
            (
                (
                    D < 0,!
                );
                (
                    length(MovesList,0),!
                )
            ),
            h(Val)
        );
        (
            D >= 0,
            boundedbest(Player, MovesList, Alpha, Beta, X1-Y1-X2-Y2, Val, NewD)
        )
    ).

boundedbest(Player,[X1-Y1-X2-Y2|MovesList],Alpha,Beta,BestX1-BestY1-BestX2-BestY2,BestVal,D):-
    move(X1,Y1,X2,Y2,Player),
    other_player(Player,NextPlayer),
    ( 
        (
            D = 0,!,
            h(Val)
        );
        (
            D > 0,
            alphabeta(NextPlayer,Alpha,Beta,_,D,Val)
        )
    ),
    undo_last_move,
    goodenough(Player,MovesList,Alpha,Beta,X1-Y1-X2-Y2,Val,BestX1-BestY1-BestX2-BestY2,BestVal,D).

goodenough(_,[],_,_,BestX1-BestY1-BestX2-BestY2,BestVal,BestX1-BestY1-BestX2-BestY2,BestVal,_) :- !. 

goodenough(Player,_,Alpha,Beta,BestX1-BestY1-BestX2-BestY2,BestVal,BestX1-BestY1-BestX2-BestY2,BestVal,_):-
    (
        ( % Maximizer attained upper bound
            Player = white,
            BestVal > Beta,!
        );
        ( % Minimizer attained lower bound
            Player = black,
            BestVal < Alpha
        )
    ),!.

goodenough(Player,MovesList,Alpha,Beta,X1-Y1-X2-Y2,Val,BestX1-BestY1-BestX2-BestY2,BestVal,D):-
    newbounds(Alpha,Beta,Player,Val,NewAlpha,NewBeta),
    boundedbest(Player,MovesList,NewAlpha,NewBeta,NewX1-NewY1-NewX2-NewY2,NewVal,D),
    betterof(Player,X1-Y1-X2-Y2,Val,NewX1-NewY1-NewX2-NewY2,NewVal,BestX1-BestY1-BestX2-BestY2,BestVal).

newbounds(Alpha,Beta,Player,Val,Val,Beta) :-
    Player = white, % Maximizer increased lower bound
    Val > Alpha,!.

newbounds(Alpha,Beta,Player,Val,Alpha,Val):-
    Player = black, % Maximizer deceased upper bound
    Val < Beta,!.

newbounds(Alpha,Beta,_,_,Alpha,Beta). % Otherwise bounds unchanged

betterof(Player,_,Val,BestX1-BestY1-BestX2-BestY2,BestVal,BestX1-BestY1-BestX2-BestY2,BestVal):- % Second move is better
    (
        (
            Player = white,
            Val > BestVal,!
        );
        (
            Player = black,
            BestVal > Val
        )
    ),!.

betterof(_,X1-Y1-X2-Y2,Val,_,_,X1-Y1-X2-Y2,Val). % Otherwise first move is better