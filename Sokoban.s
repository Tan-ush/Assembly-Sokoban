.data

# a) I implemented one enhancement, which was the multiplayer mode

# -----------------

# b) You can find code that creates this enhancement in the following Labels:

# PROMPT_PLAYERS (ask for amount of players), JUMP_TO_STORE (go to store moves), LEADERBOARD, PRINT_LOOP (Display Leaderboard), RESTART_BOARD_FOR_NEXT (restart the board for the next player), 

# STORE_MOVES_NUMS (store moves of a player), NEXT (initializes player move count), MOVE_UP (increment move count), MOVE_DOWN (increment move count), MOVE_RIGHT (increment move count)

# MOVE_LEFT (increment move count), and SORT_PLAYERS_BUBBLE_SORT (sort player moves)

# -----------------

# c) The enhancement is implemented by first prompting the number of players, then for each player, track the number of moves for the turn.

# After each turn, store the moves and the player number in a list, and restart the board for the next player. Once all players are done,

# sort the players by moves made (least to greatest) and then print the list of players and the list of their moves.

# -----------------

.align 2
gridsize:   .byte 8,8

.align 2
character:  .byte 0,0

.align 2
box:        .byte 0,0

.align 2
target:     .byte 0,0

.align 2
gameboard:  .space 65025

.align 2
move:       .space 1

.align 2
players:    .space 1

.align 2
moves_for_player: .space 10000

.align 2
player_nums:  .space 10000

.align 2
seed: .word 1

.align 2
enter_input:    .string "Select a move; 'w', 'a', 's', 'd'; Enter 'r' to RESTART\n"

.align 2
no_change:      .string "No change in game\n"

.align 2
invalid_input:  .string "Invalid input\n"

.align 2
you_win:        .string "Congratulations! You have placed the box on the target\n"

.align 2
restart_game:   .string "You have restarted the game!\n"

.align 2
ask_num_players: .string "Enter the number of players participating in the competition: "

.align 2
player_turn: .string "Turn for player "

.align 2
leaderboard_notice: .string "------------- FINAL STANDINGS ---------------\n"

.align 2
player_message: .string "Moves for Player "

.align 2
colon: .string ": "

.align 2
newline: .string "\n"

.align 2
more_players: .string "Choose a number greater than 0 and less than 2^31\n"

.align 2
length_grid: .string "What is the length of your grid?: "

.align 2
width_grid: .string "What is the width of your grid?: "

.align 2
num_six: .string "Please provide a number greater than 5 and less than 256\n"

.equ WALL, '#'
.equ CHAR, '@'
.equ BOX, 'O'
.equ TARGET, 'X'
.equ EMPTY, '.'

.text
.globl PROMPT_PLAYERS

# Supporting Enhancement Label

PROMPT_PLAYERS:
    li t1, 2147483647
    la a0, ask_num_players	# Ask user for player count
    li a7, 4
    ecall

    li a7, 5
    ecall

    la t0, players		#Store the amount of players from input
    sb a0, 0(t0)
    
    bge x0, a0, ASK_AGAIN	#Check if player count is within range
    bgt a0, t1, ASK_AGAIN

    j PROMPT_LENGTH

ASK_AGAIN:
    la a0, more_players		# Redo the prompt if invalid
    li a7, 4
    ecall
    j PROMPT_PLAYERS

PROMPT_LENGTH:
    li t0, 6
    li t2, 255

    la a0, length_grid
    li a7, 4
    ecall

    li a7, 5
    ecall
    la t1, gridsize
    sb a0, 1(t1)
  
    blt a0, t0, ASK_LENGTH_AGAIN
    bgt a0, t2, ASK_LENGTH_AGAIN

PROMPT_WIDTH:

    la a0, width_grid
    li a7, 4
    ecall

    li a7, 5
    ecall
    la t1, gridsize
    sb a0, 0(t1)
  
    blt a0, t0, ASK_WIDTH_AGAIN
    bgt a0, t2, ASK_WIDTH_AGAIN

    j INIT_GAME

ASK_LENGTH_AGAIN:
    la a0, num_six
    li a7, 4
    ecall
    
    j PROMPT_LENGTH

ASK_WIDTH_AGAIN:
    la a0, num_six
    li a7, 4
    ecall
    
    j PROMPT_WIDTH
    
    
INIT_GAME:
    
    li s10, 1
    li t2, 1
    j START_GAME


# Supporting Enhancement Label

