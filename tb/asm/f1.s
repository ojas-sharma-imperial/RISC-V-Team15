# F1 starting-light sequence
# Sequentially illuminate all LEDs, wait for a random delay, turn all LEDs off and restart.

# Register allocation
# zero  Always contains zero
# ra    Return address
# a0    LED output
# a1    Requested delay count
# s0    Number of LEDs remaining
# s1    LFSR random-number state
# t0    Delay countdown
# t1    Temporary LFSR value
# t2    Temporary LFSR feedback
# t3    Temporary LED pattern


.text
.globl main

.equ STEP_DELAY, 1000       # Countdown between LEDs
.equ RESTART_DELAY, 2000    # Countdown between rounds
.equ LED_COUNT, 8           # Number of LEDs

main:
    jal ra, init
    j new_round

init:
    addi a0, zero, 0
    addi s1, zero, 36       # Nonzero 7-bit LFSR seed
    ret

new_round:
    addi a0, zero, 0
    li a1, STEP_DELAY
    jal ra, delay
    li s0, LED_COUNT
    j light_sequence

# Hardware counter
delay:
    addi t0, a1, 0
    beq t0, zero, delay_done

delay_loop:
    addi t0, t0, -1
    bne t0, zero, delay_loop

delay_done:
    ret

# Generate random delay
random_delay:
    # LFSR algorithm
    srli t1, s1, 1
    xor t2, s1, t1
    andi t2, t2, 1
    slli t2, t2, 6
    or s1, t1, t2

    # Delay count = STEP_DELAY + 16 * LFSR state
    slli a1, s1, 4
    addi a1, a1, STEP_DELAY
    ret

light_sequence:
    slli t3, a0, 1          
    addi a0, t3, 1          
    addi s0, s0, -1
    beq s0, zero, all_on
    li a1, STEP_DELAY
    jal ra, delay
    j light_sequence

all_on:
    jal ra, random_delay
    jal ra, delay
    jal ra, start_race
    li a1, RESTART_DELAY
    jal ra, delay
    j new_round

start_race:
    addi a0, zero, 0
    ret