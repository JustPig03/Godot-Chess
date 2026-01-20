extends Node2D

var detective: int = 0


#Stuff i may want the player to adjust in the future?
var pieceScale: float = 4.9   #5.0 looks normal btw

#chessboard:
var chessGrid = []
var chessLine = []

#chess logic
var turn: int = 1 # 1 is white, -1 is black
var legalMoves = []
var underCheck : bool = false
var KingAttackers = []
var turnNumber: int = 1
var whiteCastleS: bool = true #if its false its unable to castle
var blackCastleS: bool = true 
var whiteCastleL: bool = true
var blackCastleL: bool = true
var promotionWaiting: bool = false #is true when promoted, and basically stops input
var tempPromotion: bool = false
var enPassantLegal: bool = false
var enPassantPossible = []  #store where enpassant is possible
var enPassantPawn: Vector2i
var gameended: bool = false

#pieceeaten storage
var pieceEaten : Array = []
var deadpiecesNodes : Array = []
var whitepieceeaten : int = 0
var blackpieceeaten : int = 0
var whitepieceeatenvalue : int = 0
var blackpieceeatenvalue : int = 0

#flipboard
var flipboard : bool = false

#initate the pices
var pieces = {
"pawnWhite": load("res://PieceSprite/whitepawn.png"),
"pawnBlack": load("res://PieceSprite/blackpawn.png"),
"rookWhite": load("res://PieceSprite/whiterook.png"),
"rookBlack": load("res://PieceSprite/blackrook.png"),
"bishopWhite": load("res://PieceSprite/whitebishop.png"),
"bishopBlack": load("res://PieceSprite/blackbishop.png"),
"knightWhite": load("res://PieceSprite/whiteknight.png"),
"knightBlack": load("res://PieceSprite/blackknight.png"),
"queenWhite": load("res://PieceSprite/whitequeen.png"),
"queenBlack": load("res://PieceSprite/blackqueen.png"),
"kingWhite": load("res://PieceSprite/whiteking.png"),
"kingBlack": load("res://PieceSprite/blackking.png")
}

var pieceNumber = {
6: "pawnWhite",
-6: "pawnBlack",
5: "rookWhite",
-5: "rookBlack",
3: "bishopWhite", 
-3: "bishopBlack",
4: "knightWhite", 
-4: "knightBlack",
2: "queenWhite", 
-2:"queenBlack",
1: "kingWhite",
-1: "kingBlack"
}

#movement of pieces
var KnightMoves = [Vector2i(-2, 1), Vector2i(2, 1), Vector2i(-2, -1), Vector2i(2, -1), Vector2i(1, 2), Vector2i(1, -2), Vector2i(-1, -2), Vector2i(-1, 2)]
var BishopMoves = [Vector2i(1,1), Vector2i(-1,-1), Vector2i(1,-1), Vector2i(-1,1)]
var RookMoves = [Vector2i(1,0), Vector2i(-1, 0), Vector2i(0, 1), Vector2i(0,-1)]
var KingMoves = [Vector2i(1,1), Vector2i(1,0), Vector2i(1,-1), Vector2i(0,1), Vector2i(0,-1), Vector2i(-1,-1), Vector2i(-1,0), Vector2i(-1,1)]

var pieceNodes = {}   #this stores key as Vector2i (location of keys) in Vector2i Array/grid form
var selectedPiece = []

#prevents legalmove() from calling itself
var legalmoveflag: bool = false
var helddowntime: float = 0

#send signal to print the moves:
signal printMove
signal popUpPromotion

#variables to allow drag and release:
var dragging: bool = false

#pieces: 1 king, 2 queen, 3 bishop, 4 knight, 5 rook, 6 pawn (- just means black) 0 is empty

#Draw detector
var threefold : Dictionary = {}
var fifthymove : int = 0 # up when there is a move, set to zero when there is a pawn move or a capture


#Engine#
var enginecol: int = 0 #white is 1, black is -1, 0 means engine is disabled
var pieceeval: Dictionary = {
0 : 0, 
1 : 10000, 2 : 900, 3 : 315, 4 : 300, 5 : 500, 6 : 100,
-1 : -10000, -2 : -900, -3 : -315, -4 : -300, -5 : -500, -6 : -100
}
var enginebypass : bool = false
var promobypass : bool = false

#PieceSquareTable
const PSTpawn : Array = [
[500,  500,  500,  500,  500,  500,  500,  500],
[50, 50, 50, 50, 50, 50, 50, 50],
[10, 10, 20, 30, 30, 20, 10, 10],
[5,  5, 10, 27, 27, 10,  5,  5],
[0,  0,  0, 25, 25,  0,  0,  0],
[5, -5,-10,  0,  0,-10, -5,  5],
[5, 10, 10,-25,-25, 10, 10,  5],
[0,  0,  0,  0,  0,  0,  0,  0]
]

const PSTknight : Array =  [
[-50, -40, -30, -30, -30, -30, -40, -50],
[-40, -20,   0,   0,   0,   0, -20, -40],
[-30,   0,  10,  15,  15,  10,   0, -30],
[-30,   5,  15,  20,  20,  15,   5, -30],
[-30,   0,  15,  20,  20,  15,   0, -30],
[-30,   5,  10,  15,  15,  10,   5, -30],
[-40, -20,   0,   5,   5,   0, -20, -40],
[-50, -40, -20, -30, -30, -20, -40, -50]
]

const PSTbishop : Array = [
	[-20, -10, -10, -10, -10, -10, -10, -20],
	[-10,   0,   0,   0,   0,   0,   0, -10],
	[-10,   0,   5,  10,  10,   5,   0, -10],
	[-10,   5,   5,  10,  10,   5,   5, -10],
	[-10,   0,  10,  10,  10,  10,   0, -10],
	[-10,  10,  10,  10,  10,  10,  10, -10],
	[-10,   5,   0,   0,   0,   0,   5, -10],
	[-20, -10, -40, -10, -10, -40, -10, -20]
]

