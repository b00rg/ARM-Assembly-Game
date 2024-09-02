  .syntax unified
  .cpu cortex-m4
  .fpu softvfp
  .thumb

  .global PlayerMove
  .global PlayerFrame

  .include "./src/definitions.s"

  .section .text

@ Move player 1 space forward (v_player_position)
@ If new position is 8 then PlayerWin()
PlayerMove:
  PUSH {R4-R7, LR}

  LDR R4, =v_isGameCompleted          @ Check if game is completed
  LDR R5, [R4]
  CMP R5, #1
  BEQ .LEndPlayerMove      

  LDR R4, =v_player_position            @ int playerPos = playerPosition;
  LDR R5, [R4]

  ADD R5, R5, #1
  STR R5, [R4]

  CMP R5, #8                            @ if (bit(playerPos) == 8)
  BGE .LPlayerWin                       @   PlayerWin();
.LEndPlayerMove:
  POP {R4-R7, PC}

@ Player won level. Increase v_level and reset position
.LPlayerWin:
  LDR R6, =v_levelIndex                 @ level++;
  LDR R7, [R6]
  ADD R7, R7, #1
  STR R7, [R6]

  CMP R7, #8                            @ if level == 8: 
  BGE .LPlayerCompletedGame             @   playerCompletedGame

  MOV R5, #0                            @ playerPosition = 0;
  STR R5, [R4]

  POP {R4-R7, PC}

@ Activates win state animation when game is over
.LPlayerCompletedGame:
  LDR R4, =v_isGameCompleted
  MOV R5, #1
  STR R5, [R4]
  POP {R4-R7, PC}

@ Set player LED (ORR, v_led_states)
@ If LED is already lit up then PlayerDead()
PlayerFrame:
  PUSH {R4-R7, LR}

  LDR R4, =v_isGameCompleted            @ if (gameOver):
  LDR R5, [R4]                          @   break
  CMP R5, #1
  BEQ .LEndPlayerFrame                  @ 

  LDR R4, =v_player_position            @ int playerBit = 1 << playerPosition;
  LDR R4, [R4]  
  MOV R5, #1
  LSL R4, R5, R4

  LDR R5, =v_led_states                 @ int states = ledStates;
  LDR R6, [R5]
 
  AND R7, R4, R6
  CMP R7, #0                            @ if (overlap(playerBit, states)):
  BNE .LPlayerDead                      @   PlayerDead();
 
  ORR R4, R4, R6                        @ states |= playerBit;
  STR R4, [R5]
 
.LEndPlayerFrame:
  POP {R4-R7, PC}

@ Player died. Set position back to 0
@ Set first LED on
.LPlayerDead:
  LDR R4, =v_player_position            @ playerPosition = 0;
  MOV R6, #0                            
  STR R6, [R4]

  LDR R6, [R5]                          @ states |= 0b1
  ORR R6, R6, #0b1
  STR R6, [R5]

  POP {R4-R7, PC}

  .end
