assume cs:code
stack segment
  db 80h dup (0)
stack ends
code segment
start:	mov ax,stack
	mov ss,ax
	mov sp,80h
	
	push cs
	pop ds
	mov si,offset int9
	
	mov ax,0000h
	mov es,ax
	mov ax,200h
	mov di,ax
	
	mov ax,0009h
	mov bl,04h
	mul bl
	push es:[0024h]
	pop es:[di]
	push es:[0026h]
	pop es:[di+2]
	cli
	mov word ptr es:[0024h],200h
	mov es:[0026h],es
	sti
	add di,04h
	mov cx,offset int9end - offset int9
	cld
	rep movsb
	
	mov ax,4c00h
	int 21h
int9:	push es
	push ax
	push cx
	push bx
	pushf
	mov ax,0000h
	mov es,ax
	call dword ptr es:[200h]
	in al,60h
	cmp al,9eh
	jne int9ret
	mov ax,0b800h
	mov es,ax
	mov cx,7d0h
	mov bx,0
s:	mov byte ptr es:[bx],'A'
	add bx,2
	loop s
int9ret:pop bx
	pop cx
	pop ax
	pop es
	iret
int9end:nop
code ends
end start
