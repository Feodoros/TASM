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

	mov bx, [0:41Ah] ;get head
	mov cx, [0:41Ch] ;get tail
	cmp cx, bx	
	je start

	mov ah, 00h	;get next key
	int 16h		;

	mov cx, ax	;save ax to cx (ascii symbol)

	lea di, string	
	mov bl, ah 	;scan-code
	call h2		;convert scan-code to char

	mov ax, cx	;return old ax value
			;to get ascii symbol

	cmp al, 1Bh 	;escape
	je exit
	cmp al, 24h	;$
	jne print
	mov al, 53h	;convert $ to S and not mark buffer as read

print:
	inc di	;space to write ascii symbol
	stosb	;write al (ascii symbol) to adress di

	mov ah, 09h	;
	lea dx, string	; print string
	int 21h		;

	cli	; ignore interrupts

	push es	; save es  
	push 0	; es := 0
	pop es	;

	mov al, es:[41Ah] ;  
	mov es:[41Ch], al ; tale := head

	pop es	; return old es value

	sti	; un-ignore interrupts

	jmp start

h2: 
	mov al, bl ; bl = ah = scan-code

	shr al, 4  ; al = high nibble
	call h1

	mov al, bl ; al = low nibble

h1:
	; DI - start of string

	and ax, 0fh ; ah = last nibble
	cmp al, 10  ; check if its letter or number (10 = 0Ah)
	sbb al, 69h ; al = al - (69h + CF)
	das	    ; 
	stosb	    ; store AL as ES:DI
	
exit:   ret
end _	
; :l1
; tasm /m5 buffer.bat
; tlink /x/t buffer.obj
; del buffer.obj