JUMP_TO_STORE:
    addi s10, s10, 1		# Increment current player number
    li t2, 1
    bgt s10, t2, STORE_MOVES_NUMS    # Go to Store the moves for a player that just went

START_GAME:

    la t0, players
    lb t0, 0(t0)
    bgt s10, t0, LEADERBOARD

    li a7, 4
    la a0, player_turn
    ecall

    li a7, 1
    mv a0, s10
    ecall

    li a7, 4
    la a0, newline
    ecall

    li t2, 1
    bgt s10, t2, RESTART_BOARD_FOR_NEXT     #If this is not the first player, do not initialize board and just display base
    j _start                                #Create new bord and display if it is the first player


# --------- LEADERBOARD DISPLAY ----------

# Supporting Enhancement Label

LEADERBOARD:

    jal SORT_PLAYERS_BUBBLE_SORT           # Sort the players in order

    
    li a7, 4
    la a0, leaderboard_notice		# Print Final standing announcement
    ecall

    la t0, player_nums
    la t1, moves_for_player
    lb t2, players

# Supporting Enhancement Label
PRINT_LOOP:
    beq t2, x0, exit
    lb t3, 0(t0)        #Current Player
    lb t4, 0(t1)        #Current Moves

    li a7, 4
    la a0, player_message
    ecall

    li a7, 1		#Print Player
    mv a0, t3
    ecall

    li a7, 4
    la a0, colon
    ecall

    li a7, 1		#Print Move Count
    mv a0, t4
    ecall

    li a7, 4
    la a0, newline
    ecall

    addi t0, t0, 1
    addi t1, t1, 1
    addi t2, t2, -1
    
    j PRINT_LOOP
      
# Supporting Enhancement Label

RESTART_BOARD_FOR_NEXT:
    la t0, character	#s3-8 carry positions for each character, restored by using initial position in memory
    lb s3, 0(t0)
    lb s4, 1(t0)
     
    la t0, target
    lb s5, 0(t0)
    lb s6, 1(t0)

    la t0, box
    lb s7, 0(t0)
    lb s8, 1(t0)

    j NEXT

# Supporting Enhancement Label

STORE_MOVES_NUMS:
    
    la t0, moves_for_player         #Store the moves of a player
    mv t1, s10
    addi t1, t1, -2
    add t0, t0, t1

    sb s11, 0(t0)

    la t0, player_nums              #Store the number of the player
    mv t1, s10           
    addi t1, t1, -1
    mv t2, t1
    addi t2, t2, -1
    add t0, t0, t2
    
    sb t1, 0(t0)

    j START_GAME


_start:

    li t0, 0
    la t1, seed
    sw t0, 0(t1)

    la t0, gridsize   #This grabs the values of the grid
    lb s1, 0(t0)
    addi t0, t0, 1
    lb s2, 0(t0)

PERSONPOSITIONX:
    
    mv a0, s1         #Put a random value in x of person
    jal LCG_RAND
    mv s3, a0         #S3 is the value of person x
    la t1, character  
    sb s3, 0(t1)

PERSONPOSITIONY:
    
    mv a0, s2         #Put a random value in y person
    jal LCG_RAND
    la t1, character 
    mv s4, a0         #S4 is value of person y
    addi t1, t1, 1
    sb s4, 0(t1)

TARGETPOSITIONX:
    
    mv a0, s1         #Put a random value in x of target
    jal LCG_RAND
    mv s5, a0
    la t1, target
    sb s5, 0(t1)


TARGETPOSITIONY:
 
    mv a0, s2         #Put a random value in y of target
    jal LCG_RAND
IF:

    bne a0, s4, CONTINUE

NESTEDIF:                        #if y is the same and x is the same, find a new value

    beq s5, s3, TARGETPOSITIONY

CONTINUE:

    mv s6, a0
    la t1, target
    addi t1, t1, 1
    sb s6, 0(t1)


BOXPOSITIONX:

    mv a0, s1
    jal LCG_RAND
    mv s7, a0

    li t1, 0
    beq s5, t1, CHECKNOTMAXX     

    la t1, gridsize
    lb t1, 0(t1)
    addi t1, t1, -1
    beq s5, t1, CHECKNOT0X

    li t1, 1
    la t2, gridsize
    lb t2, 0(t2)
    addi t2, t2, -2
    blt s7, t1, BOXPOSITIONX
    bgt s7, t2, BOXPOSITIONX
    
    j FINALIZEBOXX
    