const PSTRook = [
	[0,  0,  0,  0,  0,  0,  0,  0],
	[5, 10, 10, 10, 10, 10, 10,  5],
	[-5, 0,  0,  0,  0,  0,  0, -5],
	[-5, 0,  0,  0,  0,  0,  0, -5],
	[-5, 0,  0,  0,  0,  0,  0, -5],
	[-5, 0,  0,  0,  0,  0,  0, -5],
	[-5, 0,  0,  0,  0,  0,  0, -5],
	[0,  0,  5, 10, 10,  5,  0,  0]
]

const PSTQueen = [
	[-20,-10,-10, -5, -5,-10,-10,-20],
	[-10,  0,  0,  0,  0,  0,  0,-10],
	[-10,  0,  5,  5,  5,  5,  0,-10],
	[ -5,  0,  5,  5,  5,  5,  0, -5],
	[  0,  0,  5,  5,  5,  5,  0, -5],
	[-10,  5,  5,  5,  5,  5,  0,-10],
	[-10,  0,  5,  0,  0,  0,  0,-10],
	[-20,-10,-10, -5, -5,-10,-10,-20]
]

const PSTKingEarly = [
	[-30,-40,-40,-50,-50,-40,-40,-30],
	[-30,-40,-40,-50,-50,-40,-40,-30],
	[-30,-40,-40,-50,-50,-40,-40,-30],
	[-30,-40,-40,-50,-50,-40,-40,-30],
	[-20,-30,-30,-40,-40,-30,-30,-20],
	[-10,-20,-20,-20,-20,-20,-20,-10],
	 [20, 20,  0,  0,  0,  0, 20, 20],
	 [20, 30, 10,  0,  0, 10, 30, 20]
]

#Engine Test#
var test : Array = [
[ -5, -4, -3,  0, 0, -3, -4, -5 ],  # 8
[ -6, -6, -6,  0, -1, -6, -6, -6 ],  # 7
[  0,  0,  0,  0,  0,  0,  0,  0 ],  # 6
[  0,  0,  0, -2, -6,  0,  0,  0 ],  # 5   <-- Qxd5 (Queen on d5), pawn on e5
[  0,  0,  0,  0,  0,  0,  0,  0 ],  # 4
[  0,  0,  4,  0,  0,  4,  0,  0 ],  # 3   <-- Knights: c3 and f3
[  6,  6,  6,  6,  0,  6,  6,  6 ],  # 2   <-- Pawn moved from e2
[  5,  0,  3,  2,  1,  3,  0,  5 ]           # 1
]

var testmove = -1

func _ready() -> void:
	#setting up the chess Grid Array
	chessGrid.append([-5,-4,-3,-2,-1,-3,-4,-5])  #set up last row (black pieces)
	chessGrid.append([-6,-6,-6,-6,-6,-6,-6,-6])  #set up 2nd last
	for i in range(8):
		chessLine.append(0)
	for i in range(4):
		chessGrid.append(chessLine.duplicate())
	chessGrid.append([6,6,6,6,6,6,6,6])
	chessGrid.append([5,4,3,2,1,3,4,5])
	#print(evaluator(testposition, testmove))
	threefold[chessGrid] = 1
	SetupPieces()

func _process(delta: float) -> void:
	DetectTouch()
	chessEngine()
	#time decrement: (-10000 means that it is infinite time, so there is no time decrement)
	if !gameended and Global.whitetimer != -10000:
		if turn == 1 and turnNumber != 1: #turnNumber != 1 is to ensure that first move doens't drain
			Global.whitetimer -= delta
		elif turn == -1:
			Global.blacktimer -= delta
	
	if !Global.started:
		if turn == -1:
			Global.started = true
	
	#coloring the text of whitetimer / blacktimer during their turn
	if turn == 1:
		$ChessBoard/WhitesTimer.modulate = Color.GREEN
		$ChessBoard/BlacksTimer.modulate = Color.WHITE
	elif turn == -1:
		$ChessBoard/WhitesTimer.modulate = Color.WHITE
		$ChessBoard/BlacksTimer.modulate = Color.GREEN
	
	if Global.whitetimer == -10000:
		$ChessBoard/WhitesTimer.text = "∞"; 	$ChessBoard/WhitesTimer.size *= 1.5
		$ChessBoard/BlacksTimer.text = "∞"; $ChessBoard/BlacksTimer.size *= 1.5
	#printing out the text of time
	else:
		if Global.whitetimer >= 0:
			$ChessBoard/WhitesTimer.text = str(int(Global.whitetimer/60)) + ":" + str(int(Global.whitetimer)%60).pad_zeros(2)
		else:
			$ChessBoard/WhitesTimer.text = "Timeout, BLACKWIN"
		if Global.blacktimer >= 0:
			$ChessBoard/BlacksTimer.text = str(int(Global.blacktimer/60)) + ":" + str(int(Global.blacktimer)%60).pad_zeros(2)
		else:
			$ChessBoard/BlacksTimer.text = "Timeout, WHITEWIN"
	
	
	if selectedPiece.size() == 1: helddowntime += delta
	else: helddowntime = 0
	#legal move is only called if there is a piece selected AND piece selected is the correct piece turn:
	if selectedPiece.size() == 1 and Input.is_action_pressed("leftclick") and helddowntime > 0.05:
		heldDown()
	
	if selectedPiece.size() == 1 and Input.is_action_just_released("leftclick") and dragging:
		letDown()
	
	if selectedPiece.size() == 1 and chessGrid[selectedPiece[0].y][selectedPiece[0].x] * turn > 0 and legalmoveflag == false:
		legalMove(chessGrid)
		legalmoveflag = true
	
	if selectedPiece.size() != 1:
		legalmoveflag = false
	
	MovePiece()

