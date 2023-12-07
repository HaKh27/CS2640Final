#Group Members: Hafsa Khan, Hajarah Amjad, Javi Wu, Bryan Bergo, Phi Nguyen 
#Date: 12/06/23
#CS2640: Final Project: Tic-Tac-Toe

.data
	msgIntro: .asciiz "Welcome to Tic Tac Toe!"
	rule: .asciiz "Enter the location:[1-9] to play."
	rule1: .asciiz "Do not repeat a number more than once." 
	rule2: .asciiz "Player 1: X and Player 2: O"
	Play1: .asciiz "Player 1's turn (X) : (Choose a number between 1-9) "
	Play2: .asciiz "Player 2's turn (O) : (Choose a number between 1-9) "
	grid: .space 10 
	row1: .asciiz " 1 2 3 "
	row2: .asciiz " 4 5 6 "
	row3: .asciiz " 7 8 9 "
	player1win: .asciiz "Player 1 has won!"
	player2win: .asciiz "Player 2 has won!"
	DRAW: .asciiz "The game has resulted in a Draw!"
	turn_tracker: .word 0  # Initialize the turn tracker to 0 (Player 1's turn)
	tryAgain: .asciiz "The input was invalid. Please try again. " 
	s4VAL: .asciiz "Current amount of moves: "
	new: .asciiz " \n"
	ref: .asciiz "Use this board to find the corresponding positions: " 

.text
#display the main and guide the player to play the games
main:
	li $s4, 0 # Initialize the number of moves counter
	li $s5, 0 # Initialize check win counter
	j initDisplay # Jump to display

#initDisplay: displays the initial display of the game board and the rules 
initDisplay:
	la $a0, msgIntro #Display the intro message
	li $v0, 4    #code to display message 
	syscall
	
	jal newline      #jump to newline to create a newline

	jal newline
	
	la $a0, rule  #Display the rule of entering an integer 1-9 to play
	li $v0, 4
	syscall

	jal newline

	la $a0, rule1 #Display rule to indicate no repition of numbers
	li $v0, 4
	syscall

	jal newline

	la $a0, rule2 #Display the rule that indicates Player 1 plays X and Player 2 plays O 
	li $v0, 4
	syscall

	jal newline 
	jal turn # Start with Player 1's turn
	
#Turn: determines who's turn it is and checks for wins 
turn:
    	jal ROW   # Check for a win in the rows
   	jal DIAG  # Check for a win in the diagonals
    	jal COL	  # Check for a win in the columns
    	jal newline   #add newline space 
     	
    	lw $t0, turn_tracker  # Load the current turn tracker value

	
    	beq $t0, 0, play1  # If it's Player 1's turn (0), go to play1
   	beq $t0, 1, play2  # If it's Player 2's turn (1), go to play2
  
#Play1: Player 1's turn
play1:
	jal dispPosition    #jump to dispPosition function to display the game board with integers 1-9
	
	jal newline         #jump to display newline
    	la $a0, Play1       #Prompt player 1 to enter an integer 1-9  
    	li $v0, 4
    	syscall
    

    	li $t0, 1 	     # Set the turn tracker to 1 (Player 2's turn)
    	sw $t0, turn_tracker #store the updated turn tracker value in $t0 
    

    	jal play 	     #jump and loop to 'play' function

#Player 2's turn
play2: 
	beq $s4, 9, draw   	# If $s4 (amount of moves) is equal to 9 and no winner is found, the game is a draw
	jal dispPosition
    
    	la $a0, Play2   	#Prompt player 2 to enter an integer 1-9  
    	li $v0, 4
    	syscall

    	li $t0, 0  		# Set the turn tracker to 0 (Player 1's turn)
    	sw $t0, turn_tracker    #store the updated turn tracker value in $t0 
    
    	jal newline

    	jal play  		#jump and loop to 'play' function

