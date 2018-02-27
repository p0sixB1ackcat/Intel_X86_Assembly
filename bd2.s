assume cs:setupsg
;安装程序
;将引导所需的程序写入到软盘
setupsg segment
assume cs:setupsg
setup:
 ;主引导程序安装到第一扇区
 mov ax,initsg
 mov es,ax
 mov bx,0
 
 mov al,1
 mov ch,0
 mov cl,1
 mov dl,0
 mov dh,0
 
 mov ah,3
 int 13h
 
 ;子程序安装到从第2扇区开始的扇区
 mov ax,syssg
 mov es,ax
 mov al,15
 mov cl,2
 
 mov ah,3
 int 13h
 
 ;安装结束，返回
 mov ax,4c00h
 int 21h
 
setupsg ends


;主引导程序
;包含所有子程序的直接定址表，扇区加载程序，菜单
initsg segment
assume cs:initsg
init:
 call loadsys
 
 mov ax,2000h
 push ax
 mov ax,0
 push ax
 retf
 

loadsys:
 mov ax,2000h  ;软盘数据读取到2000:0
 mov es,ax
 mov bx,0
 
 mov al,15  ;读取的扇区数
 mov ch,0  ;0磁道
 mov cl,2  ;2扇区
 mov dl,0  ;0号驱动器
 mov dh,0  ;0面
 
 mov ah,2
 int 13h
 
 ret


initsg ends

 

;子程序
;包含所有菜单需要调用的子过程
syssg segment
assume cs:syssg

;菜单显示功能
menu:
 jmp near ptr menushow
 menudata dw offset md0,offset md1,offset md2,offset md3,offset md4,offset md5
 md0 db "------ welcome ------",0
 md1 db "1) reset pc",0
 md2 db "2) start system",0
 md3 db "3) clock",0
 md4 db "4) set clock",0
 md5 db "copyright @ 2010 Shiying,Inc.All rights reserved.",0
 systable dw sys_restart,sys_disksys,sys_showclock,sys_setclock
menushow:
 mov dh,5
 mov dl,30
 mov bp,0
 mov ax,cs
 mov ds,ax
 mov cx,5
menushow_s:
 push cx
 mov si,menudata[bp]
 mov cl,02h
 call sys_showstr
 add bp,2
 add dh,2
 pop cx
 loop menushow_s
 mov si,offset md5
 mov dh,23
 mov dl,28
 mov cl,02h
 call sys_showstr
 
 
;处理用户输入
sys_input:
 mov ah,0
 int 16h
 mov bx,0
 mov bl,al
 mov al,30h
 sub bl,al ;ascii转换为序列号
 sub bl,1 ;1-4转换为0-3
 
 cmp bx,0
 jb cycle
 cmp bx,3
 ja cycle
 add bx,bx
 call word ptr systable[bx]  ;调用菜单功能
 
cycle:
 jmp short sys_input
 
 
;重启计算机
sys_restart:
 mov ax,0ffffh
 push ax
 mov ax,0h
 push ax
 retf
 

;从硬盘引导
sys_disksys:
 call cls
 
 mov ax,0h  ;硬盘数据读取到0:7c00
 mov es,ax
 mov bx,7c00h
 
 mov al,1  ;读取的扇区数
 mov ch,0  ;0磁道
 mov cl,1  ;1扇区
 mov dl,80h  ;c盘
 mov dh,0  ;0面
 
 mov ah,2
 int 13h
 
 mov ax,0h
 push ax
 mov ax,7c00h
 push ax
 retf


;显示时钟
sys_showclock:
 call cls
 jmp short clockread
clockdata:
 clockstr dw offset cl1,offset cl2,offset cl3
 clockcolor db 02h
 cl1 db '00/00/00 00:00:00',0
 cl2 db 'press ESC return menu!',0
 cl3 db 'press F1 change color!',0
 cltable db 9,8,7,4,2,0
clockread:
 mov si,0        ;si指向'yy/mm/dd hh:mm:ss'的首地址
 mov di,0        ;di指向9,8,7,4,2,0的首地址
 mov cx,6        ;循环次数
clockread_s:
 push cx
 mov al,cltable[di]    ;从CMOS中读出年份的BCD码
 out 70h,al        
 in al,71h
 mov ah,al        ;al中位读出的数据
 mov cl,4        
 shr ah,cl        ;ah中为年份的十位数
 and al,00001111b    ;al中为年份的个位数
 add ah,30h        ;把数值转换为对应的ASCII码
 add al,30h        ;同上
 mov byte ptr cl1[si],ah    ;把读出的时间写入
 mov byte ptr cl1[si+1],al
 add si,3
 inc di
 pop cx
 loop clockread_s
clockprint:
 mov dh,6
 mov dl,30
 mov bp,0
 mov ax,cs
 mov ds,ax
 mov cx,3
clockprint_s:
 push cx
 mov si,clockstr[bp]
 mov cl,clockcolor[0]  ;将颜色值赋值给cl
 call sys_showstr
 add bp,2
 add dh,2
 pop cx
 loop clockprint_s
 mov ah,1 ;调用16h中断的1号功能（非阻塞）
 int 16h
 cmp al,1bh ;判断是否为ESC
 je clockreturn ;若是ESC，回到菜单
 cmp ah,3bh ;判断是否为F1
 je changecolor
 jmp short clockread
