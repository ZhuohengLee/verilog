# Week 11: PWM Duty Cycle Demo Program
# This program sets different PWM duty cycles and displays on LED
# MMIO Addresses:
#   0x94 = LED output
#   0x98 = PWM duty cycle (0-255)
#   0x9C = PWM enable (0/1)

# Register usage:
#   $t0 = duty cycle value
#   $t1 = MMIO address temp
#   $t2 = delay counter

main:
    # Step 1: Set duty = 25% (64/256)
    addi $t0, $zero, 64      # duty = 64 (25%)
    addi $t1, $zero, 0x98    # PWM duty address
    sw   $t0, 0($t1)         # Write duty
    addi $t1, $zero, 0x9C    # PWM enable address
    addi $t0, $zero, 1       # enable = 1
    sw   $t0, 0($t1)         # Enable PWM
    
    # Display on LED
    addi $t1, $zero, 0x94    # LED address
    addi $t0, $zero, 64
    sw   $t0, 0($t1)         # LED = 64

    # Delay loop
    addi $t2, $zero, 100
delay1:
    addi $t2, $t2, -1
    bne  $t2, $zero, delay1

    # Step 2: Set duty = 50% (128/256)
    addi $t0, $zero, 128     # duty = 128 (50%)
    addi $t1, $zero, 0x98
    sw   $t0, 0($t1)
    addi $t1, $zero, 0x94
    sw   $t0, 0($t1)         # LED = 128

    addi $t2, $zero, 100
delay2:
    addi $t2, $t2, -1
    bne  $t2, $zero, delay2

    # Step 3: Set duty = 75% (192/256)
    addi $t0, $zero, 192     # duty = 192 (75%)
    addi $t1, $zero, 0x98
    sw   $t0, 0($t1)
    addi $t1, $zero, 0x94
    sw   $t0, 0($t1)         # LED = 192

    addi $t2, $zero, 100
delay3:
    addi $t2, $t2, -1
    bne  $t2, $zero, delay3

    # Step 4: Disable PWM
    addi $t1, $zero, 0x9C
    sw   $zero, 0($t1)       # PWM disable

    # Infinite loop
end:
    j    end