func SetupPieces():
#only called at the start of the game
	for i in range(8):
		for j in range(8):
			for k in pieceNumber:
				if chessGrid[i][j] == k:
					TexturePieces(pieceNumber[k], Vector2i(j*100 + 140 + 50, i*100 +140 + 50))

func TexturePieces(piece: String, placement: Vector2i):
	var x = Sprite2D.new()
	x.texture = pieces[piece].duplicate()
	x.position = placement
	x.scale *= pieceScale
	add_child(x)
	pieceNodes[Vector2i((placement.x-140)/100, ((placement.y-140)/100))] = x

func DetectTouch():
#Detecting when Player Touch something and outputing into array
	if Input.is_action_just_pressed("leftclick") and !promotionWaiting and !gameended:
		var position: Vector2 = get_global_mouse_position()
		var arrayposition: Vector2i
		if !flipboard:
			arrayposition.x = int((position.x - 140) /100)
			arrayposition.y = int((position.y - 140) /100)
		else:
			arrayposition.x = int((800 - (position.x - 140)) /100)
			arrayposition.y = int((800 - (position.y - 140)) /100)
		if arrayposition.x in range(8) and arrayposition.y in range(8):
			#if underCheck, you have to move your king:
			#if not selected anything and undercheck:
			if selectedPiece.size() == 0 and underCheck:
				if arrayposition == KingFinder(turn, chessGrid):   # select KING to move
					selectedPiece.append(arrayposition)
					queue_redraw()
					return
				else: # selecet Other pieces
					for x in KingAttackers:
						if isKingSafe(chessGrid, x, -turn) is Array:  #returns an array of position of enenmies piece that are checking the king
							if arrayposition in isKingSafe(chessGrid, x, -turn) and isKingSafe(chessGrid, x, -turn).size() == 1:
								selectedPiece.append(arrayposition)
								queue_redraw()
								return
				# to block
				selectedPiece.append(arrayposition)
				legalMove(chessGrid)
				if legalMoves.size() > 0:
						queue_redraw()
						return
				selectedPiece.clear()
			# if selected something already (and before that if size == 1, legalMove approved or else legalMove will make clear array)
			# OR if where you click is a piece that is YOUR PIECE in YOUR TURN
			elif selectedPiece.size() == 1 or chessGrid[arrayposition.y][arrayposition.x]*turn > 0:
					selectedPiece.append(arrayposition)
					queue_redraw()
			#if selected
			else:
				selectedPiece.clear()

func heldDown():
	dragging = true
	var mousepos = get_global_mouse_position()
	pieceNodes[Vector2i(selectedPiece[0].x, selectedPiece[0].y)].position = mousepos

func letDown():
	dragging = false
	var mousepos = get_global_mouse_position()
	var arrayposition: Vector2i
	if !flipboard:
		arrayposition.x = int((mousepos.x - 140) /100)
		arrayposition.y = int((mousepos.y - 140) /100)
	else:
		arrayposition.x = int((800 - (mousepos.x - 140) )/100)
		arrayposition.y = int((800 - (mousepos.y - 140) )/100)
	if arrayposition != selectedPiece[0]: #if u drop on the same spot
		selectedPiece.append(arrayposition)
	else:
		if !flipboard:
			pieceNodes[Vector2i(selectedPiece[0].x, selectedPiece[0].y)].position = Vector2i(selectedPiece[0].x * 100 + 140 + 50, selectedPiece[0].y * 100 + 140 + 50)
		else:
			pieceNodes[Vector2i(selectedPiece[0].x, selectedPiece[0].y)].position = Vector2i(1040 - (selectedPiece[0].x * 100 + 140 + 50), 1040 - (selectedPiece[0].y * 100 + 140 + 50))
	queue_redraw()
	

