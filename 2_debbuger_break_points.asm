; goto l1
	.model	tiny
	.386
	.code
	org	100h
_:	
	jmp	start
filename db	"hw.com",0
errmes	db	"Error",13,10,"$"
finish	db	"Finish",13,10,"$"
outmes	db	"0000:0000",13,10,"$"

int3_handler:
	push	bp
	mov	bp, sp

	pusha
	push	ds

	push	cs
	pop	es
	push	cs
	pop	ds	

	lea	di, outmes
	mov	bx, [bp+4]
	dec	bx
	call	h4
	lea	di, [outmes+5]
	mov	bx, [bp+2]
	call	h4

	lea	dx, outmes
	mov	ah, 09h
	int	21h

	mov	ax, [bp+2]	; CS
	dec	ax		
	mov	bx, ax
	add	bx, offset psp
	add	ax, offset prog
	push	bx
	mov	bx, ax
	
	mov	cx, [bx]
	pop	bx

	; восстановление перезаписанных под брейк-поинты байты
	mov byte ptr cs:[bx], cl
	mov ax, [bp+2]
	dec ax
	mov cs:[bp+2], ax

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

	mov	si, offset prog
	mov	di, offset progCopy
	mov	cx, 100h
	rep	movsb

	mov	ah, 25h
	mov	al, 3
	lea	dx, int3_handler
	int	21h

	pushf
	pop	dx
	or	dx, 100h

	lea 	cx, psp
	shr	cx, 4
	mov	ax, cs
	add	ax, cx
	push	ax
	pop 	ds

	lea	cx, after_debug		; to return to
	pushf
	push	cs
	push	cx

	push	0

	push	dx
	push	ax
	push	100h

	mov byte ptr es:[psp+0112h], 0CCh
	mov byte ptr es:[psp+0114h], 0CCh

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
h1:	; al - number, di - destination
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
progCopy db	100h dup(0)

end _	
; :l1
; tasm /m5 debug.bat
; tlink /x/t debug.obj
; del debug.obj