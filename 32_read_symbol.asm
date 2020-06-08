	; @echo off
	; goto l1
	.model	tiny
	.386
	.code
	org	100h
_:
	jmp start

string  db '     ', 13,10,'$'
start:

	mov bx, [0:41Ah] ; get head
	mov cx, [0:41Ch] ; get tail
	cmp cx, bx	
	je start		 ; условный переход 

	mov ah, 00h		 ; get next key
	int 16h			

	mov cx, ax		 ; сохраняем ax в cx (ascii symbol)

	lea di, string	
	mov bl, ah 		 ; scan-code
	call h2			 ; конверт scan-code в char

	mov ax, cx		 ; возвращаем старое значение ax
					 ; чтобы получить ascii символ

	cmp al, 1Bh 	 ; escape
	je exit
	cmp al, 24h		 ; $
	jne print
	mov al, 53h	 	 ; конвертируем $ в S и помечаем buffer как прочитанный

print:
	inc di				; space to write ascii symbol
	stosb				; записываем al (ascii symbol) в адресс di

	mov ah, 09h	
	lea dx, string		; выводим строку
	int 21h		

	cli					; игнорируем прерывания

	push es				; сохраняем es  
	push 0				; es := 0
	pop es	

	mov al, es:[41Ah]   
	mov es:[41Ch], al	; tale := head

	pop es				; возвращаем прошлое значение es

	sti					; un-ignore interrupts

	jmp start

h2: 
	mov al, bl	; bl = ah = scan-code

	shr al, 4 	; al = high nibble
	call h1

	mov al, bl	; al = low nibble

h1:
				; DI - начальная строка
	and ax, 0fh	; ah = last nibble
	cmp al, 10 	; проверяем это буква или цифра (10 = 0Ah)
	sbb al, 69h ; al = al - (69h + CF)
	das	    
	stosb	    ; сохраняем AL как ES:DI
	
exit:   ret
end _	
; :l1
; tasm /m5 buffer.bat
; tlink /x/t buffer.obj
; del buffer.obj

