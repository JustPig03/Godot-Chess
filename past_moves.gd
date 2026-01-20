extends Label
var windowSize: Vector2i
#script

var textSize: float = 2.0

var STARTBOARD = [
	[-5, -4, -3, -2, -1, -3, -4, -5],  # 8
	[-6, -6, -6, -6, -6, -6, -6, -6],  # 7
	[ 0,  0,  0,  0,  0,  0,  0,  0],  # 6
	[ 0,  0,  0,  0,  0,  0,  0,  0],  # 5
	[ 0,  0,  0,  0,  0,  0,  0,  0],  # 4
	[ 0,  0,  0,  0,  0,  0,  0,  0],  # 3
	[ 6,  6,  6,  6,  6,  6,  6,  6],  # 2
	[ 5,  4,  3,  2,  1,  3,  4,  5],  # 1
]
var PASTMOVE = []   
# 0, 1st move
# 0
#turnNumber: 1   - 1
# turnNumber: 1 (-1) - 2
#turnNumber: 2       - 3
#turnNumber: 2 (-1)   - 4
#turnNumber: 3     - 5
#turnNumber: 3      -6 

var KnightMoves = [Vector2i(-2, 1), Vector2i(2, 1), Vector2i(-2, -1), Vector2i(2, -1), Vector2i(1, 2), Vector2i(1, -2), Vector2i(-1, -2), Vector2i(-1, 2)]
var BishopMoves = [Vector2i(1,1), Vector2i(-1,-1), Vector2i(1,-1), Vector2i(-1,1)]
var RookMoves = [Vector2i(1,0), Vector2i(-1, 0), Vector2i(0, 1), Vector2i(0,-1)]
var KingMoves = [Vector2i(1,1), Vector2i(1,0), Vector2i(1,-1), Vector2i(0,1), Vector2i(0,-1), Vector2i(-1,-1), Vector2i(-1,0), Vector2i(-1,1)]

var converter = {
0 : "a", 1 : "b", 2 : "c", 3 : "d", 4 : "e", 5: "f", 6: "g", 7: "h"
}

var intconverter = {
0: "8", 1 : "7", 2 : "6", 3 : "5", 4 : "4", 5 : "3", 6 : "2", 7 : "1"
}

var details = []
var ARRNUM: int


func _ready() -> void:
	windowSize = get_viewport_rect().size
	position = Vector2i( 1200, windowSize.y/2 - 300)
	scale *= textSize
	
	PASTMOVE.append(STARTBOARD.duplicate())
	autowrap_mode = TextServer.AUTOWRAP_WORD



func _process(delta: float) -> void:
	pass


#special will give u 1 if short, 0 no castle, 2 if long castle, 3 if enpassant, 4 if promtoed
func _on_chess_print_move(chessGrid: Array, turnNumber: int, turn: int, special:int) -> void:
	#print(PASTMOVE)
	text += " "
	if turn == 1: text += str(turnNumber)
	ARRNUM = turnNumber * 2 - 1 + (0 if turn == 1 else 1)
	PASTMOVE.append(chessGrid.duplicate(true))
	if special in [1,2]:
		text += "O-O" if special == 1 else "O-O-O" #castle notation / check or checkmate
	else:
		decipher(ARRNUM, turn, special)
		text += str(chessNotation(special))  

func decipher(arrNum: int, col: int, castleStatus: int):
	#im using details to store, original piece, final piece
	details.clear()  
	# [0] will be Original Pos
	# [1] will be Final Pos
	# [2] will be Piece No
	# [3] will be if captured (1 for captured, 0 for no capture)
	# [4] will be castle / long castle
	
	
	if PASTMOVE.size() > arrNum:   #ensure we dont crash the thing
		var arrOriginal = PASTMOVE[arrNum-1].duplicate(true)
		var arrFinal = PASTMOVE[arrNum].duplicate(true) 
		
		#print("NOOOOOOOOO", arrOriginal,  "FINAAAAAAAAAAAAAL", arrFinal)
		
		var originalPos
		var finalPos
		var pieceNo
		var captured
		
		if castleStatus not in [1,2]:
			for y in range(8):
				for x in range(8):
				
					if arrOriginal[y][x] != 0 and arrFinal[y][x] == 0:
						originalPos = Vector2i(x,y)
						pieceNo = (arrOriginal[y][x])
					if arrOriginal[y][x] == 0 and arrFinal[y][x] != 0:
						finalPos = Vector2i(x,y)
						captured = 0
				
					if arrOriginal[y][x] != 0 and arrFinal[y][x] != 0:
						if arrFinal[y][x] * arrOriginal[y][x] < 0:
							finalPos = Vector2i(x,y)
							captured = 1
		
		details.append(originalPos)
		details.append(finalPos)
		details.append(pieceNo)
		details.append(captured)
		details.append(castleStatus)
		print(details)

# [0] will be Original Pos
# [1] will be Final Pos
# [2] will be Piece No
# [3] will be if captured (1 for captured, 0 for no capture)
# [4] will be castle / long castle
func chessNotation(info: int):
	#Pawn Notation
	var finalnotation = converter[details[1].x] + str(8-details[1].y)
	var initialnotation = converter[details[0].x] + str(8-details[0].y)
	
	if details[2] in [6,-6]:

		#enpassant:
		if info == 3:
			return converter[details[0].x] + "x" + finalnotation
		
		#promotion: is setlled somewhere else
		
		else:
			return (converter[details[0].x] + "x" if details[3] == 1 else "") + finalnotation
	
	#if rook:
	if details[2] in [5, -5]:
		return "R" + rookDis() + ("x" if details[3] == 1 else "") + finalnotation
		
	if details[2] in [3, -3]:
		return "B" + bishopDis() + ("x" if details[3] == 1 else "") + finalnotation
	
	if details[2] in [2, -2]:
		return "Q" + queenDis() + ("x" if details[3] == 1 else "") + finalnotation
	
	if details[2] in [4,-4]:
		return "N" + knightDis() + ("x" if details[3] == 1 else "") + finalnotation
	
	if details[2] in [1,-1]:
		return "K" + ("x" if details[3] == 1 else "") + finalnotation
	
		
		#diambiguition#######:
