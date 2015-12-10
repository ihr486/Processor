# fibonacci.s
# 等差数列の和
# 必須命令：
#	zADD
#	zADDI
#	zSUB
#	zLD
#	zST
#	zLIL

# 初期化
        zSUB	edi,	edi
        zLIL	0x200,	edi

# 初項
        zSUB	eax,	eax
        zADDI	0x1,	eax
# n1 = 1
        zST	eax,	0x0,	edi
# n2 = 1
        zST	eax,	0x4,	edi

# 計算
# n3 = n2 + n1 = 2
        zLD	0x0,	edi,	eax
        zLD	0x4,	edi,	edx
        zADD	edx,	eax
        zST	eax,	0x8,	edi
# n4 = n3 + n2 = 3
        zLD	0x4,	edi,	eax
        zLD	0x8,	edi,	edx
        zADD	edx,	eax
        zST	eax,	0xC,	edi
# n5 = n4 + n3 = 5
        zLD	0x8,	edi,	eax
        zLD	0xC,	edi,	edx
        zADD	edx,	eax
        zST	eax,	0x10,	edi
# n6 = n5 + n4 = 8
        zLD	0xC,	edi,	eax
        zLD	0x10,	edi,	edx
        zADD	edx,	eax
        zST	eax,	0x14,	edi
# n7 = n6 + n5 = 13
        zLD	0x10,	edi,	eax
        zLD	0x14,	edi,	edx
        zADD	edx,	eax
        zST	eax,	0x18,	edi
# n8 = n7 + n6 = 21
        zLD	0x14,	edi,	eax
        zLD	0x18,	edi,	edx
        zADD	edx,	eax
        zST	eax,	0x1C,	edi
# n9 = n8 + n7 = 34
        zLD	0x18,	edi,	eax
        zLD	0x1C,	edi,	edx
        zADD	edx,	eax
        zST	eax,	0x20,	edi
# n10 = n9 + n8 = 55
        zLD	0x1C,	edi,	eax
        zLD	0x20,	edi,	edx
        zADD	edx,	eax
        zST	eax,	0x24,	edi
# n11 = n10 + n9 = 89
        zLD	0x20,	edi,	eax
        zLD	0x24,	edi,	edx
        zADD	edx,	eax
        zST	eax,	0x28,	edi
# n12 = n11 + n10 = 144
        zLD	0x24,	edi,	eax
        zLD	0x28,	edi,	edx
        zADD	edx,	eax
        zST	eax,	0x2C,	edi
# n13 = n12 + n11 = 233
        zLD	0x28,	edi,	eax
        zLD	0x2C,	edi,	edx
        zADD	edx,	eax
        zST	eax,	0x30,	edi
# n14 = n13 + n12 = 377
        zLD	0x2C,	edi,	eax
        zLD	0x30,	edi,	edx
        zADD	edx,	eax
        zST	eax,	0x34,	edi
# n15 = n14 + n13 = 610
        zLD	0x30,	edi,	eax
        zLD	0x34,	edi,	edx
        zADD	edx,	eax
        zST	eax,	0x38,	edi
# n16 = n15 + n14 = 987
        zLD	0x34,	edi,	eax
        zLD	0x38,	edi,	edx
        zADD	edx,	eax
        zST	eax,	0x3C,	edi

# 出力
        zLD	0x20,	edi,	eax	# r[0] = n9 = 34 = 0x22
        zLD	0x24,	edi,	ecx	# r[1] = n10 = 55 = 0x37
        zLD	0x28,	edi,	edx	# r[2] = n11 = 89 = 0x59
        zLD	0x2C,	edi,	ebx	# r[3] = n12 = 144 = 0x90
        zLD	0x30,	edi,	esp	# r[4] = n13 = 233 = 0xe9
        zLD	0x34,	edi,	ebp	# r[5] = n14 = 377 = 0x179
        zLD	0x38,	edi,	esi	# r[6] = n15 = 610 = 0x262
        zLD	0x3C,	edi,	edi	# r[7] = n16 = 987 = 0x3db
