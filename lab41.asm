;Базові макрокоманди
EXIT MACRO 
	MOV AX, 4C00h
	INT 21h	
ENDM


STSEG SEGMENT PARA STACK "STACK"
STSEG ENDS

DSEG SEGMENT PARA PUBLIC "DATA"

	ArraySize DW 0
	
	Array DW 100, ?, 100 DUP ('0')

	StringBuffer DB 4, ?, 4 DUP('*')
	EnterCount DB "Enter count of array elements (Min: 2, Max 100): $"
	EnterElement DB "Enter number in range from -320 to 320 of element [$"
	TryAgainMsg DB "Enter 1 to start again: $"
	ErrorSymbol DB "Dont enter symbols!",10,13,"Correct format is [+-][0-9]",10,13, "From 2 to 100 for array size", 10, 13,"From -320 to 320 for elements", 10, 13,"$"	
	ErrorNumber DB "Incorrect number!",10,13,"Correct format is [+-][0-9]",10,13, "From 2 to 100 for array size", 10, 13,"From -320 to 320 for elements", 10, 13,"$"	
	ArraySizeError DB "Array size error. Enter values in range [-2; 100]", 10, 13, "$"
	
	TOP_LIMIT DW 320
	BOTTOM_LIMIT DW -320
	
	TEN_DW DW 10
		
	NumberBuffer DW 0
	
DSEG ENDS


CSEG SEGMENT PARA PUBLIC "CODE"
	ASSUME CS:CSEG, DS:DSEG, SS:STSEG
	MAIN PROC FAR 
	
		MOV AX, DSEG
		MOV DS, AX
	
		CALL START
		
	MAIN ENDP
	
	;Процедура для початку роботи програми
	START PROC
	
		LEA DX, EnterCount
		MOV AH, 9
		INT 21h
	
		CALL READ_NUMBER
		CALL CONVERT_NUMBER 
		
		MOV AX, NumberBuffer
		
		MOV ArraySize, AX	
		CMP ArraySize, 1
		JLE ERROR_SIZE
		CMP ArraySize, 100
		JG ERROR_SIZE 
		
		MOV AL, 10
		INT 29h
		MOV AL, 13
		INT 29h
		
		CALL READ_ARRAY
		CALL COUNT_SUM
		
		MOV AL, 10
		INT 29h
		MOV AL, 13
		INT 29h
		
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
			LEA DX, EnterElement
			MOV AH, 9
			INT 21h
			
			MOV DX, ArraySize
			SUB DX, CX
			INC DX
			MOV NumberBuffer, DX
			PUSH CX
				PUSH DI
					CALL PRINT_NUMBER
					PUSH AX
					MOV AX, ']'
					INT 29h	
					MOV AX, ':'
					INT 29h	
					POP AX
					CALL READ_NUMBER
					CALL CONVERT_NUMBER
					MOV AX, NumberBuffer
					POP DI
					MOV Array[DI], AX
					ADD DI, 2
			POP CX
			
		LOOP READ_LOOP		
		
		POP CX		
		RET		
	READ_ARRAY ENDP 
	
	COUNT_SUM PROC
	
		MOV CX, ArraySize
		XOR SI, SI
		XOR BX, BX
		MOV BX, [Array + SI]
		DEC CX
		
		SUM_LOOP:
			ADD SI, 2
			ADD BX, [Array + SI]
		LOOP SUM_LOOP				
			
		MOV NumberBuffer, BX
		CALL PRINT_NUMBER	

		RET
	
	COUNT_SUM ENDP
	
	;Процедура зчитування рядка з консолі
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
	
	;Процедура перетворення рядка у число
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
				CALL START
				
			ERROR_NUMBER:
				LEA DX, ErrorNumber
				MOV AH, 9
				INT 21h
				CALL START
				
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
			;Перевірка на коректні межі
			CMP BX, TOP_LIMIT
			JG ERROR_NUMBER
			CMP BX, BOTTOM_LIMIT
			JL ERROR_NUMBER
			
			MOV NumberBuffer, BX
			RET
		
	ENDP CONVERT_NUMBER	
	
	;Процедура для виводу числа
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