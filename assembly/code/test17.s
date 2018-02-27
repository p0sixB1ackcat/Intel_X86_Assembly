assume cs:code
data segment
  db 0400h dup (0)
data ends

stacksg segment
  db 80h dup (0)
stacksg ends

code segment
start:	mov ax,stacksg
	mov ss,ax
	mov sp,400h
	push cs
	pop ds
	mov si,offset int7ch
	mov ax,0000h
	mov es,ax
	mov ax,0200h
	mov di,ax
	mov cx,offset int7end - offset int7ch
	rep movsb
	mov word ptr es:[1f0h],0200h
	mov es:[1f0h+2],es
	mov ax,0b800h
	mov es,ax
	mov bx,00h
	mov dx,0000h
	mov ah,00h
	mov al,08h
	int 7ch
	
	mov ax,4c00h
 	int 21h

org 0200h

int7ch: jmp short i7s
	table dw read,write
	
i7s:push ax
	push dx
	cmp ah,02h
	jnb int7ret
	cmp dx,00h
	jb int7ret
	call ope
	push cx
	mov cl,ah
	mov ch,00h
	add cx,cx
        mov si,cx
	pop cx
	call word ptr table[si]
	
int7ret:pop dx
	pop ax
	iret

ope:	push ax
	mov ax,dx
        mov dx,00h
	mov cx,5a0h
	div cx
	push ax
    	mov ax,dx
    	pop dx
    	mov dh,dl   
    	mov dl,00h	;这里dh才是面号，dl是驱动器编号，所以，对逻辑扇区编号除5a0h之后，取整后低8位才是求得的面号，需要将dl传送到dh
    	mov ch,12h
	div ch
	mov cl,ah
	mov ch,al
	inc cl
	pop ax
	ret

read:	push ax
	mov ah,02h
	int 13h
	pop ax
	ret

write:	push ax
	mov ah,03h
	int 13h
	pop ax
	ret
int7end:nop

code ends
end start
