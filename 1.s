assume cs:code
code segment
assume cs:code
start:
    mov ax,initsg
	mov es,ax
	mov bx,00h
	mov dx,0000h
	mov ch,00h
	mov cl,01h
	mov al,10h
	mov ah,03h
	int 13h
			;以上是将初始化程序写入到0面0磁道1扇区
			;初始化程序的作用是：“将0面0磁道2扇区中的内容移动到地址2000:0000处，并设置CS:IP为2000:0000”
			
	mov ax,subsg
	mov es,ax
	mov bx,00h
	mov dx,00h
	mov ch,00h
	mov cl,02h
	mov al,10h
	mov ah,03h
	int 13h
			;将子程序写到0面0磁道2扇区中
			
	mov ax,4c00h
	int 21h
code ends

initsg segment
assume cs:initsg
init:
    mov ax,2000h
	mov es,ax
	mov bx,00h
	mov dx,00h
	mov ch,00h
	mov cl,02h
	mov al,10h
	mov ah,02h
	int 13h
	;向0面0磁道2扇区读取子程序到地址2000:0000处
	mov ax,2000h
	push ax		;push cs
	mov ax,0000h	
	push ax		;push ip
	
	retf		;设置CS:IP为2000:0000，也就是让cpu去2000:0000处取指执行

initsg ends

subsg segment
assume cs:subsg	
subsy:
    jmp short play
	table dw str0,str1,str2,str3
	str0 db '1) reset pc',0
	str1 db '2) start system',0
	str2 db '3) clock',0
	str3 db '4) set clock',0
	len dw 16h,1eh,10h,18h
play:
	mov ax,0b800h
	mov es,ax
	mov di,0a0h * 08h + 40h
	mov bx,00h
	mov dx,len[bx]
	sub di,dx
	mov cx,04h
s:
    mov si,table[bx]
	push cx
s0:
    mov cl,cs:[si]
	mov ch,00h
	jcxz next
	mov es:[di],cl
	mov byte ptr es:[di+1],1ch
	add di,02h
	inc si
	jmp s0
next:
    mov dx,len[bx]
	sub di,dx
	add bx,02h
	add di,0a0h
	pop cx
	loop s
	
	mov ah,00h
	int 16h

cmpasc:
    jmp cmpstart
	ctable dw resetpc,startsys,clock,setclock
cmpstart:
    push ax
    mov ax,0b800h
    mov es,ax
    mov di,0f0h
    pop ax

   	cmp al,31h
	jb cwait
	cmp al,34h
	ja cwait
    sub al,31h
	mov bx,ax
	mov bh,00h
	add bx,bx
	call word ptr ctable[bx]
	ret

resetpc:
    call cls
	mov ax,0ffffh
	push ax
	mov ax,0000h
	push ax
	retf


;从c盘的0面0磁道1扇区中读取引导程序，并加载执行这个引导程序
startsys:
    call cls
    mov ax,0000h
    mov es,ax
    mov bx,7c00h
    mov dh,00h
    mov dl,80h
    mov ch,00h
    mov cl,01h
    mov al,10h
    mov ah,02h
    int 13h
    mov ax,0000h
    push ax
    mov ax,7c00h
    push ax
    retf

cwait:
    mov ah,00h
    int 16h
    jmp cmpstart

clock:
    jmp cst
	clockstr db '// ::',0
	timepoint db 9,8,7,4,2,0
cst:
    call cls
	mov ax,0b800h
	mov es,ax
	mov di,0a0h * 08h + 40h
	mov bx,00h
read_t:
    mov al,timepoint[bx]
	out 70h,al
	in al,71h
	mov ah,al
	and al,0fh
	mov cl,04h
	shr ah,cl
    add al,30h
    add ah,30h
	mov es:[di],ah
	mov byte ptr es:[di+1],1ch
	mov es:[di+2],al
	mov byte ptr es:[di+3],1ch
	mov cl,clockstr[bx]

	add di,04h
	cmp cl,0
	je creload
	mov es:[di],cl
	add di,02h
    inc bx
	jmp read_t

creload:
    mov dx,bx
    mov bp,di

reload:
    mov bx,dx
    mov di,bp
    mov cx,06h
reloads:
    push cx
gettime:
    mov al,timepoint[bx]
	out 70h,al
	in al,71h
	mov ah,al
	mov cl,04h
	shr ah,cl
	and al,0fh
	add al,30h
	add ah,30h
;cmp ah,es:[di-4]
;jne repah
;cmp al,es:[di-2]
;jne repal
;jmp reload
    cmp bx,00h
    jb reload

    mov es:[di-4],ah
    mov es:[di-2],al
    sub di,06h
    dec bx
	pop cx
    loop reloads
    mov ah,01h      ;之前调用int 16h中断读取键盘缓冲区内容，使用的是该中断例
                    ;程的0号子程序，但是使用0号子程序当键盘缓冲区中没有内容
                    ;时，会一直等待，下面的指令不会被执行，阻塞当前的任务了；
                    ;使用该中断例程的1号子程序就不会产生这个问题了
    int 16h
    cmp al,1bh
    je clock_ret
    cmp ah,3bh
    je clock_color


	jmp reload
repah:
    mov es:[di-4],ah
repal:
    mov es:[di-2],al
	jmp gettime

clock_ret:
    call gohome


clock_color:
    push di
    add di,02h
    mov cx,06h
change:
    inc byte ptr es:[di+1]
    inc byte ptr es:[di+3]
    add di,06h
    loop change
    pop di
    mov ah,00h  ;上面使用了int 16h中断例程的1号子程序，该子程序调用，读取键盘
                ;缓冲区内容后，改内容不会从键盘缓冲去的环形队列中弹出，所以要
                ;调用int 16h中断例程的0号子程序，清除键盘缓冲区
    int 16h

    jmp reload

setclock:
    jmp setclock_start
    m0 db ' Please input year format must be YYYY:',0
    m1 db ' Please input month format must be MM:',0
    m2 db ' Please input day format must be DD:',0
    m3 db ' Please input hour format must be hh:',0
    m4 db ' Please input minutes format must be mm:',0
    m5 db ' Please input seconds format must be: ss',0
    message dw offset m0,offset m1,offset m2,offset m3,offset m4,offset m5
    dataAddress db 9,8,7,4,2,0
    input db 10h dup (0)
    inputlseek dw 0
setclock_start:
    push es
    push bx
    push di
    push si
    call cls
    mov ax,0b800h
    mov es,ax
    mov di,0a0h * 08h
    mov bx,00h
    mov dx,00h
readlinenum:
    mov si,message[bx]

readdate:
    mov cl,cs:[si]
    cmp cl,00h
    je waitinput

showstr:
    mov es:[di],cl
    mov byte ptr es:[di+1],0ch
    inc si
    add di,02h
    jmp readdate


waitinput:

    mov ah,00h
    int 16h
    cmp al,1bh
    je setclock_ret

    cmp ah,1ch              ;扫描回车
    je goreadnextline
    cmp ah,0eh              ;扫描码delete
    je delonebyte
    cmp al,30h              ;ASCII 0
    jb  waitinput
    cmp al,39h              ;ASCII 9
    ja waitinput

    mov es:[di],al
    mov byte ptr es:[di+1],0ch
    push si
    mov si,inputlseek
    sub al,30h
    mov input[si],al
    inc inputlseek

    add di,02h
    pop si
    jmp waitinput

delonebyte:
    cmp word ptr inputlseek,0
    je waitinput

    mov byte ptr es:[di],' '
    sub di,02h

    cmp inputlseek,00h
    je delgoback
    dec inputlseek
delgoback:
    jmp waitinput

goreadnextline:

    cmp message[bx],offset m5
    je changetime

    mov ax,bx
    mov ch,02h
    div ch          ;行号用bx控制，bx每次自增2，要在下‘1’行显示，那么就要除2
    mov ah,00h
    add ax,08h      ;08是显示行号的基地址
    add ax,01h      ;因为是要从下一行开始，所以要在基地址的行号的基础上+1
    add bx,02h
    push cx
    mov cl,0a0h
    mul cl
    mov di,ax
    pop cx
    jmp readlinenum

setclock_ret:
    pop si
    pop di
    pop bx
    pop es
    call gohome

changetime:
    push cx
    push bx
    push dx
    push si
    mov cx,06h
    mov bx,00h          ;这个bx和上面的bx无关
    mov si,00h
    mov bp,00h
    push ax
changetimes:
    mov al,dataAddress[bx]
add al,30h
mov es:[si+40h],al
sub al,30h
    out 70h,al
    mov ah,input[si]
add ah,30h
mov es:[si+40h+0a0h+bp],ah
sub ah,30h
mov al,input[si+1]
add al,30h
mov es:[si+40h+0a0h+bp+2],al
sub al,30h
    add bp,02h
    shl ah,01h
    shl ah,01h
    shl ah,01h
    shl ah,01h          ;这里最开始也是使用按位操作，不过昨天犯浑，认为计算的
                        ;公式是ah*0a0h+al就能将输入缓冲区input的当前位置
                        ;的数据写入71h端口了，其实你错了，要记住最本质的区
                        ;别，bcd码，他是用4个二进制位表示一个十进制位，
                        ;ah*0a0h+al这种计算方式是根据十进制的方式来进行计
                        ;算的，得到的最终结果也不是这里需要的，这里就是将高字
                        ;节左移4，然后or到低字节中
    or al,ah
add al,30h
mov es:[si+40h+140h],al
sub al,30h
    out 71h,al
    inc bx
    add si,02h
    loop changetimes

    pop si
    pop dx
    pop bx
    pop cx
;jmp waitinput
    jmp setclock_ret

gohome:

    call cls
    mov ah,02h
    mov bh,00h
    mov dx,00h
    int 10h
    mov ax,2000h
    push ax
    mov ax,0000h
    push ax
    retf

;清屏
cls:
    push es
    push di
    mov ax,0b800h
    mov es,ax
	mov di,00h
	mov cx,0fa0h
	mov ah,es:[di+1]
	mov al,' '
clss:
    mov byte ptr es:[di],al
	mov byte ptr es:[di+1],ah
	add di,02h
	loop clss
    pop di
    pop es
	ret

subsg ends

end start
	
