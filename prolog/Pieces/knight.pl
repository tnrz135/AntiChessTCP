:- ["piecesCommon.pl"].

% check if a move is valid
is_valid_move(X1,Y1,X2,Y2,Player,IsEating,knight) :- 
    other_player(Player,NextPlayer),
    not(tile(_,Player,X2,Y2)),
    is_two_one_from_knight(X1,Y1,X2,Y2),
    (
        ( % can eat 
            tile(_,NextPlayer,X2,Y2),!, % checks if can eat
            IsEating = yes
        );
        ( % can't eat
             %no possible eat moves
            IsEating = no
        )
    ).

% check if the X2,Y2 is a valid knight movement from X1,Y1 so the knight can move there
is_two_one_from_knight(X1,Y1,X2,Y2):-
    (
        ( % up 2 right 1
            next_char(X1,X2),
            Y2 is Y1 + 2
        ); 
        ( % up 1 right 2
            next_char(X1,Temp),
            next_char(Temp,X2),
            Y2 is Y1 + 1 
        ); 
        ( % down 1 right 2
            next_char(X1,Temp),
            next_char(Temp,X2),
            Y2 is Y1 - 1
        );
        ( % down 2 right 1
            next_char(X1,X2),
            Y2 is Y1 - 2
        );
        ( % down 2 left 1
            next_char(X2,X1),
            Y2 is Y1 - 2
        );
        ( % down 1 left 2
            next_char(X2,Temp),
            next_char(Temp,X1),
            Y2 is Y1 - 1
        );
        ( % up 1 left 2
            next_char(X2,Temp),
            next_char(Temp,X1),
            Y2 is Y1 + 1
        );
        ( % up 2 left 1
            next_char(X2,X1),
            Y2 is Y1 + 2
        )  
    ).