func MovePiece():
	if selectedPiece.size() == 2 and !promotionWaiting:
		if selectedPiece[1] in legalMoves or enginebypass:
			if chessGrid[selectedPiece[1].y][selectedPiece[1].x] != 0:
				piecetaken(Vector2i(selectedPiece[1].x,selectedPiece[1].y))
				
			#print(pieceNodes)
			#print("here")
			
			#Short Castling
			if chessGrid[selectedPiece[0].y][selectedPiece[0].x] == turn and selectedPiece[1] == Vector2i(6,7 if turn == 1 else 0) and selectedPiece[0].x == 4:
				if turn == 1: whiteCastleS = false
				else: blackCastleS = false
				chessGrid[selectedPiece[1].y][selectedPiece[1].x] = chessGrid[selectedPiece[0].y][selectedPiece[0].x]
				chessGrid[7 if turn == 1 else 0][5] = turn * 5  #placae rook into the array
				chessGrid[7 if turn == 1 else 0][7] = 0   #remove old rook from array
				chessGrid[7 if turn == 1 else 0][4] = 0   #remove old king from array
				
				var xpos = 5 * 100 + 140 + 50
				var ypos = (7 if turn == 1 else 0) * 100 + 140 + 50
				pieceNodes[Vector2i(7,7 if turn == 1 else 0)].position = Vector2i((1080-xpos) if flipboard else xpos, (1080-ypos) if flipboard else ypos)
				pieceNodes[Vector2i(5,7 if turn == 1 else 0)] = pieceNodes[Vector2i(7,7 if turn == 1 else 0)]
				pieceNodes.erase(Vector2i(7,7 if turn == 1 else 0))
				emit_signal("printMove", chessGrid, turnNumber, turn, 1)
			
			#Long Castling
			elif chessGrid[selectedPiece[0].y][selectedPiece[0].x] == turn and selectedPiece[1] == Vector2i(2,7 if turn == 1 else 0) and selectedPiece[0].x == 4:
				if turn == 1: whiteCastleL = false
				else: blackCastleL = false
				chessGrid[selectedPiece[1].y][selectedPiece[1].x] = chessGrid[selectedPiece[0].y][selectedPiece[0].x]
				chessGrid[7 if turn == 1 else 0][3] = turn * 5  #placae rook into the array
				chessGrid[7 if turn == 1 else 0][0] = 0   #remove old rook from array
				chessGrid[7 if turn == 1 else 0][4] = 0   #remove old king from array
				
				var xpos = 3 * 100 + 140 + 50
				var ypos = (7 if turn == 1 else 0) * 100 + 140 + 50
				pieceNodes[Vector2i(0,7 if turn == 1 else 0)].position = Vector2i((1080-xpos) if !flipboard else xpos, (1080-ypos) if !flipboard else ypos)
				pieceNodes[Vector2i(3,7 if turn == 1 else 0)] = pieceNodes[Vector2i(0,7 if turn == 1 else 0)]
				pieceNodes.erase(Vector2i(0,7 if turn == 1 else 0))
				emit_signal("printMove", chessGrid, turnNumber, turn, 2)
				
				
			else:
				#if rook move / if king move --> unable to castle
				if chessGrid[selectedPiece[0].y][selectedPiece[0].x] in [5,-5]:
					if selectedPiece[0] == Vector2i(0,0): blackCastleL = false
					elif selectedPiece[0] == Vector2i(7,0): blackCastleS = false 
					elif selectedPiece[0] == Vector2i(0,7): whiteCastleL = false
					elif selectedPiece[0] == Vector2i(7,7): whiteCastleS = false
				if chessGrid[selectedPiece[0].y][selectedPiece[0].x] in [1,-1]:
					if turn == -1: blackCastleL = false; blackCastleS = false
					if turn == 1: whiteCastleL = false; whiteCastleS = false
				chessGrid[selectedPiece[1].y][selectedPiece[1].x] = chessGrid[selectedPiece[0].y][selectedPiece[0].x]
				chessGrid[selectedPiece[0].y][selectedPiece[0].x] = 0
			
			#enpassant removal of the killed pawn
			#if selected piece is eaten:
				if selectedPiece[1] == Vector2i(enPassantPawn.x, enPassantPawn.y + (-1 if turn == 1 else 1)) and enPassantLegal:
					piecetaken(enPassantPawn)
					emit_signal("printMove", chessGrid, turnNumber, turn, 3)
				else:
					emit_signal("printMove", chessGrid, turnNumber, turn, 0)
			#print(turnNumber, chessGrid)
			#print()
			
			#Shifts the Piece to the correct Position
			if pieceNodes.has(selectedPiece[0]):
				var xpos = selectedPiece[1].x * 100 + 140 + 50
				var ypos = selectedPiece[1].y * 100 + 140 + 50
				pieceNodes[selectedPiece[0]].position = Vector2i((1080 - xpos) if flipboard else xpos, (1080-ypos) if flipboard else ypos)
				
			#Ensure the node dictionary changes its keys
				pieceNodes[selectedPiece[1]] = pieceNodes[selectedPiece[0]]
				pieceNodes.erase(selectedPiece[0])
			
			
			if chessGrid[selectedPiece[1].y][selectedPiece[1].x] in [6,-6] and selectedPiece[1].y == (7 if turn == -1 else 0):
				promotionWaiting = true
				if !promobypass: emit_signal("popUpPromotion", selectedPiece[1])
				return
			
			endstate()
				
		else:
			var xpos = selectedPiece[0].x * 100 + 140 + 50
			var ypos = selectedPiece[0].y * 100 + 140 + 50
			pieceNodes[Vector2i(selectedPiece[0].x, selectedPiece[0].y)].position = Vector2i((1080-xpos) if flipboard else xpos, (1080-ypos) if flipboard else ypos )
			selectedPiece.clear()
			legalMoves.clear()


func _draw():
	for i in selectedPiece:
		var xpos = i.x * 100 + 140
		var ypos = i.y * 100 + 140
		draw_rect(Rect2((980-xpos) if flipboard else xpos, (980-ypos) if flipboard else ypos ,100, 100), Color.DARK_GRAY, false, 10)
	for i in legalMoves:
		var xpos = i.x * 100 + 140
		var ypos = i.y * 100 + 140
		draw_rect(Rect2((980-xpos) if flipboard else xpos, (980-ypos) if flipboard else ypos, 100, 100), Color.GREEN, false, 10)

func piecetaken(location: Vector2i):
	print(pieceNumber[chessGrid[selectedPiece[1].y][selectedPiece[1].x]] + "got taken!")
	pieceEatenDisplay(chessGrid[selectedPiece[1].y][selectedPiece[1].x]) 
	pieceNodes[location].queue_free()
	pieceNodes.erase(location)
	fifthymove = 0
	threefold.clear()

