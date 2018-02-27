assume cs:code
code segment
start:		push cs
		pop ds
		mov ax,0000h
		mov es,ax
		mov si,offset setscreen
		mov ax,0200h
		mov di,ax
		mov cx,offset setscreenend - offset setscreen
		cld
		rep movsb
		
		mov word ptr es:[7ch * 04h],0200h
		mov es:[7ch * 04h + 02h],es
		
		mov ah,02h
		mov al,06h
		int 7ch
		mov ax,4c00h
		int 21h

org 0200h

setscreen:	jmp short set1

		table dw sub1,sub2,sub3,sub4


set1:		push bx


		cmp ah,03h

		ja sret
		mov bl,ah
		mov bh,00h
		add bx,bx
		call word ptr table[bx]
sret:		pop bx
		iret

sub1:		push es
		push bx
		push cx
		mov bx,0b800h
		mov es,bx
		mov bx,00h
		mov cx,7d0h
sub1s:		mov byte ptr es:[bx],' '
		add bx,02h
		loop sub1s
		pop cx
		pop bx
		pop es
		ret

sub2:		push es
		push bx
		push cx
		mov bx,0b800h
		mov es,bx
		mov bx,01h
		mov cx,7d0h
sub2s:		and byte ptr es:[bx],0f8h
		or es:[bx],al
		add bx,02h
		loop sub2s
		pop cx
		pop bx
		pop es
		ret

sub3:		push es
		push bx
		push cx
		mov bx,0b800h
		mov es,bx
		mov bx,0001h
		mov cl,04h
		shl al,cl
		mov cx,7d0h
sub3s:		and byte ptr es:[bx],8fh
		or es:[bx],al
		add bx,02h
		loop sub3s
		pop cx
		pop bx
		pop es
		ret

sub4:		push es
		push di
		push ds
		push si
		mov si,0b800h
		mov es,si
		mov ds,si
		mov si,0a0h
		mov di,00h
		mov cx,18h
		cld
sub4s:		push cx
		mov cx,0a0h
		rep movsb
		pop cx
		loop sub4s
		mov si,0a0h * 18h
		mov cx,0a0h
sub4ss:		mov byte ptr ds:[si],' '
		add si,02h
		loop sub4ss
		pop si
		pop ds
		pop di
		pop es
		ret
setscreenend: 	nop
code ends
end start
