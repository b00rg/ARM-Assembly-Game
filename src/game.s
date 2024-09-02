# PASTE LINK TO TEAM VIDEO BELOW
# test

  .syntax unified
  .cpu cortex-m4
  .fpu softvfp
  .thumb
  
  .global Main
  .global SysTick_Handler
  .global EXTI0_IRQHandler

  .global v_player_position
  .global v_led_states
  .global v_levelIndex
  .global v_isGameCompleted

  .include "./src/definitions.s"

  .section .text

  .equ TICK_COOLDOWN, 500
  .equ END_REPEAT, 0xFF

Main:
  LDR R4, =v_tick_rate_counter        @ tickRateCounter = TICK_COOLDOWN
  LDR R5, =TICK_COOLDOWN              
  STR R5, [R4]                        

  @ Ensure the pattern index for levels is set to 0
  LDR     R4, =v_patternIndex
  MOV     R5, #0
  STR     R5, [R4]

  BL Setup

@ Main Rendering loop
@ Clear all LEDs
@ Loop over all obstacles and turn on correct LEDs
@ PlayerRender() to draw Player and check for death
.LRenderFrameLoop:
  LDR R4, =v_led_states               @ clear(ledStates);
  MOV R5, #0  
  STR R5, [R4]  

  @ Draw obstacles
  LDR R5, =v_levelIndex
  LDR R5, [R5]
  MOV R6, #16  
  MUL R5, R5, R6

  LDR R6, =v_patternIndex
  LDR R6, [R6]
  ADD R5, R5, R6

  LDR R4, =v_levels
  LDRB R5, [R4, R5]

  LDR R4, =v_led_states
  STRB R5, [R4]

  BL PlayerFrame

  BL SetLEDs

  B .LRenderFrameLoop

  .type  SysTick_Handler, %function
SysTick_Handler:
  PUSH  {R4-R6, LR}

  LDR   R4, =v_tick_rate_counter      @ if (tickRateCounter == 0):
  LDR   R5, [R4]                      @   CountdownFinished();
  CMP   R5, #0                      
  BEQ   .L_SysTick_Handler_CountdownFinished                  

  SUB   R5, R5, #1                    @ tickRateCounter--;
  STR   R5, [R4]                    

  B     .LendIfDelay                

@ (!) This label is entered when the SysTick timer has completed
@ Cause 1 tick to occur on every obstacle
.L_SysTick_Handler_CountdownFinished:      
  LDR R4, =v_tick_rate_counter
  LDR R5, =TICK_COOLDOWN
  STR R5, [R4]

  LDR R6, =v_levelIndex
  LDR R6, [R6]
  MOV R5, #16
  MUL R6, R6, R5

  LDR R4, =v_patternIndex             @ Load the index of the pattern
  LDRB R5, [R4]
  ADD R5, R5, #1
  STRB R5, [R4]
  ADD R5, R5, R6

  LDR R4, =v_levels     
  LDRB R4, [R4, R5]

  CMP R4, #0xFF                       @check if we reached the end
  BNE .LendIfDelay  

  LDR R4, =v_patternIndex @ Load the index of the patter and set it to 0
  MOV R6, #0
  STRB R6, [R4]

.LendIfDelay:                       
  LDR     R4, =SCB_ICSR               @ Clear (acknowledge) the interrupt
  LDR     R5, =SCB_ICSR_PENDSTCLR   
  STR     R5, [R4]                  
  POP  {R4-R6, PC}

@ (!) Entered when button1 is pressed
@ PlayerMove()
  .type  EXTI0_IRQHandler, %function
EXTI0_IRQHandler:
  PUSH  {R4,R5,LR}

  BL PlayerMove                       @ PlayerMove();       

  LDR   R4, =EXTI_PR                  @ Clear (acknowledge) the interrupt
  MOV   R5, #(1<<0)                 
  STR   R5, [R4]                    
  POP  {R4,R5,PC}