#is called when there is 1 piece selected:
func legalMove(chessGrid2: Array, turn2: int = turn, underCheck2: bool = underCheck):
		legalMoves.clear()
		var pT: int = chessGrid2[selectedPiece[0].y][selectedPiece[0].x] #pieceType 1,4,-2
		var pL: Vector2i = Vector2i(selectedPiece[0].x, selectedPiece[0].y)  #location (x,y)
		
		#for pawn:
		if pT in [-6,6]:
			#pawn one step:
			if pL.y + (-1 if turn2 == 1 else 1) in range(8): #the reason im doing this is for evaluation of the engine
				if chessGrid2[pL.y + (-1 if turn2 == 1 else 1)][pL.x] == 0: #ensure that forward doesnt have anything
					legalMoves.append(Vector2i(pL.x, pL.y +(-1 if turn2 == 1 else 1)))  #when i return value need to swap x,y
			
			#pawn two steps:
			if pL.y == (6 if turn2 == 1 else 1) and chessGrid2[pL.y + (-1 if turn2 == 1 else 1)][pL.x] == 0 and chessGrid2[pL.y + (-2 if turn2 == 1 else 2)][pL.x] == 0:
				legalMoves.append(Vector2i(pL.x, pL.y +(-2 if turn2 == 1 else 2)))
			
			if enPassantLegal:
				if pL in enPassantPossible:
					legalMoves.append(Vector2i(enPassantPawn.x, enPassantPawn.y + (-1 if turn2 == 1 else 1)))
			
			
			#pawn eating mechanic:
			for a in [-1, 1]:
				if pL.x + a in range(8) and pL.y + (-1 if turn2 == 1 else 1) in range(8):
					if chessGrid2[pL.y + (-1 if turn2 == 1 else 1)][pL.x + a] * turn2 < 0:
						legalMoves.append(Vector2i(pL.x +a, pL.y + (-1 if turn2 == 1 else 1)))
		
		#for knight
		if pT in [-4, 4]:
			#knight possible movement
			for i in KnightMoves:
				if pL.x + i.x in range(8) and pL.y + i.y in range(8):
					if chessGrid2[pL.y + i.y][pL.x + i.x] * turn2 <= 0:
						legalMoves.append(Vector2i(pL.x + i.x, pL.y + i.y))
		
		#for Rook
		if pT in [-5, 5]:
			for i in RookMoves:
				for j in range(1,8):
					var newpL: Vector2i = pL + i * j
					if newpL.y in range(8) and newpL.x in range(8): 
						if chessGrid2[newpL.y][newpL.x] == 0:
							legalMoves.append(Vector2i(newpL.x, newpL.y))
						elif chessGrid2[newpL.y][newpL.x] * turn2 < 0:
							legalMoves.append(Vector2i(newpL.x, newpL.y)); break
						else: break
		
		#for Bishop
		if pT in [-3, 3]:
			for i in BishopMoves:
				for j in range(1,8):
					var newpL: Vector2i = pL + i * j
					if newpL.y in range(8) and newpL.x in range(8): 
						if chessGrid2[newpL.y][newpL.x] == 0:
							legalMoves.append(Vector2i(newpL.x, newpL.y))
						elif chessGrid2[newpL.y][newpL.x] * turn2 < 0:
							legalMoves.append(Vector2i(newpL.x, newpL.y)); break
						else: break
		
		if pT in [2, -2]:
			for i in RookMoves:
				for j in range(1,8):
					var newpL: Vector2i = pL + i * j
					if newpL.y in range(8) and newpL.x in range(8): 
						if chessGrid2[newpL.y][newpL.x] == 0:
							legalMoves.append(Vector2i(newpL.x, newpL.y))
						elif chessGrid2[newpL.y][newpL.x] * turn2 < 0:
							legalMoves.append(Vector2i(newpL.x, newpL.y)); break
						else: break
			
			for i in BishopMoves:
				for j in range(1,8):
					var newpL: Vector2i = pL + i * j
					if newpL.y in range(8) and newpL.x in range(8): 
						if chessGrid2[newpL.y][newpL.x] == 0:
							legalMoves.append(Vector2i(newpL.x, newpL.y))
						elif chessGrid2[newpL.y][newpL.x] * turn2 < 0:
							legalMoves.append(Vector2i(newpL.x, newpL.y)); break
						else: break
		
		
		###
		#King Moves:
		if pT in [1, -1]:
			for i in KingMoves:
				var newpL: Vector2i = pL + i
				if newpL.y in range(8) and newpL.x in range(8):
					var chessGrid3 = chessGrid2.duplicate(true)
					chessGrid3[pL.y][pL.x] = 0
					if chessGrid2[newpL.y][newpL.x]*turn2 <= 0 and isKingSafe(chessGrid3, Vector2i(newpL.x,newpL.y),turn2) is not Array:
						legalMoves.append(Vector2i(newpL.x, newpL.y))
			
			if !underCheck2 and (whiteCastleS if turn2 == 1 else blackCastleS):
				#Short Castling:
				#ensure that king is safe both square
				if isKingSafe(chessGrid2, (Vector2i(5,7) if turn2 == 1 else Vector2i(5,0)),turn2) is not Array and isKingSafe(chessGrid2, (Vector2i(6,7) if turn2 == 1 else Vector2i(6,0)),turn2) is not Array:
					#ensure that both are empty
					if chessGrid2[7 if turn2 == 1 else 0][5] == 0 and chessGrid2[7 if turn2 == 1 else 0][6] == 0:
						legalMoves.append(Vector2i(6,7 if turn2 == 1 else 0))
				
			if !underCheck2 and (whiteCastleL if turn2 == 1 else blackCastleL):
				#Long Castling:
				if isKingSafe(chessGrid2, (Vector2i(2,7) if turn2 == 1 else Vector2i(2,0)),turn2) is not Array and isKingSafe(chessGrid2, (Vector2i(3,7) if turn2 == 1 else Vector2i(3,0)),turn2) is not Array:
					#ensure that both are empty
					if chessGrid2[7 if turn2 == 1 else 0][2] == 0 and chessGrid2[7 if turn2 == 1 else 0][3] == 0:
						legalMoves.append(Vector2i(2,7 if turn2 == 1 else 0))
		
		#check for checks:
		#if under check and you did not choose KING:
		if underCheck2 and KingFinder(turn2, chessGrid2) not in selectedPiece and KingAttackers[0] in legalMoves:
			var temparr2 = []
			for i in legalMoves:
				var temp = chessGrid2[i.y][i.x]  # save the final destination piece in case it isnt 0
				#shifts the piece to the location where it wanna be
				chessGrid2[i.y][i.x] = chessGrid2[selectedPiece[0].y][selectedPiece[0].x] 
				chessGrid2[selectedPiece[0].y][selectedPiece[0].x] = 0
				if isKingSafe(chessGrid2, KingFinder(turn2, chessGrid2), turn2) is Array:
					temparr2.append(i)
				chessGrid2[selectedPiece[0].y][selectedPiece[0].x] = chessGrid2[i.y][i.x]
				chessGrid2[i.y][i.x] = temp
		
			for i in temparr2:
				legalMoves.erase(i)
			#legalMoves.append(Vector2i(KingAttackers[0]))  #ensure that pieces you choose that can attack KING atually attacks King
		
		#check if i move a piece, will i get checked???
		var temparr = []
		for i in legalMoves:
			var temp = chessGrid2[i.y][i.x] 
			chessGrid2[i.y][i.x] = chessGrid2[selectedPiece[0].y][selectedPiece[0].x] 
			chessGrid2[selectedPiece[0].y][selectedPiece[0].x] = 0
			if isKingSafe(chessGrid2, KingFinder(turn2, chessGrid2), turn2) is Array:
				temparr.append(i)
			chessGrid2[selectedPiece[0].y][selectedPiece[0].x] = chessGrid2[i.y][i.x]
			chessGrid2[i.y][i.x] = temp
		
		for i in temparr:
			legalMoves.erase(i)

