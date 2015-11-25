;?????? ????????????
EXIT MACRO 
	MOV AX, 4C00h
	INT 21h	
ENDM


STSEG SEGMENT PARA STACK "STACK"
STSEG ENDS

DSEG SEGMENT PARA PUBLIC "DATA"

	ArraySize DW 0
	
	Array DW 10*10 DUP ('0')

	StringBuffer DB 4, ?, 4 DUP('*')
	EnterCount DB "Enter count of array elements (Min: 2, Max 10): $"
	EnterElement DB "Enter number in range from -320 to 320 of element [$"
	TryAgainMsg DB "Enter 1 to start again: $"
	ErrorSymbol DB "Dont enter symbols!",10,13,"Correct format is [+-][0-9]",10,13, "From 2 to 10 for array size", 10, 13,"From -320 to 320 for elements", 10, 13,"$"	
	ErrorNumber DB "Incorrect number!",10,13,"Correct format is [+-][0-9]",10,13, "From 2 to 10 for array size", 10, 13,"From -320 to 320 for elements", 10, 13,"$"	
	ArraySizeError DB "Array size error. Enter values in range [-2; 10]", 10, 13, "$"
	ElementMsg DB "Enter element to find: $"
	ResultMsg DB 10, 13, "Your result is: $"
	NoneResult DB "None $"
	
	TOP_LIMIT DW 320
	BOTTOM_LIMIT DW -320
	
	TEN_DW DW 10
		
	NumberBuffer DW 0
	Element DW 0 
	HAS_RESULT DW 0
	IS_NECESSARY DW 0
	IS_ELEMENT DW 0 
	
	ROW DW 0 
	COLUMN DW 0 
	
DSEG ENDS

