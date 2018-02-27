assume cs:code
code segment
  a dw 1,2,3,4,5,6,7,8
  b dd 0
start:	mov si,0000h
	mov cx,0008h
s:	mov ax,a[si]
	add a[10h],ax
	adc a[12h],0
	add si,02h
	loop s
	mov ax,4c00h
	int 21h
code ends
end start
