; @echo off
; goto l1
	.model	tiny
	.386
	.code
	org	100h
_:	
	jmp	start
kek	db	'$$$$$'
filename db	"hw.com",0
errmes	db	"Error",13,10,"$"
finish	db	"Finish",13,10,"$"
outmes	db	"0000:0000",13,10,"$"
old_int1_offset	dw	0
old_int1_cs	dw	0

int1_handler:
	push	bp 	;save bp
	mov	bp, sp  ;copy stack-pointer(sp) into bp 

	pusha		;save AX, CX, ... , in stack
	push	ds	;ds -- Data segment

	push	cs	;cs -- Code segment
	pop	es	;es -- Extra segment
	push	cs
	pop	ds	

	lea	di, outmes	;di = outmes
	mov	bx, [bp+4]	;cs to print
	call	h4
	lea	di, [outmes+5]	 
	mov	bx, [bp+2]	;ip to print
	call	h4		

	lea	dx, outmes
	mov	ah, 09h
	int	21h

	pop	ds
	popa

	pop	bp
	iret

start:
	mov	ax, 3D00h	; Open file
	lea	dx, filename
	int	21h	
	
	mov	bx, ax		; Read file
	mov	ah, 3Fh
	mov	cx, 100h
	lea	dx, prog
	int	21h

	mov	ah, 3Eh		; Close file
	int	21h

	mov	ah, 35h		;save old 1 interrupt
	mov	al, 1
	int	21h
	mov	old_int1_offset, bx
	mov	old_int1_cs, es

	mov	ax, 2501h	;writer new 1 interrupt
	lea	dx, int1_handler	
	int	21h

	pushf			; Change flags register
	pop	dx
	or	dx, 100h	; TF:=1	

	mov	bx, 100h

	lea	cx, psp
	shr	cx, 4

	mov	ax, cs
	add	ax, cx
	
	push	ax
	pop	ds

	pushf
	push	cs			; address for called program
	lea	cx, after_debug		; to return to
	push	cx
	xor	cx, cx ;0
	push	cx

	push	dx	;called flags
	push	ax	;code segment
	push	bx	;100 - ip 
	iret

after_debug:
	push	cs
	pop	ds

	lea	dx, finish
	mov	ah, 09h
	int	21h
	ret

er:
	lea	dx, errmes
	mov	ah, 09h
	int	21h
	ret

h4:	ror	bx, 8
	call	h2
	ror	bx, 8
h2:	mov	al, bl
	shr	al, 4
	call	h1
	mov	al, bl
h1:			; al - number, di - destination
	and	ax, 0fh
	cmp	al, 10
	sbb	al, 69h
	das
	stosb
	ret

align	16
psp:
	iret
	db	100h-($-psp) dup(0)	; program segment prefix
prog	db	100h dup(0)

end _	
; :l1
; tasm /m5 deb1.bat
; tlink /x/t deb1.obj
; del deb1.obj

