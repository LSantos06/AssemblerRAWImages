## Trabalho 3 - Organizacao e Arquitetura de Computadores 
## Lucas Nascimento Santos Souza - 14/0151010

## Configuracao do MARS
	# Memoria: default
	# Unidade de largura em pixels: 4
	# Unidade de altura em pixels: 4
	# Largura do display: 256
	# Altura do display: 256
	# Endereco base do display: 0x10040000 (heap)
.data

title:			.asciiz "\n ********* RAW Images in MIPS *********\n"
load_img_menu: 		.asciiz "1 - Load Img\n"
get_pixel_menu: 	.asciiz "2 - Get Pixel\n"
set_pixel_menu: 	.asciiz "3 - Set Pixel\n"
grey_menu: 		.asciiz "4 - 255 Grey Scale\n"
exit_menu: 		.asciiz "5 - Exit\n"
menu_msg:		.asciiz "Digite o valor correspondente a operacao desejada: "

pixel_x_msg:		.asciiz "\nDigite o valor da linha x (de 0 a 63): "
pixel_y_msg:		.asciiz "Digite o valor da coluna y (de 0 a 63): "

pixel_R_msg:		.asciiz "\nDigite o valor de R (de 0 a 255): "
pixel_G_msg:		.asciiz "Digite o valor de G (de 0 a 255): "
pixel_B_msg:		.asciiz "Digite o valor de B (de 0 a 255): "

pixel_msg:		.asciiz "\nValor do pixel: "

erro_pixel_msg:		.asciiz "\nDigite um valor valido!"
erro_arq_msg:		.asciiz "\nErro ao abrir arquivo, verifique o diretorio e o nome do mesmo!"

pixel_R:		.asciiz "\nR: "
pixel_G:		.asciiz "\nG: "
pixel_B:		.asciiz "\nB: "

file:			.asciiz "image.raw"

buffer:			.word 0

.text

# Interface com o usuario
menu:
	addi $v0, $zero, 4 # Codigo para imprimir uma string = 4
	la $a0, title 
	syscall

	addi $v0, $zero, 4 # Codigo para imprimir uma string = 4
	la $a0, load_img_menu 
	syscall

	addi $v0, $zero, 4 # Codigo para imprimir uma string = 4
	la $a0, get_pixel_menu
	syscall

	addi $v0, $zero, 4 # Codigo para imprimir uma string = 4
	la $a0, set_pixel_menu 
	syscall

	addi $v0, $zero, 4 # Codigo para imprimir uma string = 4
	la $a0, grey_menu 
	syscall

	addi $v0, $zero, 4 # Codigo para imprimir uma string = 4
	la $a0, exit_menu 
	syscall
	
	addi $v0, $zero, 4 # Codigo para imprimir uma string = 4
	la $a0, menu_msg
	syscall
	
	li $v0, 5 # Le um valor inteiro do teclado
	syscall 
	
	# Variaveis
	la $s1, buffer # Carrega o endereco do buffer
	
	add $s2, $zero, 0x10040000 # Endereco do heap 
	
	add $t0, $zero, $zero # Contador iniciado com 0
	
	addi $t1, $zero, 3 # Le 1 pixel
	
	# Menu
	beq $v0, 1, read_img # -> load_img
	beq $v0, 2, get_pixel # -> get_pixel
	beq $v0, 3, set_pixel # -> set_pixel
	beq $v0, 4, grey # -> grey
	beq $v0, 5, exit # -> exit
	
	j menu # loop


# Leitura de um arquivo binario com uma descricao de uma figura colorida no formato RGB
# Exibicao da figura no mostrador grafico
## Variaveis 
	# s0 => File Descriptor
	# s1 => Endereco inicial do Buffer
	# s2 => Endereco do heap, para display
	# s7 => load_img || grey
	# t0 => Contador
	# t1 => 1 pixel lido
	# t2 => Valor do buffer
read_img:
	# Abertura do arquivo	
	addi $v0, $zero, 13 # Codigo para abrir um arquivo
	la $a0, file
	li $a1, 0 # 0 para ler, 1 para escrever
	li $a2, 0 # mode
	syscall
	
	# Tratamento de erros
	bltz $v0, erro_arquivo
	
	move $s0, $v0 # Salva o file descriptor
	
	j load_img
	
