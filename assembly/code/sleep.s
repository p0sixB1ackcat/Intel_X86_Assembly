assume cs:code
code segment
start:   mov ax,0b800h
	 mov es,ax
	 mov ax,0a0h
	 mov bl,0ch
	 mul bl
 	 add ax,40h
	 mov di,ax
	 mov al,'a'
s:	 mov es:[di],al
	 call sleep
	 inc al
	 cmp al,'z'
	 jna s
	 mov ax,4c00h
	 int 21h
sleep:	 push ax
	 push dx
	 mov ax,0000h
	 mov dx,0001h
sub1: 	 sub ax,01h
	 sbb dx,00h
	 cmp ax,0
	 jne sub1
	 cmp dx,0
	 jne sub1
	 pop dx
	 pop ax
	 ret
code ends
end start