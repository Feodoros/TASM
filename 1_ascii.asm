                                                                                                                                                                                                                                                                                                                                                                                                                                                       UЄряя   ряря                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                    ряя   ряря                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                    еURS    BAT           ‚ЄјP ‚  WRITER  BAT           “­јP   CURS2   BAT           ­јP ­  еURS    COM           ‹ ИP    еRITER  OBJ           Њ ИP Q  еRITER  COM           Њ ИP	 b                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                  ; goto cmpl1
; Запись на дискетку
.model tiny
.386
.code
org 100h
start:
	jmp next
filename db 'curs2.com',0
errormes db 'Error!$'
success  db 'Success!$'
next:	
    ; Открытие файла
	mov ah, 3Dh
	mov al, 0
	lea dx, filename
	int 21h
	jc err1	

	; в ax находится handler
	mov bx, ax	; file hanlder from ax
	mov ah, 3Fh	;
	mov cx, 512	; number of bytes to read
	lea dx, buff	; place to read
	int 21h
	jc err1

; закрыли файл
	mov ah, 3Eh
	int 21h

; прерывание записи на носитель 
	mov ah, 03h
	mov al, 1	; number sector to write
	mov ch, 0	; cylinder number
	mov cl, 1	; starting sector
	mov dh, 0	; head number
	mov dl, 0	; drive number
	; запись на дискетку
	lea bx, buff
	int 13h
	jc err1
	
	; вывод строки 
	lea dx, success
	mov ah, 09h
	int 21h
	ret

buff 	db 512 dup(0) ; записываем 512 нулей -- место для загрузочной программы
err1:
	lea dx, errormes
	mov ah, 09h
	int 21h
	ret
end start
;:cmpl1
;tasm /m5 writer.bat
;tlink /x/t writer   


; Вывод ASCII																																																										 ; goto cmpl1
.model tiny
.486
.code
org 100h
start:
	jmp next
next:
	mov ah, 00h		; mode
	mov al, 00h
	int 10h
	
	mov cl, 0FFh   ; инкремент (значение аски символа)

	mov dh, 00h		; row
	mov dl, 0FEh		; colomn
print:
				; 15 colomns
				; inc colomn by 2	
	add dl, 02h
	
	cmp dl, 28h ; закончились ли колонки
	jne not_full_line
	add dh, 01h
	mov dl, 00h

not_full_line: ; если не дошли до конца
	mov ah, 02h
	mov bh, 00h 	; устанавливаем курсор
	int 10h			; curs is set

	add cl, 01h ; увеличиваем инкремент
	
	cmp cl, 0ffh ; закончили печатать или нет 
	je wait
	
	mov bl, cl

	mov ah, 0ah
	mov al, cl
	mov bh, 00h
	mov cx, 01h
	int 10h			; write symb

	mov cl, bl

	jmp print ; переходим в print

wait:
	jmp wait ; вечный цикл

	; Байты для загрузочной программы
	db (510-($-start)) dup(0)	
	db 55h, 0AAh	
end start
;:cmpl1
;tasm /m5 curs2.bat
;tlink /x/t curs2                                                                                                                                                                                                                                                                                                                                  