:- ["board.pl","ai.pl","Pieces/pieces.pl"].

% make an ai move in the game
aiMove(Diff):-
    h(Val),
    (
        (
            Val = 100,!
        );
        (
            Val = -100,!
        );
        (
            getDepth(Diff,D),
            alphabeta(black, -200, 200, X1-Y1-X2-Y2, D, _), % call alpha beta with the depth
            move(X1,Y1,X2,Y2,black), % make the move
            write("black: "),write(X1-Y1-X2-Y2),nl
        )
    ).

% gets the depth
getDepth(Diff, D):-
    anti_chess_valid_move(black,Moves),
    length(Moves,Len),
    (
        ( % easy
            Diff = easy,!,
            ( % the depth is determined by the number of moves the ai can do on it's turn
                (
                    Len = 1,!,
                    D = 1
                );
                (
                    Len = 2,!,
                    D = 4
                );
                (
                    Len =< 5,!,
                    D = 3
                );
                (
                    Len =< 14,!,
                    D = 2
                );
                (
                    D = 1
                )
            )
        );
        ( % medium
            Diff = medium,!,
            ( % the depth is determined by the number of moves the ai can do on it's turn
                (
                    Len = 1,!,
                    D = 1
                );
                (
                    Len = 2,!,
                    D = 5
                );
                (
                    Len =< 5,!,
                    D = 4
                );
                (
                    Len =< 14,!,
                    D = 3
                );
                (
                    Len =< 19,!,
                    D = 2
                );
                (
                    D = 1
                )
            )
        );
        ( % hard
            Diff = hard,
            ( % the depth is determined by the number of moves the ai can do on it's turn
                (
                    Len = 1,!,
                    D = 1
                );
                (
                    Len = 2,!,
                    D = 5
                );
                (
                    Len =< 5,!,
                    D = 5
                );
                (
                    Len =< 14,!,
                    D = 4
                );
                (
                    D = 3
                )
            )
        )
    ).
