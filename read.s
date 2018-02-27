assume cs:code
stack segment
    db 80h dup (0)
stack ends
code segment
start:    mov ax,stack
            mov ss,ax
            mov sp,80h
            push cs
            pop ds
            mov si,offset int7ch
            mov ax,0000h
            mov es,ax
            mov ax,0200h
            mov di,ax
            mov cx,offset int7chend - offset int7ch
            cld
            rep movsb
            mov word ptr es:[1f0h],0200h
            mov es:[1f0h+02h],es
            mov ax,0b800h
            mov es,ax
            mov bx,00h
            mov ah,00h
            mov al,08h
            mov dx,0000h
            int 7ch
            mov ax,4c00h
            int 21h

org 0200h

int7ch: jmp short int7
            table dw read,write
int7:     push ax
            push dx
            push cx
            cmp ah,02h
            jnb int7end
            cmp dx,0e3fh
            ja int7end
            call ope 
	    push cx
            mov cl,ah
            mov ch,00h
            add cx,cx
            mov si,cx
	    pop cx
            call word ptr table[si]
int7end:    pop cx
            pop dx
            pop ax
            iret
ope:        push ax
            mov ax,dx
            mov dx,00h
            mov cx,5a0h
            div cx
            mov dh,dl
            mov dl,00h
            mov cl,12h
            div cl
            mov ch,al
            mov cl,ah
            inc cl
            pop ax
            ret
read: 	    mov ah,02h
            int 13h
            ret
write:      mov ah,03h
            int 13h
            ret
int7chend:nop

code ends
end start

