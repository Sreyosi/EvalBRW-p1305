.include "../source/p1305_macros.s"
.globl p1305_nrBRW_computation
p1305_nrBRW_computation:

/*Parameters passed to p1305_nrBRW_computation by caller: rdi=no of bits, rsi=points to input message, rdx= points to input key, rcx=points to output*/


subq $300, %rsp

movq %rbx, 16(%rsp)
movq %r12, 24(%rsp)
movq %r13, 32(%rsp)
movq %r14, 40(%rsp)
movq %r15, 48(%rsp)
movq %rbp, 56(%rsp)
movq %rdx, 72(%rsp)
movq %rcx, 104(%rsp)


movq 0(%rdx), %rcx

movq 8(%rdx), %rbx

/*compute no_of_16-byte-blocks*/
xorq %rdx, %rdx
movq %rdi, %rax
movq %rax, 112(%rsp)

movq $0, 160(%rsp)
movq $0, 168(%rsp)


movq $128, %r12
divq %r12 /* divq requires dividend to be in rdx:rax..returns quotient in rax and remainder in rdx */

/*increase no_of_blocks by 1 if there is imperfect last block*/
cmp $0, %rdx
je no_imperfect_block
inc %rax
no_imperfect_block: movq %rax, 80(%rsp)

lzcnt %rax, %r12
movq $64, %rdi
subq %r12, %rdi
movq %rdi, %r11

/*** load the effective address of the memory where the squares have been stored ***/
leaq squares, %rdi
movq %rdi, 64(%rsp)
/**********************************************************************************/



/***  copy key...tau^1 ****/

movq %rcx, 0(%rdi)

movq %rbx, 8(%rdi) 

addq $16, %rdi 

/*xorq %rax, %rax*/

subq    $1, %r11

movq %rcx, %rdx

mulx %rbx, %r8, %r9

movq $0, %r10
shld $1, %r9, %r10
shld $1, %r8, %r9
shlq $1, %r8 

mulx %rdx, %rcx, %r14 
addq %r14, %r8

movq %rbx, %rdx

mulx %rdx, %rbx, %r15
adcx %rbx, %r9
adcx %r15, %r10

movq %r9, %r14
andq mask62,%r9
andq mask62_upper,%r14
addq %r14,%rcx
adcq %r10,%r8
adcq $0,%r9
shrd $2,%r10,%r14
shrq $2,%r10
addq %r14, %rcx
adcq %r10,%r8
adcq $0,%r9

movq %r9,%r13
andq mask62,%r9
shrq $2,%r13
imul $5,%r13,%r13
addq %r13,%rcx
adcq $0,%r8
adcq $0,%r9
		
movq %r9,%r13
andq mask62,%r9
shrq $2,%r13
imul $5,%r13,%r13
addq %r13,%rcx
adcq $0,%r8
adcq $0,%r9


movq %rcx, 0(%rdi)

movq %r8, 8(%rdi)

movq %r9, 16(%rdi)

cmpq $0, %r11

je extra1

addq $24, %rdi

.START:

subq    $1, %r11

movq %rcx, %rdx

mulx %r8, %r10, %r12

mulx %r9, %r14, %r15

movq %r8, %rdx

mulx %r9, %rbx, %r13

adcx %r14, %r12
adcx %rbx, %r15
adcx zero, %r13

shld $1, %r15, %r13
shld $1, %r12, %r15
shld $1, %r10, %r12
shlq $1, %r10

movq %rcx, %rdx

mulx %rdx, %rcx, %rbx
addq %rbx, %r10

movq %r8, %rdx

mulx %rdx, %r8, %rax
adcx  %r12, %r8
adcx %rax, %r15


movq %r9, %rdx

mulx %rdx, %r9, %r14
adcx %r13, %r9


movq %r8, %r14
andq mask62,%r8
andq mask62_upper,%r14
addq %r14,%rcx
adcq %r15,%r10
adcq %r9,%r8
shrd $2,%r15,%r14
shrd $2,%r9,%r15
shrq $2,%r9
addq %r14, %rcx
adcq %r15,%r10
adcq %r8,%r9

movq %r9,%r13
andq mask62,%r9
shrq $2,%r13
imul $5,%r13,%r13
addq %r13,%rcx
adcq $0,%r10
adcq $0,%r9
		

