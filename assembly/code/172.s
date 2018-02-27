assume cs:code
code segment
start:	mov ah,00h
	int 16h
	mov ah,01h
	cmp al,'r'
	je red
	cmp al,'g'
	je green
	cmp al,'b'
	je blue
	jmp short subret
red:	shl ah,01h
green:	shl ah,01h
blue:	mov bx,0b800h
	mov es,bx
	mov bx,01h
	mov cx,7d0h
s:	and byte ptr es:[bx],0f8h
	or es:[bx],ah
	add bx,02h
	loop s
subret:	mov ax,4c00h
	int 21h
code ends
end start