func rookDis():
	var result = []
	for i in RookMoves:
		for j in range(1,8):
			if i.x*j + details[1].x in range(8) and i.y*j + details[1].y in range(8):
				if PASTMOVE[ARRNUM][details[1].y + i.y*j][details[1].x + i.x*j] == details[2]:
					result.append(Vector2i(details[1].x + i.x*j, details[1].y +i.y*j))
				elif PASTMOVE[ARRNUM][details[1].y + i.y*j][details[1].x + i.x*j] != 0 or (details[1].y + i.y*j == details[0].y and details[1].x + i.x*j == details[0].x):
					break

	if result.size() >= 2:
		return (converter[details[0].x] + intconverter[details[0].y]) #ambigous BOTH
	elif result.size() == 1:
		if details[0].x != result[0].x: #if there are on different x values:
			return converter[details[0].x] #only print out letter
		else:
			return intconverter[details[0].y] #only print out number
	else: return "" #nothing
	
func bishopDis():
	var result = []
	for i in BishopMoves:
		for j in range(1,8):
			if i.x*j + details[1].x in range(8) and i.y*j + details[1].y in range(8):
				if PASTMOVE[ARRNUM][details[1].y + i.y*j][details[1].x + i.x*j] == details[2]:
					result.append(Vector2i(details[1].x + i.x*j, details[1].y +i.y*j))
				elif PASTMOVE[ARRNUM][details[1].y + i.y*j][details[1].x + i.x*j] != 0 or (details[1].y + i.y*j == details[0].y and details[1].x + i.x*j == details[0].x):
					break

	if result.size() >= 2:
		var yaxis: bool = false
		var xaxis: bool = false
		
		for i in result:
			if details[0].y == i.y:
				yaxis = true
			if details[0].x == i.x:
				xaxis = true
		
		if xaxis == true and yaxis == true:
			return (converter[details[0].x] + intconverter[details[0].y])
		elif xaxis == true:
			return intconverter[details[0].y]
		elif yaxis == true:
			return converter[details[0].x]
		else:
			return ""
		
	elif result.size() == 1:
		if details[0].x != result[0].x: #if there are on different x values:
			return converter[details[0].x] #only print out letter
		else:
			return intconverter[details[0].y] #only print out number
	else: return "" 

func queenDis():
	var result = []
	for i in BishopMoves:
		for j in range(1,8):
			if i.x*j + details[1].x in range(8) and i.y*j + details[1].y in range(8):
				if PASTMOVE[ARRNUM][details[1].y + i.y*j][details[1].x + i.x*j] == details[2]:
					result.append(Vector2i(details[1].x + i.x*j, details[1].y +i.y*j))
				elif PASTMOVE[ARRNUM][details[1].y + i.y*j][details[1].x + i.x*j] != 0 or (details[1].y + i.y*j == details[0].y and details[1].x + i.x*j == details[0].x):
					break
	for i in RookMoves:
		for j in range(1,8):
			if i.x*j + details[1].x in range(8) and i.y*j + details[1].y in range(8):
				if PASTMOVE[ARRNUM][details[1].y + i.y*j][details[1].x + i.x*j] == details[2]:
					result.append(Vector2i(details[1].x + i.x*j, details[1].y +i.y*j))
				elif PASTMOVE[ARRNUM][details[1].y + i.y*j][details[1].x + i.x*j] != 0 or (details[1].y + i.y*j == details[0].y and details[1].x + i.x*j == details[0].x):
					break
	
	if result.size() == 0:
		return ""
	elif result.size() > 1:
		var yaxis: bool = false
		var xaxis: bool = false
		for i in result:
			if details[0].y == i.y:
				yaxis = true
			if details[0].x == i.x:
				xaxis = true
		if xaxis == true and yaxis == true:
			return (converter[details[0].x] + intconverter[details[0].y])
		elif xaxis == true:
			return intconverter[details[0].y]
		else:
			return converter[details[0].x]
	elif result.size() == 1:
		if details[0].x != result[0].x: #if there are on different x values:
			return converter[details[0].x] #only print out letter
		else:
			return intconverter[details[0].y] #only print out number
	else:
		return ""

func knightDis():
	var result = []
	for i in KnightMoves:
		if details[1].y+i.y in range(8) and details[1].x+i.x in range(8):
			if PASTMOVE[ARRNUM][details[1].y+i.y][details[1].x+i.x] == details[2]:
				result.append(Vector2i(details[1].x+i.x, details[1].y+i.y))
	
	var yaxis: bool = false
	var xaxis: bool = false
	if result.size() == 0:
		return ""
	else:
		for i in result:
			if details[0].y == i.y: yaxis = true
			if details[0].x == i.x: xaxis = true
	if yaxis and xaxis: return (converter[details[0].x] + intconverter[details[0].y])
	elif xaxis: return intconverter[details[0].y]
	else: return converter[details[0].x]
