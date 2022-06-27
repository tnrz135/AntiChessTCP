import pygame
from pyswip import Prolog
import socket
import pickle

prolog = Prolog()  # init prolog
prolog.consult("prolog/main.pl")  # consult main.pl
list(prolog.query("main"))  # start chess game

pygame.init()
icon = pygame.image.load('assets/black_pawn.png')
pygame.display.set_icon(icon)
gameDisplay = pygame.display.set_mode((480, 600))
pygame.display.set_caption('Reverse Chess - Prolog')
clock = pygame.time.Clock()

address = ('127.0.0.1', 4590)
s = socket.socket(socket.AF_INET, socket.SOCK_STREAM) # use IP v4, TCP
conn = 0

board_left_up = (0, 0)
tile_size = 60

piecesImages = {
    "black": {
        "king": pygame.image.load("assets/black_king.png"),
        "queen": pygame.image.load("assets/black_queen.png"),
        "pawn": pygame.image.load("assets/black_pawn.png"),
        "knight": pygame.image.load("assets/black_knight.png"),
        "rook": pygame.image.load("assets/black_rook.png"),
        "bishop": pygame.image.load("assets/black_bishop.png")
    },
    "white": {
        "king": pygame.image.load("assets/white_king.png"),
        "queen": pygame.image.load("assets/white_queen.png"),
        "pawn": pygame.image.load("assets/white_pawn.png"),
        "knight": pygame.image.load("assets/white_knight.png"),
        "rook": pygame.image.load("assets/white_rook.png"),
        "bishop": pygame.image.load("assets/white_bishop.png")
    }
}

num_to_char = ["-", "a", "b", "c", "d", "e", "f", "g", "h"]
char_to_num = {"a": 1, "b": 2, "c": 3, "d": 4, "e": 5, "f": 6, "g": 7, "h": 8}

possible_tiles = []
selected_tile = ()


def display_board():
    # Display the board itself
    white = True
    for x in ["a", "b", "c", "d", "e", "f", "g", "h"]:  # color of tiles
        for y in range(8, 0, -1):
            curr_pos = (board_left_up[0] + (char_to_num[x] - 1) * tile_size,
                        board_left_up[1] + (y - 1) * tile_size)

            tile_pos = coordinates_to_pos(curr_pos)

            if tile_pos in possible_tiles:
                pygame.draw.rect(
                    gameDisplay, (0, 200, 0),
                    pygame.Rect(curr_pos[0], curr_pos[1], tile_size,
                                tile_size))  # paint in green possible tiles
            elif white:
                pygame.draw.rect(
                    gameDisplay, (255, 206, 158),
                    pygame.Rect(curr_pos[0], curr_pos[1], tile_size,
                                tile_size))
            else:
                pygame.draw.rect(
                    gameDisplay, (209, 139, 71),
                    pygame.Rect(curr_pos[0], curr_pos[1], tile_size,
                                tile_size))

            white = not white
        white = not white

    # Display pieces
    for x in ["a", "b", "c", "d", "e", "f", "g", "h"]: 
        for y in range(8, 0, -1):
            curr_pos = (board_left_up[0] + (char_to_num[x] - 1) * tile_size,
                        board_left_up[1] + (y - 1) * tile_size)

            tile_result = list(prolog.query(f'tile(Piece,Player,"{x}",{9-y})')) # get piece in tile

            if (tile_result != []):
                curr_tile = tile_result[0]
                gameDisplay.blit(
                    piecesImages[curr_tile["Player"]][curr_tile["Piece"]],
                    curr_pos)


def coordinates_to_pos(pos):
    x = None
    y = None
    if (board_left_up[0] <= pos[0] <= board_left_up[0] + tile_size * 8
            and board_left_up[1] <= pos[1] <= board_left_up[1] + tile_size * 8):
        x = (pos[0] - board_left_up[0]) // tile_size + 1
        x = num_to_char[x]
        y = (8 - (abs(board_left_up[1] - pos[1]) // tile_size))
    return (x, y)


white = (255, 255, 255)
black = (0, 0, 0)
grey = (180, 180, 180)
grey2 = (100, 100, 100)
font = pygame.font.Font('rubik.ttf', 24)
text1 = font.render(' In order to play, choose a piece to move', True, black,
                    grey)
text2 = font.render(' with and where to move it.', True, black, grey)
black_win = font.render(' black won.', True, black, grey)
white_win = font.render(' white won.', True, black, grey)
easy = font.render('easy', True, black, grey2)
medium = font.render('medium', True, black, grey2)
hard = font.render('hard', True, black, grey2)

whiteTurn = True

running = True

difficulty = ""
gameStarted = False
gameEnded = False

while running:
    try:
        for event in pygame.event.get(): # handle GUI
            if event.type == pygame.QUIT:
                running = False
            elif event.type == pygame.KEYDOWN and not gameStarted and not gameEnded: # multiplayer
                if event.key == pygame.K_h:
                    difficulty = "host"
                    s.bind(address)
                    print("Listening")
                    s.listen()
                    conn, _ = s.accept()
                    print("Connected")
                    gameStarted = True
                elif event.key == pygame.K_j:
                    difficulty = "join"
                    s.connect(address)
                    conn = s
                    gameStarted = True
            elif event.type == pygame.MOUSEBUTTONDOWN and event.button == 1: # a button was clicked
                pos = event.pos
                if not gameStarted and not gameEnded: # ai menu selection
                    if 10 <= pos[0] <= 150 and pos[
                            1] <= 580 and pos[1] >= 550:
                        difficulty = "easy"
                        gameStarted = True
                    elif 160 <= pos[0] <= 320 and pos[
                            1] <= 580 and pos[1] >= 550:
                        difficulty = "medium"
                        gameStarted = True
                    elif 330 <= pos[0] <= 470 and pos[
                            1] <= 580 and pos[1] >= 550:
                        difficulty = "hard"
                        gameStarted = True


                elif whiteTurn and not gameEnded and gameStarted and difficulty != "join": # a button was clicked during host turn
                    tile = coordinates_to_pos(pos)  # get current tile

                    # check if white piece here
                    if len(
                            list(
                                prolog.query(
                                    f'tile(_,white,"{tile[0]}",{tile[1]})'))
                    ) == 1:
                        selected_tile = tile
                        temp_tiles = list(
                            prolog.query(  # get all possible moves of the piece
                                f"""anti_chess_valid_move("{tile[0]}",{tile[1]},white,Moves)"""
                            ))
                        if (len(temp_tiles) == 1):
                            temp_tiles = temp_tiles[0]["Moves"]
                        possible_tiles = []
                        for tile in temp_tiles:  # format the moves
                            possible_tiles.append(
                                (tile.args[0].decode("utf-8"), tile.args[1]))

                    elif tile in possible_tiles:
                        list(
                            prolog.query(
                                f"""move("{selected_tile[0]}",{selected_tile[1]},"{tile[0]}",{tile[1]},white)"""
                            ))
                        if difficulty == "host":
                            conn.sendall(bytes(f"{selected_tile[0]}{selected_tile[1]}{tile[0]}{tile[1]}", 'utf-8'))
                        print(
                            f"white: {selected_tile[0]}-{selected_tile[1]}-{tile[0]}-{tile[1]}"
                        )
                        selected_tile = ()
                        possible_tiles = []
                        whiteTurn = False

                elif not whiteTurn and not gameEnded and gameStarted and difficulty == 'join': # a button was clicked during black turn
                    tile = coordinates_to_pos(pos)  # get current tile

                    # check if black piece here
                    if len(
                            list(
                                prolog.query(
                                    f'tile(_,black,"{tile[0]}",{tile[1]})'))
                    ) == 1:
                        selected_tile = tile
                        temp_tiles = list(
                            prolog.query(  # get all possible moves of the piece
                                f"""anti_chess_valid_move("{tile[0]}",{tile[1]},black,Moves)"""
                            ))
                        if (len(temp_tiles) == 1):
                            temp_tiles = temp_tiles[0]["Moves"]
                        possible_tiles = []
                        for tile in temp_tiles:  # format the moves
                            possible_tiles.append(
                                (tile.args[0].decode("utf-8"), tile.args[1]))

                    elif tile in possible_tiles:
                        list(
                            prolog.query(
                                f"""move("{selected_tile[0]}",{selected_tile[1]},"{tile[0]}",{tile[1]},black)"""
                            ))
                        conn.sendall(bytes(f"{selected_tile[0]}{selected_tile[1]}{tile[0]}{tile[1]}", 'utf-8'))
                        print(
                            f"black: {selected_tile[0]}-{selected_tile[1]}-{tile[0]}-{tile[1]}"
                        )
                        selected_tile = ()
                        possible_tiles = []
                        whiteTurn = True

        gameDisplay.fill((180, 180, 180))
        display_board()

        if (list(prolog.query("win(white,yes)"))):
            gameDisplay.blit(white_win, (0, 480))
            gameEnded = True
        elif (list(prolog.query("win(black,yes)"))):
            gameDisplay.blit(black_win, (0, 480))
            gameEnded = True
        else:
            gameDisplay.blit(text1, (0, 480))
            gameDisplay.blit(text2, (0, 510))

            # difficulty buttons
            if not gameStarted or difficulty == "easy":
                pygame.draw.rect(gameDisplay, (100, 100, 100),
                                 pygame.Rect(10, 550, 140, 30))
                gameDisplay.blit(easy, (50, 550))

            if not gameStarted or difficulty == "medium":
                pygame.draw.rect(gameDisplay, (100, 100, 100),
                                 pygame.Rect(160, 550, 160, 30))
                gameDisplay.blit(medium, (200, 550))

            if not gameStarted or difficulty == "hard":
                pygame.draw.rect(gameDisplay, (100, 100, 100),
                                 pygame.Rect(330, 550, 140, 30))
                gameDisplay.blit(hard, (370, 550))

        pygame.display.update()

        if not whiteTurn and gameStarted and not gameEnded:
            if difficulty == "host":
                data = conn.recv(8)
                if data:
                    data = data.decode('utf-8')
                    selected_tile = (data[0], data[1])
                    tile = (data[2], data[3])
                    list(prolog.query(
                        f"""move("{selected_tile[0]}",{selected_tile[1]},"{tile[0]}",{tile[1]},black)."""
                    ))
                    whiteTurn = True
            elif difficulty != "join":
                print("thinking...")
                list(prolog.query(f"aiMove({difficulty})."))
                whiteTurn = True
        elif whiteTurn and difficulty == "join" and gameStarted and not gameEnded:
            # get action from TCP
            data = conn.recv(8)
            if data:
                data = data.decode('utf-8')
                selected_tile = (data[0], data[1])
                tile = (data[2], data[3])
                list(prolog.query(
                    f"""move("{selected_tile[0]}",{selected_tile[1]},"{tile[0]}",{tile[1]},white)."""
                ))
            whiteTurn = False

        clock.tick(5)

    except Exception as e:
        print(e)
        if str(e) != '[WinError 10061] No connection could be made because the target machine actively refused it':
            pygame.quit()
            exit()


quit()