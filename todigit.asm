.MODEL SMALL            ; Used as our program's code/data is smaller than 64kb 
.STACK 100h             ; Allocates 256 bytes (100h in hex) for the stack

.DATA                   ; Variables begin here
    newline DB 13,10,'$'; Characters 13 and 10 result in a new line
    msg1 db "Enter HOUR:MINUTE:SECOND$" ; Prompt for input
    msg2 db "Please enter a valid number$" ; For when the user misbehaves 

    second DW ?         ; Here we declare three variables, second, minute and
    minute DW ?         ; hour, so that we can store the time as the program
    hour DW ?           ; progesses. They are 2 bytes wide and uninitialised
                        ; because input is given.

    start_second DW ?   ; We save the initial inputs so that we can compare them    
    start_minute DW ?   ; to the current time. If they are equal, we break from
    start_hour DW ?     ; the loop and exit the program

.CODE                   ; Code begins here
MAIN PROC               ; Begin the main procedure
    
    MOV AX, @DATA       ; In order to use our variables, we must initialise
    MOV DS, AX          ; the Data Segment. 

    CALL TAKE_INPUT     ; I have abstracted taking input into a take input proc

    CALL PRNTNEWLINE    ; I also make newline a proc due to its frequency of use 

    INC second          ; As the current time is compared to the start
                        ; time, and the program quits when they are equal, we
                        ; increment the second once before the loop starts. This
                        ; ensures the clock only ends after a full 12 hour cycle
                        
                        ; *The first second is technically outputed due to the
                        ; method by which we take input.

    HOUR_LOOP:                  ; Will loop the hours from 0-12, then repeat
        MINUTES_LOOP:           ; Will loop the minutes from 0-60
            SECONDS_LOOP:       ; Will loop the seconds from 0-60

                MOV AX, start_second    ; This code block handles comparing
                CMP second, AX          ; between the current time and the start
                JNE PROCEDE             ; time to decide when to quit. If any 
                MOV AX, start_minute    ; of the three variables don't match, we
                CMP minute, AX          ; Jump to proceed, skipping the
                JNE PROCEDE             ; unconditional JMP instruction that
                MOV AX, start_hour      ; quits the program.
                CMP hour, AX
                JNE PROCEDE
                JMP QUIT        ; If we reach this line we quit
                PROCEDE:        ; Label to skip the JMP to quit

                PUSH hour       ; Push the current hour onto the stack
                CALL PRINTNUM   ; This proc prints any value stored on the stack

                CALL PRINTCOLON ; We print colons between each number

                PUSH minute     ; Push the current minute onto the stack
                CALL PRINTNUM   ; Call our print number procedure to print

                CALL PRINTCOLON ; I made it a procedure to reduce repeated code

                PUSH second     ; Push the current second onto the stack
                CALL PRINTNUM   ; Prints the number we pushed to the stack

                CALL PRNTNEWLINE; Prints a new line 

                CALL WASTETIME  ; Procedure to slow the programs execution speed

                INC second      ; Increment second variable to count upward
            CMP second, 60      ; Compare the current second with 60
            JNE SECONDS_LOOP    ; If it actually is 60, dont continue the loop.
                                
            MOV second, 0       ; After the seconds loop is done, we reset the  
            INC minute          ; current second to 0 and increment the minute.
        CMP minute, 60          ; Like with the second, we loop 60 times
        JNE MINUTES_LOOP

        MOV minute, 0           ; After the minutes complete, we reset them to
        INC hour                ; zero and increment the hour.
    CMP hour, 12                ; There are only twelve hours in a cycle, not 60
    JNE HOUR_LOOP               ; This which jump until the hour reachs 12
    MOV hour, 0                 ; At which point we reset the hour to zero and
    JMP HOUR_LOOP               ; unconditionaly jump back to the start. 

    QUIT:               ; The label we use to exit the program after completion
    MOV AH, 4Ch         ; The value "4Ch" in the AH register signifies to the
    INT 21h             ; interupt request that we would like to exit DOS
MAIN ENDP               ; End of the main procedure