movq %r9,%r13
andq mask62,%r9
shrq $2,%r13
imul $5,%r13,%r13
addq %r13,%rcx
adcq $0,%r10
adcq $0,%r9


movq %r10, %r8

movq %rcx, 0(%rdi)

movq %r8, 8(%rdi)

movq %r9, 16(%rdi)

addq $24, %rdi



cmpq $0, %r11

jnz .START


cmp $7, 80(%rsp)

jle extra1 /**** jump to the extra section if number of blocks is at most 7*****/ 



     /**** For larger messages we need to compute number of chunks of blocks of input messages with number of look-ahead blocks(in this that no of look-ahead blocks is 8)********/ 
     comp_lookahead:    /*compute no of perfect chunks of look-ahead blocks*/

               
		
		xorq %rdx, %rdx
		movq 80(%rsp), %rax
		movq $8, %r12
		divq %r12 
		movq %rdx, 80(%rsp)
		movq %rax, 88(%rsp) /*store the number of perfect look-ahead blocks*/
		leaq squares, %rdi
                movq %rdi, 64(%rsp)
       

    
    
     /* prepare stack and other iteration details*/
     movq $1, 96(%rsp)
   
     leaq stack, %r9 
     movq %r9, 160(%rsp)
     movq %r9, 168(%rsp)
     movq $0, 120(%rsp)

/*nrBRW Computation for messsages at least 128 bytes long*/
        
