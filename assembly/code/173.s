assume cs:code
data segment
  db 80h dup (0)
data ends
code segment
start:		mov ax,data
		mov ds,ax
		mov si,00h
		mov dx,0100h
		call getstr
		mov ax,4c00h
		int 21h

getstr:		push ax
getstrs:	mov ah,00h
		int 16h
		cmp al,20h
		jb nochar
		mov ah,00h
		call charstack
		mov ah,02h
		call charstack
		jmp getstrs
nochar:		cmp ah,0eh	;比较是否是delete键
		je backspace
		cmp ah,1ch	;比较是否是enter键
		je enter
		jmp getstrs

backspace:	mov ah,01h
		call charstack
		mov ah,02h
		call charstack
		jmp getstrs

enter:		mov al,00h
		mov ah,00h
		call charstack
		mov ah,02h
		call charstack
		pop ax
		ret

charstack:	jmp charstart
		table dw charpush,charpop,charshow
		top   dw 0	;用来标记字符栈后面的地址
charstart:	push bx
		push es
		push di
		push dx
		cmp ah,02h
		ja charret
		mov bl,ah
		mov bh,00h
		add bx,bx
		jmp word ptr table[bx]

charpush:	mov bx,top
        	mov ds:[si+bx],al	;这里要严格注意，如果直接使用ds:[si+top]，那相当于使用了ds:[si+(top的偏移地址0057，并不是cs:[0057])]，这里要的就是cs:[0057],也就是top数据标号的第一个内容0] 
		;mov ds:[si+top],al
		inc top
		jmp charret

charpop:	cmp top,0
		je charret
		dec top
		;mov byte ptr ds:[si+top],' '	;这里的目的，是想将新的字符栈结尾的后一个字节写入' '
						;但是，这么做仅仅是对固定地址ds:[si+0057]的写入
						;并且，即使使用的是cs:[0057]，那么也是将新的字符栈中的最后一个字符写入' '					
						;现在，不对新字符栈结尾的后一个字节写入' '
						;将字符栈结尾的后一个字节（字符栈在改变之前的最后一个字节）写入al
		mov bx,top
		mov al,ds:[si+bx]
		jmp charret

charshow:	mov bx,0b800h
		mov es,bx
		mov ax,0a0h
		mul dh
		add dl,dl
		adc al,dl
		adc ah,00h
		mov bx,00h

charshows:	cmp bx,top
		mov byte ptr es:[di],' '	
		jnb charret
		mov al,ds:[si+bx]
		mov es:[di],al
		mov byte ptr es:[di+02h],' '
		inc bx
		add di,02h
		jmp charshows
charret:	pop dx
		pop di
		pop es
		pop bx
		ret
code ends
end start
