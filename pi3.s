_setup_stack:
        zXOR    eax, eax
        zLIL    0x800, eax
        zSUBI   16, eax
        zMOV    eax, esp
        zMOV    eax, ebp
_clear_7seg1:
        zXOR    edx, edx
        zXOR    eax, eax
        zXOR    ecx, ecx
        zLIL    0x80, edx
        zLIL    _display_7seg, ecx
        zJALR   ecx
_clear_7seg2:
        zXOR    edx, edx
        zXOR    eax, eax
        zXOR    ecx, ecx
        zLIL    0x40, edx
        zLIL    _display_7seg, ecx
        zJALR   ecx
_start_frc:
        zXOR    eax, eax
        zXOR    esi, esi
        zLIL    0x04, eax
        zLIL    0x2000, esi
        zST     eax, 44, esi
_montecarlo_params:
        zXOR    eax, eax
        zLIL    0x3D, ebx
        zST     eax, 12, ebp
        zSLA    16, ebx
        zLIL    0x0900, ebx
        zST     ebx, 8, ebp
_main_loop:
        zXOR    esi, esi        #128bit XORshift
        zLIL    _x, esi
        zLD     0, esi, eax
        zMOV    eax, edi
        zLD     4, esi, ebx
        zSLA    11, edi
        zLD     8, esi, ecx
        zXOR    eax, edi
        zLD     12, esi, edx
        zMOV    edx, eax
        zST     ebx, 0, esi
        zSRL    19, edx
        zST     eax, 8, esi
        zXOR    edx, eax
        zST     ecx, 4, esi
        zXOR    edi, eax
        zSRL    8, edi
        zXOR    edi, eax
        zST     eax, 12, esi
_separate_coordinates:
        zXOR    ecx, ecx
        zMOV    eax, ebx
        zLIL    0x8000, ecx
        zXOR    edx, edx
        zSRL    16, ebx
        zLIL    0xFFFF, edx
        zXOR    esi, esi
        zAND    edx, eax
        zXOR    edi, edi
_square_loop:
        zMOV    eax, edx
        zSLL    1, esi
        zAND    ecx, edx
        zBcc    E, _square_loop_skip_inc_A
        zADD    eax, esi
_square_loop_skip_inc_A:
        zMOV    ebx, edx
        zSLL    1, edi
        zAND    ecx, edx
        zBcc    E, _square_loop_skip_inc_B
        zADD    ebx, edi
_square_loop_skip_inc_B:
        zSRL    1, ecx
        zBcc    NE, _square_loop
_check_overflow:
        zADD    esi, edi
        zLD     12, ebp, eax
        zBcc    B, _no_overflow
_overflow:
        zADDI   1, eax
        zST     eax, 12, ebp
_no_overflow:
        zXOR    ecx, ecx
        zLD     8, ebp, eax
        zLIL    _main_loop, ecx
        zSUBI   1, eax
        zST     eax, 8, ebp
        zBcc    E, _stop_frc
        zJR     ecx
_stop_frc:
        zXOR    eax, eax
        zXOR    esi, esi
        zLIL    0x10, eax
        zLIL    0x2000, esi
        zST     eax, 44, esi
_display_pi:
        zXOR    ecx, ecx
        zLD     12, ebp, eax
        zLIL    _decimal_format, ecx
        zJALR   ecx
        zXOR    edx, edx
        zXOR    ecx, ecx
        zLIL    0x80, edx
        zLIL    _display_7seg, ecx
        zJALR   ecx
_display_cycles:
        zXOR    esi, esi
        zXOR    ecx, ecx
        zLIL    0x2000, esi
        zXOR    edx, edx
        zLD     60, esi, ebx
        zLIL    0x40, edx
        zSLL    16, ebx
        zLD     56, esi, eax
        zOR     ebx, eax
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

_x:
        .long   123456789
_y:
        .long   362436069
_z:
        .long   521288629
_w:
        .long   88675123
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
