        .data
N:     .word 0          #输入的N
F:      .space 5000   #存数低4个字节
F2:     .space 5000  #存数高4个字节
str_hex:       .space 5000 #存放16进制数
str_space:    .asciiz "\t\t" #制表符分隔
str_nextline: .asciiz "\n"   #换行符
str_input:     .asciiz "please input N:"        #输入提示
str_output:   .asciiz "Fibonacci is below: \n"  #输出提示
str_error:     .asciiz "the data is overflow\n"    #溢出报错
str_warn:     .asciiz "N must > 0 !\n"         #输入报错

        .text
main: la $a0,str_input #打印输入提示
         li $v0,4
         syscall
         li $v0,5       
         syscall                #输入N
         ble $v0,$0,warn    #输入的N小于0，则跳转报错
         la $t0,N              #加载N的地址
         la $t6,F               #加载F的地址
         la $t7,F2             #加载F2的地址
         la $s1,str_hex       #加载str_hex地址
         lw $t5,($t0)    
         move $a0,$v0     #t5存放N的值
         jal FIB                 #调用FIB函数
         jal printout           #调用输出函数
exit:   li $v0,10                #程序结束
         syscall

#求斐波那契数列函数
FIB:     move $t5,$a0
          
          li $t1,1                #数列第一项低位
          li $t2,1                #数列第二项低位
          li $a1,0               #数列第一项高位
          li $a2,0               #数列第二项高位 
          li $t4,0                #循环计数器
          li $s7,45              #存放32十进制数溢出判断序号
          addi $t8,$0,-1      #t8存放MAX_INT   

loop1:  sw $t1,($t6)        #保存低4个字节
           sw $a1,($t7)       #保存高4个字节
           b hexout           #转换成16进制
this:    addu $t3,$t1,$t2   #t3=t1+t2
         addi $t8,$0,-1       #t8存放MAX_INT
         subu  $t8,$t8,$t1   #t8=t8-t1
         sltu $t9,$t8,$t2     #判断是否有溢出，若有则进位t9=1；否则t9=0
         move $t1,$t2        #t1=t2  低位迭代
         move $t2,$t3        #t2=t3
         add $a3,$a1,$a2   #a3=a1+a2
         addu $a3,$a3,$t9   #加上进位
         beqz $a1,a           #判断溢出
         beqz $a2,a
         addi $t8,$a2,1    
         blt $a3,$t8,error  
          
         
a:      move $a1,$a2       #a1=a2   高位迭代
         move $a2,$a3      #a2=a3
         addi $t4,$t4,1        #循环计数器累加一
         addi $t6,$t6,4       #低位地址指向下一个字
         addi $t7,$t7,4        #高位地址指向下一个字
         blt $t4,$t5,loop1    #判断是否结束循环
         jr $ra

hexout: move $s0,$t1          #传递参数
            li $s2,8                  #设置循环变量
            addi $s3,$s1,17       #准备存放16位16进制数
loop2:   andi $s4,$s0,0x0f   #取低一个字节
            srl $s0,$s0,4           #逻辑右移4位 
           bge $s4,10,char1      #>=10转换成字符
           addi $s4,$s4,0x30    #s4<10 转换成数字
           b put1                     
char1:    addi $s4,$s4,0x37  #转换成字符
put1:    sb $s4,($s3)            #保存数据
          addi $s3,$s3,-1        #高一位bit
          addi $s2,$s2,-1        #循环变量-1
          bgtz $s2,loop2        #判断循环是否结束
           
            move $s0,$a1         #传递高位4个字节
            li $s2,8                   #设置循环变量
loop3:  andi $s4,$s0,0x0f    #取低一个字节
           srl $s0,$s0,4            #逻辑右移4位 
           bge $s4,10,char2     #>=10转换成字符
           addi $s4,$s4,0x30    #s4<10 转换成数字
           b put2
char2: addi $s4,$s4,0x37    #转换成字符
put2:   sb $s4,($s3)            #保存数据
          addi $s3,$s3,-1        #高一位bit
          addi $s2,$s2,-1        #循环变量-1
          bgtz $s2,loop3        #判断循环是否结束
            
          li $s5,0x78              #转换结束
          sb $s5,1($s1)           #设置16进制前的x
          li $s5,0x30       
          sb $s5,($s1)            #设置16进制前的0
          sb $0,18($s1)           #16进制数末尾置“\0”
          addi $s1,$s1,19        #地址指向保存下一个16进制数的地方
          b this                     #跳回



#输出函数
printout: la $a0,str_output      #打印输出提示
             li $v0,4
             syscall
             la $t6,F                    #加载F地址          
             la $t7,F2                  #加载F2地址
             li $t4,0                     #循环变量
             la $s1,str_hex            #加载存放16进制数的地址
loop4:   addi $s6,$t4,1           #s6存放下标
             move $a0,$s6          #打印下标
             li $v0,1                     
             syscall
             la $a0,str_space       #打印空格，分隔
             li $v0,4
             syscall
             blt $s7,$t4,out         #判断32位是否溢出
            
Nout:     lw $a0,($t6)             #############
             li $v0,1
             syscall                    #############
             la $a0,str_space      #打印空格分隔
             li $v0,4
            syscall
out:       move $a0,$s1          #打印16进制数
             li $v0,4
              syscall
             la $a0,str_nextline   #下一行
             li $v0,4
             syscall
             addi $t4,$t4,1          #循环变量+1
             addi $t6,$t6,4         #下一字节
             addi $t7,$t7,4          #下一字节
             addi $s1,$s1,19         #保存下一个16进制的地址
             blt $t4,$t5,loop4      #判断循环是否结束
             jr $ra                      #返回堆栈地址
warn:   la $a0,str_warn         #打印输入错误字符串
           li $v0,4
           syscall
           b exit                       #跳转到结束

error:   la $a0,str_error         #打印溢出字符串
           li $v0,4
           syscall
           b exit                        #跳转到结束


             
            
          
         
         