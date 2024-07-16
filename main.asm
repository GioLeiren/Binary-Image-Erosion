.macro done
  li a7, 10
  ecall
.end_macro

.macro input
  li a7, 12
  ecall
.end_macro

.data
mat1: .byte
 1 1 1 0 0 1 1 1 1 1 1 0 0 0 1 0
 1 1 1 0 0 1 1 1 1 1 1 0 0 0 1 0
 1 1 1 0 0 0 1 1 1 1 0 0 0 0 1 0
 0 0 0 0 0 0 0 0 0 0 0 0 0 0 1 0
 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0
 1 1 1 1 0 0 0 0 0 0 0 0 0 0 0 0
 1 1 1 1 0 0 0 0 1 1 1 1 0 0 0 0
 0 0 0 0 0 0 0 1 1 1 1 1 1 0 0 0
 0 0 0 0 0 0 1 1 1 1 1 1 1 1 0 0
 0 0 0 0 0 0 1 1 1 0 0 1 1 1 0 0
 0 0 0 0 0 0 1 1 1 0 0 1 1 1 0 0
 0 1 1 0 0 0 1 1 1 1 1 1 1 1 0 0
 0 1 1 0 0 0 0 1 1 1 1 1 1 0 0 0
 0 0 0 0 0 0 0 0 1 1 1 1 0 0 0 0
 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0
 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0
mat2: .byte 0:255

DSP:	    .word 0x10040000
SIZE:	    .word 256
SIZE_ERODE: .word 196
WIDTH:      .word 16
green:	    .word 0x0000FF00

.text

la a2, mat1          #loada o endereço inicial de mat1 em a2
lw s1, DSP           #loada o endereço inicial do display
lw t1, SIZE          #quantidade de pixels no display (ou a quantidade de elementos no array da matriz)
lw a3, green         #loada o byte correspondente à cor verde em um pixel arbitrário (uma word)
jal bin_im	     #função para printar no display a imagem contida na matriz

la a0, mat1	     #loada o endereço inicial de mat1 em a0 como matriz fonte
la a1, mat2	     #loada o endereço inicial de mat2 em a1 como matriz destino
li a2, 256	     #tamanho das matrizes (16x16)
jal cpymat	     #chamada de função de copiar matriz

li a0, 0	     #guarda o valor 0 em a0 (linha 0)
la a1, mat2	     #loada o endereço inicial de mat2 em a1
li a2, 16	     #tamanho da matriz (16x16)
jal clrln	     #chamada de função para limpar linha (linha 0)

li a0, 15	     #guarda o valor 15 em a0 (linha 15)
la a1, mat2	     #loada o endereço inicial de mat2 em a1
li a2, 16	     #tamanho da matriz (16x16)
jal clrln	     #chamada de função para limpar linha (linha 15)

li a0, 0	     #guarda o valor 0 em a0 (coluna 0)
la a1, mat2	     #loada o endereço inicial de mat2 em a1
li a2, 16	     #tamanho da matriz (16x16)
jal clrcln	     #chamada de função para limpar coluna (coluna 0)

li a0, 15	     #guarda o valor 15 em a0 (coluna 15)
la a1, mat2	     #loada o endereço inicial de mat2 em a1
li a2, 16	     #tamanho da matriz (16x16)
jal clrcln	     #chamada de função para limpar coluna (coluna 15)

li a0, 1	     #inicia a linha em 1
li a1, 1	     #inicia a coluna em 1
la a2, mat1	     #loada o endereço inicial de mat1 em a2
li a3, 196
li t0, 16	     #loada a largura da matriz
addi t1, t0, -1	     #variável para verificar se a coluna chegou no frame externo
jal erode_window     #janela de erosão deslizante

input		     #input de algum char para continuar o procedimento
jal clrdsp	     #limpa o display pra mostrar a outra matriz

la a2, mat2          #loada o endereço inicial de mat2 em a2
li s1, 0x10040000    #loada o endereço inicial do display
li t1, 256           #quantidade de pixels no display (ou a quantidade de elementos no array da matriz)
lw a3, green         #loada o byte correspondente à cor verde em um pixel arbitrário (uma word)
jal bin_im	     #função para printar no display a imagem contida na matriz

j fim

