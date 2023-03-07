%define VIDEO_SEGMENT 0xa000
%define WIDTH 320
%define HEIGHT 200
%define COLOR 0x4

mov ah, 0x0  				; set video mode
mov al, 0x13				; VGA 256color mode 320x200
int 0x10  					; bios interrupt
mov ax, VIDEO_SEGMENT		; load VGA video memory segment
mov es, ax 					; mov VGA video memory segment into the extra segment register

mov cx, 0

mov ax, 5   				; setup: rect x
mov bx, 5   				; 		 rext y
mov cx, 10  				; 		 rect width
mov dx, 50  				; 		 rect height
mov si, 0x8a  				; 		 rect color
call draw_rect 				; call draw_rect procedure

ml:
	
	jmp ml

hlt


; ax for y
; bx for x
; cx for width
; dx for height
; si for color
draw_rect:
	pusha
	push bx					; save x
	mov bx, WIDTH			; move screen width into bx
	push dx					; save dx because mul
	mul bx					; calculate the beginning index of the y-th row
	pop dx					; load back height into dx 
	pop bx					; load back x into bx
	add ax, bx				; offset the y-th row to the x coordinate
	mov bx, WIDTH			; move back the screen width into bx
	mov di, ax				; move the beggining index of the rect into di,
							; which will be offset the es(VGA_GRAPHICAL_MEMORY)
	mov ax, si				; move the color into ax, because stosb
draw_rect_inner_loop:		; inner loop for iterate over the lines
	pusha 					; push all general register
	rep stosb				; write cx(rect_width) times al(ax-> color) into es:di(di->indexing from rect first index)
	popa 					; load back all general register
	add di, bx 				; increment di(indexer) by the screen width
	; decrement dx(height), and until larger than 0 jump back to the inner loop
	dec dx					
	cmp dx, 0
	jne draw_rect_inner_loop
	popa
	ret

times 510-($-$$) db 0 		; zero the remaring memory
dw 0xaa55  					; write the magic constant to the last 2 byte