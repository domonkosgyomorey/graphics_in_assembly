%define VIDEO_SEGMENT 0xa000
%define WIDTH 320
%define HEIGHT 200
%define COLOR 0x4
%define KEYBOARD_INT 9
%define BALL_COLOR 0x8a
%define BALL_WIDTH 10
%define BALL_HEIGHT 10

mov ah, 0x0  				; set video mode
mov al, 0x13				; VGA 256color mode 320x200
int 0x10  					; bios interrupt
mov ax, VIDEO_SEGMENT		; load VGA video memory segment
mov es, ax 					; mov VGA video memory segment into the extra segment register

ml:
	mov ah, 0x1
	int 0x16
	jz ml

	xor ah, ah
	int 0x16

	cmp al, 'w'
	je up_f
	cmp al, 'a'
	je left_f
	cmp al, 's'
	je down_f
	cmp al, 'd'
	je right_f
	
up_f:
	call up
	jmp end_ml
left_f:
	call left
	jmp end_ml
down_f:
	call down
	jmp end_ml
right_f:
	call right
	jmp end_ml

end_ml:
	mov ax, [ball_idx]
	mov cx, BALL_WIDTH
	mov dx, BALL_HEIGHT
	mov si, BALL_COLOR
	call draw_rect 
	jmp ml

hlt


; ax for first index of the rect
; cx for width
; dx for height
; si for color
draw_rect:
	pusha
	mov bx, WIDTH			; move the screen width into bx
	mov di, ax				; move the beggining index of the rect into di,
							; which will be offset the es(VGA_GRAPHICAL_MEMORY)
	mov ax, si				; move the color into ax, because stosb
draw_rect_inner_loop:		; inner loop for iterate over the lines
	pusha 					; save di and cx, because rep, and stosb
	rep stosb				; write cx(rect_width) times al(ax-> color) into es:di(di->indexing from rect first index)
	popa 					; load back di, and cx
	add di, bx 				; increment di(indexer) by the screen width
	; decrement dx(height), and until larger than 0 jump back to the inner loop
	dec dx					
	cmp dx, 0
	jne draw_rect_inner_loop
	popa
	ret
up:
	pusha
	mov ax, [ball_idx]
	mov bx, WIDTH
	sub ax, bx
	mov [ball_idx], ax
	popa
	ret

left:
	pusha
	mov ax, [ball_idx]
	mov bx, WIDTH
	dec ax
	mov [ball_idx], ax
	popa
	ret

down:
	pusha
	mov ax, [ball_idx]
	mov bx, WIDTH
	add ax, bx
	mov [ball_idx], ax
	popa
	ret

right:
	pusha
	mov ax, [ball_idx]
	inc ax
	mov [ball_idx], ax
	popa
	ret
times 509-($-$$) db 0 		; zero the remaring memory
ball_idx db 0
dw 0xaa55  					; write the magic constant to the last 2 byte