load_img:
	# Convertendo para 4 bytes	
	beq $t0, 12288, close_img
	
	# Leitura do arquivo	
	addi $v0, $zero, 14 # Codigo para ler um arquivo
	move $a0, $s0 # File descriptor
	la $a1, buffer
	la $a2, 0($t1) # Le 1 pixel
	syscall
	
	# 0 
	sb $zero, 3($s1) # Armazena 0 no msbyte
	
	# Armazenando no display
	lw $t2, 0($s1) # Conteudo do buffer no $t2
	
	sw $t2, 0($s2) # Armazena o conteudo do buffer no endereco do display $s2
	
	# Incrementando as variaveis do laco
	addi $t0, $t0, 3 # Incrementa o contador em 3, numero de bytes lidos
	
	addi $s2, $s2, 4 # Proximo pixel do display
	
	j load_img

close_img:
	# Fechamento do arquivo	
	addi $v0, $zero, 16 # Codigo para fechar um arquivo
	move $a0, $s0 # File descriptor
	syscall
	
	j menu # return

# Leitura de pixels da imagem, get_pixel(x,y), imprime os valores RGB do pixel
## Variaveis 
	# s3 => valor do x
	# s4 => valor do y
	# t3 => Endereco pixel desejado
	# t4 => Pixel desejado
get_pixel:
	# X
	addi $v0, $zero, 4 # Codigo para imprimir uma string = 4
	la $a0, pixel_x_msg
	syscall	

	li $v0, 5 # Le um valor inteiro do teclado
	syscall 

	# Tratamento de erro
	bgt $v0, 63, erro_pixel
	blt $v0, 0, erro_pixel

	add $s3, $zero, $v0 # valor do x
	
	sll $s3, $s3, 2 # Multiplica x por 4

	# Y
	addi $v0, $zero, 4 # Codigo para imprimir uma string = 4
	la $a0, pixel_y_msg
	syscall	

	li $v0, 5 # Le um valor inteiro do teclado
	syscall

	# Tratamento de erro
	bgt $v0, 63, erro_pixel
	blt $v0, 0, erro_pixel
			
	add $s4, $zero, $v0 # valor do y
	
	sll $s4, $s4, 8 # Multiplica y por 64*4
	
	# Endereco do pixel desejado $t3
	add $t3, $s4, $s3 # x + y
	addi $t3, $t3, 0x10040000 # Endereco do heap + Endereco de deslocamento
	
	# Pixel desejado $t4
	lw $t4, 0($t3) # Endereco do pixel desejado em $t3
	
	addi $v0, $zero, 4 # Codigo para imprimir uma string = 4
	la $a0, pixel_msg
	syscall
	
	addi $v0, $zero, 34 # Codigo para imprimir uma hexadecimal = 34
	add $a0, $zero, $t4 
	syscall
	
	# R
	addi $v0, $zero, 4 # Codigo para imprimir uma string = 4
	la $a0, pixel_R
	syscall
	
	addi $v0, $zero, 1 # Codigo para imprimir um inteiro = 1
	lbu $a0, 2($t3) # 0x00RR0000
	syscall
	
	# G
	addi $v0, $zero, 4 # Codigo para imprimir uma string = 4
	la $a0, pixel_G
	syscall
	
	addi $v0, $zero, 1 # Codigo para imprimir um inteiro = 1
	lbu $a0, 1($t3) # 0x0000GG00
	syscall
	
	# B
	addi $v0, $zero, 4 # Codigo para imprimir uma string = 4
	la $a0, pixel_B
	syscall
	
	addi $v0, $zero, 1 # Codigo para imprimir um inteiro = 1
	lbu $a0, 0($t3) # 0x000000BB
	syscall
	
	j menu # return

# Escrita de pixels da imagem, set_pixel(x,y,valor), solicita o RGB do teclado, e escreve no pixel indicado
	# s3 => valor do x
	# s4 => valor do y
	# t2 => Endereco inicial do Buffer q contem o novo pixel
	# t3 => Endereco pixel desejado
	# t4 => Pixel desejado