start:          movq 64(%rsp), %rdx
               
                /* m6+(tau^2) */
		
		prepare_and_add_store_1 80(%rsi), 88(%rsi), 16(%rdx), 24(%rdx), 32(%rdx), %rax, %rbx, %rcx
		
		
		
		/*** m2+tau^2 ***/
			
		prepare_and_add 16(%rsi), 24(%rsi), %r11, %r12, %r13, %r14, %r15, %rdi
		
		 
		/*  m5+tau  */

		movq 64(%rsp), %rdx
		
		prepare_and_add_store_2 64(%rsi), 72(%rsi), 0(%rdx), 8(%rdx),  $0, 128(%rsp), 136(%rsp), 144(%rsp)
		
		             
                /* m1+tau  */
                
                prepare_and_add_2 0(%rsi), 8(%rsi)
                
                
                
		/* m4+tau^4 */
		
		movq 56(%rdx), %rbp
		movq %rbp, 216(%rsp)
		 
		prepare_and_add_store  48(%rsi), 56(%rsi), 40(%rdx), 48(%rdx), 56(%rdx), 200(%rsp), 208(%rsp), 216(%rsp)
		
		
					
		BRW_7	128(%rsp), 136(%rsp), 144(%rsp), %rax, %rbx,	%rcx, 96(%rsi), 104(%rsi), %r11, %r12, %r13, %r14, %r15, %rdi, 224(%rsp),232(%rsp),240(%rsp),248(%rsp),256(%rsp),32(%rsi), 40(%rsi),200(%rsp), 208(%rsp), 216(%rsp)
		
		/*jmp final_reduction*/
		/*******************************************************************************************************************************************************************************/
		
		
		check_stack: movq 96(%rsp), %rbp
    	
                		movq $0, %r13
               
				shrq $1, %rbp
				jc common
				movq 160(%rsp), %r14
			
		loop1:        add_unreduced -40(%r14), -32(%r14), -24(%r14), -16(%r14), -8(%r14)
						
			       inc %r13
                              subq $40, %r14
                              shrq $1, %rbp

        			jnc loop1
        			
        			movq %r14, 160(%rsp)
                
		common:  addq $1, 96(%rsp)
		reduce %r8, %r9, %r10, %r11, %r12
		movq %r11, %rax
		movq %r12, %rbx
		
                       
		movq 64(%rsp), %rdx
     		addq $64, %rdx
               
		imul $24, %r13, %r13
		addq %r13, %rdx
		
		movq 112(%rsi), %r14
		movq 120(%rsi), %r15
		movq $0, %r13
		
		addq 0(%rdx), %r14
		adcq 8(%rdx), %r15
		adcq 16(%rdx), %r13	
		
    		mul_3x3 %r14, %r15, %r13, %rdi, %rax, %rbx 
    		
    		
		movq 96(%rsp), %rcx
		
		
		movq 160(%rsp), %rdi
		
		
		addq $128, %rsi
		
		
		
		movq %r8,0(%rdi)
		movq %r9,8(%rdi)
		movq %r10, 16(%rdi)
		movq %r11, 24(%rdi)
		movq %r12, 32(%rdi)
		
		
		cmp %rcx, 88(%rsp)
		
		jl extra
		
		
		addq $40, 160(%rsp)
		
	        
                              
                jmp start
                               

     	   

   
   		
   extra: movq 80(%rsp), %rax /*check how many blocks are left...only one case will be satisfied*/
   
   	cmp $0, %rax
   	je common1
   	addq $40, 160(%rsp)
   	
   extra1:  cmp $1, %rax
   	je one
   	cmp $2, %rax
   	je two
   	cmp $3, %rax
   	je three
        cmp $4, %rax
   	je four
        cmp $5, %rax
   	je five
        cmp $6, %rax
   	je six
   	jmp seven
        
   

    one:  	movq 0(%rsi), %r8 
          	movq 8(%rsi), %r9
          	movq $0, %r10
	  	movq $0, %r11
	  	movq $0, %r12
	 
	 	jmp common1
                
          
    two:  	BRW_2 0(%rsi), 8(%rsi), 16(%rsi), 24(%rsi)
    
    		
         	jmp common1

    three:      movq 64(%rsp), %rdx
    		prepare_and_add_store 0(%rsi), 8(%rsi), 0(%rdx), 8(%rdx), $0, %rax, %rbx, %rcx
    		prepare_and_add_store 16(%rsi), 24(%rsi), 16(%rdx), 24(%rdx), 32(%rdx), %r11, %r12, %r13
    		BRW_3  %r11, %r12, %r13, %rax, %rbx, %rcx, 32(%rsi), 40(%rsi)
    		
		jmp common1

    four: movq 64(%rsp), %rdx
    	  prepare_and_add_store 0(%rsi), 8(%rsi), 0(%rdx), 8(%rdx), $0, %rax, %rbx, %rcx
    	  prepare_and_add_store 16(%rsi), 24(%rsi), 16(%rdx), 24(%rdx), 32(%rdx), %r11, %r12, %r13
     	  prepare_and_add_store 48(%rsi), 56(%rsi), 40(%rdx), 48(%rdx), 56(%rdx), 200(%rsp), 216(%rsp), 224(%rsp)
	  BRW_4 %r11, %r12, %r13, %rax, %rbx, %rcx, 32(%rsi), 40(%rsi), 200(%rsp), 216(%rsp), 224(%rsp)
    	  
    	  jmp common1
    	  
    five: movq 64(%rsp), %rdx
    	  prepare_and_add_store 0(%rsi), 8(%rsi), 0(%rdx), 8(%rdx), $0, %rax, %rbx, %rcx
    	  prepare_and_add_store 16(%rsi), 24(%rsi), 16(%rdx), 24(%rdx), 32(%rdx), %r11, %r12, %r13
     	  prepare_and_add_store 48(%rsi), 56(%rsi), 40(%rdx), 48(%rdx), 56(%rdx), 200(%rsp), 216(%rsp), 224(%rsp)
	  BRW_4 %r11, %r12, %r13, %rax, %rbx, %rcx, 32(%rsi), 40(%rsi), 200(%rsp), 216(%rsp), 224(%rsp)
    	  
    	  add_unreduced 64(%rsi), 72(%rsi), $0, $0, $0
    	  jmp common1
    	  	  
     six: movq 64(%rsp), %rdx
    	  prepare_and_add_store 0(%rsi), 8(%rsi), 0(%rdx), 8(%rdx), $0, %rax, %rbx, %rcx
    	  prepare_and_add_store 16(%rsi), 24(%rsi), 16(%rdx), 24(%rdx), 32(%rdx), %r11, %r12, %r13
     	  prepare_and_add_store 48(%rsi), 56(%rsi), 40(%rdx), 48(%rdx), 56(%rdx), 200(%rsp), 216(%rsp), 224(%rsp)
	  BRW_4 %r11, %r12, %r13, %rax, %rbx, %rcx, 32(%rsi), 40(%rsi), 200(%rsp), 216(%rsp), 224(%rsp)
    	  movq %r8, 224(%rsp)
    	  movq %r9, 232(%rsp)
    	  movq %r10, 240(%rsp)
    	  movq %r11, 248(%rsp)
    	  movq %r12, 256(%rsp)
    	  BRW_2 64(%rsi), 72(%rsi),80(%rsi), 88(%rsi)
    	  add_unreduced 224(%rsp), 232(%rsp), 240(%rsp), 248(%rsp), 256(%rsp)
    	  
    	  jmp common1
    	  
     seven: movq 64(%rsp), %rdx
               
                /* m6+(tau^2) */
		
		prepare_and_add_store_1 80(%rsi), 88(%rsi), 16(%rdx), 24(%rdx), 32(%rdx), %rax, %rbx, %rcx
		
		
		
		/*** m2+tau^2 ***/
			
		prepare_and_add 16(%rsi), 24(%rsi), %r11, %r12, %r13, %r14, %r15, %rdi
		
		 
		/*  m5+tau  */

		movq 64(%rsp), %rdx
		
		prepare_and_add_store_2 64(%rsi), 72(%rsi), 0(%rdx), 8(%rdx),  $0, 128(%rsp), 136(%rsp), 144(%rsp)
		
		             
                /* m1+tau  */
                
                prepare_and_add_2 0(%rsi), 8(%rsi)
                
                
                
		/* m4+tau^4 */
		
		movq 56(%rdx), %rbp
		movq %rbp, 216(%rsp)
		 
		prepare_and_add_store  48(%rsi), 56(%rsi), 40(%rdx), 48(%rdx), 56(%rdx), 200(%rsp), 208(%rsp), 216(%rsp)
		
		
					
		BRW_7	128(%rsp), 136(%rsp), 144(%rsp), %rax, %rbx,	%rcx, 96(%rsi), 104(%rsi), %r11, %r12, %r13, %r14, %r15, %rdi, 224(%rsp),232(%rsp),240(%rsp),248(%rsp),256(%rsp),32(%rsi), 40(%rsi),200(%rsp), 208(%rsp), 216(%rsp)

    	  

      common1:  movq 160(%rsp), %r14
    		 movq 168(%rsp), %r13

		
                

        loop3:  cmp %r13, %r14
                jle zero_0
               
                add_unreduced -40(%r14), -32(%r14), -24(%r14), -16(%r14), -8(%r14)
		
                subq $40, %r14
    		        
                        
                jmp loop3

      
	zero_0 : 	reduce %r8, %r9, %r10, %r11, %r12
			movq %r11, %rax
			movq %r12, %rbx
			    
    
   wrap_up:     movq    64(%rsp), %rsi


        	movq 16(%rsi), %r14
		movq 24(%rsi), %r15
		movq 32(%rsi), %r13

        
        mul_3x3 %r14, %r15, %r13, %rdi, %rax, %rbx  
	
        movq 112(%rsp), %rdx
        
	
	movq 0(%rsi), %rax
	movq 8(%rsi), %rbx
        
	mulx %rax, %rcx, %r15
	
	mulx %rbx, %rdi, %rsi
	adcx %rdi, %r15
	adcx zero, %rsi

	add_unreduced %rcx, %r15, %rsi, $0, $0
        
       
        
      final_reduction: reduce %r8, %r9, %r10, %r11, %r12
      		
		movq %r12, %r15
		shrq $2, %r15
		andq mask62, %r12
		imul $5, %r15, %r15
		addq %r15, %rdi
		adcq $0, %r11
		adcq $0, %r12


		movq    %rdi, %r8
		movq    %r11, %r9
		movq    %r12, %r10

		subq    p0,%r8
		sbbq    p1,%r9
		sbbq    p2,%r10

		movq    %r10,%r14
		shlq    $62,%r14

		cmovc   %r8, %rdi
		cmovc   %r9, %r11
		cmovc   %r10, %r12

			
		/*final result*/
    		final_result: movq 104(%rsp), %rsi

    		movq %rdi,0(%rsi) 
    		movq %r11,8(%rsi) 
    		movq %r12,16(%rsi)
		
		
    		  
movq 16(%rsp), %rbx
movq 24(%rsp), %r12
movq 32(%rsp), %r13
movq 40(%rsp), %r14
movq 48(%rsp), %r15
movq 56(%rsp), %rbp


addq $300, %rsp

ret





