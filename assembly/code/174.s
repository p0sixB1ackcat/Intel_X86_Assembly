assume cs:code
code segment
start:	mov ax,0b800h
	mov es,ax
	mov bx,00h
	mov dh,00h
	mov dl,00h
	mov ch,00h
	mov cl,01h
	mov al,08h
    ;mov ah,03h ;这里本来的目的是将屏幕的内容向0号磁头0号磁道的1扇区写入，但是写入之后的磁盘镜像就不能用了，这里为了更直观的了解，是否真正的读写了磁盘
		    ;这里，突然想到，可以先对软盘写入数据，然后在读取里面的数据，不就可以知道是否写入成功了嘛 

    mov ah,02h
	int 13h
	mov ax,4c00h
	int 21h
code ends
end start