CHECKNOTMAXX:
    la t1, gridsize
    lb t1, 0(t1)
    addi t1, t1, -1
    beq s7, t1, BOXPOSITIONX
    j FINALIZEBOXX

CHECKNOT0X:
    li t1, 0
    beq s7, t1, BOXPOSITIONX

FINALIZEBOXX:
    la t1, box
    sb s7, 0(t1)


BOXPOSITIONY:

    mv a0, s2
    jal LCG_RAND
    mv s8, a0

    li t1, 0
    beq s6, t1, CHECKNOTMAXY

    la t1, gridsize
    lb t1, 1(t1)
    addi t1, t1, -1
    beq s6, t1, CHECKNOT0Y

    li t1, 1
    la t2, gridsize
    lb t2, 1(t2)
    addi t2, t2, -2
    blt s8, t1, BOXPOSITIONY
    bgt s8, t2, BOXPOSITIONY
    
    j FINALIZEBOXY
    

CHECKNOTMAXY:
    la t1, gridsize
    lb t1, 1(t1)
    addi t1, t1, -1
    beq s8, t1, BOXPOSITIONY
    j FINALIZEBOXY

CHECKNOT0Y:
    li t1, 0
    beq s8, t1, BOXPOSITIONY

FINALIZEBOXY:
    la t1, box
    addi t1, t1, 1
    sb s8, 0(t1)

CHECKBOXISUNIQUE:
    
    bne s7, s3, TARGET_CHECK
    bne s8, s4, TARGET_CHECK
    j BOXPOSITIONY

TARGET_CHECK:
    
    bne s7, s5, NEXT
    bne s8, s6, NEXT
    j BOXPOSITIONY

NEXT: 
    

    li s11, 0               #This will track the moves for the player
    jal GAMEBOARD_DISPLAY
    

   
    




USER_PLAY:
     
    beq s5, s7, CHECK_IF_WIN

CONTINUE_INPUT:

    la a0, enter_input
    li a7, 4
    ecall
    li a7, 8
    la a0, move
    li a1, 3
    ecall
    la t0, move
    lb t1, 1(t0)
    lb t0, 0(t0)
    li t2, '\n'
    bne t2, t1, INVALID_INPUT

IF_Valid:
    li t1, 119                 #Check if input was 'w'
    beq t0, t1, MOVE_UP
    li t1, 97                  #Check if input was 'a'
    beq t0, t1, MOVE_LEFT
    li t1, 115                 #Check if input was 's'
    beq t0, t1, MOVE_DOWN
    li t1, 100                 #Check if input was 'd'
    beq t0, t1, MOVE_RIGHT
    li t1, 114
    beq t0, t1, RESTART

INVALID_INPUT:
    la a0, invalid_input
    li a7, 4
    ecall
    j CONTINUE_INPUT

NO_CHANGE:
    la a0, no_change
    li a7, 4
    ecall
    j USER_PLAY

CHECK_IF_WIN:
    bne s6, s8, CONTINUE_INPUT
    la a0, you_win
    li a7, 4
    ecall
    j JUMP_TO_STORE
    
    

# ------- FOR MOVING UP ------- 

MOVE_UP:
    mv t1, s3          	# x value of character
    mv t2, s4          	# y value of character
    addi t2, t2, -1

    li t5, -1

CHECK_INVALID:
    beq t2, t5, INVALID_INPUT

    mv t6, s7          	# x value of box
    mv s9, s8         	# y value of box
    
    beq t1, t6, CHECKEQUIVALENCE

MOVE_CHARACTER:
    
    mv s4, t2
    jal GAMEBOARD_DISPLAY
    addi s11, s11, 1		# Increment move count
    j USER_PLAY

CHECKEQUIVALENCE:
    bne t2, s9, MOVE_CHARACTER

    addi s9, s9, -1

MOVE_BOX_AND_CHAR:
    beq s9, t5, NO_CHANGE
    
    mv s4, t2

    mv s8, s9
    jal GAMEBOARD_DISPLAY
    addi s11, s11, 1		# Increment move count
    j USER_PLAY


# ------- FOR MOVING LEFT ------- 

MOVE_LEFT:

    mv t1, s3          	# x value of character
    mv t2, s4          	# y value of character
    addi t1, t1, -1

    li t5, -1

CHECK_INVALID_LEFT:
    beq t1, t5, INVALID_INPUT

    mv t6, s7          	# x value of box
    mv s9, s8         	# y value of box
    
    beq t1, t6, CHECKEQUIVALENCE_LEFT

