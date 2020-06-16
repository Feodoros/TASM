; @echo off
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
old_int1_offset	dw	0
old_int1_cs	dw	0

int1_handler:	; в bp кладем начальное состояние стека
	push	bp 	; вносим bp (base pointer) в стек 
	mov	bp, sp  ; копируем содержимое stack-pointer(sp) в bp 

	pusha		; помещаем в стек значения всех 16-битных регистров общего назначения
	push	ds	; вносим ds (Data segment) в стек

	push	cs	; вносим cs (Code segment) в стек
	pop	es	    ; извлекаем операнд из стека в es -- Extra segment
	push	cs
	pop	ds	    

	lea	di, outmes		; di = outmes
	mov	bx, [bp+4]		; копируем содержимое [bp+4] в bx (base register), cs to print
	call	h4
	lea	di, [outmes+5]  	 
	mov	bx, [bp+2]		; ip to print
	call	h4 			; вызов процедуры h4, записывает 4 байта в памяти	

	lea	dx, outmes  	; dx (data register)
	mov	ah, 09h     	; ah -- AX (primary accumulator) high, 09h -- вывод строки
	int	21h         	; прерывание

	pop	ds
	popa		   		; извлекаем из стека значения всех 16-битных регистров общего назначения

	pop	bp
	iret		   		; возврат из прерывания при 16-битном размере операнда
	; передаем управление следующей команде в HelloASM
	; возвращаемся к программе

start:
	mov	ax, 3D00h	; открываем файл
	lea	dx, filename
	int	21h	
	
	mov	bx, ax		; читаем файл
	mov	ah, 3Fh
	mov	cx, 100h
	lea	dx, prog
	int	21h

	mov	ah, 3Eh		; закрываем файл
	int	21h

	; Переписывание обработчика
	mov	ah, 35h		; сохраянем прошлое прерывание 
	mov	al, 1
	int	21h
	mov	old_int1_offset, bx
	mov	old_int1_cs, es

	mov	ax, 2501h	; записываем новое прерывание 
	lea	dx, int1_handler	
	int	21h

	pushf			; вносим в стек значения регистров флагов
	pop	dx
	or	dx, 100h	; TF := 1	

	; Подготавливаем стек для передачи управления другой программе
	mov	bx, 100h

	lea	cx, psp
	shr	cx, 4       ; свдиг cx вправо 4 раза

	mov	ax, cs
	add	ax, cx      ; ax := ax + cx
	
	push	ax
	pop	ds

    ; Подготовка стека, когда мы выходим из программы, для получения управления
	pushf
	push	cs				; адресс вызываемой программы
	lea	cx, after_debug		; to return to
	push	cx
	xor	cx, cx 				; 0
	push	cx

	push	dx				; called flags
	push	ax				; code segment
	push	bx				; 100 - ip 
	iret					; извлекает из стека cs, ip, регистр флагов

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
h1:					; al - number, di - destination
	and	ax, 0fh		
	cmp	al, 10 		; al ?= 10
	sbb	al, 69h		; вычитание с заемом
	das				; десятичная коррекция в регистре AL после вычитания
	stosb			; запись байта в строку
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

