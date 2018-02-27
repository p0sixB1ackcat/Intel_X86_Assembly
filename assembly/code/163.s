assume cs:code
code segment
start:	mov ax,00f8h
	call showbyte
	mov ax,4c00h
	int 21h
showbyte:jmp short show
	 table db '0123456789ABCDEF'
show:	 push es
	 push bx
	 mov ah,al
	 mov cl,04h
	 shr ah,cl
	 and al,0fh
	 mov bl,ah
	 mov bh,00h
	 mov ah,table[bx]
	 mov bl,al
	 mov bh,00h
	 mov al,table[bx]
	 mov bx,0b800h
	 mov es,bx
	 mov es:[0a0h*0ch+40h-02h],ah
	 mov es:[0a0h*0ch+40h],al
	 pop bx
	 pop es
	 ret
	
code ends
end start
