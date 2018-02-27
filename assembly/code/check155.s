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
	push es:[0024h]
	pop es:[di]
	push es:[0026h]
	pop es:[di+2]
	
	add di,0004h
	cli
	mov es:[0024h],di
	mov es:[0026h],es
	sti
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
    mov es,ax;这里不能直接使用es，要将es重新置为0000h，因为触发中断时es是无法确定其值的
	call dword ptr es:[200h]
	in al,60h
	cmp al,3bh
	jne int9ret
	mov ax,0b800h
	mov es,ax
	mov bx,1
	mov cx,7d0h
s:	inc byte ptr es:[bx]
	add bx,02h
	loop s
int9ret:pop bx
    pop cx
	pop ax
	pop es
	iret
int9end:nop
code ends
end start
		
