assume cs:code
code segment
assume cs:code
start:	mov ax,initsg
    mov es,ax
	mov bx,00h
	mov dx,0000h
	mov ch,00h
	mov cl,01h
	mov al,10h
	mov ah,03h
	int 13h

    mov ax,linesg
    mov es,ax
    mov bx,00h
    mov cl,02h
    mov dx,00h
    mov ch,00h
    mov al,10h
    mov ah,03h
    int 13h

	mov ax,4c00h
	int 21h
code ends


initsg segment
assume cs:initsg
init:   mov ax,2000h
        mov es,ax
        mov bx,00h
        mov dx,00h
        mov ch,00h
        mov cl,02h
        mov al,10h
        mov ah,02h
        int 13h
        mov ax,2000h
        push ax
        mov ax,0000h
        push ax
        retf
initsg ends

linesg segment
assume cs:linesg
l:	jmp line
    str db '1) reset pc',0
line:	mov ax,0b800h
	mov es,ax
	mov di,0a0h * 03h + 50h
	mov bx,00
s:	mov cl,str[bx]
    	mov ch,00h
	jcxz lret
	mov es:[di],cl
	mov byte ptr es:[di+1],1ch
	inc bx
	add di,02h
	jmp s
lret:mov ax,4c00h
     int 21h

linesg ends

end start
