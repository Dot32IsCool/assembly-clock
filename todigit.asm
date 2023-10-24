.MODEL SMALL            ; Used as our program's code/data is smaller than 64kb
.STACK 100h             ; Allocates 256 bytes (100h in hex) for the stack

.DATA                   ; Variables begin here
    ; num DW 32           ; We initialise num to 32, with the width of 2 bytes
    newline DB 13,10,'$'; Characters 13 and 10 result in a new line
    second DW 0         ; Start at 0 seconds
    minute DW 0         ; Start at 0 minutes
    hour DW 0           ; Start at 0 hours
    msg1 db "Enter HOUR:MINUTE:SECOND$"
.CODE                   ; Code begins here
MAIN PROC               ; Begin the main procedure
    
    MOV AX, @DATA       ; In order to use our variables, we must initialise
    MOV DS, AX          ; the Data Segment. 

    CALL TAKE_INPUT

    HOUR_LOOP:
        MINUTES_LOOP:
            SECONDS_LOOP:       ; Will loop 60 times
                PUSH hour
                CALL PRINTNUM

                CALL PRINTCOLON

                PUSH minute
                CALL PRINTNUM

                CALL PRINTCOLON

                PUSH second     ; Push the current second onto the stack
                CALL PRINTNUM   ; Print the number we pushed to the stack

                CALL PRNTNEWLINE; Prints a new line 

                CALL WASTETIME  ; Slows the programs execution speed

                INC second      ; Add one to the second variable
            CMP second, 60      ; Compare the current second with 60
            JNE SECONDS_LOOP    ; If they are equal, dont continue the loop

            MOV second, 0
            INC minute
        CMP minute, 60
        JNE MINUTES_LOOP

        MOV minute, 0
        INC hour
    CMP hour, 12
    JNE HOUR_LOOP

    MOV AH, 4Ch         ; The value "4Ch" in the AH register signifies to the
    INT 21h             ; interupt request that we would like to exit DOS
MAIN ENDP               ; End of the main procedure

PRINTNUM PROC           ; Begin the PRINTNUM procedure
    POP DX              ; Pop the return address (IP) from the stack into DX
    POP AX              ; Pop the two digit number from the stack into AX
    PUSH DX             ; Push the return address back onto the stack

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

    RET                 ; Return from the procedure to the address pointer
PRINTNUM ENDP           ; Ends the PRINTNUM procedure

WASTETIME PROC          ; Start of the waste time procedure
    MOV CX, 50          ; The larger this number, the larger the delay
    DELAY:              ; This loop will waste CPU cyrcles, slowing the
        XOR AX, AX      ; program's execution
    LOOP DELAY          ; LOOP automatically JMP's and decriments CX, until CX=0
    RET                 ; Returns back to the function it was called from
WASTETIME ENDP          ; End of the wastetime procedure
                        
PRNTNEWLINE PROC        ; Star of the newline procedure
    LEA DX, newline     ; Load the newline string into DX
    MOV AH, 09H         ; "9" tells the interupt request that we would like to
    INT 21H             ; print a string!
    RET                 ; Returns back to the function it was called from
PRNTNEWLINE ENDP        ; End of the newline procedure

PRINTCOLON PROC
    MOV DL, ':'
    MOV AH, 2
    INT 21H
    RET
PRINTCOLON ENDP

TAKE_INPUT PROC
    MOV AH, 09H
    LEA DX, msg1
    INT 21h

    CALL PRNTNEWLINE
    CALL PROMPT_INPUT
    MOV HOUR, AX
    CALL PRINTCOLON
    CALL PROMPT_INPUT
    MOV MINUTE, AX
    CALL PRINTCOLON
    CALL PROMPT_INPUT
    MOV SECOND, AX

    RET
TAKE_INPUT ENDP

PROMPT_INPUT PROC
    ; Print zero
    MOV DL, '0'
    MOV AH, 2
    INT 21H

    ; Take input
    MOV AH, 1
    INT 21H
    SUB AL, 48
    XOR AH, AH

    RET
PROMPT_INPUT ENDP

END MAIN                ; Terminates the program
