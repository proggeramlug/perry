
/root/cc-perf-native-recv-0909/runtime-own-read-cache-20260911/cc-candidate:	file format elf64-x86-64

Disassembly of section .text:

000000001188b440 <js_object_get_field_by_name>:
1188b440:      	pushq	%rbp
1188b441:      	movq	%rsp, %rbp
1188b444:      	pushq	%r15
1188b446:      	pushq	%r14
1188b448:      	pushq	%r13
1188b44a:      	pushq	%r12
1188b44c:      	pushq	%rbx
1188b44d:      	subq	$0xc8, %rsp
1188b454:      	movq	%rsi, %rbx
1188b457:      	movq	%rdi, %r14
1188b45a:      	movabsq	$-0x61c8864680b583eb, %r15 # imm = 0x9E3779B97F4A7C15
1188b464:      	movabsq	$0x7ffd000000000000, %r12 # imm = 0x7FFD000000000000
1188b46e:      	movabsq	$0xffffffffffff, %r13   # imm = 0xFFFFFFFFFFFF
1188b478:      	leaq	0x14(%rsi), %rax
1188b47c:      	movq	%rax, -0x38(%rbp)
1188b480:      	movq	%fs:0x0, %rax
1188b48c:      	leaq	-0x4d910(%rax), %rax
1188b493:      	movq	%rax, -0xa0(%rbp)
1188b49a:      	movq	%fs:0x0, %rax
1188b4a3:      	leaq	-0x561a8(%rax), %rax
1188b4aa:      	movq	%rax, -0x80(%rbp)
1188b4ae:      	movq	%rbx, %rax
1188b4b1:      	shrq	$0x3, %rax
1188b4b5:      	imulq	%r15, %rax
1188b4b9:      	movq	%rax, %rdx
1188b4bc:      	shrq	$0x22, %rdx
1188b4c0:      	movq	%rax, %rcx
1188b4c3:      	shrq	$0x36, %rcx
1188b4c7:      	movq	%rax, %rsi
1188b4ca:      	shrq	$0x3c, %rsi
1188b4ce:      	movq	%rsi, -0xf0(%rbp)
1188b4d5:      	movl	$0x1, %esi
1188b4da:      	shlq	%cl, %rsi
1188b4dd:      	movq	%rsi, -0xe8(%rbp)
1188b4e4:      	movq	%rax, %rcx
1188b4e7:      	shrq	$0x2c, %rcx
1188b4eb:      	movq	%rax, %rsi
1188b4ee:      	movl	$0x1, %edi
1188b4f3:      	shlq	%cl, %rdi
1188b4f6:      	movq	%rdi, -0xd8(%rbp)
1188b4fd:      	shrq	$0x32, %rsi
1188b501:      	andl	$0xf, %esi
1188b504:      	movq	%rsi, -0xe0(%rbp)
1188b50b:      	shrq	$0x28, %rax
1188b50f:      	andl	$0xf, %eax
1188b512:      	movq	%rax, -0xd0(%rbp)
1188b519:      	andl	$0x3f, %edx
1188b51c:      	movq	%rdx, -0xc8(%rbp)
1188b523:      	leaq	-0x1000(%rbx), %rax
1188b52a:      	movq	%rax, -0xc0(%rbp)
1188b531:      	movabsq	$0x800000000000, %rax   # imm = 0x800000000000
1188b53b:      	addq	$-0x1000, %rax          # imm = 0xF000
1188b541:      	movq	%rax, -0xb8(%rbp)
1188b548:      	leaq	-0x8(%rbx), %rax
1188b54c:      	movq	%rax, -0xb0(%rbp)
1188b553:      	movq	%fs:0x0, %rax
1188b55c:      	leaq	-0x54030(%rax), %rax
1188b563:      	movq	%rax, -0x98(%rbp)
1188b56a:      	leaq	0x2a755c2(%rip), %rax   # 0x14300b33 <anon.65d6174ee4273d212d69e4c9be928638.2838.llvm.16259376971001104057+0x653>
1188b571:      	movq	%rax, -0x90(%rbp)
1188b578:      	movq	%rbx, -0x30(%rbp)
1188b57c:      	testq	%rbx, %rbx
1188b57f:      	movq	%rbx, %r8
1188b582:      	je	0x1188b5b0 <js_object_get_field_by_name+0x170>
1188b584:      	cmpl	$0x18, 0x4(%r8)
1188b589:      	jb	0x1188b5b0 <js_object_get_field_by_name+0x170>
1188b58b:      	movq	-0x38(%rbp), %rax
1188b58f:      	cmpb	$0x23, (%rax)
1188b592:      	jne	0x1188b5b0 <js_object_get_field_by_name+0x170>
1188b594:      	movq	%r14, %rdi
1188b597:      	movq	-0x30(%rbp), %rsi
1188b59b:      	callq	0x116b6e20 <_RNvNtNtNtCscI5nJwKNRh4_13perry_runtime6object13field_get_set7ic_miss26private_member_get_by_name>
1188b5a0:      	movq	-0x30(%rbp), %r8
1188b5a4:      	testb	$0x1, %al
1188b5a6:      	jne	0x1188e2b0 <js_object_get_field_by_name+0x2e70>
1188b5ac:      	nopl	(%rax)
1188b5b0:      	movq	%r14, %rax
1188b5b3:      	movabsq	$-0x1000000000000, %rcx # imm = 0xFFFF000000000000
1188b5bd:      	andq	%rcx, %rax
1188b5c0:      	movq	%r12, %rcx
1188b5c3:      	movq	%r14, %r12
1188b5c6:      	andq	%r13, %r12
1188b5c9:      	cmpq	%rcx, %rax
1188b5cc:      	movq	%r14, %rbx
1188b5cf:      	cmoveq	%r12, %rbx
1188b5d3:      	cmpq	$0x100000, %rbx         # imm = 0x100000
1188b5da:      	jb	0x1188b650 <js_object_get_field_by_name+0x210>
1188b5dc:      	movabsq	$0x800000000000, %rax   # imm = 0x800000000000
1188b5e6:      	cmpq	%rax, %rbx
1188b5e9:      	jae	0x1188b650 <js_object_get_field_by_name+0x210>
1188b5eb:      	cmpb	$0x2, -0x8(%rbx)
1188b5ef:      	jne	0x1188b650 <js_object_get_field_by_name+0x210>
1188b5f1:      	cmpb	$0x0, -0x7(%rbx)
1188b5f5:      	js	0x1188b650 <js_object_get_field_by_name+0x210>
1188b5f7:      	movq	0x8(%rbx), %rax
1188b5fb:      	testq	%rax, %rax
1188b5fe:      	je	0x1188b650 <js_object_get_field_by_name+0x210>
1188b600:      	movq	0x60(%rax), %r15
1188b604:      	testq	%r15, %r15
1188b607:      	je	0x1188b650 <js_object_get_field_by_name+0x210>
1188b609:      	testq	%r8, %r8
1188b60c:      	je	0x1188e83d <js_object_get_field_by_name+0x33fd>
1188b612:      	movl	0x4(%r8), %edx
1188b616:      	leal	-0xb(%rdx), %eax
1188b619:      	cmpl	$-0xa, %eax
1188b61c:      	jb	0x1188b659 <js_object_get_field_by_name+0x219>
1188b61e:      	movq	-0x38(%rbp), %rax
1188b622:      	movzbl	(%rax), %eax
1188b625:      	leal	-0x30(%rax), %ecx
1188b628:      	cmpb	$0xa, %cl
1188b62b:      	setae	%cl
1188b62e:      	cmpb	$0x6c, %al
1188b630:      	setne	%al
1188b633:      	testb	%cl, %al
1188b635:      	jne	0x1188b659 <js_object_get_field_by_name+0x219>
1188b637:      	cmpl	%edx, (%r8)
1188b63a:      	jne	0x1188c44d <js_object_get_field_by_name+0x100d>
1188b640:      	movq	-0x38(%rbp), %rdi
1188b644:      	jmp	0x1188c471 <js_object_get_field_by_name+0x1031>
1188b649:      	nopl	(%rax)
1188b650:      	testq	%r8, %r8
1188b653:      	je	0x1188e83d <js_object_get_field_by_name+0x33fd>
1188b659:      	movq	-0xa0(%rbp), %rax
1188b660:      	movsd	(%rax), %xmm0
1188b664:      	xorpd	%xmm1, %xmm1
1188b668:      	ucomisd	%xmm1, %xmm0
1188b66c:      	jne	0x1188b670 <js_object_get_field_by_name+0x230>
1188b66e:      	jnp	0x1188b6c0 <js_object_get_field_by_name+0x280>
1188b670:      	movq	%xmm0, %rax
1188b675:      	movq	%rax, %rcx
1188b678:      	shrq	$0x30, %rcx
1188b67c:      	addl	$0xffff8006, %ecx       # imm = 0xFFFF8006
1188b682:      	cmpl	$0x5, %ecx
1188b685:      	ja	0x1188bb09 <js_object_get_field_by_name+0x6c9>
1188b68b:      	leaq	0x2a71176(%rip), %rdx   # 0x142fc808 <anon.65d6174ee4273d212d69e4c9be928638.11885.llvm.16259376971001104057+0x101ec>
1188b692:      	movslq	(%rdx,%rcx,4), %rcx
1188b696:      	addq	%rdx, %rcx
1188b699:      	jmpq	*%rcx
1188b69b:      	andq	%r13, %rax
1188b69e:      	cmpq	%rbx, %rax
1188b6a1:      	jne	0x1188b6c0 <js_object_get_field_by_name+0x280>
1188b6a3:      	movq	-0x30(%rbp), %rdi
1188b6a7:      	callq	*0x3a97be3(%rip)        # 0x15323290 <_GLOBAL_OFFSET_TABLE_+0xb230>
1188b6ad:      	movq	-0x30(%rbp), %r8
1188b6b1:      	testq	%rax, %rax
1188b6b4:      	jne	0x1188e470 <js_object_get_field_by_name+0x3030>
1188b6ba:      	nopw	(%rax,%rax)
1188b6c0:      	movq	%r14, %r13
1188b6c3:      	shrq	$0x30, %r13
1188b6c7:      	cmpq	$0x7ffd, %r13           # imm = 0x7FFD
1188b6ce:      	movq	%r14, %rax
1188b6d1:      	cmoveq	%r12, %rax
1188b6d5:      	andq	$-0x10000, %rax         # imm = 0xFFFF0000
1188b6db:      	cmpq	$0xf0000, %rax          # imm = 0xF0000
1188b6e1:      	jne	0x1188b70d <js_object_get_field_by_name+0x2cd>
1188b6e3:      	movabsq	$0x7ffd000000000000, %rax # imm = 0x7FFD000000000000
1188b6ed:      	addq	%r12, %rax
1188b6f0:      	movq	%rax, %xmm0
1188b6f5:      	movq	%xmm0, -0x50(%rbp)
1188b6fa:      	callq	0x11290fb0 <_RNvNtCscI5nJwKNRh4_13perry_runtime5proxy6lookup.llvm.16259376971001104057>
1188b6ff:      	movq	-0x30(%rbp), %r8
1188b703:      	cmpq	$0x1, %rax
1188b707:      	je	0x1188e104 <js_object_get_field_by_name+0x2cc4>
1188b70d:      	cmpq	$0x1000, %r8            # imm = 0x1000
1188b714:      	jb	0x1188b724 <js_object_get_field_by_name+0x2e4>
1188b716:      	movl	0x4(%r8), %eax
1188b71a:      	cmpq	$0x5, %rax
1188b71e:      	jbe	0x1188b970 <js_object_get_field_by_name+0x530>
1188b724:      	cmpq	$0x100000, %r14         # imm = 0x100000
1188b72b:      	setae	%bl
1188b72e:      	testq	%r13, %r13
1188b731:      	je	0x1188b750 <js_object_get_field_by_name+0x310>
1188b733:      	cmpl	$0x7ffd, %r13d          # imm = 0x7FFD
1188b73a:      	jne	0x1188bc40 <js_object_get_field_by_name+0x800>
1188b740:      	cmpq	$0x100000, %r12         # imm = 0x100000
1188b747:      	jae	0x1188b760 <js_object_get_field_by_name+0x320>
1188b749:      	jmp	0x1188bc40 <js_object_get_field_by_name+0x800>
1188b74e:      	nop
1188b750:      	movq	%r14, %r12
1188b753:      	cmpq	$0x100000, %r12         # imm = 0x100000
1188b75a:      	jb	0x1188bc40 <js_object_get_field_by_name+0x800>
1188b760:      	movq	%r12, %rax
1188b763:      	shrq	$0x3, %rax
1188b767:      	movabsq	$-0x61c8864680b583eb, %rcx # imm = 0x9E3779B97F4A7C15
1188b771:      	imulq	%rcx, %rax
1188b775:      	movq	%rax, %rcx
1188b778:      	shrq	$0x36, %rcx
1188b77c:      	movq	%rax, %rdx
1188b77f:      	shrq	$0x3c, %rdx
1188b783:      	leaq	0x54e9f96(%rip), %rsi   # 0x16d75720 <_RNvNtNtCscI5nJwKNRh4_13perry_runtime13native_handle9canonical28CANONICAL_HANDLE_ADDR_FILTER.llvm.16259376971001104057>
1188b78a:      	movq	(%rsi,%rdx,8), %rdx
1188b78e:      	btq	%rcx, %rdx
1188b792:      	jae	0x1188b830 <js_object_get_field_by_name+0x3f0>
1188b798:      	movq	%rax, %rcx
1188b79b:      	shrq	$0x2c, %rcx
1188b79f:      	movq	%rax, %rdx
1188b7a2:      	shrq	$0x32, %rdx
1188b7a6:      	andl	$0xf, %edx
1188b7a9:      	leaq	0x54e9f70(%rip), %rsi   # 0x16d75720 <_RNvNtNtCscI5nJwKNRh4_13perry_runtime13native_handle9canonical28CANONICAL_HANDLE_ADDR_FILTER.llvm.16259376971001104057>
1188b7b0:      	movq	(%rsi,%rdx,8), %rdx
1188b7b4:      	btq	%rcx, %rdx
1188b7b8:      	jae	0x1188b830 <js_object_get_field_by_name+0x3f0>
1188b7ba:      	movq	%rax, %rcx
1188b7bd:      	shrq	$0x22, %rcx
1188b7c1:      	shrq	$0x28, %rax
1188b7c5:      	andl	$0xf, %eax
1188b7c8:      	leaq	0x54e9f51(%rip), %rdx   # 0x16d75720 <_RNvNtNtCscI5nJwKNRh4_13perry_runtime13native_handle9canonical28CANONICAL_HANDLE_ADDR_FILTER.llvm.16259376971001104057>
1188b7cf:      	movq	(%rdx,%rax,8), %rax
1188b7d3:      	btq	%rcx, %rax
1188b7d7:      	jae	0x1188b830 <js_object_get_field_by_name+0x3f0>
1188b7d9:      	movabsq	$0x800000000000, %rax   # imm = 0x800000000000
1188b7e3:      	decq	%rax
1188b7e6:      	cmpq	%rax, %r12
1188b7e9:      	ja	0x1188b830 <js_object_get_field_by_name+0x3f0>
1188b7eb:      	leaq	-0x8(%r12), %r15
1188b7f0:      	movq	%r15, %rdi
1188b7f3:      	callq	*0x3a917df(%rip)        # 0x1531cfd8 <_GLOBAL_OFFSET_TABLE_+0x4f78>
1188b7f9:      	movq	-0x30(%rbp), %r8
1188b7fd:      	testb	%al, %al
1188b7ff:      	je	0x1188b830 <js_object_get_field_by_name+0x3f0>
1188b801:      	cmpb	$0xf, (%r15)
1188b805:      	jne	0x1188b830 <js_object_get_field_by_name+0x3f0>
1188b807:      	movabsq	$0x5045525259484e44, %rax # imm = 0x5045525259484E44
1188b811:      	cmpq	%rax, (%r12)
1188b815:      	jne	0x1188b830 <js_object_get_field_by_name+0x3f0>
1188b817:      	testb	$0x1, 0x1c(%r12)
1188b81d:      	jne	0x1188c4bd <js_object_get_field_by_name+0x107d>
1188b823:      	nopw	%cs:(%rax,%rax)
1188b830:      	cmpq	$0x100000, %r8          # imm = 0x100000
1188b837:      	jb	0x1188bc40 <js_object_get_field_by_name+0x800>
1188b83d:      	cmpq	$0x200000, %r12         # imm = 0x200000
1188b844:      	jb	0x1188bc40 <js_object_get_field_by_name+0x800>
1188b84a:      	movq	-0xf0(%rbp), %rax
1188b851:      	leaq	0x54e9ec8(%rip), %rcx   # 0x16d75720 <_RNvNtNtCscI5nJwKNRh4_13perry_runtime13native_handle9canonical28CANONICAL_HANDLE_ADDR_FILTER.llvm.16259376971001104057>
1188b858:      	movq	(%rcx,%rax,8), %rax
1188b85c:      	testq	%rax, -0xe8(%rbp)
1188b863:      	je	0x1188b900 <js_object_get_field_by_name+0x4c0>
1188b869:      	movq	-0xe0(%rbp), %rax
1188b870:      	leaq	0x54e9ea9(%rip), %rcx   # 0x16d75720 <_RNvNtNtCscI5nJwKNRh4_13perry_runtime13native_handle9canonical28CANONICAL_HANDLE_ADDR_FILTER.llvm.16259376971001104057>
1188b877:      	movq	(%rcx,%rax,8), %rax
1188b87b:      	testq	%rax, -0xd8(%rbp)
1188b882:      	je	0x1188b900 <js_object_get_field_by_name+0x4c0>
1188b884:      	movq	-0xd0(%rbp), %rax
1188b88b:      	leaq	0x54e9e8e(%rip), %rcx   # 0x16d75720 <_RNvNtNtCscI5nJwKNRh4_13perry_runtime13native_handle9canonical28CANONICAL_HANDLE_ADDR_FILTER.llvm.16259376971001104057>
1188b892:      	movq	(%rcx,%rax,8), %rax
1188b896:      	movq	-0xc8(%rbp), %rcx
1188b89d:      	shrq	%cl, %rax
1188b8a0:      	movq	-0xb8(%rbp), %rcx
1188b8a7:      	cmpq	%rcx, -0xc0(%rbp)
1188b8ae:      	jae	0x1188b900 <js_object_get_field_by_name+0x4c0>
1188b8b0:      	testb	$0x1, %al
1188b8b2:      	je	0x1188b900 <js_object_get_field_by_name+0x4c0>
1188b8b4:      	movq	-0xb0(%rbp), %rdi
1188b8bb:      	callq	*0x3a91717(%rip)        # 0x1531cfd8 <_GLOBAL_OFFSET_TABLE_+0x4f78>
1188b8c1:      	movq	-0x30(%rbp), %r8
1188b8c5:      	testb	%al, %al
1188b8c7:      	je	0x1188b900 <js_object_get_field_by_name+0x4c0>
1188b8c9:      	movq	-0xb0(%rbp), %rax
1188b8d0:      	cmpb	$0xf, (%rax)
1188b8d3:      	jne	0x1188b900 <js_object_get_field_by_name+0x4c0>
1188b8d5:      	movabsq	$0x5045525259484e44, %rax # imm = 0x5045525259484E44
1188b8df:      	cmpq	%rax, (%r8)
1188b8e2:      	jne	0x1188b900 <js_object_get_field_by_name+0x4c0>
1188b8e4:      	testb	$0x1, 0x1c(%r8)
1188b8e9:      	je	0x1188b900 <js_object_get_field_by_name+0x4c0>
1188b8eb:      	cmpb	$0x0, 0x1b(%r8)
1188b8f0:      	je	0x1188bc40 <js_object_get_field_by_name+0x800>
1188b8f6:      	nopw	%cs:(%rax,%rax)
1188b900:      	testb	$0x10, -0x7(%r8)
1188b905:      	je	0x1188bc40 <js_object_get_field_by_name+0x800>
1188b90b:      	movq	-0x80(%rbp), %rdi
1188b90f:      	cmpq	$0x0, 0x78(%rdi)
1188b914:      	je	0x1188d92b <js_object_get_field_by_name+0x24eb>
1188b91a:      	movq	%r12, %rsi
1188b91d:      	shrq	$0x14, %rsi
1188b921:      	movq	0x10(%rdi), %rax
1188b925:      	cmpb	$0x2, (%rax)
1188b928:      	jne	0x1188bb27 <js_object_get_field_by_name+0x6e7>
1188b92e:      	cmpb	$0x0, 0x88(%rax)
1188b935:      	je	0x1188bb77 <js_object_get_field_by_name+0x737>
1188b93b:      	cmpq	%rsi, 0x80(%rax)
1188b942:      	jne	0x1188bb77 <js_object_get_field_by_name+0x737>
1188b948:      	cmpq	0x60(%rax), %r12
1188b94c:      	jb	0x1188bb77 <js_object_get_field_by_name+0x737>
1188b952:      	cmpq	0x68(%rax), %r12
1188b956:      	jae	0x1188bb77 <js_object_get_field_by_name+0x737>
1188b95c:      	leaq	0x60(%rax), %rcx
1188b960:      	jmp	0x1188bbfc <js_object_get_field_by_name+0x7bc>
1188b965:      	nopw	%cs:(%rax,%rax)
1188b970:      	testq	%rax, %rax
1188b973:      	je	0x1188b9f0 <js_object_get_field_by_name+0x5b0>
1188b975:      	leaq	0x14(%r8), %rcx
1188b979:      	movsbq	(%rcx), %rsi
1188b97d:      	testq	%rsi, %rsi
1188b980:      	js	0x1188b724 <js_object_get_field_by_name+0x2e4>
1188b986:      	cmpl	$0x1, %eax
1188b989:      	je	0x1188b9f2 <js_object_get_field_by_name+0x5b2>
1188b98b:      	movsbq	0x15(%r8), %rcx
1188b990:      	testq	%rcx, %rcx
1188b993:      	js	0x1188b724 <js_object_get_field_by_name+0x2e4>
1188b999:      	shlq	$0x8, %rcx
1188b99d:      	orq	%rcx, %rsi
1188b9a0:      	cmpl	$0x2, %eax
1188b9a3:      	je	0x1188b9f2 <js_object_get_field_by_name+0x5b2>
1188b9a5:      	movsbq	0x16(%r8), %rcx
1188b9aa:      	testq	%rcx, %rcx
1188b9ad:      	js	0x1188b724 <js_object_get_field_by_name+0x2e4>
1188b9b3:      	shlq	$0x10, %rcx
1188b9b7:      	orq	%rcx, %rsi
1188b9ba:      	cmpl	$0x3, %eax
1188b9bd:      	je	0x1188b9f2 <js_object_get_field_by_name+0x5b2>
1188b9bf:      	movsbq	0x17(%r8), %rcx
1188b9c4:      	testq	%rcx, %rcx
1188b9c7:      	js	0x1188b724 <js_object_get_field_by_name+0x2e4>
1188b9cd:      	shlq	$0x18, %rcx
1188b9d1:      	orq	%rcx, %rsi
1188b9d4:      	cmpl	$0x4, %eax
1188b9d7:      	je	0x1188b9f2 <js_object_get_field_by_name+0x5b2>
1188b9d9:      	movsbq	0x18(%r8), %rcx
1188b9de:      	testq	%rcx, %rcx
1188b9e1:      	js	0x1188b724 <js_object_get_field_by_name+0x2e4>
1188b9e7:      	shlq	$0x20, %rcx
1188b9eb:      	orq	%rcx, %rsi
1188b9ee:      	jmp	0x1188b9f2 <js_object_get_field_by_name+0x5b2>
1188b9f0:      	xorl	%esi, %esi
1188b9f2:      	cmpq	$0xfffff, %r14          # imm = 0xFFFFF
1188b9f9:      	jbe	0x1188bb02 <js_object_get_field_by_name+0x6c2>
1188b9ff:      	movb	$0x1, %bl
1188ba01:      	movabsq	$0x800000000000, %rcx   # imm = 0x800000000000
1188ba0b:      	cmpq	%rcx, %r14
1188ba0e:      	jae	0x1188b72e <js_object_get_field_by_name+0x2ee>
1188ba14:      	cmpb	$0x2, -0x8(%r14)
1188ba19:      	jne	0x1188b72e <js_object_get_field_by_name+0x2ee>
1188ba1f:      	cmpb	$0x0, -0x7(%r14)
1188ba24:      	js	0x1188b72e <js_object_get_field_by_name+0x2ee>
1188ba2a:      	movzwl	-0x6(%r14), %ecx
1188ba2f:      	testl	$0x100, %ecx            # imm = 0x100
1188ba35:      	jne	0x1188b72e <js_object_get_field_by_name+0x2ee>
1188ba3b:      	shlq	$0x28, %rax
1188ba3f:      	movabsq	$0x7ff8ffffffffffff, %rdx # imm = 0x7FF8FFFFFFFFFFFF
1188ba49:      	incq	%rdx
1188ba4c:      	orq	%rdx, %rsi
1188ba4f:      	orq	%rax, %rsi
1188ba52:      	testl	$0x800, %ecx            # imm = 0x800
1188ba58:      	jne	0x1188d841 <js_object_get_field_by_name+0x2401>
1188ba5e:      	movl	(%r14), %eax
1188ba61:      	testl	%eax, %eax
1188ba63:      	je	0x1188d841 <js_object_get_field_by_name+0x2401>
1188ba69:      	cmpl	$-0x2, %eax
1188ba6c:      	je	0x1188d841 <js_object_get_field_by_name+0x2401>
1188ba72:      	movl	0x4(%r14), %edi
1188ba76:      	cmpl	$0xbfffffff, %edi       # imm = 0xBFFFFFFF
1188ba7c:      	jg	0x1188d841 <js_object_get_field_by_name+0x2401>
1188ba82:      	movl	0x3ac75f7(%rip), %r15d  # 0x15353080 <_RNvNvNtNtCscI5nJwKNRh4_13perry_runtime6object9read_stub9READ_STUB4SLOT+0x10>
1188ba89:      	cmpl	$0x300, %r15d           # imm = 0x300
1188ba90:      	movq	-0x80(%rbp), %rax
1188ba94:      	jae	0x1188da05 <js_object_get_field_by_name+0x25c5>
1188ba9a:      	cmpq	$0x0, 0x78(%rax)
1188ba9f:      	je	0x1188d9d7 <js_object_get_field_by_name+0x2597>
1188baa5:      	movq	0x1e8(%rax,%r15,8), %rdx
1188baad:      	testq	%rdx, %rdx
1188bab0:      	je	0x1188da05 <js_object_get_field_by_name+0x25c5>
1188bab6:      	movabsq	$0x4000000000000000, %rax # imm = 0x4000000000000000
1188bac0:      	orq	%rax, %rdi
1188bac3:      	movq	%rsi, %r15
1188bac6:      	callq	0x11143a60 <_RNCNvNtNtCscI5nJwKNRh4_13perry_runtime6object9read_stub15read_stub_probe0B7_>
1188bacb:      	movq	%r15, %rsi
1188bace:      	cmpl	$0x1, %eax
1188bad1:      	jne	0x1188d841 <js_object_get_field_by_name+0x2401>
1188bad7:      	testl	$0x40000000, %edx       # imm = 0x40000000
1188badd:      	jne	0x1188d811 <js_object_get_field_by_name+0x23d1>
1188bae3:      	movl	%edx, %eax
1188bae5:      	movq	0x10(%r14,%rax,8), %rax
1188baea:      	movabsq	$0x7ffc000000000010, %rcx # imm = 0x7FFC000000000010
1188baf4:      	cmpq	%rcx, %rax
1188baf7:      	je	0x1188d841 <js_object_get_field_by_name+0x2401>
1188bafd:      	jmp	0x1188ed4d <js_object_get_field_by_name+0x390d>
1188bb02:      	xorl	%ebx, %ebx
1188bb04:      	jmp	0x1188b72e <js_object_get_field_by_name+0x2ee>
1188bb09:      	leaq	-0x1(%rax), %rcx
1188bb0d:      	cmpq	%r13, %rcx
1188bb10:      	movl	$0x0, %ecx
1188bb15:      	cmovaeq	%rcx, %rax
1188bb19:      	cmpq	%rbx, %rax
1188bb1c:      	je	0x1188b6a3 <js_object_get_field_by_name+0x263>
1188bb22:      	jmp	0x1188b6c0 <js_object_get_field_by_name+0x280>
1188bb27:      	movq	%rsi, %rcx
1188bb2a:      	subq	0x8(%rax), %rcx
1188bb2e:      	cmpq	0x28(%rax), %rcx
1188bb32:      	jae	0x1188bc11 <js_object_get_field_by_name+0x7d1>
1188bb38:      	movq	0x20(%rax), %rdx
1188bb3c:      	leaq	(%rcx,%rcx,4), %rcx
1188bb40:      	movq	(%rdx,%rcx,8), %rdi
1188bb44:      	cmpq	0x10(%rax), %rdi
1188bb48:      	movq	-0x30(%rbp), %r8
1188bb4c:      	jne	0x1188bc15 <js_object_get_field_by_name+0x7d5>
1188bb52:      	leaq	(%rdx,%rcx,8), %rcx
1188bb56:      	cmpq	0x8(%rcx), %r12
1188bb5a:      	jb	0x1188bc15 <js_object_get_field_by_name+0x7d5>
1188bb60:      	cmpq	0x10(%rcx), %r12
1188bb64:      	jae	0x1188bc15 <js_object_get_field_by_name+0x7d5>
1188bb6a:      	incq	0x30(%rax)
1188bb6e:      	addq	$0x21, %rcx
1188bb72:      	jmp	0x1188bc04 <js_object_get_field_by_name+0x7c4>
1188bb77:      	cmpb	$0x1, 0xb8(%rax)
1188bb7e:      	jne	0x1188bba4 <js_object_get_field_by_name+0x764>
1188bb80:      	cmpq	%rsi, 0xb0(%rax)
1188bb87:      	jne	0x1188bba4 <js_object_get_field_by_name+0x764>
1188bb89:      	cmpq	0x90(%rax), %r12
1188bb90:      	jb	0x1188bba4 <js_object_get_field_by_name+0x764>
1188bb92:      	cmpq	0x98(%rax), %r12
1188bb99:      	jae	0x1188bba4 <js_object_get_field_by_name+0x764>
1188bb9b:      	leaq	0x90(%rax), %rcx
1188bba2:      	jmp	0x1188bbfc <js_object_get_field_by_name+0x7bc>
1188bba4:      	cmpb	$0x1, 0xe8(%rax)
1188bbab:      	jne	0x1188bbd1 <js_object_get_field_by_name+0x791>
1188bbad:      	cmpq	%rsi, 0xe0(%rax)
1188bbb4:      	jne	0x1188bbd1 <js_object_get_field_by_name+0x791>
1188bbb6:      	cmpq	0xc0(%rax), %r12
1188bbbd:      	jb	0x1188bbd1 <js_object_get_field_by_name+0x791>
1188bbbf:      	cmpq	0xc8(%rax), %r12
1188bbc6:      	jae	0x1188bbd1 <js_object_get_field_by_name+0x791>
1188bbc8:      	leaq	0xc0(%rax), %rcx
1188bbcf:      	jmp	0x1188bbfc <js_object_get_field_by_name+0x7bc>
1188bbd1:      	cmpb	$0x1, 0x118(%rax)
1188bbd8:      	jne	0x1188bc15 <js_object_get_field_by_name+0x7d5>
1188bbda:      	cmpq	%rsi, 0x110(%rax)
1188bbe1:      	jne	0x1188bc15 <js_object_get_field_by_name+0x7d5>
1188bbe3:      	cmpq	0xf0(%rax), %r12
1188bbea:      	jb	0x1188bc15 <js_object_get_field_by_name+0x7d5>
1188bbec:      	cmpq	0xf8(%rax), %r12
1188bbf3:      	jae	0x1188bc15 <js_object_get_field_by_name+0x7d5>
1188bbf5:      	leaq	0xf0(%rax), %rcx
1188bbfc:      	incq	0x30(%rax)
1188bc00:      	addq	$0x19, %rcx
1188bc04:      	movzbl	(%rcx), %eax
1188bc07:      	cmpb	$-0x1, %al
1188bc09:      	je	0x1188bc19 <js_object_get_field_by_name+0x7d9>
1188bc0b:      	testb	%al, %al
1188bc0d:      	jne	0x1188bc2a <js_object_get_field_by_name+0x7ea>
1188bc0f:      	jmp	0x1188bc40 <js_object_get_field_by_name+0x800>
1188bc11:      	incq	0x58(%rax)
1188bc15:      	incq	0x38(%rax)
1188bc19:      	movq	%r12, %rdi
1188bc1c:      	callq	*0x3a8e736(%rip)        # 0x1531a358 <_GLOBAL_OFFSET_TABLE_+0x22f8>
1188bc22:      	movq	-0x30(%rbp), %r8
1188bc26:      	testb	%al, %al
1188bc28:      	je	0x1188bc40 <js_object_get_field_by_name+0x800>
1188bc2a:      	cmpb	$0x2, -0x8(%r12)
1188bc30:      	jne	0x1188bc40 <js_object_get_field_by_name+0x800>
1188bc32:      	testb	$0x9, -0x5(%r12)
1188bc38:      	je	0x1188c231 <js_object_get_field_by_name+0xdf1>
1188bc3e:      	nop
1188bc40:      	testq	%r13, %r13
1188bc43:      	sete	%al
1188bc46:      	testb	%bl, %al
1188bc48:      	je	0x1188c080 <js_object_get_field_by_name+0xc40>
1188bc4e:      	movq	%r14, %r12
1188bc51:      	shrq	$0x3, %r12
1188bc55:      	movabsq	$-0x61c8864680b583eb, %rax # imm = 0x9E3779B97F4A7C15
1188bc5f:      	imulq	%rax, %r12
1188bc63:      	movq	%r12, %rbx
1188bc66:      	shrq	$0x22, %rbx
1188bc6a:      	movq	%r12, %rcx
1188bc6d:      	shrq	$0x36, %rcx
1188bc71:      	movq	%r12, %r13
1188bc74:      	shrq	$0x3c, %r13
1188bc78:      	leaq	0x54e9aa1(%rip), %rax   # 0x16d75720 <_RNvNtNtCscI5nJwKNRh4_13perry_runtime13native_handle9canonical28CANONICAL_HANDLE_ADDR_FILTER.llvm.16259376971001104057>
1188bc7f:      	movq	(%rax,%r13,8), %rax
1188bc83:      	movl	$0x1, %r15d
1188bc89:      	shlq	%cl, %r15
1188bc8c:      	btq	%rcx, %rax
1188bc90:      	jae	0x1188bd20 <js_object_get_field_by_name+0x8e0>
1188bc96:      	movq	%r12, %rax
1188bc99:      	shrq	$0x2c, %rax
1188bc9d:      	movq	%r12, %rcx
1188bca0:      	shrq	$0x32, %rcx
1188bca4:      	andl	$0xf, %ecx
1188bca7:      	leaq	0x54e9a72(%rip), %rdx   # 0x16d75720 <_RNvNtNtCscI5nJwKNRh4_13perry_runtime13native_handle9canonical28CANONICAL_HANDLE_ADDR_FILTER.llvm.16259376971001104057>
1188bcae:      	movq	(%rdx,%rcx,8), %rcx
1188bcb2:      	btq	%rax, %rcx
1188bcb6:      	jae	0x1188bd20 <js_object_get_field_by_name+0x8e0>
1188bcb8:      	movq	%r12, %rax
1188bcbb:      	shrq	$0x28, %rax
1188bcbf:      	andl	$0xf, %eax
1188bcc2:      	leaq	0x54e9a57(%rip), %rcx   # 0x16d75720 <_RNvNtNtCscI5nJwKNRh4_13perry_runtime13native_handle9canonical28CANONICAL_HANDLE_ADDR_FILTER.llvm.16259376971001104057>
1188bcc9:      	movq	(%rcx,%rax,8), %rax
1188bccd:      	movl	%ebx, %ecx
1188bccf:      	shrq	%cl, %rax
1188bcd2:      	leaq	-0x1000(%r14), %rcx
1188bcd9:      	cmpq	-0xb8(%rbp), %rcx
1188bce0:      	jae	0x1188bd20 <js_object_get_field_by_name+0x8e0>
1188bce2:      	testb	$0x1, %al
1188bce4:      	je	0x1188bd20 <js_object_get_field_by_name+0x8e0>
1188bce6:      	leaq	-0x8(%r14), %rdi
1188bcea:      	callq	*0x3a912e8(%rip)        # 0x1531cfd8 <_GLOBAL_OFFSET_TABLE_+0x4f78>
1188bcf0:      	movq	-0x30(%rbp), %r8
1188bcf4:      	testb	%al, %al
1188bcf6:      	je	0x1188bd20 <js_object_get_field_by_name+0x8e0>
1188bcf8:      	leaq	-0x8(%r14), %rax
1188bcfc:      	cmpb	$0xf, (%rax)
1188bcff:      	jne	0x1188bd20 <js_object_get_field_by_name+0x8e0>
1188bd01:      	movabsq	$0x5045525259484e44, %rax # imm = 0x5045525259484E44
1188bd0b:      	cmpq	%rax, (%r14)
1188bd0e:      	jne	0x1188bd20 <js_object_get_field_by_name+0x8e0>
1188bd10:      	testb	$0x1, 0x1c(%r14)
1188bd15:      	je	0x1188bd20 <js_object_get_field_by_name+0x8e0>
1188bd17:      	cmpb	$0x0, 0x1b(%r14)
1188bd1c:      	je	0x1188bd40 <js_object_get_field_by_name+0x900>
1188bd1e:      	nop
1188bd20:      	cmpq	$0x1000, %r14           # imm = 0x1000
1188bd27:      	jb	0x1188e83d <js_object_get_field_by_name+0x33fd>
1188bd2d:      	movabsq	$0x800000000000, %rax   # imm = 0x800000000000
1188bd37:      	cmpq	%rax, %r14
1188bd3a:      	jae	0x1188e83d <js_object_get_field_by_name+0x33fd>
1188bd40:      	leaq	0x54e99d9(%rip), %rax   # 0x16d75720 <_RNvNtNtCscI5nJwKNRh4_13perry_runtime13native_handle9canonical28CANONICAL_HANDLE_ADDR_FILTER.llvm.16259376971001104057>
1188bd47:      	movq	(%rax,%r13,8), %rax
1188bd4b:      	testq	%r15, %rax
1188bd4e:      	je	0x1188bdd0 <js_object_get_field_by_name+0x990>
1188bd54:      	movq	%r12, %rax
1188bd57:      	shrq	$0x2c, %rax
1188bd5b:      	movq	%r12, %rcx
1188bd5e:      	shrq	$0x32, %rcx
1188bd62:      	andl	$0xf, %ecx
1188bd65:      	leaq	0x54e99b4(%rip), %rdx   # 0x16d75720 <_RNvNtNtCscI5nJwKNRh4_13perry_runtime13native_handle9canonical28CANONICAL_HANDLE_ADDR_FILTER.llvm.16259376971001104057>
1188bd6c:      	movq	(%rdx,%rcx,8), %rcx
1188bd70:      	btq	%rax, %rcx
1188bd74:      	jae	0x1188bdd0 <js_object_get_field_by_name+0x990>
1188bd76:      	shrq	$0x28, %r12
1188bd7a:      	andl	$0xf, %r12d
1188bd7e:      	leaq	0x54e999b(%rip), %rax   # 0x16d75720 <_RNvNtNtCscI5nJwKNRh4_13perry_runtime13native_handle9canonical28CANONICAL_HANDLE_ADDR_FILTER.llvm.16259376971001104057>
1188bd85:      	movq	(%rax,%r12,8), %rax
1188bd89:      	btq	%rbx, %rax
1188bd8d:      	jae	0x1188bdd0 <js_object_get_field_by_name+0x990>
1188bd8f:      	leaq	-0x8(%r14), %rbx
1188bd93:      	movq	%rbx, %rdi
1188bd96:      	callq	*0x3a9123c(%rip)        # 0x1531cfd8 <_GLOBAL_OFFSET_TABLE_+0x4f78>
1188bd9c:      	movq	-0x30(%rbp), %r8
1188bda0:      	testb	%al, %al
1188bda2:      	je	0x1188bdd0 <js_object_get_field_by_name+0x990>
1188bda4:      	cmpb	$0xf, (%rbx)
1188bda7:      	jne	0x1188bdd0 <js_object_get_field_by_name+0x990>
1188bda9:      	movabsq	$0x5045525259484e44, %rax # imm = 0x5045525259484E44
1188bdb3:      	cmpq	%rax, (%r14)
1188bdb6:      	jne	0x1188bdd0 <js_object_get_field_by_name+0x990>
1188bdb8:      	testb	$0x1, 0x1c(%r14)
1188bdbd:      	je	0x1188bdd0 <js_object_get_field_by_name+0x990>
1188bdbf:      	cmpb	$0x0, 0x1b(%r14)
1188bdc4:      	je	0x1188c080 <js_object_get_field_by_name+0xc40>
1188bdca:      	nopw	(%rax,%rax)
1188bdd0:      	cmpl	$0x4, 0x4(%r8)
1188bdd5:      	jne	0x1188c080 <js_object_get_field_by_name+0xc40>
1188bddb:      	leaq	0x14(%r8), %rax
1188bddf:      	cmpl	$0x657a6973, (%rax)     # imm = 0x657A6973
1188bde5:      	jne	0x1188c080 <js_object_get_field_by_name+0xc40>
1188bdeb:      	movq	-0x98(%rbp), %rbx
1188bdf2:      	movzbl	0x20(%rbx), %eax
1188bdf6:      	testl	%eax, %eax
1188bdf8:      	jne	0x1188d93e <js_object_get_field_by_name+0x24fe>
1188bdfe:      	movq	(%rbx), %rax
1188be01:      	movabsq	$0x7fffffffffffffff, %rcx # imm = 0x7FFFFFFFFFFFFFFF
1188be0b:      	cmpq	%rcx, %rax
1188be0e:      	jae	0x1188ed26 <js_object_get_field_by_name+0x38e6>
1188be14:      	movq	0x18(%rbx), %r12
1188be18:      	testq	%r14, %r14
1188be1b:      	je	0x1188be41 <js_object_get_field_by_name+0xa01>
1188be1d:      	leaq	0x54e8918(%rip), %rcx   # 0x16d7473c <PERRY_INCREMENTAL_MARK_BARRIER_ACTIVE_COUNT>
1188be24:      	movl	(%rcx), %ecx
1188be26:      	testl	%ecx, %ecx
1188be28:      	je	0x1188be41 <js_object_get_field_by_name+0xa01>
1188be2a:      	movabsq	$0x7ffd000000000000, %rax # imm = 0x7FFD000000000000
1188be34:      	leaq	(%r14,%rax), %rdi
1188be38:      	callq	*0x3a9edf2(%rip)        # 0x1532ac30 <_GLOBAL_OFFSET_TABLE_+0x12bd0>
1188be3e:      	movq	(%rbx), %rax
1188be41:      	testq	%rax, %rax
1188be44:      	jne	0x1188ed33 <js_object_get_field_by_name+0x38f3>
1188be4a:      	movq	$-0x1, (%rbx)
1188be51:      	movq	0x18(%rbx), %r15
1188be55:      	cmpq	0x8(%rbx), %r15
1188be59:      	je	0x1188c3d5 <js_object_get_field_by_name+0xf95>
1188be5f:      	movq	0x10(%rbx), %rax
1188be63:      	leaq	(%r15,%r15,2), %r13
1188be67:      	movq	$0x1, (%rax,%r13,8)
1188be6f:      	movq	%r14, 0x8(%rax,%r13,8)
1188be74:      	movabsq	$0x7ffd000000000000, %rcx # imm = 0x7FFD000000000000
1188be7e:      	movq	%rcx, 0x10(%rax,%r13,8)
1188be83:      	leaq	0x1(%r15), %rax
1188be87:      	movq	%rax, 0x18(%rbx)
1188be8b:      	incq	(%rbx)
1188be8e:      	movq	%r14, %rdi
1188be91:      	movq	-0x30(%rbp), %rsi
1188be95:      	callq	0x1167fd60 <_RNvNtNtNtCscI5nJwKNRh4_13perry_runtime6object10object_ops10keys_array15own_key_present>
1188be9a:      	movq	(%rbx), %rcx
1188be9d:      	movabsq	$0x7fffffffffffffff, %rdx # imm = 0x7FFFFFFFFFFFFFFF
1188bea7:      	cmpq	%rdx, %rcx
1188beaa:      	jae	0x1188eb5e <js_object_get_field_by_name+0x371e>
1188beb0:      	leaq	0x1(%rcx), %rsi
1188beb4:      	movq	%rsi, (%rbx)
1188beb7:      	movq	0x18(%rbx), %rdx
1188bebb:      	cmpq	%rdx, %r15
1188bebe:      	jae	0x1188eb6b <js_object_get_field_by_name+0x372b>
1188bec4:      	movq	0x10(%rbx), %rdi
1188bec8:      	cmpq	$0x1, (%rdi,%r13,8)
1188becd:      	jne	0x1188eb71 <js_object_get_field_by_name+0x3731>
1188bed3:      	leaq	(%rdi,%r13,8), %rdi
1188bed7:      	movq	0x8(%rdi), %rdi
1188bedb:      	movq	%rcx, (%rbx)
1188bede:      	testb	%al, %al
1188bee0:      	jne	0x1188c03b <js_object_get_field_by_name+0xbfb>
1188bee6:      	callq	*0x3a9eb14(%rip)        # 0x1532aa00 <_GLOBAL_OFFSET_TABLE_+0x129a0>
1188beec:      	testl	%eax, %eax
1188beee:      	je	0x1188bf0b <js_object_get_field_by_name+0xacb>
1188bef0:      	movl	$0x4, %edx
1188bef5:      	movl	%eax, %edi
1188bef7:      	leaq	0x2a605be(%rip), %rsi   # 0x142ec4bc <anon.65d6174ee4273d212d69e4c9be928638.6575.llvm.16259376971001104057+0x84>
1188befe:      	callq	0x11520e20 <_RNvNtNtCscI5nJwKNRh4_13perry_runtime6object13native_module25class_instance_has_member>
1188bf03:      	testb	%al, %al
1188bf05:      	jne	0x1188c016 <js_object_get_field_by_name+0xbd6>
1188bf0b:      	movq	-0x98(%rbp), %rbx
1188bf12:      	movq	(%rbx), %rcx
1188bf15:      	movabsq	$0x7fffffffffffffff, %rax # imm = 0x7FFFFFFFFFFFFFFF
1188bf1f:      	cmpq	%rax, %rcx
1188bf22:      	jae	0x1188eb5e <js_object_get_field_by_name+0x371e>
1188bf28:      	leaq	0x1(%rcx), %rsi
1188bf2c:      	movq	%rsi, (%rbx)
1188bf2f:      	movq	0x18(%rbx), %rdx
1188bf33:      	cmpq	%rdx, %r15
1188bf36:      	jae	0x1188eb6b <js_object_get_field_by_name+0x372b>
1188bf3c:      	movq	0x10(%rbx), %rax
1188bf40:      	cmpq	$0x1, (%rax,%r13,8)
1188bf45:      	jne	0x1188eb71 <js_object_get_field_by_name+0x3731>
1188bf4b:      	leaq	(%rax,%r13,8), %rax
1188bf4f:      	movq	0x8(%rax), %rax
1188bf53:      	movq	%rcx, (%rbx)
1188bf56:      	movzbl	0x556a073(%rip), %edi   # 0x16df5fd0 <_RNvNtNtCscI5nJwKNRh4_13perry_runtime6object16map_set_subclass21MAP_SET_SUBCLASS_EVER.0.llvm.16259376971001104057>
1188bf5d:      	testb	%dil, %dil
1188bf60:      	je	0x1188c03b <js_object_get_field_by_name+0xbfb>
1188bf66:      	movabsq	$0xffffffffffff, %rcx   # imm = 0xFFFFFFFFFFFF
1188bf70:      	andq	%rcx, %rax
1188bf73:      	movabsq	$0x7ffd000000000000, %rcx # imm = 0x7FFD000000000000
1188bf7d:      	orq	%rcx, %rax
1188bf80:      	movq	%rax, %xmm0
1188bf85:      	callq	0x11543ae0 <_RNvNtNtCscI5nJwKNRh4_13perry_runtime6object16map_set_subclass19instance_object_ptr.llvm.16259376971001104057>
1188bf8a:      	cmpq	$0x1, %rax
1188bf8e:      	jne	0x1188c016 <js_object_get_field_by_name+0xbd6>
1188bf94:      	movq	%rdx, %rbx
1188bf97:      	leaq	0x2ab4003(%rip), %rdi   # 0x1433ffa1 <anon.65d6174ee4273d212d69e4c9be928638.10935.llvm.16259376971001104057>
1188bf9e:      	movl	$0x1c, %esi
1188bfa3:      	movl	$0x1c, %edx
1188bfa8:      	callq	*0x3a912e2(%rip)        # 0x1531d290 <_GLOBAL_OFFSET_TABLE_+0x5230>
1188bfae:      	movq	%rbx, %rdi
1188bfb1:      	movq	%rax, %rsi
1188bfb4:      	callq	*0x3aa5f06(%rip)        # 0x15331ec0 <_GLOBAL_OFFSET_TABLE_+0x19e60>
1188bfba:      	movq	%xmm0, %rbx
1188bfbf:      	movq	%rbx, %rax
1188bfc2:      	movabsq	$-0x1000000000000, %rcx # imm = 0xFFFF000000000000
1188bfcc:      	andq	%rcx, %rax
1188bfcf:      	movabsq	$0x7ffd000000000000, %rcx # imm = 0x7FFD000000000000
1188bfd9:      	cmpq	%rcx, %rax
1188bfdc:      	jne	0x1188c016 <js_object_get_field_by_name+0xbd6>
1188bfde:      	movabsq	$0xffffffffffff, %rax   # imm = 0xFFFFFFFFFFFF
1188bfe8:      	andq	%rax, %rbx
1188bfeb:      	cmpq	$0x1008, %rbx           # imm = 0x1008
1188bff2:      	jb	0x1188c016 <js_object_get_field_by_name+0xbd6>
1188bff4:      	movq	%rbx, %rdi
1188bff7:      	callq	*0x3a9dbc3(%rip)        # 0x15329bc0 <_GLOBAL_OFFSET_TABLE_+0x11b60>
1188bffd:      	testb	%al, %al
1188bfff:      	jne	0x1188ec92 <js_object_get_field_by_name+0x3852>
1188c005:      	movq	%rbx, %rdi
1188c008:      	callq	*0x3a8d3e2(%rip)        # 0x153193f0 <_GLOBAL_OFFSET_TABLE_+0x1390>
1188c00e:      	testb	%al, %al
1188c010:      	jne	0x1188ec9d <js_object_get_field_by_name+0x385d>
1188c016:      	movq	-0x98(%rbp), %rbx
1188c01d:      	movq	(%rbx), %rcx
1188c020:      	movabsq	$0x7fffffffffffffff, %rax # imm = 0x7FFFFFFFFFFFFFFF
1188c02a:      	cmpq	%rax, %rcx
1188c02d:      	jae	0x1188eb5e <js_object_get_field_by_name+0x371e>
1188c033:      	movq	0x18(%rbx), %rdx
1188c037:      	leaq	0x1(%rcx), %rsi
1188c03b:      	movq	%rsi, (%rbx)
1188c03e:      	cmpq	%rdx, %r15
1188c041:      	jae	0x1188eb6b <js_object_get_field_by_name+0x372b>
1188c047:      	movq	0x10(%rbx), %rax
1188c04b:      	cmpq	$0x1, (%rax,%r13,8)
1188c050:      	jne	0x1188eb71 <js_object_get_field_by_name+0x3731>
1188c056:      	leaq	(%rax,%r13,8), %rax
1188c05a:      	movq	0x8(%rax), %r14
1188c05e:      	movq	%rcx, (%rbx)
1188c061:      	testq	%rcx, %rcx
1188c064:      	jne	0x1188ed40 <js_object_get_field_by_name+0x3900>
1188c06a:      	cmpq	%rdx, %r12
1188c06d:      	ja	0x1188c080 <js_object_get_field_by_name+0xc40>
1188c06f:      	movq	%r12, 0x18(%rbx)
1188c073:      	nopw	%cs:(%rax,%rax)
1188c080:      	movq	%r14, %r15
1188c083:      	shrq	$0x30, %r15
1188c087:      	cmpq	$0x100000, %r14         # imm = 0x100000
1188c08e:      	movq	%r15, -0x78(%rbp)
1188c092:      	jb	0x1188ca21 <js_object_get_field_by_name+0x15e1>
1188c098:      	testq	%r15, %r15
1188c09b:      	jne	0x1188ca21 <js_object_get_field_by_name+0x15e1>
1188c0a1:      	movq	%r14, %r13
1188c0a4:      	shrq	$0x3, %r13
1188c0a8:      	movabsq	$-0x61c8864680b583eb, %rax # imm = 0x9E3779B97F4A7C15
1188c0b2:      	imulq	%rax, %r13
1188c0b6:      	movq	%r13, %rax
1188c0b9:      	shrq	$0x22, %rax
1188c0bd:      	movq	%rax, -0x70(%rbp)
1188c0c1:      	movq	%r13, %rcx
1188c0c4:      	shrq	$0x36, %rcx
1188c0c8:      	movq	%r13, %r12
1188c0cb:      	shrq	$0x3c, %r12
1188c0cf:      	leaq	0x54e964a(%rip), %rax   # 0x16d75720 <_RNvNtNtCscI5nJwKNRh4_13perry_runtime13native_handle9canonical28CANONICAL_HANDLE_ADDR_FILTER.llvm.16259376971001104057>
1188c0d6:      	movq	(%rax,%r12,8), %rax
1188c0da:      	movl	$0x1, %edx
1188c0df:      	shlq	%cl, %rdx
1188c0e2:      	movq	%rdx, -0x50(%rbp)
1188c0e6:      	btq	%rcx, %rax
1188c0ea:      	jae	0x1188c190 <js_object_get_field_by_name+0xd50>
1188c0f0:      	movq	%r13, %rax
1188c0f3:      	shrq	$0x2c, %rax
1188c0f7:      	movq	%r13, %rcx
1188c0fa:      	shrq	$0x32, %rcx
1188c0fe:      	andl	$0xf, %ecx
1188c101:      	leaq	0x54e9618(%rip), %rdx   # 0x16d75720 <_RNvNtNtCscI5nJwKNRh4_13perry_runtime13native_handle9canonical28CANONICAL_HANDLE_ADDR_FILTER.llvm.16259376971001104057>
1188c108:      	movq	(%rdx,%rcx,8), %rcx
1188c10c:      	btq	%rax, %rcx
1188c110:      	jae	0x1188c190 <js_object_get_field_by_name+0xd50>
1188c112:      	movq	%r13, %rax
1188c115:      	shrq	$0x28, %rax
1188c119:      	andl	$0xf, %eax
1188c11c:      	leaq	0x54e95fd(%rip), %rcx   # 0x16d75720 <_RNvNtNtCscI5nJwKNRh4_13perry_runtime13native_handle9canonical28CANONICAL_HANDLE_ADDR_FILTER.llvm.16259376971001104057>
1188c123:      	movq	(%rcx,%rax,8), %rax
1188c127:      	movq	-0x70(%rbp), %rcx
1188c12b:      	shrq	%cl, %rax
1188c12e:      	testq	%r14, %r14
1188c131:      	je	0x1188c190 <js_object_get_field_by_name+0xd50>
1188c133:      	testb	$0x1, %al
1188c135:      	je	0x1188c190 <js_object_get_field_by_name+0xd50>
1188c137:      	movabsq	$-0x800000000000, %rcx  # imm = 0xFFFF800000000000
1188c141:      	leaq	(%r14,%rcx), %rax
1188c145:      	addq	$0x1000, %rcx           # imm = 0x1000
1188c14c:      	cmpq	%rcx, %rax
1188c14f:      	jb	0x1188c190 <js_object_get_field_by_name+0xd50>
1188c151:      	leaq	-0x8(%r14), %rbx
1188c155:      	movq	%rbx, %rdi
1188c158:      	callq	*0x3a90e7a(%rip)        # 0x1531cfd8 <_GLOBAL_OFFSET_TABLE_+0x4f78>
1188c15e:      	testb	%al, %al
1188c160:      	je	0x1188c190 <js_object_get_field_by_name+0xd50>
1188c162:      	cmpb	$0xf, (%rbx)
1188c165:      	jne	0x1188c190 <js_object_get_field_by_name+0xd50>
1188c167:      	movabsq	$0x5045525259484e44, %rax # imm = 0x5045525259484E44
1188c171:      	cmpq	%rax, (%r14)
1188c174:      	jne	0x1188c190 <js_object_get_field_by_name+0xd50>
1188c176:      	testb	$0x1, 0x1c(%r14)
1188c17b:      	je	0x1188c190 <js_object_get_field_by_name+0xd50>
1188c17d:      	cmpb	$0x0, 0x1b(%r14)
1188c182:      	je	0x1188c580 <js_object_get_field_by_name+0x1140>
1188c188:      	nopl	(%rax,%rax)
1188c190:      	movq	%r14, %rax
1188c193:      	movabsq	$0xffffffffffff, %rcx   # imm = 0xFFFFFFFFFFFF
1188c19d:      	andq	%rcx, %rax
1188c1a0:      	cmpq	$0x100000, %rax         # imm = 0x100000
1188c1a6:      	jb	0x1188c580 <js_object_get_field_by_name+0x1140>
1188c1ac:      	movabsq	$0x800000000000, %rcx   # imm = 0x800000000000
1188c1b6:      	cmpq	%rcx, %rax
1188c1b9:      	jae	0x1188c580 <js_object_get_field_by_name+0x1140>
1188c1bf:      	cmpb	$0x2, -0x8(%rax)
1188c1c3:      	jne	0x1188c580 <js_object_get_field_by_name+0x1140>
1188c1c9:      	movl	(%rax), %edx
1188c1cb:      	leal	0xffd9(%rdx), %eax
1188c1d1:      	cmpl	$0x4, %eax
1188c1d4:      	jae	0x1188c1fa <js_object_get_field_by_name+0xdba>
1188c1d6:      	cmpl	$0xffff0028, %edx       # imm = 0xFFFF0028
1188c1dc:      	ja	0x1188c580 <js_object_get_field_by_name+0x1140>
1188c1e2:      	movq	-0x30(%rbp), %rcx
1188c1e6:      	movl	0x4(%rcx), %ebx
1188c1e9:      	cmpl	$0xffff0027, %edx       # imm = 0xFFFF0027
1188c1ef:      	je	0x1188c2fe <js_object_get_field_by_name+0xebe>
1188c1f5:      	jmp	0x1188c36d <js_object_get_field_by_name+0xf2d>
1188c1fa:      	movl	$0x40, %ebx
1188c1ff:      	nop
1188c200:      	movl	%edx, %edi
1188c202:      	callq	0x11552cb0 <_RNvNtNtCscI5nJwKNRh4_13perry_runtime6object19class_meta_registry19get_parent_class_id.llvm.16259376971001104057>
1188c207:      	cmpl	$0x1, %eax
1188c20a:      	jne	0x1188c580 <js_object_get_field_by_name+0x1140>
1188c210:      	cmpl	$0xffff002c, %edx       # imm = 0xFFFF002C
1188c216:      	je	0x1188c2f7 <js_object_get_field_by_name+0xeb7>
1188c21c:      	cmpl	$0xffff002d, %edx       # imm = 0xFFFF002D
1188c222:      	je	0x1188c366 <js_object_get_field_by_name+0xf26>
1188c228:      	decl	%ebx
1188c22a:      	jne	0x1188c200 <js_object_get_field_by_name+0xdc0>
1188c22c:      	jmp	0x1188c580 <js_object_get_field_by_name+0x1140>
1188c231:      	movl	(%r12), %eax
1188c235:      	cmpl	$-0x2, %eax
1188c238:      	je	0x1188bc40 <js_object_get_field_by_name+0x800>
1188c23e:      	testl	%eax, %eax
1188c240:      	je	0x1188bc40 <js_object_get_field_by_name+0x800>
1188c246:      	movq	%r12, %rdi
1188c249:      	callq	0x1129fed0 <_RNvNtCscI5nJwKNRh4_13perry_runtime6object17object_keys_array>
1188c24e:      	movq	-0x30(%rbp), %r8
1188c252:      	movq	%rax, %r15
1188c255:      	movabsq	$0xffffffffffff, %rax   # imm = 0xFFFFFFFFFFFF
1188c25f:      	incq	%rax
1188c262:      	cmpq	%rax, %r15
1188c265:      	setae	%al
1188c268:      	cmpq	$0x100000, %r15         # imm = 0x100000
1188c26f:      	setb	%cl
1188c272:      	orb	%al, %cl
1188c274:      	jne	0x1188bc40 <js_object_get_field_by_name+0x800>
1188c27a:      	movq	%r15, %rdi
1188c27d:      	callq	*0x3a97c15(%rip)        # 0x15323e98 <_GLOBAL_OFFSET_TABLE_+0xbe38>
1188c283:      	movq	-0x30(%rbp), %r8
1188c287:      	testb	%al, %al
1188c289:      	jne	0x1188bc40 <js_object_get_field_by_name+0x800>
1188c28f:      	movq	%r12, %rdi
1188c292:      	callq	0x115169e0 <_RNvNtNtCscI5nJwKNRh4_13perry_runtime6object10live_slots22object_live_slot_count>
1188c297:      	movl	%eax, -0x50(%rbp)
1188c29a:      	movq	%r15, %rdi
1188c29d:      	movq	-0x30(%rbp), %rsi
1188c2a1:      	callq	0x11579660 <_RNvNtNtCscI5nJwKNRh4_13perry_runtime6object9prop_plan16read_plan_lookup>
1188c2a6:      	cmpl	$0x1, %eax
1188c2a9:      	je	0x1188ef00 <js_object_get_field_by_name+0x3ac0>
1188c2af:      	cmpb	$0x1, -0x8(%r15)
1188c2b4:      	movq	-0x30(%rbp), %r8
1188c2b8:      	jne	0x1188bc40 <js_object_get_field_by_name+0x800>
1188c2be:      	movq	%r15, %rdi
1188c2c1:      	callq	*0x3a9f449(%rip)        # 0x1532b710 <_GLOBAL_OFFSET_TABLE_+0x136b0>
1188c2c7:      	movq	-0x30(%rbp), %r8
1188c2cb:      	cmpq	$0x1000, %rax           # imm = 0x1000
1188c2d1:      	ja	0x1188bc40 <js_object_get_field_by_name+0x800>
1188c2d7:      	movq	%r15, %rdi
1188c2da:      	movl	%eax, %esi
1188c2dc:      	movq	-0x30(%rbp), %rdx
1188c2e0:      	callq	0x1151d3c0 <_RNvNtNtCscI5nJwKNRh4_13perry_runtime6object11keys_lookup25keys_find_slot_by_key_ptr>
1188c2e5:      	movq	-0x30(%rbp), %r8
1188c2e9:      	cmpl	$0x1, %eax
1188c2ec:      	jne	0x1188bc40 <js_object_get_field_by_name+0x800>
1188c2f2:      	jmp	0x1188f0a5 <js_object_get_field_by_name+0x3c65>
1188c2f7:      	movq	-0x30(%rbp), %rcx
1188c2fb:      	movl	0x4(%rcx), %ebx
1188c2fe:      	cmpl	$0x3, %ebx
1188c301:      	je	0x1188c3e4 <js_object_get_field_by_name+0xfa4>
1188c307:      	cmpl	$0x6, %ebx
1188c30a:      	jne	0x1188c580 <js_object_get_field_by_name+0x1140>
1188c310:      	movq	-0x30(%rbp), %rax
1188c314:      	addq	$0x14, %rax
1188c318:      	cmpb	$0x64, (%rax)
1188c31b:      	jne	0x1188c580 <js_object_get_field_by_name+0x1140>
1188c321:      	movq	-0x30(%rbp), %rax
1188c325:      	cmpb	$0x65, 0x15(%rax)
1188c329:      	jne	0x1188c580 <js_object_get_field_by_name+0x1140>
1188c32f:      	movq	-0x30(%rbp), %rax
1188c333:      	cmpb	$0x6c, 0x16(%rax)
1188c337:      	jne	0x1188c580 <js_object_get_field_by_name+0x1140>
1188c33d:      	movq	-0x30(%rbp), %rax
1188c341:      	cmpb	$0x65, 0x17(%rax)
1188c345:      	jne	0x1188c580 <js_object_get_field_by_name+0x1140>
1188c34b:      	movq	-0x30(%rbp), %rax
1188c34f:      	cmpb	$0x74, 0x18(%rax)
1188c353:      	jne	0x1188c580 <js_object_get_field_by_name+0x1140>
1188c359:      	movq	-0x30(%rbp), %rax
1188c35d:      	cmpb	$0x65, 0x19(%rax)
1188c361:      	jmp	0x1188c523 <js_object_get_field_by_name+0x10e3>
1188c366:      	movq	-0x30(%rbp), %rcx
1188c36a:      	movl	0x4(%rcx), %ebx
1188c36d:      	cmpl	$0x3, %ebx
1188c370:      	je	0x1188c419 <js_object_get_field_by_name+0xfd9>
1188c376:      	cmpl	$0x6, %ebx
1188c379:      	jne	0x1188c580 <js_object_get_field_by_name+0x1140>
1188c37f:      	movq	-0x30(%rbp), %rax
1188c383:      	addq	$0x14, %rax
1188c387:      	cmpb	$0x64, (%rax)
1188c38a:      	jne	0x1188c580 <js_object_get_field_by_name+0x1140>
1188c390:      	movq	-0x30(%rbp), %rax
1188c394:      	cmpb	$0x65, 0x15(%rax)
1188c398:      	jne	0x1188c580 <js_object_get_field_by_name+0x1140>
1188c39e:      	movq	-0x30(%rbp), %rax
1188c3a2:      	cmpb	$0x6c, 0x16(%rax)
1188c3a6:      	jne	0x1188c580 <js_object_get_field_by_name+0x1140>
1188c3ac:      	movq	-0x30(%rbp), %rax
1188c3b0:      	cmpb	$0x65, 0x17(%rax)
1188c3b4:      	jne	0x1188c580 <js_object_get_field_by_name+0x1140>
1188c3ba:      	movq	-0x30(%rbp), %rax
1188c3be:      	cmpb	$0x74, 0x18(%rax)
1188c3c2:      	jne	0x1188c580 <js_object_get_field_by_name+0x1140>
1188c3c8:      	movq	-0x30(%rbp), %rax
1188c3cc:      	cmpb	$0x65, 0x19(%rax)
1188c3d0:      	jmp	0x1188c4fa <js_object_get_field_by_name+0x10ba>
1188c3d5:      	leaq	0x8(%rbx), %rdi
1188c3d9:      	callq	*0x3a91329(%rip)        # 0x1531d708 <_GLOBAL_OFFSET_TABLE_+0x56a8>
1188c3df:      	jmp	0x1188be5f <js_object_get_field_by_name+0xa1f>
1188c3e4:      	leaq	0x14(%rcx), %rax
1188c3e8:      	movzbl	(%rax), %eax
1188c3eb:      	cmpl	$0x67, %eax
1188c3ee:      	je	0x1188c515 <js_object_get_field_by_name+0x10d5>
1188c3f4:      	cmpl	$0x68, %eax
1188c3f7:      	je	0x1188c505 <js_object_get_field_by_name+0x10c5>
1188c3fd:      	cmpl	$0x73, %eax
1188c400:      	jne	0x1188c580 <js_object_get_field_by_name+0x1140>
1188c406:      	movq	-0x30(%rbp), %rax
1188c40a:      	cmpb	$0x65, 0x15(%rax)
1188c40e:      	je	0x1188c51b <js_object_get_field_by_name+0x10db>
1188c414:      	jmp	0x1188c580 <js_object_get_field_by_name+0x1140>
1188c419:      	leaq	0x14(%rcx), %rax
1188c41d:      	movzbl	(%rax), %eax
1188c420:      	cmpl	$0x68, %eax
1188c423:      	je	0x1188c4e8 <js_object_get_field_by_name+0x10a8>
1188c429:      	cmpl	$0x61, %eax
1188c42c:      	jne	0x1188c580 <js_object_get_field_by_name+0x1140>
1188c432:      	movq	-0x30(%rbp), %rax
1188c436:      	cmpb	$0x64, 0x15(%rax)
1188c43a:      	jne	0x1188c580 <js_object_get_field_by_name+0x1140>
1188c440:      	movq	-0x30(%rbp), %rax
1188c444:      	cmpb	$0x64, 0x16(%rax)
1188c448:      	jmp	0x1188c4fa <js_object_get_field_by_name+0x10ba>
1188c44d:      	leaq	-0x68(%rbp), %rdi
1188c451:      	movq	-0x38(%rbp), %rsi
1188c455:      	callq	*0x3a923fd(%rip)        # 0x1531e858 <_GLOBAL_OFFSET_TABLE_+0x67f8>
1188c45b:      	cmpb	$0x0, -0x68(%rbp)
1188c45f:      	movq	-0x30(%rbp), %r8
1188c463:      	jne	0x1188b659 <js_object_get_field_by_name+0x219>
1188c469:      	movq	-0x60(%rbp), %rdi
1188c46d:      	movq	-0x58(%rbp), %rdx
1188c471:      	movq	%rdx, %rsi
1188c474:      	callq	0x114aa700 <_RNvNtNtCscI5nJwKNRh4_13perry_runtime5array17subclass_elements10key_of_str>
1188c479:      	cmpl	$0x2, %eax
1188c47c:      	movq	-0x30(%rbp), %r8
1188c480:      	je	0x1188b659 <js_object_get_field_by_name+0x219>
1188c486:      	movl	(%r15), %ecx
1188c489:      	cmpl	$0x1, %eax
1188c48c:      	je	0x1188ecd9 <js_object_get_field_by_name+0x3899>
1188c492:      	cmpl	%ecx, %edx
1188c494:      	jae	0x1188b659 <js_object_get_field_by_name+0x219>
1188c49a:      	movl	%edx, %eax
1188c49c:      	movq	0x8(%r15,%rax,8), %r15
1188c4a1:      	movabsq	$0x7ffc000000000001, %rax # imm = 0x7FFC000000000001
1188c4ab:      	addq	$0xf, %rax
1188c4af:      	cmpq	%rax, %r15
1188c4b2:      	je	0x1188b659 <js_object_get_field_by_name+0x219>
1188c4b8:      	jmp	0x1188e847 <js_object_get_field_by_name+0x3407>
1188c4bd:      	cmpq	$0x100000, %r8          # imm = 0x100000
1188c4c4:      	jb	0x1188bc40 <js_object_get_field_by_name+0x800>
1188c4ca:      	cmpq	$0x200000, %r12         # imm = 0x200000
1188c4d1:      	jb	0x1188bc40 <js_object_get_field_by_name+0x800>
1188c4d7:      	cmpb	$0x0, 0x1b(%r12)
1188c4dd:      	jne	0x1188b84a <js_object_get_field_by_name+0x40a>
1188c4e3:      	jmp	0x1188bc40 <js_object_get_field_by_name+0x800>
1188c4e8:      	cmpb	$0x61, 0x15(%rcx)
1188c4ec:      	jne	0x1188c580 <js_object_get_field_by_name+0x1140>
1188c4f2:      	movq	-0x30(%rbp), %rax
1188c4f6:      	cmpb	$0x73, 0x16(%rax)
1188c4fa:      	leaq	0x2a7462b(%rip), %r15   # 0x14300b2c <anon.65d6174ee4273d212d69e4c9be928638.2838.llvm.16259376971001104057+0x64c>
1188c501:      	je	0x1188c52c <js_object_get_field_by_name+0x10ec>
1188c503:      	jmp	0x1188c580 <js_object_get_field_by_name+0x1140>
1188c505:      	cmpb	$0x61, 0x15(%rcx)
1188c509:      	jne	0x1188c580 <js_object_get_field_by_name+0x1140>
1188c50b:      	movq	-0x30(%rbp), %rax
1188c50f:      	cmpb	$0x73, 0x16(%rax)
1188c513:      	jmp	0x1188c523 <js_object_get_field_by_name+0x10e3>
1188c515:      	cmpb	$0x65, 0x15(%rcx)
1188c519:      	jne	0x1188c580 <js_object_get_field_by_name+0x1140>
1188c51b:      	movq	-0x30(%rbp), %rax
1188c51f:      	cmpb	$0x74, 0x16(%rax)
1188c523:      	leaq	0x2a745fb(%rip), %r15   # 0x14300b25 <anon.65d6174ee4273d212d69e4c9be928638.2838.llvm.16259376971001104057+0x645>
1188c52a:      	jne	0x1188c580 <js_object_get_field_by_name+0x1140>
1188c52c:      	movq	%r14, %rdi
1188c52f:      	movq	-0x30(%rbp), %rsi
1188c533:      	callq	0x1167fd60 <_RNvNtNtNtCscI5nJwKNRh4_13perry_runtime6object10object_ops10keys_array15own_key_present>
1188c538:      	testb	%al, %al
1188c53a:      	jne	0x1188c580 <js_object_get_field_by_name+0x1140>
1188c53c:      	leaq	-0x68(%rbp), %rdi
1188c540:      	movq	-0x30(%rbp), %rax
1188c544:      	leaq	0x14(%rax), %rsi
1188c548:      	movq	%rbx, %rdx
1188c54b:      	callq	*0x3a92307(%rip)        # 0x1531e858 <_GLOBAL_OFFSET_TABLE_+0x67f8>
1188c551:      	cmpl	$0x1, -0x68(%rbp)
1188c555:      	je	0x1188c580 <js_object_get_field_by_name+0x1140>
1188c557:      	movq	-0x60(%rbp), %rdx
1188c55b:      	movq	-0x58(%rbp), %rcx
1188c55f:      	movl	$0x7, %esi
1188c564:      	movq	%r15, %rdi
1188c567:      	callq	0x11560d10 <_RNvNtNtCscI5nJwKNRh4_13perry_runtime6object23collection_proto_thunks29collection_proto_method_value>
1188c56c:      	cmpq	$0x1, %rax
1188c570:      	je	0x1188e2b0 <js_object_get_field_by_name+0x2e70>
1188c576:      	nopw	%cs:(%rax,%rax)
1188c580:      	leaq	0x54e9199(%rip), %rax   # 0x16d75720 <_RNvNtNtCscI5nJwKNRh4_13perry_runtime13native_handle9canonical28CANONICAL_HANDLE_ADDR_FILTER.llvm.16259376971001104057>
1188c587:      	movq	(%rax,%r12,8), %rax
1188c58b:      	testq	%rax, -0x50(%rbp)
1188c58f:      	je	0x1188c630 <js_object_get_field_by_name+0x11f0>
1188c595:      	movq	%r13, %rax
1188c598:      	shrq	$0x2c, %rax
1188c59c:      	movq	%r13, %rcx
1188c59f:      	shrq	$0x32, %rcx
1188c5a3:      	andl	$0xf, %ecx
1188c5a6:      	leaq	0x54e9173(%rip), %rdx   # 0x16d75720 <_RNvNtNtCscI5nJwKNRh4_13perry_runtime13native_handle9canonical28CANONICAL_HANDLE_ADDR_FILTER.llvm.16259376971001104057>
1188c5ad:      	movq	(%rdx,%rcx,8), %rcx
1188c5b1:      	btq	%rax, %rcx
1188c5b5:      	jae	0x1188c630 <js_object_get_field_by_name+0x11f0>
1188c5b7:      	movq	%r13, %rax
1188c5ba:      	shrq	$0x28, %rax
1188c5be:      	andl	$0xf, %eax
1188c5c1:      	leaq	0x54e9158(%rip), %rcx   # 0x16d75720 <_RNvNtNtCscI5nJwKNRh4_13perry_runtime13native_handle9canonical28CANONICAL_HANDLE_ADDR_FILTER.llvm.16259376971001104057>
1188c5c8:      	movq	(%rcx,%rax,8), %rax
1188c5cc:      	movq	-0x70(%rbp), %rcx
1188c5d0:      	shrq	%cl, %rax
1188c5d3:      	testq	%r14, %r14
1188c5d6:      	je	0x1188c630 <js_object_get_field_by_name+0x11f0>
1188c5d8:      	testb	$0x1, %al
1188c5da:      	je	0x1188c630 <js_object_get_field_by_name+0x11f0>
1188c5dc:      	movabsq	$-0x800000000000, %rcx  # imm = 0xFFFF800000000000
1188c5e6:      	leaq	(%r14,%rcx), %rax
1188c5ea:      	addq	$0x1000, %rcx           # imm = 0x1000
1188c5f1:      	cmpq	%rcx, %rax
1188c5f4:      	jb	0x1188c630 <js_object_get_field_by_name+0x11f0>
1188c5f6:      	leaq	-0x8(%r14), %rbx
1188c5fa:      	movq	%rbx, %rdi
1188c5fd:      	callq	*0x3a909d5(%rip)        # 0x1531cfd8 <_GLOBAL_OFFSET_TABLE_+0x4f78>
1188c603:      	testb	%al, %al
1188c605:      	je	0x1188c630 <js_object_get_field_by_name+0x11f0>
1188c607:      	cmpb	$0xf, (%rbx)
1188c60a:      	jne	0x1188c630 <js_object_get_field_by_name+0x11f0>
1188c60c:      	movabsq	$0x5045525259484e44, %rax # imm = 0x5045525259484E44
1188c616:      	cmpq	%rax, (%r14)
1188c619:      	jne	0x1188c630 <js_object_get_field_by_name+0x11f0>
1188c61b:      	testb	$0x1, 0x1c(%r14)
1188c620:      	je	0x1188c630 <js_object_get_field_by_name+0x11f0>
1188c622:      	cmpb	$0x0, 0x1b(%r14)
1188c627:      	je	0x1188c740 <js_object_get_field_by_name+0x1300>
1188c62d:      	nopl	(%rax)
1188c630:      	movq	%r14, %rax
1188c633:      	movabsq	$0xffffffffffff, %rcx   # imm = 0xFFFFFFFFFFFF
1188c63d:      	andq	%rcx, %rax
1188c640:      	cmpq	$0x100000, %rax         # imm = 0x100000
1188c646:      	jb	0x1188c740 <js_object_get_field_by_name+0x1300>
1188c64c:      	movabsq	$0x800000000000, %rcx   # imm = 0x800000000000
1188c656:      	cmpq	%rcx, %rax
1188c659:      	jae	0x1188c740 <js_object_get_field_by_name+0x1300>
1188c65f:      	cmpb	$0x2, -0x8(%rax)
1188c663:      	jne	0x1188c740 <js_object_get_field_by_name+0x1300>
1188c669:      	movl	(%rax), %r15d
1188c66c:      	leal	0xffd9(%r15), %eax
1188c673:      	cmpl	$0x4, %eax
1188c676:      	jae	0x1188c706 <js_object_get_field_by_name+0x12c6>
1188c67c:      	movq	-0x30(%rbp), %rax
1188c680:      	movl	0x4(%rax), %edx
1188c683:      	leaq	-0x68(%rbp), %rdi
1188c687:      	leaq	0x14(%rax), %rsi
1188c68b:      	callq	*0x3a921c7(%rip)        # 0x1531e858 <_GLOBAL_OFFSET_TABLE_+0x67f8>
1188c691:      	cmpl	$0x1, -0x68(%rbp)
1188c695:      	je	0x1188c740 <js_object_get_field_by_name+0x1300>
1188c69b:      	movq	-0x60(%rbp), %rax
1188c69f:      	movq	%rax, -0x88(%rbp)
1188c6a6:      	movq	-0x58(%rbp), %rbx
1188c6aa:      	movq	%r14, %rdi
1188c6ad:      	movq	-0x30(%rbp), %rsi
1188c6b1:      	callq	0x1167fd60 <_RNvNtNtNtCscI5nJwKNRh4_13perry_runtime6object10object_ops10keys_array15own_key_present>
1188c6b6:      	testb	%al, %al
1188c6b8:      	jne	0x1188c740 <js_object_get_field_by_name+0x1300>
1188c6be:      	cmpl	$0xffff002a, %r15d      # imm = 0xFFFF002A
1188c6c5:      	je	0x1188d11b <js_object_get_field_by_name+0x1cdb>
1188c6cb:      	cmpl	$0xffff0029, %r15d      # imm = 0xFFFF0029
1188c6d2:      	jne	0x1188c740 <js_object_get_field_by_name+0x1300>
1188c6d4:      	cmpq	$0x5, %rbx
1188c6d8:      	jne	0x1188c740 <js_object_get_field_by_name+0x1300>
1188c6da:      	movq	-0x88(%rbp), %rdx
1188c6e1:      	movl	(%rdx), %eax
1188c6e3:      	movl	$0x65726564, %ecx       # imm = 0x65726564
1188c6e8:      	xorl	%ecx, %eax
1188c6ea:      	movzbl	0x4(%rdx), %ecx
1188c6ee:      	xorl	$0x66, %ecx
1188c6f1:      	orl	%eax, %ecx
1188c6f3:      	jne	0x1188c740 <js_object_get_field_by_name+0x1300>
1188c6f5:      	movl	$0x7, %esi
1188c6fa:      	leaq	0x2ab3c54(%rip), %rdi   # 0x14340355 <anon.65d6174ee4273d212d69e4c9be928638.10935.llvm.16259376971001104057+0x3b4>
1188c701:      	jmp	0x1188d68b <js_object_get_field_by_name+0x224b>
1188c706:      	movl	$0x40, %ebx
1188c70b:      	nopl	(%rax,%rax)
1188c710:      	movl	%r15d, %edi
1188c713:      	callq	0x11552cb0 <_RNvNtNtCscI5nJwKNRh4_13perry_runtime6object19class_meta_registry19get_parent_class_id.llvm.16259376971001104057>
1188c718:      	cmpl	$0x1, %eax
1188c71b:      	jne	0x1188c740 <js_object_get_field_by_name+0x1300>
1188c71d:      	movl	%edx, %r15d
1188c720:      	cmpl	$0xffff002d, %edx       # imm = 0xFFFF002D
1188c726:      	je	0x1188cf42 <js_object_get_field_by_name+0x1b02>
1188c72c:      	cmpl	$0xffff002c, %r15d      # imm = 0xFFFF002C
1188c733:      	je	0x1188cf4d <js_object_get_field_by_name+0x1b0d>
1188c739:      	decl	%ebx
1188c73b:      	jne	0x1188c710 <js_object_get_field_by_name+0x12d0>
1188c73d:      	nopl	(%rax)
1188c740:      	leaq	0x54e8fd9(%rip), %rax   # 0x16d75720 <_RNvNtNtCscI5nJwKNRh4_13perry_runtime13native_handle9canonical28CANONICAL_HANDLE_ADDR_FILTER.llvm.16259376971001104057>
1188c747:      	movq	(%rax,%r12,8), %rax
1188c74b:      	testq	%rax, -0x50(%rbp)
1188c74f:      	je	0x1188c7f0 <js_object_get_field_by_name+0x13b0>
1188c755:      	movq	%r13, %rax
1188c758:      	shrq	$0x2c, %rax
1188c75c:      	movq	%r13, %rcx
1188c75f:      	shrq	$0x32, %rcx
1188c763:      	andl	$0xf, %ecx
1188c766:      	leaq	0x54e8fb3(%rip), %rdx   # 0x16d75720 <_RNvNtNtCscI5nJwKNRh4_13perry_runtime13native_handle9canonical28CANONICAL_HANDLE_ADDR_FILTER.llvm.16259376971001104057>
1188c76d:      	movq	(%rdx,%rcx,8), %rcx
1188c771:      	btq	%rax, %rcx
1188c775:      	jae	0x1188c7f0 <js_object_get_field_by_name+0x13b0>
1188c777:      	movq	%r13, %rax
1188c77a:      	shrq	$0x28, %rax
1188c77e:      	andl	$0xf, %eax
1188c781:      	leaq	0x54e8f98(%rip), %rcx   # 0x16d75720 <_RNvNtNtCscI5nJwKNRh4_13perry_runtime13native_handle9canonical28CANONICAL_HANDLE_ADDR_FILTER.llvm.16259376971001104057>
1188c788:      	movq	(%rcx,%rax,8), %rax
1188c78c:      	movq	-0x70(%rbp), %rcx
1188c790:      	shrq	%cl, %rax
1188c793:      	testq	%r14, %r14
1188c796:      	je	0x1188c7f0 <js_object_get_field_by_name+0x13b0>
1188c798:      	testb	$0x1, %al
1188c79a:      	je	0x1188c7f0 <js_object_get_field_by_name+0x13b0>
1188c79c:      	movabsq	$-0x800000000000, %rcx  # imm = 0xFFFF800000000000
1188c7a6:      	leaq	(%r14,%rcx), %rax
1188c7aa:      	addq	$0x1000, %rcx           # imm = 0x1000
1188c7b1:      	cmpq	%rcx, %rax
1188c7b4:      	jb	0x1188c7f0 <js_object_get_field_by_name+0x13b0>
1188c7b6:      	leaq	-0x8(%r14), %rbx
1188c7ba:      	movq	%rbx, %rdi
1188c7bd:      	callq	*0x3a90815(%rip)        # 0x1531cfd8 <_GLOBAL_OFFSET_TABLE_+0x4f78>
1188c7c3:      	testb	%al, %al
1188c7c5:      	je	0x1188c7f0 <js_object_get_field_by_name+0x13b0>
1188c7c7:      	cmpb	$0xf, (%rbx)
1188c7ca:      	jne	0x1188c7f0 <js_object_get_field_by_name+0x13b0>
1188c7cc:      	movabsq	$0x5045525259484e44, %rax # imm = 0x5045525259484E44
1188c7d6:      	cmpq	%rax, (%r14)
1188c7d9:      	jne	0x1188c7f0 <js_object_get_field_by_name+0x13b0>
1188c7db:      	testb	$0x1, 0x1c(%r14)
1188c7e0:      	je	0x1188c7f0 <js_object_get_field_by_name+0x13b0>
1188c7e2:      	cmpb	$0x0, 0x1b(%r14)
1188c7e7:      	je	0x1188c960 <js_object_get_field_by_name+0x1520>
1188c7ed:      	nopl	(%rax)
1188c7f0:      	movq	-0x30(%rbp), %rax
1188c7f4:      	movl	0x4(%rax), %edx
1188c7f7:      	leaq	-0x68(%rbp), %rdi
1188c7fb:      	leaq	0x14(%rax), %rsi
1188c7ff:      	callq	*0x3a92053(%rip)        # 0x1531e858 <_GLOBAL_OFFSET_TABLE_+0x67f8>
1188c805:      	cmpb	$0x0, -0x68(%rbp)
1188c809:      	movq	-0x60(%rbp), %rbx
1188c80d:      	movl	$0x1, %eax
1188c812:      	cmovneq	%rax, %rbx
1188c816:      	movq	-0x58(%rbp), %r15
1188c81a:      	movl	$0x0, %eax
1188c81f:      	cmovneq	%rax, %r15
1188c823:      	cmpq	$0x7, %r15
1188c827:      	je	0x1188c861 <js_object_get_field_by_name+0x1421>
1188c829:      	cmpq	$0x5, %r15
1188c82d:      	je	0x1188c847 <js_object_get_field_by_name+0x1407>
1188c82f:      	cmpq	$0x4, %r15
1188c833:      	jne	0x1188c960 <js_object_get_field_by_name+0x1520>
1188c839:      	cmpl	$0x6e656874, (%rbx)     # imm = 0x6E656874
1188c83f:      	jne	0x1188c960 <js_object_get_field_by_name+0x1520>
1188c845:      	jmp	0x1188c87c <js_object_get_field_by_name+0x143c>
1188c847:      	movl	(%rbx), %eax
1188c849:      	movl	$0x63746163, %ecx       # imm = 0x63746163
1188c84e:      	xorl	%ecx, %eax
1188c850:      	movzbl	0x4(%rbx), %ecx
1188c854:      	xorl	$0x68, %ecx
1188c857:      	orl	%eax, %ecx
1188c859:      	jne	0x1188c960 <js_object_get_field_by_name+0x1520>
1188c85f:      	jmp	0x1188c87c <js_object_get_field_by_name+0x143c>
1188c861:      	movl	(%rbx), %eax
1188c863:      	movl	$0x616e6966, %ecx       # imm = 0x616E6966
1188c868:      	xorl	%ecx, %eax
1188c86a:      	movl	0x3(%rbx), %ecx
1188c86d:      	movl	$0x796c6c61, %edx       # imm = 0x796C6C61
1188c872:      	xorl	%edx, %ecx
1188c874:      	orl	%eax, %ecx
1188c876:      	jne	0x1188c960 <js_object_get_field_by_name+0x1520>
1188c87c:      	movq	%r14, %rdi
1188c87f:      	movq	-0x30(%rbp), %rsi
1188c883:      	callq	0x1167fd60 <_RNvNtNtNtCscI5nJwKNRh4_13perry_runtime6object10object_ops10keys_array15own_key_present>
1188c888:      	testb	%al, %al
1188c88a:      	jne	0x1188c960 <js_object_get_field_by_name+0x1520>
1188c890:      	movzbl	0x5569c31(%rip), %eax   # 0x16df64c8 <_RNvNtNtCscI5nJwKNRh4_13perry_runtime7promise8subclass21PROMISE_SUBCLASS_EVER.0>
1188c897:      	testb	%al, %al
1188c899:      	je	0x1188c960 <js_object_get_field_by_name+0x1520>
1188c89f:      	movq	%r14, %rax
1188c8a2:      	movabsq	$0xffffffffffff, %rcx   # imm = 0xFFFFFFFFFFFF
1188c8ac:      	andq	%rcx, %rax
1188c8af:      	movabsq	$0x7ffd000000000000, %rcx # imm = 0x7FFD000000000000
1188c8b9:      	orq	%rcx, %rax
1188c8bc:      	movq	%rax, %xmm0
1188c8c1:      	callq	0x11543ae0 <_RNvNtNtCscI5nJwKNRh4_13perry_runtime6object16map_set_subclass19instance_object_ptr.llvm.16259376971001104057>
1188c8c6:      	cmpq	$0x1, %rax
1188c8ca:      	jne	0x1188c960 <js_object_get_field_by_name+0x1520>
1188c8d0:      	leaq	0x2ab6bd0(%rip), %rdi   # 0x143434a7 <anon.65d6174ee4273d212d69e4c9be928638.11886.llvm.16259376971001104057+0x478>
1188c8d7:      	movl	$0x19, %esi
1188c8dc:      	movq	%rdx, -0x88(%rbp)
1188c8e3:      	movl	$0x19, %edx
1188c8e8:      	callq	*0x3a909a2(%rip)        # 0x1531d290 <_GLOBAL_OFFSET_TABLE_+0x5230>
1188c8ee:      	movq	-0x88(%rbp), %rdi
1188c8f5:      	movq	%rax, %rsi
1188c8f8:      	callq	*0x3aa55c2(%rip)        # 0x15331ec0 <_GLOBAL_OFFSET_TABLE_+0x19e60>
1188c8fe:      	movq	%xmm0, %rax
1188c903:      	movq	%rax, %rcx
1188c906:      	movabsq	$-0x1000000000000, %rdx # imm = 0xFFFF000000000000
1188c910:      	andq	%rdx, %rcx
1188c913:      	movabsq	$0x7ffd000000000000, %rdx # imm = 0x7FFD000000000000
1188c91d:      	cmpq	%rdx, %rcx
1188c920:      	jne	0x1188c960 <js_object_get_field_by_name+0x1520>
1188c922:      	movabsq	$0xffffffffffff, %rcx   # imm = 0xFFFFFFFFFFFF
1188c92c:      	addq	$-0x7, %rcx
1188c930:      	andq	%rcx, %rax
1188c933:      	cmpq	$0x1008, %rax           # imm = 0x1008
1188c939:      	jb	0x1188c960 <js_object_get_field_by_name+0x1520>
1188c93b:      	callq	*0x3a9496f(%rip)        # 0x153212b0 <_GLOBAL_OFFSET_TABLE_+0x9250>
1188c941:      	testl	%eax, %eax
1188c943:      	je	0x1188c960 <js_object_get_field_by_name+0x1520>
1188c945:      	movq	%rbx, %rsi
1188c948:      	movq	%r15, %rdx
1188c94b:      	callq	*0x3a95b7f(%rip)        # 0x153224d0 <_GLOBAL_OFFSET_TABLE_+0xa470>
1188c951:      	cmpq	$0x1, %rax
1188c955:      	je	0x1188e2b0 <js_object_get_field_by_name+0x2e70>
1188c95b:      	nopl	(%rax,%rax)
1188c960:      	leaq	0x54e8db9(%rip), %rax   # 0x16d75720 <_RNvNtNtCscI5nJwKNRh4_13perry_runtime13native_handle9canonical28CANONICAL_HANDLE_ADDR_FILTER.llvm.16259376971001104057>
1188c967:      	movq	(%rax,%r12,8), %rax
1188c96b:      	testq	%rax, -0x50(%rbp)
1188c96f:      	movq	-0x78(%rbp), %r15
1188c973:      	je	0x1188ca10 <js_object_get_field_by_name+0x15d0>
1188c979:      	movq	%r13, %rax
1188c97c:      	shrq	$0x2c, %rax
1188c980:      	movq	%r13, %rcx
1188c983:      	shrq	$0x32, %rcx
1188c987:      	andl	$0xf, %ecx
1188c98a:      	leaq	0x54e8d8f(%rip), %rdx   # 0x16d75720 <_RNvNtNtCscI5nJwKNRh4_13perry_runtime13native_handle9canonical28CANONICAL_HANDLE_ADDR_FILTER.llvm.16259376971001104057>
1188c991:      	movq	(%rdx,%rcx,8), %rcx
1188c995:      	btq	%rax, %rcx
1188c999:      	jae	0x1188ca10 <js_object_get_field_by_name+0x15d0>
1188c99b:      	shrq	$0x28, %r13
1188c99f:      	andl	$0xf, %r13d
1188c9a3:      	leaq	0x54e8d76(%rip), %rax   # 0x16d75720 <_RNvNtNtCscI5nJwKNRh4_13perry_runtime13native_handle9canonical28CANONICAL_HANDLE_ADDR_FILTER.llvm.16259376971001104057>
1188c9aa:      	movq	(%rax,%r13,8), %rax
1188c9ae:      	movq	-0x70(%rbp), %rcx
1188c9b2:      	shrq	%cl, %rax
1188c9b5:      	testq	%r14, %r14
1188c9b8:      	je	0x1188ca10 <js_object_get_field_by_name+0x15d0>
1188c9ba:      	testb	$0x1, %al
1188c9bc:      	je	0x1188ca10 <js_object_get_field_by_name+0x15d0>
1188c9be:      	movabsq	$-0x800000000000, %rcx  # imm = 0xFFFF800000000000
1188c9c8:      	leaq	(%r14,%rcx), %rax
1188c9cc:      	addq	$0x1000, %rcx           # imm = 0x1000
1188c9d3:      	cmpq	%rcx, %rax
1188c9d6:      	jb	0x1188ca10 <js_object_get_field_by_name+0x15d0>
1188c9d8:      	leaq	-0x8(%r14), %rbx
1188c9dc:      	movq	%rbx, %rdi
1188c9df:      	callq	*0x3a905f3(%rip)        # 0x1531cfd8 <_GLOBAL_OFFSET_TABLE_+0x4f78>
1188c9e5:      	testb	%al, %al
1188c9e7:      	je	0x1188ca10 <js_object_get_field_by_name+0x15d0>
1188c9e9:      	cmpb	$0xf, (%rbx)
1188c9ec:      	jne	0x1188ca10 <js_object_get_field_by_name+0x15d0>
1188c9ee:      	movabsq	$0x5045525259484e44, %rax # imm = 0x5045525259484E44
1188c9f8:      	cmpq	%rax, (%r14)
1188c9fb:      	jne	0x1188ca10 <js_object_get_field_by_name+0x15d0>
1188c9fd:      	testb	$0x1, 0x1c(%r14)
1188ca02:      	je	0x1188ca10 <js_object_get_field_by_name+0x15d0>
1188ca04:      	cmpb	$0x0, 0x1b(%r14)
1188ca09:      	je	0x1188ca21 <js_object_get_field_by_name+0x15e1>
1188ca0b:      	nopl	(%rax,%rax)
1188ca10:      	movq	%r14, %rdi
1188ca13:      	callq	*0x3a8ff87(%rip)        # 0x1531c9a0 <_GLOBAL_OFFSET_TABLE_+0x4940>
1188ca19:      	testb	%al, %al
1188ca1b:      	jne	0x1188e136 <js_object_get_field_by_name+0x2cf6>
1188ca21:      	movq	%r14, %xmm0
1188ca26:      	movdqa	%xmm0, -0x50(%rbp)
1188ca2b:      	callq	0x1122d9d0 <_RNvNtCscI5nJwKNRh4_13perry_runtime16typedarray_props27typed_array_addr_from_value>
1188ca30:      	testb	$0x1, %al
1188ca32:      	movq	-0x30(%rbp), %rsi
1188ca36:      	je	0x1188d2b4 <js_object_get_field_by_name+0x1e74>
1188ca3c:      	movq	%rdx, %r12
1188ca3f:      	movl	0x4(%rsi), %ebx
1188ca42:      	movq	%rsi, %r13
1188ca45:      	movq	%rdx, %rdi
1188ca48:      	movq	-0x38(%rbp), %rsi
1188ca4c:      	movq	%rbx, %rdx
1188ca4f:      	callq	0x116a6d80 <_RNvNtNtNtCscI5nJwKNRh4_13perry_runtime6object13field_get_set10crypto_key25crypto_key_property_value>
1188ca54:      	testb	$0x1, %al
1188ca56:      	jne	0x1188e0d6 <js_object_get_field_by_name+0x2c96>
1188ca5c:      	cmpq	$0x10000, %r13          # imm = 0x10000
1188ca63:      	jb	0x1188cb70 <js_object_get_field_by_name+0x1730>
1188ca69:      	testq	%r12, %r12
1188ca6c:      	je	0x1188cb70 <js_object_get_field_by_name+0x1730>
1188ca72:      	movl	0x4(%r13), %r15d
1188ca76:      	cmpl	%r15d, (%r13)
1188ca7a:      	jne	0x1188ca90 <js_object_get_field_by_name+0x1650>
1188ca7c:      	movq	-0x38(%rbp), %rdx
1188ca80:      	leaq	0x54e8559(%rip), %rax   # 0x16d74fe0 <_RNvNtCscI5nJwKNRh4_13perry_runtime10typedarray27TYPED_ARRAY_EVER_REGISTERED>
1188ca87:      	movzbl	(%rax), %eax
1188ca8a:      	testb	%al, %al
1188ca8c:      	jne	0x1188cac5 <js_object_get_field_by_name+0x1685>
1188ca8e:      	jmp	0x1188cb00 <js_object_get_field_by_name+0x16c0>
1188ca90:      	leaq	-0x68(%rbp), %rdi
1188ca94:      	movq	-0x38(%rbp), %rsi
1188ca98:      	movq	%r15, %rdx
1188ca9b:      	callq	*0x3a91db7(%rip)        # 0x1531e858 <_GLOBAL_OFFSET_TABLE_+0x67f8>
1188caa1:      	movq	-0x30(%rbp), %r13
1188caa5:      	cmpb	$0x0, -0x68(%rbp)
1188caa9:      	jne	0x1188cb70 <js_object_get_field_by_name+0x1730>
1188caaf:      	movq	-0x60(%rbp), %rdx
1188cab3:      	movq	-0x58(%rbp), %r15
1188cab7:      	leaq	0x54e8522(%rip), %rax   # 0x16d74fe0 <_RNvNtCscI5nJwKNRh4_13perry_runtime10typedarray27TYPED_ARRAY_EVER_REGISTERED>
1188cabe:      	movzbl	(%rax), %eax
1188cac1:      	testb	%al, %al
1188cac3:      	je	0x1188cb00 <js_object_get_field_by_name+0x16c0>
1188cac5:      	leaq	0x3ac34fc(%rip), %rax   # 0x1534ffc8 <_RNvNtCscI5nJwKNRh4_13perry_runtime10typedarray23TYPED_ARRAY_ADDR_WINDOW>
1188cacc:      	movq	(%rax), %rax
1188cacf:      	cmpq	%rax, %r12
1188cad2:      	jb	0x1188cb00 <js_object_get_field_by_name+0x16c0>
1188cad4:      	leaq	0x3ac34ed(%rip), %rax   # 0x1534ffc8 <_RNvNtCscI5nJwKNRh4_13perry_runtime10typedarray23TYPED_ARRAY_ADDR_WINDOW>
1188cadb:      	movq	0x8(%rax), %rax
1188cadf:      	cmpq	%rax, %r12
1188cae2:      	ja	0x1188cb00 <js_object_get_field_by_name+0x16c0>
1188cae4:      	movq	%r12, %rdi
1188cae7:      	movq	%rdx, %r13
1188caea:      	callq	*0x3aa3140(%rip)        # 0x1532fc30 <_GLOBAL_OFFSET_TABLE_+0x17bd0>
1188caf0:      	movq	%r13, %rdx
1188caf3:      	movq	-0x30(%rbp), %r13
1188caf7:      	testb	$0x1, %al
1188caf9:      	je	0x1188cb00 <js_object_get_field_by_name+0x16c0>
1188cafb:      	xorl	%ecx, %ecx
1188cafd:      	jmp	0x1188cb46 <js_object_get_field_by_name+0x1706>
1188caff:      	nop
1188cb00:      	leaq	0x5569214(%rip), %rax   # 0x16df5d1b <_RNvNtNtCscI5nJwKNRh4_13perry_runtime6buffer6header22UINT8ARRAY_EVER_MARKED>
1188cb07:      	movzbl	(%rax), %eax
1188cb0a:      	testb	%al, %al
1188cb0c:      	je	0x1188cb70 <js_object_get_field_by_name+0x1730>
1188cb0e:      	leaq	0x3ac3fbb(%rip), %rax   # 0x15350ad0 <_RNvNtNtCscI5nJwKNRh4_13perry_runtime6buffer6header22UINT8ARRAY_ADDR_WINDOW>
1188cb15:      	movq	(%rax), %rax
1188cb18:      	cmpq	%rax, %r12
1188cb1b:      	jb	0x1188cb70 <js_object_get_field_by_name+0x1730>
1188cb1d:      	leaq	0x3ac3fac(%rip), %rax   # 0x15350ad0 <_RNvNtNtCscI5nJwKNRh4_13perry_runtime6buffer6header22UINT8ARRAY_ADDR_WINDOW>
1188cb24:      	movq	0x8(%rax), %rax
1188cb28:      	cmpq	%rax, %r12
1188cb2b:      	ja	0x1188cb70 <js_object_get_field_by_name+0x1730>
1188cb2d:      	movq	%r12, %rdi
1188cb30:      	movq	%rdx, %r13
1188cb33:      	callq	*0x3a95b1f(%rip)        # 0x15322658 <_GLOBAL_OFFSET_TABLE_+0xa5f8>
1188cb39:      	movq	%r13, %rdx
1188cb3c:      	movq	-0x30(%rbp), %r13
1188cb40:      	movb	$0x1, %cl
1188cb42:      	testb	%al, %al
1188cb44:      	je	0x1188cb70 <js_object_get_field_by_name+0x1730>
1188cb46:      	movzbl	%cl, %esi
1188cb49:      	movq	%r12, %rdi
1188cb4c:      	movq	%r15, %rcx
1188cb4f:      	callq	0x11232230 <_RNvNtCscI5nJwKNRh4_13perry_runtime16typedarray_props42typed_array_get_property_value_by_name_for>
1188cb54:      	movq	-0x30(%rbp), %r13
1188cb58:      	cmpq	$0x1, %rax
1188cb5c:      	je	0x1188e2b0 <js_object_get_field_by_name+0x2e70>
1188cb62:      	nopw	%cs:(%rax,%rax)
1188cb70:      	leaq	0x54e8469(%rip), %rax   # 0x16d74fe0 <_RNvNtCscI5nJwKNRh4_13perry_runtime10typedarray27TYPED_ARRAY_EVER_REGISTERED>
1188cb77:      	movzbl	(%rax), %eax
1188cb7a:      	testb	%al, %al
1188cb7c:      	je	0x1188cc50 <js_object_get_field_by_name+0x1810>
1188cb82:      	leaq	0x3ac343f(%rip), %rax   # 0x1534ffc8 <_RNvNtCscI5nJwKNRh4_13perry_runtime10typedarray23TYPED_ARRAY_ADDR_WINDOW>
1188cb89:      	movq	(%rax), %rax
1188cb8c:      	cmpq	%rax, %r12
1188cb8f:      	jb	0x1188cc50 <js_object_get_field_by_name+0x1810>
1188cb95:      	leaq	0x3ac342c(%rip), %rax   # 0x1534ffc8 <_RNvNtCscI5nJwKNRh4_13perry_runtime10typedarray23TYPED_ARRAY_ADDR_WINDOW>
1188cb9c:      	movq	0x8(%rax), %rax
1188cba0:      	cmpq	%rax, %r12
1188cba3:      	ja	0x1188cc50 <js_object_get_field_by_name+0x1810>
1188cba9:      	movq	%r12, %rdi
1188cbac:      	callq	*0x3aa307e(%rip)        # 0x1532fc30 <_GLOBAL_OFFSET_TABLE_+0x17bd0>
1188cbb2:      	movq	-0x30(%rbp), %r13
1188cbb6:      	testb	$0x1, %al
1188cbb8:      	je	0x1188cc50 <js_object_get_field_by_name+0x1810>
1188cbbe:      	movl	$0x8, %r15d
1188cbc4:      	cmpb	$0xb, %dl
1188cbc7:      	ja	0x1188cbd8 <js_object_get_field_by_name+0x1798>
1188cbc9:      	movzbl	%dl, %eax
1188cbcc:      	leaq	0x2ac8175(%rip), %rcx   # 0x14354d48 <anon.65d6174ee4273d212d69e4c9be928638.16457.llvm.16259376971001104057+0x833>
1188cbd3:      	movzbl	(%rax,%rcx), %r15d
1188cbd8:      	movb	%dl, -0x70(%rbp)
1188cbdb:      	addl	$-0x6, %ebx
1188cbde:      	cmpl	$0xb, %ebx
1188cbe1:      	ja	0x1188d797 <js_object_get_field_by_name+0x2357>
1188cbe7:      	leaq	0x2a6fc32(%rip), %rcx   # 0x142fc820 <anon.65d6174ee4273d212d69e4c9be928638.11885.llvm.16259376971001104057+0x10204>
1188cbee:      	movslq	(%rcx,%rbx,4), %rax
1188cbf2:      	addq	%rcx, %rax
1188cbf5:      	jmpq	*%rax
1188cbf7:      	movq	-0x38(%rbp), %rax
1188cbfb:      	movzbl	(%rax), %eax
1188cbfe:      	cmpl	$0x62, %eax
1188cc01:      	je	0x1188d15f <js_object_get_field_by_name+0x1d1f>
1188cc07:      	cmpl	$0x6c, %eax
1188cc0a:      	jne	0x1188d797 <js_object_get_field_by_name+0x2357>
1188cc10:      	cmpb	$0x65, 0x15(%r13)
1188cc15:      	jne	0x1188d797 <js_object_get_field_by_name+0x2357>
1188cc1b:      	cmpb	$0x6e, 0x16(%r13)
1188cc20:      	jne	0x1188d797 <js_object_get_field_by_name+0x2357>
1188cc26:      	cmpb	$0x67, 0x17(%r13)
1188cc2b:      	jne	0x1188d797 <js_object_get_field_by_name+0x2357>
1188cc31:      	cmpb	$0x74, 0x18(%r13)
1188cc36:      	jne	0x1188d797 <js_object_get_field_by_name+0x2357>
1188cc3c:      	cmpb	$0x68, 0x19(%r13)
1188cc41:      	jne	0x1188d797 <js_object_get_field_by_name+0x2357>
1188cc47:      	jmp	0x1188f0f4 <js_object_get_field_by_name+0x3cb4>
1188cc4c:      	nopl	(%rax)
1188cc50:      	addl	$-0x6, %ebx
1188cc53:      	cmpl	$0xb, %ebx
1188cc56:      	ja	0x1188d1d0 <js_object_get_field_by_name+0x1d90>
1188cc5c:      	leaq	0x2a6fbed(%rip), %rcx   # 0x142fc850 <anon.65d6174ee4273d212d69e4c9be928638.11885.llvm.16259376971001104057+0x10234>
1188cc63:      	movslq	(%rcx,%rbx,4), %rax
1188cc67:      	addq	%rcx, %rax
1188cc6a:      	jmpq	*%rax
1188cc6c:      	movq	-0x38(%rbp), %rax
1188cc70:      	movzbl	(%rax), %eax
1188cc73:      	addl	$-0x62, %eax
1188cc76:      	cmpl	$0xe, %eax
1188cc79:      	ja	0x1188d1d0 <js_object_get_field_by_name+0x1d90>
1188cc7f:      	leaq	0x2a6fbfa(%rip), %rcx   # 0x142fc880 <anon.65d6174ee4273d212d69e4c9be928638.11885.llvm.16259376971001104057+0x10264>
1188cc86:      	movslq	(%rcx,%rax,4), %rax
1188cc8a:      	addq	%rcx, %rax
1188cc8d:      	jmpq	*%rax
1188cc8f:      	cmpb	$0x75, 0x15(%r13)
1188cc94:      	jne	0x1188d1d0 <js_object_get_field_by_name+0x1d90>
1188cc9a:      	cmpb	$0x66, 0x16(%r13)
1188cc9f:      	jne	0x1188d1d0 <js_object_get_field_by_name+0x1d90>
1188cca5:      	cmpb	$0x66, 0x17(%r13)
1188ccaa:      	jne	0x1188d1d0 <js_object_get_field_by_name+0x1d90>
1188ccb0:      	cmpb	$0x65, 0x18(%r13)
1188ccb5:      	jne	0x1188d1d0 <js_object_get_field_by_name+0x1d90>
1188ccbb:      	cmpb	$0x72, 0x19(%r13)
1188ccc0:      	jne	0x1188d1d0 <js_object_get_field_by_name+0x1d90>
1188ccc6:      	jmp	0x1188ece8 <js_object_get_field_by_name+0x38a8>
1188cccb:      	movq	-0x38(%rbp), %rax
1188cccf:      	cmpb	$0x63, (%rax)
1188ccd2:      	jne	0x1188d1d0 <js_object_get_field_by_name+0x1d90>
1188ccd8:      	cmpb	$0x6f, 0x15(%r13)
1188ccdd:      	jne	0x1188d1d0 <js_object_get_field_by_name+0x1d90>
1188cce3:      	cmpb	$0x6e, 0x16(%r13)
1188cce8:      	jne	0x1188d1d0 <js_object_get_field_by_name+0x1d90>
1188ccee:      	cmpb	$0x73, 0x17(%r13)
1188ccf3:      	jne	0x1188d1d0 <js_object_get_field_by_name+0x1d90>
1188ccf9:      	cmpb	$0x74, 0x18(%r13)
1188ccfe:      	jne	0x1188d1d0 <js_object_get_field_by_name+0x1d90>
1188cd04:      	cmpb	$0x72, 0x19(%r13)
1188cd09:      	jne	0x1188d1d0 <js_object_get_field_by_name+0x1d90>
1188cd0f:      	cmpb	$0x75, 0x1a(%r13)
1188cd14:      	jne	0x1188d1d0 <js_object_get_field_by_name+0x1d90>
1188cd1a:      	cmpb	$0x63, 0x1b(%r13)
1188cd1f:      	jne	0x1188d1d0 <js_object_get_field_by_name+0x1d90>
1188cd25:      	cmpb	$0x74, 0x1c(%r13)
1188cd2a:      	jne	0x1188d1d0 <js_object_get_field_by_name+0x1d90>
1188cd30:      	cmpb	$0x6f, 0x1d(%r13)
1188cd35:      	jne	0x1188d1d0 <js_object_get_field_by_name+0x1d90>
1188cd3b:      	cmpb	$0x72, 0x1e(%r13)
1188cd40:      	jne	0x1188d1d0 <js_object_get_field_by_name+0x1d90>
1188cd46:      	jmp	0x1188f155 <js_object_get_field_by_name+0x3d15>
1188cd4b:      	movq	-0x38(%rbp), %rax
1188cd4f:      	cmpb	$0x62, (%rax)
1188cd52:      	jne	0x1188d1d0 <js_object_get_field_by_name+0x1d90>
1188cd58:      	cmpb	$0x79, 0x15(%r13)
1188cd5d:      	jne	0x1188d1d0 <js_object_get_field_by_name+0x1d90>
1188cd63:      	cmpb	$0x74, 0x16(%r13)
1188cd68:      	jne	0x1188d1d0 <js_object_get_field_by_name+0x1d90>
1188cd6e:      	cmpb	$0x65, 0x17(%r13)
1188cd73:      	jne	0x1188d1d0 <js_object_get_field_by_name+0x1d90>
1188cd79:      	movzbl	0x18(%r13), %eax
1188cd7e:      	cmpl	$0x4f, %eax
1188cd81:      	je	0x1188d19b <js_object_get_field_by_name+0x1d5b>
1188cd87:      	cmpl	$0x4c, %eax
1188cd8a:      	jne	0x1188d1d0 <js_object_get_field_by_name+0x1d90>
1188cd90:      	cmpb	$0x65, 0x19(%r13)
1188cd95:      	jne	0x1188d1d0 <js_object_get_field_by_name+0x1d90>
1188cd9b:      	cmpb	$0x6e, 0x1a(%r13)
1188cda0:      	jne	0x1188d1d0 <js_object_get_field_by_name+0x1d90>
1188cda6:      	cmpb	$0x67, 0x1b(%r13)
1188cdab:      	jne	0x1188d1d0 <js_object_get_field_by_name+0x1d90>
1188cdb1:      	cmpb	$0x74, 0x1c(%r13)
1188cdb6:      	jne	0x1188d1d0 <js_object_get_field_by_name+0x1d90>
1188cdbc:      	cmpb	$0x68, 0x1d(%r13)
1188cdc1:      	jne	0x1188d1d0 <js_object_get_field_by_name+0x1d90>
1188cdc7:      	jmp	0x1188eece <js_object_get_field_by_name+0x3a8e>
1188cdcc:      	movq	-0x38(%rbp), %rax
1188cdd0:      	cmpb	$0x42, (%rax)
1188cdd3:      	jne	0x1188d1d0 <js_object_get_field_by_name+0x1d90>
1188cdd9:      	cmpb	$0x59, 0x15(%r13)
1188cdde:      	jne	0x1188d1d0 <js_object_get_field_by_name+0x1d90>
1188cde4:      	cmpb	$0x54, 0x16(%r13)
1188cde9:      	jne	0x1188d1d0 <js_object_get_field_by_name+0x1d90>
1188cdef:      	cmpb	$0x45, 0x17(%r13)
1188cdf4:      	jne	0x1188d1d0 <js_object_get_field_by_name+0x1d90>
1188cdfa:      	cmpb	$0x53, 0x18(%r13)
1188cdff:      	jne	0x1188d1d0 <js_object_get_field_by_name+0x1d90>
1188ce05:      	cmpb	$0x5f, 0x19(%r13)
1188ce0a:      	jne	0x1188d1d0 <js_object_get_field_by_name+0x1d90>
1188ce10:      	cmpb	$0x50, 0x1a(%r13)
1188ce15:      	jne	0x1188d1d0 <js_object_get_field_by_name+0x1d90>
1188ce1b:      	cmpb	$0x45, 0x1b(%r13)
1188ce20:      	jne	0x1188d1d0 <js_object_get_field_by_name+0x1d90>
1188ce26:      	cmpb	$0x52, 0x1c(%r13)
1188ce2b:      	jne	0x1188d1d0 <js_object_get_field_by_name+0x1d90>
1188ce31:      	cmpb	$0x5f, 0x1d(%r13)
1188ce36:      	jne	0x1188d1d0 <js_object_get_field_by_name+0x1d90>
1188ce3c:      	cmpb	$0x45, 0x1e(%r13)
1188ce41:      	jne	0x1188d1d0 <js_object_get_field_by_name+0x1d90>
1188ce47:      	cmpb	$0x4c, 0x1f(%r13)
1188ce4c:      	jne	0x1188d1d0 <js_object_get_field_by_name+0x1d90>
1188ce52:      	cmpb	$0x45, 0x20(%r13)
1188ce57:      	jne	0x1188d1d0 <js_object_get_field_by_name+0x1d90>
1188ce5d:      	cmpb	$0x4d, 0x21(%r13)
1188ce62:      	jne	0x1188d1d0 <js_object_get_field_by_name+0x1d90>
1188ce68:      	cmpb	$0x45, 0x22(%r13)
1188ce6d:      	jne	0x1188d1d0 <js_object_get_field_by_name+0x1d90>
1188ce73:      	cmpb	$0x4e, 0x23(%r13)
1188ce78:      	jne	0x1188d1d0 <js_object_get_field_by_name+0x1d90>
1188ce7e:      	cmpb	$0x54, 0x24(%r13)
1188ce83:      	jne	0x1188d1d0 <js_object_get_field_by_name+0x1d90>
1188ce89:      	jmp	0x1188f2c0 <js_object_get_field_by_name+0x3e80>
1188ce8e:      	cmpb	$0x66, 0x15(%r13)
1188ce93:      	jne	0x1188d1d0 <js_object_get_field_by_name+0x1d90>
1188ce99:      	cmpb	$0x66, 0x16(%r13)
1188ce9e:      	jne	0x1188d1d0 <js_object_get_field_by_name+0x1d90>
1188cea4:      	cmpb	$0x73, 0x17(%r13)
1188cea9:      	jne	0x1188d1d0 <js_object_get_field_by_name+0x1d90>
1188ceaf:      	cmpb	$0x65, 0x18(%r13)
1188ceb4:      	jne	0x1188d1d0 <js_object_get_field_by_name+0x1d90>
1188ceba:      	cmpb	$0x74, 0x19(%r13)
1188cebf:      	jne	0x1188d1d0 <js_object_get_field_by_name+0x1d90>
1188cec5:      	jmp	0x1188ee9c <js_object_get_field_by_name+0x3a5c>
1188ceca:      	cmpb	$0x65, 0x15(%r13)
1188cecf:      	jne	0x1188d1d0 <js_object_get_field_by_name+0x1d90>
1188ced5:      	cmpb	$0x6e, 0x16(%r13)
1188ceda:      	jne	0x1188d1d0 <js_object_get_field_by_name+0x1d90>
1188cee0:      	cmpb	$0x67, 0x17(%r13)
1188cee5:      	jne	0x1188d1d0 <js_object_get_field_by_name+0x1d90>
1188ceeb:      	cmpb	$0x74, 0x18(%r13)
1188cef0:      	jne	0x1188d1d0 <js_object_get_field_by_name+0x1d90>
1188cef6:      	cmpb	$0x68, 0x19(%r13)
1188cefb:      	jne	0x1188d1d0 <js_object_get_field_by_name+0x1d90>
1188cf01:      	jmp	0x1188eeb4 <js_object_get_field_by_name+0x3a74>
1188cf06:      	cmpb	$0x61, 0x15(%r13)
1188cf0b:      	jne	0x1188d1d0 <js_object_get_field_by_name+0x1d90>
1188cf11:      	cmpb	$0x72, 0x16(%r13)
1188cf16:      	jne	0x1188d1d0 <js_object_get_field_by_name+0x1d90>
1188cf1c:      	cmpb	$0x65, 0x17(%r13)
1188cf21:      	jne	0x1188d1d0 <js_object_get_field_by_name+0x1d90>
1188cf27:      	cmpb	$0x6e, 0x18(%r13)
1188cf2c:      	jne	0x1188d1d0 <js_object_get_field_by_name+0x1d90>
1188cf32:      	cmpb	$0x74, 0x19(%r13)
1188cf37:      	jne	0x1188d1d0 <js_object_get_field_by_name+0x1d90>
1188cf3d:      	jmp	0x1188ece8 <js_object_get_field_by_name+0x38a8>
1188cf42:      	movl	$0xffff0028, %r15d      # imm = 0xFFFF0028
1188cf48:      	jmp	0x1188c67c <js_object_get_field_by_name+0x123c>
1188cf4d:      	movl	$0xffff0027, %r15d      # imm = 0xFFFF0027
1188cf53:      	jmp	0x1188c67c <js_object_get_field_by_name+0x123c>
1188cf58:      	movq	-0x38(%rbp), %rax
1188cf5c:      	cmpb	$0x63, (%rax)
1188cf5f:      	jne	0x1188d797 <js_object_get_field_by_name+0x2357>
1188cf65:      	cmpb	$0x6f, 0x15(%r13)
1188cf6a:      	jne	0x1188d797 <js_object_get_field_by_name+0x2357>
1188cf70:      	cmpb	$0x6e, 0x16(%r13)
1188cf75:      	jne	0x1188d797 <js_object_get_field_by_name+0x2357>
1188cf7b:      	cmpb	$0x73, 0x17(%r13)
1188cf80:      	jne	0x1188d797 <js_object_get_field_by_name+0x2357>
1188cf86:      	cmpb	$0x74, 0x18(%r13)
1188cf8b:      	jne	0x1188d797 <js_object_get_field_by_name+0x2357>
1188cf91:      	cmpb	$0x72, 0x19(%r13)
1188cf96:      	jne	0x1188d797 <js_object_get_field_by_name+0x2357>
1188cf9c:      	cmpb	$0x75, 0x1a(%r13)
1188cfa1:      	jne	0x1188d797 <js_object_get_field_by_name+0x2357>
1188cfa7:      	cmpb	$0x63, 0x1b(%r13)
1188cfac:      	jne	0x1188d797 <js_object_get_field_by_name+0x2357>
1188cfb2:      	cmpb	$0x74, 0x1c(%r13)
1188cfb7:      	jne	0x1188d797 <js_object_get_field_by_name+0x2357>
1188cfbd:      	cmpb	$0x6f, 0x1d(%r13)
1188cfc2:      	jne	0x1188d797 <js_object_get_field_by_name+0x2357>
1188cfc8:      	cmpb	$0x72, 0x1e(%r13)
1188cfcd:      	jne	0x1188d797 <js_object_get_field_by_name+0x2357>
1188cfd3:      	jmp	0x1188f263 <js_object_get_field_by_name+0x3e23>
1188cfd8:      	movq	-0x38(%rbp), %rax
1188cfdc:      	cmpb	$0x62, (%rax)
1188cfdf:      	jne	0x1188d797 <js_object_get_field_by_name+0x2357>
1188cfe5:      	cmpb	$0x79, 0x15(%r13)
1188cfea:      	jne	0x1188d797 <js_object_get_field_by_name+0x2357>
1188cff0:      	cmpb	$0x74, 0x16(%r13)
1188cff5:      	jne	0x1188d797 <js_object_get_field_by_name+0x2357>
1188cffb:      	cmpb	$0x65, 0x17(%r13)
1188d000:      	jne	0x1188d797 <js_object_get_field_by_name+0x2357>
1188d006:      	movzbl	0x18(%r13), %eax
1188d00b:      	cmpl	$0x4f, %eax
1188d00e:      	je	0x1188d770 <js_object_get_field_by_name+0x2330>
1188d014:      	cmpl	$0x4c, %eax
1188d017:      	jne	0x1188d797 <js_object_get_field_by_name+0x2357>
1188d01d:      	cmpb	$0x65, 0x19(%r13)
1188d022:      	jne	0x1188d797 <js_object_get_field_by_name+0x2357>
1188d028:      	cmpb	$0x6e, 0x1a(%r13)
1188d02d:      	jne	0x1188d797 <js_object_get_field_by_name+0x2357>
1188d033:      	cmpb	$0x67, 0x1b(%r13)
1188d038:      	jne	0x1188d797 <js_object_get_field_by_name+0x2357>
1188d03e:      	cmpb	$0x74, 0x1c(%r13)
1188d043:      	jne	0x1188d797 <js_object_get_field_by_name+0x2357>
1188d049:      	cmpb	$0x68, 0x1d(%r13)
1188d04e:      	jne	0x1188d797 <js_object_get_field_by_name+0x2357>
1188d054:      	jmp	0x1188f21b <js_object_get_field_by_name+0x3ddb>
1188d059:      	movq	-0x38(%rbp), %rax
1188d05d:      	cmpb	$0x42, (%rax)
1188d060:      	jne	0x1188d797 <js_object_get_field_by_name+0x2357>
1188d066:      	cmpb	$0x59, 0x15(%r13)
1188d06b:      	jne	0x1188d797 <js_object_get_field_by_name+0x2357>
1188d071:      	cmpb	$0x54, 0x16(%r13)
1188d076:      	jne	0x1188d797 <js_object_get_field_by_name+0x2357>
1188d07c:      	cmpb	$0x45, 0x17(%r13)
1188d081:      	jne	0x1188d797 <js_object_get_field_by_name+0x2357>
1188d087:      	cmpb	$0x53, 0x18(%r13)
1188d08c:      	jne	0x1188d797 <js_object_get_field_by_name+0x2357>
1188d092:      	cmpb	$0x5f, 0x19(%r13)
1188d097:      	jne	0x1188d797 <js_object_get_field_by_name+0x2357>
1188d09d:      	cmpb	$0x50, 0x1a(%r13)
1188d0a2:      	jne	0x1188d797 <js_object_get_field_by_name+0x2357>
1188d0a8:      	cmpb	$0x45, 0x1b(%r13)
1188d0ad:      	jne	0x1188d797 <js_object_get_field_by_name+0x2357>
1188d0b3:      	cmpb	$0x52, 0x1c(%r13)
1188d0b8:      	jne	0x1188d797 <js_object_get_field_by_name+0x2357>
1188d0be:      	cmpb	$0x5f, 0x1d(%r13)
1188d0c3:      	jne	0x1188d797 <js_object_get_field_by_name+0x2357>
1188d0c9:      	cmpb	$0x45, 0x1e(%r13)
1188d0ce:      	jne	0x1188d797 <js_object_get_field_by_name+0x2357>
1188d0d4:      	cmpb	$0x4c, 0x1f(%r13)
1188d0d9:      	jne	0x1188d797 <js_object_get_field_by_name+0x2357>
1188d0df:      	cmpb	$0x45, 0x20(%r13)
1188d0e4:      	jne	0x1188d797 <js_object_get_field_by_name+0x2357>
1188d0ea:      	cmpb	$0x4d, 0x21(%r13)
1188d0ef:      	jne	0x1188d797 <js_object_get_field_by_name+0x2357>
1188d0f5:      	cmpb	$0x45, 0x22(%r13)
1188d0fa:      	jne	0x1188d797 <js_object_get_field_by_name+0x2357>
1188d100:      	cmpb	$0x4e, 0x23(%r13)
1188d105:      	jne	0x1188d797 <js_object_get_field_by_name+0x2357>
1188d10b:      	cmpb	$0x54, 0x24(%r13)
1188d110:      	jne	0x1188d797 <js_object_get_field_by_name+0x2357>
1188d116:      	jmp	0x1188f2cf <js_object_get_field_by_name+0x3e8f>
1188d11b:      	cmpq	$0x8, %rbx
1188d11f:      	je	0x1188d665 <js_object_get_field_by_name+0x2225>
1188d125:      	cmpq	$0xa, %rbx
1188d129:      	jne	0x1188c740 <js_object_get_field_by_name+0x1300>
1188d12f:      	movq	-0x88(%rbp), %rdx
1188d136:      	movq	(%rdx), %rax
1188d139:      	movabsq	$0x7473696765726e75, %rcx # imm = 0x7473696765726E75
1188d143:      	xorq	%rcx, %rax
1188d146:      	movzwl	0x8(%rdx), %ecx
1188d14a:      	xorq	$0x7265, %rcx           # imm = 0x7265
1188d151:      	orq	%rax, %rcx
1188d154:      	jne	0x1188c740 <js_object_get_field_by_name+0x1300>
1188d15a:      	jmp	0x1188d67f <js_object_get_field_by_name+0x223f>
1188d15f:      	cmpb	$0x75, 0x15(%r13)
1188d164:      	jne	0x1188d797 <js_object_get_field_by_name+0x2357>
1188d16a:      	cmpb	$0x66, 0x16(%r13)
1188d16f:      	jne	0x1188d797 <js_object_get_field_by_name+0x2357>
1188d175:      	cmpb	$0x66, 0x17(%r13)
1188d17a:      	jne	0x1188d797 <js_object_get_field_by_name+0x2357>
1188d180:      	cmpb	$0x65, 0x18(%r13)
1188d185:      	jne	0x1188d797 <js_object_get_field_by_name+0x2357>
1188d18b:      	cmpb	$0x72, 0x19(%r13)
1188d190:      	jne	0x1188d797 <js_object_get_field_by_name+0x2357>
1188d196:      	jmp	0x1188f109 <js_object_get_field_by_name+0x3cc9>
1188d19b:      	cmpb	$0x66, 0x19(%r13)
1188d1a0:      	jne	0x1188d1d0 <js_object_get_field_by_name+0x1d90>
1188d1a2:      	cmpb	$0x66, 0x1a(%r13)
1188d1a7:      	jne	0x1188d1d0 <js_object_get_field_by_name+0x1d90>
1188d1a9:      	cmpb	$0x73, 0x1b(%r13)
1188d1ae:      	jne	0x1188d1d0 <js_object_get_field_by_name+0x1d90>
1188d1b0:      	cmpb	$0x65, 0x1c(%r13)
1188d1b5:      	jne	0x1188d1d0 <js_object_get_field_by_name+0x1d90>
1188d1b7:      	cmpb	$0x74, 0x1d(%r13)
1188d1bc:      	je	0x1188ee9c <js_object_get_field_by_name+0x3a5c>
1188d1c2:      	nopw	%cs:(%rax,%rax)
1188d1d0:      	movq	%r12, %rdi
1188d1d3:      	callq	0x11538370 <_RNvNtNtCscI5nJwKNRh4_13perry_runtime6object15prototype_chain23object_static_prototype>
1188d1d8:      	testb	$0x1, %al
1188d1da:      	je	0x1188d220 <js_object_get_field_by_name+0x1de0>
1188d1dc:      	movabsq	$0x7ffc000000000001, %rax # imm = 0x7FFC000000000001
1188d1e6:      	incq	%rax
1188d1e9:      	cmpq	%rax, %rdx
1188d1ec:      	je	0x1188d29c <js_object_get_field_by_name+0x1e5c>
1188d1f2:      	movq	%r12, %rdi
1188d1f5:      	callq	0x11538370 <_RNvNtNtCscI5nJwKNRh4_13perry_runtime6object15prototype_chain23object_static_prototype>
1188d1fa:      	cmpq	$0x1, %rax
1188d1fe:      	jne	0x1188d29c <js_object_get_field_by_name+0x1e5c>
1188d204:      	movq	%r12, %rdi
1188d207:      	movq	%rdx, %rsi
1188d20a:      	movq	-0x30(%rbp), %rdx
1188d20e:      	callq	0x11539540 <_RNvNtNtCscI5nJwKNRh4_13perry_runtime6object15prototype_chain38resolve_inherited_field_from_prototype>
1188d213:      	testb	$0x1, %al
1188d215:      	je	0x1188d29c <js_object_get_field_by_name+0x1e5c>
1188d21b:      	jmp	0x1188e0d6 <js_object_get_field_by_name+0x2c96>
1188d220:      	movl	$0xa, %esi
1188d225:      	leaq	0x2a73907(%rip), %rdi   # 0x14300b33 <anon.65d6174ee4273d212d69e4c9be928638.2838.llvm.16259376971001104057+0x653>
1188d22c:      	callq	*0x3a8b43e(%rip)        # 0x15318670 <_GLOBAL_OFFSET_TABLE_+0x610>
1188d232:      	movq	%xmm0, %rdi
1188d237:      	movq	%rdi, %rax
1188d23a:      	movabsq	$-0x1000000000000, %rcx # imm = 0xFFFF000000000000
1188d244:      	andq	%rcx, %rax
1188d247:      	movabsq	$0x7ffc000000000001, %rsi # imm = 0x7FFC000000000001
1188d251:      	movabsq	$0x7ffd000000000000, %rcx # imm = 0x7FFD000000000000
1188d25b:      	cmpq	%rcx, %rax
1188d25e:      	jne	0x1188d286 <js_object_get_field_by_name+0x1e46>
1188d260:      	movabsq	$0xffffffffffff, %rax   # imm = 0xFFFFFFFFFFFF
1188d26a:      	andq	%rax, %rdi
1188d26d:      	je	0x1188d286 <js_object_get_field_by_name+0x1e46>
1188d26f:      	movl	$0x9, %edx
1188d274:      	leaq	0x2a71985(%rip), %rsi   # 0x142fec00 <anon.65d6174ee4273d212d69e4c9be928638.837.llvm.16259376971001104057+0x21>
1188d27b:      	callq	*0x3a8ccdf(%rip)        # 0x15319f60 <_GLOBAL_OFFSET_TABLE_+0x1f00>
1188d281:      	movq	%xmm0, %rsi
1188d286:      	movq	%r12, %rdi
1188d289:      	movq	-0x30(%rbp), %rdx
1188d28d:      	callq	0x11539540 <_RNvNtNtCscI5nJwKNRh4_13perry_runtime6object15prototype_chain38resolve_inherited_field_from_prototype>
1188d292:      	cmpq	$0x1, %rax
1188d296:      	je	0x1188e0d6 <js_object_get_field_by_name+0x2c96>
1188d29c:      	movq	%r12, %rdi
1188d29f:      	callq	0x1150dca0 <_RNvNtNtCscI5nJwKNRh4_13perry_runtime6buffer6header13is_secret_key>
1188d2a4:      	testb	%al, %al
1188d2a6:      	movq	-0x30(%rbp), %rsi
1188d2aa:      	movq	-0x78(%rbp), %r15
1188d2ae:      	je	0x1188e83d <js_object_get_field_by_name+0x33fd>
1188d2b4:      	testq	%r15, %r15
1188d2b7:      	je	0x1188d2f0 <js_object_get_field_by_name+0x1eb0>
1188d2b9:      	movabsq	$0x7ff8ffffffffffff, %rax # imm = 0x7FF8FFFFFFFFFFFF
1188d2c3:      	cmpq	%rax, %r14
1188d2c6:      	movabsq	$0xffffffffffff, %r13   # imm = 0xFFFFFFFFFFFF
1188d2d0:      	movabsq	$-0x1000000000000, %rcx # imm = 0xFFFF000000000000
1188d2da:      	movdqa	-0x50(%rbp), %xmm0
1188d2df:      	jg	0x1188d312 <js_object_get_field_by_name+0x1ed2>
1188d2e1:      	jmp	0x1188dcff <js_object_get_field_by_name+0x28bf>
1188d2e6:      	nopw	%cs:(%rax,%rax)
1188d2f0:      	testq	%r14, %r14
1188d2f3:      	movabsq	$0xffffffffffff, %r13   # imm = 0xFFFFFFFFFFFF
1188d2fd:      	movabsq	$-0x1000000000000, %rcx # imm = 0xFFFF000000000000
1188d307:      	movdqa	-0x50(%rbp), %xmm0
1188d30c:      	je	0x1188dcff <js_object_get_field_by_name+0x28bf>
1188d312:      	movq	%r14, %rax
1188d315:      	andq	%rcx, %rax
1188d318:      	movabsq	$0x7ff9000000000000, %rcx # imm = 0x7FF9000000000000
1188d322:      	cmpq	%rcx, %rax
1188d325:      	je	0x1188dbc3 <js_object_get_field_by_name+0x2783>
1188d32b:      	movabsq	$0x7fff000000000000, %rcx # imm = 0x7FFF000000000000
1188d335:      	cmpq	%rcx, %rax
1188d338:      	je	0x1188dbc3 <js_object_get_field_by_name+0x2783>
1188d33e:      	movq	%r14, %r12
1188d341:      	testq	%r15, %r15
1188d344:      	je	0x1188d355 <js_object_get_field_by_name+0x1f15>
1188d346:      	cmpl	$0x7ffd, %r15d          # imm = 0x7FFD
1188d34d:      	jne	0x1188d3b0 <js_object_get_field_by_name+0x1f70>
1188d34f:      	movq	%r14, %r12
1188d352:      	andq	%r13, %r12
1188d355:      	testq	%r12, %r12
1188d358:      	je	0x1188d3b0 <js_object_get_field_by_name+0x1f70>
1188d35a:      	movl	0x4(%rsi), %edx
1188d35d:      	leaq	-0x68(%rbp), %rdi
1188d361:      	movq	-0x38(%rbp), %rsi
1188d365:      	callq	*0x3a914ed(%rip)        # 0x1531e858 <_GLOBAL_OFFSET_TABLE_+0x67f8>
1188d36b:      	cmpb	$0x0, -0x68(%rbp)
1188d36f:      	jne	0x1188d38c <js_object_get_field_by_name+0x1f4c>
1188d371:      	movq	-0x60(%rbp), %rsi
1188d375:      	movq	-0x58(%rbp), %rdx
1188d379:      	movq	%r12, %rdi
1188d37c:      	callq	*0x3a9e8fe(%rip)        # 0x1532bc80 <_GLOBAL_OFFSET_TABLE_+0x13c20>
1188d382:      	cmpq	$0x1, %rax
1188d386:      	je	0x1188e2b0 <js_object_get_field_by_name+0x2e70>
1188d38c:      	cmpq	$0x100000, %r12         # imm = 0x100000
1188d393:      	movq	-0x30(%rbp), %rsi
1188d397:      	movdqa	-0x50(%rbp), %xmm0
1188d39c:      	jae	0x1188d3b3 <js_object_get_field_by_name+0x1f73>
1188d39e:      	jmp	0x1188e188 <js_object_get_field_by_name+0x2d48>
1188d3a3:      	nopw	%cs:(%rax,%rax)
1188d3b0:      	xorl	%r12d, %r12d
1188d3b3:      	movq	%r12, %rax
1188d3b6:      	shrq	$0x3, %rax
1188d3ba:      	movabsq	$-0x61c8864680b583eb, %rcx # imm = 0x9E3779B97F4A7C15
1188d3c4:      	imulq	%rcx, %rax
1188d3c8:      	movq	%rax, %rcx
1188d3cb:      	shrq	$0x36, %rcx
1188d3cf:      	movq	%rax, %rdx
1188d3d2:      	shrq	$0x3c, %rdx
1188d3d6:      	leaq	0x54e8343(%rip), %rdi   # 0x16d75720 <_RNvNtNtCscI5nJwKNRh4_13perry_runtime13native_handle9canonical28CANONICAL_HANDLE_ADDR_FILTER.llvm.16259376971001104057>
1188d3dd:      	movq	(%rdi,%rdx,8), %rdx
1188d3e1:      	btq	%rcx, %rdx
1188d3e5:      	jae	0x1188d490 <js_object_get_field_by_name+0x2050>
1188d3eb:      	movq	%rax, %rcx
1188d3ee:      	shrq	$0x2c, %rcx
1188d3f2:      	movq	%rax, %rdx
1188d3f5:      	shrq	$0x32, %rdx
1188d3f9:      	andl	$0xf, %edx
1188d3fc:      	leaq	0x54e831d(%rip), %rdi   # 0x16d75720 <_RNvNtNtCscI5nJwKNRh4_13perry_runtime13native_handle9canonical28CANONICAL_HANDLE_ADDR_FILTER.llvm.16259376971001104057>
1188d403:      	movq	(%rdi,%rdx,8), %rdx
1188d407:      	btq	%rcx, %rdx
1188d40b:      	jae	0x1188d490 <js_object_get_field_by_name+0x2050>
1188d411:      	movq	%rax, %rcx
1188d414:      	shrq	$0x22, %rcx
1188d418:      	shrq	$0x28, %rax
1188d41c:      	andl	$0xf, %eax
1188d41f:      	leaq	0x54e82fa(%rip), %rdx   # 0x16d75720 <_RNvNtNtCscI5nJwKNRh4_13perry_runtime13native_handle9canonical28CANONICAL_HANDLE_ADDR_FILTER.llvm.16259376971001104057>
1188d426:      	movq	(%rdx,%rax,8), %rax
1188d42a:      	shrq	%cl, %rax
1188d42d:      	testq	%r12, %r12
1188d430:      	je	0x1188d490 <js_object_get_field_by_name+0x2050>
1188d432:      	testb	$0x1, %al
1188d434:      	je	0x1188d490 <js_object_get_field_by_name+0x2050>
1188d436:      	movabsq	$0x800000000000, %rax   # imm = 0x800000000000
1188d440:      	decq	%rax
1188d443:      	cmpq	%rax, %r12
1188d446:      	ja	0x1188d490 <js_object_get_field_by_name+0x2050>
1188d448:      	leaq	-0x8(%r12), %rbx
1188d44d:      	movq	%rbx, %rdi
1188d450:      	callq	*0x3a8fb82(%rip)        # 0x1531cfd8 <_GLOBAL_OFFSET_TABLE_+0x4f78>
1188d456:      	movdqa	-0x50(%rbp), %xmm0
1188d45b:      	movq	-0x30(%rbp), %rsi
1188d45f:      	testb	%al, %al
1188d461:      	je	0x1188d490 <js_object_get_field_by_name+0x2050>
1188d463:      	cmpb	$0xf, (%rbx)
1188d466:      	jne	0x1188d490 <js_object_get_field_by_name+0x2050>
1188d468:      	movabsq	$0x5045525259484e44, %rax # imm = 0x5045525259484E44
1188d472:      	cmpq	%rax, (%r12)
1188d476:      	jne	0x1188d490 <js_object_get_field_by_name+0x2050>
1188d478:      	testb	$0x1, 0x1c(%r12)
1188d47e:      	je	0x1188d490 <js_object_get_field_by_name+0x2050>
1188d480:      	cmpb	$0x0, 0x1b(%r12)
1188d486:      	je	0x1188e188 <js_object_get_field_by_name+0x2d48>
1188d48c:      	nopl	(%rax)
1188d490:      	movzwl	%r15w, %r12d
1188d494:      	cmpl	$0x7ffc, %r12d          # imm = 0x7FFC
1188d49b:      	jg	0x1188d4c0 <js_object_get_field_by_name+0x2080>
1188d49d:      	movq	%r14, %rbx
1188d4a0:      	testl	%r12d, %r12d
1188d4a3:      	jne	0x1188de08 <js_object_get_field_by_name+0x29c8>
1188d4a9:      	testq	%rbx, %rbx
1188d4ac:      	jne	0x1188d4dc <js_object_get_field_by_name+0x209c>
1188d4ae:      	jmp	0x1188da28 <js_object_get_field_by_name+0x25e8>
1188d4b3:      	nopw	%cs:(%rax,%rax)
1188d4c0:      	cmpl	$0x7ffd, %r12d          # imm = 0x7FFD
1188d4c7:      	jne	0x1188de42 <js_object_get_field_by_name+0x2a02>
1188d4cd:      	movq	%r14, %rbx
1188d4d0:      	andq	%r13, %rbx
1188d4d3:      	testq	%rbx, %rbx
1188d4d6:      	je	0x1188da28 <js_object_get_field_by_name+0x25e8>
1188d4dc:      	leaq	0x54e7afd(%rip), %rax   # 0x16d74fe0 <_RNvNtCscI5nJwKNRh4_13perry_runtime10typedarray27TYPED_ARRAY_EVER_REGISTERED>
1188d4e3:      	movzbl	(%rax), %eax
1188d4e6:      	testb	%al, %al
1188d4e8:      	je	0x1188d520 <js_object_get_field_by_name+0x20e0>
1188d4ea:      	leaq	0x3ac2ad7(%rip), %rax   # 0x1534ffc8 <_RNvNtCscI5nJwKNRh4_13perry_runtime10typedarray23TYPED_ARRAY_ADDR_WINDOW>
1188d4f1:      	movq	(%rax), %rax
1188d4f4:      	cmpq	%rax, %rbx
1188d4f7:      	jb	0x1188d520 <js_object_get_field_by_name+0x20e0>
1188d4f9:      	leaq	0x3ac2ac8(%rip), %rax   # 0x1534ffc8 <_RNvNtCscI5nJwKNRh4_13perry_runtime10typedarray23TYPED_ARRAY_ADDR_WINDOW>
1188d500:      	movq	0x8(%rax), %rax
1188d504:      	cmpq	%rax, %rbx
1188d507:      	ja	0x1188d520 <js_object_get_field_by_name+0x20e0>
1188d509:      	movq	%rbx, %rdi
1188d50c:      	callq	*0x3aa271e(%rip)        # 0x1532fc30 <_GLOBAL_OFFSET_TABLE_+0x17bd0>
1188d512:      	testb	$0x1, %al
1188d514:      	jne	0x1188da28 <js_object_get_field_by_name+0x25e8>
1188d51a:      	nopw	(%rax,%rax)
1188d520:      	movq	%rbx, %rdi
1188d523:      	callq	0x1150eed0 <_RNvNtNtCscI5nJwKNRh4_13perry_runtime6buffer6header20is_registered_buffer.llvm.16259376971001104057>
1188d528:      	movabsq	$-0x800000000000, %rdx  # imm = 0xFFFF800000000000
1188d532:      	leaq	(%rbx,%rdx), %rcx
1188d536:      	addq	$0x100000, %rdx         # imm = 0x100000
1188d53d:      	cmpq	%rdx, %rcx
1188d540:      	jb	0x1188da28 <js_object_get_field_by_name+0x25e8>
1188d546:      	testb	%al, %al
1188d548:      	jne	0x1188da28 <js_object_get_field_by_name+0x25e8>
1188d54e:      	cmpb	$0x11, -0x8(%rbx)
1188d552:      	jne	0x1188da28 <js_object_get_field_by_name+0x25e8>
1188d558:      	movq	%rbx, %rdi
1188d55b:      	callq	0x1150eed0 <_RNvNtNtCscI5nJwKNRh4_13perry_runtime6buffer6header20is_registered_buffer.llvm.16259376971001104057>
1188d560:      	testb	%al, %al
1188d562:      	jne	0x1188da28 <js_object_get_field_by_name+0x25e8>
1188d568:      	movq	-0x30(%rbp), %rax
1188d56c:      	movl	0x4(%rax), %r15d
1188d570:      	leaq	-0x68(%rbp), %rdi
1188d574:      	movq	-0x38(%rbp), %rsi
1188d578:      	movq	%r15, %rdx
1188d57b:      	callq	*0x3a912d7(%rip)        # 0x1531e858 <_GLOBAL_OFFSET_TABLE_+0x67f8>
1188d581:      	cmpb	$0x0, -0x68(%rbp)
1188d585:      	movabsq	$0x7ffd000000000000, %r12 # imm = 0x7FFD000000000000
1188d58f:      	jne	0x1188d5b6 <js_object_get_field_by_name+0x2176>
1188d591:      	movq	-0x60(%rbp), %rdx
1188d595:      	movq	-0x58(%rbp), %rcx
1188d599:      	leaq	(%rbx,%r12), %rax
1188d59d:      	movq	%rax, %xmm0
1188d5a2:      	movq	%rbx, %rdi
1188d5a5:      	xorl	%esi, %esi
1188d5a7:      	callq	0x1152a680 <_RNvNtNtCscI5nJwKNRh4_13perry_runtime6object14exotic_expando23exotic_get_own_property>
1188d5ac:      	cmpq	$0x1, %rax
1188d5b0:      	je	0x1188e2b0 <js_object_get_field_by_name+0x2e70>
1188d5b6:      	cmpl	$0xb, %r15d
1188d5ba:      	jne	0x1188d5ee <js_object_get_field_by_name+0x21ae>
1188d5bc:      	movq	-0x38(%rbp), %rdx
1188d5c0:      	movzwl	0x8(%rdx), %eax
1188d5c4:      	movzbl	0xa(%rdx), %ecx
1188d5c8:      	shll	$0x10, %ecx
1188d5cb:      	orq	%rax, %rcx
1188d5ce:      	movq	(%rdx), %rax
1188d5d1:      	movabsq	$0x63757274736e6f63, %rdx # imm = 0x63757274736E6F63
1188d5db:      	xorq	%rdx, %rax
1188d5de:      	xorq	$0x726f74, %rcx         # imm = 0x726F74
1188d5e5:      	orq	%rax, %rcx
1188d5e8:      	je	0x1188e29e <js_object_get_field_by_name+0x2e5e>
1188d5ee:      	movl	$0x4, %esi
1188d5f3:      	leaq	0x2a5ed9e(%rip), %rdi   # 0x142ec398 <anon.65d6174ee4273d212d69e4c9be928638.5290.llvm.16259376971001104057+0x1c>
1188d5fa:      	callq	*0x3a8b070(%rip)        # 0x15318670 <_GLOBAL_OFFSET_TABLE_+0x610>
1188d600:      	movq	%xmm0, %rdi
1188d605:      	movq	%rdi, %rax
1188d608:      	movabsq	$-0x1000000000000, %rbx # imm = 0xFFFF000000000000
1188d612:      	andq	%rbx, %rax
1188d615:      	cmpq	%r12, %rax
1188d618:      	jne	0x1188e83d <js_object_get_field_by_name+0x33fd>
1188d61e:      	andq	%r13, %rdi
1188d621:      	movl	$0x9, %edx
1188d626:      	leaq	0x2a715d3(%rip), %rsi   # 0x142fec00 <anon.65d6174ee4273d212d69e4c9be928638.837.llvm.16259376971001104057+0x21>
1188d62d:      	callq	*0x3a8c92d(%rip)        # 0x15319f60 <_GLOBAL_OFFSET_TABLE_+0x1f00>
1188d633:      	movq	%xmm0, %r14
1188d638:      	movq	%r14, %rax
1188d63b:      	andq	%rbx, %rax
1188d63e:      	cmpq	%r12, %rax
1188d641:      	jne	0x1188e83d <js_object_get_field_by_name+0x33fd>
1188d647:      	andq	%r13, %r14
1188d64a:      	je	0x1188e83d <js_object_get_field_by_name+0x33fd>
1188d650:      	movq	-0x30(%rbp), %rbx
1188d654:      	testq	%rbx, %rbx
1188d657:      	movq	%rbx, %r8
1188d65a:      	jne	0x1188b584 <js_object_get_field_by_name+0x144>
1188d660:      	jmp	0x1188b5b0 <js_object_get_field_by_name+0x170>
1188d665:      	movabsq	$0x7265747369676572, %rax # imm = 0x7265747369676572
1188d66f:      	movq	-0x88(%rbp), %rcx
1188d676:      	cmpq	%rax, (%rcx)
1188d679:      	jne	0x1188c740 <js_object_get_field_by_name+0x1300>
1188d67f:      	movl	$0x14, %esi
1188d684:      	leaq	0x2ab2cda(%rip), %rdi   # 0x14340365 <anon.65d6174ee4273d212d69e4c9be928638.10935.llvm.16259376971001104057+0x3c4>
1188d68b:      	callq	*0x3a8afdf(%rip)        # 0x15318670 <_GLOBAL_OFFSET_TABLE_+0x610>
1188d691:      	movq	%xmm0, %rdi
1188d696:      	movq	%rdi, %rax
1188d699:      	movabsq	$-0x1000000000000, %rcx # imm = 0xFFFF000000000000
1188d6a3:      	andq	%rcx, %rax
1188d6a6:      	movabsq	$0x7ffd000000000000, %rcx # imm = 0x7FFD000000000000
1188d6b0:      	cmpq	%rcx, %rax
1188d6b3:      	setne	%al
1188d6b6:      	movabsq	$0xffffffffffff, %rcx   # imm = 0xFFFFFFFFFFFF
1188d6c0:      	andq	%rcx, %rdi
1188d6c3:      	sete	%cl
1188d6c6:      	orb	%al, %cl
1188d6c8:      	jne	0x1188c740 <js_object_get_field_by_name+0x1300>
1188d6ce:      	movl	$0x9, %edx
1188d6d3:      	leaq	0x2a71526(%rip), %rsi   # 0x142fec00 <anon.65d6174ee4273d212d69e4c9be928638.837.llvm.16259376971001104057+0x21>
1188d6da:      	callq	*0x3a8c880(%rip)        # 0x15319f60 <_GLOBAL_OFFSET_TABLE_+0x1f00>
1188d6e0:      	movq	%xmm0, %r15
1188d6e5:      	movabsq	$0x7ffc000000000001, %rax # imm = 0x7FFC000000000001
1188d6ef:      	cmpq	%rax, %r15
1188d6f2:      	je	0x1188c740 <js_object_get_field_by_name+0x1300>
1188d6f8:      	movq	%r15, %rax
1188d6fb:      	shrq	$0x30, %rax
1188d6ff:      	addl	$0xffff8006, %eax       # imm = 0xFFFF8006
1188d704:      	cmpl	$0x5, %eax
1188d707:      	ja	0x1188d90f <js_object_get_field_by_name+0x24cf>
1188d70d:      	movl	$0x2b, %ecx
1188d712:      	btl	%eax, %ecx
1188d715:      	jae	0x1188d90f <js_object_get_field_by_name+0x24cf>
1188d71b:      	movabsq	$0xffffffffffff, %rax   # imm = 0xFFFFFFFFFFFF
1188d725:      	andq	%rax, %r15
1188d728:      	je	0x1188c740 <js_object_get_field_by_name+0x1300>
1188d72e:      	movq	-0x88(%rbp), %rdi
1188d735:      	movl	%ebx, %esi
1188d737:      	movl	%ebx, %edx
1188d739:      	callq	*0x3a8fb51(%rip)        # 0x1531d290 <_GLOBAL_OFFSET_TABLE_+0x5230>
1188d73f:      	movq	%r15, %rdi
1188d742:      	movq	%rax, %rsi
1188d745:      	callq	0x116ba5d0 <_RNvNtNtNtCscI5nJwKNRh4_13perry_runtime6object13field_get_set9accessors22own_data_field_by_name>
1188d74a:      	cmpq	$0x1, %rax
1188d74e:      	jne	0x1188d8fe <js_object_get_field_by_name+0x24be>
1188d754:      	movq	%rdx, %xmm0
1188d759:      	xorl	%eax, %eax
1188d75b:      	movabsq	$0x7ffc000000000001, %rcx # imm = 0x7FFC000000000001
1188d765:      	cmpq	%rcx, %rdx
1188d768:      	setne	%al
1188d76b:      	jmp	0x1188d900 <js_object_get_field_by_name+0x24c0>
1188d770:      	cmpb	$0x66, 0x19(%r13)
1188d775:      	jne	0x1188d797 <js_object_get_field_by_name+0x2357>
1188d777:      	cmpb	$0x66, 0x1a(%r13)
1188d77c:      	jne	0x1188d797 <js_object_get_field_by_name+0x2357>
1188d77e:      	cmpb	$0x73, 0x1b(%r13)
1188d783:      	jne	0x1188d797 <js_object_get_field_by_name+0x2357>
1188d785:      	cmpb	$0x65, 0x1c(%r13)
1188d78a:      	jne	0x1188d797 <js_object_get_field_by_name+0x2357>
1188d78c:      	cmpb	$0x74, 0x1d(%r13)
1188d791:      	je	0x1188f255 <js_object_get_field_by_name+0x3e15>
1188d797:      	movq	%r12, %rdi
1188d79a:      	callq	0x11538370 <_RNvNtNtCscI5nJwKNRh4_13perry_runtime6object15prototype_chain23object_static_prototype>
1188d79f:      	testb	$0x1, %al
1188d7a1:      	jne	0x1188d1dc <js_object_get_field_by_name+0x1d9c>
1188d7a7:      	movl	$0xa, %esi
1188d7ac:      	leaq	0x2a7aa28(%rip), %rdi   # 0x143081db <anon.65d6174ee4273d212d69e4c9be928638.4211.llvm.16259376971001104057+0x5c70>
1188d7b3:      	movzbl	-0x70(%rbp), %eax
1188d7b7:      	cmpb	$0xb, %al
1188d7b9:      	movabsq	$-0x1000000000000, %rbx # imm = 0xFFFF000000000000
1188d7c3:      	ja	0x1188d7de <js_object_get_field_by_name+0x239e>
1188d7c5:      	movzbl	%al, %eax
1188d7c8:      	leaq	0x2ac7509(%rip), %rcx   # 0x14354cd8 <anon.65d6174ee4273d212d69e4c9be928638.16457.llvm.16259376971001104057+0x7c3>
1188d7cf:      	movzbl	(%rax,%rcx), %esi
1188d7d3:      	leaq	0x39cb45e(%rip), %rcx   # 0x15258c38 <anon.65d6174ee4273d212d69e4c9be928638.16336.llvm.16259376971001104057+0x12e0>
1188d7da:      	movq	(%rcx,%rax,8), %rdi
1188d7de:      	callq	*0x3a8ae8c(%rip)        # 0x15318670 <_GLOBAL_OFFSET_TABLE_+0x610>
1188d7e4:      	movq	%xmm0, %rdi
1188d7e9:      	movq	%rdi, %rax
1188d7ec:      	andq	%rbx, %rax
1188d7ef:      	movabsq	$0x7ffc000000000001, %rsi # imm = 0x7FFC000000000001
1188d7f9:      	movabsq	$0x7ffd000000000000, %rcx # imm = 0x7FFD000000000000
1188d803:      	cmpq	%rcx, %rax
1188d806:      	je	0x1188d260 <js_object_get_field_by_name+0x1e20>
1188d80c:      	jmp	0x1188d286 <js_object_get_field_by_name+0x1e46>
1188d811:      	andl	$0xbfffffff, %edx       # imm = 0xBFFFFFFF
1188d817:      	movq	%r14, %rdi
1188d81a:      	movq	%rdx, %rsi
1188d81d:      	callq	0x115695b0 <_RNvNtNtCscI5nJwKNRh4_13perry_runtime6object5spill12overflow_get>
1188d822:      	movq	%r15, %rsi
1188d825:      	movabsq	$0x7ffc000000000001, %rcx # imm = 0x7FFC000000000001
1188d82f:      	addq	$0xf, %rcx
1188d833:      	cmpq	%rcx, %rdx
1188d836:      	setne	%cl
1188d839:      	testb	%cl, %al
1188d83b:      	jne	0x1188e0d6 <js_object_get_field_by_name+0x2c96>
1188d841:      	movl	0x4(%r14), %ecx
1188d845:      	cmpl	$0xbfffffff, %ecx       # imm = 0xBFFFFFFF
1188d84b:      	jg	0x1188d8bf <js_object_get_field_by_name+0x247f>
1188d84d:      	movl	(%r14), %edi
1188d850:      	movl	0x3ac55b1(%rip), %r15d  # 0x15352e08 <_RNvNvNtNtCscI5nJwKNRh4_13perry_runtime6object14own_read_cache14OWN_READ_CACHE4SLOT+0x10>
1188d857:      	cmpl	$0x300, %r15d           # imm = 0x300
1188d85e:      	movq	-0x80(%rbp), %rax
1188d862:      	jae	0x1188d9ac <js_object_get_field_by_name+0x256c>
1188d868:      	cmpq	$0x0, 0x78(%rax)
1188d86d:      	je	0x1188d976 <js_object_get_field_by_name+0x2536>
1188d873:      	movq	0x1e8(%rax,%r15,8), %rdx
1188d87b:      	testq	%rdx, %rdx
1188d87e:      	je	0x1188d9ac <js_object_get_field_by_name+0x256c>
1188d884:      	shlq	$0x20, %rdi
1188d888:      	orq	%rcx, %rdi
1188d88b:      	callq	0x11142ab0 <_RNCNvNtNtCscI5nJwKNRh4_13perry_runtime6object14own_read_cache5probe0B7_>
1188d890:      	testb	$0x1, %al
1188d892:      	je	0x1188d8bf <js_object_get_field_by_name+0x247f>
1188d894:      	testl	$0x40000000, %edx       # imm = 0x40000000
1188d89a:      	jne	0x1188d8c8 <js_object_get_field_by_name+0x2488>
1188d89c:      	movl	%edx, %eax
1188d89e:      	movq	0x10(%r14,%rax,8), %rax
1188d8a3:      	movabsq	$0x7ffc000000000010, %rcx # imm = 0x7FFC000000000010
1188d8ad:      	cmpq	%rcx, %rax
1188d8b0:      	movq	-0x30(%rbp), %r8
1188d8b4:      	je	0x1188b72e <js_object_get_field_by_name+0x2ee>
1188d8ba:      	jmp	0x1188ed4d <js_object_get_field_by_name+0x390d>
1188d8bf:      	movq	-0x30(%rbp), %r8
1188d8c3:      	jmp	0x1188b72e <js_object_get_field_by_name+0x2ee>
1188d8c8:      	andl	$0xbfffffff, %edx       # imm = 0xBFFFFFFF
1188d8ce:      	movq	%r14, %rdi
1188d8d1:      	movq	%rdx, %rsi
1188d8d4:      	callq	0x115695b0 <_RNvNtNtCscI5nJwKNRh4_13perry_runtime6object5spill12overflow_get>
1188d8d9:      	movabsq	$0x7ffc000000000001, %rcx # imm = 0x7FFC000000000001
1188d8e3:      	addq	$0xf, %rcx
1188d8e7:      	cmpq	%rcx, %rdx
1188d8ea:      	setne	%cl
1188d8ed:      	testb	%cl, %al
1188d8ef:      	movq	-0x30(%rbp), %r8
1188d8f3:      	je	0x1188b72e <js_object_get_field_by_name+0x2ee>
1188d8f9:      	jmp	0x1188e0d6 <js_object_get_field_by_name+0x2c96>
1188d8fe:      	xorl	%eax, %eax
1188d900:      	cmpq	$0x1, %rax
1188d904:      	jne	0x1188c740 <js_object_get_field_by_name+0x1300>
1188d90a:      	jmp	0x1188e2b0 <js_object_get_field_by_name+0x2e70>
1188d90f:      	leaq	-0x1(%r15), %rax
1188d913:      	movabsq	$0xffffffffffff, %rcx   # imm = 0xFFFFFFFFFFFF
1188d91d:      	cmpq	%rcx, %rax
1188d920:      	jae	0x1188c740 <js_object_get_field_by_name+0x1300>
1188d926:      	jmp	0x1188d72e <js_object_get_field_by_name+0x22ee>
1188d92b:      	callq	*0x3a96acf(%rip)        # 0x15324400 <_GLOBAL_OFFSET_TABLE_+0xc3a0>
1188d931:      	movq	-0x80(%rbp), %rdi
1188d935:      	movq	-0x30(%rbp), %r8
1188d939:      	jmp	0x1188b91a <js_object_get_field_by_name+0x4da>
1188d93e:      	cmpl	$0x1, %eax
1188d941:      	jne	0x1188efe1 <js_object_get_field_by_name+0x3ba1>
1188d947:      	movq	%rbx, %rdi
1188d94a:      	leaq	-0x787b01(%rip), %rsi   # 0x11105e50 <_RINvNtNtNtNtCsjFfivMnupPH_3std3sys12thread_local6native5eager7destroyINtNtCs9ueeiBwVTSo_4core4cell7RefCellINtNtCscv7DEBI70Kq_5alloc3vec3VecTyyEEEECscI5nJwKNRh4_13perry_runtime.llvm.16259376971001104057>
1188d951:      	callq	*0x3aa0799(%rip)        # 0x1532e0f0 <_GLOBAL_OFFSET_TABLE_+0x16090>
1188d957:      	movb	$0x0, 0x20(%rbx)
1188d95b:      	movq	(%rbx), %rax
1188d95e:      	movabsq	$0x7fffffffffffffff, %rcx # imm = 0x7FFFFFFFFFFFFFFF
1188d968:      	cmpq	%rcx, %rax
1188d96b:      	jb	0x1188be14 <js_object_get_field_by_name+0x9d4>
1188d971:      	jmp	0x1188ed26 <js_object_get_field_by_name+0x38e6>
1188d976:      	movq	%rdi, -0x50(%rbp)
1188d97a:      	movq	%rax, %rdi
1188d97d:      	movq	%rsi, -0x70(%rbp)
1188d981:      	movq	%rcx, -0x78(%rbp)
1188d985:      	callq	*0x3a96a75(%rip)        # 0x15324400 <_GLOBAL_OFFSET_TABLE_+0xc3a0>
1188d98b:      	movq	-0x78(%rbp), %rcx
1188d98f:      	movq	-0x70(%rbp), %rsi
1188d993:      	movq	-0x80(%rbp), %rax
1188d997:      	movq	-0x50(%rbp), %rdi
1188d99b:      	movq	0x1e8(%rax,%r15,8), %rdx
1188d9a3:      	testq	%rdx, %rdx
1188d9a6:      	jne	0x1188d884 <js_object_get_field_by_name+0x2444>
1188d9ac:      	movq	%rcx, -0x78(%rbp)
1188d9b0:      	movq	%rdi, -0x50(%rbp)
1188d9b4:      	leaq	0x39ab66d(%rip), %rdi   # 0x15239028 <_RNvNtNtCscI5nJwKNRh4_13perry_runtime6object14own_read_cache14OWN_READ_CACHE>
1188d9bb:      	movq	%rsi, %r15
1188d9be:      	callq	*0x3a8e09c(%rip)        # 0x1531ba60 <_GLOBAL_OFFSET_TABLE_+0x3a00>
1188d9c4:      	movq	-0x78(%rbp), %rcx
1188d9c8:      	movq	%r15, %rsi
1188d9cb:      	movq	-0x50(%rbp), %rdi
1188d9cf:      	movq	%rax, %rdx
1188d9d2:      	jmp	0x1188d884 <js_object_get_field_by_name+0x2444>
1188d9d7:      	movq	%rdi, -0x50(%rbp)
1188d9db:      	movq	%rax, %rdi
1188d9de:      	movq	%rsi, -0x70(%rbp)
1188d9e2:      	callq	*0x3a96a18(%rip)        # 0x15324400 <_GLOBAL_OFFSET_TABLE_+0xc3a0>
1188d9e8:      	movq	-0x70(%rbp), %rsi
1188d9ec:      	movq	-0x80(%rbp), %rax
1188d9f0:      	movq	-0x50(%rbp), %rdi
1188d9f4:      	movq	0x1e8(%rax,%r15,8), %rdx
1188d9fc:      	testq	%rdx, %rdx
1188d9ff:      	jne	0x1188bab6 <js_object_get_field_by_name+0x676>
1188da05:      	movq	%rdi, -0x50(%rbp)
1188da09:      	leaq	0x39accc0(%rip), %rdi   # 0x1523a6d0 <_RNvNtNtCscI5nJwKNRh4_13perry_runtime6object9read_stub9READ_STUB>
1188da10:      	movq	%rsi, %r15
1188da13:      	callq	*0x3a8e047(%rip)        # 0x1531ba60 <_GLOBAL_OFFSET_TABLE_+0x3a00>
1188da19:      	movq	%r15, %rsi
1188da1c:      	movq	-0x50(%rbp), %rdi
1188da20:      	movq	%rax, %rdx
1188da23:      	jmp	0x1188bab6 <js_object_get_field_by_name+0x676>
1188da28:      	movq	%r15, %rax
1188da2b:      	movq	%r14, %r15
1188da2e:      	testw	%ax, %ax
1188da31:      	movq	-0x30(%rbp), %rsi
1188da35:      	movdqa	-0x50(%rbp), %xmm0
1188da3a:      	je	0x1188da5c <js_object_get_field_by_name+0x261c>
1188da3c:      	cmpl	$0x7ffb, %r12d          # imm = 0x7FFB
1188da43:      	je	0x1188de15 <js_object_get_field_by_name+0x29d5>
1188da49:      	cmpl	$0x7ffd, %r12d          # imm = 0x7FFD
1188da50:      	jne	0x1188df5b <js_object_get_field_by_name+0x2b1b>
1188da56:      	movq	%r14, %r15
1188da59:      	andq	%r13, %r15
1188da5c:      	testq	%r15, %r15
1188da5f:      	je	0x1188dc06 <js_object_get_field_by_name+0x27c6>
1188da65:      	leaq	0x54e7574(%rip), %rax   # 0x16d74fe0 <_RNvNtCscI5nJwKNRh4_13perry_runtime10typedarray27TYPED_ARRAY_EVER_REGISTERED>
1188da6c:      	movzbl	(%rax), %eax
1188da6f:      	testb	%al, %al
1188da71:      	je	0x1188daac <js_object_get_field_by_name+0x266c>
1188da73:      	leaq	0x3ac254e(%rip), %rax   # 0x1534ffc8 <_RNvNtCscI5nJwKNRh4_13perry_runtime10typedarray23TYPED_ARRAY_ADDR_WINDOW>
1188da7a:      	movq	(%rax), %rax
1188da7d:      	cmpq	%rax, %r15
1188da80:      	jb	0x1188daac <js_object_get_field_by_name+0x266c>
1188da82:      	leaq	0x3ac253f(%rip), %rax   # 0x1534ffc8 <_RNvNtCscI5nJwKNRh4_13perry_runtime10typedarray23TYPED_ARRAY_ADDR_WINDOW>
1188da89:      	movq	0x8(%rax), %rax
1188da8d:      	cmpq	%rax, %r15
1188da90:      	ja	0x1188daac <js_object_get_field_by_name+0x266c>
1188da92:      	movq	%r15, %rdi
1188da95:      	callq	*0x3aa2195(%rip)        # 0x1532fc30 <_GLOBAL_OFFSET_TABLE_+0x17bd0>
1188da9b:      	movdqa	-0x50(%rbp), %xmm0
1188daa0:      	movq	-0x30(%rbp), %rsi
1188daa4:      	testb	$0x1, %al
1188daa6:      	jne	0x1188dc06 <js_object_get_field_by_name+0x27c6>
1188daac:      	movq	%r15, %rdi
1188daaf:      	callq	0x1150eed0 <_RNvNtNtCscI5nJwKNRh4_13perry_runtime6buffer6header20is_registered_buffer.llvm.16259376971001104057>
1188dab4:      	movdqa	-0x50(%rbp), %xmm0
1188dab9:      	movq	-0x30(%rbp), %rsi
1188dabd:      	movabsq	$-0x800000000000, %rdx  # imm = 0xFFFF800000000000
1188dac7:      	leaq	(%r15,%rdx), %rcx
1188dacb:      	addq	$0x100000, %rdx         # imm = 0x100000
1188dad2:      	cmpq	%rdx, %rcx
1188dad5:      	setb	%cl
1188dad8:      	orb	%al, %cl
1188dada:      	jne	0x1188dc06 <js_object_get_field_by_name+0x27c6>
1188dae0:      	cmpb	$0x12, -0x8(%r15)
1188dae5:      	jne	0x1188dc06 <js_object_get_field_by_name+0x27c6>
1188daeb:      	movl	0x4(%rsi), %r14d
1188daef:      	leaq	-0x68(%rbp), %rdi
1188daf3:      	movq	-0x38(%rbp), %rsi
1188daf7:      	movq	%r14, %rdx
1188dafa:      	callq	*0x3a95538(%rip)        # 0x15323038 <_GLOBAL_OFFSET_TABLE_+0xafd8>
1188db00:      	movabsq	$0x7ffd000000000000, %rax # imm = 0x7FFD000000000000
1188db0a:      	orq	%r15, %rax
1188db0d:      	movq	%rax, %xmm0
1188db12:      	movq	-0x68(%rbp), %r13
1188db16:      	movq	-0x60(%rbp), %rbx
1188db1a:      	movq	-0x58(%rbp), %r12
1188db1e:      	movq	%r15, %rdi
1188db21:      	movl	$0x3, %esi
1188db26:      	movq	%rbx, %rdx
1188db29:      	movq	%r12, %rcx
1188db2c:      	movq	%xmm0, -0x30(%rbp)
1188db31:      	callq	0x1152a680 <_RNvNtNtCscI5nJwKNRh4_13perry_runtime6object14exotic_expando23exotic_get_own_property>
1188db36:      	testb	$0x1, %al
1188db38:      	jne	0x1188dba2 <js_object_get_field_by_name+0x2762>
1188db3a:      	movq	-0x30(%rbp), %xmm0
1188db3f:      	movq	%rbx, %rdi
1188db42:      	movq	%r12, %rsi
1188db45:      	callq	*0x3aa4965(%rip)        # 0x153324b0 <_GLOBAL_OFFSET_TABLE_+0x1a450>
1188db4b:      	testb	$0x1, %al
1188db4d:      	jne	0x1188dba2 <js_object_get_field_by_name+0x2762>
1188db4f:      	movsd	-0x30(%rbp), %xmm0
1188db54:      	movq	%rbx, %rdi
1188db57:      	movq	%r12, %rsi
1188db5a:      	callq	*0x3a945c0(%rip)        # 0x15322120 <_GLOBAL_OFFSET_TABLE_+0xa0c0>
1188db60:      	testb	%al, %al
1188db62:      	je	0x1188e890 <js_object_get_field_by_name+0x3450>
1188db68:      	cmpq	$0x1, %r14
1188db6c:      	movq	%r14, %rdi
1188db6f:      	adcq	$0x0, %rdi
1188db73:      	movl	$0x1, %esi
1188db78:      	callq	*0x3a8dd72(%rip)        # 0x1531b8f0 <_GLOBAL_OFFSET_TABLE_+0x3890>
1188db7e:      	movq	%rax, %r15
1188db81:      	movq	%rax, %rdi
1188db84:      	movq	-0x38(%rbp), %rsi
1188db88:      	movq	%r14, %rdx
1188db8b:      	callq	*0x3a90187(%rip)        # 0x1531dd18 <_GLOBAL_OFFSET_TABLE_+0x5cb8>
1188db91:      	movq	-0x30(%rbp), %xmm0
1188db96:      	movq	%r15, %rdi
1188db99:      	movq	%r14, %rsi
1188db9c:      	callq	*0x3aa4006(%rip)        # 0x15331ba8 <_GLOBAL_OFFSET_TABLE_+0x19b48>
1188dba2:      	testq	%r13, %r13
1188dba5:      	jle	0x1188e2b0 <js_object_get_field_by_name+0x2e70>
1188dbab:      	movq	%rbx, %rdi
1188dbae:      	movq	%xmm0, -0x30(%rbp)
1188dbb3:      	callq	*0x3aa5217(%rip)        # 0x15332dd0 <_GLOBAL_OFFSET_TABLE_+0x1ad70>
1188dbb9:      	movsd	-0x30(%rbp), %xmm0
1188dbbe:      	jmp	0x1188e2b0 <js_object_get_field_by_name+0x2e70>
1188dbc3:      	testq	%rsi, %rsi
1188dbc6:      	jne	0x1188dbe6 <js_object_get_field_by_name+0x27a6>
1188dbc8:      	xorl	%edi, %edi
1188dbca:      	callq	0x112a3da0 <_RNvNtCscI5nJwKNRh4_13perry_runtime6string20string_storage_alloc.llvm.16259376971001104057>
1188dbcf:      	movq	%rax, %rsi
1188dbd2:      	xorpd	%xmm0, %xmm0
1188dbd6:      	movupd	%xmm0, (%rax)
1188dbda:      	movapd	-0x50(%rbp), %xmm0
1188dbdf:      	movl	$0x0, 0x10(%rax)
1188dbe6:      	andq	%r13, %rsi
1188dbe9:      	movabsq	$0x7fff000000000000, %rax # imm = 0x7FFF000000000000
1188dbf3:      	orq	%rax, %rsi
1188dbf6:      	movq	%rsi, %xmm1
1188dbfb:      	callq	*0x3a8eb5f(%rip)        # 0x1531c760 <_GLOBAL_OFFSET_TABLE_+0x4700>
1188dc01:      	jmp	0x1188e2b0 <js_object_get_field_by_name+0x2e70>
1188dc06:      	movq	%r14, %r15
1188dc09:      	cmpw	$0x0, -0x78(%rbp)
1188dc0e:      	je	0x1188dc30 <js_object_get_field_by_name+0x27f0>
1188dc10:      	cmpl	$0x7ffb, %r12d          # imm = 0x7FFB
1188dc17:      	je	0x1188de15 <js_object_get_field_by_name+0x29d5>
1188dc1d:      	cmpl	$0x7ffd, %r12d          # imm = 0x7FFD
1188dc24:      	jne	0x1188df5b <js_object_get_field_by_name+0x2b1b>
1188dc2a:      	andq	%r14, %r13
1188dc2d:      	movq	%r13, %r15
1188dc30:      	leaq	-0x100000(%r15), %rax
1188dc37:      	movabsq	$0x800000000000, %rcx   # imm = 0x800000000000
1188dc41:      	addq	$-0x100000, %rcx        # imm = 0xFFF00000
1188dc48:      	cmpq	%rcx, %rax
1188dc4b:      	jae	0x1188df5b <js_object_get_field_by_name+0x2b1b>
1188dc51:      	cmpb	$0x5, -0x8(%r15)
1188dc56:      	jne	0x1188df5b <js_object_get_field_by_name+0x2b1b>
1188dc5c:      	movq	%r15, %rdi
1188dc5f:      	callq	0x1150eed0 <_RNvNtNtCscI5nJwKNRh4_13perry_runtime6buffer6header20is_registered_buffer.llvm.16259376971001104057>
1188dc64:      	movdqa	-0x50(%rbp), %xmm0
1188dc69:      	testb	%al, %al
1188dc6b:      	jne	0x1188df5b <js_object_get_field_by_name+0x2b1b>
1188dc71:      	movq	%r15, %rdi
1188dc74:      	callq	0x111d9270 <_RNvNtCscI5nJwKNRh4_13perry_runtime10typedarray23lookup_typed_array_kind>
1188dc79:      	movdqa	-0x50(%rbp), %xmm0
1188dc7e:      	movq	-0x30(%rbp), %rcx
1188dc82:      	testb	$0x1, %al
1188dc84:      	jne	0x1188df5b <js_object_get_field_by_name+0x2b1b>
1188dc8a:      	movl	0x4(%rcx), %ebx
1188dc8d:      	movq	%r15, %rdi
1188dc90:      	movl	$0x4, %esi
1188dc95:      	movq	-0x38(%rbp), %rdx
1188dc99:      	movq	%rbx, %rcx
1188dc9c:      	callq	0x1152a680 <_RNvNtNtCscI5nJwKNRh4_13perry_runtime6object14exotic_expando23exotic_get_own_property>
1188dca1:      	cmpq	$0x1, %rax
1188dca5:      	je	0x1188e2b0 <js_object_get_field_by_name+0x2e70>
1188dcab:      	leal	-0x4(%rbx), %eax
1188dcae:      	cmpl	$0x7, %eax
1188dcb1:      	ja	0x1188e83d <js_object_get_field_by_name+0x33fd>
1188dcb7:      	leaq	0x2a6ebfe(%rip), %rcx   # 0x142fc8bc <anon.65d6174ee4273d212d69e4c9be928638.11885.llvm.16259376971001104057+0x102a0>
1188dcbe:      	movslq	(%rcx,%rax,4), %rax
1188dcc2:      	addq	%rcx, %rax
1188dcc5:      	jmpq	*%rax
1188dcc7:      	movq	-0x38(%rbp), %rax
1188dccb:      	cmpb	$0x74, (%rax)
1188dcce:      	jne	0x1188e83d <js_object_get_field_by_name+0x33fd>
1188dcd4:      	movq	-0x30(%rbp), %rax
1188dcd8:      	cmpb	$0x68, 0x15(%rax)
1188dcdc:      	jne	0x1188e83d <js_object_get_field_by_name+0x33fd>
1188dce2:      	cmpb	$0x65, 0x16(%rax)
1188dce6:      	jne	0x1188e83d <js_object_get_field_by_name+0x33fd>
1188dcec:      	movq	-0x30(%rbp), %rax
1188dcf0:      	cmpb	$0x6e, 0x17(%rax)
1188dcf4:      	jne	0x1188e83d <js_object_get_field_by_name+0x33fd>
1188dcfa:      	jmp	0x1188ec22 <js_object_get_field_by_name+0x37e2>
1188dcff:      	movabsq	$0x7fffffffffffffff, %rcx # imm = 0x7FFFFFFFFFFFFFFF
1188dd09:      	andq	%r14, %rcx
1188dd0c:      	movabsq	$-0x10000000000000, %rax # imm = 0xFFF0000000000000
1188dd16:      	addq	%rcx, %rax
1188dd19:      	shrq	$0x35, %rax
1188dd1d:      	cmpl	$0x3ff, %eax            # imm = 0x3FF
1188dd22:      	setae	%al
1188dd25:      	testq	%r14, %r14
1188dd28:      	sets	%bl
1188dd2b:      	orb	%al, %bl
1188dd2d:      	decq	%r14
1188dd30:      	movabsq	$0xffffffffffffe, %rax  # imm = 0xFFFFFFFFFFFFE
1188dd3a:      	cmpq	%rax, %r14
1188dd3d:      	seta	%r14b
1188dd41:      	callq	*0x3aa0ec9(%rip)        # 0x1532ec10 <_GLOBAL_OFFSET_TABLE_+0x16bb0>
1188dd47:      	testb	%bl, %r14b
1188dd4a:      	jne	0x1188dde1 <js_object_get_field_by_name+0x29a1>
1188dd50:      	ucomisd	-0x50(%rbp), %xmm0
1188dd55:      	jne	0x1188dde1 <js_object_get_field_by_name+0x29a1>
1188dd5b:      	jp	0x1188dde1 <js_object_get_field_by_name+0x29a1>
1188dd61:      	movapd	-0x50(%rbp), %xmm1
1188dd66:      	cvttsd2si	%xmm1, %rax
1188dd6b:      	movq	%rax, %rcx
1188dd6e:      	sarq	$0x3f, %rcx
1188dd72:      	movapd	%xmm1, %xmm0
1188dd76:      	subsd	0xde2e42(%rip), %xmm0   # 0x12670bc0 <perry_typed_shape_raw_f64_mask_cli_2_1_112_js____AnonShape_d5b61070a717b2b2+0x8d0>
1188dd7e:      	cvttsd2si	%xmm0, %rdx
1188dd83:      	andq	%rcx, %rdx
1188dd86:      	orq	%rax, %rdx
1188dd89:      	xorl	%eax, %eax
1188dd8b:      	xorpd	%xmm0, %xmm0
1188dd8f:      	ucomisd	%xmm0, %xmm1
1188dd93:      	cmovaeq	%rdx, %rax
1188dd97:      	ucomisd	0xde6331(%rip), %xmm1   # 0x126740d0 <perry_typed_shape_mask_cli_2_1_112_js__fP8+0x30>
1188dd9f:      	movq	$-0x1, %rbx
1188dda6:      	cmovbeq	%rax, %rbx
1188ddaa:      	movq	%rbx, %rax
1188ddad:      	andq	$-0x100000, %rax        # imm = 0xFFF00000
1188ddb3:      	cmpq	$0x100000, %rax         # imm = 0x100000
1188ddb9:      	jne	0x1188dde1 <js_object_get_field_by_name+0x29a1>
1188ddbb:      	leaq	0x5568066(%rip), %rax   # 0x16df5e28 <_RNvNtNtCscI5nJwKNRh4_13perry_runtime6object13class_handles23STREAM_HANDLE_PROBE_PTR>
1188ddc2:      	movq	(%rax), %rax
1188ddc5:      	testq	%rax, %rax
1188ddc8:      	je	0x1188dde1 <js_object_get_field_by_name+0x29a1>
1188ddca:      	movq	%rbx, %rdi
1188ddcd:      	callq	*%rax
1188ddcf:      	testb	$0x1, %al
1188ddd1:      	je	0x1188dde1 <js_object_get_field_by_name+0x29a1>
1188ddd3:      	callq	0x1151e260 <_RNvNtNtCscI5nJwKNRh4_13perry_runtime6object13class_handles24handle_property_dispatch>
1188ddd8:      	testq	%rax, %rax
1188dddb:      	jne	0x1188e03a <js_object_get_field_by_name+0x2bfa>
1188dde1:      	movq	-0x30(%rbp), %rax
1188dde5:      	movl	0x4(%rax), %ebx
1188dde8:      	leaq	-0x68(%rbp), %rdi
1188ddec:      	movq	-0x38(%rbp), %rsi
1188ddf0:      	movq	%rbx, %rdx
1188ddf3:      	callq	*0x3a90a5f(%rip)        # 0x1531e858 <_GLOBAL_OFFSET_TABLE_+0x67f8>
1188ddf9:      	cmpb	$0x0, -0x68(%rbp)
1188ddfd:      	jne	0x1188e0c4 <js_object_get_field_by_name+0x2c84>
1188de03:      	jmp	0x1188e0ac <js_object_get_field_by_name+0x2c6c>
1188de08:      	cmpl	$0x7ffb, %r12d          # imm = 0x7FFB
1188de0f:      	jne	0x1188df5b <js_object_get_field_by_name+0x2b1b>
1188de15:      	movq	0x5567ed4(%rip), %rax   # 0x16df5cf0 <_RNvNtNtCscI5nJwKNRh4_13perry_runtime5value4tags29JS_HANDLE_OBJECT_GET_PROPERTY.0>
1188de1c:      	movabsq	$0x7ffc000000000001, %r15 # imm = 0x7FFC000000000001
1188de26:      	testq	%rax, %rax
1188de29:      	je	0x1188e847 <js_object_get_field_by_name+0x3407>
1188de2f:      	movl	0x4(%rsi), %esi
1188de32:      	movapd	-0x50(%rbp), %xmm0
1188de37:      	movq	-0x38(%rbp), %rdi
1188de3b:      	callq	*%rax
1188de3d:      	jmp	0x1188e2b0 <js_object_get_field_by_name+0x2e70>
1188de42:      	cmpl	$0x7ffe, %r12d          # imm = 0x7FFE
1188de49:      	jne	0x1188df5b <js_object_get_field_by_name+0x2b1b>
1188de4f:      	movl	%r14d, -0x3c(%rbp)
1188de53:      	movabsq	$-0xffff00000000, %rax  # imm = 0xFFFF000100000000
1188de5d:      	andq	%r14, %rax
1188de60:      	movabsq	$0x7ffe000100000000, %r13 # imm = 0x7FFE000100000000
1188de6a:      	cmpq	%r13, %rax
1188de6d:      	setne	%al
1188de70:      	testl	%r14d, %r14d
1188de73:      	sete	%cl
1188de76:      	orb	%al, %cl
1188de78:      	movb	$0x1, %bl
1188de7a:      	jne	0x1188de8e <js_object_get_field_by_name+0x2a4e>
1188de7c:      	movl	%r14d, %edi
1188de7f:      	callq	*0x3a8e783(%rip)        # 0x1531c608 <_GLOBAL_OFFSET_TABLE_+0x45a8>
1188de85:      	movq	-0x30(%rbp), %rsi
1188de89:      	movl	%eax, %ebx
1188de8b:      	xorb	$0x1, %bl
1188de8e:      	movl	0x4(%rsi), %edx
1188de91:      	leaq	-0x68(%rbp), %rdi
1188de95:      	addq	$0x14, %rsi
1188de99:      	movq	%rdx, -0x78(%rbp)
1188de9d:      	callq	*0x3a909b5(%rip)        # 0x1531e858 <_GLOBAL_OFFSET_TABLE_+0x67f8>
1188dea3:      	xorl	%r15d, %r15d
1188dea6:      	cmpb	$0x0, -0x68(%rbp)
1188deaa:      	movl	$0x1, %r12d
1188deb0:      	cmoveq	-0x60(%rbp), %r12
1188deb5:      	cmoveq	-0x58(%rbp), %r15
1188deba:      	cmpq	$0xb, %r15
1188debe:      	setne	%al
1188dec1:      	orb	%bl, %al
1188dec3:      	cmpb	$0x1, %al
1188dec5:      	jne	0x1188e335 <js_object_get_field_by_name+0x2ef5>
1188decb:      	cmpq	$0xb, %r15
1188decf:      	movdqa	-0x50(%rbp), %xmm0
1188ded4:      	je	0x1188e396 <js_object_get_field_by_name+0x2f56>
1188deda:      	cmpq	$0x9, %r15
1188dede:      	jne	0x1188e3cf <js_object_get_field_by_name+0x2f8f>
1188dee4:      	movb	$0x1, %dl
1188dee6:      	testl	%r14d, %r14d
1188dee9:      	je	0x1188e3d1 <js_object_get_field_by_name+0x2f91>
1188deef:      	movabsq	$0x7079746f746f7270, %rax # imm = 0x7079746F746F7270
1188def9:      	xorq	(%r12), %rax
1188defd:      	movzbl	0x8(%r12), %ecx
1188df03:      	xorq	$0x65, %rcx
1188df07:      	orq	%rax, %rcx
1188df0a:      	jne	0x1188e3d1 <js_object_get_field_by_name+0x2f91>
1188df10:      	movl	%r14d, %edi
1188df13:      	callq	*0x3a8e6ef(%rip)        # 0x1531c608 <_GLOBAL_OFFSET_TABLE_+0x45a8>
1188df19:      	movb	$0x1, %dl
1188df1b:      	movdqa	-0x50(%rbp), %xmm0
1188df20:      	testb	%al, %al
1188df22:      	je	0x1188e3d1 <js_object_get_field_by_name+0x2f91>
1188df28:      	testb	%bl, %bl
1188df2a:      	je	0x1188e4af <js_object_get_field_by_name+0x306f>
1188df30:      	movl	%r14d, %edi
1188df33:      	callq	0x116ebf40 <_RNvNtNtNtCscI5nJwKNRh4_13perry_runtime6object14class_registry5state26class_decl_prototype_value>
1188df38:      	movq	%xmm0, %r15
1188df3d:      	movabsq	$0x7ffc000000000001, %rax # imm = 0x7FFC000000000001
1188df47:      	cmpq	%rax, %r15
1188df4a:      	jne	0x1188e847 <js_object_get_field_by_name+0x3407>
1188df50:      	movl	%r14d, %r15d
1188df53:      	orq	%r13, %r15
1188df56:      	jmp	0x1188e847 <js_object_get_field_by_name+0x3407>
1188df5b:      	movabsq	$0x7fffffffffffffff, %rcx # imm = 0x7FFFFFFFFFFFFFFF
1188df65:      	andq	%r14, %rcx
1188df68:      	movabsq	$-0x10000000000000, %rax # imm = 0xFFF0000000000000
1188df72:      	addq	%rcx, %rax
1188df75:      	shrq	$0x35, %rax
1188df79:      	cmpl	$0x3ff, %eax            # imm = 0x3FF
1188df7e:      	setae	%al
1188df81:      	testq	%r14, %r14
1188df84:      	sets	%bl
1188df87:      	orb	%al, %bl
1188df89:      	leaq	-0x1(%r14), %rax
1188df8d:      	movabsq	$0xffffffffffffe, %rcx  # imm = 0xFFFFFFFFFFFFE
1188df97:      	cmpq	%rcx, %rax
1188df9a:      	seta	%r15b
1188df9e:      	callq	*0x3aa0c6c(%rip)        # 0x1532ec10 <_GLOBAL_OFFSET_TABLE_+0x16bb0>
1188dfa4:      	testb	%bl, %r15b
1188dfa7:      	jne	0x1188e04f <js_object_get_field_by_name+0x2c0f>
1188dfad:      	ucomisd	-0x50(%rbp), %xmm0
1188dfb2:      	jne	0x1188e04f <js_object_get_field_by_name+0x2c0f>
1188dfb8:      	jp	0x1188e04f <js_object_get_field_by_name+0x2c0f>
1188dfbe:      	movapd	-0x50(%rbp), %xmm1
1188dfc3:      	cvttsd2si	%xmm1, %rax
1188dfc8:      	movq	%rax, %rcx
1188dfcb:      	sarq	$0x3f, %rcx
1188dfcf:      	movapd	%xmm1, %xmm0
1188dfd3:      	subsd	0xde2be5(%rip), %xmm0   # 0x12670bc0 <perry_typed_shape_raw_f64_mask_cli_2_1_112_js____AnonShape_d5b61070a717b2b2+0x8d0>
1188dfdb:      	cvttsd2si	%xmm0, %rdx
1188dfe0:      	andq	%rcx, %rdx
1188dfe3:      	orq	%rax, %rdx
1188dfe6:      	xorl	%eax, %eax
1188dfe8:      	xorpd	%xmm0, %xmm0
1188dfec:      	ucomisd	%xmm0, %xmm1
1188dff0:      	cmovaeq	%rdx, %rax
1188dff4:      	ucomisd	0xde60d4(%rip), %xmm1   # 0x126740d0 <perry_typed_shape_mask_cli_2_1_112_js__fP8+0x30>
1188dffc:      	movq	$-0x1, %rbx
1188e003:      	cmovbeq	%rax, %rbx
1188e007:      	movq	%rbx, %rax
1188e00a:      	andq	$-0x100000, %rax        # imm = 0xFFF00000
1188e010:      	cmpq	$0x100000, %rax         # imm = 0x100000
1188e016:      	jne	0x1188e04f <js_object_get_field_by_name+0x2c0f>
1188e018:      	leaq	0x5567e09(%rip), %rax   # 0x16df5e28 <_RNvNtNtCscI5nJwKNRh4_13perry_runtime6object13class_handles23STREAM_HANDLE_PROBE_PTR>
1188e01f:      	movq	(%rax), %rax
1188e022:      	testq	%rax, %rax
1188e025:      	je	0x1188e04f <js_object_get_field_by_name+0x2c0f>
1188e027:      	movq	%rbx, %rdi
1188e02a:      	callq	*%rax
1188e02c:      	testb	$0x1, %al
1188e02e:      	je	0x1188e04f <js_object_get_field_by_name+0x2c0f>
1188e030:      	callq	0x1151e260 <_RNvNtNtCscI5nJwKNRh4_13perry_runtime6object13class_handles24handle_property_dispatch>
1188e035:      	testq	%rax, %rax
1188e038:      	je	0x1188e04f <js_object_get_field_by_name+0x2c0f>
1188e03a:      	movq	-0x30(%rbp), %rcx
1188e03e:      	movl	0x4(%rcx), %edx
1188e041:      	movq	%rbx, %rdi
1188e044:      	movq	-0x38(%rbp), %rsi
1188e048:      	callq	*%rax
1188e04a:      	jmp	0x1188e2b0 <js_object_get_field_by_name+0x2e70>
1188e04f:      	cmpq	$0x0, -0x78(%rbp)
1188e054:      	sete	%al
1188e057:      	movq	%r14, %rcx
1188e05a:      	shrq	$0x34, %rcx
1188e05e:      	andl	$0x7ff, %ecx            # imm = 0x7FF
1188e064:      	cmpl	$0x7ff, %ecx            # imm = 0x7FF
1188e06a:      	setae	%cl
1188e06d:      	orb	%al, %cl
1188e06f:      	je	0x1188e08e <js_object_get_field_by_name+0x2c4e>
1188e071:      	movq	%r14, %rdi
1188e074:      	movq	-0x30(%rbp), %rsi
1188e078:      	addq	$0xc8, %rsp
1188e07f:      	popq	%rbx
1188e080:      	popq	%r12
1188e082:      	popq	%r13
1188e084:      	popq	%r14
1188e086:      	popq	%r15
1188e088:      	popq	%rbp
1188e089:      	jmp	0x116b2140 <_RNvNtNtNtCscI5nJwKNRh4_13perry_runtime6object13field_get_set22get_field_by_name_tail29get_field_by_name_object_tail>
1188e08e:      	movq	-0x30(%rbp), %rax
1188e092:      	movl	0x4(%rax), %ebx
1188e095:      	leaq	-0x68(%rbp), %rdi
1188e099:      	movq	-0x38(%rbp), %rsi
1188e09d:      	movq	%rbx, %rdx
1188e0a0:      	callq	*0x3a907b2(%rip)        # 0x1531e858 <_GLOBAL_OFFSET_TABLE_+0x67f8>
1188e0a6:      	cmpl	$0x1, -0x68(%rbp)
1188e0aa:      	je	0x1188e0c4 <js_object_get_field_by_name+0x2c84>
1188e0ac:      	movq	-0x60(%rbp), %rdi
1188e0b0:      	movq	-0x58(%rbp), %rsi
1188e0b4:      	movapd	-0x50(%rbp), %xmm0
1188e0b9:      	callq	0x116bba10 <_RNvNtNtNtCscI5nJwKNRh4_13perry_runtime6object13field_get_set9accessors35primitive_object_prototype_accessor>
1188e0be:      	cmpq	$0x1, %rax
1188e0c2:      	je	0x1188e0d6 <js_object_get_field_by_name+0x2c96>
1188e0c4:      	movq	-0x30(%rbp), %rdi
1188e0c8:      	movapd	-0x50(%rbp), %xmm0
1188e0cd:      	callq	0x116bc530 <_RNvNtNtNtCscI5nJwKNRh4_13perry_runtime6object13field_get_set9accessors36primitive_builtin_prototype_property>
1188e0d2:      	testb	$0x1, %al
1188e0d4:      	je	0x1188e0de <js_object_get_field_by_name+0x2c9e>
1188e0d6:      	movq	%rdx, %r15
1188e0d9:      	jmp	0x1188e847 <js_object_get_field_by_name+0x3407>
1188e0de:      	movapd	-0x50(%rbp), %xmm0
1188e0e3:      	movq	-0x38(%rbp), %rdi
1188e0e7:      	movq	%rbx, %rsi
1188e0ea:      	callq	0x116b9110 <_RNvNtNtNtCscI5nJwKNRh4_13perry_runtime6object13field_get_set7ic_miss34bind_primitive_proto_method_static>
1188e0ef:      	testb	$0x1, %al
1188e0f1:      	movabsq	$0x7ffc000000000001, %r15 # imm = 0x7FFC000000000001
1188e0fb:      	cmovneq	%rdx, %r15
1188e0ff:      	jmp	0x1188e847 <js_object_get_field_by_name+0x3407>
1188e104:      	movabsq	$0xffffffffffff, %rax   # imm = 0xFFFFFFFFFFFF
1188e10e:      	andq	%rax, %r8
1188e111:      	movabsq	$0x7fff000000000000, %rax # imm = 0x7FFF000000000000
1188e11b:      	orq	%rax, %r8
1188e11e:      	movq	%r8, %xmm1
1188e123:      	movsd	-0x50(%rbp), %xmm0
1188e128:      	movapd	%xmm0, %xmm2
1188e12c:      	callq	0x114de6c0 <_RNvNtNtCscI5nJwKNRh4_13perry_runtime5proxy3get23proxy_get_with_receiver>
1188e131:      	jmp	0x1188e2b0 <js_object_get_field_by_name+0x2e70>
1188e136:      	movq	-0x30(%rbp), %rax
1188e13a:      	movl	0x4(%rax), %ebx
1188e13d:      	movq	%r14, %rdi
1188e140:      	leaq	0x14(%rax), %r13
1188e144:      	movq	%r13, %rsi
1188e147:      	movq	%rbx, %rdx
1188e14a:      	callq	0x116e23a0 <_RNvNtNtNtCscI5nJwKNRh4_13perry_runtime6object14class_registry13parent_static28class_object_own_field_bytes>
1188e14f:      	cmpq	$0x1, %rax
1188e153:      	je	0x1188e2b0 <js_object_get_field_by_name+0x2e70>
1188e159:      	cmpl	$0x9, %ebx
1188e15c:      	je	0x1188e52e <js_object_get_field_by_name+0x30ee>
1188e162:      	cmpl	$0x4, %ebx
1188e165:      	movabsq	$0x7ffd000000000000, %r12 # imm = 0x7FFD000000000000
1188e16f:      	jne	0x1188e558 <js_object_get_field_by_name+0x3118>
1188e175:      	cmpl	$0x656d616e, (%r13)     # imm = 0x656D616E
1188e17d:      	jne	0x1188e558 <js_object_get_field_by_name+0x3118>
1188e183:      	jmp	0x1188e5f0 <js_object_get_field_by_name+0x31b0>
1188e188:      	movl	0x4(%rsi), %ebx
1188e18b:      	cmpq	$0xb, %rbx
1188e18f:      	jne	0x1188e1d1 <js_object_get_field_by_name+0x2d91>
1188e191:      	movq	-0x38(%rbp), %rdx
1188e195:      	movzwl	0x8(%rdx), %eax
1188e199:      	movzbl	0xa(%rdx), %ecx
1188e19d:      	shll	$0x10, %ecx
1188e1a0:      	orq	%rax, %rcx
1188e1a3:      	movq	(%rdx), %rax
1188e1a6:      	movabsq	$0x63757274736e6f63, %rdx # imm = 0x63757274736E6F63
1188e1b0:      	xorq	%rdx, %rax
1188e1b3:      	xorq	$0x726f74, %rcx         # imm = 0x726F74
1188e1ba:      	orq	%rax, %rcx
1188e1bd:      	jne	0x1188e1d1 <js_object_get_field_by_name+0x2d91>
1188e1bf:      	movq	%r12, %rdi
1188e1c2:      	callq	0x1129dde0 <_RNvNtCscI5nJwKNRh4_13perry_runtime5timer23timer_constructor_value>
1188e1c7:      	cmpq	$0x1, %rax
1188e1cb:      	je	0x1188e2b0 <js_object_get_field_by_name+0x2e70>
1188e1d1:      	movq	-0x38(%rbp), %rdi
1188e1d5:      	movq	%rbx, %rsi
1188e1d8:      	callq	0x116b8a60 <_RNvNtNtNtCscI5nJwKNRh4_13perry_runtime6object13field_get_set7ic_miss31timer_handle_method_name_static>
1188e1dd:      	testq	%rax, %rax
1188e1e0:      	je	0x1188e2ba <js_object_get_field_by_name+0x2e7a>
1188e1e6:      	movq	%rax, %r15
1188e1e9:      	movq	%rdx, %r13
1188e1ec:      	movabsq	$-0x800000000000, %rcx  # imm = 0xFFFF800000000000
1188e1f6:      	leaq	(%r12,%rcx), %rax
1188e1fa:      	addq	$0x1000, %rcx           # imm = 0x1000
1188e201:      	movq	%r12, %rdi
1188e204:      	cmpq	%rcx, %rax
1188e207:      	jb	0x1188e26a <js_object_get_field_by_name+0x2e2a>
1188e209:      	leaq	-0x8(%r12), %r14
1188e20e:      	movq	%r14, %rdi
1188e211:      	callq	*0x3a8edc1(%rip)        # 0x1531cfd8 <_GLOBAL_OFFSET_TABLE_+0x4f78>
1188e217:      	movq	%r12, %rdi
1188e21a:      	testb	%al, %al
1188e21c:      	je	0x1188e26a <js_object_get_field_by_name+0x2e2a>
1188e21e:      	cmpb	$0xf, (%r14)
1188e222:      	movq	%r12, %rdi
1188e225:      	jne	0x1188e26a <js_object_get_field_by_name+0x2e2a>
1188e227:      	movq	%r12, %rdi
1188e22a:      	movabsq	$0x5045525259484e44, %rax # imm = 0x5045525259484E44
1188e234:      	cmpq	%rax, (%r12)
1188e238:      	jne	0x1188e26a <js_object_get_field_by_name+0x2e2a>
1188e23a:      	testb	$0x1, 0x1c(%r12)
1188e240:      	movq	%r12, %rdi
1188e243:      	je	0x1188e26a <js_object_get_field_by_name+0x2e2a>
1188e245:      	cmpb	$0x0, 0x1b(%r12)
1188e24b:      	movq	%r12, %rdi
1188e24e:      	jne	0x1188e26a <js_object_get_field_by_name+0x2e2a>
1188e250:      	addq	$0xbfb09, %rax          # imm = 0xBFB09
1188e256:      	movq	%r12, %rdi
1188e259:      	cmpq	%rax, 0x8(%r12)
1188e25e:      	jne	0x1188e26a <js_object_get_field_by_name+0x2e2a>
1188e260:      	movq	0x10(%r12), %rdi
1188e265:      	testq	%rdi, %rdi
1188e268:      	jle	0x1188e2ba <js_object_get_field_by_name+0x2e7a>
1188e26a:      	movzbl	0x5567a07(%rip), %eax   # 0x16df5c78 <_RNvNtNtCscI5nJwKNRh4_13perry_runtime5timer10ref_states18TIMER_IDS_NONEMPTY.0>
1188e271:      	testb	%al, %al
1188e273:      	je	0x1188e2ba <js_object_get_field_by_name+0x2e7a>
1188e275:      	callq	0x114fb2f0 <_RNvNtNtCscI5nJwKNRh4_13perry_runtime5timer10ref_states22is_known_timer_id_slow>
1188e27a:      	testb	%al, %al
1188e27c:      	je	0x1188e2ba <js_object_get_field_by_name+0x2e7a>
1188e27e:      	movabsq	$0x7ffd000000000000, %rax # imm = 0x7FFD000000000000
1188e288:      	orq	%rax, %r12
1188e28b:      	movq	%r12, %xmm0
1188e290:      	movq	%r15, %rdi
1188e293:      	movq	%r13, %rsi
1188e296:      	callq	*0x3aa390c(%rip)        # 0x15331ba8 <_GLOBAL_OFFSET_TABLE_+0x19b48>
1188e29c:      	jmp	0x1188e2b0 <js_object_get_field_by_name+0x2e70>
1188e29e:      	leaq	0x2a5e0f3(%rip), %rdi   # 0x142ec398 <anon.65d6174ee4273d212d69e4c9be928638.5290.llvm.16259376971001104057+0x1c>
1188e2a5:      	movl	$0x4, %esi
1188e2aa:      	callq	*0x3a8a3c0(%rip)        # 0x15318670 <_GLOBAL_OFFSET_TABLE_+0x610>
1188e2b0:      	movq	%xmm0, %r15
1188e2b5:      	jmp	0x1188e847 <js_object_get_field_by_name+0x3407>
1188e2ba:      	movq	%r12, %rdi
1188e2bd:      	movq	-0x30(%rbp), %rax
1188e2c1:      	leaq	0x14(%rax), %r14
1188e2c5:      	movq	%r14, %rsi
1188e2c8:      	movq	%rbx, %rdx
1188e2cb:      	callq	0x112826f0 <_RNvNtCscI5nJwKNRh4_13perry_runtime4text20text_handle_property>
1188e2d0:      	testb	$0x1, %al
1188e2d2:      	jne	0x1188e0d6 <js_object_get_field_by_name+0x2c96>
1188e2d8:      	cmpl	$0xb, %ebx
1188e2db:      	jne	0x1188e4f1 <js_object_get_field_by_name+0x30b1>
1188e2e1:      	movzwl	0x8(%r14), %eax
1188e2e6:      	movzbl	0xa(%r14), %ecx
1188e2eb:      	shll	$0x10, %ecx
1188e2ee:      	orq	%rax, %rcx
1188e2f1:      	movabsq	$0x63757274736e6f63, %rax # imm = 0x63757274736E6F63
1188e2fb:      	xorq	(%r14), %rax
1188e2fe:      	xorq	$0x726f74, %rcx         # imm = 0x726F74
1188e305:      	orq	%rax, %rcx
1188e308:      	jne	0x1188e4f1 <js_object_get_field_by_name+0x30b1>
1188e30e:      	movabsq	$0xffffffffffff, %r15   # imm = 0xFFFFFFFFFFFF
1188e318:      	addq	$-0x7, %r15
1188e31c:      	andq	0x3a96b25(%rip), %r15   # 0x15324e48 <_GLOBAL_OFFSET_TABLE_+0xcde8>
1188e323:      	movabsq	$0x7ffd000000000000, %rax # imm = 0x7FFD000000000000
1188e32d:      	orq	%rax, %r15
1188e330:      	jmp	0x1188e847 <js_object_get_field_by_name+0x3407>
1188e335:      	testl	%r14d, %r14d
1188e338:      	movdqa	-0x50(%rbp), %xmm0
1188e33d:      	je	0x1188e396 <js_object_get_field_by_name+0x2f56>
1188e33f:      	movq	(%r12), %rax
1188e343:      	movabsq	$0x63757274736e6f63, %rcx # imm = 0x63757274736E6F63
1188e34d:      	xorq	%rcx, %rax
1188e350:      	movq	0x3(%r12), %rcx
1188e355:      	movabsq	$0x726f746375727473, %rdx # imm = 0x726F746375727473
1188e35f:      	xorq	%rdx, %rcx
1188e362:      	orq	%rax, %rcx
1188e365:      	jne	0x1188e396 <js_object_get_field_by_name+0x2f56>
1188e367:      	movl	$0xb, %edx
1188e36c:      	movl	%r14d, %edi
1188e36f:      	movq	%r12, %rsi
1188e372:      	callq	0x1151fdb0 <_RNvNtNtCscI5nJwKNRh4_13perry_runtime6object13native_module20class_has_own_method>
1188e377:      	movdqa	-0x50(%rbp), %xmm0
1188e37c:      	testb	%al, %al
1188e37e:      	je	0x1188e396 <js_object_get_field_by_name+0x2f56>
1188e380:      	movl	$0xb, %edx
1188e385:      	movl	%r14d, %edi
1188e388:      	movq	%r12, %rsi
1188e38b:      	callq	*0x3a94b57(%rip)        # 0x15322ee8 <_GLOBAL_OFFSET_TABLE_+0xae88>
1188e391:      	jmp	0x1188e2b0 <js_object_get_field_by_name+0x2e70>
1188e396:      	testl	%r14d, %r14d
1188e399:      	sete	%al
1188e39c:      	movq	(%r12), %rcx
1188e3a0:      	movabsq	$0x63757274736e6f63, %rdx # imm = 0x63757274736E6F63
1188e3aa:      	xorq	%rdx, %rcx
1188e3ad:      	movq	0x3(%r12), %rdx
1188e3b2:      	movabsq	$0x726f746375727473, %rsi # imm = 0x726F746375727473
1188e3bc:      	xorq	%rsi, %rdx
1188e3bf:      	orq	%rcx, %rdx
1188e3c2:      	setne	%cl
1188e3c5:      	orb	%bl, %al
1188e3c7:      	orb	%cl, %al
1188e3c9:      	je	0x1188e488 <js_object_get_field_by_name+0x3048>
1188e3cf:      	xorl	%edx, %edx
1188e3d1:      	testb	%bl, %bl
1188e3d3:      	je	0x1188e4aa <js_object_get_field_by_name+0x306a>
1188e3d9:      	testq	%r15, %r15
1188e3dc:      	je	0x1188e85c <js_object_get_field_by_name+0x341c>
1188e3e2:      	movl	%edx, -0xa0(%rbp)
1188e3e8:      	movl	%r14d, %edi
1188e3eb:      	movq	%r12, %rsi
1188e3ee:      	movq	%r15, %rdx
1188e3f1:      	callq	0x116eb390 <_RNvNtNtNtCscI5nJwKNRh4_13perry_runtime6object14class_registry5state20class_is_key_deleted>
1188e3f6:      	testb	%al, %al
1188e3f8:      	jne	0x1188e83d <js_object_get_field_by_name+0x33fd>
1188e3fe:      	leaq	-0x3c(%rbp), %rax
1188e402:      	movq	%rax, -0x68(%rbp)
1188e406:      	movq	%r12, -0x60(%rbp)
1188e40a:      	movq	%r15, -0x58(%rbp)
1188e40e:      	movl	0x3ac31a4(%rip), %ebx   # 0x153515b8 <_RNvNvNtCscI5nJwKNRh4_13perry_runtime6object19CLASS_DYNAMIC_PROPS4SLOT+0x10>
1188e414:      	cmpl	$0x300, %ebx            # imm = 0x300
1188e41a:      	jae	0x1188f1f3 <js_object_get_field_by_name+0x3db3>
1188e420:      	movq	-0x80(%rbp), %rdi
1188e424:      	cmpq	$0x0, 0x78(%rdi)
1188e429:      	je	0x1188f1d8 <js_object_get_field_by_name+0x3d98>
1188e42f:      	movq	0x1e8(%rdi,%rbx,8), %rsi
1188e437:      	testq	%rsi, %rsi
1188e43a:      	je	0x1188f1f3 <js_object_get_field_by_name+0x3db3>
1188e440:      	leaq	-0x68(%rbp), %rdi
1188e444:      	callq	0x111491a0 <_RNCNvNtNtNtCscI5nJwKNRh4_13perry_runtime6object13field_get_set17get_field_by_name27js_object_get_field_by_names_0B9_>
1188e449:      	cmpq	$0x1, %rax
1188e44d:      	je	0x1188e2b0 <js_object_get_field_by_name+0x2e70>
1188e453:      	cmpq	$0x4, %r15
1188e457:      	jne	0x1188e8de <js_object_get_field_by_name+0x349e>
1188e45d:      	cmpl	$0x656d616e, (%r12)     # imm = 0x656D616E
1188e465:      	jne	0x1188e901 <js_object_get_field_by_name+0x34c1>
1188e46b:      	jmp	0x1188ea71 <js_object_get_field_by_name+0x3631>
1188e470:      	movq	%rax, %r15
1188e473:      	andq	%r13, %r15
1188e476:      	movabsq	$0x7fff000000000000, %rax # imm = 0x7FFF000000000000
1188e480:      	orq	%rax, %r15
1188e483:      	jmp	0x1188e847 <js_object_get_field_by_name+0x3407>
1188e488:      	movl	%r14d, %edi
1188e48b:      	callq	*0x3a8e177(%rip)        # 0x1531c608 <_GLOBAL_OFFSET_TABLE_+0x45a8>
1188e491:      	testb	%al, %al
1188e493:      	je	0x1188e4af <js_object_get_field_by_name+0x306f>
1188e495:      	movl	%r14d, %eax
1188e498:      	movabsq	$0x7ffe000000000000, %r15 # imm = 0x7FFE000000000000
1188e4a2:      	orq	%rax, %r15
1188e4a5:      	jmp	0x1188e847 <js_object_get_field_by_name+0x3407>
1188e4aa:      	testl	%r14d, %r14d
1188e4ad:      	je	0x1188e4d5 <js_object_get_field_by_name+0x3095>
1188e4af:      	movl	%r14d, %edi
1188e4b2:      	movq	%r12, %rsi
1188e4b5:      	movq	%r15, %rdx
1188e4b8:      	callq	0x1151fdb0 <_RNvNtNtCscI5nJwKNRh4_13perry_runtime6object13native_module20class_has_own_method>
1188e4bd:      	testb	%al, %al
1188e4bf:      	je	0x1188e4d5 <js_object_get_field_by_name+0x3095>
1188e4c1:      	movl	%r14d, %edi
1188e4c4:      	movq	%r12, %rsi
1188e4c7:      	movq	%r15, %rdx
1188e4ca:      	callq	*0x3a94a18(%rip)        # 0x15322ee8 <_GLOBAL_OFFSET_TABLE_+0xae88>
1188e4d0:      	jmp	0x1188e2b0 <js_object_get_field_by_name+0x2e70>
1188e4d5:      	leaq	-0x68(%rbp), %rdi
1188e4d9:      	callq	0x11183980 <_RNvMs1_NtNtCscI5nJwKNRh4_13perry_runtime6object11class_imageINtB5_10ImageTableINtNtNtNtCsjFfivMnupPH_3std4sync6poison6rwlock6RwLockINtNtCs9ueeiBwVTSo_4core6option6OptionINtNtNtNtB1n_11collections4hash3map7HashMapmNtNtNtB7_14class_registry5state11ClassVTableNtNtB9_9fast_hash9PtrHasherEEEE4readB9_>
1188e4de:      	cmpb	$0x0, -0x68(%rbp)
1188e4e2:      	je	0x1188e712 <js_object_get_field_by_name+0x32d2>
1188e4e8:      	movq	-0x58(%rbp), %rdi
1188e4ec:      	jmp	0x1188e823 <js_object_get_field_by_name+0x33e3>
1188e4f1:      	callq	0x1151e260 <_RNvNtNtCscI5nJwKNRh4_13perry_runtime6object13class_handles24handle_property_dispatch>
1188e4f6:      	testq	%rax, %rax
1188e4f9:      	je	0x1188e87f <js_object_get_field_by_name+0x343f>
1188e4ff:      	movq	%r12, %rdi
1188e502:      	movq	%r14, %rsi
1188e505:      	movq	%rbx, %rdx
1188e508:      	callq	*%rax
1188e50a:      	movq	%xmm0, %r15
1188e50f:      	movabsq	$0x7ffc000000000001, %rax # imm = 0x7FFC000000000001
1188e519:      	cmpq	%rax, %r15
1188e51c:      	movq	-0x30(%rbp), %rsi
1188e520:      	jne	0x1188e847 <js_object_get_field_by_name+0x3407>
1188e526:      	movq	%r12, %rdi
1188e529:      	jmp	0x1188e886 <js_object_get_field_by_name+0x3446>
1188e52e:      	movzbl	0x8(%r13), %eax
1188e533:      	movabsq	$0x7079746f746f7270, %rcx # imm = 0x7079746F746F7270
1188e53d:      	xorq	(%r13), %rcx
1188e541:      	xorq	$0x65, %rax
1188e545:      	orq	%rcx, %rax
1188e548:      	movabsq	$0x7ffd000000000000, %r12 # imm = 0x7FFD000000000000
1188e552:      	je	0x1188e5f0 <js_object_get_field_by_name+0x31b0>
1188e558:      	leaq	0x2ab8d57(%rip), %rsi   # 0x143472b6 <anon.65d6174ee4273d212d69e4c9be928638.12135.llvm.16259376971001104057+0x33f6>
1188e55f:      	movl	$0x14, %edx
1188e564:      	movq	%r14, %rdi
1188e567:      	callq	0x116e23a0 <_RNvNtNtNtCscI5nJwKNRh4_13perry_runtime6object14class_registry13parent_static28class_object_own_field_bytes>
1188e56c:      	cmpq	$0x1, %rax
1188e570:      	jne	0x1188e5f0 <js_object_get_field_by_name+0x31b0>
1188e572:      	movq	%xmm0, %rbx
1188e577:      	movabsq	$-0x1000000000000, %rax # imm = 0xFFFF000000000000
1188e581:      	andq	%rbx, %rax
1188e584:      	cmpq	%r12, %rax
1188e587:      	jne	0x1188e5f0 <js_object_get_field_by_name+0x31b0>
1188e589:      	movabsq	$0xffffffffffff, %rax   # imm = 0xFFFFFFFFFFFF
1188e593:      	andq	%rax, %rbx
1188e596:      	cmpq	%r14, %rbx
1188e599:      	setne	%al
1188e59c:      	cmpq	$0x100000, %rbx         # imm = 0x100000
1188e5a3:      	setae	%cl
1188e5a6:      	andb	%al, %cl
1188e5a8:      	cmpb	$0x1, %cl
1188e5ab:      	jne	0x1188e5f0 <js_object_get_field_by_name+0x31b0>
1188e5ad:      	movq	%rbx, %rdi
1188e5b0:      	callq	*0x3a958e2(%rip)        # 0x15323e98 <_GLOBAL_OFFSET_TABLE_+0xbe38>
1188e5b6:      	movabsq	$0x800000000000, %rcx   # imm = 0x800000000000
1188e5c0:      	decq	%rcx
1188e5c3:      	cmpq	%rcx, %rbx
1188e5c6:      	seta	%cl
1188e5c9:      	orb	%al, %cl
1188e5cb:      	jne	0x1188e5f0 <js_object_get_field_by_name+0x31b0>
1188e5cd:      	movq	%rbx, %rdi
1188e5d0:      	movq	-0x30(%rbp), %rsi
1188e5d4:      	callq	*0x3a917f6(%rip)        # 0x1531fdd0 <_GLOBAL_OFFSET_TABLE_+0x7d70>
1188e5da:      	movq	%rax, %r15
1188e5dd:      	movabsq	$0x7ffc000000000001, %rax # imm = 0x7FFC000000000001
1188e5e7:      	cmpq	%rax, %r15
1188e5ea:      	jne	0x1188e847 <js_object_get_field_by_name+0x3407>
1188e5f0:      	movq	%r14, %rdi
1188e5f3:      	movq	-0x30(%rbp), %rsi
1188e5f7:      	callq	0x116b2140 <_RNvNtNtNtCscI5nJwKNRh4_13perry_runtime6object13field_get_set22get_field_by_name_tail29get_field_by_name_object_tail>
1188e5fc:      	movq	%rax, %r15
1188e5ff:      	movabsq	$0x7ffc000000000001, %rax # imm = 0x7FFC000000000001
1188e609:      	cmpq	%rax, %r15
1188e60c:      	jne	0x1188e847 <js_object_get_field_by_name+0x3407>
1188e612:      	movq	%r14, %rax
1188e615:      	shrq	$0x34, %rax
1188e619:      	orq	%r14, %r12
1188e61c:      	cmpl	$0x7ff, %eax            # imm = 0x7FF
1188e621:      	cmovaeq	%r14, %r12
1188e625:      	testq	%r14, %r14
1188e628:      	je	0x1188e630 <js_object_get_field_by_name+0x31f0>
1188e62a:      	movq	%r12, -0x50(%rbp)
1188e62e:      	jmp	0x1188e63d <js_object_get_field_by_name+0x31fd>
1188e630:      	movsd	0xdded78(%rip), %xmm0   # 0x1266d3b0 <perry_typed_shape_mask_cli_2_1_112_js___e8__class_expr_17991+0x98>
1188e638:      	movsd	%xmm0, -0x50(%rbp)
1188e63d:      	movq	%r14, %rdi
1188e640:      	callq	*0x3a9c3ba(%rip)        # 0x1532aa00 <_GLOBAL_OFFSET_TABLE_+0x129a0>
1188e646:      	testl	%eax, %eax
1188e648:      	je	0x1188e83d <js_object_get_field_by_name+0x33fd>
1188e64e:      	movl	%eax, %r15d
1188e651:      	movq	-0x30(%rbp), %rax
1188e655:      	movl	0x4(%rax), %ebx
1188e658:      	leaq	-0x68(%rbp), %rdi
1188e65c:      	movq	%r13, %rsi
1188e65f:      	movq	%rbx, %rdx
1188e662:      	callq	*0x3a901f0(%rip)        # 0x1531e858 <_GLOBAL_OFFSET_TABLE_+0x67f8>
1188e668:      	movq	-0x58(%rbp), %r14
1188e66c:      	testq	%r14, %r14
1188e66f:      	sete	%al
1188e672:      	orb	-0x68(%rbp), %al
1188e675:      	jne	0x1188e83d <js_object_get_field_by_name+0x33fd>
1188e67b:      	movq	-0x60(%rbp), %r12
1188e67f:      	movl	%r15d, %edi
1188e682:      	movq	%r12, %rsi
1188e685:      	movq	%r14, %rdx
1188e688:      	callq	0x116eb390 <_RNvNtNtNtCscI5nJwKNRh4_13perry_runtime6object14class_registry5state20class_is_key_deleted>
1188e68d:      	testb	%al, %al
1188e68f:      	jne	0x1188e83d <js_object_get_field_by_name+0x33fd>
1188e695:      	leaq	-0x68(%rbp), %rdi
1188e699:      	movl	%r15d, %esi
1188e69c:      	movq	%r12, %rdx
1188e69f:      	movq	%r14, %rcx
1188e6a2:      	callq	0x116e3250 <_RNvNtNtNtCscI5nJwKNRh4_13perry_runtime6object14class_registry13parent_static29lookup_static_method_in_chain>
1188e6a7:      	cmpb	$0x2, -0x5c(%rbp)
1188e6ab:      	jne	0x1188e8a0 <js_object_get_field_by_name+0x3460>
1188e6b1:      	movl	%r15d, %edi
1188e6b4:      	movq	%r12, %rsi
1188e6b7:      	movq	%r14, %rdx
1188e6ba:      	movsd	-0x50(%rbp), %xmm0
1188e6bf:      	callq	0x116e3a30 <_RNvNtNtNtCscI5nJwKNRh4_13perry_runtime6object14class_registry13parent_static34class_static_accessor_getter_value>
1188e6c4:      	cmpq	$0x1, %rax
1188e6c8:      	je	0x1188e2b0 <js_object_get_field_by_name+0x2e70>
1188e6ce:      	movl	%r15d, %edi
1188e6d1:      	callq	0x116fdb60 <_RNvNtNtNtCscI5nJwKNRh4_13perry_runtime6object14class_registry9construct23promise_parent_in_chain>
1188e6d6:      	testb	%al, %al
1188e6d8:      	je	0x1188e83d <js_object_get_field_by_name+0x33fd>
1188e6de:      	leaq	-0x68(%rbp), %rdi
1188e6e2:      	movq	%r12, %rsi
1188e6e5:      	movq	%r14, %rdx
1188e6e8:      	callq	0x11693360 <_RNvNtNtNtCscI5nJwKNRh4_13perry_runtime6object11global_this14bigint_promise28promise_static_function_spec>
1188e6ed:      	cmpb	$0x2, -0x58(%rbp)
1188e6f1:      	movabsq	$0x7ffc000000000001, %r15 # imm = 0x7FFC000000000001
1188e6fb:      	je	0x1188e847 <js_object_get_field_by_name+0x3407>
1188e701:      	movq	%r13, %rdi
1188e704:      	movq	%rbx, %rsi
1188e707:      	callq	*0x3a9367b(%rip)        # 0x15321d88 <_GLOBAL_OFFSET_TABLE_+0x9d28>
1188e70d:      	jmp	0x1188e2b0 <js_object_get_field_by_name+0x2e70>
1188e712:      	movq	%r15, %rbx
1188e715:      	movq	-0x60(%rbp), %r15
1188e719:      	movq	-0x58(%rbp), %rdi
1188e71d:      	cmpq	$0x0, (%r15)
1188e721:      	je	0x1188e823 <js_object_get_field_by_name+0x33e3>
1188e727:      	movq	%rdi, -0x30(%rbp)
1188e72b:      	movl	-0x3c(%rbp), %r14d
1188e72f:      	xorl	%r13d, %r13d
1188e732:      	cmpq	$0x0, 0x18(%r15)
1188e737:      	je	0x1188e7f3 <js_object_get_field_by_name+0x33b3>
1188e73d:      	movl	%r14d, %edx
1188e740:      	movabsq	$-0x61c8864680b583eb, %rax # imm = 0x9E3779B97F4A7C15
1188e74a:      	imulq	%rax, %rdx
1188e74e:      	movq	%rdx, %rax
1188e751:      	shrq	$0x20, %rax
1188e755:      	xorq	%rdx, %rax
1188e758:      	shrq	$0x39, %rdx
1188e75c:      	movq	(%r15), %rdi
1188e75f:      	movq	0x8(%r15), %rcx
1188e763:      	movd	%edx, %xmm0
1188e767:      	punpcklbw	%xmm0, %xmm0    # xmm0 = xmm0[0,0,1,1,2,2,3,3,4,4,5,5,6,6,7,7]
1188e76b:      	pshuflw	$0x0, %xmm0, %xmm0      # xmm0 = xmm0[0,0,0,0,4,5,6,7]
1188e770:      	pshufd	$0x44, %xmm0, %xmm0     # xmm0 = xmm0[0,1,0,1]
1188e775:      	xorl	%edx, %edx
1188e777:      	andq	%rcx, %rax
1188e77a:      	movdqu	(%rdi,%rax), %xmm1
1188e77f:      	movdqa	%xmm1, %xmm2
1188e783:      	pcmpeqb	%xmm0, %xmm2
1188e787:      	pmovmskb	%xmm2, %esi
1188e78b:      	testl	%esi, %esi
1188e78d:      	je	0x1188e7bb <js_object_get_field_by_name+0x337b>
1188e78f:      	tzcntl	%esi, %r8d
1188e794:      	addq	%rax, %r8
1188e797:      	andq	%rcx, %r8
1188e79a:      	negq	%r8
1188e79d:      	imulq	$0x98, %r8, %r8
1188e7a4:      	cmpl	-0x98(%rdi,%r8), %r14d
1188e7ac:      	je	0x1188e7d8 <js_object_get_field_by_name+0x3398>
1188e7ae:      	leal	-0x1(%rsi), %r8d
1188e7b2:      	andw	%si, %r8w
1188e7b6:      	movl	%r8d, %esi
1188e7b9:      	jne	0x1188e78f <js_object_get_field_by_name+0x334f>
1188e7bb:      	pcmpeqd	%xmm2, %xmm2
1188e7bf:      	pcmpeqb	%xmm2, %xmm1
1188e7c3:      	pmovmskb	%xmm1, %esi
1188e7c7:      	testl	%esi, %esi
1188e7c9:      	jne	0x1188e7f3 <js_object_get_field_by_name+0x33b3>
1188e7cb:      	addq	%rdx, %rax
1188e7ce:      	addq	$0x10, %rax
1188e7d2:      	addq	$0x10, %rdx
1188e7d6:      	jmp	0x1188e777 <js_object_get_field_by_name+0x3337>
1188e7d8:      	addq	%r8, %rdi
1188e7db:      	addq	$-0x60, %rdi
1188e7df:      	movq	%r12, %rsi
1188e7e2:      	movq	%rbx, %rdx
1188e7e5:      	callq	0x1103cba0 <_RINvMs1_NtCsbuoDnTMY902_9hashbrown3mapINtB6_7HashMapNtNtCscv7DEBI70Kq_5alloc6string6StringjNtNtNtCsjFfivMnupPH_3std4hash6random11RandomStateE3geteECscI5nJwKNRh4_13perry_runtime>
1188e7ea:      	testq	%rax, %rax
1188e7ed:      	jne	0x1188ea35 <js_object_get_field_by_name+0x35f5>
1188e7f3:      	movl	%r14d, %edi
1188e7f6:      	callq	0x11552cb0 <_RNvNtNtCscI5nJwKNRh4_13perry_runtime6object19class_meta_registry19get_parent_class_id.llvm.16259376971001104057>
1188e7fb:      	testb	$0x1, %al
1188e7fd:      	je	0x1188e818 <js_object_get_field_by_name+0x33d8>
1188e7ff:      	testl	%edx, %edx
1188e801:      	je	0x1188e818 <js_object_get_field_by_name+0x33d8>
1188e803:      	cmpl	%r14d, %edx
1188e806:      	je	0x1188e818 <js_object_get_field_by_name+0x33d8>
1188e808:      	incq	%r13
1188e80b:      	movl	%edx, %r14d
1188e80e:      	cmpq	$0x20, %r13
1188e812:      	jne	0x1188e732 <js_object_get_field_by_name+0x32f2>
1188e818:      	movl	$0xffffffff, %esi       # imm = 0xFFFFFFFF
1188e81d:      	movq	-0x30(%rbp), %rdi
1188e821:      	jmp	0x1188e828 <js_object_get_field_by_name+0x33e8>
1188e823:      	movl	$0xffffffff, %esi       # imm = 0xFFFFFFFF
1188e828:      	lock
1188e829:      	xaddl	%esi, (%rdi)
1188e82c:      	decl	%esi
1188e82e:      	movl	%esi, %eax
1188e830:      	andl	$0xbfffffff, %eax       # imm = 0xBFFFFFFF
1188e835:      	negl	%eax
1188e837:      	jo	0x1188f197 <js_object_get_field_by_name+0x3d57>
1188e83d:      	movabsq	$0x7ffc000000000001, %r15 # imm = 0x7FFC000000000001
1188e847:      	movq	%r15, %rax
1188e84a:      	addq	$0xc8, %rsp
1188e851:      	popq	%rbx
1188e852:      	popq	%r12
1188e854:      	popq	%r13
1188e856:      	popq	%r14
1188e858:      	popq	%r15
1188e85a:      	popq	%rbp
1188e85b:      	retq
1188e85c:      	movl	%r14d, %edi
1188e85f:      	movq	%r12, %rsi
1188e862:      	xorl	%edx, %edx
1188e864:      	callq	0x116e3a30 <_RNvNtNtNtCscI5nJwKNRh4_13perry_runtime6object14class_registry13parent_static34class_static_accessor_getter_value>
1188e869:      	movabsq	$0x7ffc000000000001, %r15 # imm = 0x7FFC000000000001
1188e873:      	cmpq	$0x1, %rax
1188e877:      	je	0x1188e2b0 <js_object_get_field_by_name+0x2e70>
1188e87d:      	jmp	0x1188e847 <js_object_get_field_by_name+0x3407>
1188e87f:      	movq	%r12, %rdi
1188e882:      	movq	-0x30(%rbp), %rsi
1188e886:      	callq	0x116b0830 <_RNvNtNtNtCscI5nJwKNRh4_13perry_runtime6object13field_get_set17get_field_by_name28handle_proto_inherited_field>
1188e88b:      	jmp	0x1188e0ef <js_object_get_field_by_name+0x2caf>
1188e890:      	testq	%r13, %r13
1188e893:      	jle	0x1188e83d <js_object_get_field_by_name+0x33fd>
1188e895:      	movq	%rbx, %rdi
1188e898:      	callq	*0x3aa4532(%rip)        # 0x15332dd0 <_GLOBAL_OFFSET_TABLE_+0x1ad70>
1188e89e:      	jmp	0x1188e83d <js_object_get_field_by_name+0x33fd>
1188e8a0:      	cmpq	$0x1, %rbx
1188e8a4:      	movq	%rbx, %rdi
1188e8a7:      	adcq	$0x0, %rdi
1188e8ab:      	movl	$0x1, %esi
1188e8b0:      	callq	*0x3a8d03a(%rip)        # 0x1531b8f0 <_GLOBAL_OFFSET_TABLE_+0x3890>
1188e8b6:      	movq	%rax, %r14
1188e8b9:      	movq	%rax, %rdi
1188e8bc:      	movq	%r13, %rsi
1188e8bf:      	movq	%rbx, %rdx
1188e8c2:      	callq	*0x3a8f450(%rip)        # 0x1531dd18 <_GLOBAL_OFFSET_TABLE_+0x5cb8>
1188e8c8:      	movsd	-0x50(%rbp), %xmm0
1188e8cd:      	movq	%r14, %rdi
1188e8d0:      	movq	%rbx, %rsi
1188e8d3:      	callq	*0x3aa32cf(%rip)        # 0x15331ba8 <_GLOBAL_OFFSET_TABLE_+0x19b48>
1188e8d9:      	jmp	0x1188e2b0 <js_object_get_field_by_name+0x2e70>
1188e8de:      	cmpq	$0x6, %r15
1188e8e2:      	jne	0x1188e901 <js_object_get_field_by_name+0x34c1>
1188e8e4:      	movl	$0x676e656c, %eax       # imm = 0x676E656C
1188e8e9:      	xorl	(%r12), %eax
1188e8ed:      	movzwl	0x4(%r12), %ecx
1188e8f3:      	xorl	$0x6874, %ecx           # imm = 0x6874
1188e8f9:      	orl	%eax, %ecx
1188e8fb:      	je	0x1188ea71 <js_object_get_field_by_name+0x3631>
1188e901:      	movl	$0x20, %r14d
1188e907:      	movl	-0x3c(%rbp), %ebx
1188e90a:      	jmp	0x1188e915 <js_object_get_field_by_name+0x34d5>
1188e90c:      	decq	%r14
1188e90f:      	je	0x1188ea71 <js_object_get_field_by_name+0x3631>
1188e915:      	movq	%r15, %r13
1188e918:      	movl	%ebx, %edi
1188e91a:      	callq	0x116ebb60 <_RNvNtNtNtCscI5nJwKNRh4_13perry_runtime6object14class_registry5state22class_static_prototype>
1188e91f:      	testq	%rax, %rax
1188e922:      	je	0x1188e947 <js_object_get_field_by_name+0x3507>
1188e924:      	movq	%rax, %rdi
1188e927:      	movq	-0x30(%rbp), %rsi
1188e92b:      	callq	*0x3a9149f(%rip)        # 0x1531fdd0 <_GLOBAL_OFFSET_TABLE_+0x7d70>
1188e931:      	movq	%rax, %r15
1188e934:      	movabsq	$0x7ffc000000000001, %rax # imm = 0x7FFC000000000001
1188e93e:      	cmpq	%rax, %r15
1188e941:      	jne	0x1188e847 <js_object_get_field_by_name+0x3407>
1188e947:      	movl	%ebx, %edi
1188e949:      	callq	0x116e7ff0 <_RNvNtNtNtCscI5nJwKNRh4_13perry_runtime6object14class_registry17prototype_objects22class_prototype_object>
1188e94e:      	testq	%rax, %rax
1188e951:      	je	0x1188e976 <js_object_get_field_by_name+0x3536>
1188e953:      	movq	%rax, %rdi
1188e956:      	movq	-0x30(%rbp), %rsi
1188e95a:      	callq	*0x3a91470(%rip)        # 0x1531fdd0 <_GLOBAL_OFFSET_TABLE_+0x7d70>
1188e960:      	movq	%rax, %r15
1188e963:      	movabsq	$0x7ffc000000000001, %rax # imm = 0x7FFC000000000001
1188e96d:      	cmpq	%rax, %r15
1188e970:      	jne	0x1188e847 <js_object_get_field_by_name+0x3407>
1188e976:      	movl	%ebx, %edi
1188e978:      	callq	0x11552cb0 <_RNvNtNtCscI5nJwKNRh4_13perry_runtime6object19class_meta_registry19get_parent_class_id.llvm.16259376971001104057>
1188e97d:      	cmpl	$0x1, %eax
1188e980:      	jne	0x1188ea6e <js_object_get_field_by_name+0x362e>
1188e986:      	testl	%edx, %edx
1188e988:      	je	0x1188ea6e <js_object_get_field_by_name+0x362e>
1188e98e:      	cmpl	%ebx, %edx
1188e990:      	je	0x1188ea6e <js_object_get_field_by_name+0x362e>
1188e996:      	movl	%edx, %ebx
1188e998:      	movl	%edx, -0xa4(%rbp)
1188e99e:      	movl	%edx, %edi
1188e9a0:      	movq	%r12, %rsi
1188e9a3:      	movq	%r13, %r15
1188e9a6:      	movq	%r13, %rdx
1188e9a9:      	callq	0x116eb390 <_RNvNtNtNtCscI5nJwKNRh4_13perry_runtime6object14class_registry5state20class_is_key_deleted>
1188e9ae:      	testb	%al, %al
1188e9b0:      	jne	0x1188e90c <js_object_get_field_by_name+0x34cc>
1188e9b6:      	leaq	-0xa4(%rbp), %rax
1188e9bd:      	movq	%rax, -0x68(%rbp)
1188e9c1:      	movq	%r12, -0x60(%rbp)
1188e9c5:      	movq	%r15, -0x58(%rbp)
1188e9c9:      	movl	0x3ac2be8(%rip), %r15d  # 0x153515b8 <_RNvNvNtCscI5nJwKNRh4_13perry_runtime6object19CLASS_DYNAMIC_PROPS4SLOT+0x10>
1188e9d0:      	cmpl	$0x300, %r15d           # imm = 0x300
1188e9d7:      	movq	-0x80(%rbp), %rdi
1188e9db:      	jae	0x1188ea23 <js_object_get_field_by_name+0x35e3>
1188e9dd:      	cmpq	$0x0, 0x78(%rdi)
1188e9e2:      	je	0x1188ea0c <js_object_get_field_by_name+0x35cc>
1188e9e4:      	movq	0x1e8(%rdi,%r15,8), %rsi
1188e9ec:      	testq	%rsi, %rsi
1188e9ef:      	je	0x1188ea23 <js_object_get_field_by_name+0x35e3>
1188e9f1:      	leaq	-0x68(%rbp), %rdi
1188e9f5:      	callq	0x11148f80 <_RNCNvNtNtNtCscI5nJwKNRh4_13perry_runtime6object13field_get_set17get_field_by_name27js_object_get_field_by_names0_0B9_>
1188e9fa:      	cmpq	$0x1, %rax
1188e9fe:      	movq	%r13, %r15
1188ea01:      	jne	0x1188e90c <js_object_get_field_by_name+0x34cc>
1188ea07:      	jmp	0x1188e2b0 <js_object_get_field_by_name+0x2e70>
1188ea0c:      	callq	*0x3a959ee(%rip)        # 0x15324400 <_GLOBAL_OFFSET_TABLE_+0xc3a0>
1188ea12:      	movq	-0x80(%rbp), %rdi
1188ea16:      	movq	0x1e8(%rdi,%r15,8), %rsi
1188ea1e:      	testq	%rsi, %rsi
1188ea21:      	jne	0x1188e9f1 <js_object_get_field_by_name+0x35b1>
1188ea23:      	leaq	0x39a3ad6(%rip), %rdi   # 0x15232500 <_RNvNtCscI5nJwKNRh4_13perry_runtime6object19CLASS_DYNAMIC_PROPS>
1188ea2a:      	callq	*0x3a8d030(%rip)        # 0x1531ba60 <_GLOBAL_OFFSET_TABLE_+0x3a00>
1188ea30:      	movq	%rax, %rsi
1188ea33:      	jmp	0x1188e9f1 <js_object_get_field_by_name+0x35b1>
1188ea35:      	movaps	-0x50(%rbp), %xmm0
1188ea39:      	callq	*(%rax)
1188ea3b:      	movl	$0xffffffff, %esi       # imm = 0xFFFFFFFF
1188ea40:      	movq	-0x30(%rbp), %rdi
1188ea44:      	lock
1188ea45:      	xaddl	%esi, (%rdi)
1188ea48:      	decl	%esi
1188ea4a:      	movl	%esi, %eax
1188ea4c:      	andl	$0xbfffffff, %eax       # imm = 0xBFFFFFFF
1188ea51:      	negl	%eax
1188ea53:      	jno	0x1188e2b0 <js_object_get_field_by_name+0x2e70>
1188ea59:      	movsd	%xmm0, -0x30(%rbp)
1188ea5e:      	callq	*0x3a89aac(%rip)        # 0x15318510 <_GLOBAL_OFFSET_TABLE_+0x4b0>
1188ea64:      	movsd	-0x30(%rbp), %xmm0
1188ea69:      	jmp	0x1188e2b0 <js_object_get_field_by_name+0x2e70>
1188ea6e:      	movq	%r13, %r15
1188ea71:      	movl	-0x3c(%rbp), %esi
1188ea74:      	leaq	-0x68(%rbp), %rdi
1188ea78:      	movq	%r12, %rdx
1188ea7b:      	movq	%r15, %rcx
1188ea7e:      	callq	0x116e3250 <_RNvNtNtNtCscI5nJwKNRh4_13perry_runtime6object14class_registry13parent_static29lookup_static_method_in_chain>
1188ea83:      	cmpb	$0x2, -0x5c(%rbp)
1188ea87:      	jne	0x1188eb1c <js_object_get_field_by_name+0x36dc>
1188ea8d:      	movq	%r15, %r14
1188ea90:      	movl	-0x3c(%rbp), %edi
1188ea93:      	callq	0x116fdb60 <_RNvNtNtNtCscI5nJwKNRh4_13perry_runtime6object14class_registry9construct23promise_parent_in_chain>
1188ea98:      	testb	%al, %al
1188ea9a:      	je	0x1188ead7 <js_object_get_field_by_name+0x3697>
1188ea9c:      	leaq	-0x68(%rbp), %rdi
1188eaa0:      	movq	%r12, %rsi
1188eaa3:      	movq	%r14, %rdx
1188eaa6:      	callq	0x11693360 <_RNvNtNtNtCscI5nJwKNRh4_13perry_runtime6object11global_this14bigint_promise28promise_static_function_spec>
1188eaab:      	cmpb	$0x2, -0x58(%rbp)
1188eaaf:      	je	0x1188ead7 <js_object_get_field_by_name+0x3697>
1188eab1:      	movq	-0x38(%rbp), %rdi
1188eab5:      	movq	-0x78(%rbp), %rsi
1188eab9:      	callq	*0x3a932c9(%rip)        # 0x15321d88 <_GLOBAL_OFFSET_TABLE_+0x9d28>
1188eabf:      	movq	%xmm0, %r15
1188eac4:      	movabsq	$0x7ffc000000000001, %rax # imm = 0x7FFC000000000001
1188eace:      	cmpq	%rax, %r15
1188ead1:      	jne	0x1188e847 <js_object_get_field_by_name+0x3407>
1188ead7:      	movl	-0x3c(%rbp), %edi
1188eada:      	movq	%r12, %rsi
1188eadd:      	movq	%r14, %r15
1188eae0:      	movq	%r14, %rdx
1188eae3:      	movdqa	-0x50(%rbp), %xmm0
1188eae8:      	callq	0x116e3a30 <_RNvNtNtNtCscI5nJwKNRh4_13perry_runtime6object14class_registry13parent_static34class_static_accessor_getter_value>
1188eaed:      	testb	$0x1, %al
1188eaef:      	jne	0x1188e2b0 <js_object_get_field_by_name+0x2e70>
1188eaf5:      	movabsq	$-0x7ffc000000000003, %rbx # imm = 0x8003FFFFFFFFFFFD
1188eaff:      	cmpq	$0x4, %r15
1188eb03:      	jne	0x1188ed72 <js_object_get_field_by_name+0x3932>
1188eb09:      	cmpl	$0x656d616e, (%r12)     # imm = 0x656D616E
1188eb11:      	jne	0x1188ed91 <js_object_get_field_by_name+0x3951>
1188eb17:      	jmp	0x1188edbc <js_object_get_field_by_name+0x397c>
1188eb1c:      	movq	-0x78(%rbp), %r14
1188eb20:      	cmpq	$0x1, %r14
1188eb24:      	movq	%r14, %rdi
1188eb27:      	adcq	$0x0, %rdi
1188eb2b:      	movl	$0x1, %esi
1188eb30:      	callq	*0x3a8cdba(%rip)        # 0x1531b8f0 <_GLOBAL_OFFSET_TABLE_+0x3890>
1188eb36:      	movq	%rax, %rbx
1188eb39:      	movq	%rax, %rdi
1188eb3c:      	movq	-0x38(%rbp), %rsi
1188eb40:      	movq	%r14, %rdx
1188eb43:      	callq	*0x3a8f1cf(%rip)        # 0x1531dd18 <_GLOBAL_OFFSET_TABLE_+0x5cb8>
1188eb49:      	movaps	-0x50(%rbp), %xmm0
1188eb4d:      	movq	%rbx, %rdi
1188eb50:      	movq	%r14, %rsi
1188eb53:      	callq	*0x3aa304f(%rip)        # 0x15331ba8 <_GLOBAL_OFFSET_TABLE_+0x19b48>
1188eb59:      	jmp	0x1188e2b0 <js_object_get_field_by_name+0x2e70>
1188eb5e:      	leaq	0x3990bc3(%rip), %rdi   # 0x1521f728 <anon.65d6174ee4273d212d69e4c9be928638.644.llvm.16259376971001104057>
1188eb65:      	callq	*0x3a9e49d(%rip)        # 0x1532d008 <_GLOBAL_OFFSET_TABLE_+0x14fa8>
1188eb6b:      	callq	*0x3a8c03f(%rip)        # 0x1531abb0 <_GLOBAL_OFFSET_TABLE_+0x2b50>
1188eb71:      	leaq	0x2a6ff04(%rip), %rdi   # 0x142fea7c <anon.65d6174ee4273d212d69e4c9be928638.395.llvm.16259376971001104057+0x740>
1188eb78:      	movl	$0xb, %esi
1188eb7d:      	callq	*0x3a97415(%rip)        # 0x15325f98 <_GLOBAL_OFFSET_TABLE_+0xdf38>
1188eb83:      	movq	-0x38(%rbp), %rax
1188eb87:      	cmpb	$0x66, (%rax)
1188eb8a:      	jne	0x1188e83d <js_object_get_field_by_name+0x33fd>
1188eb90:      	movq	-0x30(%rbp), %rax
1188eb94:      	cmpb	$0x69, 0x15(%rax)
1188eb98:      	jne	0x1188e83d <js_object_get_field_by_name+0x33fd>
1188eb9e:      	cmpb	$0x6e, 0x16(%rax)
1188eba2:      	jne	0x1188e83d <js_object_get_field_by_name+0x33fd>
1188eba8:      	movq	-0x30(%rbp), %rax
1188ebac:      	cmpb	$0x61, 0x17(%rax)
1188ebb0:      	jne	0x1188e83d <js_object_get_field_by_name+0x33fd>
1188ebb6:      	movq	-0x30(%rbp), %rax
1188ebba:      	cmpb	$0x6c, 0x18(%rax)
1188ebbe:      	jne	0x1188e83d <js_object_get_field_by_name+0x33fd>
1188ebc4:      	movq	-0x30(%rbp), %rax
1188ebc8:      	cmpb	$0x6c, 0x19(%rax)
1188ebcc:      	jne	0x1188e83d <js_object_get_field_by_name+0x33fd>
1188ebd2:      	movq	-0x30(%rbp), %rax
1188ebd6:      	cmpb	$0x79, 0x1a(%rax)
1188ebda:      	je	0x1188ec22 <js_object_get_field_by_name+0x37e2>
1188ebdc:      	jmp	0x1188e83d <js_object_get_field_by_name+0x33fd>
1188ebe1:      	movq	-0x38(%rbp), %rax
1188ebe5:      	cmpb	$0x63, (%rax)
1188ebe8:      	jne	0x1188e83d <js_object_get_field_by_name+0x33fd>
1188ebee:      	movq	-0x30(%rbp), %rax
1188ebf2:      	cmpb	$0x61, 0x15(%rax)
1188ebf6:      	jne	0x1188e83d <js_object_get_field_by_name+0x33fd>
1188ebfc:      	cmpb	$0x74, 0x16(%rax)
1188ec00:      	jne	0x1188e83d <js_object_get_field_by_name+0x33fd>
1188ec06:      	movq	-0x30(%rbp), %rax
1188ec0a:      	cmpb	$0x63, 0x17(%rax)
1188ec0e:      	jne	0x1188e83d <js_object_get_field_by_name+0x33fd>
1188ec14:      	movq	-0x30(%rbp), %rax
1188ec18:      	cmpb	$0x68, 0x18(%rax)
1188ec1c:      	jne	0x1188e83d <js_object_get_field_by_name+0x33fd>
1188ec22:      	movq	-0x38(%rbp), %rsi
1188ec26:      	movq	%rbx, %rdx
1188ec29:      	callq	*0x3a938a1(%rip)        # 0x153224d0 <_GLOBAL_OFFSET_TABLE_+0xa470>
1188ec2f:      	movabsq	$0x7ffc000000000001, %r15 # imm = 0x7FFC000000000001
1188ec39:      	cmpq	$0x1, %rax
1188ec3d:      	je	0x1188e2b0 <js_object_get_field_by_name+0x2e70>
1188ec43:      	jmp	0x1188e847 <js_object_get_field_by_name+0x3407>
1188ec48:      	movq	-0x38(%rbp), %rsi
1188ec4c:      	movzwl	0x8(%rsi), %eax
1188ec50:      	movzbl	0xa(%rsi), %ecx
1188ec54:      	shll	$0x10, %ecx
1188ec57:      	movabsq	$0x63757274736e6f63, %rdx # imm = 0x63757274736E6F63
1188ec61:      	xorq	(%rsi), %rdx
1188ec64:      	orq	%rax, %rcx
1188ec67:      	xorq	$0x726f74, %rcx         # imm = 0x726F74
1188ec6e:      	orq	%rdx, %rcx
1188ec71:      	movabsq	$0x7ffc000000000001, %r15 # imm = 0x7FFC000000000001
1188ec7b:      	jne	0x1188e847 <js_object_get_field_by_name+0x3407>
1188ec81:      	leaq	0x2a9735d(%rip), %rdi   # 0x14325fe5 <anon.65d6174ee4273d212d69e4c9be928638.7425.llvm.16259376971001104057+0x1b9>
1188ec88:      	movl	$0x7, %esi
1188ec8d:      	jmp	0x1188e2aa <js_object_get_field_by_name+0x2e6a>
1188ec92:      	movq	%rbx, %rdi
1188ec95:      	callq	*0x3a9741d(%rip)        # 0x153260b8 <_GLOBAL_OFFSET_TABLE_+0xe058>
1188ec9b:      	jmp	0x1188eca6 <js_object_get_field_by_name+0x3866>
1188ec9d:      	movq	%rbx, %rdi
1188eca0:      	callq	*0x3a92f9a(%rip)        # 0x15321c40 <_GLOBAL_OFFSET_TABLE_+0x9be0>
1188eca6:      	movq	-0x98(%rbp), %rcx
1188ecad:      	cmpq	$0x0, (%rcx)
1188ecb1:      	jne	0x1188ed40 <js_object_get_field_by_name+0x3900>
1188ecb7:      	movl	%eax, %eax
1188ecb9:      	xorps	%xmm0, %xmm0
1188ecbc:      	cvtsi2sd	%rax, %xmm0
1188ecc1:      	movq	%xmm0, %r15
1188ecc6:      	cmpq	0x18(%rcx), %r12
1188ecca:      	ja	0x1188e847 <js_object_get_field_by_name+0x3407>
1188ecd0:      	movq	%r12, 0x18(%rcx)
1188ecd4:      	jmp	0x1188e847 <js_object_get_field_by_name+0x3407>
1188ecd9:      	movl	%ecx, %eax
1188ecdb:      	xorps	%xmm0, %xmm0
1188ecde:      	cvtsi2sd	%rax, %xmm0
1188ece3:      	jmp	0x1188e2b0 <js_object_get_field_by_name+0x2e70>
1188ece8:      	movq	%r12, %rdi
1188eceb:      	callq	0x1150a240 <_RNvNtNtCscI5nJwKNRh4_13perry_runtime6buffer4view10backing_of>
1188ecf0:      	movq	%rax, %rdi
1188ecf3:      	callq	*0x3a9f7e7(%rip)        # 0x1532e4e0 <_GLOBAL_OFFSET_TABLE_+0x16480>
1188ecf9:      	testq	%rax, %rax
1188ecfc:      	je	0x1188ef4a <js_object_get_field_by_name+0x3b0a>
1188ed02:      	movq	%rax, %r15
1188ed05:      	shrq	$0x34, %rax
1188ed09:      	cmpl	$0x7fe, %eax            # imm = 0x7FE
1188ed0e:      	ja	0x1188e847 <js_object_get_field_by_name+0x3407>
1188ed14:      	movabsq	$0xffffffffffff, %rax   # imm = 0xFFFFFFFFFFFF
1188ed1e:      	andq	%rax, %r15
1188ed21:      	jmp	0x1188e323 <js_object_get_field_by_name+0x2ee3>
1188ed26:      	leaq	0x39916e3(%rip), %rdi   # 0x15220410 <anon.65d6174ee4273d212d69e4c9be928638.932.llvm.16259376971001104057>
1188ed2d:      	callq	*0x3a9e2d5(%rip)        # 0x1532d008 <_GLOBAL_OFFSET_TABLE_+0x14fa8>
1188ed33:      	leaq	0x39916ee(%rip), %rdi   # 0x15220428 <anon.65d6174ee4273d212d69e4c9be928638.933.llvm.16259376971001104057>
1188ed3a:      	callq	*0x3a9d698(%rip)        # 0x1532c3d8 <_GLOBAL_OFFSET_TABLE_+0x14378>
1188ed40:      	leaq	0x399d2e9(%rip), %rdi   # 0x1522c030 <anon.65d6174ee4273d212d69e4c9be928638.3973.llvm.16259376971001104057>
1188ed47:      	callq	*0x3a9d68b(%rip)        # 0x1532c3d8 <_GLOBAL_OFFSET_TABLE_+0x14378>
1188ed4d:      	movabsq	$0x7ffc000000000001, %r15 # imm = 0x7FFC000000000001
1188ed57:      	movabsq	$0x7ffd000000000000, %rcx # imm = 0x7FFD000000000000
1188ed61:      	cmpq	%rcx, %rax
1188ed64:      	je	0x1188e847 <js_object_get_field_by_name+0x3407>
1188ed6a:      	movq	%rax, %r15
1188ed6d:      	jmp	0x1188e847 <js_object_get_field_by_name+0x3407>
1188ed72:      	cmpq	$0x6, %r15
1188ed76:      	jne	0x1188ed91 <js_object_get_field_by_name+0x3951>
1188ed78:      	movl	$0x676e656c, %eax       # imm = 0x676E656C
1188ed7d:      	xorl	(%r12), %eax
1188ed81:      	movzwl	0x4(%r12), %ecx
1188ed87:      	xorl	$0x6874, %ecx           # imm = 0x6874
1188ed8d:      	orl	%eax, %ecx
1188ed8f:      	je	0x1188edbc <js_object_get_field_by_name+0x397c>
1188ed91:      	movl	-0x3c(%rbp), %edi
1188ed94:      	movq	-0x30(%rbp), %rsi
1188ed98:      	xorl	%edx, %edx
1188ed9a:      	movl	$0x1, %ecx
1188ed9f:      	callq	0x116e8f20 <_RNvNtNtNtCscI5nJwKNRh4_13perry_runtime6object14class_registry17prototype_objects31resolve_proto_chain_field_inner>
1188eda4:      	movq	%rdx, %r15
1188eda7:      	movq	%rdx, %rcx
1188edaa:      	addq	%rbx, %rcx
1188edad:      	cmpq	$-0x2, %rcx
1188edb1:      	setb	%cl
1188edb4:      	testb	%al, %cl
1188edb6:      	jne	0x1188e847 <js_object_get_field_by_name+0x3407>
1188edbc:      	movl	-0x3c(%rbp), %edi
1188edbf:      	callq	0x116eb630 <_RNvNtNtNtCscI5nJwKNRh4_13perry_runtime6object14class_registry5state20class_parent_closure>
1188edc4:      	cmpq	$0x1, %rax
1188edc8:      	jne	0x1188edf0 <js_object_get_field_by_name+0x39b0>
1188edca:      	movq	%rdx, %rdi
1188edcd:      	movq	%r12, %rsi
1188edd0:      	movq	%r14, %rdx
1188edd3:      	callq	*0x3a8b187(%rip)        # 0x15319f60 <_GLOBAL_OFFSET_TABLE_+0x1f00>
1188edd9:      	movq	%xmm0, %r15
1188edde:      	leaq	(%rbx,%r15), %rax
1188ede2:      	addq	$0x2, %rax
1188ede6:      	cmpq	$0x1, %rax
1188edea:      	ja	0x1188e847 <js_object_get_field_by_name+0x3407>
1188edf0:      	cmpq	$0x4, %r14
1188edf4:      	jne	0x1188ef5c <js_object_get_field_by_name+0x3b1c>
1188edfa:      	cmpl	$0x656d616e, (%r12)     # imm = 0x656D616E
1188ee02:      	setne	%al
1188ee05:      	movl	-0x3c(%rbp), %edi
1188ee08:      	testl	%edi, %edi
1188ee0a:      	sete	%cl
1188ee0d:      	orb	%al, %cl
1188ee0f:      	jne	0x1188efbb <js_object_get_field_by_name+0x3b7b>
1188ee15:      	movl	$0x4, %edx
1188ee1a:      	movq	%r12, %rsi
1188ee1d:      	callq	0x116eb390 <_RNvNtNtNtCscI5nJwKNRh4_13perry_runtime6object14class_registry5state20class_is_key_deleted>
1188ee22:      	testb	%al, %al
1188ee24:      	jne	0x1188efbb <js_object_get_field_by_name+0x3b7b>
1188ee2a:      	movl	-0x3c(%rbp), %esi
1188ee2d:      	leaq	-0x68(%rbp), %rdi
1188ee31:      	callq	*0x3a9cae9(%rip)        # 0x1532b920 <_GLOBAL_OFFSET_TABLE_+0x138c0>
1188ee37:      	movq	-0x68(%rbp), %r13
1188ee3b:      	cmpq	$-0x1, %r13
1188ee3f:      	je	0x1188efbb <js_object_get_field_by_name+0x3b7b>
1188ee45:      	movq	-0x60(%rbp), %rbx
1188ee49:      	movl	-0x58(%rbp), %edx
1188ee4c:      	movq	%rbx, %rdi
1188ee4f:      	movl	%edx, %esi
1188ee51:      	callq	*0x3a8e439(%rip)        # 0x1531d290 <_GLOBAL_OFFSET_TABLE_+0x5230>
1188ee57:      	movq	%rax, %r15
1188ee5a:      	testq	%rax, %rax
1188ee5d:      	jne	0x1188ee78 <js_object_get_field_by_name+0x3a38>
1188ee5f:      	xorl	%edi, %edi
1188ee61:      	callq	0x112a3da0 <_RNvNtCscI5nJwKNRh4_13perry_runtime6string20string_storage_alloc.llvm.16259376971001104057>
1188ee66:      	movq	%rax, %r15
1188ee69:      	pxor	%xmm0, %xmm0
1188ee6d:      	movdqu	%xmm0, (%rax)
1188ee71:      	movl	$0x0, 0x10(%rax)
1188ee78:      	movabsq	$0xffffffffffff, %rax   # imm = 0xFFFFFFFFFFFF
1188ee82:      	andq	%rax, %r15
1188ee85:      	testq	%r13, %r13
1188ee88:      	je	0x1188e476 <js_object_get_field_by_name+0x3036>
1188ee8e:      	movq	%rbx, %rdi
1188ee91:      	callq	*0x3aa3f39(%rip)        # 0x15332dd0 <_GLOBAL_OFFSET_TABLE_+0x1ad70>
1188ee97:      	jmp	0x1188e476 <js_object_get_field_by_name+0x3036>
1188ee9c:      	movq	%r12, %rdi
1188ee9f:      	callq	*0x3a9a603(%rip)        # 0x153294a8 <_GLOBAL_OFFSET_TABLE_+0x11448>
1188eea5:      	movl	%eax, %eax
1188eea7:      	xorps	%xmm0, %xmm0
1188eeaa:      	cvtsi2sd	%rax, %xmm0
1188eeaf:      	jmp	0x1188e2b0 <js_object_get_field_by_name+0x2e70>
1188eeb4:      	movq	%r12, %rdi
1188eeb7:      	callq	0x11508740 <_RNvNtNtCscI5nJwKNRh4_13perry_runtime6buffer11exotic_view26is_non_indexed_buffer_view>
1188eebc:      	movabsq	$0x7ffc000000000001, %r15 # imm = 0x7FFC000000000001
1188eec6:      	testb	%al, %al
1188eec8:      	jne	0x1188e847 <js_object_get_field_by_name+0x3407>
1188eece:      	movq	%r12, %rax
1188eed1:      	shrq	$0x33, %rax
1188eed5:      	movabsq	$0xffffffffffff, %rcx   # imm = 0xFFFFFFFFFFFF
1188eedf:      	andq	%r12, %rcx
1188eee2:      	cmpl	$0xfff, %eax            # imm = 0xFFF
1188eee7:      	cmovbq	%r12, %rcx
1188eeeb:      	cmpq	$0x1000, %rcx           # imm = 0x1000
1188eef2:      	jae	0x1188f099 <js_object_get_field_by_name+0x3c59>
1188eef8:      	xorl	%r15d, %r15d
1188eefb:      	jmp	0x1188e847 <js_object_get_field_by_name+0x3407>
1188ef00:      	movl	-0x50(%rbp), %eax
1188ef03:      	cmpl	$0x3, %eax
1188ef06:      	movl	$0x2, %ebx
1188ef0b:      	cmovael	%eax, %ebx
1188ef0e:      	xorl	%ecx, %ecx
1188ef10:      	cmpl	%ebx, %edx
1188ef12:      	setb	%cl
1188ef15:      	movq	%r12, %rdi
1188ef18:      	movq	-0x30(%rbp), %rsi
1188ef1c:      	movl	%edx, %r14d
1188ef1f:      	callq	0x116b0650 <_RNvNtNtNtCscI5nJwKNRh4_13perry_runtime6object13field_get_set17get_field_by_name15prime_read_stub>
1188ef24:      	movl	%r14d, %esi
1188ef27:      	cmpl	%ebx, %r14d
1188ef2a:      	jae	0x1188f0e5 <js_object_get_field_by_name+0x3ca5>
1188ef30:      	movq	%r12, %rdi
1188ef33:      	addq	$0xc8, %rsp
1188ef3a:      	popq	%rbx
1188ef3b:      	popq	%r12
1188ef3d:      	popq	%r13
1188ef3f:      	popq	%r14
1188ef41:      	popq	%r15
1188ef43:      	popq	%rbp
1188ef44:      	jmpq	*0x3a9e266(%rip)        # 0x1532d1b0 <_GLOBAL_OFFSET_TABLE_+0x15150>
1188ef4a:      	movabsq	$0x7ffc000000000001, %r15 # imm = 0x7FFC000000000001
1188ef54:      	incq	%r15
1188ef57:      	jmp	0x1188e847 <js_object_get_field_by_name+0x3407>
1188ef5c:      	cmpq	$0x6, %r14
1188ef60:      	jne	0x1188efbb <js_object_get_field_by_name+0x3b7b>
1188ef62:      	movl	$0x676e656c, %eax       # imm = 0x676E656C
1188ef67:      	xorl	(%r12), %eax
1188ef6b:      	movzwl	0x4(%r12), %ecx
1188ef71:      	xorl	$0x6874, %ecx           # imm = 0x6874
1188ef77:      	orl	%eax, %ecx
1188ef79:      	setne	%al
1188ef7c:      	movl	-0x3c(%rbp), %edi
1188ef7f:      	testl	%edi, %edi
1188ef81:      	sete	%cl
1188ef84:      	orb	%al, %cl
1188ef86:      	movb	$0x1, %bl
1188ef88:      	cmpb	$0x1, %cl
1188ef8b:      	je	0x1188efbd <js_object_get_field_by_name+0x3b7d>
1188ef8d:      	movl	$0x6, %edx
1188ef92:      	movq	%r12, %rsi
1188ef95:      	callq	0x116eb390 <_RNvNtNtNtCscI5nJwKNRh4_13perry_runtime6object14class_registry5state20class_is_key_deleted>
1188ef9a:      	testb	%al, %al
1188ef9c:      	jne	0x1188efbd <js_object_get_field_by_name+0x3b7d>
1188ef9e:      	movl	-0x3c(%rbp), %edi
1188efa1:      	callq	*0x3a96fa1(%rip)        # 0x15325f48 <_GLOBAL_OFFSET_TABLE_+0xdee8>
1188efa7:      	cmpl	$0x1, %eax
1188efaa:      	jne	0x1188efbd <js_object_get_field_by_name+0x3b7d>
1188efac:      	movl	%edx, %eax
1188efae:      	xorps	%xmm0, %xmm0
1188efb1:      	cvtsi2sd	%rax, %xmm0
1188efb6:      	jmp	0x1188e2b0 <js_object_get_field_by_name+0x2e70>
1188efbb:      	xorl	%ebx, %ebx
1188efbd:      	movq	%r12, %rdi
1188efc0:      	movq	%r14, %rsi
1188efc3:      	callq	0x116ae820 <_RNvNtNtNtCscI5nJwKNRh4_13perry_runtime6object13field_get_set12has_property28reified_function_method_name>
1188efc8:      	testq	%rax, %rax
1188efcb:      	je	0x1188efee <js_object_get_field_by_name+0x3bae>
1188efcd:      	movaps	-0x50(%rbp), %xmm0
1188efd1:      	movq	%rax, %rdi
1188efd4:      	movq	%rdx, %rsi
1188efd7:      	callq	0x1172a5e0 <_RNvNtNtNtCscI5nJwKNRh4_13perry_runtime7closure8dispatch5bound27reify_function_method_value>
1188efdc:      	jmp	0x1188e2b0 <js_object_get_field_by_name+0x2e70>
1188efe1:      	leaq	0x398f688(%rip), %rdi   # 0x1521e670 <anon.65d6174ee4273d212d69e4c9be928638.196.llvm.16259376971001104057>
1188efe8:      	callq	*0x3a931ba(%rip)        # 0x153221a8 <_GLOBAL_OFFSET_TABLE_+0xa148>
1188efee:      	testb	%bl, %bl
1188eff0:      	je	0x1188f00f <js_object_get_field_by_name+0x3bcf>
1188eff2:      	movl	$0x6c6c6163, %eax       # imm = 0x6C6C6163
1188eff7:      	xorl	(%r12), %eax
1188effb:      	movzwl	0x4(%r12), %ecx
1188f001:      	xorl	$0x7265, %ecx           # imm = 0x7265
1188f007:      	orl	%eax, %ecx
1188f009:      	je	0x1188f2d9 <js_object_get_field_by_name+0x3e99>
1188f00f:      	cmpb	$0x0, -0xa0(%rbp)
1188f016:      	je	0x1188f033 <js_object_get_field_by_name+0x3bf3>
1188f018:      	leaq	0x2a6fb8f(%rip), %rsi   # 0x142febae <anon.65d6174ee4273d212d69e4c9be928638.395.llvm.16259376971001104057+0x872>
1188f01f:      	movq	%r12, %rdi
1188f022:      	movq	%r14, %rdx
1188f025:      	callq	*0x3a9648d(%rip)        # 0x153254b8 <_GLOBAL_OFFSET_TABLE_+0xd458>
1188f02b:      	testl	%eax, %eax
1188f02d:      	je	0x1188f2d9 <js_object_get_field_by_name+0x3e99>
1188f033:      	cmpq	$0xb, %r14
1188f037:      	jne	0x1188e83d <js_object_get_field_by_name+0x33fd>
1188f03d:      	movabsq	$0x63757274736e6f63, %rax # imm = 0x63757274736E6F63
1188f047:      	xorq	(%r12), %rax
1188f04b:      	movabsq	$0x726f746375727473, %rcx # imm = 0x726F746375727473
1188f055:      	xorq	0x3(%r12), %rcx
1188f05a:      	orq	%rax, %rcx
1188f05d:      	setne	%al
1188f060:      	movl	-0x3c(%rbp), %edi
1188f063:      	testl	%edi, %edi
1188f065:      	sete	%cl
1188f068:      	orb	%al, %cl
1188f06a:      	jne	0x1188e83d <js_object_get_field_by_name+0x33fd>
1188f070:      	callq	*0x3a8d592(%rip)        # 0x1531c608 <_GLOBAL_OFFSET_TABLE_+0x45a8>
1188f076:      	movabsq	$0x7ffc000000000001, %r15 # imm = 0x7FFC000000000001
1188f080:      	testb	%al, %al
1188f082:      	je	0x1188e847 <js_object_get_field_by_name+0x3407>
1188f088:      	leaq	0xde54f9(%rip), %rdi    # 0x12674588 <anon.6caf4f70f73897e5f37d36d35ee47d16.255.llvm.15844591618349634503+0x3e8>
1188f08f:      	movl	$0x8, %esi
1188f094:      	jmp	0x1188e2aa <js_object_get_field_by_name+0x2e6a>
1188f099:      	xorps	%xmm0, %xmm0
1188f09c:      	cvtsi2sdl	(%rcx), %xmm0
1188f0a0:      	jmp	0x1188e2b0 <js_object_get_field_by_name+0x2e70>
1188f0a5:      	movl	-0x50(%rbp), %eax
1188f0a8:      	cmpl	$0x3, %eax
1188f0ab:      	movl	$0x2, %ebx
1188f0b0:      	cmovael	%eax, %ebx
1188f0b3:      	xorl	%ecx, %ecx
1188f0b5:      	cmpl	%ebx, %edx
1188f0b7:      	setb	%cl
1188f0ba:      	movq	%r8, %r14
1188f0bd:      	movq	%r12, %rdi
1188f0c0:      	movq	%r8, %rsi
1188f0c3:      	movl	%edx, %r13d
1188f0c6:      	callq	0x116b0650 <_RNvNtNtNtCscI5nJwKNRh4_13perry_runtime6object13field_get_set17get_field_by_name15prime_read_stub>
1188f0cb:      	movq	%r15, %rdi
1188f0ce:      	movq	%r14, %rsi
1188f0d1:      	movl	%r13d, %edx
1188f0d4:      	callq	0x11579780 <_RNvNtNtCscI5nJwKNRh4_13perry_runtime6object9prop_plan16read_plan_record>
1188f0d9:      	movl	%r13d, %esi
1188f0dc:      	cmpl	%ebx, %r13d
1188f0df:      	jb	0x1188ef30 <js_object_get_field_by_name+0x3af0>
1188f0e5:      	movl	%esi, %esi
1188f0e7:      	movq	%r12, %rdi
1188f0ea:      	callq	0x115695b0 <_RNvNtNtCscI5nJwKNRh4_13perry_runtime6object5spill12overflow_get>
1188f0ef:      	jmp	0x1188e0ef <js_object_get_field_by_name+0x2caf>
1188f0f4:      	movq	%r12, %rdi
1188f0f7:      	callq	*0x3a973b3(%rip)        # 0x153264b0 <_GLOBAL_OFFSET_TABLE_+0xe450>
1188f0fd:      	xorps	%xmm0, %xmm0
1188f100:      	cvtsi2sd	%eax, %xmm0
1188f104:      	jmp	0x1188e2b0 <js_object_get_field_by_name+0x2e70>
1188f109:      	movq	%r12, %rdi
1188f10c:      	callq	*0x3a9155e(%rip)        # 0x15320670 <_GLOBAL_OFFSET_TABLE_+0x8610>
1188f112:      	movabsq	$0x7ffc000000000001, %r15 # imm = 0x7FFC000000000001
1188f11c:      	testq	%rax, %rax
1188f11f:      	je	0x1188e847 <js_object_get_field_by_name+0x3407>
1188f125:      	movq	%rax, %rcx
1188f128:      	shrq	$0x34, %rcx
1188f12c:      	movabsq	$0xffffffffffff, %r15   # imm = 0xFFFFFFFFFFFF
1188f136:      	andq	%rax, %r15
1188f139:      	movabsq	$0x7ffd000000000000, %rdx # imm = 0x7FFD000000000000
1188f143:      	orq	%rdx, %r15
1188f146:      	cmpl	$0x7ff, %ecx            # imm = 0x7FF
1188f14c:      	cmovaeq	%rax, %r15
1188f150:      	jmp	0x1188e847 <js_object_get_field_by_name+0x3407>
1188f155:      	movq	%r12, %rdi
1188f158:      	callq	0x1150f640 <_RNvNtNtCscI5nJwKNRh4_13perry_runtime6buffer6header22is_shared_array_buffer>
1188f15d:      	testb	%al, %al
1188f15f:      	je	0x1188f176 <js_object_get_field_by_name+0x3d36>
1188f161:      	movl	$0x11, %esi
1188f166:      	leaq	0x2a719d0(%rip), %rax   # 0x14300b3d <anon.65d6174ee4273d212d69e4c9be928638.2838.llvm.16259376971001104057+0x65d>
1188f16d:      	movq	%rax, -0x90(%rbp)
1188f174:      	jmp	0x1188f1cc <js_object_get_field_by_name+0x3d8c>
1188f176:      	movq	%r12, %rdi
1188f179:      	callq	0x1150e3d0 <_RNvNtNtCscI5nJwKNRh4_13perry_runtime6buffer6header15is_array_buffer>
1188f17e:      	testb	%al, %al
1188f180:      	je	0x1188f1a2 <js_object_get_field_by_name+0x3d62>
1188f182:      	movl	$0xb, %esi
1188f187:      	leaq	0x2a719c0(%rip), %rax   # 0x14300b4e <anon.65d6174ee4273d212d69e4c9be928638.2838.llvm.16259376971001104057+0x66e>
1188f18e:      	movq	%rax, -0x90(%rbp)
1188f195:      	jmp	0x1188f1cc <js_object_get_field_by_name+0x3d8c>
1188f197:      	callq	*0x3a89373(%rip)        # 0x15318510 <_GLOBAL_OFFSET_TABLE_+0x4b0>
1188f19d:      	jmp	0x1188e83d <js_object_get_field_by_name+0x33fd>
1188f1a2:      	movq	%r12, %rdi
1188f1a5:      	callq	0x1150f640 <_RNvNtNtCscI5nJwKNRh4_13perry_runtime6buffer6header22is_shared_array_buffer>
1188f1aa:      	leaq	0x2a7199d(%rip), %rcx   # 0x14300b4e <anon.65d6174ee4273d212d69e4c9be928638.2838.llvm.16259376971001104057+0x66e>
1188f1b1:      	testb	%al, %al
1188f1b3:      	movq	-0x90(%rbp), %rdx
1188f1ba:      	cmovneq	%rcx, %rdx
1188f1be:      	movq	%rdx, -0x90(%rbp)
1188f1c5:      	movzbl	%al, %esi
1188f1c8:      	orq	$0xa, %rsi
1188f1cc:      	movq	-0x90(%rbp), %rdi
1188f1d3:      	jmp	0x1188e2aa <js_object_get_field_by_name+0x2e6a>
1188f1d8:      	callq	*0x3a95222(%rip)        # 0x15324400 <_GLOBAL_OFFSET_TABLE_+0xc3a0>
1188f1de:      	movq	-0x80(%rbp), %rdi
1188f1e2:      	movq	0x1e8(%rdi,%rbx,8), %rsi
1188f1ea:      	testq	%rsi, %rsi
1188f1ed:      	jne	0x1188e440 <js_object_get_field_by_name+0x3000>
1188f1f3:      	leaq	0x39a3306(%rip), %rdi   # 0x15232500 <_RNvNtCscI5nJwKNRh4_13perry_runtime6object19CLASS_DYNAMIC_PROPS>
1188f1fa:      	callq	*0x3a8c860(%rip)        # 0x1531ba60 <_GLOBAL_OFFSET_TABLE_+0x3a00>
1188f200:      	movq	%rax, %rsi
1188f203:      	leaq	-0x68(%rbp), %rdi
1188f207:      	callq	0x111491a0 <_RNCNvNtNtNtCscI5nJwKNRh4_13perry_runtime6object13field_get_set17get_field_by_name27js_object_get_field_by_names_0B9_>
1188f20c:      	cmpq	$0x1, %rax
1188f210:      	je	0x1188e2b0 <js_object_get_field_by_name+0x2e70>
1188f216:      	jmp	0x1188e453 <js_object_get_field_by_name+0x3013>
1188f21b:      	movq	%r12, %rdi
1188f21e:      	callq	*0x3a9728c(%rip)        # 0x153264b0 <_GLOBAL_OFFSET_TABLE_+0xe450>
1188f224:      	cltq
1188f226:      	imulq	%rax, %r15
1188f22a:      	movq	%r15, %xmm0
1188f22f:      	punpckldq	0xe10e59(%rip), %xmm0 # xmm0 = xmm0[0],mem[0],xmm0[1],mem[1]
                                                # 0x126a0090 <perry_class_keys_packed_cli_2_1_112_js__1227+0x530>
1188f237:      	subpd	0xe10e61(%rip), %xmm0   # 0x126a00a0 <perry_class_keys_packed_cli_2_1_112_js__1227+0x540>
1188f23f:      	movapd	%xmm0, %xmm1
1188f243:      	unpckhpd	%xmm0, %xmm1            # xmm1 = xmm1[1],xmm0[1]
1188f247:      	addsd	%xmm0, %xmm1
1188f24b:      	movq	%xmm1, %r15
1188f250:      	jmp	0x1188e847 <js_object_get_field_by_name+0x3407>
1188f255:      	movq	%r12, %rdi
1188f258:      	callq	*0x3a89c2a(%rip)        # 0x15318e88 <_GLOBAL_OFFSET_TABLE_+0xe28>
1188f25e:      	jmp	0x1188eea5 <js_object_get_field_by_name+0x3a65>
1188f263:      	movq	%r12, %rdi
1188f266:      	callq	0x11538370 <_RNvNtNtCscI5nJwKNRh4_13perry_runtime6object15prototype_chain23object_static_prototype>
1188f26b:      	movabsq	$0x7ffc000000000001, %rcx # imm = 0x7FFC000000000001
1188f275:      	incq	%rcx
1188f278:      	cmpq	%rcx, %rdx
1188f27b:      	setne	%cl
1188f27e:      	testb	%cl, %al
1188f280:      	je	0x1188f298 <js_object_get_field_by_name+0x3e58>
1188f282:      	movq	%r12, %rdi
1188f285:      	movq	-0x30(%rbp), %rsi
1188f289:      	callq	0x11538680 <_RNvNtNtCscI5nJwKNRh4_13perry_runtime6object15prototype_chain23resolve_inherited_field>
1188f28e:      	cmpq	$0x1, %rax
1188f292:      	je	0x1188e0d6 <js_object_get_field_by_name+0x2c96>
1188f298:      	movzbl	-0x70(%rbp), %ebx
1188f29c:      	movl	%ebx, %edi
1188f29e:      	movq	%r12, %rsi
1188f2a1:      	callq	0x11300ea0 <_RNvNtNtCscI5nJwKNRh4_13perry_runtime10typedarray7species27prototype_constructor_patch>
1188f2a6:      	testb	$0x1, %al
1188f2a8:      	jne	0x1188e2b0 <js_object_get_field_by_name+0x2e70>
1188f2ae:      	movl	%ebx, %edi
1188f2b0:      	callq	0x111d8910 <_RNvNtCscI5nJwKNRh4_13perry_runtime10typedarray13name_for_kind>
1188f2b5:      	movq	%rax, %rdi
1188f2b8:      	movq	%rdx, %rsi
1188f2bb:      	jmp	0x1188e2aa <js_object_get_field_by_name+0x2e6a>
1188f2c0:      	movabsq	$0x3ff0000000000000, %r15 # imm = 0x3FF0000000000000
1188f2ca:      	jmp	0x1188e847 <js_object_get_field_by_name+0x3407>
1188f2cf:      	cvtsi2sd	%r15d, %xmm0
1188f2d4:      	jmp	0x1188e2b0 <js_object_get_field_by_name+0x2e70>
1188f2d9:      	leaq	0x2ab8126(%rip), %rdi   # 0x14347406 <anon.65d6174ee4273d212d69e4c9be928638.12135.llvm.16259376971001104057+0x3546>
1188f2e0:      	leaq	0x2a6fab9(%rip), %rdx   # 0x142feda0 <anon.65d6174ee4273d212d69e4c9be928638.1057.llvm.16259376971001104057>
1188f2e7:      	movl	$0x23, %esi
1188f2ec:      	movl	$0x14, %ecx
1188f2f1:      	callq	*0x3aa3a19(%rip)        # 0x15332d10 <_GLOBAL_OFFSET_TABLE_+0x1acb0>
1188f2f7:      	nopw	(%rax,%rax)