#play: the main play begins here 
play:  
    	jal newline
    
    	jal getinput      #jump to get location input from user  
    	jal checkinput    #jump to function to verify input is valid
    	j storeinput      #store user's input in the grid
   

#getinput: get input from user
getinput:
    	li $v0, 5 	#Read the location from the player
    	syscall

    	li $s2, 0 	  #intialize new vairable: $s2 to 0
    	add $s2, $s2, $v0 # Add the location of user's input and save to $s2

    	jr $ra # Return to the previous function

#checkinput: check the input is it within the range of [1-9] or not
checkinput:
	la $t1, grid  # Load the grid address
	add $t1, $t1, $s2 # Add $s2 to $t1 to get the exact location
	lb $t2, ($t1) # Load the value at $t1 into $t2
	
	bne $t2, 0, sameTurn # If the value at the location is NOT zero (position is taken), jump to sameTurn
	bge $s2, 10, sameTurn # If user's input is greater than or equal to 10, jump to sameTurn 
	ble $s2, 0, sameTurn # If user's input is less than or equal to 0, jump to sameTurn 

        jr $ra  # Return to the calling function
   

#sameTurn: Redo current player's turn due to invalid input 
sameTurn: 
 
    	la $a0, tryAgain   # Prompt user to enter valid input
    	li $v0, 4          # 4 to display a message
    	syscall
    
    	jal newline 
    
    	lw $t0, turn_tracker  # Repeat players turn if input conditions are not met. 
    	beq $t0, 0, play2  # If it's Player 1's turn (0), go to play2
    	beq $t0, 1, play1  # If it's Player 2's turn (1), go to play1
   
    	
#storeinput: store the input into grid	
storeinput:
    	beq $v0, 0, sameTurn  #if input is invalid, don't increment the number of moves
    	addi $s4, $s4, 1 # Increment $s4 for every turn
    	addi $s5, $s5, 1 # Increment check win counter
    	beq $s3, 0, storeX # If player 1's turn, jump to storeX
    	beq $s3, 1, storeO  # If player 2's turn, jump to storeO
    
#storeX: stores an X 
storeX:
    	la $t1, grid #load the grid
    	add $t1, $t1, $s2 #add $s2 location to $t1 to get the exact location
    
    	li $t2, 1  #Set t2 = 1
    
   	sb $t2, ($t1) #store $t1 to $t2
    	li $s3, 1 #change the turn to player 2
    	j display #jump to display

#storeO: stores an O 
storeO:
    	la $t1, grid  
    	add $t1, $t1, $s2 #add $s2 location to $t1 to get the exact location
    
    	li $t2, 2  #Set t2 = 2
    
    	sb $t2, ($t1) #store $t1 to $t2
    	li $s3, 0 #change the turn to player 1
    	j display #jump to display

#display: displays amount of valid moves 
display:
    	li $s0, 0 # Initialize $s0 to 0
    	li $s1, 0 # Initialize $s1 to 0
    	
    	la $a0, s4VAL   # Display the message regarding current number of valid moves made by player 1 and 2
    	li $v0, 4          # 4 to display a message
    	syscall
   
   	move $a0, $s4   #Display the number of current valid moves made 
   	li $v0, 1        # 1 to display integer
   	syscall
   
    	j displayline  # Jump to displayline
    

#displayline: to display newline for displaying the grid
displayline:
    	addi $s1, $s1, 3 # Add 3 to $s1 to ensure every 3 outputs make a new line
    	
    	jal newline
    	
    	j displaygrid  # Jump to display grid

#displaygrid: displaying all the grid information
displaygrid:
    	beq $s0, $s1, displayline #adds new line after every 3 positions in the grid 
    	addi $s0, $s0, 1  # Increment $s0
    	beq $s0, 10, turn # Print 9 characters and return to switch turn
    	
    	la $t2, grid  # Load the current grid address
    	add $t2, $t2, $s0  # Add $s0 to the address to access the current grid element
    	lb $t3, ($t2)  # Load the byte at the grid location
    	
    	jal addspace  # Add space
    	
    	beq $t3, 0, displayspace  # If the value at $t3 is 0, jump to displayspace to display '?' in empty positions
    	beq $t3, 1, displayX  # If $t3 is 1, jump to displayx (for 'X')
    	beq $t3, 2, displayO  # If $t3 is 2, jump to displayo (for 'O')
    	
    	j turn