#function return 0 if safe, array if not safe
func isKingSafe(chessGrid2: Array, position: Vector2i, kingCol: int):  # input should be (x, y), kingtype: 1 for white, -1 for black
	#rook / queen acting as rook
	var checkers = []   #
	
	for i in RookMoves:
		for j in range(1,8):
			var newpL: Vector2i = position + i * j
			if newpL.y in range(8) and newpL.x in range(8):  
				if chessGrid2[newpL.y][newpL.x] * kingCol in [-5, -2]:  #blackrook * white king = gg
					checkers.append(Vector2i(newpL.x, newpL.y))
				elif chessGrid2[newpL.y][newpL.x] * kingCol != 0:
					break
	
	#bishop / queen acting as bishop:
	for i in BishopMoves:
		for j in range(1,8):
			var newpL: Vector2i = position + i * j
			if newpL.y in range(8) and newpL.x in range(8):  
				if chessGrid2[newpL.y][newpL.x] * kingCol in [-3, -2]:
					checkers.append(Vector2i(newpL.x, newpL.y))
				elif chessGrid2[newpL.y][newpL.x] * kingCol != 0:
					break
	
	#Knight
	for i in KnightMoves:
		var newpL = position + i
		if newpL.x in range(8) and newpL.y in range(8):
			if chessGrid2[newpL.y][newpL.x] * kingCol == -4:
				checkers.append(Vector2i(newpL.x, newpL.y))
	
	#diagonal check for pawn
	for i in [Vector2i(-1,-kingCol), Vector2i(1,-kingCol)]:
		var newpL = position + i
		if newpL.x in range(8) and newpL.y in range(8):
			if chessGrid2[newpL.y][newpL.x] * kingCol == -6:
				checkers.append(Vector2i(newpL.x, newpL.y))
	
	for i in KingMoves:
		var newpL = position + i
		if newpL.x in range(8) and newpL.y in range(8):
			if chessGrid2[newpL.y][newpL.x] * kingCol == -1:
				checkers.append(Vector2i(newpL.x, newpL.y))
	
	if checkers.size() > 0:
		return checkers
	
	if checkers.size() == 0:
		return 0
	# reverse check the king
	#so if black king --> check white knight, check white rook ,check white

#function take in 1 or -1 , output Vector2i(x,y) where the king is
func KingFinder(kingcol: int, chessGridcopy: Array):
	for x in range(8):
		for y in range(8):
			if chessGridcopy[y][x] == kingcol:
				return Vector2i(x,y)

#return 1 if checkmate, return 0 if NOT CHECKMATE
func checkMate(chessGrid2: Array, turn2: int):  #use turn to check
	for i in range(8):
		for j in range(8):
			if chessGrid2[i][j]*turn2 > 0: #check that it is the piece
				legalMoves.clear()
				selectedPiece.clear()
				selectedPiece.append(Vector2i(j,i))
				legalMove(chessGrid2, turn2, true)
				
				#if there is a legal move
				if legalMoves.size() > 0:
					legalMoves.clear()
					selectedPiece.clear()
					return 0
	
	legalMoves.clear()
	selectedPiece.clear()
	return 1

func _on_promotion_menu_id_pressed(id: int) -> void:
	promotion(id)

func promotion(id : int):
	# removes the pawn:
	if pieceNodes.has(selectedPiece[1]):
		pieceNodes[selectedPiece[1]].queue_free()
		pieceNodes.erase(selectedPiece[1])
	# pawns the new piece:
	TexturePieces(pieceNumber[id*turn], Vector2i(selectedPiece[1].x*100+140+50, selectedPiece[1].y*100+140+50))
	chessGrid[selectedPiece[1].y][selectedPiece[1].x] = id * turn
	#this line is for printing out
	$PastMoves.text += "=" + ("Q" if id == 2 else "B" if id == 3 else "N" if id == 4 else "R" if id == 5 else "")
	tempPromotion = true
	promotionWaiting = false #ensure that the game continues
	endstate()
	queue_redraw()