MOVE_CHARACTER_LEFT:
    
    mv s3, t1
    jal GAMEBOARD_DISPLAY
    addi s11, s11, 1		# Increment move count
    j USER_PLAY

CHECKEQUIVALENCE_LEFT:
    bne t2, s9, MOVE_CHARACTER_LEFT

    addi t6, t6, -1

MOVE_BOX_AND_CHAR_LEFT:
    beq t6, t5, NO_CHANGE
    
    mv s3, t1

    mv s7, t6
    jal GAMEBOARD_DISPLAY
    addi s11, s11, 1		# Increment move count
    j USER_PLAY

# ------- FOR MOVING DOWN ------- 

MOVE_DOWN:
    
    mv t1, s3          	# x value of character
    mv t2, s4          	# y value of character
    addi t2, t2, 1

    la t5, gridsize
    lb t5, 1(t5)

CHECK_INVALID_DOWN:
    beq t2, t5, INVALID_INPUT

    mv t6, s7          	# x value of box
    mv s9, s8         	# y value of box
    
    beq t1, t6, CHECKEQUIVALENCE_DOWN

MOVE_CHARACTER_DOWN:
    
    mv s4, t2
    jal GAMEBOARD_DISPLAY
    addi s11, s11, 1		# Increment move count
    j USER_PLAY

CHECKEQUIVALENCE_DOWN:
    bne t2, s9, MOVE_CHARACTER_DOWN

    addi s9, s9, 1

MOVE_BOX_AND_CHAR_DOWN:
    beq s9, t5, NO_CHANGE
    
    mv s4, t2

    mv s8, s9
    jal GAMEBOARD_DISPLAY
    addi s11, s11, 1		# Increment move count
    j USER_PLAY

# ------- FOR MOVING RIGHT ------- 

MOVE_RIGHT:

    mv t1, s3          	# x value of character
    mv t2, s4          	# y value of character
    addi t1, t1, 1

    la t5, gridsize
    lb t5, 0(t5)

CHECK_INVALID_RIGHT:
    beq t1, t5, INVALID_INPUT

    mv t6, s7          	# x value of box
    mv s9, s8         	# y value of box
    
    beq t1, t6, CHECKEQUIVALENCE_RIGHT
    
MOVE_CHARACTER_RIGHT:
    
    mv s3, t1
    jal GAMEBOARD_DISPLAY
    addi s11, s11, 1		# Increment move count
    j USER_PLAY

CHECKEQUIVALENCE_RIGHT:
    bne t2, s9, MOVE_CHARACTER_RIGHT

    addi t6, t6, 1

MOVE_BOX_AND_CHAR_RIGHT:
    beq t6, t5, NO_CHANGE
    
    mv s3, t1

    mv s7, t6
    jal GAMEBOARD_DISPLAY
    addi s11, s11, 1		# Increment move count
    j USER_PLAY

RESTART:
    la a0, restart_game
    li a7, 4
    ecall
    j RESTART_BOARD_FOR_NEXT

    
    
# ------ END OF PROGRAM -------
	
exit:
    li a7, 10
    ecall
    
    
# --- HELPER FUNCTIONS ---

GAMEBOARD_DISPLAY:
    
    la t0, gameboard
    la t1, gridsize
    lb t1, 0(t1)
    addi t1, t1, 2 

TOPWALLS:
    li t2, WALL
    sb t2, 0(t0)
    addi t0, t0, 1
    addi t1, t1, -1
    bne t1, x0, TOPWALLS

    li t6, '\n'
    sb t6, 0(t0)
    addi t0, t0, 1

BEGIN_INNER:
    la t1, gridsize
    lb t3, 1(t1)

LEFT_WALL:
    sb t2, 0(t0)
    addi t0, t0, 1

    lb t4, 0(t1)

INNER_SPOTS:
    li t5, EMPTY
    sb t5, 0(t0)
    addi t0, t0, 1
    addi t4, t4, -1
    bne t4, x0, INNER_SPOTS
    
    sb t2, 0(t0)
    addi t0, t0, 1
    
    sb t6, 0(t0)
    addi t0, t0, 1

    addi t3, t3, -1
    bne t3, x0, LEFT_WALL

    lb t4, 0(t1)
    addi t4, t4, 2


BOTTOMWALLS:
    sb t2, 0(t0)
    addi t4, t4, -1
    addi t0, t0, 1
    bne t4, x0, BOTTOMWALLS
   
    sb t6, 0(t0)
    addi t0, t0, 1