#displayX: to display 1 to x
displayX:
	li $a0, 88 #load X
	li $v0, 11 #print X
	syscall
	
	j displaygrid #jump to displaygrid

#displayO: to display 2 to O
displayO:
	li $a0, 79 #load O
	li $v0, 11 #print O
	syscall
	
	j displaygrid #jump to displaygrid
	
#displayspace: Checks if the space is empty 
displayspace:
    	la $t1, grid  # Load the grid address
    	add $t1, $t1, $s0  # Add $s0 to $t1 to get the current grid position
    	lb $t2, ($t1)  # Load the value at the current grid position
    
    	beq $t2, 0, displayempty  # If the value at $t2 is 0, jump to displayempty
    	
    	j displaygrid  # Otherwise, jump back to display grid

#to display empty space with ?
displayempty:
    	li $a0, 63  # Load '?' (ASCII code) into $a0
    	li $v0, 11  # Print character
    	syscall
    	
    	j displaygrid  # Jump back to display grid
   
#DIAG: check winning conditions diagonally (1,5,9)
DIAG:
    	la $t0, grid   # load address of the board
    	lb $t1, 1($t0) # load the 1st square, position 1
    	lb $t2, 5($t0) # load the 2nd square, position 5
    	lb $t3, 9($t0) # load the 3rd square, position 9
    	
    	bne $t1, $t2, DIAG2 # check if square 1 and 2 are equal
    	bne $t1, $t3, DIAG2 # check if square 1 and 3 are equal
    	
    	j WINNER   # there is a winner
    	
#DIAG: check winning conditions diagonally (3,5,7)
DIAG2:
    	lb $t1, 3($t0) # load the 1st square, position 3
    	lb $t2, 5($t0) # load the 2nd square, position 5
    	lb $t3, 7($t0) # load the 3rd square, position 7
    
    	bne $t1, $t2, DIAGN # check if square 1 and 2 are equal
    	bne $t1, $t3, DIAGN # check if square 1 and 3 are equal
    	
    	j WINNER   # there is a winner
    	
#DIAGN: no diagonal wins 	
DIAGN:
    	jr $ra   # jump to where the label was called
    	
#WINNER: no diagonal wins 	
WINNER:
    	move $v1, $t1  #move $t1 to $v1 
    	beq $t1, 1, player1wins #if t1 is X, player1 wins
    	beq $t1, 2, player2wins	#if t1 is O player2 wins
    	
    	jr $ra # jump to where the label was called

#player1wins: Display winning message for player 1 
player1wins:
	la $a0, player1win   #Display message for player 1 winning
	li $v0, 4
	syscall
			
	j exit  #exit the game after finding winner
			
#player2wins: Display winning message for player 2		
player2wins:
	la $a0, player2win    #Display message for player 2 winning
	li $v0, 4
	syscall
	
	j exit  #exit the game after finding winner

#ROW: finds winner in row 1 
ROW:
    	la $t0, grid   # load address of the board
    	
    	lb $t1, 1($t0) # load the 1st square, position 1
    	lb $t2, 2($t0) # load the 2nd square, position 2
    	lb $t3, 3($t0) # load the 3rd square, position 3
    	
    	bne $t1, $t2, ROW2 # check if square 1 and 2 are equal, if false they are equal
    	bne $t1, $t3, ROW2 # check if square 1 and 3 are equal
    	
    	j WINNER   # there is a winner
    