CSEG SEGMENT PARA PUBLIC "CODE"
	ASSUME CS:CSEG, DS:DSEG, SS:STSEG
	MAIN PROC FAR 
	
		MOV AX, DSEG
		MOV DS, AX
	
		CALL START
		
	MAIN ENDP
	
	;Starting procedure
	START PROC 		
	
		MOV AX, 0
		MOV HAS_RESULT, AX
		MOV IS_ELEMENT, AX
		MOV IS_NECESSARY, AX
	
		LEA DX, EnterCount
		MOV AH, 9
		INT 21h
	
		CALL READ_NUMBER
		CALL CONVERT_NUMBER 
		
		MOV AX, NumberBuffer		
		
		MOV ArraySize, AX	
		CMP ArraySize, 1
		JLE ERROR_SIZE
		CMP ArraySize, 10
		JG ERROR_SIZE 
		
		MOV AL, 10
		INT 29h
		MOV AL, 13
		INT 29h
		
		CALL READ_ARRAY
		CALL READ_NECESSARY
		CALL FIND_ELEMENT
		
		LEA DX, TryAgainMsg
		MOV AH, 9
		INT 21h
		
		CALL READ_NUMBER
		CALL CONVERT_NUMBER
		CMP NumberBuffer, 1
		JE START	
		EXIT			
	
		ERROR_SIZE:
			LEA DX, ArraySizeError
			MOV AH, 9
			INT 21h		
			
			CALL START
	START ENDP
	
	READ_ARRAY PROC
		PUSH CX
		MOV CX, ArraySize
		MOV DI, 0
		
		READ_LOOP:			
		
			MOV AX, 1
			MOV IS_ELEMENT, AX 
			
			MOV DX, ArraySize
			SUB DX, CX
			INC DX
			
			PUSH CX
				MOV CX, ArraySize
				INNER_READ_LOOP:				
					
					PUSH DI
					CALL READ_ELEMENT
					POP DI 
					MOV Array[DI], AX
					ADD DI, 2
					
				LOOP INNER_READ_LOOP
				
			POP CX
			
		LOOP READ_LOOP		
		
		POP CX		
		RET		
	READ_ARRAY ENDP 
	
	FIND_ELEMENT PROC
	
		LEA DX, ResultMsg
		MOV AH, 9
		INT 21h
	
		PUSH CX
		MOV CX, ArraySize
		MOV DI, 0
		
		OUT_LOOP:			
			
			MOV DX, ArraySize
			SUB DX, CX
			INC DX
			
			PUSH CX
				MOV CX, ArraySize
				IN_LOOP:							
					MOV AX, Array[DI]
					CMP AX, Element
					JNE END_IN_LOOP
					
					MOV AX, 1
					MOV HAS_RESULT, AX
					
					MOV AX, '['
					INT 29h	
					MOV NumberBuffer, DX
					PUSH CX
					PUSH DX
					CALL PRINT_NUMBER
					POP DX
					POP CX
					MOV AX, ','
					INT 29h	
					
					PUSH DX
					MOV DX, ArraySize
					SUB DX, CX
					INC DX
					MOV NumberBuffer, DX
					PUSH CX
					PUSH DX
					CALL PRINT_NUMBER
					POP DX
					POP CX
					MOV AX, ']'
					INT 29h	
					POP DX
					
					
					END_IN_LOOP:
					ADD DI, 2
					
				LOOP IN_LOOP
				
			POP CX
			
		LOOP OUT_LOOP	
		
		CMP HAS_RESULT, 1
		JE HAS
		
		LEA DX, NoneResult
		MOV AH, 9
		INT 21h
		
		HAS:
		
			MOV AL, 10
			INT 29h
			MOV AL, 13
			INT 29h	
		
		POP CX	
		RET	
	
	FIND_ELEMENT ENDP
	
	READ_NUMBER PROC
			
		LEA DX, StringBuffer
		MOV AH, 10
		INT 21h
		
		MOV AL, 10
		INT 29h
		MOV AL, 13
		INT 29h		
		
		RET 
		
	READ_NUMBER ENDP
	
	READ_NECESSARY PROC
	
		MOV AX, 0
		MOV IS_ELEMENT, AX
	
		MOV AX, 1
		MOV IS_NECESSARY, AX
	
		LEA DX, ElementMsg
		MOV AH, 9
		INT 21h
	
		LEA DX, StringBuffer
		MOV AH, 10
		INT 21h
		
		MOV AL, 10
		INT 29h
		MOV AL, 13
		INT 29h		
		
		CALL CONVERT_NUMBER
		MOV AX, NumberBuffer
		MOV Element, AX 
		
		RET 
	
	READ_NECESSARY ENDP
	
	READ_ELEMENT PROC	
	
		PUSH DX
		LEA DX, EnterElement
		MOV AH, 9
		INT 21h
		POP DX
					
		MOV NumberBuffer, DX
		PUSH CX
		PUSH DX
		CALL PRINT_NUMBER
		POP DX
		POP CX
					
		MOV AX, ']'
		INT 29h	
					
		MOV AX, '['
		INT 29h	
		
		PUSH DX
		
		MOV DX, ArraySize
		SUB DX, CX
		INC DX
		
		MOV NumberBuffer, DX
		PUSH CX
		PUSH DX
		CALL PRINT_NUMBER
		POP DX
		POP CX
		
		MOV AX, ']'
		INT 29h	
		MOV AX, ':'
		INT 29h	
		
		POP DX
		
		PUSH DX
		LEA DX, StringBuffer
		MOV AH, 10
		INT 21h
		
		MOV AL, 10
		INT 29h
		MOV AL, 13
		INT 29h	
		
		PUSH CX
		CALL CONVERT_NUMBER
		POP CX
		MOV AX, NumberBuffer
		
		POP DX
		
		RET 		
	READ_ELEMENT ENDP
	
	
	CONVERT_NUMBER PROC
		
		XOR BX, BX
		XOR CX, CX
		XOR DI, DI
		
		MOV CL, StringBuffer + 1
		
		MOV AL, StringBuffer + 2
		CMP AL, '-'
		JE IS_SIGN
		CMP AL, '+'
		JE IS_SIGN
		JMP NO_SIGN
		
		IS_SIGN :
			MOV DI, 1
		
		NO_SIGN :
			MOV SI, CX
			ADD SI, 1
			
		SYMBOL_LOOP:
			
			CMP CX, DI
			JE HANDLE_SIGN
			
			XOR AX, AX
			MOV AL, StringBuffer[SI]
			SUB AL, '0'
			
			CMP AL, 0
				JL ERROR_SYMBOL
			CMP AL, 9
				JG ERROR_SYMBOL
			JMP NO_ERROR
			
			ERROR_SYMBOL:
				LEA DX, ErrorSymbol
				MOV AH, 9
				INT 21h
				CMP IS_ELEMENT, 1
				JE ERROR_ELEMENTS
				CMP IS_NECESSARY, 1
				JE ERROR_NECESSARY
				CALL START
				
			ERROR_NUMBER:
				LEA DX, ErrorNumber
				MOV AH, 9
				INT 21h
				CMP IS_ELEMENT, 1
				JE ERROR_ELEMENTS
				CMP IS_NECESSARY, 1
				JE ERROR_NECESSARY
				LEA DX, ErrorNumber
				MOV AH, 9
				INT 21h
				CALL START
			
			ERROR_NECESSARY:
			
				CALL READ_NECESSARY
				RET 
			
			ERROR_ELEMENTS:
				CALL READ_ELEMENT
				RET
				
			NO_ERROR:
			
				CMP CL, StringBuffer + 1
				JE END_IMUL
				
				PUSH CX
				
				MOV DL, StringBuffer + 1
				SUB DL, CL
				MOV CL, DL
				
				INSIDE_LOOP:
					MUL TEN_DW				
				LOOP INSIDE_LOOP
				
				POP CX
			
				END_IMUL:
					DEC SI
					ADD BX, AX
					JO ERROR_NUMBER
			
		LOOP SYMBOL_LOOP
		
		
		HANDLE_SIGN:
			MOV AL, StringBuffer + 2
			CMP AL, '-'
			JNE SAVE_RESULT
			NEG BX
			JMP SAVE_RESULT
		
		SAVE_RESULT:
			CMP BX, TOP_LIMIT
			JG ERROR_NUMBER
			CMP BX, BOTTOM_LIMIT
			JL ERROR_NUMBER
			
			MOV NumberBuffer, BX
			RET
		
	ENDP CONVERT_NUMBER	
	
	PRINT_NUMBER PROC
	
		MOV BX, NumberBuffer
		OR BX, BX
		JNS M1 
		MOV AL, "-" 
		INT 29H 
		NEG BX 
	M1:
		MOV AX, BX 
		XOR CX, CX 
		MOV BX, 10 
	M2:
		XOR DX, DX 
		DIV BX 
		ADD DL, "0" 
		PUSH DX 
		INC CX 
		TEST AX, AX 
		JNZ M2 
	M3:
		POP AX 
		INT 29H 
		LOOP M3
		
		RET
		
	ENDP PRINT_NUMBER
		
	
CSEG ENDS
END MAIN