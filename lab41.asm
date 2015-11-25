STSEG SEGMENT PARA STACK "STACK"
STSEG ENDS

DSEG SEGMENT PARA PUBLIC "DATA"
	
	ARRAY DW 1, 2, 3, 4, 5
	COUNT DW 5

	NumberBuffer DW 0
	
DSEG ENDS

CSEG SEGMENT PARA PUBLIC "CODE"
	ASSUME CS:CSEG, DS:DSEG, SS:STSEG
	MAIN PROC FAR 
	
	MOV AX, DSEG
	MOV DS, AX
	
	BEGIN_LABEL:
		CALL COUNT_SUM
		;CALL COUNT_EQUATION 
		CALL PRINT_NUMBER

		MOV AX, 4C00h
		INT 21h
		
	MAIN ENDP
	
	COUNT_SUM PROC 
		MOV CX, COUNT
		XOR AX, AX
		XOR SI, SI
		loop1:
			ADD AX, ARRAY + SI
			INC SI
		LOOP loop1
		MOV NumberBuffer, AX
		
		
	COUNT_SUM ENDP
	
	PRINT_NUMBER PROC
	
		MOV BX, NumberBuffer
		OR BX, BX
		JNS M1 ; если флаг знака был 0 (т.е. число положительное) то идем в M1
		MOV AL, "-" ; если число было отрицательным 
		INT 29H ; то выводим минус на экран
		NEG BX ; инвертируем число
	M1:
		MOV AX, BX ; записываем число в AX (нужно будет для деления)
		XOR CX, CX ; обнуляем CX (нужно будет для цикла)
		MOV BX, 10 ; записываем в BX 10 (это будет наш делитель)
	M2:
		XOR DX, DX ; т.к. резльтат деления будет записан в паре AX:DX (Целая часть:Остача) на каждой итерации обнуляем остачу
		DIV BX ; делим AX на BX (т.е. на 10)
		ADD DL, "0" ; добавляем к остаче код символа 0 (что бы можно было вывести на экран)
		PUSH DX ; записываем этот символ в стек
		INC CX ; увеличиваем CX (CX == количество символов для вывода)
		TEST AX, AX ; проверяем или AX не равен 0 (можно было написать cmp AX, 0 , но test ax,ax типа быстрее)
		JNZ M2 ; если не ноль то делим опять
	M3:
		POP AX ; достаем символ из стека
		INT 29H ; выводим на экран
		LOOP M3 
		
		MOV AL, 13 ; возращаем каретку на начало строки (это чисто для косметического эффекта)
		INT 29H 
		
		RET
		
	ENDP PRINT_NUMBER
	
CSEG ENDS
END MAIN