set_pixel:
	# X
	addi $v0, $zero, 4 # Codigo para imprimir uma string = 4
	la $a0, pixel_x_msg
	syscall	

	li $v0, 5 # Le um valor inteiro do teclado
	syscall 
	
	# Tratamento de erro
	bgt $v0, 63, erro_pixel
	blt $v0, 0, erro_pixel

	add $s3, $zero, $v0 # valor do x
	
	sll $s3, $s3, 2 # Multiplica x por 4

	# Y
	addi $v0, $zero, 4 # Codigo para imprimir uma string = 4
	la $a0, pixel_y_msg
	syscall	

	li $v0, 5 # Le um valor inteiro do teclado
	syscall
	
	# Tratamento de erro
	bgt $v0, 63, erro_pixel
	blt $v0, 0, erro_pixel
	
	add $s4, $zero, $v0 # valor do y
	
	sll $s4, $s4, 8 # Multiplica y por 64*4
	
	# Buffer
	la $t2, buffer
	
	# Endereco do pixel desejado $t3
	add $t3, $s4, $s3 # x + y
	addi $t3, $t3, 0x10040000 # Endereco do heap + Endereco de deslocamento
	
	# Pixel atual $t4
	lw $t4, 0($t3) # Endereco do pixel desejado em $t3
	
	addi $v0, $zero, 4 # Codigo para imprimir uma string = 4
	la $a0, pixel_msg
	syscall
	
	addi $v0, $zero, 34 # Codigo para imprimir uma hexadecimal = 34
	add $a0, $zero, $t4 
	syscall
	
	# R
	addi $v0, $zero, 4 # Codigo para imprimir uma string = 4
	la $a0, pixel_R_msg
	syscall
	
	li $v0, 5 # Le um valor inteiro do teclado
	syscall
	
	# Tratamento de erro
	bgt $v0, 255, erro_pixel
	blt $v0, 0, erro_pixel
	
	sb $v0, 2($t2) # Armazena o novo R
	
	# G
	addi $v0, $zero, 4 # Codigo para imprimir uma string = 4
	la $a0, pixel_G_msg
	syscall
	
	li $v0, 5 # Le um valor inteiro do teclado
	syscall 
	
	# Tratamento de erro
	bgt $v0, 255, erro_pixel
	blt $v0, 0, erro_pixel
	
	sb $v0, 1($t2) # Armazena o novo G
	
	# B
	addi $v0, $zero, 4 # Codigo para imprimir uma string = 4
	la $a0, pixel_B_msg
	syscall
	
	li $v0, 5 # Le um valor inteiro do teclado
	syscall 
	
	# Tratamento de erro
	bgt $v0, 255, erro_pixel
	blt $v0, 0, erro_pixel 
	
	sb $v0, 0($t2) # Armazena o novo B
	
	# 0
	sb $zero, 3($t2) # Armazena o 0x00 no msbyte
	
	# Passando o buffer para o display
	lw $t4, 0($t2) # Conteudo do buffer no $t2
	
	sw $t4, 0($t3) # Armazena o conteudo do buffer no endereco do display $s2
	
	addi $v0, $zero, 4 # Codigo para imprimir uma string = 4
	la $a0, pixel_msg
	syscall
	
	addi $v0, $zero, 34 # Codigo para imprimir uma hexadecimal = 34
	add $a0, $zero, $t4 
	syscall
	
	j menu # return

# Conversao para cinza, para cada pixel, deve-se atribuir R=G=B=media(R,G,B)
## Variaveis 
	# s0 => File Descriptor
	# s1 => Endereco inicial do Buffer
	# s2 => Endereco do heap, para display
	# t0 => Contador
	# t1 => 1 pixel lido
	# t2 => media(R,G,B)
	# t3 => G
	# t4 => R
	# t5 => Buffer auxiliar
grey:
	# Convertendo para 4 bytes	
	beq $t0, 12288, close_img
	
	# Buffer
	add $s1, $zero, $s2 
	
	# Calculando a media
	lbu $t2, 0($s1) # Armazena o B, 0x000000BB => 0xBB
	lbu $t3, 1($s1) # Armazena o G, 0x0000GG00 => 0xGG
	lbu $t4, 2($s1) # Armazena o R, 0x00RR0000 => 0xRR
	
	add $t2, $t2, $t3 # B+G
	add $t2, $t2, $t4 # R+B+G
	
	divu $t2, $t2, 3 # (R+G+B)/3
	
	# Colocando a media no R,G e B no bufer
	sb $t2, 0($s1) 
	sb $t2, 1($s1) 
	sb $t2, 2($s1) 
	sb $zero, 3($s1) 
	
	# Passando o buffer para o display
	lw $t5, 0($s1) 
	sw $t5, 0($s2) 
	
	# Incrementando as variaveis do laco
	addi $t0, $t0, 3 # Incrementa o contador em 3, numero de bytes lidos
	
	addi $s1, $s1, 4 # Proximo pixel do heap
	
	addi $s2, $s2, 4 # Proximo pixel do display
	
	j grey

# Tratamento de erros
erro_pixel:
	addi $v0, $zero, 4 # Codigo para imprimir uma string = 4
	la $a0, erro_pixel_msg 
	syscall
	
	j menu
	
erro_arquivo:
	addi $v0, $zero, 4 # Codigo para imprimir uma string = 4
	la $a0, erro_arq_msg 
	syscall
	
	j exit
	
# Termino do programa
exit:
	li $v0, 10 # Codigo para terminar o programa = 10
	syscall
