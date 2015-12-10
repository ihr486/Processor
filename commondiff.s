# commondiff.s
# 等差数列の和
# 必須命令：
#	zADD
#	zADDI
# movもsubもxorも無いのでレジスタ初期値=0を信用するしかない
        zADDI	0x1,	eax	# 0x1
        zADD	eax,	edx		# 0x1
        zADDI	0x1,	eax	# 0x2
        zADD	eax,	edx		# 0x3
        zADDI	0x1,	eax	# 0x3
        zADD	eax,	edx		# 0x6
        zADDI	0x1,	eax	# 0x4
        zADD	eax,	edx		# 0xa
        zADDI	0x1,	eax	# 0x5
        zADD	eax,	edx		# 0xf
        zADDI	0x1,	eax	# 0x6
        zADD	eax,	edx		# 0x15
        zADDI	0x1,	eax	# 0x7
        zADD	eax,	edx		# 0x1c
        zADDI	0x1,	eax	# 0x8
        zADD	eax,	edx		# 0x24
        zADDI	0x1,	eax	# 0x9
        zADD	eax,	edx		# 0x2d
        zADDI	0x1,	eax	# 0xa
        zADD	eax,	edx		# 0x37
