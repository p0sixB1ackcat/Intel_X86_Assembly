assume cs:code
stack segment
    db 80h dup (0)
stack ends
data segment
    db 10h dup (0)
data ends
code segment
start:      mov ax,stack
            mov ss,ax
            mov sp,80h
            mov ax,data
            mov ds,ax
            mov ax,0000h
            mov es,ax
            mov ax,0009h
            mov bl,0004h
            mul bl
            mov di,ax

            push es:[di]
            pop ds:[0]
            push es:[di+2]
            pop ds:[2]


            cli
            mov word ptr es:[di],offset int9
            mov es:[di+2],cs
            sti

	        mov ax,0b800h
            mov es,ax
            mov ax,0a0h
            mov bl,0ch
            mul bl
            add ax,40h
            mov di,ax
            mov al,'a'
s:          mov es:[di],al
            call sleep
            inc al
            cmp al,'z'
            jna s

            mov ax,0000h
            mov es,ax
            cli
            push ds:[0]
            pop es:[0024h]
            push ds:[2]
            pop es:[0026h]
            sti

            mov ax,4c00h
            int 21h
sleep:	    push ax
            push dx
            mov ax,0000h
            mov dx,0001h
sub1:       sub ax,0001
            sbb dx,0000
            cmp ax,0
            jne sub1
            cmp dx,0
            jne sub1
            pop dx
            pop ax
            ret

int9:      push es
           push ax
           push bx
           push di
           in al,60h
           pushf

           call dword ptr ds:[0]
           cmp al,01
           jne int9ret
           mov ax,0b800h
           mov es,ax
           mov ax,0a0h
           mov bl,0ch
           mul bl
	       add ax,40h
           inc ax
           mov di,ax
           inc byte ptr es:[di]
int9ret:
           pop di
           pop bx
           pop ax
           pop es
           iret

code ends
end start