func endstate():
	if true:
		if true:
			#add increment:
			if Global.whitetimer >= 0 and Global.blacktimer >= 0:
				if turn == -1: Global.blacktimer += Global.increment
				elif turn == 1: Global.whitetimer += Global.increment
			
			enPassantPossible.clear()
			#check for enpassant:
			
			if chessGrid[selectedPiece[1].y][selectedPiece[1].x] in [6,-6]:
				#if its a pawn move i can clear dictionary:
				threefold.clear()
				fifthymove = 0
				enPassantPawn = selectedPiece[1]
				#if white pawn move frm 6 to 4: check surrounding pawn
				if turn == 1 and selectedPiece[0].y == 6 and selectedPiece[1].y == 4:
					if selectedPiece[1].x + 1 in range(8): if chessGrid[selectedPiece[1].y][selectedPiece[1].x+1]: enPassantLegal = true; enPassantPossible.append(Vector2i(selectedPiece[1].x+1, selectedPiece[1].y))
					if selectedPiece[1].x - 1 in range(8): if chessGrid[selectedPiece[1].y][selectedPiece[1].x-1]: enPassantLegal = true; enPassantPossible.append(Vector2i(selectedPiece[1].x-1, selectedPiece[1].y))
				
				#if black pawn move from 1 to 3: check surrounding pawn 
				if turn == -1 and selectedPiece[0].y == 1 and selectedPiece[1].y == 3:
					if selectedPiece[1].x + 1 in range(8): if chessGrid[selectedPiece[1].y][selectedPiece[1].x+1]: enPassantLegal = true; enPassantPossible.append(Vector2i(selectedPiece[1].x+1, selectedPiece[1].y))
					if selectedPiece[1].x - 1 in range(8): if chessGrid[selectedPiece[1].y][selectedPiece[1].x-1]: enPassantLegal = true; enPassantPossible.append(Vector2i(selectedPiece[1].x-1, selectedPiece[1].y))
			
			print(enPassantPossible)
			#if no enpassant cases: print false
			if enPassantPossible.size() == 0:
				enPassantLegal = false
			
			#3fold:
			if not threefold.has(chessGrid):
				threefold[chessGrid] = 1
			else:
				threefold[chessGrid] += 1
			
			for a in threefold.values():
				if a >= 3:
					gamedraw()
			if fifthymove == 50:
				gamedraw()
			
			turn *= -1 #switches between black and white
			if turn == 1: turnNumber += 1; fifthymove += 1  #incremenent the move number
			selectedPiece.clear()  #i clear this to make sure it is emtpy to accept new move
			legalMoves.clear()
			
			if isKingSafe(chessGrid, KingFinder(turn, chessGrid), turn) is Array:
				KingAttackers = isKingSafe(chessGrid, KingFinder(turn, chessGrid), turn)
				print("check")
				underCheck = true
				$PastMoves.text += "+"
				if checkMate(chessGrid, turn) == 1:
					print("checkmate")
					$PastMoves.text += "#"
			else:
				underCheck = false
				stalemate()

###########################
#Pass the array, and whose turn issit ~for now no
func evaluator(CurrentPos: Array, turncol: int): #takes in current board (array position) status and evaluates it
	#check for checkmate and award CRAZY POINTS:
	var score: int = 0
	if isKingSafe(CurrentPos, KingFinder(1,CurrentPos),1) is Array:
		KingAttackers = isKingSafe(CurrentPos, KingFinder(1, CurrentPos), 1)
		if checkMate(CurrentPos, 1) == 1:
			return -6400
	if isKingSafe(CurrentPos, KingFinder(-1,CurrentPos),-1) is Array:
		KingAttackers = isKingSafe(CurrentPos, KingFinder(-1, CurrentPos), -1)
		if checkMate(CurrentPos, -1) == 1:
			return 6400
	
	#else evaluate based on adding the pieces
	for i in range(8):
		for j in range(8):
			score += pieceeval[CurrentPos[i][j]]
			if CurrentPos[i][j] == 6: # if it is a pawn
				score += PSTpawn[i][j]
			elif CurrentPos[i][j] == -6: # if it is a BLACK pawn
				score -= PSTpawn[7-i][j]
			elif CurrentPos[i][j] == 4:    score += PSTknight[i][j]
			elif CurrentPos[i][j] == -4:   score -= PSTknight[7-i][j]
			elif CurrentPos[i][j] == 5:    score += PSTRook[i][j]
			elif CurrentPos[i][j] == -5:   score -= PSTRook[7-i][j]
			elif CurrentPos[i][j] == 3:    score += PSTbishop[i][j]
			elif CurrentPos[i][j] == -3:   score -= PSTbishop[7-i][j]
			elif CurrentPos[i][j] == 2:    score += PSTQueen[i][j]
			elif CurrentPos[i][j] == -2:   score -= PSTQueen[7-i][j]
			elif CurrentPos[i][j] == 1:    score += PSTKingEarly[i][j]
			elif CurrentPos[i][j] == -1:   score -= PSTKingEarly[7-i][j]
	
	score += randi_range(-5,5)  #random for engine
	return score


func _on_engine_toggled(toggled_on: bool) -> void:
	var button = toggled_on
	if button: enginecol = -1
	else: enginecol = 0
	UICOLOUR()

func UICOLOUR():
	if enginecol == 1:
		$Settings/SettingPopUp/VBoxContainer/SelectEngineColour/White.modulate = Color.GREEN
		$Settings/SettingPopUp/VBoxContainer/SelectEngineColour/Black.modulate = Color.WHITE
	elif enginecol == 0:
		$Settings/SettingPopUp/VBoxContainer/SelectEngineColour/White.modulate = Color.WHITE
		$Settings/SettingPopUp/VBoxContainer/SelectEngineColour/Black.modulate = Color.WHITE
	else:
		$Settings/SettingPopUp/VBoxContainer/SelectEngineColour/White.modulate = Color.WHITE
		$Settings/SettingPopUp/VBoxContainer/SelectEngineColour/Black.modulate = Color.GREEN

