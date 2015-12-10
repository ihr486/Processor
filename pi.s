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
	zXOR	eax, eax
	zST	eax, 12, ebp		# ヒット数
	zLIL	400, eax		# im16のヒット数
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
	zLD	12, ebp, ecx
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
	zHLT				# この時点で eax に10進化円周率が入っている
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
#_mul16:
#	pushl	esi
#	pushl	ebx
#	movl	16, ecx
#	movzwl	12, ebp, ebx
#	movl	32768, edx
#	xorl	eax, eax
#L4:
#	addl	eax, eax
#	testl	ebx, edx
#	leal	(eax,ebx), esi
#	cmovne	esi, eax
#	sarl	edx
#	subl	1, ecx
#	jne	L4
#	popl	ebx
#	popl	esi
#	ret
_x:
	.long	123456789
_y:
	.long	362436069
_z:
	.long	521288629
_w:
	.long	88675123
END:
