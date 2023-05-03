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



/*compute no_of_16-byte-blocks*/
xorq %rdx, %rdx
movq %rdi, %rax
movq %rax, 112(%rsp)

/*** load the effective address of the memory where the squares have been stored ***/
leaq squares, %rdi
movq %rdi, 64(%rsp)
/**********************************************************************************/

movq $0, 160(%rsp)
movq $0, 168(%rsp)



movq $128, %r12
divq %r12 /* divq requires dividend to be in rdx:rax..returns quotient in rax and remainder in rdx */

/*increase no_of_blocks by 1 if there is imperfect last block*/
cmp $0, %rdx
je no_imperfect_block
inc %rax
no_imperfect_block: movq %rax, 80(%rsp)
cmp $3, %rax
jle extra1 /**** jump to the extra section if number of bytes is at most 48 *****/ 



     /**** For larger messages we need to compute number of chunks of blocks of input messages with number of look-ahead blocks(in this that no of look-ahead blocks is 4)********/ 
     comp_lookahead:    /*compute no of perfect chunks of look-ahead blocks*/

               
		
		xorq %rdx, %rdx
		movq $4, %r12
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

/*nrBRW Computation for messsages at least 64 bytes long*/
        
start:          movq 64(%rsp), %rdx
               
               
		/*** m2+tau^2 ***/
			
		prepare_and_add_store 16(%rsi), 24(%rsi), 16(%rdx), 24(%rdx), 32(%rdx), %r14, %r15, %rdi
		             
                /* m1+tau  */
                
                prepare_and_add_store 0(%rsi), 8(%rsi),0(%rdx), 8(%rdx),  $0, %rax, %rbx, %rcx
                
                			
		BRW_3	%r14, %r15, %rdi, %rax, %rbx,	%rcx, 32(%rsi), 40(%rsi)		
		
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
     		addq $40, %rdx
               
		imul $24, %r13, %r13
		addq %r13, %rdx
		
		movq 48(%rsi), %r14
		movq 56(%rsi), %r15
		movq $0, %r13
		
		addq 0(%rdx), %r14
		adcq 8(%rdx), %r15
		adcq 16(%rdx), %r13	
		
    		mul_3x3 %r14, %r15, %r13, %rdi, %rax, %rbx 
    		
    		
		movq 96(%rsp), %rcx
		
		
		movq 160(%rsp), %rdi
		
		
		addq $64, %rsi
		
		
		
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
   	
   extra1:     cmp $1, %rax
   	je one
   	cmp $2, %rax
   	je two
   	
   	jmp three
        
        
   

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
    		/*movq %r12,16(%rsi)*/
		
		
    		  
movq 16(%rsp), %rbx
movq 24(%rsp), %r12
movq 32(%rsp), %r13
movq 40(%rsp), %r14
movq 48(%rsp), %r15
movq 56(%rsp), %rbp


addq $300, %rsp

ret





