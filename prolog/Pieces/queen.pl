:- ["rook.pl","bishop.pl","piecesCommon.pl"].

% check if a move is valid
is_valid_move(X1,Y1,X2,Y2,Player,IsEating,queen) :- % the queen's movement is based on the rook's and the bishop's
    (
        ( % can eat
            (
                (
                    eat_move(X1,Y1,X1,Y1,X2,Y2,Player,rook,_)
                );
                (
                    eat_move(X1,Y1,X1,Y1,X2,Y2,Player,bishop,_)
                )
            ),!,
            IsEating = yes
        );
        ( % can't eat
            (
                (
                    nothing_blocking_range(X1,Y1,X2,Y2,rook)
                );
                (
                    nothing_blocking_range(X1,Y1,X2,Y2,bishop)
                )
            ),
            IsEating = no
        )
    ).