func _on_white_pressed() -> void:
	if enginecol !=0: enginecol = 1
	UICOLOUR()

func _on_black_pressed() -> void:
	if enginecol !=0: enginecol = -1
	UICOLOUR()

func chessEngine():
	if enginecol in [1, -1]: #engine will start
		if enginecol == -1: #engine plays black
			if turn == -1:
				var em = allmovefinder(chessGrid, turn)
				enginebypass = true
				var enginemove1 = Vector2i(em.y,em.x)
				var enginemove2 = Vector2i(em.w,em.z)
				
				for i in range(8):
					if enginemove2 == Vector2i(i,7):
						if chessGrid[em.x][em.y] == enginecol *6:
							print("promoting omfg")
							promobypass = true
				selectedPiece.append(enginemove1)
				selectedPiece.append(enginemove2)
				MovePiece()
				if promobypass:
					promotion(2)
					promobypass = false
				enginebypass = false

func allmovefinder(tiles: Array, turn2: int):
	var store : Dictionary = {}
	for i in range(8):
		for j in range(8):
			if turn2 * tiles[i][j] > 0:
				selectedPiece.clear()
				selectedPiece.append(Vector2i(j,i))
				legalMove(tiles, turn2)
				var templegal = legalMoves.duplicate()
				var piecetype = tiles[i][j]
				
				for k in templegal:
					var temptiles = tiles.duplicate(true)
					temptiles[i][j] = 0
					temptiles[k.y][k.x] = piecetype
					
					var x = (-10000 if turn2 == 1 else 10000)
					if store.size() > 0:
						x = store.keys().max() if turn2 == 1 else store.keys().min()
					if x == null: x = (-10000 if turn2 == 1 else 10000)
					store[depth(temptiles, -turn2,x)] = Vector4i(i, j, k.y, k.x)
				selectedPiece.clear()
	
	var max_value
	if turn2 == 1:
		max_value = store.keys().max()
	else:
		max_value = store.keys().min()
	return store[max_value]

func depth(tiles2: Array, turn2: int, prune2: int):
	var store2 = null
	for i in range(8):
		for j in range(8):
			if turn2 * tiles2[i][j] > 0:
				selectedPiece.clear()
				selectedPiece.append(Vector2i(j,i))
				legalMove(tiles2,turn2)
				var templegal2 : Array = legalMoves.duplicate()
				var piecetype : int = tiles2[i][j]
				
				for k in templegal2:
					var b : int = tiles2[k.y][k.x] 
					tiles2[i][j] = 0
					tiles2[k.y][k.x] = piecetype
					
					var x = (-10000 if turn2 == 1 else 10000)
					if store2 != null: x = store2
					
					var a : int = depth2(tiles2, -turn2, x)
					if turn2 == -1:
						if store2 == null: store2 = a
						else: store2 = min(store2, a)
						if prune2 >= store2: return store2
					elif turn2 == 1:
						if store2 == null: store2 = a
						else: store2 = max(store2, a)
						if prune2 <= store2: return store2
					
					tiles2[i][j] = piecetype
					tiles2[k.y][k.x] = b
					
	return store2

#Btw i have to do this instead of calling recursion cause godot sucks and cant do more than 1024 idk
func depth2(tiles2: Array, turn2: int, prune: int):
	var store2 = null
	for i in range(8):
		for j in range(8):
			if turn2 * tiles2[i][j] > 0:
				selectedPiece.clear()
				selectedPiece.append(Vector2i(j,i))
				legalMove(tiles2,turn2)
				var templegal2 : Array = legalMoves.duplicate()
				var piecetype : int = tiles2[i][j]
				
				for k in templegal2:
					var b : int = tiles2[k.y][k.x]
					tiles2[i][j] = 0
					tiles2[k.y][k.x] = piecetype
					
					var a : int = evaluator(tiles2, turn2)
					tiles2[i][j] = piecetype
					tiles2[k.y][k.x] = b
					
					if turn2 == -1:
						if store2 == null: store2 = a
						else: store2 = min(store2, a)
						if prune >= store2: return store2
					elif turn2 == 1:
						if store2 == null: store2 = a
						else: store2 = max(store2, a)
						if prune <= store2: return store2
	return store2

func pieceEatenDisplay(i : int):
	var x = Sprite2D.new()
	x.texture = pieces[pieceNumber[i]].duplicate()
	if i > 0:
		x.position = Vector2i(400 + 15*whitepieceeaten,80)
		whitepieceeaten += 1
		whitepieceeatenvalue += i
	if i < 0:
		x.position = Vector2i(400 + 15*blackpieceeaten, 1000)
		blackpieceeaten += 1
		blackpieceeatenvalue -= 1
	x.scale *= pieceScale*0.8
	$ChessBoard/WhiteEatenValue.text = str(whitepieceeaten)
	$ChessBoard/BlackEatenvalue.text = str(blackpieceeaten)
	add_child(x)

func gamedraw():
	$PastMoves.text += "1/2-1/2"
	gameended = true

func stalemate():
	for i in range(8):
		for j in range(8):
			if chessGrid[i][j] * turn > 0:
				selectedPiece.append(Vector2i(j,i))
				legalMove(chessGrid, turn, false)
				selectedPiece.clear()
				
				if legalMoves.size() != 0:
					print("legalmove", j,i,legalMoves)
					legalMoves.clear()
					return
				legalMoves.clear()
	print("stalefmate")
	gamedraw()


func _on_flip_board_pressed() -> void:
	flipboard = !flipboard
	print(flipboard)
	for i in pieceNodes.values():
		i.position.y = 1080 - i.position.y
		i.position.x = 1080 - i.position.x
