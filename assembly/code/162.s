assume cs:code,ds:data
data segment
  a db 1,2,3,4,5,6,7,8
  b dw 0
data ends
code segment
start:	mov ax,data
	mov ds,ax
	mov si,00h
	mov cx,08h
s:	mov al,a[si]
	mov ah,00h
	add b[0],ax
	inc si
	loop s
	mov ax,4c00h
	int 21h
code ends
end start
