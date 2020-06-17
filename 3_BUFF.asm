; goto cmpl
.model tiny
.386
.code
org 100h
start:
	jmp next
scan 	db 'scan:__h',13,10,'$'
ascii	db 'ascii:__h',13,10,'$'
t 	db '__',13,10,'$'
next:
	push es

	cli						; if 13h 28h then 
	mov ax, 40h
	mov es, ax
	mov ah, [es:1Ch]
	mov [es:1Ah], ah		; clear buff
	sti

	pop es

wait_for_key:
	push es

	mov ax, 40h
	mov es, ax
	mov al, [es:1Ah]   ; ascii, scan
	mov ah, [es:1Ch]
	cmp ah, al

	pop es
	je wait_for_key

	push es

	mov bx, 40h
	mov es, bx
	movzx bx, al
	mov cl, [es:bx]	; ascii
	mov ch, [es:bx+1]	; scan

	pop es
	
	xor ah, ah
	push ax

	movzx bx, ch
	lea di, [scan+5]
	call h2

 	lea dx, scan
	mov ah, 09h
	int 21h
				
	movzx bx, cl
	lea di, [ascii+6]
	call h2
	
	lea dx, ascii
	mov ah, 09h
	int 21h

	pop ax

	cmp al, 3ch
	jne head_before_tail

	mov al, 1Eh 		; set to start (60->30)
	jmp inc_head	

head_before_tail:
	inc al 
	inc al

inc_head:
			;test

	;mov bl, al
	push es	
	mov bx, 40h
	mov es, bx

	mov [es:1Ah], al
	pop es
	
	;mov al, [es:1Ah]


	cmp ch, 01h
	jnz wait_for_key
finish:	
	ret
int9:
	sti

	in al, 61h
	or al, 10000000b
	out 61h, al
	and al, 01111111b
	out 61h, al
		
	mov al, 20h
	out 20h, al

	iret
h8:
	ror ebx, 16
	call h4
	ror ebx, 16
h4:
	ror bx, 8
	call h2
	ror bx, 8
h2: ;; write to console 2 bytes
	mov al, bl
	shr al, 4
	cmp al, 10
	sbb al, 69h
	das
	cld
	stosb
	mov al, bl
	and al, 0fh
	cmp al, 10
	sbb al, 69h
	das
	stosb
	ret

end start
; :cmpl
; tasm /m5 /l kb_buff.bat
; tlink /x/t kb_buff.obj
