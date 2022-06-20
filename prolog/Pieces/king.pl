:- ["piecesCommon.pl"].

% check if a move is valid
is_valid_move(X1,Y1,X2,Y2,Player,IsEating,king) :- 
    other_player(Player,NextPlayer),
    not(tile(_,Player,X2,Y2)), %check that the target tile is empty
    (
        ( % can eat 
            setof(X-Y,(is_next_to_tile(X1,Y1,X,Y),tile(_,NextPlayer,X,Y)),EatMoves),!, % checks if can eat
            member(X2-Y2,EatMoves),
            IsEating = yes
        );
        ( % can't eat
            % no possible eat moves
            is_next_to_tile(X1,Y1,X2,Y2),
            IsEating = no
        )
    ).

%check if the X2,Y2 is adjacent to X1,Y1 so the king can move there
is_next_to_tile(X1,Y1,X2,Y2):- 
    (
        ( % up
            X2 = X1,
            Y2 is Y1 + 1
        ); 
        ( % up right
            next_char(X1,X2),
            Y2 is Y1 + 1 
        ); 
        ( % right
            next_char(X1,X2),
            Y2 = Y1
        );
        ( % down right
            next_char(X1,X2),
            Y2 is Y1 - 1
        );
        ( % down
            X2 = X1,
            Y2 is Y1 - 1
        );
        ( % down left
            next_char(X2,X1),
            Y2 is Y1 - 1
        );
        ( % left
            next_char(X2,X1),
            Y2 = Y1
        );
        ( % up left
            next_char(X2,X1),
            Y2 is Y1 + 1
        )  
    ).