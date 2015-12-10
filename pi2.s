# pi.s
# モンテカルロ法で円周率を求めて10進数表示する
#	性能に自信があるならプロット回数 4 * 10^n (n<=7)を増やす
# 変数(esp)
#	8	i
#	12	hit
# espの相対ロード・ストアを排除するためにすべてebpで行っている
# 必須命令
#	zJALR
#	push
#	ret

_main:
	zXOR	eax, eax
	zLIL	0x7FC, eax		# 512wordの最後のword
	zMOV	eax, esp		# 形のうえだけのesp
	zANDI	-16, esp
	zSUBI	16, esp
	zMOV	esp, ebp		# 以後、ebpで代替する

        zXOR    edx, edx
        zLIL    0x80, edx
        zXOR    eax, eax
        zXOR    ecx, ecx
        zLIL    _display_7seg, ecx
        zJALR   ecx
        zXOR    edx, edx
        zLIL    0x40, edx
        zXOR    eax, eax
        zXOR    ecx, ecx
        zLIL    _display_7seg, ecx
        zJALR   ecx

        zXOR    eax, eax
        zLIL    0x04, eax
        zXOR    esi, esi
        zLIL    0x2000, esi
        zST     eax, 44, esi

	zXOR	eax, eax
	zST	eax, 12, ebp		# ヒット数
	zLIL	0x3D, eax		# im16のヒット数
        zSLA    16, eax
        zLIL    0x0900, eax
        #zLIL    40, eax
	zST	eax, 8, ebp		# プロット回数
L16:
	zXOR	edx, edx		# この3命令で call _xor128
	zLIL	_xor128, edx
	zJALR	edx
	zMOV	eax, esi
	zXOR	ebx, ebx
	zLIL	16, ebx
	zXOR	eax, eax
	zLIL	0xffff, eax
	zAND	esi, eax		# 乱数a
	zSRL	16, esi			# 乱数b
	zXOR	ecx, ecx		# ここから a * a
	zLIL	0x8000, ecx
	zXOR	edx, edx		# sum = 0
L12:
	zADD	edx, edx
	zMOV	eax, edi
	zAND	ecx, edi
	zBcc	E, B40			# leal (edx,eax), edi; cmovne edi, edx
	zADD	eax, edx
	zB	B40
L16step1:				# L16が遠すぎて相対ジャンプできない命令があるので中継
	zB	L16
B40:
	zSRA	1, ecx
	zSUBI	1, ebx
	zBcc	NE, L12			# ここまでで edx = a * a
	zXOR	ebx, ebx
	zLIL	16, ebx
	zXOR	ecx, ecx		# ここから b * b
	zLIL	0x8000, ecx
	zXOR	eax, eax		# sum = 0
L14:
	zADD	eax, eax
	zMOV	esi, edi		# testl	esi, ecx
	zAND	ecx, edi
	zBcc	E, B55			# leal (eax,esi), edi; cmovne edi, eax
	zADD	esi, eax
B55:
	zSRA	1, ecx
	zSUBI	1, ebx
	zBcc	NE, L14
	zADD	eax, edx		# キャリーが発生するか？
	zBcc	B, B62			# if (a * a + b * b < 0x10000 * 0x1000) hit++;
	zLD	12, ebp, eax
	zADDI	1, eax
	zST	eax, 12, ebp
B62:
	zLD	8, ebp, eax
	zSUBI	1, eax
	zST	eax, 8, ebp
	zBcc	NE, L16step1		# L16が遠すぎるので中継地点へ

        zXOR    eax, eax
        zLIL    0x10, eax
        zXOR    esi, esi
        zLIL    0x2000, esi
        zST     eax, 44, esi

	zLD	12, ebp, eax
        zXOR    ecx, ecx
        zLIL    _decimal_format, ecx
        zJALR   ecx
        zXOR    edx, edx
        zLIL    0x80, edx
        zXOR    ecx, ecx
        zLIL    _display_7seg, ecx
        zJALR   ecx
        zXOR    esi, esi
        zLIL    0x2000, esi
        zLD     56, esi, eax
        zLD     60, esi, ebx
        zSLL    16, ebx
        zOR     ebx, eax
        zXOR    edx, edx
        zLIL    0x40, edx
        zXOR    ecx, ecx
        zLIL    _display_7seg, ecx
        zJALR   ecx