clockreturn:
 call cls
 mov ah,0    ;16h中断的1号功能不会清除键盘缓冲区，下次读取还会读出
 int 16h     ;调用0号功能清除一次
 jmp near ptr menu
changecolor:
 inc clockcolor
 mov ah,0    ;16h中断的1号功能不会清除键盘缓冲区，下次读取还会读出
 int 16h     ;调用0号功能清除一次
 jmp near ptr clockread
 

;设置时钟
sys_setclock:
 jmp short setclock
 setclockdata db 'Please input time like "yy/mm/dd hh:mm:ss"',0
 setsuccess   db  'Set clock successful! Press any key return...',0
setclock:
 call cls
 mov dh,6
 mov dl,20
 mov cl,02h
 mov ax,cs
 mov ds,ax
 mov si,offset setclockdata
 call sys_showstr
 call getstr 
 call settime
 mov dh,10
 mov dl,20
 mov cl,02h
 mov ax,cs
 mov ds,ax
 mov si,offset setsuccess
 call sys_showstr
 mov ah,0
 int 16h
 call cls
 jmp near ptr menu


;ds:si指向时间字符串
settime:
 jmp short seting
 settable db 9,8,7,4,2,0
seting:
 mov bx,0
 mov cx,6
settime_s:
 mov dh,ds:[si]
 inc si
 mov dl,ds:[si]
 add si,2
 mov al,30h
 sub dl,al
 sub dh,al
 shl dh,1
 shl dh,1
 shl dh,1
 shl dh,1
 or dl,dh
 mov al,settable[bx]
 out 70h,al
 mov al,dl
 out 71h,al
 inc bx
 loop settime_s
 ret
 
;子程序：接收字符串
getstr:
 push ax
getstrs:
 mov ah,0
 int 16h
 cmp al,20h
 jb nochar
 mov ah,0
 call charstack
 mov ah,2
 mov dh,8
 mov dl,25
 call charstack
 jmp getstrs
nochar:
 cmp ah,0eh
 je backspace
 cmp ah,1ch
 je enter
 jmp getstrs
backspace:
 mov ah,1
 call charstack
 mov ah,2
 call charstack
 jmp getstrs
enter:
 mov al,0
 mov ah,0
 call charstack
 mov ah,2
 call charstack
 pop ax
 ret
 
 
;子程序：字符串入栈，出栈和显示
;参数：(ah)=功能号，0入栈，1出栈，2显示
;  ds:si指向字符栈空间，对于0号功能，(al)表示入栈字符
;  1号功能，(al)返回的字符，对于2号功能，(dh)(dl)字符串在屏幕显示的行列位置
charstack:
 jmp short charstart
 table dw charpush,charpop,charshow
 top  dw 0
charstart:
 push bx
 push dx
 push di
 push es
 cmp ah,2
 ja sret
 mov bl,ah
 mov bh,0
 add bx,bx
 jmp word ptr table[bx]
charpush:
 mov bx,top
 mov [si][bx],al
 inc top
 jmp sret
charpop:
 cmp top,0
 je sret
 dec top
 mov bx,top
 mov al,[si][bx]
 jmp sret
charshow:
 mov bx,0b800h
 mov es,bx
 mov al,160
 mov ah,0
 mul dh
 mov di,ax
 add dl,dl
 mov dh,0
 add di,dx
 mov bx,0
charshows:
 cmp bx,top
 jne noempty
 mov byte ptr es:[di],' '
 mov byte ptr es:[di+1],02h
 jmp sret
noempty:
 mov al,[si][bx]
 mov es:[di],al
 mov byte ptr es:[di+2],' '
 mov byte ptr es:[di+1],02h
 inc bx
 add di,2
 jmp charshows
sret:
 pop es
 pop di
 pop dx
 pop bx
 ret
 

;显示0结尾的字符串
;参数：dh=行号，dl=列号，cl=颜色，ds:si指向字符串首地址
sys_showstr:
 push ax
 push cx
 push dx
 push si
 push bp
 push es
 mov ax,0b800h
 mov es,ax
 mov al,80*2 ;80*2*行号
 mul dh
 mov dh,0
 add dx,dx ;列号*2
 add ax,dx
 mov bp,ax
showstr_s:
 mov ch,ds:[si]
 cmp ch,0
 je showstr_return
 mov es:[bp],ch
 inc bp
 mov es:[bp],cl
 inc bp
 inc si
 jmp short showstr_s
showstr_return:
 pop es
 pop bp
 pop si
 pop dx
 pop cx
 pop ax
 ret
 

;清屏
cls:
 mov ax,0b800h
 mov ds,ax
 mov bx,0
 mov cx,24*80*2
cls_s:
 mov byte ptr ds:[bx],0
 add bx,2
 loop cls_s
 mov bx,1
resetcol:
 mov byte ptr ds:[bx],07h
 add bx,2
 loop resetcol
 ret
 
 
syssg ends


;安装过程的第一行指令
end setup
