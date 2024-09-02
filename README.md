# ARM Assembly Mini-Game for STM32F303
This project is a mini-game developed in ARM Assembly for the STM32F303 microcontroller.

## Hardware Setup
We are utilizing Port E on the STM32F303 microcontroller. The LEDs are arranged and indexed as follows, starting from the North-West and moving clockwise:

* LED4 (Blue, Pin 8, Bit 0)
* LED3 (Red, Pin 9, Bit 1)
* LED5 (Orange, Pin 10, Bit 2)
* LED7 (Green, Pin 11, Bit 3)
* LED9 (Blue, Pin 12, Bit 4)
* LED10 (Red, Pin 13, Bit 5)
* LED8 (Orange, Pin 14, Bit 6)
* LED6 (Green, Pin 15, Bit 7)

## Game Structure
### Render Frame
1. Clear all LEDs.
2. For each obstacle:
3. Turn on the corresponding obstacle LEDs.
4. Turn on the player LED.
5. If the player LED is already on, it indicates a collision and the player loses.
   
### Button Interrupt
1. Move the player forward.
2. Check if the player has won.

### SysTick Timer
1. Advance all obstacles by one tick.

### Player Wins
1. Increase the game difficulty.
2. Reset the player position to the starting point.