PLACEPLAYER:
    li t5, CHAR
    la t0, gameboard

    la t1, gridsize
    lb t6, 0(t1)         #X dimension of Grid
    addi t6, t6, 3       #Account for the walls around, and newline
    
    addi t2, s3, 1
    addi t3, s4, 1

    mul t4, t6, t3
    add t4, t4, t2
    add t0, t0, t4
    sb t5, 0(t0)

PLACETARGET:
    li t5, TARGET
    la t0, gameboard

    la t1, gridsize
    lb t6, 0(t1)         #X dimension of Grid
    addi t6, t6, 3       #Account for the walls around, and newline

    addi t2, s5, 1
    addi t3, s6, 1
    mul t4, t6, t3
    add t4, t4, t2
    add t0, t0, t4
    sb t5, 0(t0)

PLACEBOX:
    li t5, BOX
    la t0, gameboard

    la t1, gridsize
    lb t6, 0(t1)         #X dimension of Grid
    addi t6, t6, 3       #Account for the walls around, and newline

    addi t2, s7, 1
    addi t3, s8, 1
    mul t4, t6, t3
    add t4, t4, t2
    add t0, t0, t4
    sb t5, 0(t0)

END:
    la t1, gridsize
    lb t2, 0(t1)
    lb t3, 1(t1)
    addi t2, t2, 3
    addi t3, t3, 2
    mul a1, t3, t2
    
    
    li a7, 4
    la a0, gameboard
    ecall

    jr ra


# ------ SORT PLAYERS FOR THE LEADERBOARD USING BUBBLE SORT ------

SORT_PLAYERS_BUBBLE_SORT:

    la t2, players

    lb t2, 0(t2)		#t2 = Number of Players
    addi t3, t2, -1          #t3 = Number of iterations

MAIN_LOOP:

    beq t3, x0, FINISH_SORT
    li t4, 0		       # Current iterations of inner

SUB_LOOP:
    
    beq t3, t4, FINISH_SUB_SORT
    la t5, moves_for_player
    add t5, t5, t4

    lb t6, 0(t5)             #Current player move
    lb t0, 1(t5)             #Following player move

    bge t0, t6, DONT_SWITCH

SWITCH:
    
    sb t6, 1(t5)
    sb t0, 0(t5)

    la t1, player_nums      #Store the numbers of the players in the correct order
    add t1, t1, t4
    lb t6, 0(t1)
    lb t0, 1(t1)

    sb t6, 1(t1)
    sb t0, 0(t1)


DONT_SWITCH:

    addi t4, t4, 1
    j SUB_LOOP
    

FINISH_SUB_SORT:

    addi t3, t3, -1
    j MAIN_LOOP

FINISH_SORT:
    jr ra
    


notrand:
    mv t0, a0
    li a7, 30
    ecall             # time syscall (returns milliseconds)
    remu a0, a0, t0   # modulus on bottom bits 
    li a7, 32
    ecall             # sleeping to try to generate a different number
    jr ra



# ----------------- NEW RANDOM GENERATOR ------------------ #
# Citation for algorithm
# Name: Linear Congruential Generator, Creator(s): W. E. Thomson, A. Rotenberg
# [1] Hui-Chin Tang. 2007. An analysis of linear congruential random number generators when multiplier restrictions exist. 
#		Stochastics and Statistics 182, (Feb. 2007), 820-828. 10.1016/j.ejor.2006.08.055
# Since the modulo is dynamic, the values of a and c are dependent on m to follow the LCG restrictions



LCG_RAND:
    
    mv t1, a0		#This is the m (modulo)

    la t0, seed
    lw t2, 0(t0)
    bne t2, x0, IF_SET_ALREADY

    li a0, 20		# Generate imita seed using time in milliseconds
    li a7, 32
    ecall

    li a7, 30
    ecall
    
    remu a0, a0, t1	#modulus to meet requirement of seed <= m
    sw a0, 0(t0)
    

IF_SET_ALREADY:

    la t0, seed
    lw t0, 0(t0)

    srli t2, t1, 1
    addi t2, t2, 1	# a = floor(m/2) + 1

    addi t3, t1, -2     # c = m - 2 

    mul t4, t0, t2	# Xn+1 = (a * Xn + c) mod seed
    add t4, t4, t3
    remu t4, t4, t1

    la t0, seed		#Store new seed for next generation
    sw t4, 0(t0)

    andi t4, t4, 254

    mv a0, t4
    jr ra
    
    
  

    






