bin_im:
beqz t1, return
lb t0, 0(a2)         #pega o byte atual da matriz
bnez t0, green_pixel #se o byte for 1, vai pra função de printar verde no display
sw zero, 0(s1)	     #se o byte for 0, printa preto
addi s1, s1, 4	     #incrementa o endereço do display
addi a2, a2, 1	     #incrementa o endereço da matriz
addi t1, t1, -1      #decrementa quantidade de pixels que faltam para preencher
j bin_im

green_pixel:
sw a3, 0(s1)	     #muda a cor do pixel pra verde
addi s1, s1, 4	     #incrementa o endereço do display
addi a2, a2, 1	     #incrementa o endereço da matriz
addi t1, t1, -1      #decrementa quantidade de pixels que faltam para preencher
j bin_im

erode_window:
mv s0, a0	     #salva o valor de a0 (linha 1) em s0
beqz a3, return
mul a0, a0, t0	     #linha correspondente
add a0, a0, a1	     #coluna correspondente
add a0, a0, a2	     #atualiza a posição da janela na matriz

evalpix:
beq a1, t1, end_ln   #vê se a janela chegou na coluna 14
mv t2, a0	     #elemento (i-1, j-1)
sub t2, t2, t0	     #da
addi t2, t2, -1      #janela
mv t3, t2	     #elemento (i-1, j)
addi t3, t3, 1	     #da janela
lb s1, 0(t2)
lb s2, 0(t3)
and s1, s1, s2	     #compara os elementos (i-1, j-1) e i-1, j)
beqz s1, erode	     #se der 0, erode o bit

addi t3, t3, 1	     #elemento (i-1, j+1) da janela
lb s2, 0(t3)
and s1, s1, s2
beqz s1, erode

add t3, t3, t0
addi t3, t3, -2	     #elemento (i, j-1) da janela
lb s2, 0(t3)
and s1, s1, s2
beqz s1, erode

addi t3, t3, 1	     #elemento (i, j) da janela
lb s2, 0(t3)
and s1, s1, s2
beqz s1, erode

addi t3, t3, 1	     #elemento (i, j+1) da janela
lb s2, 0(t3)
and s1, s1, s2
beqz s1, erode

add t3, t3, t0
addi t3, t3, -2	     #elemento (i+1, j-1) da janela
lb s2, 0(t3)
and s1, s1, s2
beqz s1, erode

addi t3, t3, 1	     #elemento (i+1, j) da janela
lb s2, 0(t3)
and s1, s1, s2
beqz s1, erode

addi t3, t3, 1	     #elemento (i+1, j+1) da janela
lb s2, 0(t3)
and s1, s1, s2
beqz s1, erode

mv a0, s0	     #restaura valor de a0, para a janela continuar na linha
addi a1, a1, 1	     #avança a janela para a direita
addi a3, a3, -1
j erode_window

erode:
sb zero, 256(a0)
mv a0, s0	     #restaura valor de a0, para a janela continuar na linha
addi a1, a1, 1	     #avança a janela para a direita
addi a3, a3, -1
j erode_window

end_ln:
addi a1, a1, -14     #volta para a coluna 1
mv a0, s0	     #restaura valor de a0
addi a0, a0, 1	     #pula para a próxima linha
j erode_window

return:
ret

fim:
done



cpymat: ############################################# COPY MAT
# a0: matorg a1: matdst a2: length in bytes

cpS:
blez a2, cpE
lbu t0, 0(a0)
sb t0, 0(a1)
addi a0, a0, 1
addi a1, a1, 1
addi a2, a2, -1
j cpS
cpE:
ret

clrln: ############################################# CLEAR LINE
# a0: lin a1: mat a2: length
li t0, 16	     #guarda a largura da matriz em t0
mul a0, a0, t0	     #multiplica a linha a0 pela largura da matriz para identificar a linha para limpar
add a1, a1, a0	     #muda o endereço atual da matriz para a linha correspondente
lnS:
blez a2, lnE
sb zero, 0(a1)
addi a1, a1, 1
addi a2, a2, -1
j lnS
lnE:
ret

clrcln: ############################################# CLEAR COLUMN
# a0: col a1: mat a2: length
li t0, 16
add a1, a1, a0
clnS:
blez a2, clnE
sb zero, 0(a1)
add a1, a1, t0
addi a2, a2, -1
j clnS
clnE:
ret

clrdsp: ############################################# CLEAR DSP
#
li t0, 0x10040000    # display initial address
li t1, 256           # number of pixels in display
cL:
blez t1, cR
sw zero, 0(t0)
addi t1, t1, -1
addi t0, t0, 4
j cL
cR:
ret