PRINTNUM PROC           ; Begin the PRINTNUM procedure
    POP DX              ; Pop the return address (IP) from the stack into DX
    POP AX              ; Pop the two digit number from the stack into AX
    PUSH DX             ; Push the return address back onto the stack
                        ; It took me way too long to discover the return address 

    MOV BL, 10          ; We move 10 into BL, so that we can divide AX by 10
    DIV BL              ; Dividig a 2 digit number by 10 will output the left 
                        ; digit (quotient) and right digit (remainder) into 
                        ; AL and AH respectively

    ADD AL, 48          ; Adding 48 to a number turns it into the ASCII
    ADD AH, 48          ; representation of that number. Here we are adding
                        ; 48 to both AL and AH to transform both digits

    MOV BX, AX          ; We use BX as a temporary place to store AX while we 
                        ; use AH for interupt requests.

    MOV DL, BL          ; We move the left digit into DL to be displayed
    MOV AH, 2           ; "2" signifies to the interupt request that we want
    INT 21H             ; to display a single character from DL.

    MOV DL, BH          ; We move the right digit into DL to be displayed
    MOV AH, 2           ; As before, we are asking to display a single
    INT 21H             ; character. We then call the interupt request.

    RET                 ; Return from the procedure to the return address
PRINTNUM ENDP           ; Ends the PRINTNUM procedure

WASTETIME PROC          ; Start of the waste time procedure
    MOV CX, 50          ; The larger this number, the larger the delay
    DELAY:              ; This loop will waste CPU cyrcles, slowing the
        XOR AX, AX      ; program's execution
    LOOP DELAY          ; LOOP automatically JMP's and decriments CX, until CX=0
    RET                 ; Returns back to the function it was called from
WASTETIME ENDP          ; End of the wastetime procedure
                        
PRNTNEWLINE PROC        ; Start of the newline procedure
    LEA DX, newline     ; Load the newline string into DX
    MOV AH, 09H         ; "9" tells the interupt request that we would like to
    INT 21H             ; print a string!
    RET                 ; Returns back to the function it was called from
PRNTNEWLINE ENDP        ; End of the newline procedure

PRINTCOLON PROC         ; Start of the print colon procedure
    MOV DL, ':'         ; In order to print a single colon, which is a
    MOV AH, 2           ; character, we directly move ':' into the DL register
    INT 21H             ; and call the "print character" method. This is more
    RET                 ; direct than using a string just for a colon.
PRINTCOLON ENDP         ; The procedure ends here

TAKE_INPUT PROC         ; This procedure handles taking input and setting the
    MOV AH, 09H         ; relevent variables. First we ouput the input prompt, 
    LEA DX, msg1        ; which is a single message in this case.
    INT 21h

    CALL PRNTNEWLINE

    CALL PROMPT_INPUT   ; A procedure has been used for the repetitive actions.
    MOV hour, AX        ; The procedure stores its result in the AX register, 
    MOV start_hour, AX  ; which is then moved into the respective variables

    CALL PRINTCOLON     ; Between certain inputs we print colons

    CALL PROMPT_INPUT   ; This block takes input for the minutes
    MOV minute, AX
    MOV start_minute, AX

    CALL PRINTCOLON

    CALL PROMPT_INPUT   ; This block takes input for the seconds
    MOV second, AX
    MOV start_second, AX

    RET
TAKE_INPUT ENDP

PROMPT_INPUT PROC       ; The procedure that is called for every input
    MOV DL, '0'         ; Here we are printing 0, as we only take a single digit
    MOV AH, 2           ; of input and the hour/minute/second values are two
    INT 21H             ; digits by design.

    MOV AH, 1           ; Here we take input from the user. The value "1"
    INT 21H             ; instructs the interupt request to take a character for
    SUB AL, 48          ; input. We subtract 48 to turn the character into a
    XOR AH, AH          ; number, and XOR AH to avoid any corruption when moving
                        ; the entirety of AX into our time keeping variables

    CMP AL, 0           ; As I got tired of accidentally inputting "enter" into
    JL INVALID_INPUT    ; my clock program, I decided to write some code to
    CMP AL, 9           ; check for valid input. JL stands for jump if lower and
    JG INVALID_INPUT    ; JG stands for jump if greater. If less than 0 or more
                        ; than 9, we jump to invalid input.

    JMP VALID           ; If nothing is wrong, we will continue the program
        INVALID_INPUT:  ; If something IS wrong, we jump here
        CALL PRNTNEWLINE; Seperate the error message from the input

        MOV AH, 09H     ; Prints the invalid input message, informing the user
        LEA DX, msg2    ; that they made a mistake.
        INT 21h

        JMP QUIT        ; Exits the program
    VALID:

    RET                 ; Returns back to the take input procedure
PROMPT_INPUT ENDP       ; The end of the prompt input procedure

END MAIN 
