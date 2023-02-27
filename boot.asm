%define VIDEO_SEGMENT 0xa000
%define WIDTH 320
%define HEIGHT 200
%define COLOR 0x4

BITS 16

mov ah, 0x0
mov al, 0x13
int 0x10
mov ax, VIDEO_SEGMENT
mov es, ax

mov ax, 0
mov bx, 0
mov cx, 10
mov dx, 150
mov si, 0x8
call draw_rect

jmp $

; ax for y
; bx for x
; cx for width
; dx for height
; si for color
draw_rect:
	push ax		; save y for later
	; calculate index after final line  (y+height+1)*scr_Width
	add ax, dx
	mov dx, WIDTH
	mul dx
	add ax, bx
	add ax, cx

	mov di, ax	; mov last pixel index into di, because mul -> dx:ax
	pop ax		; load y
	push cx		; save rect with for later

	; calculate first pixel of the rect (y*scr_width)+x
	mov cx, WIDTH
	mul cx
	add ax, bx

	mov cx, ax	; mov first pixel index into cx
	pop bx		; save rect width into bx
	add bx, cx	; add first pixel index to the width fot calc end line index of the rect
	mov dx, di
	ol:		; outer loop
	il:		; inner loop	
	mov di, cx 	; store pixel index to di
	mov WORD [es:di], si 	; write pixel in video memory with color (si)
	inc cx		; increment the iterator
	cmp ecx, ebx	; compare current idx with (rect width + x) 
	jl il		; jump if iterator less than x+width on the current row
	add bx, WIDTH	; add the end line of rect index to scr_width (go next end line index) 	
	add ax, WIDTH	; skip the current row
	mov cx, ax	; store first index of rect into cx
	cmp ecx, edx	; compare current idx with index after final line
	jl ol		; jump if cx less than the index after final line of the rect
	ret

times 510-($-$$) db 0
dw 0xaa55