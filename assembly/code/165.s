assume cs:code
code segment
start:	mov ax,78h
	call showbyte
	mov ax,4c00h
	int 21h

showbyte:jmp short show
	 table dw ag0,ag1,ag2,ag3,ag4,ag5,ag6
	 ag0 db "0",0
	 ag1 db "0.5",0
	 ag2 db "0.866",0
	 ag3 db "1",0
	 ag4 db "0.866",0
	 ag5 db "0.5",0
	 ag6 db "0",0
show:	 push es
	 push di
	 push bx
     push ax
     mov ax,0b800h
     mov es,ax
     mov di,0a0h*0ch+40h-02h
     pop ax
	 mov ah,00h
	 mov bl,1eh
	 div bl
	 mov bl,al
	 add bl,bl
     cmp bl,10
     ja showerr
     cmp bl,0
     jb showerr
     mov bx,table[bx]
shows:	 mov ah,cs:[bx]
	 cmp ah,0
	 je showret
  	 mov es:[di],ah
	 mov byte ptr es:[di+1],7ch
	 add di,02h
     	 inc bx
     	 jmp shows
showerr: jmp showerror
	 message db "input error!!!",0
         mov si,00h
showerror:mov ah,message[si]
	  cmp ah,00h
	  je showret
	  mov es:[di],ah
	  mov byte ptr es:[di+1],7ch
	  inc si
	  add di,02h
	  jmp showerror
showret: pop bx
	 pop di
	 pop es
 	 ret


code ends
end start
