:- ["piecesCommon.pl"].

% check if a move is valid
is_valid_move(X1,Y1,X2,Y2,white,IsEating,pawn):-
    (
        ( % eating
            eat_move(X1,Y1,X2,Y2,white,pawn),!,
            IsEating = yes
        );
        ( % moving and not eating
            (
                ( % normal pawn move
                    Y2 is Y1 + 1,
                    X1 = X2,
                    not(tile(_,_,X2,Y2))
                );
                ( % pawn can move 2 tiles if he didn't move yet
                    Y1 is 2,
                    Y2 is 4,
                    X1 = X2,
                    not(tile(_,_,X2,4)),
                    not(tile(_,_,X2,3))
                )
            ),
            IsEating = no
        )
    ).

% check if a move is valid
is_valid_move(X1,Y1,X2,Y2,black,IsEating,pawn):-
    (
        ( % eating
            eat_move(X1,Y1,X2,Y2,black,pawn),
            IsEating = yes
        );
        ( % moving and not eating
            (( % normal pawn move
                Y2 is Y1 - 1,
                X1 = X2,
                not(tile(_,_,X2,Y2))
            );
            ( % pawn can move 2 tiles if he didn't move yet
                Y1 is 7,
                Y2 is 5,
                X1 = X2,
                not(tile(_,_,X2,6)),
                not(tile(_,_,X2,5))
            ))
        ),
        IsEating = no
    ).

%check if pawn is eating
eat_move(X1,Y1,X2,Y2,white,pawn):-
    % ensure the move is diagonal and in the right direction
    Y2 is Y1 + 1,
    (
        (
            next_char(X1,X2)
        );
        (
            next_char(X2,X1)
        )
    ),
    (
        (
            tile(_,black,X2,Y2) % check for normal pawn eating
        );
        (
            Y1 = 5, % check for En passant eating
            tile(pawn,black,X2,5), 
            moves(_,_,X,Y,black,_,_,_),!,
            X = X2,
            Y = 5
        )
    ).

%check if pawn is eating
eat_move(X1,Y1,X2,Y2,black,pawn):-
    % ensure the move is diagonal and in the right direction
    Y2 is Y1 - 1,
    (
        (
            next_char(X1,X2)
        );
        (
            next_char(X2,X1)
        )
    ),
    (
        (
            tile(_,white,X2,Y2) % check for normal pawn eating
        );
        (
            Y1 = 4, % check for En passant eating
            tile(pawn,white,X2,4), 
            moves(_,_,X,Y,white,_,_,_),!,
            X = X2,
            Y = 4
        )
    ).