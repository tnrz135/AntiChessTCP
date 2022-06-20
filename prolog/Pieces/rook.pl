:- ["piecesCommon.pl"].

% check if a move is valid
is_valid_move(X1,Y1,X2,Y2,Player,IsEating,rook) :-
    not(tile(_,Player,X2,Y2)),
    (
        ( % can eat
            eat_move(X1,Y1,X1,Y1,X2,Y2,Player,rook,_),!,
            IsEating = yes
        );
        ( % can't eat
            nothing_blocking_range(X1,Y1,X2,Y2,rook),
            IsEating = no
        )
    ).

%check if there is a piece blocking the range of the bishop
nothing_blocking_range(X1,Y1,X2,Y2,rook) :-
    (
        ( % down

            X1 = X2,
            Y1 > Y2,
            check_empty_down(X1,Y1,Y2)
        );
        ( % up
            X1 = X2,
            Y1 < Y2,
            check_empty_up(X1,Y1,Y2)
        );
        ( % right
            Y1 = Y2,
            X1 < X2,
            check_empty_right(X1,Y1,X2)
        );
        ( % left
            Y1 = Y2,
            X1 > X2,
            check_empty_left(X1,Y1,X2)
        )
    ).


% check in the direction if all the tiles are empty
check_empty_right(X1,Y1,X2) :-
    not(tile(_,_,X2,Y1)),
    next_char(NextX, X2),
    NextX \= no,
    (
        (
            NextX = X1
        );
        (
            NextX \= X1, 
            check_empty_right(X1,Y1,NextX)
        )
    ).

% check in the direction if all the tiles are empty
check_empty_left(X1,Y1,X2) :-
    not(tile(_,_,X2,Y1)),
    next_char(X2,NextX),
    NextX \= no,
    (
        (
            NextX = X1
        );
        (
            NextX \= X1, 
            check_empty_left(X1,Y1,NextX)
        )
    ).

% check in the direction if all the tiles are empty
check_empty_up(X1,Y1,Y2) :-
    not(tile(_,_,X1,Y2)),
    NextY is Y2 - 1,
    NextY >= 1,
    (
        (
            NextY = Y1
        );
        (
            NextY \= Y1,
            check_empty_up(X1,Y1,NextY)
        )
    ).

% check in the direction if all the tiles are empty
check_empty_down(X1,Y1,Y2) :-
    not(tile(_,_,X1,Y2)),
    NextY is Y2 + 1,
    NextY =< 8,
    (
        (
            NextY = Y1
        );
        (
            NextY \= Y1,
            check_empty_down(X1,Y1,NextY)
        )
    ).

%check if move is an eating move
eat_move(X1,Y1,X2,Y2,XTarget,YTarget,Player,rook,Direction):-
    other_player(Player,NextPlayer),
    between(1, 8, Y2),
    char_code("a", A),
    char_code("h", H),
    X2 \= no,
    char_code(X2, X2Code),
    between(A,H,X2Code),
    (
        (
            not(tile(_,Player,X2,Y2)) %check that nothing blocking the range
        );
        (
            %the bishop himself can't block is own range
            X1 = X2,
            Y1 = Y2
        )
    ),
    (
        (
            %if X2,Y2 is a tile with NextPlayer's piece then this is an eat move (if there is nothing blocking the range which we checked using recurison before)
            tile(_,NextPlayer,X2,Y2),!,
            XTarget=X2,
            YTarget=Y2
        );
        %check for eat move in each direction
        (
            Direction = right,
            next_char(X2,XRight),
            eat_move(X1,Y1,XRight,Y1,XTarget,YTarget,Player,rook,Direction)
        );
        (
            Direction = left,
            next_char(XLeft,X2),
            eat_move(X1,Y1,XLeft,Y1,XTarget,YTarget,Player,rook,Direction)
        );
        (
            Direction = up,
            YUp is Y2 + 1,
            eat_move(X1,Y1,X1,YUp,XTarget,YTarget,Player,rook,Direction)
        );
        (
            Direction = down,
            YDown is Y2 - 1,
            eat_move(X1,Y1,X1,YDown,XTarget,YTarget,Player,rook,Direction)
        )
    ).
