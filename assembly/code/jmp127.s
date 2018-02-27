assume cs:code
code segment
start:
;jmp short s
jmp s
jmp near ptr s
jmp far ptr s
db 80h dup (0b8h,0,0)
s:mov ax,4c00h
int 21h

code ends
end start