@ Set LEDs based on v_led_states
SetLEDs:
  PUSH {R4-R8, LR}

  LDR R4, =GPIOE_ODR                  @ int currentVal = GPIOE_ODR;
  LDR R5, [R4]

  LDR R6, =v_led_states               @ ledStates <<= 8;
  LDR R7, [R6]
  LSL R7, R7, #8

  MOV R8, #0b11111111                 @ int mask = 0xFF << 8
  LSL R8, R8, #8

  BIC R5, R5, R8                      @ clearBits(currentVal, mask);
  ORR R5, R5, R7                      @ setBits(currentVal, ledStates)

  STR R5, [R4]                        @ GPIOE_ODR = currentVal;

  POP {R4-R8, PC}

  .section .data
v_tick_rate_counter:
  .space 4
v_led_states:
  .space 4
v_player_position:
  .space 4
v_levelIndex:
  .space 4
v_patternIndex:
  .space 4
v_isGameCompleted:
  .word 0

  @ MSB = Last "Win" LED
  @ LSB = Player Start LED (DO NOT SET TO 1)
v_levels:  
  @ Single Dot Blinker (Easy)
  .byte 0b00001000, 0b00000000, 0b00000000, END_REPEAT, END_REPEAT, END_REPEAT, END_REPEAT, END_REPEAT, END_REPEAT, END_REPEAT, END_REPEAT, END_REPEAT, END_REPEAT, END_REPEAT, END_REPEAT, END_REPEAT               
  @ Alternating Dots (Easy)
  .byte 0b00001000, 0b01000000, END_REPEAT, END_REPEAT, END_REPEAT, END_REPEAT, END_REPEAT, END_REPEAT, END_REPEAT, END_REPEAT, END_REPEAT, END_REPEAT, END_REPEAT, END_REPEAT, END_REPEAT, END_REPEAT               
  @ Scrolling Dot (Easy)
  .byte 0b00000010, 0b00000100, 0b00001000, 0b00010000, 0b00100000, 0b01000000, 0b10000000, END_REPEAT, END_REPEAT, END_REPEAT, END_REPEAT, END_REPEAT, END_REPEAT, END_REPEAT, END_REPEAT, END_REPEAT   
  @ 3 Dot Blinkers (Medium)
  .byte 0b01010100, 0b00000000, END_REPEAT, END_REPEAT, END_REPEAT, END_REPEAT, END_REPEAT, END_REPEAT, END_REPEAT, END_REPEAT, END_REPEAT, END_REPEAT, END_REPEAT, END_REPEAT, END_REPEAT, END_REPEAT  
  @ Odds n' Evens (Medium)
  .byte 0b01010100, 0b00000000, 0b10101010, 0b00000000, END_REPEAT, END_REPEAT, END_REPEAT, END_REPEAT, END_REPEAT, END_REPEAT, END_REPEAT, END_REPEAT, END_REPEAT, END_REPEAT, END_REPEAT, END_REPEAT               
  @ Fit the gaps (Medium)
  .byte 0b10110110, 0b00000000, 0b10110110, 0b00000000, END_REPEAT, END_REPEAT, END_REPEAT, END_REPEAT, END_REPEAT, END_REPEAT, END_REPEAT, END_REPEAT, END_REPEAT, END_REPEAT, END_REPEAT, END_REPEAT
  @ 2 Scrolling Dots (Hard)
  .byte 0b11110010, 0b11100110, 0b11001110, 0b10011110, 0b00111110, 0b01111100, 0b11111000, END_REPEAT, END_REPEAT, END_REPEAT, END_REPEAT, END_REPEAT, END_REPEAT, END_REPEAT, END_REPEAT, END_REPEAT
  @ Irregular ZigZags (Hard)
  .byte 0b00010000, 0b00100000, 0b00001000, 0b01000000, 0b00000100, END_REPEAT, END_REPEAT, END_REPEAT, END_REPEAT, END_REPEAT, END_REPEAT, END_REPEAT, END_REPEAT, END_REPEAT, END_REPEAT, END_REPEAT
  @ WIN STATE
  .byte 0b10001000, 0b00000101, 0b00000010, 0b00000101, 0b10001000, 0b01010000, 0b00100000, 0b01010000, 0b10001000, END_REPEAT, END_REPEAT, END_REPEAT, END_REPEAT, END_REPEAT, END_REPEAT, END_REPEAT

  .end
