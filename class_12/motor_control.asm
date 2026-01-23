# Week 12: Motor Control Algorithm Demo
# Simulates motor acceleration -> hold -> deceleration pattern
# Like a robot moving forward, holding, then braking
#
# MMIO Addresses:
#   0x94 = LED output (visual feedback)
#   0x98 = PWM duty cycle (motor speed)
#   0x9C = PWM enable

# Algorithm:
#   Phase 1: Accelerate (duty 0 -> 255, step +16)
#   Phase 2: Hold at full speed (100 cycles)
#   Phase 3: Decelerate (duty 255 -> 0, step -16)
#   Phase 4: Stop and repeat

main:
    # Initialize: Enable PWM
    addi $t1, $zero, 0x9C
    addi $t0, $zero, 1
    sw   $t0, 0($t1)         # PWM enable = 1

# ============= Phase 1: Acceleration =============
accelerate:
    addi $t0, $zero, 0       # duty = 0
    addi $t3, $zero, 256     # target (stop when >= 256)
    
accel_loop:
    # Set PWM duty
    addi $t1, $zero, 0x98
    sw   $t0, 0($t1)
    # Update LED
    addi $t1, $zero, 0x94
    sw   $t0, 0($t1)
    # Delay
    addi $t2, $zero, 20
accel_delay:
    addi $t2, $t2, -1
    bne  $t2, $zero, accel_delay
    # Increment duty
    addi $t0, $t0, 16
    slt  $t4, $t0, $t3       # if duty < 256
    bne  $t4, $zero, accel_loop

# ============= Phase 2: Hold at Full Speed =============
hold:
    addi $t0, $zero, 255
    addi $t1, $zero, 0x98
    sw   $t0, 0($t1)
    addi $t2, $zero, 100
hold_loop:
    addi $t2, $t2, -1
    bne  $t2, $zero, hold_loop

# ============= Phase 3: Deceleration =============
decelerate:
    addi $t0, $zero, 255     # duty = 255
    
decel_loop:
    # Set PWM duty
    addi $t1, $zero, 0x98
    sw   $t0, 0($t1)
    # Update LED
    addi $t1, $zero, 0x94
    sw   $t0, 0($t1)
    # Delay
    addi $t2, $zero, 20
decel_delay:
    addi $t2, $t2, -1
    bne  $t2, $zero, decel_delay
    # Decrement duty
    addi $t0, $t0, -16
    slt  $t4, $zero, $t0     # if 0 < duty (duty > 0)
    bne  $t4, $zero, decel_loop

# ============= Phase 4: Stop Motor =============
stop:
    addi $t1, $zero, 0x98
    sw   $zero, 0($t1)       # duty = 0
    addi $t1, $zero, 0x94
    sw   $zero, 0($t1)       # LED = 0

    # Loop back to start
    j    accelerate