_buzzer_loop:
        zXOR    esi, esi
        zLIL    0x2000, esi
        zXOR    eax, eax
        zLIL    0x02, eax
        zST     eax, 44, esi
        zLIL    20000, eax
        zST     eax, 36, esi
        zLIL    10000, eax
        zST     eax, 40, esi
        zLIL    0x01, eax
        zST     eax, 44, esi
        zLIL    0x20, eax
        zSLL    16, eax
        zLIL    0x9680, eax
_buzzer_on_loop:
        zLD     16, esi, ebx
        zXORI   0x1F, ebx
        zBcc    NE, _program_end
        zSUBI   1, eax
        zBcc    NE, _buzzer_on_loop

        zXOR    eax, eax
        zLIL    0x02, eax
        zST     eax, 44, esi
        zLIL    0x20, eax
        zSLL    16, eax
        zLIL    0x9680, eax
_buzzer_off_loop:
        zLD     16, esi, ebx
        zXORI   0x1F, ebx
        zBcc    NE, _program_end
        zSUBI   1, eax
        zBcc    NE, _buzzer_off_loop
        zB      _buzzer_loop
_program_end:
        zXOR    eax, eax
        zLIL    0x02, eax
        zST     eax, 44, esi
        zHLT

_display_7seg:
        zXOR    ebx, ebx
        zLIL    8, ebx
        zXOR    esi, esi
        zLIL    0x2000, esi
        zST     edx, 0x20, esi
_display_7seg_skip:
        zLIL    0xF000, ecx
        zSLL    16, ecx
        zAND    eax, ecx
        zBcc    NE, _display_7seg_loop
        zST     ecx, 0, esi
        zSLL    4, eax
        zADDI   4, esi
        zSUBI   1, ebx
        zBcc    NE, _display_7seg_skip
        zRET
_display_7seg_loop:
        zLIL    0xF000, ecx
        zSLL    16, ecx
        zAND    eax, ecx
        zSRL    26, ecx
        zXOR    edi, edi
        zLIL    _7seg_table, edi
        zADD    ecx, edi
        zLD     0, edi, ecx
        zST     ecx, 0, esi
        zSLL    4, eax
        zADDI   4, esi
        zSUBI   1, ebx
        zBcc    NE, _display_7seg_loop
	zRET

_decimal_format:
        zMOV    eax, ecx
	zXOR	eax, eax
	zXOR	ebx, ebx
	zLIL	7, ebx
L21:
	zSLA	4, eax
	zXOR	edx, edx
	zLIL	1, edx
	zCMPI	0, ebx
	zBcc	E, L17
	zXOR	esi, esi
L18:
	zMOV	edx, edi
	zADD	edx, edi
	zADDI	1, esi
	zSLA	3, edx
	zADD	edi, edx
	zCMP	ebx, esi
	zBcc	NE, L18
L17:
	zCMP	ecx, edx
	zBcc	A, L19
	zSUB	edx, ecx
	zB	L20
L23:
	zMOV	esi, ecx
L20:
	zMOV	ecx, esi
	zADDI	1, eax
	zSUB	edx, esi
	zCMP	edx, ecx
	zBcc	NB, L23
L19:
	zSUBI	1, ebx
	zCMPI	-1, ebx
	zBcc	NE, L21
        zRET

_xor128:				# xorshift 128 bit
	zLIL	_x, ebx
	zLD	0, ebx, eax		# mov _x, eax
	zMOV	eax, edx
	zSLA	11, edx
	zXOR	eax, edx
	zLD	4, ebx, eax		# mov _y, eax
	zST	eax, 0, ebx		# mov eax, _x
	zLD	8, ebx, eax		# mov _z, eax
	zST	eax, 4, ebx
	zLD	12, ebx, eax
	zMOV	eax, ecx
	zST	eax, 8, ebx
	zSRL	19, ecx
	zXOR	ecx, eax
	zXOR	edx, eax
	zSRL	8, edx
	zXOR	edx, eax
	zST	eax, 12, ebx
	zRET

_x:
	.long	123456789
_y:
	.long	362436069
_z:
	.long	521288629
_w:
	.long	88675123

_7seg_table:
        .long   0xFC
        .long   0x60
        .long   0xDA
        .long   0xF2
        .long   0x66
        .long   0xB6
        .long   0xBE
        .long   0xE0
        .long   0xFE
        .long   0xF6
        .long   0xEE
        .long   0x3E
        .long   0x1A
        .long   0x7A
        .long   0x9E
        .long   0x8E
END:
