# Godot Chess
This is my attempt to make chess in Godot (mainly using godot as a GUI)

## Uploaded a preview of the Preview in Mp4
- There are still some bugs present in this version

## Description of the game:
- Made entirely using GDScript (language similar to python)
- Inclusive of all legal moves
- Detect checks and checkmates and forces the other player to certain moves accordingly
- Keep track of piece taken and promotion of pieces

## Engine
- Weak chess engine (3 half-moves depth) using minimax algorithm with alpha-beta pruning
- Use a evaluation system to evaluate the position based on:
- Piece Table (allocate points based on position of pieces not just whether the piece exist)
- Eg. pawns are weighted more nearer to promotion
- Overall value of a piece (eg. pawn is 100 points, bishop is 315 points, knight is 300 etc.)


## Move Notation
- Able to print out the basic move notation
- Keep track of time and basic increment