#ROW2: finds winner in row 2
ROW2:
    	lb $t1, 4($t0) # load the 1st square, position 4
    	lb $t2, 5($t0) # load the 2nd square, position 5
    	lb $t3, 6($t0) # load the 3rd square, position 6
    	
    	bne $t1, $t2, ROW3 # check if square 1 and 2 are equal
    	bne $t1, $t3, ROW3 # check if square 1 and 3 are equal
    	
    	j WINNER   # there is a winner
    
#ROW3: finds winner in row 3
ROW3:
    	lb $t1, 7($t0) # load the 1st square, position 7
    	lb $t2, 8($t0) # load the 2nd square, position 8
    	lb $t3, 9($t0) # load the 3rd square, position 9
    	
    	bne $t1, $t2, ROWN  # check if square 1 and 2 are equal
    	bne $t1, $t3, ROWN  # check if square 1 and 3 are equal
    	
    	j WINNER   # there is a winner
    
#ROWN: no winners in any row 
ROWN:
    	jr $ra   # jump to where the label was called

#COL: check for winners in column 1 
COL:
    	la $t0, grid   # load address of the board
    	
    	lb $t1, 1($t0) # load the 1st square, position 1
    	lb $t2, 4($t0) # load the 2nd square, position 4
	lb $t3, 7($t0) # load the 3rd square, position 7

    	bne $t1, $t2, COL2 # check if square 1 and 2 are equal, if false they are equal
    	bne $t1, $t3, COL2 # check if square 1 and 3 are equal

    	j WINNER   # there is a winner
    	
#COL2: check for winners in column 2
COL2:
    	lb $t1, 2($t0) # load the 1st square, position 2
    	lb $t2, 5($t0) # load the 2nd square, position 5
    	lb $t3, 8($t0) # load the 3rd square, position 8

    	bne $t1, $t2, COL3 # check if square 1 and 2 are equal, if false they are equal
    	bne $t1, $t3, COL3 # check if square 1 and 3 are equal

    	j WINNER   # there is a winner
    	
#COL3: check for winners in column 3   
COL3:
    	lb $t1, 3($t0) # load the 1st square, position 3
    	lb $t2, 6($t0) # load the 2nd square, position 6
    	lb $t3, 9($t0) # load the 3rd square, position 9

    	bne $t1, $t2, COLN # check if square 1 and 2 are equal, if false they are equal
    	bne $t1, $t3, COLN # check if square 1 and 3 are equal

    	j WINNER   # there is a winner
    	
#COLN: no winners found in any columns 
COLN:
	jr $ra # return to game loop

#draw: if all positions are filled up and no winner is found, display draw message 
draw:
    	jal newline
    	la $a0, DRAW     #Display message of the game ending in a draw
    	li $v0, 4
    	syscall
    	
    	j exit   #exit the game
 
#dispPosition: display the game board showing the position of the numbers [1-9]
dispPosition: 
 	la $a0, ref #Display the first row (1-3) of integers for the board game
	li $v0, 4    #code to display message 
	syscall
	
	la $a0, new #Display a new line
	li $v0, 4    #code to display message 
	syscall
	
 	la $a0, row1 #Display the first row (1-3) of integers for the board game
	li $v0, 4    #code to display message 
	syscall
	
	la $a0, new #Display a new line
	li $v0, 4    #code to display message 
	syscall
	
	la $a0, row2 #Display the second row (4-6) of integers for the board game
	li $v0, 4    
	syscall

	la $a0, new #Display a new line
	li $v0, 4    #code to display message 
	syscall

	la $a0, row3  #Display the third row (7-9) of integers for the board game
	li $v0, 4
	syscall

	la $a0, new #Display a new line
	li $v0, 4    #code to display message 
	syscall
	
	jr $ra
 
    	
#newline: to make new line	
newline:
	li $a0, 10 #load line
	li $v0, 11 #print line
	syscall
	
	jr $ra

#addspace: to make space
addspace:
	li $a0, 32 #load space
	li $v0, 11 #print space
	syscall
	
	jr $ra
	

#exit the program
exit:
	li $v0, 10
	syscall
