assume cs:code
code segment
start:  ;call sub1 0号子程序调用
	
	;mov al,06h
	;call sub2 1号子程序调用
	
	;mov al,06h
	;call sub3 2号子程序调用
	
	;call sub4 3号子程序调用

	mov ah,02h
    mov al,06h
	call setscreen
	
	mov ax,4c00h
	int 21h
setscreen:jmp short set1
          table dw sub1,sub2,sub3,sub4
set1:	  push bx
          cmp ah,03h
          ja sret
          mov bl,ah
          mov bh,00h
          add bx,bx
          call word ptr table[bx]
sret:	  pop bx
          ret

sub1:	push es
	push bx
	push cx
	mov bx,0b800h
	mov es,bx
	mov bx,00h
	mov cx,7d0h
sub1s:  mov byte ptr es:[bx],' '
	add bx,02h
	loop sub1s
	pop cx
	pop bx
	pop es
	ret

sub2:	push es
	push bx
	push cx
	mov bx,0b800h
	mov es,bx
	mov bx,01h
	mov cx,7d0h
sub2s:	and byte ptr es:[bx],0f8h
	or es:[bx],al
	add bx,02h
	loop sub2s
	pop cx
	pop bx
	pop es
	ret

sub3:	push es
	push bx
	push cx
	mov bx,0b800h
	mov es,bx
	mov cl,04h
	shl al,cl
	mov bx,01h
	mov cx,7d0h
sub3s:	and byte ptr es:[bx],8fh
	or es:[bx],al
	add bx,02h
	loop sub3s
	pop cx
	pop bx
	pop es
	ret

sub4:	push es
	push di
	push ds
	push si
	push cx
	mov si,0b800h
	mov es,si
	mov ds,si
	mov si,0a0h
	mov di,00h
	mov cx,18h
	cld
sub4s0:	push cx
	mov cx,0a0h
	rep movsb
	pop cx
	loop sub4s0
	mov cx,0a0h
	mov si,0a0h*18h
subs41:	mov byte ptr es:[si],' '
	add si,02h
	loop subs41
	pop cx
	pop si
	pop ds
	pop di
	pop es
	ret

code ends
end start
