# eratosthenes.s
# 必要な命令他
#	zLD
#	zST
#	zLIL
#	zMOV
#	zADD
#	zADDのゼロフラグ
#	zXOR
#	zADDI
#	zCMPI
#	zSLA
#	zB
#	zBcc

_main:
	zXOR	eax, eax
	zXOR	esp, esp		# // 今回はゼロレジスタ
	zXOR	ebx, ebx		# // 上のビット初期化
L2:					# do {
	zLIL	128, ebx		#	&(int*)((128
	zADD	eax, ebx		#		+ i)
	zSLA	2, ebx			#		* sizeof(int))
	zST	eax, 0, ebx		#		= i;
	zADDI	1, eax			#	++i
	zCMPI	100, eax		# } while (i < 100);
	zBcc	NE, L2
	zLIL	516, ebx		# ((int*)512)[1]
	zST	esp, 0, ebx		#	= 0;	// 1は素数でない
	zXOR	edx, edx		# j = 0;
L4:					# do {
	zLIL	128, ebx
	zADD	edx, ebx
	zSLA	2, ebx
	zLD	0, ebx, ecx		#	if ((factor = ((int*)512)[j]) != 0) {
	zADD	esp, ecx
	zBcc	E, L6
	zMOV	ecx, eax		#		for (	multiple = factor
	zADD	ecx, eax		#				+ factor;
	zCMPI	99, eax			#			multiple <= 99;
	zBcc	G, L6
L7:					#			multiple += factor)
	zLIL	128, ebx		#			&(int*)((128
	zADD	eax, ebx		#				+ multiple)
	zSLA	2, ebx			#				* sizeof(int))
	zST	esp, 0, ebx		#				= 0;
	zADD	ecx, eax		#			// multiple += factor;
	zCMPI	99, eax			#			// multiple <= 99;
	zBcc	LE, L7
L6:					#	} else {
	zADDI	1, edx			#		j += 1;
	zCMPI	50, edx			# }} while (j < (100 + 1) / 2);
	zBcc	NE, L4
	zXOR	edx, edx		#i = 0;
L8:					#do {
	zLIL	128, ebx
	zADD	edx, ebx
	zSLA	2, ebx
	zLD	0, ebx, ecx		#	if ((factor = ((int*)512)[i]) != 0) {
	zADD	esp, ecx
	zBcc	E, L9
	zMOV	ecx, eax		#		eax = factor;
L9:					#	}
	zADDI	1, edx			#	++i
	zCMPI	100, edx		#} while (i < 100);
	zBcc	NE, L8
        zHLT
