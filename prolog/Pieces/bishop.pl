:- ["piecesCommon.pl"].

% check if a move is valid
is_valid_move(X1,Y1,X2,Y2,Player,IsEating,bishop) :-
    not(tile(_,Player,X2,Y2)), %check that the target tile is empty
    (
        ( % can eat
            eat_move(X1,Y1,X1,Y1,X2,Y2,Player,bishop,_),!,
            IsEating = yes
        );
        ( % can't eat
            nothing_blocking_range(X1,Y1,X2,Y2,bishop),
            IsEating = no
        )
    ).

%check if there is a piece blocking the range of the bishop
nothing_blocking_range(X1,Y1,X2,Y2,bishop) :-
    (
        ( % down left
            X1 > X2,
            Y1 > Y2,
            check_empty_down_left(X1,Y1,X2,Y2)
        );
        ( % up left
            X1 > X2,
            Y1 < Y2,
            check_empty_up_left(X1,Y1,X2,Y2)
        );
        ( % up right
            X1 < X2,
            Y1 < Y2,
            check_empty_up_right(X1,Y1,X2,Y2)
        );
        ( % down right
            X1 < X2,
            Y1 > Y2,
            check_empty_down_right(X1,Y1,X2,Y2)
        )
    ).

%check using recurison if there is a piece blocking the range of the bishop in the down left direction
check_empty_down_left(X1,Y1,X2,Y2) :-
    %check for each tile in the way
    not(tile(_,_,X2,Y2)),
    next_char(X2, NextX),
    NextY is Y2+1,
    NextX \= no,
    (
        (
            NextX = X1, 
            NextY = Y1
        );
        (
            NextX \= X1, 
            NextY \= Y1, 
            check_empty_down_left(X1,Y1,NextX,NextY)
        )
    ).

%check using recurison if there is a piece blocking the range of the bishop in the up left direction
check_empty_up_left(X1,Y1,X2,Y2) :-
    %check for each tile in the way
    not(tile(_,_,X2,Y2)),
    next_char(X2, NextX),
    NextY is Y2-1,
    NextX \= no,
    (
        (
            NextX = X1, 
            NextY = Y1
        );
        (
            NextX \= X1, 
            NextY \= Y1, 
            check_empty_up_left(X1,Y1,NextX,NextY)
        )
    ).

%check using recurison if there is a piece blocking the range of the bishop in the up right direction
check_empty_up_right(X1,Y1,X2,Y2) :-
    %check for each tile in the way
    not(tile(_,_,X2,Y2)),
    next_char(NextX, X2),
    NextY is Y2-1,
    NextX \= no,
    (
        (
            NextX = X1, 
            NextY = Y1
        );
        (
            NextX \= X1, 
            NextY \= Y1, 
            check_empty_up_right(X1,Y1,NextX,NextY)
        )
    ).

%check using recurison if there is a piece blocking the range of the bishop in the down right direction
check_empty_down_right(X1,Y1,X2,Y2) :-
    %check for each tile in the way
    not(tile(_,_,X2,Y2)),
    next_char(NextX, X2),
    NextY is Y2+1,
    NextX \= no,
    (
        (
            NextX = X1, 
            NextY = Y1
        );
        (
            NextX \= X1, 
            NextY \= Y1, 
            check_empty_down_right(X1,Y1,NextX,NextY)
        )
    ).

%check if move is an eating move
eat_move(X1,Y1,X2,Y2,XTarget,YTarget,Player,bishop,Direction):-
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
            Direction = down_left,
            next_char(XLeft,X2),
            YDown is Y2 - 1,
            eat_move(X1,Y1,XLeft,YDown,XTarget,YTarget,Player,bishop,Direction)
        );
        (
            Direction = up_left,
            next_char(XLeft,X2),
            YUp is Y2 + 1,
            eat_move(X1,Y1,XLeft,YUp,XTarget,YTarget,Player,bishop,Direction)
        );
        (
            Direction = up_right,
            next_char(X2,XRight),
            YUp is Y2 + 1,
            eat_move(X1,Y1,XRight,YUp,XTarget,YTarget,Player,bishop,Direction)
        );
        (
            Direction = down_right,
            next_char(X2,XRight),
            YDown is Y2 - 1,
            eat_move(X1,Y1,XRight,YDown,XTarget,YTarget,Player,bishop,Direction)
        )
    ).