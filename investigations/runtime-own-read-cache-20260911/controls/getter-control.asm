
/root/cc-perf-native-recv-0909/property-key-dispatch-20260911/cc-control:	file format elf64-x86-64

Disassembly of section .text:

000000001188ae20 <js_object_get_field_by_name>:
1188ae20:      	pushq	%rbp
1188ae21:      	movq	%rsp, %rbp
1188ae24:      	pushq	%r15
1188ae26:      	pushq	%r14
1188ae28:      	pushq	%r13
1188ae2a:      	pushq	%r12
1188ae2c:      	pushq	%rbx
1188ae2d:      	subq	$0xd8, %rsp
1188ae34:      	movq	%rsi, %r12
1188ae37:      	movq	%rdi, %r14
1188ae3a:      	movabsq	$-0x61c8864680b583eb, %r15 # imm = 0x9E3779B97F4A7C15
1188ae44:      	movabsq	$0x7ffd000000000000, %r13 # imm = 0x7FFD000000000000
1188ae4e:      	movabsq	$0xffffffffffff, %rbx   # imm = 0xFFFFFFFFFFFF
1188ae58:      	leaq	0x14(%rsi), %rax
1188ae5c:      	movq	%rax, -0x78(%rbp)
1188ae60:      	movq	%fs:0x0, %rax
1188ae6c:      	leaq	-0x35910(%rax), %rax
1188ae73:      	movq	%rax, -0xa8(%rbp)
1188ae7a:      	movq	%fs:0x0, %rax
1188ae83:      	leaq	-0x3e1a8(%rax), %rax
1188ae8a:      	movq	%rax, -0x88(%rbp)
1188ae91:      	movq	%r12, %rax
1188ae94:      	shrq	$0x3, %rax
1188ae98:      	imulq	%r15, %rax
1188ae9c:      	movq	%rax, %rdx
1188ae9f:      	shrq	$0x22, %rdx
1188aea3:      	movq	%rax, %rcx
1188aea6:      	shrq	$0x36, %rcx
1188aeaa:      	movq	%rax, %rsi
1188aead:      	shrq	$0x3c, %rsi
1188aeb1:      	movq	%rsi, -0xf8(%rbp)
1188aeb8:      	movl	$0x1, %esi
1188aebd:      	shlq	%cl, %rsi
1188aec0:      	movq	%rsi, -0xf0(%rbp)
1188aec7:      	movq	%rax, %rcx
1188aeca:      	shrq	$0x2c, %rcx
1188aece:      	movq	%rax, %rsi
1188aed1:      	movl	$0x1, %edi
1188aed6:      	shlq	%cl, %rdi
1188aed9:      	movq	%rdi, -0xe0(%rbp)
1188aee0:      	shrq	$0x32, %rsi
1188aee4:      	andl	$0xf, %esi
1188aee7:      	movq	%rsi, -0xe8(%rbp)
1188aeee:      	shrq	$0x28, %rax
1188aef2:      	andl	$0xf, %eax
1188aef5:      	movq	%rax, -0xd8(%rbp)
1188aefc:      	andl	$0x3f, %edx
1188aeff:      	movq	%rdx, -0xd0(%rbp)
1188af06:      	leaq	-0x1000(%r12), %rax
1188af0e:      	movq	%rax, -0xc8(%rbp)
1188af15:      	movabsq	$0x800000000000, %rax   # imm = 0x800000000000
1188af1f:      	addq	$-0x1000, %rax          # imm = 0xF000
1188af25:      	movq	%rax, -0xc0(%rbp)
1188af2c:      	leaq	-0x8(%r12), %rax
1188af31:      	movq	%rax, -0xb8(%rbp)
1188af38:      	movq	%fs:0x0, %rax
1188af41:      	leaq	-0x3c030(%rax), %rax
1188af48:      	movq	%rax, -0x90(%rbp)
1188af4f:      	leaq	0x2a74bdd(%rip), %rax   # 0x142ffb33 <anon.b37f594bd5826585f7e5082f302a037e.2838.llvm.4573768808118376784+0x653>
1188af56:      	movq	%rax, -0xa0(%rbp)
1188af5d:      	movq	%r12, -0x30(%rbp)
1188af61:      	testq	%r12, %r12
1188af64:      	je	0x1188af90 <js_object_get_field_by_name+0x170>
1188af66:      	cmpl	$0x18, 0x4(%r12)
1188af6c:      	jb	0x1188af90 <js_object_get_field_by_name+0x170>
1188af6e:      	leaq	0x14(%r12), %rax
1188af73:      	cmpb	$0x23, (%rax)
1188af76:      	jne	0x1188af90 <js_object_get_field_by_name+0x170>
1188af78:      	movq	%r14, %rdi
1188af7b:      	movq	%r12, %rsi
1188af7e:      	callq	0x116b6a00 <_RNvNtNtNtCscI5nJwKNRh4_13perry_runtime6object13field_get_set7ic_miss26private_member_get_by_name>
1188af83:      	testb	$0x1, %al
1188af85:      	jne	0x1188dbf5 <js_object_get_field_by_name+0x2dd5>
1188af8b:      	nopl	(%rax,%rax)
1188af90:      	movq	%r14, %rax
1188af93:      	movabsq	$-0x1000000000000, %rcx # imm = 0xFFFF000000000000
1188af9d:      	andq	%rcx, %rax
1188afa0:      	movq	%r13, %rcx
1188afa3:      	movq	%r14, %r13
1188afa6:      	andq	%rbx, %r13
1188afa9:      	cmpq	%rcx, %rax
1188afac:      	movq	%r14, %rbx
1188afaf:      	cmoveq	%r13, %rbx
1188afb3:      	cmpq	$0x100000, %rbx         # imm = 0x100000
1188afba:      	jb	0x1188b030 <js_object_get_field_by_name+0x210>
1188afbc:      	movabsq	$0x800000000000, %rax   # imm = 0x800000000000
1188afc6:      	cmpq	%rax, %rbx
1188afc9:      	jae	0x1188b030 <js_object_get_field_by_name+0x210>
1188afcb:      	cmpb	$0x2, -0x8(%rbx)
1188afcf:      	jne	0x1188b030 <js_object_get_field_by_name+0x210>
1188afd1:      	cmpb	$0x0, -0x7(%rbx)
1188afd5:      	js	0x1188b030 <js_object_get_field_by_name+0x210>
1188afd7:      	movq	0x8(%rbx), %rax
1188afdb:      	testq	%rax, %rax
1188afde:      	je	0x1188b030 <js_object_get_field_by_name+0x210>
1188afe0:      	movq	0x60(%rax), %r15
1188afe4:      	testq	%r15, %r15
1188afe7:      	je	0x1188b030 <js_object_get_field_by_name+0x210>
1188afe9:      	testq	%r12, %r12
1188afec:      	je	0x1188e184 <js_object_get_field_by_name+0x3364>
1188aff2:      	movl	0x4(%r12), %edx
1188aff7:      	leal	-0xb(%rdx), %eax
1188affa:      	cmpl	$-0xa, %eax
1188affd:      	jb	0x1188b039 <js_object_get_field_by_name+0x219>
1188afff:      	leaq	0x14(%r12), %rax
1188b004:      	movzbl	(%rax), %eax
1188b007:      	leal	-0x30(%rax), %ecx
1188b00a:      	cmpb	$0xa, %cl
1188b00d:      	setae	%cl
1188b010:      	cmpb	$0x6c, %al
1188b012:      	setne	%al
1188b015:      	testb	%cl, %al
1188b017:      	jne	0x1188b039 <js_object_get_field_by_name+0x219>
1188b019:      	cmpl	%edx, (%r12)
1188b01d:      	jne	0x1188be3b <js_object_get_field_by_name+0x101b>
1188b023:      	leaq	0x14(%r12), %rdi
1188b028:      	jmp	0x1188be5c <js_object_get_field_by_name+0x103c>
1188b02d:      	nopl	(%rax)
1188b030:      	testq	%r12, %r12
1188b033:      	je	0x1188e184 <js_object_get_field_by_name+0x3364>
1188b039:      	movq	-0xa8(%rbp), %rax
1188b040:      	movsd	(%rax), %xmm0
1188b044:      	xorpd	%xmm1, %xmm1
1188b048:      	ucomisd	%xmm1, %xmm0
1188b04c:      	jne	0x1188b050 <js_object_get_field_by_name+0x230>
1188b04e:      	jnp	0x1188b0a0 <js_object_get_field_by_name+0x280>
1188b050:      	movq	%xmm0, %rax
1188b055:      	movq	%rax, %rcx
1188b058:      	shrq	$0x30, %rcx
1188b05c:      	addl	$0xffff8006, %ecx       # imm = 0xFFFF8006
1188b062:      	cmpl	$0x5, %ecx
1188b065:      	ja	0x1188b4de <js_object_get_field_by_name+0x6be>
1188b06b:      	leaq	0x2a70796(%rip), %rdx   # 0x142fb808 <anon.b37f594bd5826585f7e5082f302a037e.11885.llvm.4573768808118376784+0x101ec>
1188b072:      	movslq	(%rdx,%rcx,4), %rcx
1188b076:      	addq	%rdx, %rcx
1188b079:      	jmpq	*%rcx
1188b07b:      	movabsq	$0xffffffffffff, %rcx   # imm = 0xFFFFFFFFFFFF
1188b085:      	andq	%rcx, %rax
1188b088:      	cmpq	%rbx, %rax
1188b08b:      	jne	0x1188b0a0 <js_object_get_field_by_name+0x280>
1188b08d:      	movq	%r12, %rdi
1188b090:      	callq	*0x3a97212(%rip)        # 0x153222a8 <_GLOBAL_OFFSET_TABLE_+0xb228>
1188b096:      	testq	%rax, %rax
1188b099:      	jne	0x1188ddb5 <js_object_get_field_by_name+0x2f95>
1188b09f:      	nop
1188b0a0:      	movq	%r14, %r12
1188b0a3:      	shrq	$0x30, %r12
1188b0a7:      	cmpq	$0x7ffd, %r12           # imm = 0x7FFD
1188b0ae:      	movq	%r14, %rax
1188b0b1:      	cmoveq	%r13, %rax
1188b0b5:      	andq	$-0x10000, %rax         # imm = 0xFFFF0000
1188b0bb:      	cmpq	$0xf0000, %rax          # imm = 0xF0000
1188b0c1:      	jne	0x1188b0e9 <js_object_get_field_by_name+0x2c9>
1188b0c3:      	movabsq	$0x7ffd000000000000, %rax # imm = 0x7FFD000000000000
1188b0cd:      	addq	%r13, %rax
1188b0d0:      	movq	%rax, %xmm0
1188b0d5:      	movq	%xmm0, -0x40(%rbp)
1188b0da:      	callq	0x11290eb0 <_RNvNtCscI5nJwKNRh4_13perry_runtime5proxy6lookup.llvm.4573768808118376784>
1188b0df:      	cmpq	$0x1, %rax
1188b0e3:      	je	0x1188da39 <js_object_get_field_by_name+0x2c19>
1188b0e9:      	cmpq	$0x1000, -0x30(%rbp)    # imm = 0x1000
1188b0f1:      	jb	0x1188b105 <js_object_get_field_by_name+0x2e5>
1188b0f3:      	movq	-0x30(%rbp), %rax
1188b0f7:      	movl	0x4(%rax), %r15d
1188b0fb:      	cmpq	$0x5, %r15
1188b0ff:      	jbe	0x1188b340 <js_object_get_field_by_name+0x520>
1188b105:      	cmpq	$0x100000, %r14         # imm = 0x100000
1188b10c:      	setae	%bl
1188b10f:      	testq	%r12, %r12
1188b112:      	je	0x1188b130 <js_object_get_field_by_name+0x310>
1188b114:      	cmpl	$0x7ffd, %r12d          # imm = 0x7FFD
1188b11b:      	jne	0x1188b620 <js_object_get_field_by_name+0x800>
1188b121:      	cmpq	$0x100000, %r13         # imm = 0x100000
1188b128:      	jae	0x1188b140 <js_object_get_field_by_name+0x320>
1188b12a:      	jmp	0x1188b620 <js_object_get_field_by_name+0x800>
1188b12f:      	nop
1188b130:      	movq	%r14, %r13
1188b133:      	cmpq	$0x100000, %r13         # imm = 0x100000
1188b13a:      	jb	0x1188b620 <js_object_get_field_by_name+0x800>
1188b140:      	movq	%r13, %rax
1188b143:      	shrq	$0x3, %rax
1188b147:      	movabsq	$-0x61c8864680b583eb, %rcx # imm = 0x9E3779B97F4A7C15
1188b151:      	imulq	%rcx, %rax
1188b155:      	movq	%rax, %rcx
1188b158:      	shrq	$0x36, %rcx
1188b15c:      	movq	%rax, %rdx
1188b15f:      	shrq	$0x3c, %rdx
1188b163:      	leaq	0x54e9536(%rip), %rsi   # 0x16d746a0 <_RNvNtNtCscI5nJwKNRh4_13perry_runtime13native_handle9canonical28CANONICAL_HANDLE_ADDR_FILTER.llvm.4573768808118376784>
1188b16a:      	movq	(%rsi,%rdx,8), %rdx
1188b16e:      	btq	%rcx, %rdx
1188b172:      	jae	0x1188b200 <js_object_get_field_by_name+0x3e0>
1188b178:      	movq	%rax, %rcx
1188b17b:      	shrq	$0x2c, %rcx
1188b17f:      	movq	%rax, %rdx
1188b182:      	shrq	$0x32, %rdx
1188b186:      	andl	$0xf, %edx
1188b189:      	leaq	0x54e9510(%rip), %rsi   # 0x16d746a0 <_RNvNtNtCscI5nJwKNRh4_13perry_runtime13native_handle9canonical28CANONICAL_HANDLE_ADDR_FILTER.llvm.4573768808118376784>
1188b190:      	movq	(%rsi,%rdx,8), %rdx
1188b194:      	btq	%rcx, %rdx
1188b198:      	jae	0x1188b200 <js_object_get_field_by_name+0x3e0>
1188b19a:      	movq	%rax, %rcx
1188b19d:      	shrq	$0x22, %rcx
1188b1a1:      	shrq	$0x28, %rax
1188b1a5:      	andl	$0xf, %eax
1188b1a8:      	leaq	0x54e94f1(%rip), %rdx   # 0x16d746a0 <_RNvNtNtCscI5nJwKNRh4_13perry_runtime13native_handle9canonical28CANONICAL_HANDLE_ADDR_FILTER.llvm.4573768808118376784>
1188b1af:      	movq	(%rdx,%rax,8), %rax
1188b1b3:      	btq	%rcx, %rax
1188b1b7:      	jae	0x1188b200 <js_object_get_field_by_name+0x3e0>
1188b1b9:      	movabsq	$0x800000000000, %rax   # imm = 0x800000000000
1188b1c3:      	decq	%rax
1188b1c6:      	cmpq	%rax, %r13
1188b1c9:      	ja	0x1188b200 <js_object_get_field_by_name+0x3e0>
1188b1cb:      	leaq	-0x8(%r13), %r15
1188b1cf:      	movq	%r15, %rdi
1188b1d2:      	callq	*0x3a90e18(%rip)        # 0x1531bff0 <_GLOBAL_OFFSET_TABLE_+0x4f70>
1188b1d8:      	testb	%al, %al
1188b1da:      	je	0x1188b200 <js_object_get_field_by_name+0x3e0>
1188b1dc:      	cmpb	$0xf, (%r15)
1188b1e0:      	jne	0x1188b200 <js_object_get_field_by_name+0x3e0>
1188b1e2:      	movabsq	$0x5045525259484e44, %rax # imm = 0x5045525259484E44
1188b1ec:      	cmpq	%rax, (%r13)
1188b1f0:      	jne	0x1188b200 <js_object_get_field_by_name+0x3e0>
1188b1f2:      	testb	$0x1, 0x1c(%r13)
1188b1f7:      	jne	0x1188bea4 <js_object_get_field_by_name+0x1084>
1188b1fd:      	nopl	(%rax)
1188b200:      	cmpq	$0x100000, -0x30(%rbp)  # imm = 0x100000
1188b208:      	jb	0x1188b620 <js_object_get_field_by_name+0x800>
1188b20e:      	cmpq	$0x200000, %r13         # imm = 0x200000
1188b215:      	jb	0x1188b620 <js_object_get_field_by_name+0x800>
1188b21b:      	movq	-0xf8(%rbp), %rax
1188b222:      	leaq	0x54e9477(%rip), %rcx   # 0x16d746a0 <_RNvNtNtCscI5nJwKNRh4_13perry_runtime13native_handle9canonical28CANONICAL_HANDLE_ADDR_FILTER.llvm.4573768808118376784>
1188b229:      	movq	(%rcx,%rax,8), %rax
1188b22d:      	testq	%rax, -0xf0(%rbp)
1188b234:      	je	0x1188b2cd <js_object_get_field_by_name+0x4ad>
1188b23a:      	movq	-0xe8(%rbp), %rax
1188b241:      	leaq	0x54e9458(%rip), %rcx   # 0x16d746a0 <_RNvNtNtCscI5nJwKNRh4_13perry_runtime13native_handle9canonical28CANONICAL_HANDLE_ADDR_FILTER.llvm.4573768808118376784>
1188b248:      	movq	(%rcx,%rax,8), %rax
1188b24c:      	testq	%rax, -0xe0(%rbp)
1188b253:      	je	0x1188b2cd <js_object_get_field_by_name+0x4ad>
1188b255:      	movq	-0xd8(%rbp), %rax
1188b25c:      	leaq	0x54e943d(%rip), %rcx   # 0x16d746a0 <_RNvNtNtCscI5nJwKNRh4_13perry_runtime13native_handle9canonical28CANONICAL_HANDLE_ADDR_FILTER.llvm.4573768808118376784>
1188b263:      	movq	(%rcx,%rax,8), %rax
1188b267:      	movq	-0xd0(%rbp), %rcx
1188b26e:      	shrq	%cl, %rax
1188b271:      	movq	-0xc0(%rbp), %rcx
1188b278:      	cmpq	%rcx, -0xc8(%rbp)
1188b27f:      	jae	0x1188b2cd <js_object_get_field_by_name+0x4ad>
1188b281:      	testb	$0x1, %al
1188b283:      	je	0x1188b2cd <js_object_get_field_by_name+0x4ad>
1188b285:      	movq	-0xb8(%rbp), %rdi
1188b28c:      	callq	*0x3a90d5e(%rip)        # 0x1531bff0 <_GLOBAL_OFFSET_TABLE_+0x4f70>
1188b292:      	testb	%al, %al
1188b294:      	je	0x1188b2cd <js_object_get_field_by_name+0x4ad>
1188b296:      	movq	-0xb8(%rbp), %rax
1188b29d:      	cmpb	$0xf, (%rax)
1188b2a0:      	jne	0x1188b2cd <js_object_get_field_by_name+0x4ad>
1188b2a2:      	movq	-0x30(%rbp), %rax
1188b2a6:      	movabsq	$0x5045525259484e44, %rcx # imm = 0x5045525259484E44
1188b2b0:      	cmpq	%rcx, (%rax)
1188b2b3:      	jne	0x1188b2cd <js_object_get_field_by_name+0x4ad>
1188b2b5:      	movq	-0x30(%rbp), %rax
1188b2b9:      	testb	$0x1, 0x1c(%rax)
1188b2bd:      	je	0x1188b2cd <js_object_get_field_by_name+0x4ad>
1188b2bf:      	movq	-0x30(%rbp), %rax
1188b2c3:      	cmpb	$0x0, 0x1b(%rax)
1188b2c7:      	je	0x1188b620 <js_object_get_field_by_name+0x800>
1188b2cd:      	movq	-0x30(%rbp), %rax
1188b2d1:      	testb	$0x10, -0x7(%rax)
1188b2d5:      	je	0x1188b620 <js_object_get_field_by_name+0x800>
1188b2db:      	movq	-0x88(%rbp), %rdi
1188b2e2:      	cmpq	$0x0, 0x78(%rdi)
1188b2e7:      	je	0x1188d2ab <js_object_get_field_by_name+0x248b>
1188b2ed:      	movq	%r13, %rsi
1188b2f0:      	shrq	$0x14, %rsi
1188b2f4:      	movq	0x10(%rdi), %rax
1188b2f8:      	cmpb	$0x2, (%rax)
1188b2fb:      	jne	0x1188b506 <js_object_get_field_by_name+0x6e6>
1188b301:      	cmpb	$0x0, 0x88(%rax)
1188b308:      	je	0x1188b552 <js_object_get_field_by_name+0x732>
1188b30e:      	cmpq	%rsi, 0x80(%rax)
1188b315:      	jne	0x1188b552 <js_object_get_field_by_name+0x732>
1188b31b:      	cmpq	0x60(%rax), %r13
1188b31f:      	jb	0x1188b552 <js_object_get_field_by_name+0x732>
1188b325:      	cmpq	0x68(%rax), %r13
1188b329:      	jae	0x1188b552 <js_object_get_field_by_name+0x732>
1188b32f:      	leaq	0x60(%rax), %rcx
1188b333:      	jmp	0x1188b5d7 <js_object_get_field_by_name+0x7b7>
1188b338:      	nopl	(%rax,%rax)
1188b340:      	testq	%r15, %r15
1188b343:      	je	0x1188b3dc <js_object_get_field_by_name+0x5bc>
1188b349:      	movq	-0x30(%rbp), %rax
1188b34d:      	addq	$0x14, %rax
1188b351:      	movsbq	(%rax), %rsi
1188b355:      	testq	%rsi, %rsi
1188b358:      	js	0x1188b105 <js_object_get_field_by_name+0x2e5>
1188b35e:      	cmpl	$0x1, %r15d
1188b362:      	je	0x1188b3de <js_object_get_field_by_name+0x5be>
1188b364:      	movq	-0x30(%rbp), %rax
1188b368:      	movsbq	0x15(%rax), %rax
1188b36d:      	testq	%rax, %rax
1188b370:      	js	0x1188b105 <js_object_get_field_by_name+0x2e5>
1188b376:      	shlq	$0x8, %rax
1188b37a:      	orq	%rax, %rsi
1188b37d:      	cmpl	$0x2, %r15d
1188b381:      	je	0x1188b3de <js_object_get_field_by_name+0x5be>
1188b383:      	movq	-0x30(%rbp), %rax
1188b387:      	movsbq	0x16(%rax), %rax
1188b38c:      	testq	%rax, %rax
1188b38f:      	js	0x1188b105 <js_object_get_field_by_name+0x2e5>
1188b395:      	shlq	$0x10, %rax
1188b399:      	orq	%rax, %rsi
1188b39c:      	cmpl	$0x3, %r15d
1188b3a0:      	je	0x1188b3de <js_object_get_field_by_name+0x5be>
1188b3a2:      	movq	-0x30(%rbp), %rax
1188b3a6:      	movsbq	0x17(%rax), %rax
1188b3ab:      	testq	%rax, %rax
1188b3ae:      	js	0x1188b105 <js_object_get_field_by_name+0x2e5>
1188b3b4:      	shlq	$0x18, %rax
1188b3b8:      	orq	%rax, %rsi
1188b3bb:      	cmpl	$0x4, %r15d
1188b3bf:      	je	0x1188b3de <js_object_get_field_by_name+0x5be>
1188b3c1:      	movq	-0x30(%rbp), %rax
1188b3c5:      	movsbq	0x18(%rax), %rax
1188b3ca:      	testq	%rax, %rax
1188b3cd:      	js	0x1188b105 <js_object_get_field_by_name+0x2e5>
1188b3d3:      	shlq	$0x20, %rax
1188b3d7:      	orq	%rax, %rsi
1188b3da:      	jmp	0x1188b3de <js_object_get_field_by_name+0x5be>
1188b3dc:      	xorl	%esi, %esi
1188b3de:      	cmpq	$0xfffff, %r14          # imm = 0xFFFFF
1188b3e5:      	jbe	0x1188b4d7 <js_object_get_field_by_name+0x6b7>
1188b3eb:      	movb	$0x1, %bl
1188b3ed:      	movabsq	$0x800000000000, %rax   # imm = 0x800000000000
1188b3f7:      	cmpq	%rax, %r14
1188b3fa:      	jae	0x1188b10f <js_object_get_field_by_name+0x2ef>
1188b400:      	cmpb	$0x2, -0x8(%r14)
1188b405:      	jne	0x1188b10f <js_object_get_field_by_name+0x2ef>
1188b40b:      	cmpb	$0x0, -0x7(%r14)
1188b410:      	js	0x1188b10f <js_object_get_field_by_name+0x2ef>
1188b416:      	testb	$0x9, -0x5(%r14)
1188b41b:      	jne	0x1188b10f <js_object_get_field_by_name+0x2ef>
1188b421:      	movl	(%r14), %eax
1188b424:      	cmpl	$-0x2, %eax
1188b427:      	je	0x1188b10f <js_object_get_field_by_name+0x2ef>
1188b42d:      	testl	%eax, %eax
1188b42f:      	je	0x1188b10f <js_object_get_field_by_name+0x2ef>
1188b435:      	movl	0x4(%r14), %edi
1188b439:      	cmpl	$0xbfffffff, %edi       # imm = 0xBFFFFFFF
1188b43f:      	jg	0x1188b10f <js_object_get_field_by_name+0x2ef>
1188b445:      	movl	0x3ac6c1d(%rip), %ecx   # 0x15352068 <_RNvNvNtNtCscI5nJwKNRh4_13perry_runtime6object9read_stub9READ_STUB4SLOT+0x10>
1188b44b:      	cmpl	$0x300, %ecx            # imm = 0x300
1188b451:      	movq	-0x88(%rbp), %rax
1188b458:      	jae	0x1188d336 <js_object_get_field_by_name+0x2516>
1188b45e:      	cmpq	$0x0, 0x78(%rax)
1188b463:      	je	0x1188d2fd <js_object_get_field_by_name+0x24dd>
1188b469:      	movq	0x1e8(%rax,%rcx,8), %rdx
1188b471:      	testq	%rdx, %rdx
1188b474:      	je	0x1188d336 <js_object_get_field_by_name+0x2516>
1188b47a:      	shlq	$0x28, %r15
1188b47e:      	movabsq	$0x7ff8ffffffffffff, %rax # imm = 0x7FF8FFFFFFFFFFFF
1188b488:      	incq	%rax
1188b48b:      	orq	%rax, %rsi
1188b48e:      	orq	%r15, %rsi
1188b491:      	movabsq	$0x4000000000000000, %rax # imm = 0x4000000000000000
1188b49b:      	orq	%rax, %rdi
1188b49e:      	callq	0x11143960 <_RNCNvNtNtCscI5nJwKNRh4_13perry_runtime6object9read_stub15read_stub_probe0B7_>
1188b4a3:      	cmpl	$0x1, %eax
1188b4a6:      	jne	0x1188b10f <js_object_get_field_by_name+0x2ef>
1188b4ac:      	testl	$0x40000000, %edx       # imm = 0x40000000
1188b4b2:      	jne	0x1188d193 <js_object_get_field_by_name+0x2373>
1188b4b8:      	movl	%edx, %eax
1188b4ba:      	movq	0x10(%r14,%rax,8), %rax
1188b4bf:      	movabsq	$0x7ffc000000000010, %rcx # imm = 0x7FFC000000000010
1188b4c9:      	cmpq	%rcx, %rax
1188b4cc:      	je	0x1188b10f <js_object_get_field_by_name+0x2ef>
1188b4d2:      	jmp	0x1188e9ac <js_object_get_field_by_name+0x3b8c>
1188b4d7:      	xorl	%ebx, %ebx
1188b4d9:      	jmp	0x1188b10f <js_object_get_field_by_name+0x2ef>
1188b4de:      	leaq	-0x1(%rax), %rcx
1188b4e2:      	movabsq	$0xffffffffffff, %rdx   # imm = 0xFFFFFFFFFFFF
1188b4ec:      	cmpq	%rdx, %rcx
1188b4ef:      	movl	$0x0, %ecx
1188b4f4:      	cmovaeq	%rcx, %rax
1188b4f8:      	cmpq	%rbx, %rax
1188b4fb:      	je	0x1188b08d <js_object_get_field_by_name+0x26d>
1188b501:      	jmp	0x1188b0a0 <js_object_get_field_by_name+0x280>
1188b506:      	movq	%rsi, %rcx
1188b509:      	subq	0x8(%rax), %rcx
1188b50d:      	cmpq	0x28(%rax), %rcx
1188b511:      	jae	0x1188b5ec <js_object_get_field_by_name+0x7cc>
1188b517:      	movq	0x20(%rax), %rdx
1188b51b:      	leaq	(%rcx,%rcx,4), %rcx
1188b51f:      	movq	(%rdx,%rcx,8), %rdi
1188b523:      	cmpq	0x10(%rax), %rdi
1188b527:      	jne	0x1188b5f0 <js_object_get_field_by_name+0x7d0>
1188b52d:      	leaq	(%rdx,%rcx,8), %rcx
1188b531:      	cmpq	0x8(%rcx), %r13
1188b535:      	jb	0x1188b5f0 <js_object_get_field_by_name+0x7d0>
1188b53b:      	cmpq	0x10(%rcx), %r13
1188b53f:      	jae	0x1188b5f0 <js_object_get_field_by_name+0x7d0>
1188b545:      	incq	0x30(%rax)
1188b549:      	addq	$0x21, %rcx
1188b54d:      	jmp	0x1188b5df <js_object_get_field_by_name+0x7bf>
1188b552:      	cmpb	$0x1, 0xb8(%rax)
1188b559:      	jne	0x1188b57f <js_object_get_field_by_name+0x75f>
1188b55b:      	cmpq	%rsi, 0xb0(%rax)
1188b562:      	jne	0x1188b57f <js_object_get_field_by_name+0x75f>
1188b564:      	cmpq	0x90(%rax), %r13
1188b56b:      	jb	0x1188b57f <js_object_get_field_by_name+0x75f>
1188b56d:      	cmpq	0x98(%rax), %r13
1188b574:      	jae	0x1188b57f <js_object_get_field_by_name+0x75f>
1188b576:      	leaq	0x90(%rax), %rcx
1188b57d:      	jmp	0x1188b5d7 <js_object_get_field_by_name+0x7b7>
1188b57f:      	cmpb	$0x1, 0xe8(%rax)
1188b586:      	jne	0x1188b5ac <js_object_get_field_by_name+0x78c>
1188b588:      	cmpq	%rsi, 0xe0(%rax)
1188b58f:      	jne	0x1188b5ac <js_object_get_field_by_name+0x78c>
1188b591:      	cmpq	0xc0(%rax), %r13
1188b598:      	jb	0x1188b5ac <js_object_get_field_by_name+0x78c>
1188b59a:      	cmpq	0xc8(%rax), %r13
1188b5a1:      	jae	0x1188b5ac <js_object_get_field_by_name+0x78c>
1188b5a3:      	leaq	0xc0(%rax), %rcx
1188b5aa:      	jmp	0x1188b5d7 <js_object_get_field_by_name+0x7b7>
1188b5ac:      	cmpb	$0x1, 0x118(%rax)
1188b5b3:      	jne	0x1188b5f0 <js_object_get_field_by_name+0x7d0>
1188b5b5:      	cmpq	%rsi, 0x110(%rax)
1188b5bc:      	jne	0x1188b5f0 <js_object_get_field_by_name+0x7d0>
1188b5be:      	cmpq	0xf0(%rax), %r13
1188b5c5:      	jb	0x1188b5f0 <js_object_get_field_by_name+0x7d0>
1188b5c7:      	cmpq	0xf8(%rax), %r13
1188b5ce:      	jae	0x1188b5f0 <js_object_get_field_by_name+0x7d0>
1188b5d0:      	leaq	0xf0(%rax), %rcx
1188b5d7:      	incq	0x30(%rax)
1188b5db:      	addq	$0x19, %rcx
1188b5df:      	movzbl	(%rcx), %eax
1188b5e2:      	cmpb	$-0x1, %al
1188b5e4:      	je	0x1188b5f4 <js_object_get_field_by_name+0x7d4>
1188b5e6:      	testb	%al, %al
1188b5e8:      	jne	0x1188b601 <js_object_get_field_by_name+0x7e1>
1188b5ea:      	jmp	0x1188b620 <js_object_get_field_by_name+0x800>
1188b5ec:      	incq	0x58(%rax)
1188b5f0:      	incq	0x38(%rax)
1188b5f4:      	movq	%r13, %rdi
1188b5f7:      	callq	*0x3a8dd7b(%rip)        # 0x15319378 <_GLOBAL_OFFSET_TABLE_+0x22f8>
1188b5fd:      	testb	%al, %al
1188b5ff:      	je	0x1188b620 <js_object_get_field_by_name+0x800>
1188b601:      	cmpb	$0x2, -0x8(%r13)
1188b606:      	jne	0x1188b620 <js_object_get_field_by_name+0x800>
1188b608:      	testb	$0x9, -0x5(%r13)
1188b60d:      	je	0x1188bc21 <js_object_get_field_by_name+0xe01>
1188b613:      	nopw	%cs:(%rax,%rax)
1188b620:      	testq	%r12, %r12
1188b623:      	sete	%al
1188b626:      	testb	%bl, %al
1188b628:      	je	0x1188ba70 <js_object_get_field_by_name+0xc50>
1188b62e:      	movq	%r14, %r12
1188b631:      	shrq	$0x3, %r12
1188b635:      	movabsq	$-0x61c8864680b583eb, %rax # imm = 0x9E3779B97F4A7C15
1188b63f:      	imulq	%rax, %r12
1188b643:      	movq	%r12, %rbx
1188b646:      	shrq	$0x22, %rbx
1188b64a:      	movq	%r12, %rcx
1188b64d:      	shrq	$0x36, %rcx
1188b651:      	movq	%r12, %r13
1188b654:      	shrq	$0x3c, %r13
1188b658:      	leaq	0x54e9041(%rip), %rax   # 0x16d746a0 <_RNvNtNtCscI5nJwKNRh4_13perry_runtime13native_handle9canonical28CANONICAL_HANDLE_ADDR_FILTER.llvm.4573768808118376784>
1188b65f:      	movq	(%rax,%r13,8), %rax
1188b663:      	movl	$0x1, %r15d
1188b669:      	shlq	%cl, %r15
1188b66c:      	btq	%rcx, %rax
1188b670:      	jae	0x1188b700 <js_object_get_field_by_name+0x8e0>
1188b676:      	movq	%r12, %rax
1188b679:      	shrq	$0x2c, %rax
1188b67d:      	movq	%r12, %rcx
1188b680:      	shrq	$0x32, %rcx
1188b684:      	andl	$0xf, %ecx
1188b687:      	leaq	0x54e9012(%rip), %rdx   # 0x16d746a0 <_RNvNtNtCscI5nJwKNRh4_13perry_runtime13native_handle9canonical28CANONICAL_HANDLE_ADDR_FILTER.llvm.4573768808118376784>
1188b68e:      	movq	(%rdx,%rcx,8), %rcx
1188b692:      	btq	%rax, %rcx
1188b696:      	jae	0x1188b700 <js_object_get_field_by_name+0x8e0>
1188b698:      	movq	%r12, %rax
1188b69b:      	shrq	$0x28, %rax
1188b69f:      	andl	$0xf, %eax
1188b6a2:      	leaq	0x54e8ff7(%rip), %rcx   # 0x16d746a0 <_RNvNtNtCscI5nJwKNRh4_13perry_runtime13native_handle9canonical28CANONICAL_HANDLE_ADDR_FILTER.llvm.4573768808118376784>
1188b6a9:      	movq	(%rcx,%rax,8), %rax
1188b6ad:      	movl	%ebx, %ecx
1188b6af:      	shrq	%cl, %rax
1188b6b2:      	leaq	-0x1000(%r14), %rcx
1188b6b9:      	cmpq	-0xc0(%rbp), %rcx
1188b6c0:      	jae	0x1188b700 <js_object_get_field_by_name+0x8e0>
1188b6c2:      	testb	$0x1, %al
1188b6c4:      	je	0x1188b700 <js_object_get_field_by_name+0x8e0>
1188b6c6:      	leaq	-0x8(%r14), %rdi
1188b6ca:      	callq	*0x3a90920(%rip)        # 0x1531bff0 <_GLOBAL_OFFSET_TABLE_+0x4f70>
1188b6d0:      	testb	%al, %al
1188b6d2:      	je	0x1188b700 <js_object_get_field_by_name+0x8e0>
1188b6d4:      	leaq	-0x8(%r14), %rax
1188b6d8:      	cmpb	$0xf, (%rax)
1188b6db:      	jne	0x1188b700 <js_object_get_field_by_name+0x8e0>
1188b6dd:      	movabsq	$0x5045525259484e44, %rax # imm = 0x5045525259484E44
1188b6e7:      	cmpq	%rax, (%r14)
1188b6ea:      	jne	0x1188b700 <js_object_get_field_by_name+0x8e0>
1188b6ec:      	testb	$0x1, 0x1c(%r14)
1188b6f1:      	je	0x1188b700 <js_object_get_field_by_name+0x8e0>
1188b6f3:      	cmpb	$0x0, 0x1b(%r14)
1188b6f8:      	je	0x1188b720 <js_object_get_field_by_name+0x900>
1188b6fa:      	nopw	(%rax,%rax)
1188b700:      	cmpq	$0x1000, %r14           # imm = 0x1000
1188b707:      	jb	0x1188e184 <js_object_get_field_by_name+0x3364>
1188b70d:      	movabsq	$0x800000000000, %rax   # imm = 0x800000000000
1188b717:      	cmpq	%rax, %r14
1188b71a:      	jae	0x1188e184 <js_object_get_field_by_name+0x3364>
1188b720:      	leaq	0x54e8f79(%rip), %rax   # 0x16d746a0 <_RNvNtNtCscI5nJwKNRh4_13perry_runtime13native_handle9canonical28CANONICAL_HANDLE_ADDR_FILTER.llvm.4573768808118376784>
1188b727:      	movq	(%rax,%r13,8), %rax
1188b72b:      	testq	%r15, %rax
1188b72e:      	je	0x1188b7b0 <js_object_get_field_by_name+0x990>
1188b734:      	movq	%r12, %rax
1188b737:      	shrq	$0x2c, %rax
1188b73b:      	movq	%r12, %rcx
1188b73e:      	shrq	$0x32, %rcx
1188b742:      	andl	$0xf, %ecx
1188b745:      	leaq	0x54e8f54(%rip), %rdx   # 0x16d746a0 <_RNvNtNtCscI5nJwKNRh4_13perry_runtime13native_handle9canonical28CANONICAL_HANDLE_ADDR_FILTER.llvm.4573768808118376784>
1188b74c:      	movq	(%rdx,%rcx,8), %rcx
1188b750:      	btq	%rax, %rcx
1188b754:      	jae	0x1188b7b0 <js_object_get_field_by_name+0x990>
1188b756:      	shrq	$0x28, %r12
1188b75a:      	andl	$0xf, %r12d
1188b75e:      	leaq	0x54e8f3b(%rip), %rax   # 0x16d746a0 <_RNvNtNtCscI5nJwKNRh4_13perry_runtime13native_handle9canonical28CANONICAL_HANDLE_ADDR_FILTER.llvm.4573768808118376784>
1188b765:      	movq	(%rax,%r12,8), %rax
1188b769:      	btq	%rbx, %rax
1188b76d:      	jae	0x1188b7b0 <js_object_get_field_by_name+0x990>
1188b76f:      	leaq	-0x8(%r14), %rbx
1188b773:      	movq	%rbx, %rdi
1188b776:      	callq	*0x3a90874(%rip)        # 0x1531bff0 <_GLOBAL_OFFSET_TABLE_+0x4f70>
1188b77c:      	testb	%al, %al
1188b77e:      	je	0x1188b7b0 <js_object_get_field_by_name+0x990>
1188b780:      	cmpb	$0xf, (%rbx)
1188b783:      	jne	0x1188b7b0 <js_object_get_field_by_name+0x990>
1188b785:      	movabsq	$0x5045525259484e44, %rax # imm = 0x5045525259484E44
1188b78f:      	cmpq	%rax, (%r14)
1188b792:      	jne	0x1188b7b0 <js_object_get_field_by_name+0x990>
1188b794:      	testb	$0x1, 0x1c(%r14)
1188b799:      	je	0x1188b7b0 <js_object_get_field_by_name+0x990>
1188b79b:      	cmpb	$0x0, 0x1b(%r14)
1188b7a0:      	je	0x1188ba70 <js_object_get_field_by_name+0xc50>
1188b7a6:      	nopw	%cs:(%rax,%rax)
1188b7b0:      	movq	-0x30(%rbp), %rax
1188b7b4:      	cmpl	$0x4, 0x4(%rax)
1188b7b8:      	jne	0x1188ba70 <js_object_get_field_by_name+0xc50>
1188b7be:      	addq	$0x14, %rax
1188b7c2:      	cmpl	$0x657a6973, (%rax)     # imm = 0x657A6973
1188b7c8:      	jne	0x1188ba70 <js_object_get_field_by_name+0xc50>
1188b7ce:      	movq	-0x90(%rbp), %r15
1188b7d5:      	movzbl	0x20(%r15), %eax
1188b7da:      	testl	%eax, %eax
1188b7dc:      	movabsq	$0x7ffd000000000000, %rbx # imm = 0x7FFD000000000000
1188b7e6:      	jne	0x1188d2bd <js_object_get_field_by_name+0x249d>
1188b7ec:      	movq	(%r15), %rax
1188b7ef:      	movabsq	$0x7fffffffffffffff, %rcx # imm = 0x7FFFFFFFFFFFFFFF
1188b7f9:      	cmpq	%rcx, %rax
1188b7fc:      	jae	0x1188e662 <js_object_get_field_by_name+0x3842>
1188b802:      	movq	0x18(%r15), %r12
1188b806:      	testq	%r14, %r14
1188b809:      	je	0x1188b82c <js_object_get_field_by_name+0xa0c>
1188b80b:      	leaq	0x54e7eaa(%rip), %rcx   # 0x16d736bc <PERRY_INCREMENTAL_MARK_BARRIER_ACTIVE_COUNT>
1188b812:      	movl	(%rcx), %ecx
1188b814:      	testl	%ecx, %ecx
1188b816:      	je	0x1188b82c <js_object_get_field_by_name+0xa0c>
1188b818:      	leaq	(%r14,%rbx), %rdi
1188b81c:      	callq	*0x3a9e426(%rip)        # 0x15329c48 <_GLOBAL_OFFSET_TABLE_+0x12bc8>
1188b822:      	movq	-0x90(%rbp), %rax
1188b829:      	movq	(%rax), %rax
1188b82c:      	testq	%rax, %rax
1188b82f:      	jne	0x1188e66f <js_object_get_field_by_name+0x384f>
1188b835:      	movq	-0x90(%rbp), %rbx
1188b83c:      	movq	$-0x1, (%rbx)
1188b843:      	movq	0x18(%rbx), %r15
1188b847:      	cmpq	0x8(%rbx), %r15
1188b84b:      	je	0x1188bdb7 <js_object_get_field_by_name+0xf97>
1188b851:      	movq	0x10(%rbx), %rax
1188b855:      	leaq	(%r15,%r15,2), %r13
1188b859:      	movq	$0x1, (%rax,%r13,8)
1188b861:      	movq	%r14, 0x8(%rax,%r13,8)
1188b866:      	movabsq	$0x7ffd000000000000, %rcx # imm = 0x7FFD000000000000
1188b870:      	movq	%rcx, 0x10(%rax,%r13,8)
1188b875:      	leaq	0x1(%r15), %rax
1188b879:      	movq	%rax, 0x18(%rbx)
1188b87d:      	incq	(%rbx)
1188b880:      	movq	%r14, %rdi
1188b883:      	movq	-0x30(%rbp), %rsi
1188b887:      	callq	0x1167f9a0 <_RNvNtNtNtCscI5nJwKNRh4_13perry_runtime6object10object_ops10keys_array15own_key_present>
1188b88c:      	movq	(%rbx), %rcx
1188b88f:      	movabsq	$0x7fffffffffffffff, %rdx # imm = 0x7FFFFFFFFFFFFFFF
1188b899:      	cmpq	%rdx, %rcx
1188b89c:      	jae	0x1188e49e <js_object_get_field_by_name+0x367e>
1188b8a2:      	leaq	0x1(%rcx), %rsi
1188b8a6:      	movq	%rsi, (%rbx)
1188b8a9:      	movq	0x18(%rbx), %rdx
1188b8ad:      	cmpq	%rdx, %r15
1188b8b0:      	jae	0x1188e4ab <js_object_get_field_by_name+0x368b>
1188b8b6:      	movq	0x10(%rbx), %rdi
1188b8ba:      	cmpq	$0x1, (%rdi,%r13,8)
1188b8bf:      	jne	0x1188e4b1 <js_object_get_field_by_name+0x3691>
1188b8c5:      	leaq	(%rdi,%r13,8), %rdi
1188b8c9:      	movq	0x8(%rdi), %rdi
1188b8cd:      	movq	%rcx, (%rbx)
1188b8d0:      	testb	%al, %al
1188b8d2:      	jne	0x1188ba2d <js_object_get_field_by_name+0xc0d>
1188b8d8:      	callq	*0x3a9e13a(%rip)        # 0x15329a18 <_GLOBAL_OFFSET_TABLE_+0x12998>
1188b8de:      	testl	%eax, %eax
1188b8e0:      	je	0x1188b8fd <js_object_get_field_by_name+0xadd>
1188b8e2:      	movl	$0x4, %edx
1188b8e7:      	movl	%eax, %edi
1188b8e9:      	leaq	0x2a5fbcc(%rip), %rsi   # 0x142eb4bc <anon.b37f594bd5826585f7e5082f302a037e.6575.llvm.4573768808118376784+0x84>
1188b8f0:      	callq	0x11520d20 <_RNvNtNtCscI5nJwKNRh4_13perry_runtime6object13native_module25class_instance_has_member>
1188b8f5:      	testb	%al, %al
1188b8f7:      	jne	0x1188ba08 <js_object_get_field_by_name+0xbe8>
1188b8fd:      	movq	-0x90(%rbp), %rbx
1188b904:      	movq	(%rbx), %rcx
1188b907:      	movabsq	$0x7fffffffffffffff, %rax # imm = 0x7FFFFFFFFFFFFFFF
1188b911:      	cmpq	%rax, %rcx
1188b914:      	jae	0x1188e49e <js_object_get_field_by_name+0x367e>
1188b91a:      	leaq	0x1(%rcx), %rsi
1188b91e:      	movq	%rsi, (%rbx)
1188b921:      	movq	0x18(%rbx), %rdx
1188b925:      	cmpq	%rdx, %r15
1188b928:      	jae	0x1188e4ab <js_object_get_field_by_name+0x368b>
1188b92e:      	movq	0x10(%rbx), %rax
1188b932:      	cmpq	$0x1, (%rax,%r13,8)
1188b937:      	jne	0x1188e4b1 <js_object_get_field_by_name+0x3691>
1188b93d:      	leaq	(%rax,%r13,8), %rax
1188b941:      	movq	0x8(%rax), %rax
1188b945:      	movq	%rcx, (%rbx)
1188b948:      	movzbl	0x5569601(%rip), %edi   # 0x16df4f50 <_RNvNtNtCscI5nJwKNRh4_13perry_runtime6object16map_set_subclass21MAP_SET_SUBCLASS_EVER.0.llvm.4573768808118376784>
1188b94f:      	testb	%dil, %dil
1188b952:      	je	0x1188ba2d <js_object_get_field_by_name+0xc0d>
1188b958:      	movabsq	$0xffffffffffff, %rcx   # imm = 0xFFFFFFFFFFFF
1188b962:      	andq	%rcx, %rax
1188b965:      	movabsq	$0x7ffd000000000000, %rcx # imm = 0x7FFD000000000000
1188b96f:      	orq	%rcx, %rax
1188b972:      	movq	%rax, %xmm0
1188b977:      	callq	0x11543720 <_RNvNtNtCscI5nJwKNRh4_13perry_runtime6object16map_set_subclass19instance_object_ptr.llvm.4573768808118376784>
1188b97c:      	cmpq	$0x1, %rax
1188b980:      	jne	0x1188ba08 <js_object_get_field_by_name+0xbe8>
1188b986:      	movq	%rdx, %rbx
1188b989:      	leaq	0x2ab3611(%rip), %rdi   # 0x1433efa1 <anon.b37f594bd5826585f7e5082f302a037e.10935.llvm.4573768808118376784>
1188b990:      	movl	$0x1c, %esi
1188b995:      	movl	$0x1c, %edx
1188b99a:      	callq	*0x3a90908(%rip)        # 0x1531c2a8 <_GLOBAL_OFFSET_TABLE_+0x5228>
1188b9a0:      	movq	%rbx, %rdi
1188b9a3:      	movq	%rax, %rsi
1188b9a6:      	callq	*0x3aa5534(%rip)        # 0x15330ee0 <_GLOBAL_OFFSET_TABLE_+0x19e60>
1188b9ac:      	movq	%xmm0, %rbx
1188b9b1:      	movq	%rbx, %rax
1188b9b4:      	movabsq	$-0x1000000000000, %rcx # imm = 0xFFFF000000000000
1188b9be:      	andq	%rcx, %rax
1188b9c1:      	movabsq	$0x7ffd000000000000, %rcx # imm = 0x7FFD000000000000
1188b9cb:      	cmpq	%rcx, %rax
1188b9ce:      	jne	0x1188ba08 <js_object_get_field_by_name+0xbe8>
1188b9d0:      	movabsq	$0xffffffffffff, %rax   # imm = 0xFFFFFFFFFFFF
1188b9da:      	andq	%rax, %rbx
1188b9dd:      	cmpq	$0x1008, %rbx           # imm = 0x1008
1188b9e4:      	jb	0x1188ba08 <js_object_get_field_by_name+0xbe8>
1188b9e6:      	movq	%rbx, %rdi
1188b9e9:      	callq	*0x3a9d1e1(%rip)        # 0x15328bd0 <_GLOBAL_OFFSET_TABLE_+0x11b50>
1188b9ef:      	testb	%al, %al
1188b9f1:      	jne	0x1188e5ce <js_object_get_field_by_name+0x37ae>
1188b9f7:      	movq	%rbx, %rdi
1188b9fa:      	callq	*0x3a8ca10(%rip)        # 0x15318410 <_GLOBAL_OFFSET_TABLE_+0x1390>
1188ba00:      	testb	%al, %al
1188ba02:      	jne	0x1188e5d9 <js_object_get_field_by_name+0x37b9>
1188ba08:      	movq	-0x90(%rbp), %rbx
1188ba0f:      	movq	(%rbx), %rcx
1188ba12:      	movabsq	$0x7fffffffffffffff, %rax # imm = 0x7FFFFFFFFFFFFFFF
1188ba1c:      	cmpq	%rax, %rcx
1188ba1f:      	jae	0x1188e49e <js_object_get_field_by_name+0x367e>
1188ba25:      	movq	0x18(%rbx), %rdx
1188ba29:      	leaq	0x1(%rcx), %rsi
1188ba2d:      	movq	%rsi, (%rbx)
1188ba30:      	cmpq	%rdx, %r15
1188ba33:      	jae	0x1188e4ab <js_object_get_field_by_name+0x368b>
1188ba39:      	movq	0x10(%rbx), %rax
1188ba3d:      	cmpq	$0x1, (%rax,%r13,8)
1188ba42:      	jne	0x1188e4b1 <js_object_get_field_by_name+0x3691>
1188ba48:      	leaq	(%rax,%r13,8), %rax
1188ba4c:      	movq	0x8(%rax), %r14
1188ba50:      	movq	%rcx, (%rbx)
1188ba53:      	testq	%rcx, %rcx
1188ba56:      	jne	0x1188e67c <js_object_get_field_by_name+0x385c>
1188ba5c:      	cmpq	%rdx, %r12
1188ba5f:      	ja	0x1188ba70 <js_object_get_field_by_name+0xc50>
1188ba61:      	movq	%r12, 0x18(%rbx)
1188ba65:      	nopw	%cs:(%rax,%rax)
1188ba70:      	movq	%r14, %rax
1188ba73:      	shrq	$0x30, %rax
1188ba77:      	movq	%rax, -0x40(%rbp)
1188ba7b:      	cmpq	$0x100000, %r14         # imm = 0x100000
1188ba82:      	jb	0x1188c401 <js_object_get_field_by_name+0x15e1>
1188ba88:      	cmpq	$0x0, -0x40(%rbp)
1188ba8d:      	jne	0x1188c401 <js_object_get_field_by_name+0x15e1>
1188ba93:      	movq	%r14, %r12
1188ba96:      	shrq	$0x3, %r12
1188ba9a:      	movabsq	$-0x61c8864680b583eb, %rax # imm = 0x9E3779B97F4A7C15
1188baa4:      	imulq	%rax, %r12
1188baa8:      	movq	%r12, %rax
1188baab:      	shrq	$0x22, %rax
1188baaf:      	movq	%rax, -0x80(%rbp)
1188bab3:      	movq	%r12, %rcx
1188bab6:      	shrq	$0x36, %rcx
1188baba:      	movq	%r12, %r13
1188babd:      	shrq	$0x3c, %r13
1188bac1:      	leaq	0x54e8bd8(%rip), %rax   # 0x16d746a0 <_RNvNtNtCscI5nJwKNRh4_13perry_runtime13native_handle9canonical28CANONICAL_HANDLE_ADDR_FILTER.llvm.4573768808118376784>
1188bac8:      	movq	(%rax,%r13,8), %rax
1188bacc:      	movl	$0x1, %edx
1188bad1:      	shlq	%cl, %rdx
1188bad4:      	movq	%rdx, -0x70(%rbp)
1188bad8:      	btq	%rcx, %rax
1188badc:      	jae	0x1188bb80 <js_object_get_field_by_name+0xd60>
1188bae2:      	movq	%r12, %rax
1188bae5:      	shrq	$0x2c, %rax
1188bae9:      	movq	%r12, %rcx
1188baec:      	shrq	$0x32, %rcx
1188baf0:      	andl	$0xf, %ecx
1188baf3:      	leaq	0x54e8ba6(%rip), %rdx   # 0x16d746a0 <_RNvNtNtCscI5nJwKNRh4_13perry_runtime13native_handle9canonical28CANONICAL_HANDLE_ADDR_FILTER.llvm.4573768808118376784>
1188bafa:      	movq	(%rdx,%rcx,8), %rcx
1188bafe:      	btq	%rax, %rcx
1188bb02:      	jae	0x1188bb80 <js_object_get_field_by_name+0xd60>
1188bb04:      	movq	%r12, %rax
1188bb07:      	shrq	$0x28, %rax
1188bb0b:      	andl	$0xf, %eax
1188bb0e:      	leaq	0x54e8b8b(%rip), %rcx   # 0x16d746a0 <_RNvNtNtCscI5nJwKNRh4_13perry_runtime13native_handle9canonical28CANONICAL_HANDLE_ADDR_FILTER.llvm.4573768808118376784>
1188bb15:      	movq	(%rcx,%rax,8), %rax
1188bb19:      	movq	-0x80(%rbp), %rcx
1188bb1d:      	shrq	%cl, %rax
1188bb20:      	testq	%r14, %r14
1188bb23:      	je	0x1188bb80 <js_object_get_field_by_name+0xd60>
1188bb25:      	testb	$0x1, %al
1188bb27:      	je	0x1188bb80 <js_object_get_field_by_name+0xd60>
1188bb29:      	movabsq	$-0x800000000000, %rcx  # imm = 0xFFFF800000000000
1188bb33:      	leaq	(%r14,%rcx), %rax
1188bb37:      	addq	$0x1000, %rcx           # imm = 0x1000
1188bb3e:      	cmpq	%rcx, %rax
1188bb41:      	jb	0x1188bb80 <js_object_get_field_by_name+0xd60>
1188bb43:      	leaq	-0x8(%r14), %rbx
1188bb47:      	movq	%rbx, %rdi
1188bb4a:      	callq	*0x3a904a0(%rip)        # 0x1531bff0 <_GLOBAL_OFFSET_TABLE_+0x4f70>
1188bb50:      	testb	%al, %al
1188bb52:      	je	0x1188bb80 <js_object_get_field_by_name+0xd60>
1188bb54:      	cmpb	$0xf, (%rbx)
1188bb57:      	jne	0x1188bb80 <js_object_get_field_by_name+0xd60>
1188bb59:      	movabsq	$0x5045525259484e44, %rax # imm = 0x5045525259484E44
1188bb63:      	cmpq	%rax, (%r14)
1188bb66:      	jne	0x1188bb80 <js_object_get_field_by_name+0xd60>
1188bb68:      	testb	$0x1, 0x1c(%r14)
1188bb6d:      	je	0x1188bb80 <js_object_get_field_by_name+0xd60>
1188bb6f:      	cmpb	$0x0, 0x1b(%r14)
1188bb74:      	je	0x1188bf60 <js_object_get_field_by_name+0x1140>
1188bb7a:      	nopw	(%rax,%rax)
1188bb80:      	movq	%r14, %rax
1188bb83:      	movabsq	$0xffffffffffff, %rcx   # imm = 0xFFFFFFFFFFFF
1188bb8d:      	andq	%rcx, %rax
1188bb90:      	cmpq	$0x100000, %rax         # imm = 0x100000
1188bb96:      	jb	0x1188bf60 <js_object_get_field_by_name+0x1140>
1188bb9c:      	movabsq	$0x800000000000, %rcx   # imm = 0x800000000000
1188bba6:      	cmpq	%rcx, %rax
1188bba9:      	jae	0x1188bf60 <js_object_get_field_by_name+0x1140>
1188bbaf:      	cmpb	$0x2, -0x8(%rax)
1188bbb3:      	jne	0x1188bf60 <js_object_get_field_by_name+0x1140>
1188bbb9:      	movl	(%rax), %edx
1188bbbb:      	leal	0xffd9(%rdx), %eax
1188bbc1:      	cmpl	$0x4, %eax
1188bbc4:      	jae	0x1188bbeb <js_object_get_field_by_name+0xdcb>
1188bbc6:      	cmpl	$0xffff0028, %edx       # imm = 0xFFFF0028
1188bbcc:      	ja	0x1188bf60 <js_object_get_field_by_name+0x1140>
1188bbd2:      	movq	-0x30(%rbp), %rax
1188bbd6:      	movl	0x4(%rax), %r15d
1188bbda:      	cmpl	$0xffff0027, %edx       # imm = 0xFFFF0027
1188bbe0:      	je	0x1188bcdb <js_object_get_field_by_name+0xebb>
1188bbe6:      	jmp	0x1188bd4d <js_object_get_field_by_name+0xf2d>
1188bbeb:      	movl	$0x40, %ebx
1188bbf0:      	movl	%edx, %edi
1188bbf2:      	callq	0x115528f0 <_RNvNtNtCscI5nJwKNRh4_13perry_runtime6object19class_meta_registry19get_parent_class_id.llvm.4573768808118376784>
1188bbf7:      	cmpl	$0x1, %eax
1188bbfa:      	jne	0x1188bf60 <js_object_get_field_by_name+0x1140>
1188bc00:      	cmpl	$0xffff002c, %edx       # imm = 0xFFFF002C
1188bc06:      	je	0x1188bcd3 <js_object_get_field_by_name+0xeb3>
1188bc0c:      	cmpl	$0xffff002d, %edx       # imm = 0xFFFF002D
1188bc12:      	je	0x1188bd45 <js_object_get_field_by_name+0xf25>
1188bc18:      	decl	%ebx
1188bc1a:      	jne	0x1188bbf0 <js_object_get_field_by_name+0xdd0>
1188bc1c:      	jmp	0x1188bf60 <js_object_get_field_by_name+0x1140>
1188bc21:      	movl	(%r13), %eax
1188bc25:      	cmpl	$-0x2, %eax
1188bc28:      	je	0x1188b620 <js_object_get_field_by_name+0x800>
1188bc2e:      	testl	%eax, %eax
1188bc30:      	je	0x1188b620 <js_object_get_field_by_name+0x800>
1188bc36:      	movq	%r13, %rdi
1188bc39:      	callq	0x1129fdd0 <_RNvNtCscI5nJwKNRh4_13perry_runtime6object17object_keys_array>
1188bc3e:      	movq	%rax, %r15
1188bc41:      	movabsq	$0xffffffffffff, %rax   # imm = 0xFFFFFFFFFFFF
1188bc4b:      	incq	%rax
1188bc4e:      	cmpq	%rax, %r15
1188bc51:      	setae	%al
1188bc54:      	cmpq	$0x100000, %r15         # imm = 0x100000
1188bc5b:      	setb	%cl
1188bc5e:      	orb	%al, %cl
1188bc60:      	jne	0x1188b620 <js_object_get_field_by_name+0x800>
1188bc66:      	movq	%r15, %rdi
1188bc69:      	callq	*0x3a97241(%rip)        # 0x15322eb0 <_GLOBAL_OFFSET_TABLE_+0xbe30>
1188bc6f:      	testb	%al, %al
1188bc71:      	jne	0x1188b620 <js_object_get_field_by_name+0x800>
1188bc77:      	movq	%r13, %rdi
1188bc7a:      	callq	0x115168e0 <_RNvNtNtCscI5nJwKNRh4_13perry_runtime6object10live_slots22object_live_slot_count>
1188bc7f:      	movl	%eax, -0x40(%rbp)
1188bc82:      	movq	%r15, %rdi
1188bc85:      	movq	-0x30(%rbp), %rsi
1188bc89:      	callq	0x115792a0 <_RNvNtNtCscI5nJwKNRh4_13perry_runtime6object9prop_plan16read_plan_lookup>
1188bc8e:      	cmpl	$0x1, %eax
1188bc91:      	je	0x1188e816 <js_object_get_field_by_name+0x39f6>
1188bc97:      	cmpb	$0x1, -0x8(%r15)
1188bc9c:      	jne	0x1188b620 <js_object_get_field_by_name+0x800>
1188bca2:      	movq	%r15, %rdi
1188bca5:      	callq	*0x3a9ea7d(%rip)        # 0x1532a728 <_GLOBAL_OFFSET_TABLE_+0x136a8>
1188bcab:      	cmpq	$0x1000, %rax           # imm = 0x1000
1188bcb1:      	ja	0x1188b620 <js_object_get_field_by_name+0x800>
1188bcb7:      	movq	%r15, %rdi
1188bcba:      	movl	%eax, %esi
1188bcbc:      	movq	-0x30(%rbp), %rdx
1188bcc0:      	callq	0x1151d2c0 <_RNvNtNtCscI5nJwKNRh4_13perry_runtime6object11keys_lookup25keys_find_slot_by_key_ptr>
1188bcc5:      	cmpl	$0x1, %eax
1188bcc8:      	jne	0x1188b620 <js_object_get_field_by_name+0x800>
1188bcce:      	jmp	0x1188e9dd <js_object_get_field_by_name+0x3bbd>
1188bcd3:      	movq	-0x30(%rbp), %rax
1188bcd7:      	movl	0x4(%rax), %r15d
1188bcdb:      	cmpl	$0x3, %r15d
1188bcdf:      	je	0x1188bdc6 <js_object_get_field_by_name+0xfa6>
1188bce5:      	cmpl	$0x6, %r15d
1188bce9:      	jne	0x1188bf60 <js_object_get_field_by_name+0x1140>
1188bcef:      	movq	-0x30(%rbp), %rax
1188bcf3:      	addq	$0x14, %rax
1188bcf7:      	cmpb	$0x64, (%rax)
1188bcfa:      	jne	0x1188bf60 <js_object_get_field_by_name+0x1140>
1188bd00:      	movq	-0x30(%rbp), %rax
1188bd04:      	cmpb	$0x65, 0x15(%rax)
1188bd08:      	jne	0x1188bf60 <js_object_get_field_by_name+0x1140>
1188bd0e:      	movq	-0x30(%rbp), %rax
1188bd12:      	cmpb	$0x6c, 0x16(%rax)
1188bd16:      	jne	0x1188bf60 <js_object_get_field_by_name+0x1140>
1188bd1c:      	movq	-0x30(%rbp), %rax
1188bd20:      	cmpb	$0x65, 0x17(%rax)
1188bd24:      	jne	0x1188bf60 <js_object_get_field_by_name+0x1140>
1188bd2a:      	movq	-0x30(%rbp), %rax
1188bd2e:      	cmpb	$0x74, 0x18(%rax)
1188bd32:      	jne	0x1188bf60 <js_object_get_field_by_name+0x1140>
1188bd38:      	movq	-0x30(%rbp), %rax
1188bd3c:      	cmpb	$0x65, 0x19(%rax)
1188bd40:      	jmp	0x1188bf02 <js_object_get_field_by_name+0x10e2>
1188bd45:      	movq	-0x30(%rbp), %rax
1188bd49:      	movl	0x4(%rax), %r15d
1188bd4d:      	cmpl	$0x3, %r15d
1188bd51:      	je	0x1188be03 <js_object_get_field_by_name+0xfe3>
1188bd57:      	cmpl	$0x6, %r15d
1188bd5b:      	jne	0x1188bf60 <js_object_get_field_by_name+0x1140>
1188bd61:      	movq	-0x30(%rbp), %rax
1188bd65:      	addq	$0x14, %rax
1188bd69:      	cmpb	$0x64, (%rax)
1188bd6c:      	jne	0x1188bf60 <js_object_get_field_by_name+0x1140>
1188bd72:      	movq	-0x30(%rbp), %rax
1188bd76:      	cmpb	$0x65, 0x15(%rax)
1188bd7a:      	jne	0x1188bf60 <js_object_get_field_by_name+0x1140>
1188bd80:      	movq	-0x30(%rbp), %rax
1188bd84:      	cmpb	$0x6c, 0x16(%rax)
1188bd88:      	jne	0x1188bf60 <js_object_get_field_by_name+0x1140>
1188bd8e:      	movq	-0x30(%rbp), %rax
1188bd92:      	cmpb	$0x65, 0x17(%rax)
1188bd96:      	jne	0x1188bf60 <js_object_get_field_by_name+0x1140>
1188bd9c:      	movq	-0x30(%rbp), %rax
1188bda0:      	cmpb	$0x74, 0x18(%rax)
1188bda4:      	jne	0x1188bf60 <js_object_get_field_by_name+0x1140>
1188bdaa:      	movq	-0x30(%rbp), %rax
1188bdae:      	cmpb	$0x65, 0x19(%rax)
1188bdb2:      	jmp	0x1188bee5 <js_object_get_field_by_name+0x10c5>
1188bdb7:      	leaq	0x8(%rbx), %rdi
1188bdbb:      	callq	*0x3a9095f(%rip)        # 0x1531c720 <_GLOBAL_OFFSET_TABLE_+0x56a0>
1188bdc1:      	jmp	0x1188b851 <js_object_get_field_by_name+0xa31>
1188bdc6:      	movq	-0x30(%rbp), %rax
1188bdca:      	addq	$0x14, %rax
1188bdce:      	movzbl	(%rax), %eax
1188bdd1:      	cmpl	$0x67, %eax
1188bdd4:      	je	0x1188bde8 <js_object_get_field_by_name+0xfc8>
1188bdd6:      	cmpl	$0x68, %eax
1188bdd9:      	je	0x1188bef0 <js_object_get_field_by_name+0x10d0>
1188bddf:      	cmpl	$0x73, %eax
1188bde2:      	jne	0x1188bf60 <js_object_get_field_by_name+0x1140>
1188bde8:      	movq	-0x30(%rbp), %rax
1188bdec:      	cmpb	$0x65, 0x15(%rax)
1188bdf0:      	jne	0x1188bf60 <js_object_get_field_by_name+0x1140>
1188bdf6:      	movq	-0x30(%rbp), %rax
1188bdfa:      	cmpb	$0x74, 0x16(%rax)
1188bdfe:      	jmp	0x1188bf02 <js_object_get_field_by_name+0x10e2>
1188be03:      	movq	-0x30(%rbp), %rax
1188be07:      	addq	$0x14, %rax
1188be0b:      	movzbl	(%rax), %eax
1188be0e:      	cmpl	$0x68, %eax
1188be11:      	je	0x1188becf <js_object_get_field_by_name+0x10af>
1188be17:      	cmpl	$0x61, %eax
1188be1a:      	jne	0x1188bf60 <js_object_get_field_by_name+0x1140>
1188be20:      	movq	-0x30(%rbp), %rax
1188be24:      	cmpb	$0x64, 0x15(%rax)
1188be28:      	jne	0x1188bf60 <js_object_get_field_by_name+0x1140>
1188be2e:      	movq	-0x30(%rbp), %rax
1188be32:      	cmpb	$0x64, 0x16(%rax)
1188be36:      	jmp	0x1188bee5 <js_object_get_field_by_name+0x10c5>
1188be3b:      	leaq	-0x58(%rbp), %rdi
1188be3f:      	leaq	0x14(%r12), %rsi
1188be44:      	callq	*0x3a91a26(%rip)        # 0x1531d870 <_GLOBAL_OFFSET_TABLE_+0x67f0>
1188be4a:      	cmpb	$0x0, -0x58(%rbp)
1188be4e:      	jne	0x1188b039 <js_object_get_field_by_name+0x219>
1188be54:      	movq	-0x50(%rbp), %rdi
1188be58:      	movq	-0x48(%rbp), %rdx
1188be5c:      	movq	%rdx, %rsi
1188be5f:      	callq	0x114aa600 <_RNvNtNtCscI5nJwKNRh4_13perry_runtime5array17subclass_elements10key_of_str>
1188be64:      	cmpl	$0x2, %eax
1188be67:      	je	0x1188b039 <js_object_get_field_by_name+0x219>
1188be6d:      	movl	(%r15), %ecx
1188be70:      	cmpl	$0x1, %eax
1188be73:      	je	0x1188e615 <js_object_get_field_by_name+0x37f5>
1188be79:      	cmpl	%ecx, %edx
1188be7b:      	jae	0x1188b039 <js_object_get_field_by_name+0x219>
1188be81:      	movl	%edx, %eax
1188be83:      	movq	0x8(%r15,%rax,8), %r15
1188be88:      	movabsq	$0x7ffc000000000001, %rax # imm = 0x7FFC000000000001
1188be92:      	addq	$0xf, %rax
1188be96:      	cmpq	%rax, %r15
1188be99:      	je	0x1188b039 <js_object_get_field_by_name+0x219>
1188be9f:      	jmp	0x1188e18e <js_object_get_field_by_name+0x336e>
1188bea4:      	cmpq	$0x100000, -0x30(%rbp)  # imm = 0x100000
1188beac:      	jb	0x1188b620 <js_object_get_field_by_name+0x800>
1188beb2:      	cmpq	$0x200000, %r13         # imm = 0x200000
1188beb9:      	jb	0x1188b620 <js_object_get_field_by_name+0x800>
1188bebf:      	cmpb	$0x0, 0x1b(%r13)
1188bec4:      	jne	0x1188b21b <js_object_get_field_by_name+0x3fb>
1188beca:      	jmp	0x1188b620 <js_object_get_field_by_name+0x800>
1188becf:      	movq	-0x30(%rbp), %rax
1188bed3:      	cmpb	$0x61, 0x15(%rax)
1188bed7:      	jne	0x1188bf60 <js_object_get_field_by_name+0x1140>
1188bedd:      	movq	-0x30(%rbp), %rax
1188bee1:      	cmpb	$0x73, 0x16(%rax)
1188bee5:      	leaq	0x2a73c40(%rip), %rbx   # 0x142ffb2c <anon.b37f594bd5826585f7e5082f302a037e.2838.llvm.4573768808118376784+0x64c>
1188beec:      	je	0x1188bf0b <js_object_get_field_by_name+0x10eb>
1188beee:      	jmp	0x1188bf60 <js_object_get_field_by_name+0x1140>
1188bef0:      	movq	-0x30(%rbp), %rax
1188bef4:      	cmpb	$0x61, 0x15(%rax)
1188bef8:      	jne	0x1188bf60 <js_object_get_field_by_name+0x1140>
1188befa:      	movq	-0x30(%rbp), %rax
1188befe:      	cmpb	$0x73, 0x16(%rax)
1188bf02:      	leaq	0x2a73c1c(%rip), %rbx   # 0x142ffb25 <anon.b37f594bd5826585f7e5082f302a037e.2838.llvm.4573768808118376784+0x645>
1188bf09:      	jne	0x1188bf60 <js_object_get_field_by_name+0x1140>
1188bf0b:      	movq	%r14, %rdi
1188bf0e:      	movq	-0x30(%rbp), %rsi
1188bf12:      	callq	0x1167f9a0 <_RNvNtNtNtCscI5nJwKNRh4_13perry_runtime6object10object_ops10keys_array15own_key_present>
1188bf17:      	testb	%al, %al
1188bf19:      	jne	0x1188bf60 <js_object_get_field_by_name+0x1140>
1188bf1b:      	leaq	-0x58(%rbp), %rdi
1188bf1f:      	movq	-0x30(%rbp), %rax
1188bf23:      	leaq	0x14(%rax), %rsi
1188bf27:      	movq	%r15, %rdx
1188bf2a:      	callq	*0x3a91940(%rip)        # 0x1531d870 <_GLOBAL_OFFSET_TABLE_+0x67f0>
1188bf30:      	cmpl	$0x1, -0x58(%rbp)
1188bf34:      	je	0x1188bf60 <js_object_get_field_by_name+0x1140>
1188bf36:      	movq	-0x50(%rbp), %rdx
1188bf3a:      	movq	-0x48(%rbp), %rcx
1188bf3e:      	movl	$0x7, %esi
1188bf43:      	movq	%rbx, %rdi
1188bf46:      	callq	0x11560950 <_RNvNtNtCscI5nJwKNRh4_13perry_runtime6object23collection_proto_thunks29collection_proto_method_value>
1188bf4b:      	cmpq	$0x1, %rax
1188bf4f:      	je	0x1188dbf5 <js_object_get_field_by_name+0x2dd5>
1188bf55:      	nopw	%cs:(%rax,%rax)
1188bf60:      	leaq	0x54e8739(%rip), %rax   # 0x16d746a0 <_RNvNtNtCscI5nJwKNRh4_13perry_runtime13native_handle9canonical28CANONICAL_HANDLE_ADDR_FILTER.llvm.4573768808118376784>
1188bf67:      	movq	(%rax,%r13,8), %rax
1188bf6b:      	testq	%rax, -0x70(%rbp)
1188bf6f:      	je	0x1188c010 <js_object_get_field_by_name+0x11f0>
1188bf75:      	movq	%r12, %rax
1188bf78:      	shrq	$0x2c, %rax
1188bf7c:      	movq	%r12, %rcx
1188bf7f:      	shrq	$0x32, %rcx
1188bf83:      	andl	$0xf, %ecx
1188bf86:      	leaq	0x54e8713(%rip), %rdx   # 0x16d746a0 <_RNvNtNtCscI5nJwKNRh4_13perry_runtime13native_handle9canonical28CANONICAL_HANDLE_ADDR_FILTER.llvm.4573768808118376784>
1188bf8d:      	movq	(%rdx,%rcx,8), %rcx
1188bf91:      	btq	%rax, %rcx
1188bf95:      	jae	0x1188c010 <js_object_get_field_by_name+0x11f0>
1188bf97:      	movq	%r12, %rax
1188bf9a:      	shrq	$0x28, %rax
1188bf9e:      	andl	$0xf, %eax
1188bfa1:      	leaq	0x54e86f8(%rip), %rcx   # 0x16d746a0 <_RNvNtNtCscI5nJwKNRh4_13perry_runtime13native_handle9canonical28CANONICAL_HANDLE_ADDR_FILTER.llvm.4573768808118376784>
1188bfa8:      	movq	(%rcx,%rax,8), %rax
1188bfac:      	movq	-0x80(%rbp), %rcx
1188bfb0:      	shrq	%cl, %rax
1188bfb3:      	testq	%r14, %r14
1188bfb6:      	je	0x1188c010 <js_object_get_field_by_name+0x11f0>
1188bfb8:      	testb	$0x1, %al
1188bfba:      	je	0x1188c010 <js_object_get_field_by_name+0x11f0>
1188bfbc:      	movabsq	$-0x800000000000, %rcx  # imm = 0xFFFF800000000000
1188bfc6:      	leaq	(%r14,%rcx), %rax
1188bfca:      	addq	$0x1000, %rcx           # imm = 0x1000
1188bfd1:      	cmpq	%rcx, %rax
1188bfd4:      	jb	0x1188c010 <js_object_get_field_by_name+0x11f0>
1188bfd6:      	leaq	-0x8(%r14), %rbx
1188bfda:      	movq	%rbx, %rdi
1188bfdd:      	callq	*0x3a9000d(%rip)        # 0x1531bff0 <_GLOBAL_OFFSET_TABLE_+0x4f70>
1188bfe3:      	testb	%al, %al
1188bfe5:      	je	0x1188c010 <js_object_get_field_by_name+0x11f0>
1188bfe7:      	cmpb	$0xf, (%rbx)
1188bfea:      	jne	0x1188c010 <js_object_get_field_by_name+0x11f0>
1188bfec:      	movabsq	$0x5045525259484e44, %rax # imm = 0x5045525259484E44
1188bff6:      	cmpq	%rax, (%r14)
1188bff9:      	jne	0x1188c010 <js_object_get_field_by_name+0x11f0>
1188bffb:      	testb	$0x1, 0x1c(%r14)
1188c000:      	je	0x1188c010 <js_object_get_field_by_name+0x11f0>
1188c002:      	cmpb	$0x0, 0x1b(%r14)
1188c007:      	je	0x1188c120 <js_object_get_field_by_name+0x1300>
1188c00d:      	nopl	(%rax)
1188c010:      	movq	%r14, %rax
1188c013:      	movabsq	$0xffffffffffff, %rcx   # imm = 0xFFFFFFFFFFFF
1188c01d:      	andq	%rcx, %rax
1188c020:      	cmpq	$0x100000, %rax         # imm = 0x100000
1188c026:      	jb	0x1188c120 <js_object_get_field_by_name+0x1300>
1188c02c:      	movabsq	$0x800000000000, %rcx   # imm = 0x800000000000
1188c036:      	cmpq	%rcx, %rax
1188c039:      	jae	0x1188c120 <js_object_get_field_by_name+0x1300>
1188c03f:      	cmpb	$0x2, -0x8(%rax)
1188c043:      	jne	0x1188c120 <js_object_get_field_by_name+0x1300>
1188c049:      	movl	(%rax), %r15d
1188c04c:      	leal	0xffd9(%r15), %eax
1188c053:      	cmpl	$0x4, %eax
1188c056:      	jae	0x1188c0e6 <js_object_get_field_by_name+0x12c6>
1188c05c:      	movq	-0x30(%rbp), %rax
1188c060:      	movl	0x4(%rax), %edx
1188c063:      	leaq	-0x58(%rbp), %rdi
1188c067:      	leaq	0x14(%rax), %rsi
1188c06b:      	callq	*0x3a917ff(%rip)        # 0x1531d870 <_GLOBAL_OFFSET_TABLE_+0x67f0>
1188c071:      	cmpl	$0x1, -0x58(%rbp)
1188c075:      	je	0x1188c120 <js_object_get_field_by_name+0x1300>
1188c07b:      	movq	-0x50(%rbp), %rax
1188c07f:      	movq	%rax, -0x98(%rbp)
1188c086:      	movq	-0x48(%rbp), %rbx
1188c08a:      	movq	%r14, %rdi
1188c08d:      	movq	-0x30(%rbp), %rsi
1188c091:      	callq	0x1167f9a0 <_RNvNtNtNtCscI5nJwKNRh4_13perry_runtime6object10object_ops10keys_array15own_key_present>
1188c096:      	testb	%al, %al
1188c098:      	jne	0x1188c120 <js_object_get_field_by_name+0x1300>
1188c09e:      	cmpl	$0xffff002a, %r15d      # imm = 0xFFFF002A
1188c0a5:      	je	0x1188cb4c <js_object_get_field_by_name+0x1d2c>
1188c0ab:      	cmpl	$0xffff0029, %r15d      # imm = 0xFFFF0029
1188c0b2:      	jne	0x1188c120 <js_object_get_field_by_name+0x1300>
1188c0b4:      	cmpq	$0x5, %rbx
1188c0b8:      	jne	0x1188c120 <js_object_get_field_by_name+0x1300>
1188c0ba:      	movq	-0x98(%rbp), %rdx
1188c0c1:      	movl	(%rdx), %eax
1188c0c3:      	movl	$0x65726564, %ecx       # imm = 0x65726564
1188c0c8:      	xorl	%ecx, %eax
1188c0ca:      	movzbl	0x4(%rdx), %ecx
1188c0ce:      	xorl	$0x66, %ecx
1188c0d1:      	orl	%eax, %ecx
1188c0d3:      	jne	0x1188c120 <js_object_get_field_by_name+0x1300>
1188c0d5:      	movl	$0x7, %esi
1188c0da:      	leaq	0x2ab3274(%rip), %rdi   # 0x1433f355 <anon.b37f594bd5826585f7e5082f302a037e.10935.llvm.4573768808118376784+0x3b4>
1188c0e1:      	jmp	0x1188d0ae <js_object_get_field_by_name+0x228e>
1188c0e6:      	movl	$0x40, %ebx
1188c0eb:      	nopl	(%rax,%rax)
1188c0f0:      	movl	%r15d, %edi
1188c0f3:      	callq	0x115528f0 <_RNvNtNtCscI5nJwKNRh4_13perry_runtime6object19class_meta_registry19get_parent_class_id.llvm.4573768808118376784>
1188c0f8:      	cmpl	$0x1, %eax
1188c0fb:      	jne	0x1188c120 <js_object_get_field_by_name+0x1300>
1188c0fd:      	movl	%edx, %r15d
1188c100:      	cmpl	$0xffff002d, %edx       # imm = 0xFFFF002D
1188c106:      	je	0x1188c94d <js_object_get_field_by_name+0x1b2d>
1188c10c:      	cmpl	$0xffff002c, %r15d      # imm = 0xFFFF002C
1188c113:      	je	0x1188c958 <js_object_get_field_by_name+0x1b38>
1188c119:      	decl	%ebx
1188c11b:      	jne	0x1188c0f0 <js_object_get_field_by_name+0x12d0>
1188c11d:      	nopl	(%rax)
1188c120:      	leaq	0x54e8579(%rip), %rax   # 0x16d746a0 <_RNvNtNtCscI5nJwKNRh4_13perry_runtime13native_handle9canonical28CANONICAL_HANDLE_ADDR_FILTER.llvm.4573768808118376784>
1188c127:      	movq	(%rax,%r13,8), %rax
1188c12b:      	testq	%rax, -0x70(%rbp)
1188c12f:      	je	0x1188c1d0 <js_object_get_field_by_name+0x13b0>
1188c135:      	movq	%r12, %rax
1188c138:      	shrq	$0x2c, %rax
1188c13c:      	movq	%r12, %rcx
1188c13f:      	shrq	$0x32, %rcx
1188c143:      	andl	$0xf, %ecx
1188c146:      	leaq	0x54e8553(%rip), %rdx   # 0x16d746a0 <_RNvNtNtCscI5nJwKNRh4_13perry_runtime13native_handle9canonical28CANONICAL_HANDLE_ADDR_FILTER.llvm.4573768808118376784>
1188c14d:      	movq	(%rdx,%rcx,8), %rcx
1188c151:      	btq	%rax, %rcx
1188c155:      	jae	0x1188c1d0 <js_object_get_field_by_name+0x13b0>
1188c157:      	movq	%r12, %rax
1188c15a:      	shrq	$0x28, %rax
1188c15e:      	andl	$0xf, %eax
1188c161:      	leaq	0x54e8538(%rip), %rcx   # 0x16d746a0 <_RNvNtNtCscI5nJwKNRh4_13perry_runtime13native_handle9canonical28CANONICAL_HANDLE_ADDR_FILTER.llvm.4573768808118376784>
1188c168:      	movq	(%rcx,%rax,8), %rax
1188c16c:      	movq	-0x80(%rbp), %rcx
1188c170:      	shrq	%cl, %rax
1188c173:      	testq	%r14, %r14
1188c176:      	je	0x1188c1d0 <js_object_get_field_by_name+0x13b0>
1188c178:      	testb	$0x1, %al
1188c17a:      	je	0x1188c1d0 <js_object_get_field_by_name+0x13b0>
1188c17c:      	movabsq	$-0x800000000000, %rcx  # imm = 0xFFFF800000000000
1188c186:      	leaq	(%r14,%rcx), %rax
1188c18a:      	addq	$0x1000, %rcx           # imm = 0x1000
1188c191:      	cmpq	%rcx, %rax
1188c194:      	jb	0x1188c1d0 <js_object_get_field_by_name+0x13b0>
1188c196:      	leaq	-0x8(%r14), %rbx
1188c19a:      	movq	%rbx, %rdi
1188c19d:      	callq	*0x3a8fe4d(%rip)        # 0x1531bff0 <_GLOBAL_OFFSET_TABLE_+0x4f70>
1188c1a3:      	testb	%al, %al
1188c1a5:      	je	0x1188c1d0 <js_object_get_field_by_name+0x13b0>
1188c1a7:      	cmpb	$0xf, (%rbx)
1188c1aa:      	jne	0x1188c1d0 <js_object_get_field_by_name+0x13b0>
1188c1ac:      	movabsq	$0x5045525259484e44, %rax # imm = 0x5045525259484E44
1188c1b6:      	cmpq	%rax, (%r14)
1188c1b9:      	jne	0x1188c1d0 <js_object_get_field_by_name+0x13b0>
1188c1bb:      	testb	$0x1, 0x1c(%r14)
1188c1c0:      	je	0x1188c1d0 <js_object_get_field_by_name+0x13b0>
1188c1c2:      	cmpb	$0x0, 0x1b(%r14)
1188c1c7:      	je	0x1188c340 <js_object_get_field_by_name+0x1520>
1188c1cd:      	nopl	(%rax)
1188c1d0:      	movq	-0x30(%rbp), %rax
1188c1d4:      	movl	0x4(%rax), %edx
1188c1d7:      	leaq	-0x58(%rbp), %rdi
1188c1db:      	leaq	0x14(%rax), %rsi
1188c1df:      	callq	*0x3a9168b(%rip)        # 0x1531d870 <_GLOBAL_OFFSET_TABLE_+0x67f0>
1188c1e5:      	cmpb	$0x0, -0x58(%rbp)
1188c1e9:      	movq	-0x50(%rbp), %rbx
1188c1ed:      	movl	$0x1, %eax
1188c1f2:      	cmovneq	%rax, %rbx
1188c1f6:      	movq	-0x48(%rbp), %r15
1188c1fa:      	movl	$0x0, %eax
1188c1ff:      	cmovneq	%rax, %r15
1188c203:      	cmpq	$0x7, %r15
1188c207:      	je	0x1188c241 <js_object_get_field_by_name+0x1421>
1188c209:      	cmpq	$0x5, %r15
1188c20d:      	je	0x1188c227 <js_object_get_field_by_name+0x1407>
1188c20f:      	cmpq	$0x4, %r15
1188c213:      	jne	0x1188c340 <js_object_get_field_by_name+0x1520>
1188c219:      	cmpl	$0x6e656874, (%rbx)     # imm = 0x6E656874
1188c21f:      	jne	0x1188c340 <js_object_get_field_by_name+0x1520>
1188c225:      	jmp	0x1188c25c <js_object_get_field_by_name+0x143c>
1188c227:      	movl	(%rbx), %eax
1188c229:      	movl	$0x63746163, %ecx       # imm = 0x63746163
1188c22e:      	xorl	%ecx, %eax
1188c230:      	movzbl	0x4(%rbx), %ecx
1188c234:      	xorl	$0x68, %ecx
1188c237:      	orl	%eax, %ecx
1188c239:      	jne	0x1188c340 <js_object_get_field_by_name+0x1520>
1188c23f:      	jmp	0x1188c25c <js_object_get_field_by_name+0x143c>
1188c241:      	movl	(%rbx), %eax
1188c243:      	movl	$0x616e6966, %ecx       # imm = 0x616E6966
1188c248:      	xorl	%ecx, %eax
1188c24a:      	movl	0x3(%rbx), %ecx
1188c24d:      	movl	$0x796c6c61, %edx       # imm = 0x796C6C61
1188c252:      	xorl	%edx, %ecx
1188c254:      	orl	%eax, %ecx
1188c256:      	jne	0x1188c340 <js_object_get_field_by_name+0x1520>
1188c25c:      	movq	%r14, %rdi
1188c25f:      	movq	-0x30(%rbp), %rsi
1188c263:      	callq	0x1167f9a0 <_RNvNtNtNtCscI5nJwKNRh4_13perry_runtime6object10object_ops10keys_array15own_key_present>
1188c268:      	testb	%al, %al
1188c26a:      	jne	0x1188c340 <js_object_get_field_by_name+0x1520>
1188c270:      	movzbl	0x55691d1(%rip), %eax   # 0x16df5448 <_RNvNtNtCscI5nJwKNRh4_13perry_runtime7promise8subclass21PROMISE_SUBCLASS_EVER.0>
1188c277:      	testb	%al, %al
1188c279:      	je	0x1188c340 <js_object_get_field_by_name+0x1520>
1188c27f:      	movq	%r14, %rax
1188c282:      	movabsq	$0xffffffffffff, %rcx   # imm = 0xFFFFFFFFFFFF
1188c28c:      	andq	%rcx, %rax
1188c28f:      	movabsq	$0x7ffd000000000000, %rcx # imm = 0x7FFD000000000000
1188c299:      	orq	%rcx, %rax
1188c29c:      	movq	%rax, %xmm0
1188c2a1:      	callq	0x11543720 <_RNvNtNtCscI5nJwKNRh4_13perry_runtime6object16map_set_subclass19instance_object_ptr.llvm.4573768808118376784>
1188c2a6:      	cmpq	$0x1, %rax
1188c2aa:      	jne	0x1188c340 <js_object_get_field_by_name+0x1520>
1188c2b0:      	leaq	0x2ab61f0(%rip), %rdi   # 0x143424a7 <anon.b37f594bd5826585f7e5082f302a037e.11886.llvm.4573768808118376784+0x478>
1188c2b7:      	movl	$0x19, %esi
1188c2bc:      	movq	%rdx, -0x98(%rbp)
1188c2c3:      	movl	$0x19, %edx
1188c2c8:      	callq	*0x3a8ffda(%rip)        # 0x1531c2a8 <_GLOBAL_OFFSET_TABLE_+0x5228>
1188c2ce:      	movq	-0x98(%rbp), %rdi
1188c2d5:      	movq	%rax, %rsi
1188c2d8:      	callq	*0x3aa4c02(%rip)        # 0x15330ee0 <_GLOBAL_OFFSET_TABLE_+0x19e60>
1188c2de:      	movq	%xmm0, %rax
1188c2e3:      	movq	%rax, %rcx
1188c2e6:      	movabsq	$-0x1000000000000, %rdx # imm = 0xFFFF000000000000
1188c2f0:      	andq	%rdx, %rcx
1188c2f3:      	movabsq	$0x7ffd000000000000, %rdx # imm = 0x7FFD000000000000
1188c2fd:      	cmpq	%rdx, %rcx
1188c300:      	jne	0x1188c340 <js_object_get_field_by_name+0x1520>
1188c302:      	movabsq	$0xffffffffffff, %rcx   # imm = 0xFFFFFFFFFFFF
1188c30c:      	addq	$-0x7, %rcx
1188c310:      	andq	%rcx, %rax
1188c313:      	cmpq	$0x1008, %rax           # imm = 0x1008
1188c319:      	jb	0x1188c340 <js_object_get_field_by_name+0x1520>
1188c31b:      	callq	*0x3a93fa7(%rip)        # 0x153202c8 <_GLOBAL_OFFSET_TABLE_+0x9248>
1188c321:      	testl	%eax, %eax
1188c323:      	je	0x1188c340 <js_object_get_field_by_name+0x1520>
1188c325:      	movq	%rbx, %rsi
1188c328:      	movq	%r15, %rdx
1188c32b:      	callq	*0x3a951b7(%rip)        # 0x153214e8 <_GLOBAL_OFFSET_TABLE_+0xa468>
1188c331:      	cmpq	$0x1, %rax
1188c335:      	je	0x1188dbf5 <js_object_get_field_by_name+0x2dd5>
1188c33b:      	nopl	(%rax,%rax)
1188c340:      	leaq	0x54e8359(%rip), %rax   # 0x16d746a0 <_RNvNtNtCscI5nJwKNRh4_13perry_runtime13native_handle9canonical28CANONICAL_HANDLE_ADDR_FILTER.llvm.4573768808118376784>
1188c347:      	movq	(%rax,%r13,8), %rax
1188c34b:      	testq	%rax, -0x70(%rbp)
1188c34f:      	je	0x1188c3f0 <js_object_get_field_by_name+0x15d0>
1188c355:      	movq	%r12, %rax
1188c358:      	shrq	$0x2c, %rax
1188c35c:      	movq	%r12, %rcx
1188c35f:      	shrq	$0x32, %rcx
1188c363:      	andl	$0xf, %ecx
1188c366:      	leaq	0x54e8333(%rip), %rdx   # 0x16d746a0 <_RNvNtNtCscI5nJwKNRh4_13perry_runtime13native_handle9canonical28CANONICAL_HANDLE_ADDR_FILTER.llvm.4573768808118376784>
1188c36d:      	movq	(%rdx,%rcx,8), %rcx
1188c371:      	btq	%rax, %rcx
1188c375:      	jae	0x1188c3f0 <js_object_get_field_by_name+0x15d0>
1188c377:      	shrq	$0x28, %r12
1188c37b:      	andl	$0xf, %r12d
1188c37f:      	leaq	0x54e831a(%rip), %rax   # 0x16d746a0 <_RNvNtNtCscI5nJwKNRh4_13perry_runtime13native_handle9canonical28CANONICAL_HANDLE_ADDR_FILTER.llvm.4573768808118376784>
1188c386:      	movq	(%rax,%r12,8), %rax
1188c38a:      	movq	-0x80(%rbp), %rcx
1188c38e:      	shrq	%cl, %rax
1188c391:      	testq	%r14, %r14
1188c394:      	je	0x1188c3f0 <js_object_get_field_by_name+0x15d0>
1188c396:      	testb	$0x1, %al
1188c398:      	je	0x1188c3f0 <js_object_get_field_by_name+0x15d0>
1188c39a:      	movabsq	$-0x800000000000, %rcx  # imm = 0xFFFF800000000000
1188c3a4:      	leaq	(%r14,%rcx), %rax
1188c3a8:      	addq	$0x1000, %rcx           # imm = 0x1000
1188c3af:      	cmpq	%rcx, %rax
1188c3b2:      	jb	0x1188c3f0 <js_object_get_field_by_name+0x15d0>
1188c3b4:      	leaq	-0x8(%r14), %rbx
1188c3b8:      	movq	%rbx, %rdi
1188c3bb:      	callq	*0x3a8fc2f(%rip)        # 0x1531bff0 <_GLOBAL_OFFSET_TABLE_+0x4f70>
1188c3c1:      	testb	%al, %al
1188c3c3:      	je	0x1188c3f0 <js_object_get_field_by_name+0x15d0>
1188c3c5:      	cmpb	$0xf, (%rbx)
1188c3c8:      	jne	0x1188c3f0 <js_object_get_field_by_name+0x15d0>
1188c3ca:      	movabsq	$0x5045525259484e44, %rax # imm = 0x5045525259484E44
1188c3d4:      	cmpq	%rax, (%r14)
1188c3d7:      	jne	0x1188c3f0 <js_object_get_field_by_name+0x15d0>
1188c3d9:      	testb	$0x1, 0x1c(%r14)
1188c3de:      	je	0x1188c3f0 <js_object_get_field_by_name+0x15d0>
1188c3e0:      	cmpb	$0x0, 0x1b(%r14)
1188c3e5:      	je	0x1188c401 <js_object_get_field_by_name+0x15e1>
1188c3e7:      	nopw	(%rax,%rax)
1188c3f0:      	movq	%r14, %rdi
1188c3f3:      	callq	*0x3a8f5bf(%rip)        # 0x1531b9b8 <_GLOBAL_OFFSET_TABLE_+0x4938>
1188c3f9:      	testb	%al, %al
1188c3fb:      	jne	0x1188da6f <js_object_get_field_by_name+0x2c4f>
1188c401:      	movq	%r14, %xmm0
1188c406:      	movdqa	%xmm0, -0x70(%rbp)
1188c40b:      	callq	0x1122d8d0 <_RNvNtCscI5nJwKNRh4_13perry_runtime16typedarray_props27typed_array_addr_from_value>
1188c410:      	testb	$0x1, %al
1188c412:      	movq	-0x30(%rbp), %r12
1188c416:      	je	0x1188ccdb <js_object_get_field_by_name+0x1ebb>
1188c41c:      	movq	%rdx, %r13
1188c41f:      	movl	0x4(%r12), %ebx
1188c424:      	movq	%rdx, %rdi
1188c427:      	leaq	0x14(%r12), %rsi
1188c42c:      	movq	%rbx, %rdx
1188c42f:      	callq	0x116a69c0 <_RNvNtNtNtCscI5nJwKNRh4_13perry_runtime6object13field_get_set10crypto_key25crypto_key_property_value>
1188c434:      	testb	$0x1, %al
1188c436:      	jne	0x1188da0b <js_object_get_field_by_name+0x2beb>
1188c43c:      	cmpq	$0x10000, %r12          # imm = 0x10000
1188c443:      	jb	0x1188c540 <js_object_get_field_by_name+0x1720>
1188c449:      	testq	%r13, %r13
1188c44c:      	je	0x1188c540 <js_object_get_field_by_name+0x1720>
1188c452:      	movl	0x4(%r12), %r15d
1188c457:      	cmpl	%r15d, (%r12)
1188c45b:      	jne	0x1188c472 <js_object_get_field_by_name+0x1652>
1188c45d:      	leaq	0x14(%r12), %rdx
1188c462:      	leaq	0x54e7af7(%rip), %rax   # 0x16d73f60 <_RNvNtCscI5nJwKNRh4_13perry_runtime10typedarray27TYPED_ARRAY_EVER_REGISTERED>
1188c469:      	movzbl	(%rax), %eax
1188c46c:      	testb	%al, %al
1188c46e:      	jne	0x1188c4a4 <js_object_get_field_by_name+0x1684>
1188c470:      	jmp	0x1188c4dc <js_object_get_field_by_name+0x16bc>
1188c472:      	leaq	-0x58(%rbp), %rdi
1188c476:      	leaq	0x14(%r12), %rsi
1188c47b:      	movq	%r15, %rdx
1188c47e:      	callq	*0x3a913ec(%rip)        # 0x1531d870 <_GLOBAL_OFFSET_TABLE_+0x67f0>
1188c484:      	cmpb	$0x0, -0x58(%rbp)
1188c488:      	jne	0x1188c540 <js_object_get_field_by_name+0x1720>
1188c48e:      	movq	-0x50(%rbp), %rdx
1188c492:      	movq	-0x48(%rbp), %r15
1188c496:      	leaq	0x54e7ac3(%rip), %rax   # 0x16d73f60 <_RNvNtCscI5nJwKNRh4_13perry_runtime10typedarray27TYPED_ARRAY_EVER_REGISTERED>
1188c49d:      	movzbl	(%rax), %eax
1188c4a0:      	testb	%al, %al
1188c4a2:      	je	0x1188c4dc <js_object_get_field_by_name+0x16bc>
1188c4a4:      	leaq	0x3ac2b1d(%rip), %rax   # 0x1534efc8 <_RNvNtCscI5nJwKNRh4_13perry_runtime10typedarray23TYPED_ARRAY_ADDR_WINDOW>
1188c4ab:      	movq	(%rax), %rax
1188c4ae:      	cmpq	%rax, %r13
1188c4b1:      	jb	0x1188c4dc <js_object_get_field_by_name+0x16bc>
1188c4b3:      	leaq	0x3ac2b0e(%rip), %rax   # 0x1534efc8 <_RNvNtCscI5nJwKNRh4_13perry_runtime10typedarray23TYPED_ARRAY_ADDR_WINDOW>
1188c4ba:      	movq	0x8(%rax), %rax
1188c4be:      	cmpq	%rax, %r13
1188c4c1:      	ja	0x1188c4dc <js_object_get_field_by_name+0x16bc>
1188c4c3:      	movq	%r13, %rdi
1188c4c6:      	movq	%rdx, -0x80(%rbp)
1188c4ca:      	callq	*0x3aa2780(%rip)        # 0x1532ec50 <_GLOBAL_OFFSET_TABLE_+0x17bd0>
1188c4d0:      	movq	-0x80(%rbp), %rdx
1188c4d4:      	testb	$0x1, %al
1188c4d6:      	je	0x1188c4dc <js_object_get_field_by_name+0x16bc>
1188c4d8:      	xorl	%ecx, %ecx
1188c4da:      	jmp	0x1188c520 <js_object_get_field_by_name+0x1700>
1188c4dc:      	leaq	0x55687b8(%rip), %rax   # 0x16df4c9b <_RNvNtNtCscI5nJwKNRh4_13perry_runtime6buffer6header22UINT8ARRAY_EVER_MARKED>
1188c4e3:      	movzbl	(%rax), %eax
1188c4e6:      	testb	%al, %al
1188c4e8:      	je	0x1188c540 <js_object_get_field_by_name+0x1720>
1188c4ea:      	leaq	0x3ac35df(%rip), %rax   # 0x1534fad0 <_RNvNtNtCscI5nJwKNRh4_13perry_runtime6buffer6header22UINT8ARRAY_ADDR_WINDOW>
1188c4f1:      	movq	(%rax), %rax
1188c4f4:      	cmpq	%rax, %r13
1188c4f7:      	jb	0x1188c540 <js_object_get_field_by_name+0x1720>
1188c4f9:      	leaq	0x3ac35d0(%rip), %rax   # 0x1534fad0 <_RNvNtNtCscI5nJwKNRh4_13perry_runtime6buffer6header22UINT8ARRAY_ADDR_WINDOW>
1188c500:      	movq	0x8(%rax), %rax
1188c504:      	cmpq	%rax, %r13
1188c507:      	ja	0x1188c540 <js_object_get_field_by_name+0x1720>
1188c509:      	movq	%r13, %rdi
1188c50c:      	movq	%rdx, -0x80(%rbp)
1188c510:      	callq	*0x3a9515a(%rip)        # 0x15321670 <_GLOBAL_OFFSET_TABLE_+0xa5f0>
1188c516:      	movq	-0x80(%rbp), %rdx
1188c51a:      	movb	$0x1, %cl
1188c51c:      	testb	%al, %al
1188c51e:      	je	0x1188c540 <js_object_get_field_by_name+0x1720>
1188c520:      	movzbl	%cl, %esi
1188c523:      	movq	%r13, %rdi
1188c526:      	movq	%r15, %rcx
1188c529:      	callq	0x11232130 <_RNvNtCscI5nJwKNRh4_13perry_runtime16typedarray_props42typed_array_get_property_value_by_name_for>
1188c52e:      	cmpq	$0x1, %rax
1188c532:      	je	0x1188dbf5 <js_object_get_field_by_name+0x2dd5>
1188c538:      	nopl	(%rax,%rax)
1188c540:      	leaq	0x54e7a19(%rip), %rax   # 0x16d73f60 <_RNvNtCscI5nJwKNRh4_13perry_runtime10typedarray27TYPED_ARRAY_EVER_REGISTERED>
1188c547:      	movzbl	(%rax), %eax
1188c54a:      	testb	%al, %al
1188c54c:      	je	0x1188c620 <js_object_get_field_by_name+0x1800>
1188c552:      	leaq	0x3ac2a6f(%rip), %rax   # 0x1534efc8 <_RNvNtCscI5nJwKNRh4_13perry_runtime10typedarray23TYPED_ARRAY_ADDR_WINDOW>
1188c559:      	movq	(%rax), %rax
1188c55c:      	cmpq	%rax, %r13
1188c55f:      	jb	0x1188c620 <js_object_get_field_by_name+0x1800>
1188c565:      	leaq	0x3ac2a5c(%rip), %rax   # 0x1534efc8 <_RNvNtCscI5nJwKNRh4_13perry_runtime10typedarray23TYPED_ARRAY_ADDR_WINDOW>
1188c56c:      	movq	0x8(%rax), %rax
1188c570:      	cmpq	%rax, %r13
1188c573:      	ja	0x1188c620 <js_object_get_field_by_name+0x1800>
1188c579:      	movq	%r13, %rdi
1188c57c:      	callq	*0x3aa26ce(%rip)        # 0x1532ec50 <_GLOBAL_OFFSET_TABLE_+0x17bd0>
1188c582:      	testb	$0x1, %al
1188c584:      	je	0x1188c620 <js_object_get_field_by_name+0x1800>
1188c58a:      	movl	$0x8, %r15d
1188c590:      	cmpb	$0xb, %dl
1188c593:      	ja	0x1188c5a4 <js_object_get_field_by_name+0x1784>
1188c595:      	movzbl	%dl, %eax
1188c598:      	leaq	0x2ac7769(%rip), %rcx   # 0x14353d08 <anon.b37f594bd5826585f7e5082f302a037e.16456.llvm.4573768808118376784+0x833>
1188c59f:      	movzbl	(%rax,%rcx), %r15d
1188c5a4:      	movb	%dl, -0x80(%rbp)
1188c5a7:      	addl	$-0x6, %ebx
1188c5aa:      	cmpl	$0xb, %ebx
1188c5ad:      	ja	0x1188d1f1 <js_object_get_field_by_name+0x23d1>
1188c5b3:      	leaq	0x2a6f266(%rip), %rcx   # 0x142fb820 <anon.b37f594bd5826585f7e5082f302a037e.11885.llvm.4573768808118376784+0x10204>
1188c5ba:      	movslq	(%rcx,%rbx,4), %rax
1188c5be:      	addq	%rcx, %rax
1188c5c1:      	jmpq	*%rax
1188c5c3:      	leaq	0x14(%r12), %rax
1188c5c8:      	movzbl	(%rax), %eax
1188c5cb:      	cmpl	$0x62, %eax
1188c5ce:      	je	0x1188cb90 <js_object_get_field_by_name+0x1d70>
1188c5d4:      	cmpl	$0x6c, %eax
1188c5d7:      	jne	0x1188d1f1 <js_object_get_field_by_name+0x23d1>
1188c5dd:      	cmpb	$0x65, 0x15(%r12)
1188c5e3:      	jne	0x1188d1f1 <js_object_get_field_by_name+0x23d1>
1188c5e9:      	cmpb	$0x6e, 0x16(%r12)
1188c5ef:      	jne	0x1188d1f1 <js_object_get_field_by_name+0x23d1>
1188c5f5:      	cmpb	$0x67, 0x17(%r12)
1188c5fb:      	jne	0x1188d1f1 <js_object_get_field_by_name+0x23d1>
1188c601:      	cmpb	$0x74, 0x18(%r12)
1188c607:      	jne	0x1188d1f1 <js_object_get_field_by_name+0x23d1>
1188c60d:      	cmpb	$0x68, 0x19(%r12)
1188c613:      	jne	0x1188d1f1 <js_object_get_field_by_name+0x23d1>
1188c619:      	jmp	0x1188ea2d <js_object_get_field_by_name+0x3c0d>
1188c61e:      	nop
1188c620:      	addl	$-0x6, %ebx
1188c623:      	cmpl	$0xb, %ebx
1188c626:      	ja	0x1188cc00 <js_object_get_field_by_name+0x1de0>
1188c62c:      	leaq	0x2a6f21d(%rip), %rcx   # 0x142fb850 <anon.b37f594bd5826585f7e5082f302a037e.11885.llvm.4573768808118376784+0x10234>
1188c633:      	movslq	(%rcx,%rbx,4), %rax
1188c637:      	addq	%rcx, %rax
1188c63a:      	jmpq	*%rax
1188c63c:      	leaq	0x14(%r12), %rax
1188c641:      	movzbl	(%rax), %eax
1188c644:      	addl	$-0x62, %eax
1188c647:      	cmpl	$0xe, %eax
1188c64a:      	ja	0x1188cc00 <js_object_get_field_by_name+0x1de0>
1188c650:      	leaq	0x2a6f229(%rip), %rcx   # 0x142fb880 <anon.b37f594bd5826585f7e5082f302a037e.11885.llvm.4573768808118376784+0x10264>
1188c657:      	movslq	(%rcx,%rax,4), %rax
1188c65b:      	addq	%rcx, %rax
1188c65e:      	jmpq	*%rax
1188c660:      	cmpb	$0x75, 0x15(%r12)
1188c666:      	jne	0x1188cc00 <js_object_get_field_by_name+0x1de0>
1188c66c:      	cmpb	$0x66, 0x16(%r12)
1188c672:      	jne	0x1188cc00 <js_object_get_field_by_name+0x1de0>
1188c678:      	cmpb	$0x66, 0x17(%r12)
1188c67e:      	jne	0x1188cc00 <js_object_get_field_by_name+0x1de0>
1188c684:      	cmpb	$0x65, 0x18(%r12)
1188c68a:      	jne	0x1188cc00 <js_object_get_field_by_name+0x1de0>
1188c690:      	cmpb	$0x72, 0x19(%r12)
1188c696:      	jne	0x1188cc00 <js_object_get_field_by_name+0x1de0>
1188c69c:      	jmp	0x1188e624 <js_object_get_field_by_name+0x3804>
1188c6a1:      	leaq	0x14(%r12), %rax
1188c6a6:      	cmpb	$0x63, (%rax)
1188c6a9:      	jne	0x1188cc00 <js_object_get_field_by_name+0x1de0>
1188c6af:      	cmpb	$0x6f, 0x15(%r12)
1188c6b5:      	jne	0x1188cc00 <js_object_get_field_by_name+0x1de0>
1188c6bb:      	cmpb	$0x6e, 0x16(%r12)
1188c6c1:      	jne	0x1188cc00 <js_object_get_field_by_name+0x1de0>
1188c6c7:      	cmpb	$0x73, 0x17(%r12)
1188c6cd:      	jne	0x1188cc00 <js_object_get_field_by_name+0x1de0>
1188c6d3:      	cmpb	$0x74, 0x18(%r12)
1188c6d9:      	jne	0x1188cc00 <js_object_get_field_by_name+0x1de0>
1188c6df:      	cmpb	$0x72, 0x19(%r12)
1188c6e5:      	jne	0x1188cc00 <js_object_get_field_by_name+0x1de0>
1188c6eb:      	cmpb	$0x75, 0x1a(%r12)
1188c6f1:      	jne	0x1188cc00 <js_object_get_field_by_name+0x1de0>
1188c6f7:      	cmpb	$0x63, 0x1b(%r12)
1188c6fd:      	jne	0x1188cc00 <js_object_get_field_by_name+0x1de0>
1188c703:      	cmpb	$0x74, 0x1c(%r12)
1188c709:      	jne	0x1188cc00 <js_object_get_field_by_name+0x1de0>
1188c70f:      	cmpb	$0x6f, 0x1d(%r12)
1188c715:      	jne	0x1188cc00 <js_object_get_field_by_name+0x1de0>
1188c71b:      	cmpb	$0x72, 0x1e(%r12)
1188c721:      	jne	0x1188cc00 <js_object_get_field_by_name+0x1de0>
1188c727:      	jmp	0x1188ea8e <js_object_get_field_by_name+0x3c6e>
1188c72c:      	leaq	0x14(%r12), %rax
1188c731:      	cmpb	$0x62, (%rax)
1188c734:      	jne	0x1188cc00 <js_object_get_field_by_name+0x1de0>
1188c73a:      	cmpb	$0x79, 0x15(%r12)
1188c740:      	jne	0x1188cc00 <js_object_get_field_by_name+0x1de0>
1188c746:      	cmpb	$0x74, 0x16(%r12)
1188c74c:      	jne	0x1188cc00 <js_object_get_field_by_name+0x1de0>
1188c752:      	cmpb	$0x65, 0x17(%r12)
1188c758:      	jne	0x1188cc00 <js_object_get_field_by_name+0x1de0>
1188c75e:      	movzbl	0x18(%r12), %eax
1188c764:      	cmpl	$0x4f, %eax
1188c767:      	je	0x1188cbd1 <js_object_get_field_by_name+0x1db1>
1188c76d:      	cmpl	$0x4c, %eax
1188c770:      	jne	0x1188cc00 <js_object_get_field_by_name+0x1de0>
1188c776:      	cmpb	$0x65, 0x19(%r12)
1188c77c:      	jne	0x1188cc00 <js_object_get_field_by_name+0x1de0>
1188c782:      	cmpb	$0x6e, 0x1a(%r12)
1188c788:      	jne	0x1188cc00 <js_object_get_field_by_name+0x1de0>
1188c78e:      	cmpb	$0x67, 0x1b(%r12)
1188c794:      	jne	0x1188cc00 <js_object_get_field_by_name+0x1de0>
1188c79a:      	cmpb	$0x74, 0x1c(%r12)
1188c7a0:      	jne	0x1188cc00 <js_object_get_field_by_name+0x1de0>
1188c7a6:      	cmpb	$0x68, 0x1d(%r12)
1188c7ac:      	jne	0x1188cc00 <js_object_get_field_by_name+0x1de0>
1188c7b2:      	jmp	0x1188e7e4 <js_object_get_field_by_name+0x39c4>
1188c7b7:      	leaq	0x14(%r12), %rax
1188c7bc:      	cmpb	$0x42, (%rax)
1188c7bf:      	jne	0x1188cc00 <js_object_get_field_by_name+0x1de0>
1188c7c5:      	cmpb	$0x59, 0x15(%r12)
1188c7cb:      	jne	0x1188cc00 <js_object_get_field_by_name+0x1de0>
1188c7d1:      	cmpb	$0x54, 0x16(%r12)
1188c7d7:      	jne	0x1188cc00 <js_object_get_field_by_name+0x1de0>
1188c7dd:      	cmpb	$0x45, 0x17(%r12)
1188c7e3:      	jne	0x1188cc00 <js_object_get_field_by_name+0x1de0>
1188c7e9:      	cmpb	$0x53, 0x18(%r12)
1188c7ef:      	jne	0x1188cc00 <js_object_get_field_by_name+0x1de0>
1188c7f5:      	cmpb	$0x5f, 0x19(%r12)
1188c7fb:      	jne	0x1188cc00 <js_object_get_field_by_name+0x1de0>
1188c801:      	cmpb	$0x50, 0x1a(%r12)
1188c807:      	jne	0x1188cc00 <js_object_get_field_by_name+0x1de0>
1188c80d:      	cmpb	$0x45, 0x1b(%r12)
1188c813:      	jne	0x1188cc00 <js_object_get_field_by_name+0x1de0>
1188c819:      	cmpb	$0x52, 0x1c(%r12)
1188c81f:      	jne	0x1188cc00 <js_object_get_field_by_name+0x1de0>
1188c825:      	cmpb	$0x5f, 0x1d(%r12)
1188c82b:      	jne	0x1188cc00 <js_object_get_field_by_name+0x1de0>
1188c831:      	cmpb	$0x45, 0x1e(%r12)
1188c837:      	jne	0x1188cc00 <js_object_get_field_by_name+0x1de0>
1188c83d:      	cmpb	$0x4c, 0x1f(%r12)
1188c843:      	jne	0x1188cc00 <js_object_get_field_by_name+0x1de0>
1188c849:      	cmpb	$0x45, 0x20(%r12)
1188c84f:      	jne	0x1188cc00 <js_object_get_field_by_name+0x1de0>
1188c855:      	cmpb	$0x4d, 0x21(%r12)
1188c85b:      	jne	0x1188cc00 <js_object_get_field_by_name+0x1de0>
1188c861:      	cmpb	$0x45, 0x22(%r12)
1188c867:      	jne	0x1188cc00 <js_object_get_field_by_name+0x1de0>
1188c86d:      	cmpb	$0x4e, 0x23(%r12)
1188c873:      	jne	0x1188cc00 <js_object_get_field_by_name+0x1de0>
1188c879:      	cmpb	$0x54, 0x24(%r12)
1188c87f:      	jne	0x1188cc00 <js_object_get_field_by_name+0x1de0>
1188c885:      	jmp	0x1188ebfc <js_object_get_field_by_name+0x3ddc>
1188c88a:      	cmpb	$0x66, 0x15(%r12)
1188c890:      	jne	0x1188cc00 <js_object_get_field_by_name+0x1de0>
1188c896:      	cmpb	$0x66, 0x16(%r12)
1188c89c:      	jne	0x1188cc00 <js_object_get_field_by_name+0x1de0>
1188c8a2:      	cmpb	$0x73, 0x17(%r12)
1188c8a8:      	jne	0x1188cc00 <js_object_get_field_by_name+0x1de0>
1188c8ae:      	cmpb	$0x65, 0x18(%r12)
1188c8b4:      	jne	0x1188cc00 <js_object_get_field_by_name+0x1de0>
1188c8ba:      	cmpb	$0x74, 0x19(%r12)
1188c8c0:      	jne	0x1188cc00 <js_object_get_field_by_name+0x1de0>
1188c8c6:      	jmp	0x1188e7b2 <js_object_get_field_by_name+0x3992>
1188c8cb:      	cmpb	$0x65, 0x15(%r12)
1188c8d1:      	jne	0x1188cc00 <js_object_get_field_by_name+0x1de0>
1188c8d7:      	cmpb	$0x6e, 0x16(%r12)
1188c8dd:      	jne	0x1188cc00 <js_object_get_field_by_name+0x1de0>
1188c8e3:      	cmpb	$0x67, 0x17(%r12)
1188c8e9:      	jne	0x1188cc00 <js_object_get_field_by_name+0x1de0>
1188c8ef:      	cmpb	$0x74, 0x18(%r12)
1188c8f5:      	jne	0x1188cc00 <js_object_get_field_by_name+0x1de0>
1188c8fb:      	cmpb	$0x68, 0x19(%r12)
1188c901:      	jne	0x1188cc00 <js_object_get_field_by_name+0x1de0>
1188c907:      	jmp	0x1188e7ca <js_object_get_field_by_name+0x39aa>
1188c90c:      	cmpb	$0x61, 0x15(%r12)
1188c912:      	jne	0x1188cc00 <js_object_get_field_by_name+0x1de0>
1188c918:      	cmpb	$0x72, 0x16(%r12)
1188c91e:      	jne	0x1188cc00 <js_object_get_field_by_name+0x1de0>
1188c924:      	cmpb	$0x65, 0x17(%r12)
1188c92a:      	jne	0x1188cc00 <js_object_get_field_by_name+0x1de0>
1188c930:      	cmpb	$0x6e, 0x18(%r12)
1188c936:      	jne	0x1188cc00 <js_object_get_field_by_name+0x1de0>
1188c93c:      	cmpb	$0x74, 0x19(%r12)
1188c942:      	jne	0x1188cc00 <js_object_get_field_by_name+0x1de0>
1188c948:      	jmp	0x1188e624 <js_object_get_field_by_name+0x3804>
1188c94d:      	movl	$0xffff0028, %r15d      # imm = 0xFFFF0028
1188c953:      	jmp	0x1188c05c <js_object_get_field_by_name+0x123c>
1188c958:      	movl	$0xffff0027, %r15d      # imm = 0xFFFF0027
1188c95e:      	jmp	0x1188c05c <js_object_get_field_by_name+0x123c>
1188c963:      	leaq	0x14(%r12), %rax
1188c968:      	cmpb	$0x63, (%rax)
1188c96b:      	jne	0x1188d1f1 <js_object_get_field_by_name+0x23d1>
1188c971:      	cmpb	$0x6f, 0x15(%r12)
1188c977:      	jne	0x1188d1f1 <js_object_get_field_by_name+0x23d1>
1188c97d:      	cmpb	$0x6e, 0x16(%r12)
1188c983:      	jne	0x1188d1f1 <js_object_get_field_by_name+0x23d1>
1188c989:      	cmpb	$0x73, 0x17(%r12)
1188c98f:      	jne	0x1188d1f1 <js_object_get_field_by_name+0x23d1>
1188c995:      	cmpb	$0x74, 0x18(%r12)
1188c99b:      	jne	0x1188d1f1 <js_object_get_field_by_name+0x23d1>
1188c9a1:      	cmpb	$0x72, 0x19(%r12)
1188c9a7:      	jne	0x1188d1f1 <js_object_get_field_by_name+0x23d1>
1188c9ad:      	cmpb	$0x75, 0x1a(%r12)
1188c9b3:      	jne	0x1188d1f1 <js_object_get_field_by_name+0x23d1>
1188c9b9:      	cmpb	$0x63, 0x1b(%r12)
1188c9bf:      	jne	0x1188d1f1 <js_object_get_field_by_name+0x23d1>
1188c9c5:      	cmpb	$0x74, 0x1c(%r12)
1188c9cb:      	jne	0x1188d1f1 <js_object_get_field_by_name+0x23d1>
1188c9d1:      	cmpb	$0x6f, 0x1d(%r12)
1188c9d7:      	jne	0x1188d1f1 <js_object_get_field_by_name+0x23d1>
1188c9dd:      	cmpb	$0x72, 0x1e(%r12)
1188c9e3:      	jne	0x1188d1f1 <js_object_get_field_by_name+0x23d1>
1188c9e9:      	jmp	0x1188eb9f <js_object_get_field_by_name+0x3d7f>
1188c9ee:      	leaq	0x14(%r12), %rax
1188c9f3:      	cmpb	$0x62, (%rax)
1188c9f6:      	jne	0x1188d1f1 <js_object_get_field_by_name+0x23d1>
1188c9fc:      	cmpb	$0x79, 0x15(%r12)
1188ca02:      	jne	0x1188d1f1 <js_object_get_field_by_name+0x23d1>
1188ca08:      	cmpb	$0x74, 0x16(%r12)
1188ca0e:      	jne	0x1188d1f1 <js_object_get_field_by_name+0x23d1>
1188ca14:      	cmpb	$0x65, 0x17(%r12)
1188ca1a:      	jne	0x1188d1f1 <js_object_get_field_by_name+0x23d1>
1188ca20:      	movzbl	0x18(%r12), %eax
1188ca26:      	cmpl	$0x4f, %eax
1188ca29:      	je	0x1188d1c5 <js_object_get_field_by_name+0x23a5>
1188ca2f:      	cmpl	$0x4c, %eax
1188ca32:      	jne	0x1188d1f1 <js_object_get_field_by_name+0x23d1>
1188ca38:      	cmpb	$0x65, 0x19(%r12)
1188ca3e:      	jne	0x1188d1f1 <js_object_get_field_by_name+0x23d1>
1188ca44:      	cmpb	$0x6e, 0x1a(%r12)
1188ca4a:      	jne	0x1188d1f1 <js_object_get_field_by_name+0x23d1>
1188ca50:      	cmpb	$0x67, 0x1b(%r12)
1188ca56:      	jne	0x1188d1f1 <js_object_get_field_by_name+0x23d1>
1188ca5c:      	cmpb	$0x74, 0x1c(%r12)
1188ca62:      	jne	0x1188d1f1 <js_object_get_field_by_name+0x23d1>
1188ca68:      	cmpb	$0x68, 0x1d(%r12)
1188ca6e:      	jne	0x1188d1f1 <js_object_get_field_by_name+0x23d1>
1188ca74:      	jmp	0x1188eb57 <js_object_get_field_by_name+0x3d37>
1188ca79:      	leaq	0x14(%r12), %rax
1188ca7e:      	cmpb	$0x42, (%rax)
1188ca81:      	jne	0x1188d1f1 <js_object_get_field_by_name+0x23d1>
1188ca87:      	cmpb	$0x59, 0x15(%r12)
1188ca8d:      	jne	0x1188d1f1 <js_object_get_field_by_name+0x23d1>
1188ca93:      	cmpb	$0x54, 0x16(%r12)
1188ca99:      	jne	0x1188d1f1 <js_object_get_field_by_name+0x23d1>
1188ca9f:      	cmpb	$0x45, 0x17(%r12)
1188caa5:      	jne	0x1188d1f1 <js_object_get_field_by_name+0x23d1>
1188caab:      	cmpb	$0x53, 0x18(%r12)
1188cab1:      	jne	0x1188d1f1 <js_object_get_field_by_name+0x23d1>
1188cab7:      	cmpb	$0x5f, 0x19(%r12)
1188cabd:      	jne	0x1188d1f1 <js_object_get_field_by_name+0x23d1>
1188cac3:      	cmpb	$0x50, 0x1a(%r12)
1188cac9:      	jne	0x1188d1f1 <js_object_get_field_by_name+0x23d1>
1188cacf:      	cmpb	$0x45, 0x1b(%r12)
1188cad5:      	jne	0x1188d1f1 <js_object_get_field_by_name+0x23d1>
1188cadb:      	cmpb	$0x52, 0x1c(%r12)
1188cae1:      	jne	0x1188d1f1 <js_object_get_field_by_name+0x23d1>
1188cae7:      	cmpb	$0x5f, 0x1d(%r12)
1188caed:      	jne	0x1188d1f1 <js_object_get_field_by_name+0x23d1>
1188caf3:      	cmpb	$0x45, 0x1e(%r12)
1188caf9:      	jne	0x1188d1f1 <js_object_get_field_by_name+0x23d1>
1188caff:      	cmpb	$0x4c, 0x1f(%r12)
1188cb05:      	jne	0x1188d1f1 <js_object_get_field_by_name+0x23d1>
1188cb0b:      	cmpb	$0x45, 0x20(%r12)
1188cb11:      	jne	0x1188d1f1 <js_object_get_field_by_name+0x23d1>
1188cb17:      	cmpb	$0x4d, 0x21(%r12)
1188cb1d:      	jne	0x1188d1f1 <js_object_get_field_by_name+0x23d1>
1188cb23:      	cmpb	$0x45, 0x22(%r12)
1188cb29:      	jne	0x1188d1f1 <js_object_get_field_by_name+0x23d1>
1188cb2f:      	cmpb	$0x4e, 0x23(%r12)
1188cb35:      	jne	0x1188d1f1 <js_object_get_field_by_name+0x23d1>
1188cb3b:      	cmpb	$0x54, 0x24(%r12)
1188cb41:      	jne	0x1188d1f1 <js_object_get_field_by_name+0x23d1>
1188cb47:      	jmp	0x1188ec0b <js_object_get_field_by_name+0x3deb>
1188cb4c:      	cmpq	$0x8, %rbx
1188cb50:      	je	0x1188d088 <js_object_get_field_by_name+0x2268>
1188cb56:      	cmpq	$0xa, %rbx
1188cb5a:      	jne	0x1188c120 <js_object_get_field_by_name+0x1300>
1188cb60:      	movq	-0x98(%rbp), %rdx
1188cb67:      	movq	(%rdx), %rax
1188cb6a:      	movabsq	$0x7473696765726e75, %rcx # imm = 0x7473696765726E75
1188cb74:      	xorq	%rcx, %rax
1188cb77:      	movzwl	0x8(%rdx), %ecx
1188cb7b:      	xorq	$0x7265, %rcx           # imm = 0x7265
1188cb82:      	orq	%rax, %rcx
1188cb85:      	jne	0x1188c120 <js_object_get_field_by_name+0x1300>
1188cb8b:      	jmp	0x1188d0a2 <js_object_get_field_by_name+0x2282>
1188cb90:      	cmpb	$0x75, 0x15(%r12)
1188cb96:      	jne	0x1188d1f1 <js_object_get_field_by_name+0x23d1>
1188cb9c:      	cmpb	$0x66, 0x16(%r12)
1188cba2:      	jne	0x1188d1f1 <js_object_get_field_by_name+0x23d1>
1188cba8:      	cmpb	$0x66, 0x17(%r12)
1188cbae:      	jne	0x1188d1f1 <js_object_get_field_by_name+0x23d1>
1188cbb4:      	cmpb	$0x65, 0x18(%r12)
1188cbba:      	jne	0x1188d1f1 <js_object_get_field_by_name+0x23d1>
1188cbc0:      	cmpb	$0x72, 0x19(%r12)
1188cbc6:      	jne	0x1188d1f1 <js_object_get_field_by_name+0x23d1>
1188cbcc:      	jmp	0x1188ea42 <js_object_get_field_by_name+0x3c22>
1188cbd1:      	cmpb	$0x66, 0x19(%r12)
1188cbd7:      	jne	0x1188cc00 <js_object_get_field_by_name+0x1de0>
1188cbd9:      	cmpb	$0x66, 0x1a(%r12)
1188cbdf:      	jne	0x1188cc00 <js_object_get_field_by_name+0x1de0>
1188cbe1:      	cmpb	$0x73, 0x1b(%r12)
1188cbe7:      	jne	0x1188cc00 <js_object_get_field_by_name+0x1de0>
1188cbe9:      	cmpb	$0x65, 0x1c(%r12)
1188cbef:      	jne	0x1188cc00 <js_object_get_field_by_name+0x1de0>
1188cbf1:      	cmpb	$0x74, 0x1d(%r12)
1188cbf7:      	je	0x1188e7b2 <js_object_get_field_by_name+0x3992>
1188cbfd:      	nopl	(%rax)
1188cc00:      	movq	%r13, %rdi
1188cc03:      	callq	0x11537fb0 <_RNvNtNtCscI5nJwKNRh4_13perry_runtime6object15prototype_chain23object_static_prototype>
1188cc08:      	testb	$0x1, %al
1188cc0a:      	je	0x1188cc50 <js_object_get_field_by_name+0x1e30>
1188cc0c:      	movabsq	$0x7ffc000000000001, %rax # imm = 0x7FFC000000000001
1188cc16:      	incq	%rax
1188cc19:      	cmpq	%rax, %rdx
1188cc1c:      	je	0x1188cccb <js_object_get_field_by_name+0x1eab>
1188cc22:      	movq	%r13, %rdi
1188cc25:      	callq	0x11537fb0 <_RNvNtNtCscI5nJwKNRh4_13perry_runtime6object15prototype_chain23object_static_prototype>
1188cc2a:      	cmpq	$0x1, %rax
1188cc2e:      	jne	0x1188cccb <js_object_get_field_by_name+0x1eab>
1188cc34:      	movq	%r13, %rdi
1188cc37:      	movq	%rdx, %rsi
1188cc3a:      	movq	%r12, %rdx
1188cc3d:      	callq	0x11539180 <_RNvNtNtCscI5nJwKNRh4_13perry_runtime6object15prototype_chain38resolve_inherited_field_from_prototype>
1188cc42:      	testb	$0x1, %al
1188cc44:      	je	0x1188cccb <js_object_get_field_by_name+0x1eab>
1188cc4a:      	jmp	0x1188da0b <js_object_get_field_by_name+0x2beb>
1188cc4f:      	nop
1188cc50:      	movl	$0xa, %esi
1188cc55:      	leaq	0x2a72ed7(%rip), %rdi   # 0x142ffb33 <anon.b37f594bd5826585f7e5082f302a037e.2838.llvm.4573768808118376784+0x653>
1188cc5c:      	callq	*0x3a8aa2e(%rip)        # 0x15317690 <_GLOBAL_OFFSET_TABLE_+0x610>
1188cc62:      	movq	%xmm0, %rdi
1188cc67:      	movq	%rdi, %rax
1188cc6a:      	movabsq	$-0x1000000000000, %rcx # imm = 0xFFFF000000000000
1188cc74:      	andq	%rcx, %rax
1188cc77:      	movabsq	$0x7ffc000000000001, %rsi # imm = 0x7FFC000000000001
1188cc81:      	movabsq	$0x7ffd000000000000, %rcx # imm = 0x7FFD000000000000
1188cc8b:      	cmpq	%rcx, %rax
1188cc8e:      	jne	0x1188ccb6 <js_object_get_field_by_name+0x1e96>
1188cc90:      	movabsq	$0xffffffffffff, %rax   # imm = 0xFFFFFFFFFFFF
1188cc9a:      	andq	%rax, %rdi
1188cc9d:      	je	0x1188ccb6 <js_object_get_field_by_name+0x1e96>
1188cc9f:      	movl	$0x9, %edx
1188cca4:      	leaq	0x2a70f55(%rip), %rsi   # 0x142fdc00 <anon.b37f594bd5826585f7e5082f302a037e.837.llvm.4573768808118376784+0x21>
1188ccab:      	callq	*0x3a8c2cf(%rip)        # 0x15318f80 <_GLOBAL_OFFSET_TABLE_+0x1f00>
1188ccb1:      	movq	%xmm0, %rsi
1188ccb6:      	movq	%r13, %rdi
1188ccb9:      	movq	%r12, %rdx
1188ccbc:      	callq	0x11539180 <_RNvNtNtCscI5nJwKNRh4_13perry_runtime6object15prototype_chain38resolve_inherited_field_from_prototype>
1188ccc1:      	cmpq	$0x1, %rax
1188ccc5:      	je	0x1188da0b <js_object_get_field_by_name+0x2beb>
1188cccb:      	movq	%r13, %rdi
1188ccce:      	callq	0x1150dba0 <_RNvNtNtCscI5nJwKNRh4_13perry_runtime6buffer6header13is_secret_key>
1188ccd3:      	testb	%al, %al
1188ccd5:      	je	0x1188e184 <js_object_get_field_by_name+0x3364>
1188ccdb:      	cmpq	$0x0, -0x40(%rbp)
1188cce0:      	je	0x1188cd10 <js_object_get_field_by_name+0x1ef0>
1188cce2:      	movabsq	$0x7ff8ffffffffffff, %rax # imm = 0x7FF8FFFFFFFFFFFF
1188ccec:      	cmpq	%rax, %r14
1188ccef:      	movabsq	$0xffffffffffff, %r15   # imm = 0xFFFFFFFFFFFF
1188ccf9:      	movdqa	-0x70(%rbp), %xmm0
1188ccfe:      	jg	0x1188cd28 <js_object_get_field_by_name+0x1f08>
1188cd00:      	jmp	0x1188d62f <js_object_get_field_by_name+0x280f>
1188cd05:      	nopw	%cs:(%rax,%rax)
1188cd10:      	testq	%r14, %r14
1188cd13:      	movabsq	$0xffffffffffff, %r15   # imm = 0xFFFFFFFFFFFF
1188cd1d:      	movdqa	-0x70(%rbp), %xmm0
1188cd22:      	je	0x1188d62f <js_object_get_field_by_name+0x280f>
1188cd28:      	movq	%r14, %rax
1188cd2b:      	movabsq	$-0x1000000000000, %rcx # imm = 0xFFFF000000000000
1188cd35:      	andq	%rcx, %rax
1188cd38:      	movabsq	$0x7ff9000000000000, %rcx # imm = 0x7FF9000000000000
1188cd42:      	cmpq	%rcx, %rax
1188cd45:      	je	0x1188d4ed <js_object_get_field_by_name+0x26cd>
1188cd4b:      	movabsq	$0x7fff000000000000, %rcx # imm = 0x7FFF000000000000
1188cd55:      	cmpq	%rcx, %rax
1188cd58:      	je	0x1188d4ed <js_object_get_field_by_name+0x26cd>
1188cd5e:      	movq	%r14, %r13
1188cd61:      	cmpq	$0x0, -0x40(%rbp)
1188cd66:      	je	0x1188cd77 <js_object_get_field_by_name+0x1f57>
1188cd68:      	cmpl	$0x7ffd, -0x40(%rbp)    # imm = 0x7FFD
1188cd6f:      	jne	0x1188cdd0 <js_object_get_field_by_name+0x1fb0>
1188cd71:      	movq	%r14, %r13
1188cd74:      	andq	%r15, %r13
1188cd77:      	testq	%r13, %r13
1188cd7a:      	je	0x1188cdd0 <js_object_get_field_by_name+0x1fb0>
1188cd7c:      	movl	0x4(%r12), %edx
1188cd81:      	leaq	-0x58(%rbp), %rdi
1188cd85:      	leaq	0x14(%r12), %rsi
1188cd8a:      	callq	*0x3a90ae0(%rip)        # 0x1531d870 <_GLOBAL_OFFSET_TABLE_+0x67f0>
1188cd90:      	cmpb	$0x0, -0x58(%rbp)
1188cd94:      	jne	0x1188cdb1 <js_object_get_field_by_name+0x1f91>
1188cd96:      	movq	-0x50(%rbp), %rsi
1188cd9a:      	movq	-0x48(%rbp), %rdx
1188cd9e:      	movq	%r13, %rdi
1188cda1:      	callq	*0x3a9def1(%rip)        # 0x1532ac98 <_GLOBAL_OFFSET_TABLE_+0x13c18>
1188cda7:      	cmpq	$0x1, %rax
1188cdab:      	je	0x1188dbf5 <js_object_get_field_by_name+0x2dd5>
1188cdb1:      	cmpq	$0x100000, %r13         # imm = 0x100000
1188cdb8:      	movdqa	-0x70(%rbp), %xmm0
1188cdbd:      	jae	0x1188cdd3 <js_object_get_field_by_name+0x1fb3>
1188cdbf:      	jmp	0x1188dace <js_object_get_field_by_name+0x2cae>
1188cdc4:      	nopw	%cs:(%rax,%rax)
1188cdd0:      	xorl	%r13d, %r13d
1188cdd3:      	movq	%r13, %rax
1188cdd6:      	shrq	$0x3, %rax
1188cdda:      	movabsq	$-0x61c8864680b583eb, %rcx # imm = 0x9E3779B97F4A7C15
1188cde4:      	imulq	%rcx, %rax
1188cde8:      	movq	%rax, %rcx
1188cdeb:      	shrq	$0x36, %rcx
1188cdef:      	movq	%rax, %rdx
1188cdf2:      	shrq	$0x3c, %rdx
1188cdf6:      	leaq	0x54e78a3(%rip), %rsi   # 0x16d746a0 <_RNvNtNtCscI5nJwKNRh4_13perry_runtime13native_handle9canonical28CANONICAL_HANDLE_ADDR_FILTER.llvm.4573768808118376784>
1188cdfd:      	movq	(%rsi,%rdx,8), %rdx
1188ce01:      	btq	%rcx, %rdx
1188ce05:      	jae	0x1188ceb0 <js_object_get_field_by_name+0x2090>
1188ce0b:      	movq	%rax, %rcx
1188ce0e:      	shrq	$0x2c, %rcx
1188ce12:      	movq	%rax, %rdx
1188ce15:      	shrq	$0x32, %rdx
1188ce19:      	andl	$0xf, %edx
1188ce1c:      	leaq	0x54e787d(%rip), %rsi   # 0x16d746a0 <_RNvNtNtCscI5nJwKNRh4_13perry_runtime13native_handle9canonical28CANONICAL_HANDLE_ADDR_FILTER.llvm.4573768808118376784>
1188ce23:      	movq	(%rsi,%rdx,8), %rdx
1188ce27:      	btq	%rcx, %rdx
1188ce2b:      	jae	0x1188ceb0 <js_object_get_field_by_name+0x2090>
1188ce31:      	movq	%rax, %rcx
1188ce34:      	shrq	$0x22, %rcx
1188ce38:      	shrq	$0x28, %rax
1188ce3c:      	andl	$0xf, %eax
1188ce3f:      	leaq	0x54e785a(%rip), %rdx   # 0x16d746a0 <_RNvNtNtCscI5nJwKNRh4_13perry_runtime13native_handle9canonical28CANONICAL_HANDLE_ADDR_FILTER.llvm.4573768808118376784>
1188ce46:      	movq	(%rdx,%rax,8), %rax
1188ce4a:      	shrq	%cl, %rax
1188ce4d:      	testq	%r13, %r13
1188ce50:      	je	0x1188ceb0 <js_object_get_field_by_name+0x2090>
1188ce52:      	testb	$0x1, %al
1188ce54:      	je	0x1188ceb0 <js_object_get_field_by_name+0x2090>
1188ce56:      	movabsq	$0x800000000000, %rax   # imm = 0x800000000000
1188ce60:      	decq	%rax
1188ce63:      	cmpq	%rax, %r13
1188ce66:      	ja	0x1188ceb0 <js_object_get_field_by_name+0x2090>
1188ce68:      	leaq	-0x8(%r13), %rbx
1188ce6c:      	movq	%rbx, %rdi
1188ce6f:      	callq	*0x3a8f17b(%rip)        # 0x1531bff0 <_GLOBAL_OFFSET_TABLE_+0x4f70>
1188ce75:      	movdqa	-0x70(%rbp), %xmm0
1188ce7a:      	testb	%al, %al
1188ce7c:      	je	0x1188ceb0 <js_object_get_field_by_name+0x2090>
1188ce7e:      	cmpb	$0xf, (%rbx)
1188ce81:      	jne	0x1188ceb0 <js_object_get_field_by_name+0x2090>
1188ce83:      	movabsq	$0x5045525259484e44, %rax # imm = 0x5045525259484E44
1188ce8d:      	cmpq	%rax, (%r13)
1188ce91:      	jne	0x1188ceb0 <js_object_get_field_by_name+0x2090>
1188ce93:      	testb	$0x1, 0x1c(%r13)
1188ce98:      	je	0x1188ceb0 <js_object_get_field_by_name+0x2090>
1188ce9a:      	cmpb	$0x0, 0x1b(%r13)
1188ce9f:      	je	0x1188dace <js_object_get_field_by_name+0x2cae>
1188cea5:      	nopw	%cs:(%rax,%rax)
1188ceb0:      	movzwl	-0x40(%rbp), %r12d
1188ceb5:      	cmpl	$0x7ffc, %r12d          # imm = 0x7FFC
1188cebc:      	jg	0x1188cee0 <js_object_get_field_by_name+0x20c0>
1188cebe:      	movq	%r14, %rbx
1188cec1:      	testl	%r12d, %r12d
1188cec4:      	movabsq	$0x7ffd000000000000, %r13 # imm = 0x7FFD000000000000
1188cece:      	jne	0x1188d855 <js_object_get_field_by_name+0x2a35>
1188ced4:      	testq	%rbx, %rbx
1188ced7:      	jne	0x1188cf06 <js_object_get_field_by_name+0x20e6>
1188ced9:      	jmp	0x1188d35b <js_object_get_field_by_name+0x253b>
1188cede:      	nop
1188cee0:      	cmpl	$0x7ffd, %r12d          # imm = 0x7FFD
1188cee7:      	movabsq	$0x7ffd000000000000, %r13 # imm = 0x7FFD000000000000
1188cef1:      	jne	0x1188d73d <js_object_get_field_by_name+0x291d>
1188cef7:      	movq	%r14, %rbx
1188cefa:      	andq	%r15, %rbx
1188cefd:      	testq	%rbx, %rbx
1188cf00:      	je	0x1188d35b <js_object_get_field_by_name+0x253b>
1188cf06:      	leaq	0x54e7053(%rip), %rax   # 0x16d73f60 <_RNvNtCscI5nJwKNRh4_13perry_runtime10typedarray27TYPED_ARRAY_EVER_REGISTERED>
1188cf0d:      	movzbl	(%rax), %eax
1188cf10:      	testb	%al, %al
1188cf12:      	je	0x1188cf50 <js_object_get_field_by_name+0x2130>
1188cf14:      	leaq	0x3ac20ad(%rip), %rax   # 0x1534efc8 <_RNvNtCscI5nJwKNRh4_13perry_runtime10typedarray23TYPED_ARRAY_ADDR_WINDOW>
1188cf1b:      	movq	(%rax), %rax
1188cf1e:      	cmpq	%rax, %rbx
1188cf21:      	jb	0x1188cf50 <js_object_get_field_by_name+0x2130>
1188cf23:      	leaq	0x3ac209e(%rip), %rax   # 0x1534efc8 <_RNvNtCscI5nJwKNRh4_13perry_runtime10typedarray23TYPED_ARRAY_ADDR_WINDOW>
1188cf2a:      	movq	0x8(%rax), %rax
1188cf2e:      	cmpq	%rax, %rbx
1188cf31:      	ja	0x1188cf50 <js_object_get_field_by_name+0x2130>
1188cf33:      	movq	%rbx, %rdi
1188cf36:      	callq	*0x3aa1d14(%rip)        # 0x1532ec50 <_GLOBAL_OFFSET_TABLE_+0x17bd0>
1188cf3c:      	testb	$0x1, %al
1188cf3e:      	jne	0x1188d35b <js_object_get_field_by_name+0x253b>
1188cf44:      	nopw	%cs:(%rax,%rax)
1188cf50:      	movq	%rbx, %rdi
1188cf53:      	callq	0x1150edd0 <_RNvNtNtCscI5nJwKNRh4_13perry_runtime6buffer6header20is_registered_buffer.llvm.4573768808118376784>
1188cf58:      	movabsq	$-0x800000000000, %rdx  # imm = 0xFFFF800000000000
1188cf62:      	leaq	(%rbx,%rdx), %rcx
1188cf66:      	addq	$0x100000, %rdx         # imm = 0x100000
1188cf6d:      	cmpq	%rdx, %rcx
1188cf70:      	jb	0x1188d35b <js_object_get_field_by_name+0x253b>
1188cf76:      	testb	%al, %al
1188cf78:      	jne	0x1188d35b <js_object_get_field_by_name+0x253b>
1188cf7e:      	cmpb	$0x11, -0x8(%rbx)
1188cf82:      	jne	0x1188d35b <js_object_get_field_by_name+0x253b>
1188cf88:      	movq	%rbx, %rdi
1188cf8b:      	callq	0x1150edd0 <_RNvNtNtCscI5nJwKNRh4_13perry_runtime6buffer6header20is_registered_buffer.llvm.4573768808118376784>
1188cf90:      	testb	%al, %al
1188cf92:      	jne	0x1188d35b <js_object_get_field_by_name+0x253b>
1188cf98:      	movq	-0x30(%rbp), %r12
1188cf9c:      	movl	0x4(%r12), %r15d
1188cfa1:      	leaq	-0x58(%rbp), %rdi
1188cfa5:      	leaq	0x14(%r12), %rsi
1188cfaa:      	movq	%r15, %rdx
1188cfad:      	callq	*0x3a908bd(%rip)        # 0x1531d870 <_GLOBAL_OFFSET_TABLE_+0x67f0>
1188cfb3:      	cmpb	$0x0, -0x58(%rbp)
1188cfb7:      	jne	0x1188cfde <js_object_get_field_by_name+0x21be>
1188cfb9:      	movq	-0x50(%rbp), %rdx
1188cfbd:      	movq	-0x48(%rbp), %rcx
1188cfc1:      	leaq	(%rbx,%r13), %rax
1188cfc5:      	movq	%rax, %xmm0
1188cfca:      	movq	%rbx, %rdi
1188cfcd:      	xorl	%esi, %esi
1188cfcf:      	callq	0x1152a580 <_RNvNtNtCscI5nJwKNRh4_13perry_runtime6object14exotic_expando23exotic_get_own_property>
1188cfd4:      	cmpq	$0x1, %rax
1188cfd8:      	je	0x1188dbf5 <js_object_get_field_by_name+0x2dd5>
1188cfde:      	cmpl	$0xb, %r15d
1188cfe2:      	jne	0x1188d017 <js_object_get_field_by_name+0x21f7>
1188cfe4:      	leaq	0x14(%r12), %rdx
1188cfe9:      	movzwl	0x8(%rdx), %eax
1188cfed:      	movzbl	0xa(%rdx), %ecx
1188cff1:      	shll	$0x10, %ecx
1188cff4:      	orq	%rax, %rcx
1188cff7:      	movq	(%rdx), %rax
1188cffa:      	movabsq	$0x63757274736e6f63, %rdx # imm = 0x63757274736E6F63
1188d004:      	xorq	%rdx, %rax
1188d007:      	xorq	$0x726f74, %rcx         # imm = 0x726F74
1188d00e:      	orq	%rax, %rcx
1188d011:      	je	0x1188dbe3 <js_object_get_field_by_name+0x2dc3>
1188d017:      	movl	$0x4, %esi
1188d01c:      	leaq	0x2a5e375(%rip), %rdi   # 0x142eb398 <anon.b37f594bd5826585f7e5082f302a037e.5290.llvm.4573768808118376784+0x1c>
1188d023:      	callq	*0x3a8a667(%rip)        # 0x15317690 <_GLOBAL_OFFSET_TABLE_+0x610>
1188d029:      	movq	%xmm0, %rdi
1188d02e:      	movq	%rdi, %rax
1188d031:      	movabsq	$-0x1000000000000, %r15 # imm = 0xFFFF000000000000
1188d03b:      	andq	%r15, %rax
1188d03e:      	cmpq	%r13, %rax
1188d041:      	jne	0x1188e184 <js_object_get_field_by_name+0x3364>
1188d047:      	movabsq	$0xffffffffffff, %rbx   # imm = 0xFFFFFFFFFFFF
1188d051:      	andq	%rbx, %rdi
1188d054:      	movl	$0x9, %edx
1188d059:      	leaq	0x2a70ba0(%rip), %rsi   # 0x142fdc00 <anon.b37f594bd5826585f7e5082f302a037e.837.llvm.4573768808118376784+0x21>
1188d060:      	callq	*0x3a8bf1a(%rip)        # 0x15318f80 <_GLOBAL_OFFSET_TABLE_+0x1f00>
1188d066:      	movq	%xmm0, %r14
1188d06b:      	movq	%r14, %rax
1188d06e:      	andq	%r15, %rax
1188d071:      	cmpq	%r13, %rax
1188d074:      	jne	0x1188e184 <js_object_get_field_by_name+0x3364>
1188d07a:      	andq	%rbx, %r14
1188d07d:      	jne	0x1188af61 <js_object_get_field_by_name+0x141>
1188d083:      	jmp	0x1188e184 <js_object_get_field_by_name+0x3364>
1188d088:      	movabsq	$0x7265747369676572, %rax # imm = 0x7265747369676572
1188d092:      	movq	-0x98(%rbp), %rcx
1188d099:      	cmpq	%rax, (%rcx)
1188d09c:      	jne	0x1188c120 <js_object_get_field_by_name+0x1300>
1188d0a2:      	movl	$0x14, %esi
1188d0a7:      	leaq	0x2ab22b7(%rip), %rdi   # 0x1433f365 <anon.b37f594bd5826585f7e5082f302a037e.10935.llvm.4573768808118376784+0x3c4>
1188d0ae:      	callq	*0x3a8a5dc(%rip)        # 0x15317690 <_GLOBAL_OFFSET_TABLE_+0x610>
1188d0b4:      	movq	%xmm0, %rdi
1188d0b9:      	movq	%rdi, %rax
1188d0bc:      	movabsq	$-0x1000000000000, %rcx # imm = 0xFFFF000000000000
1188d0c6:      	andq	%rcx, %rax
1188d0c9:      	movabsq	$0x7ffd000000000000, %rcx # imm = 0x7FFD000000000000
1188d0d3:      	cmpq	%rcx, %rax
1188d0d6:      	setne	%al
1188d0d9:      	movabsq	$0xffffffffffff, %rcx   # imm = 0xFFFFFFFFFFFF
1188d0e3:      	andq	%rcx, %rdi
1188d0e6:      	sete	%cl
1188d0e9:      	orb	%al, %cl
1188d0eb:      	jne	0x1188c120 <js_object_get_field_by_name+0x1300>
1188d0f1:      	movl	$0x9, %edx
1188d0f6:      	leaq	0x2a70b03(%rip), %rsi   # 0x142fdc00 <anon.b37f594bd5826585f7e5082f302a037e.837.llvm.4573768808118376784+0x21>
1188d0fd:      	callq	*0x3a8be7d(%rip)        # 0x15318f80 <_GLOBAL_OFFSET_TABLE_+0x1f00>
1188d103:      	movq	%xmm0, %r15
1188d108:      	movabsq	$0x7ffc000000000001, %rax # imm = 0x7FFC000000000001
1188d112:      	cmpq	%rax, %r15
1188d115:      	je	0x1188c120 <js_object_get_field_by_name+0x1300>
1188d11b:      	movq	%r15, %rax
1188d11e:      	shrq	$0x30, %rax
1188d122:      	addl	$0xffff8006, %eax       # imm = 0xFFFF8006
1188d127:      	cmpl	$0x5, %eax
1188d12a:      	ja	0x1188d28f <js_object_get_field_by_name+0x246f>
1188d130:      	movl	$0x2b, %ecx
1188d135:      	btl	%eax, %ecx
1188d138:      	jae	0x1188d28f <js_object_get_field_by_name+0x246f>
1188d13e:      	movabsq	$0xffffffffffff, %rax   # imm = 0xFFFFFFFFFFFF
1188d148:      	andq	%rax, %r15
1188d14b:      	je	0x1188c120 <js_object_get_field_by_name+0x1300>
1188d151:      	movq	-0x98(%rbp), %rdi
1188d158:      	movl	%ebx, %esi
1188d15a:      	movl	%ebx, %edx
1188d15c:      	callq	*0x3a8f146(%rip)        # 0x1531c2a8 <_GLOBAL_OFFSET_TABLE_+0x5228>
1188d162:      	movq	%r15, %rdi
1188d165:      	movq	%rax, %rsi
1188d168:      	callq	0x116ba1b0 <_RNvNtNtNtCscI5nJwKNRh4_13perry_runtime6object13field_get_set9accessors22own_data_field_by_name>
1188d16d:      	cmpq	$0x1, %rax
1188d171:      	jne	0x1188d27e <js_object_get_field_by_name+0x245e>
1188d177:      	movq	%rdx, %xmm0
1188d17c:      	xorl	%eax, %eax
1188d17e:      	movabsq	$0x7ffc000000000001, %rcx # imm = 0x7FFC000000000001
1188d188:      	cmpq	%rcx, %rdx
1188d18b:      	setne	%al
1188d18e:      	jmp	0x1188d280 <js_object_get_field_by_name+0x2460>
1188d193:      	andl	$0xbfffffff, %edx       # imm = 0xBFFFFFFF
1188d199:      	movq	%r14, %rdi
1188d19c:      	movq	%rdx, %rsi
1188d19f:      	callq	0x115691f0 <_RNvNtNtCscI5nJwKNRh4_13perry_runtime6object5spill12overflow_get>
1188d1a4:      	movabsq	$0x7ffc000000000001, %rcx # imm = 0x7FFC000000000001
1188d1ae:      	addq	$0xf, %rcx
1188d1b2:      	cmpq	%rcx, %rdx
1188d1b5:      	setne	%cl
1188d1b8:      	testb	%cl, %al
1188d1ba:      	je	0x1188b10f <js_object_get_field_by_name+0x2ef>
1188d1c0:      	jmp	0x1188da0b <js_object_get_field_by_name+0x2beb>
1188d1c5:      	cmpb	$0x66, 0x19(%r12)
1188d1cb:      	jne	0x1188d1f1 <js_object_get_field_by_name+0x23d1>
1188d1cd:      	cmpb	$0x66, 0x1a(%r12)
1188d1d3:      	jne	0x1188d1f1 <js_object_get_field_by_name+0x23d1>
1188d1d5:      	cmpb	$0x73, 0x1b(%r12)
1188d1db:      	jne	0x1188d1f1 <js_object_get_field_by_name+0x23d1>
1188d1dd:      	cmpb	$0x65, 0x1c(%r12)
1188d1e3:      	jne	0x1188d1f1 <js_object_get_field_by_name+0x23d1>
1188d1e5:      	cmpb	$0x74, 0x1d(%r12)
1188d1eb:      	je	0x1188eb91 <js_object_get_field_by_name+0x3d71>
1188d1f1:      	movq	%r13, %rdi
1188d1f4:      	callq	0x11537fb0 <_RNvNtNtCscI5nJwKNRh4_13perry_runtime6object15prototype_chain23object_static_prototype>
1188d1f9:      	testb	$0x1, %al
1188d1fb:      	jne	0x1188cc0c <js_object_get_field_by_name+0x1dec>
1188d201:      	movl	$0xa, %esi
1188d206:      	leaq	0x2a79fce(%rip), %rdi   # 0x143071db <anon.b37f594bd5826585f7e5082f302a037e.4211.llvm.4573768808118376784+0x5c70>
1188d20d:      	movzbl	-0x80(%rbp), %eax
1188d211:      	cmpb	$0xb, %al
1188d213:      	movabsq	$0xffffffffffff, %rbx   # imm = 0xFFFFFFFFFFFF
1188d21d:      	movabsq	$-0x1000000000000, %r15 # imm = 0xFFFF000000000000
1188d227:      	ja	0x1188d242 <js_object_get_field_by_name+0x2422>
1188d229:      	movzbl	%al, %eax
1188d22c:      	leaq	0x2ac6a65(%rip), %rcx   # 0x14353c98 <anon.b37f594bd5826585f7e5082f302a037e.16456.llvm.4573768808118376784+0x7c3>
1188d233:      	movzbl	(%rax,%rcx), %esi
1188d237:      	leaq	0x39caa22(%rip), %rcx   # 0x15257c60 <anon.b37f594bd5826585f7e5082f302a037e.16335.llvm.4573768808118376784+0x12e0>
1188d23e:      	movq	(%rcx,%rax,8), %rdi
1188d242:      	callq	*0x3a8a448(%rip)        # 0x15317690 <_GLOBAL_OFFSET_TABLE_+0x610>
1188d248:      	movq	%xmm0, %rdi
1188d24d:      	movq	%rdi, %rax
1188d250:      	andq	%r15, %rax
1188d253:      	movabsq	$0x7ffc000000000001, %rsi # imm = 0x7FFC000000000001
1188d25d:      	movabsq	$0x7ffd000000000000, %rcx # imm = 0x7FFD000000000000
1188d267:      	cmpq	%rcx, %rax
1188d26a:      	jne	0x1188ccb6 <js_object_get_field_by_name+0x1e96>
1188d270:      	andq	%rbx, %rdi
1188d273:      	jne	0x1188cc9f <js_object_get_field_by_name+0x1e7f>
1188d279:      	jmp	0x1188ccb6 <js_object_get_field_by_name+0x1e96>
1188d27e:      	xorl	%eax, %eax
1188d280:      	cmpq	$0x1, %rax
1188d284:      	jne	0x1188c120 <js_object_get_field_by_name+0x1300>
1188d28a:      	jmp	0x1188dbf5 <js_object_get_field_by_name+0x2dd5>
1188d28f:      	leaq	-0x1(%r15), %rax
1188d293:      	movabsq	$0xffffffffffff, %rcx   # imm = 0xFFFFFFFFFFFF
1188d29d:      	cmpq	%rcx, %rax
1188d2a0:      	jae	0x1188c120 <js_object_get_field_by_name+0x1300>
1188d2a6:      	jmp	0x1188d151 <js_object_get_field_by_name+0x2331>
1188d2ab:      	callq	*0x3a96167(%rip)        # 0x15323418 <_GLOBAL_OFFSET_TABLE_+0xc398>
1188d2b1:      	movq	-0x88(%rbp), %rdi
1188d2b8:      	jmp	0x1188b2ed <js_object_get_field_by_name+0x4cd>
1188d2bd:      	cmpl	$0x1, %eax
1188d2c0:      	jne	0x1188e8f6 <js_object_get_field_by_name+0x3ad6>
1188d2c6:      	movq	-0x90(%rbp), %r15
1188d2cd:      	movq	%r15, %rdi
1188d2d0:      	leaq	-0x787487(%rip), %rsi   # 0x11105e50 <_RINvNtNtNtNtCsjFfivMnupPH_3std3sys12thread_local6native5eager7destroyINtNtCs9ueeiBwVTSo_4core4cell7RefCellINtNtCscv7DEBI70Kq_5alloc3vec3VecTyyEEEECscI5nJwKNRh4_13perry_runtime.llvm.4573768808118376784>
1188d2d7:      	callq	*0x3a9fe33(%rip)        # 0x1532d110 <_GLOBAL_OFFSET_TABLE_+0x16090>
1188d2dd:      	movb	$0x0, 0x20(%r15)
1188d2e2:      	movq	(%r15), %rax
1188d2e5:      	movabsq	$0x7fffffffffffffff, %rcx # imm = 0x7FFFFFFFFFFFFFFF
1188d2ef:      	cmpq	%rcx, %rax
1188d2f2:      	jb	0x1188b802 <js_object_get_field_by_name+0x9e2>
1188d2f8:      	jmp	0x1188e662 <js_object_get_field_by_name+0x3842>
1188d2fd:      	movq	%rdi, -0x40(%rbp)
1188d301:      	movq	%rax, %rdi
1188d304:      	movq	%rsi, -0x70(%rbp)
1188d308:      	movq	%rcx, -0x80(%rbp)
1188d30c:      	callq	*0x3a96106(%rip)        # 0x15323418 <_GLOBAL_OFFSET_TABLE_+0xc398>
1188d312:      	movq	-0x80(%rbp), %rcx
1188d316:      	movq	-0x88(%rbp), %rax
1188d31d:      	movq	-0x40(%rbp), %rdi
1188d321:      	movq	-0x70(%rbp), %rsi
1188d325:      	movq	0x1e8(%rax,%rcx,8), %rdx
1188d32d:      	testq	%rdx, %rdx
1188d330:      	jne	0x1188b47a <js_object_get_field_by_name+0x65a>
1188d336:      	movq	%rsi, -0x70(%rbp)
1188d33a:      	movq	%rdi, -0x40(%rbp)
1188d33e:      	leaq	0x39ac3b3(%rip), %rdi   # 0x152396f8 <_RNvNtNtCscI5nJwKNRh4_13perry_runtime6object9read_stub9READ_STUB>
1188d345:      	callq	*0x3a9f76d(%rip)        # 0x1532cab8 <_GLOBAL_OFFSET_TABLE_+0x15a38>
1188d34b:      	movq	-0x40(%rbp), %rdi
1188d34f:      	movq	-0x70(%rbp), %rsi
1188d353:      	movq	%rax, %rdx
1188d356:      	jmp	0x1188b47a <js_object_get_field_by_name+0x65a>
1188d35b:      	movq	%r14, %r15
1188d35e:      	cmpw	$0x0, -0x40(%rbp)
1188d363:      	movdqa	-0x70(%rbp), %xmm0
1188d368:      	je	0x1188d394 <js_object_get_field_by_name+0x2574>
1188d36a:      	cmpl	$0x7ffb, %r12d          # imm = 0x7FFB
1188d371:      	je	0x1188d85e <js_object_get_field_by_name+0x2a3e>
1188d377:      	cmpl	$0x7ffd, %r12d          # imm = 0x7FFD
1188d37e:      	jne	0x1188d88f <js_object_get_field_by_name+0x2a6f>
1188d384:      	movq	%r14, %r15
1188d387:      	movabsq	$0xffffffffffff, %rax   # imm = 0xFFFFFFFFFFFF
1188d391:      	andq	%rax, %r15
1188d394:      	testq	%r15, %r15
1188d397:      	je	0x1188d530 <js_object_get_field_by_name+0x2710>
1188d39d:      	leaq	0x54e6bbc(%rip), %rax   # 0x16d73f60 <_RNvNtCscI5nJwKNRh4_13perry_runtime10typedarray27TYPED_ARRAY_EVER_REGISTERED>
1188d3a4:      	movzbl	(%rax), %eax
1188d3a7:      	testb	%al, %al
1188d3a9:      	je	0x1188d3e0 <js_object_get_field_by_name+0x25c0>
1188d3ab:      	leaq	0x3ac1c16(%rip), %rax   # 0x1534efc8 <_RNvNtCscI5nJwKNRh4_13perry_runtime10typedarray23TYPED_ARRAY_ADDR_WINDOW>
1188d3b2:      	movq	(%rax), %rax
1188d3b5:      	cmpq	%rax, %r15
1188d3b8:      	jb	0x1188d3e0 <js_object_get_field_by_name+0x25c0>
1188d3ba:      	leaq	0x3ac1c07(%rip), %rax   # 0x1534efc8 <_RNvNtCscI5nJwKNRh4_13perry_runtime10typedarray23TYPED_ARRAY_ADDR_WINDOW>
1188d3c1:      	movq	0x8(%rax), %rax
1188d3c5:      	cmpq	%rax, %r15
1188d3c8:      	ja	0x1188d3e0 <js_object_get_field_by_name+0x25c0>
1188d3ca:      	movq	%r15, %rdi
1188d3cd:      	callq	*0x3aa187d(%rip)        # 0x1532ec50 <_GLOBAL_OFFSET_TABLE_+0x17bd0>
1188d3d3:      	movdqa	-0x70(%rbp), %xmm0
1188d3d8:      	testb	$0x1, %al
1188d3da:      	jne	0x1188d530 <js_object_get_field_by_name+0x2710>
1188d3e0:      	movq	%r15, %rdi
1188d3e3:      	callq	0x1150edd0 <_RNvNtNtCscI5nJwKNRh4_13perry_runtime6buffer6header20is_registered_buffer.llvm.4573768808118376784>
1188d3e8:      	movdqa	-0x70(%rbp), %xmm0
1188d3ed:      	movabsq	$-0x800000000000, %rdx  # imm = 0xFFFF800000000000
1188d3f7:      	leaq	(%r15,%rdx), %rcx
1188d3fb:      	addq	$0x100000, %rdx         # imm = 0x100000
1188d402:      	cmpq	%rdx, %rcx
1188d405:      	setb	%cl
1188d408:      	orb	%al, %cl
1188d40a:      	jne	0x1188d530 <js_object_get_field_by_name+0x2710>
1188d410:      	cmpb	$0x12, -0x8(%r15)
1188d415:      	jne	0x1188d530 <js_object_get_field_by_name+0x2710>
1188d41b:      	movq	-0x30(%rbp), %rax
1188d41f:      	movl	0x4(%rax), %r14d
1188d423:      	leaq	-0x58(%rbp), %rdi
1188d427:      	movq	-0x78(%rbp), %rsi
1188d42b:      	movq	%r14, %rdx
1188d42e:      	callq	*0x3a94c1c(%rip)        # 0x15322050 <_GLOBAL_OFFSET_TABLE_+0xafd0>
1188d434:      	orq	%r15, %r13
1188d437:      	movq	%r13, %xmm0
1188d43c:      	movq	-0x58(%rbp), %r13
1188d440:      	movq	-0x50(%rbp), %rbx
1188d444:      	movq	-0x48(%rbp), %r12
1188d448:      	movq	%r15, %rdi
1188d44b:      	movl	$0x3, %esi
1188d450:      	movq	%rbx, %rdx
1188d453:      	movq	%r12, %rcx
1188d456:      	movq	%xmm0, -0x30(%rbp)
1188d45b:      	callq	0x1152a580 <_RNvNtNtCscI5nJwKNRh4_13perry_runtime6object14exotic_expando23exotic_get_own_property>
1188d460:      	testb	$0x1, %al
1188d462:      	jne	0x1188d4cc <js_object_get_field_by_name+0x26ac>
1188d464:      	movq	-0x30(%rbp), %xmm0
1188d469:      	movq	%rbx, %rdi
1188d46c:      	movq	%r12, %rsi
1188d46f:      	callq	*0x3aa405b(%rip)        # 0x153314d0 <_GLOBAL_OFFSET_TABLE_+0x1a450>
1188d475:      	testb	$0x1, %al
1188d477:      	jne	0x1188d4cc <js_object_get_field_by_name+0x26ac>
1188d479:      	movsd	-0x30(%rbp), %xmm0
1188d47e:      	movq	%rbx, %rdi
1188d481:      	movq	%r12, %rsi
1188d484:      	callq	*0x3a93cae(%rip)        # 0x15321138 <_GLOBAL_OFFSET_TABLE_+0xa0b8>
1188d48a:      	testb	%al, %al
1188d48c:      	je	0x1188e1c6 <js_object_get_field_by_name+0x33a6>
1188d492:      	cmpq	$0x1, %r14
1188d496:      	movq	%r14, %rdi
1188d499:      	adcq	$0x0, %rdi
1188d49d:      	movl	$0x1, %esi
1188d4a2:      	callq	*0x3a8d468(%rip)        # 0x1531a910 <_GLOBAL_OFFSET_TABLE_+0x3890>
1188d4a8:      	movq	%rax, %r15
1188d4ab:      	movq	%rax, %rdi
1188d4ae:      	movq	-0x78(%rbp), %rsi
1188d4b2:      	movq	%r14, %rdx
1188d4b5:      	callq	*0x3a8f875(%rip)        # 0x1531cd30 <_GLOBAL_OFFSET_TABLE_+0x5cb0>
1188d4bb:      	movq	-0x30(%rbp), %xmm0
1188d4c0:      	movq	%r15, %rdi
1188d4c3:      	movq	%r14, %rsi
1188d4c6:      	callq	*0x3aa36fc(%rip)        # 0x15330bc8 <_GLOBAL_OFFSET_TABLE_+0x19b48>
1188d4cc:      	testq	%r13, %r13
1188d4cf:      	jle	0x1188dbf5 <js_object_get_field_by_name+0x2dd5>
1188d4d5:      	movq	%rbx, %rdi
1188d4d8:      	movq	%xmm0, -0x30(%rbp)
1188d4dd:      	callq	*0x3aa490d(%rip)        # 0x15331df0 <_GLOBAL_OFFSET_TABLE_+0x1ad70>
1188d4e3:      	movsd	-0x30(%rbp), %xmm0
1188d4e8:      	jmp	0x1188dbf5 <js_object_get_field_by_name+0x2dd5>
1188d4ed:      	testq	%r12, %r12
1188d4f0:      	jne	0x1188d510 <js_object_get_field_by_name+0x26f0>
1188d4f2:      	xorl	%edi, %edi
1188d4f4:      	callq	0x112a3ca0 <_RNvNtCscI5nJwKNRh4_13perry_runtime6string20string_storage_alloc.llvm.4573768808118376784>
1188d4f9:      	movq	%rax, %r12
1188d4fc:      	xorpd	%xmm0, %xmm0
1188d500:      	movupd	%xmm0, (%rax)
1188d504:      	movapd	-0x70(%rbp), %xmm0
1188d509:      	movl	$0x0, 0x10(%rax)
1188d510:      	andq	%r15, %r12
1188d513:      	movabsq	$0x7fff000000000000, %rax # imm = 0x7FFF000000000000
1188d51d:      	orq	%rax, %r12
1188d520:      	movq	%r12, %xmm1
1188d525:      	callq	*0x3a8e24d(%rip)        # 0x1531b778 <_GLOBAL_OFFSET_TABLE_+0x46f8>
1188d52b:      	jmp	0x1188dbf5 <js_object_get_field_by_name+0x2dd5>
1188d530:      	movq	%r14, %r15
1188d533:      	cmpw	$0x0, -0x40(%rbp)
1188d538:      	je	0x1188d561 <js_object_get_field_by_name+0x2741>
1188d53a:      	cmpl	$0x7ffb, %r12d          # imm = 0x7FFB
1188d541:      	je	0x1188d85e <js_object_get_field_by_name+0x2a3e>
1188d547:      	cmpl	$0x7ffd, %r12d          # imm = 0x7FFD
1188d54e:      	jne	0x1188d88f <js_object_get_field_by_name+0x2a6f>
1188d554:      	movabsq	$0xffffffffffff, %r15   # imm = 0xFFFFFFFFFFFF
1188d55e:      	andq	%r14, %r15
1188d561:      	leaq	-0x100000(%r15), %rax
1188d568:      	movabsq	$0x800000000000, %rcx   # imm = 0x800000000000
1188d572:      	addq	$-0x100000, %rcx        # imm = 0xFFF00000
1188d579:      	cmpq	%rcx, %rax
1188d57c:      	jae	0x1188d88f <js_object_get_field_by_name+0x2a6f>
1188d582:      	cmpb	$0x5, -0x8(%r15)
1188d587:      	jne	0x1188d88f <js_object_get_field_by_name+0x2a6f>
1188d58d:      	movq	%r15, %rdi
1188d590:      	callq	0x1150edd0 <_RNvNtNtCscI5nJwKNRh4_13perry_runtime6buffer6header20is_registered_buffer.llvm.4573768808118376784>
1188d595:      	movdqa	-0x70(%rbp), %xmm0
1188d59a:      	testb	%al, %al
1188d59c:      	jne	0x1188d88f <js_object_get_field_by_name+0x2a6f>
1188d5a2:      	movq	%r15, %rdi
1188d5a5:      	callq	0x111d9170 <_RNvNtCscI5nJwKNRh4_13perry_runtime10typedarray23lookup_typed_array_kind>
1188d5aa:      	movdqa	-0x70(%rbp), %xmm0
1188d5af:      	testb	$0x1, %al
1188d5b1:      	jne	0x1188d88f <js_object_get_field_by_name+0x2a6f>
1188d5b7:      	movq	-0x30(%rbp), %r14
1188d5bb:      	movl	0x4(%r14), %ebx
1188d5bf:      	movq	%r15, %rdi
1188d5c2:      	movl	$0x4, %esi
1188d5c7:      	leaq	0x14(%r14), %rdx
1188d5cb:      	movq	%rbx, %rcx
1188d5ce:      	callq	0x1152a580 <_RNvNtNtCscI5nJwKNRh4_13perry_runtime6object14exotic_expando23exotic_get_own_property>
1188d5d3:      	cmpq	$0x1, %rax
1188d5d7:      	je	0x1188dbf5 <js_object_get_field_by_name+0x2dd5>
1188d5dd:      	leal	-0x4(%rbx), %eax
1188d5e0:      	cmpl	$0x7, %eax
1188d5e3:      	ja	0x1188e184 <js_object_get_field_by_name+0x3364>
1188d5e9:      	leaq	0x2a6e2cc(%rip), %rcx   # 0x142fb8bc <anon.b37f594bd5826585f7e5082f302a037e.11885.llvm.4573768808118376784+0x102a0>
1188d5f0:      	movslq	(%rcx,%rax,4), %rax
1188d5f4:      	addq	%rcx, %rax
1188d5f7:      	jmpq	*%rax
1188d5f9:      	leaq	0x14(%r14), %rax
1188d5fd:      	cmpb	$0x74, (%rax)
1188d600:      	jne	0x1188e184 <js_object_get_field_by_name+0x3364>
1188d606:      	cmpb	$0x68, 0x15(%r14)
1188d60b:      	jne	0x1188e184 <js_object_get_field_by_name+0x3364>
1188d611:      	cmpb	$0x65, 0x16(%r14)
1188d616:      	jne	0x1188e184 <js_object_get_field_by_name+0x3364>
1188d61c:      	movq	-0x30(%rbp), %rax
1188d620:      	cmpb	$0x6e, 0x17(%rax)
1188d624:      	jne	0x1188e184 <js_object_get_field_by_name+0x3364>
1188d62a:      	jmp	0x1188e55e <js_object_get_field_by_name+0x373e>
1188d62f:      	movabsq	$0x7fffffffffffffff, %rcx # imm = 0x7FFFFFFFFFFFFFFF
1188d639:      	andq	%r14, %rcx
1188d63c:      	movabsq	$-0x10000000000000, %rax # imm = 0xFFF0000000000000
1188d646:      	addq	%rcx, %rax
1188d649:      	shrq	$0x35, %rax
1188d64d:      	cmpl	$0x3ff, %eax            # imm = 0x3FF
1188d652:      	setae	%al
1188d655:      	testq	%r14, %r14
1188d658:      	sets	%bl
1188d65b:      	orb	%al, %bl
1188d65d:      	decq	%r14
1188d660:      	movabsq	$0xffffffffffffe, %rax  # imm = 0xFFFFFFFFFFFFE
1188d66a:      	cmpq	%rax, %r14
1188d66d:      	seta	%r14b
1188d671:      	callq	*0x3aa05b9(%rip)        # 0x1532dc30 <_GLOBAL_OFFSET_TABLE_+0x16bb0>
1188d677:      	testb	%bl, %r14b
1188d67a:      	jne	0x1188d717 <js_object_get_field_by_name+0x28f7>
1188d680:      	ucomisd	-0x70(%rbp), %xmm0
1188d685:      	jne	0x1188d717 <js_object_get_field_by_name+0x28f7>
1188d68b:      	jp	0x1188d717 <js_object_get_field_by_name+0x28f7>
1188d691:      	movapd	-0x70(%rbp), %xmm1
1188d696:      	cvttsd2si	%xmm1, %rax
1188d69b:      	movq	%rax, %rcx
1188d69e:      	sarq	$0x3f, %rcx
1188d6a2:      	movapd	%xmm1, %xmm0
1188d6a6:      	subsd	0xde2512(%rip), %xmm0   # 0x1266fbc0 <perry_typed_shape_raw_f64_mask_cli_2_1_112_js____AnonShape_d5b61070a717b2b2+0x8d0>
1188d6ae:      	cvttsd2si	%xmm0, %rdx
1188d6b3:      	andq	%rcx, %rdx
1188d6b6:      	orq	%rax, %rdx
1188d6b9:      	xorl	%eax, %eax
1188d6bb:      	xorpd	%xmm0, %xmm0
1188d6bf:      	ucomisd	%xmm0, %xmm1
1188d6c3:      	cmovaeq	%rdx, %rax
1188d6c7:      	ucomisd	0xde5a01(%rip), %xmm1   # 0x126730d0 <perry_typed_shape_mask_cli_2_1_112_js__fP8+0x30>
1188d6cf:      	movq	$-0x1, %rbx
1188d6d6:      	cmovbeq	%rax, %rbx
1188d6da:      	movq	%rbx, %rax
1188d6dd:      	andq	$-0x100000, %rax        # imm = 0xFFF00000
1188d6e3:      	cmpq	$0x100000, %rax         # imm = 0x100000
1188d6e9:      	jne	0x1188d717 <js_object_get_field_by_name+0x28f7>
1188d6eb:      	leaq	0x55676b6(%rip), %rax   # 0x16df4da8 <_RNvNtNtCscI5nJwKNRh4_13perry_runtime6object13class_handles23STREAM_HANDLE_PROBE_PTR>
1188d6f2:      	movq	(%rax), %rax
1188d6f5:      	testq	%rax, %rax
1188d6f8:      	je	0x1188d717 <js_object_get_field_by_name+0x28f7>
1188d6fa:      	movq	%rbx, %rdi
1188d6fd:      	callq	*%rax
1188d6ff:      	testb	$0x1, %al
1188d701:      	je	0x1188d717 <js_object_get_field_by_name+0x28f7>
1188d703:      	callq	0x1151e160 <_RNvNtNtCscI5nJwKNRh4_13perry_runtime6object13class_handles24handle_property_dispatch>
1188d708:      	testq	%rax, %rax
1188d70b:      	je	0x1188d717 <js_object_get_field_by_name+0x28f7>
1188d70d:      	movl	0x4(%r12), %edx
1188d712:      	jmp	0x1188d975 <js_object_get_field_by_name+0x2b55>
1188d717:      	movl	0x4(%r12), %ebx
1188d71c:      	leaq	-0x58(%rbp), %rdi
1188d720:      	leaq	0x14(%r12), %rsi
1188d725:      	movq	%rbx, %rdx
1188d728:      	callq	*0x3a90142(%rip)        # 0x1531d870 <_GLOBAL_OFFSET_TABLE_+0x67f0>
1188d72e:      	cmpb	$0x0, -0x58(%rbp)
1188d732:      	je	0x1188d9e2 <js_object_get_field_by_name+0x2bc2>
1188d738:      	jmp	0x1188d9fa <js_object_get_field_by_name+0x2bda>
1188d73d:      	cmpl	$0x7ffe, %r12d          # imm = 0x7FFE
1188d744:      	jne	0x1188d88f <js_object_get_field_by_name+0x2a6f>
1188d74a:      	movl	%r14d, -0x34(%rbp)
1188d74e:      	movabsq	$-0xffff00000000, %rax  # imm = 0xFFFF000100000000
1188d758:      	andq	%r14, %rax
1188d75b:      	movabsq	$0x7ffe000100000000, %r12 # imm = 0x7FFE000100000000
1188d765:      	cmpq	%r12, %rax
1188d768:      	setne	%al
1188d76b:      	testl	%r14d, %r14d
1188d76e:      	sete	%cl
1188d771:      	orb	%al, %cl
1188d773:      	movb	$0x1, %bl
1188d775:      	jne	0x1188d785 <js_object_get_field_by_name+0x2965>
1188d777:      	movl	%r14d, %edi
1188d77a:      	callq	*0x3a8dea0(%rip)        # 0x1531b620 <_GLOBAL_OFFSET_TABLE_+0x45a0>
1188d780:      	movl	%eax, %ebx
1188d782:      	xorb	$0x1, %bl
1188d785:      	movq	-0x30(%rbp), %rax
1188d789:      	movl	0x4(%rax), %edx
1188d78c:      	leaq	-0x58(%rbp), %rdi
1188d790:      	leaq	0x14(%rax), %rsi
1188d794:      	movq	%rdx, -0x40(%rbp)
1188d798:      	callq	*0x3a900d2(%rip)        # 0x1531d870 <_GLOBAL_OFFSET_TABLE_+0x67f0>
1188d79e:      	xorl	%r15d, %r15d
1188d7a1:      	cmpb	$0x0, -0x58(%rbp)
1188d7a5:      	movl	$0x1, %r13d
1188d7ab:      	cmoveq	-0x50(%rbp), %r13
1188d7b0:      	cmoveq	-0x48(%rbp), %r15
1188d7b5:      	cmpq	$0xb, %r15
1188d7b9:      	setne	%al
1188d7bc:      	orb	%bl, %al
1188d7be:      	cmpb	$0x1, %al
1188d7c0:      	jne	0x1188dc79 <js_object_get_field_by_name+0x2e59>
1188d7c6:      	cmpq	$0xb, %r15
1188d7ca:      	movdqa	-0x70(%rbp), %xmm0
1188d7cf:      	je	0x1188dcd9 <js_object_get_field_by_name+0x2eb9>
1188d7d5:      	cmpq	$0x9, %r15
1188d7d9:      	jne	0x1188dd11 <js_object_get_field_by_name+0x2ef1>
1188d7df:      	movb	$0x1, %dl
1188d7e1:      	testl	%r14d, %r14d
1188d7e4:      	je	0x1188dd13 <js_object_get_field_by_name+0x2ef3>
1188d7ea:      	movabsq	$0x7079746f746f7270, %rax # imm = 0x7079746F746F7270
1188d7f4:      	xorq	(%r13), %rax
1188d7f8:      	movzbl	0x8(%r13), %ecx
1188d7fd:      	xorq	$0x65, %rcx
1188d801:      	orq	%rax, %rcx
1188d804:      	jne	0x1188dd13 <js_object_get_field_by_name+0x2ef3>
1188d80a:      	movl	%r14d, %edi
1188d80d:      	callq	*0x3a8de0d(%rip)        # 0x1531b620 <_GLOBAL_OFFSET_TABLE_+0x45a0>
1188d813:      	movb	$0x1, %dl
1188d815:      	movdqa	-0x70(%rbp), %xmm0
1188d81a:      	testb	%al, %al
1188d81c:      	je	0x1188dd13 <js_object_get_field_by_name+0x2ef3>
1188d822:      	testb	%bl, %bl
1188d824:      	je	0x1188ddfe <js_object_get_field_by_name+0x2fde>
1188d82a:      	movl	%r14d, %edi
1188d82d:      	callq	0x116ebb20 <_RNvNtNtNtCscI5nJwKNRh4_13perry_runtime6object14class_registry5state26class_decl_prototype_value>
1188d832:      	movq	%xmm0, %r15
1188d837:      	movabsq	$0x7ffc000000000001, %rax # imm = 0x7FFC000000000001
1188d841:      	cmpq	%rax, %r15
1188d844:      	jne	0x1188e18e <js_object_get_field_by_name+0x336e>
1188d84a:      	movl	%r14d, %r15d
1188d84d:      	orq	%r12, %r15
1188d850:      	jmp	0x1188e18e <js_object_get_field_by_name+0x336e>
1188d855:      	cmpl	$0x7ffb, %r12d          # imm = 0x7FFB
1188d85c:      	jne	0x1188d88f <js_object_get_field_by_name+0x2a6f>
1188d85e:      	movq	0x556740b(%rip), %rax   # 0x16df4c70 <_RNvNtNtCscI5nJwKNRh4_13perry_runtime5value4tags29JS_HANDLE_OBJECT_GET_PROPERTY.0>
1188d865:      	movabsq	$0x7ffc000000000001, %r15 # imm = 0x7FFC000000000001
1188d86f:      	testq	%rax, %rax
1188d872:      	movq	-0x30(%rbp), %rcx
1188d876:      	je	0x1188e18e <js_object_get_field_by_name+0x336e>
1188d87c:      	movl	0x4(%rcx), %esi
1188d87f:      	movapd	-0x70(%rbp), %xmm0
1188d884:      	movq	-0x78(%rbp), %rdi
1188d888:      	callq	*%rax
1188d88a:      	jmp	0x1188dbf5 <js_object_get_field_by_name+0x2dd5>
1188d88f:      	movabsq	$0x7fffffffffffffff, %rcx # imm = 0x7FFFFFFFFFFFFFFF
1188d899:      	andq	%r14, %rcx
1188d89c:      	movabsq	$-0x10000000000000, %rax # imm = 0xFFF0000000000000
1188d8a6:      	addq	%rcx, %rax
1188d8a9:      	shrq	$0x35, %rax
1188d8ad:      	cmpl	$0x3ff, %eax            # imm = 0x3FF
1188d8b2:      	setae	%al
1188d8b5:      	testq	%r14, %r14
1188d8b8:      	sets	%bl
1188d8bb:      	orb	%al, %bl
1188d8bd:      	leaq	-0x1(%r14), %rax
1188d8c1:      	movabsq	$0xffffffffffffe, %rcx  # imm = 0xFFFFFFFFFFFFE
1188d8cb:      	cmpq	%rcx, %rax
1188d8ce:      	seta	%r15b
1188d8d2:      	callq	*0x3aa0358(%rip)        # 0x1532dc30 <_GLOBAL_OFFSET_TABLE_+0x16bb0>
1188d8d8:      	testb	%bl, %r15b
1188d8db:      	jne	0x1188d983 <js_object_get_field_by_name+0x2b63>
1188d8e1:      	ucomisd	-0x70(%rbp), %xmm0
1188d8e6:      	jne	0x1188d983 <js_object_get_field_by_name+0x2b63>
1188d8ec:      	jp	0x1188d983 <js_object_get_field_by_name+0x2b63>
1188d8f2:      	movapd	-0x70(%rbp), %xmm1
1188d8f7:      	cvttsd2si	%xmm1, %rax
1188d8fc:      	movq	%rax, %rcx
1188d8ff:      	sarq	$0x3f, %rcx
1188d903:      	movapd	%xmm1, %xmm0
1188d907:      	subsd	0xde22b1(%rip), %xmm0   # 0x1266fbc0 <perry_typed_shape_raw_f64_mask_cli_2_1_112_js____AnonShape_d5b61070a717b2b2+0x8d0>
1188d90f:      	cvttsd2si	%xmm0, %rdx
1188d914:      	andq	%rcx, %rdx
1188d917:      	orq	%rax, %rdx
1188d91a:      	xorl	%eax, %eax
1188d91c:      	xorpd	%xmm0, %xmm0
1188d920:      	ucomisd	%xmm0, %xmm1
1188d924:      	cmovaeq	%rdx, %rax
1188d928:      	ucomisd	0xde57a0(%rip), %xmm1   # 0x126730d0 <perry_typed_shape_mask_cli_2_1_112_js__fP8+0x30>
1188d930:      	movq	$-0x1, %rbx
1188d937:      	cmovbeq	%rax, %rbx
1188d93b:      	movq	%rbx, %rax
1188d93e:      	andq	$-0x100000, %rax        # imm = 0xFFF00000
1188d944:      	cmpq	$0x100000, %rax         # imm = 0x100000
1188d94a:      	jne	0x1188d983 <js_object_get_field_by_name+0x2b63>
1188d94c:      	leaq	0x5567455(%rip), %rax   # 0x16df4da8 <_RNvNtNtCscI5nJwKNRh4_13perry_runtime6object13class_handles23STREAM_HANDLE_PROBE_PTR>
1188d953:      	movq	(%rax), %rax
1188d956:      	testq	%rax, %rax
1188d959:      	je	0x1188d983 <js_object_get_field_by_name+0x2b63>
1188d95b:      	movq	%rbx, %rdi
1188d95e:      	callq	*%rax
1188d960:      	testb	$0x1, %al
1188d962:      	je	0x1188d983 <js_object_get_field_by_name+0x2b63>
1188d964:      	callq	0x1151e160 <_RNvNtNtCscI5nJwKNRh4_13perry_runtime6object13class_handles24handle_property_dispatch>
1188d969:      	testq	%rax, %rax
1188d96c:      	je	0x1188d983 <js_object_get_field_by_name+0x2b63>
1188d96e:      	movq	-0x30(%rbp), %rcx
1188d972:      	movl	0x4(%rcx), %edx
1188d975:      	movq	%rbx, %rdi
1188d978:      	movq	-0x78(%rbp), %rsi
1188d97c:      	callq	*%rax
1188d97e:      	jmp	0x1188dbf5 <js_object_get_field_by_name+0x2dd5>
1188d983:      	cmpq	$0x0, -0x40(%rbp)
1188d988:      	sete	%al
1188d98b:      	movq	%r14, %rcx
1188d98e:      	shrq	$0x34, %rcx
1188d992:      	andl	$0x7ff, %ecx            # imm = 0x7FF
1188d998:      	cmpl	$0x7ff, %ecx            # imm = 0x7FF
1188d99e:      	setae	%cl
1188d9a1:      	orb	%al, %cl
1188d9a3:      	movq	-0x30(%rbp), %r12
1188d9a7:      	je	0x1188d9c5 <js_object_get_field_by_name+0x2ba5>
1188d9a9:      	movq	%r14, %rdi
1188d9ac:      	movq	%r12, %rsi
1188d9af:      	addq	$0xd8, %rsp
1188d9b6:      	popq	%rbx
1188d9b7:      	popq	%r12
1188d9b9:      	popq	%r13
1188d9bb:      	popq	%r14
1188d9bd:      	popq	%r15
1188d9bf:      	popq	%rbp
1188d9c0:      	jmp	0x116b1d80 <_RNvNtNtNtCscI5nJwKNRh4_13perry_runtime6object13field_get_set22get_field_by_name_tail29get_field_by_name_object_tail>
1188d9c5:      	movl	0x4(%r12), %ebx
1188d9ca:      	leaq	-0x58(%rbp), %rdi
1188d9ce:      	leaq	0x14(%r12), %rsi
1188d9d3:      	movq	%rbx, %rdx
1188d9d6:      	callq	*0x3a8fe94(%rip)        # 0x1531d870 <_GLOBAL_OFFSET_TABLE_+0x67f0>
1188d9dc:      	cmpl	$0x1, -0x58(%rbp)
1188d9e0:      	je	0x1188d9fa <js_object_get_field_by_name+0x2bda>
1188d9e2:      	movq	-0x50(%rbp), %rdi
1188d9e6:      	movq	-0x48(%rbp), %rsi
1188d9ea:      	movapd	-0x70(%rbp), %xmm0
1188d9ef:      	callq	0x116bb5f0 <_RNvNtNtNtCscI5nJwKNRh4_13perry_runtime6object13field_get_set9accessors35primitive_object_prototype_accessor>
1188d9f4:      	cmpq	$0x1, %rax
1188d9f8:      	je	0x1188da0b <js_object_get_field_by_name+0x2beb>
1188d9fa:      	movq	%r12, %rdi
1188d9fd:      	movapd	-0x70(%rbp), %xmm0
1188da02:      	callq	0x116bc110 <_RNvNtNtNtCscI5nJwKNRh4_13perry_runtime6object13field_get_set9accessors36primitive_builtin_prototype_property>
1188da07:      	testb	$0x1, %al
1188da09:      	je	0x1188da13 <js_object_get_field_by_name+0x2bf3>
1188da0b:      	movq	%rdx, %r15
1188da0e:      	jmp	0x1188e18e <js_object_get_field_by_name+0x336e>
1188da13:      	movapd	-0x70(%rbp), %xmm0
1188da18:      	movq	-0x78(%rbp), %rdi
1188da1c:      	movq	%rbx, %rsi
1188da1f:      	callq	0x116b8cf0 <_RNvNtNtNtCscI5nJwKNRh4_13perry_runtime6object13field_get_set7ic_miss34bind_primitive_proto_method_static>
1188da24:      	testb	$0x1, %al
1188da26:      	movabsq	$0x7ffc000000000001, %r15 # imm = 0x7FFC000000000001
1188da30:      	cmovneq	%rdx, %r15
1188da34:      	jmp	0x1188e18e <js_object_get_field_by_name+0x336e>
1188da39:      	movq	-0x30(%rbp), %rax
1188da3d:      	movabsq	$0xffffffffffff, %rcx   # imm = 0xFFFFFFFFFFFF
1188da47:      	andq	%rcx, %rax
1188da4a:      	movabsq	$0x7fff000000000000, %rcx # imm = 0x7FFF000000000000
1188da54:      	orq	%rcx, %rax
1188da57:      	movq	%rax, %xmm1
1188da5c:      	movsd	-0x40(%rbp), %xmm0
1188da61:      	movapd	%xmm0, %xmm2
1188da65:      	callq	0x114de5c0 <_RNvNtNtCscI5nJwKNRh4_13perry_runtime5proxy3get23proxy_get_with_receiver>
1188da6a:      	jmp	0x1188dbf5 <js_object_get_field_by_name+0x2dd5>
1188da6f:      	movq	-0x30(%rbp), %r12
1188da73:      	movl	0x4(%r12), %ebx
1188da78:      	movq	%r14, %rdi
1188da7b:      	leaq	0x14(%r12), %rsi
1188da80:      	movq	%rbx, %rdx
1188da83:      	callq	0x116e1f80 <_RNvNtNtNtCscI5nJwKNRh4_13perry_runtime6object14class_registry13parent_static28class_object_own_field_bytes>
1188da88:      	cmpq	$0x1, %rax
1188da8c:      	je	0x1188dbf5 <js_object_get_field_by_name+0x2dd5>
1188da92:      	cmpl	$0x9, %ebx
1188da95:      	movabsq	$0xffffffffffff, %r15   # imm = 0xFFFFFFFFFFFF
1188da9f:      	je	0x1188de7e <js_object_get_field_by_name+0x305e>
1188daa5:      	cmpl	$0x4, %ebx
1188daa8:      	movabsq	$0x7ffd000000000000, %r13 # imm = 0x7FFD000000000000
1188dab2:      	jne	0x1188deab <js_object_get_field_by_name+0x308b>
1188dab8:      	leaq	0x14(%r12), %rax
1188dabd:      	cmpl	$0x656d616e, (%rax)     # imm = 0x656D616E
1188dac3:      	jne	0x1188deab <js_object_get_field_by_name+0x308b>
1188dac9:      	jmp	0x1188df38 <js_object_get_field_by_name+0x3118>
1188dace:      	movl	0x4(%r12), %ebx
1188dad3:      	cmpq	$0xb, %rbx
1188dad7:      	jne	0x1188db1a <js_object_get_field_by_name+0x2cfa>
1188dad9:      	leaq	0x14(%r12), %rdx
1188dade:      	movzwl	0x8(%rdx), %eax
1188dae2:      	movzbl	0xa(%rdx), %ecx
1188dae6:      	shll	$0x10, %ecx
1188dae9:      	orq	%rax, %rcx
1188daec:      	movq	(%rdx), %rax
1188daef:      	movabsq	$0x63757274736e6f63, %rdx # imm = 0x63757274736E6F63
1188daf9:      	xorq	%rdx, %rax
1188dafc:      	xorq	$0x726f74, %rcx         # imm = 0x726F74
1188db03:      	orq	%rax, %rcx
1188db06:      	jne	0x1188db1a <js_object_get_field_by_name+0x2cfa>
1188db08:      	movq	%r13, %rdi
1188db0b:      	callq	0x1129dce0 <_RNvNtCscI5nJwKNRh4_13perry_runtime5timer23timer_constructor_value>
1188db10:      	cmpq	$0x1, %rax
1188db14:      	je	0x1188dbf5 <js_object_get_field_by_name+0x2dd5>
1188db1a:      	leaq	0x14(%r12), %rdi
1188db1f:      	movq	%rbx, %rsi
1188db22:      	callq	0x116b8640 <_RNvNtNtNtCscI5nJwKNRh4_13perry_runtime6object13field_get_set7ic_miss31timer_handle_method_name_static>
1188db27:      	testq	%rax, %rax
1188db2a:      	je	0x1188dbff <js_object_get_field_by_name+0x2ddf>
1188db30:      	movq	%rax, %r15
1188db33:      	movq	%rdx, %r12
1188db36:      	movabsq	$-0x800000000000, %rcx  # imm = 0xFFFF800000000000
1188db40:      	leaq	(%rcx,%r13), %rax
1188db44:      	addq	$0x1000, %rcx           # imm = 0x1000
1188db4b:      	movq	%r13, %rdi
1188db4e:      	cmpq	%rcx, %rax
1188db51:      	jb	0x1188dbaf <js_object_get_field_by_name+0x2d8f>
1188db53:      	leaq	-0x8(%r13), %r14
1188db57:      	movq	%r14, %rdi
1188db5a:      	callq	*0x3a8e490(%rip)        # 0x1531bff0 <_GLOBAL_OFFSET_TABLE_+0x4f70>
1188db60:      	movq	%r13, %rdi
1188db63:      	testb	%al, %al
1188db65:      	je	0x1188dbaf <js_object_get_field_by_name+0x2d8f>
1188db67:      	cmpb	$0xf, (%r14)
1188db6b:      	movq	%r13, %rdi
1188db6e:      	jne	0x1188dbaf <js_object_get_field_by_name+0x2d8f>
1188db70:      	movq	%r13, %rdi
1188db73:      	movabsq	$0x5045525259484e44, %rax # imm = 0x5045525259484E44
1188db7d:      	cmpq	%rax, (%r13)
1188db81:      	jne	0x1188dbaf <js_object_get_field_by_name+0x2d8f>
1188db83:      	testb	$0x1, 0x1c(%r13)
1188db88:      	movq	%r13, %rdi
1188db8b:      	je	0x1188dbaf <js_object_get_field_by_name+0x2d8f>
1188db8d:      	cmpb	$0x0, 0x1b(%r13)
1188db92:      	movq	%r13, %rdi
1188db95:      	jne	0x1188dbaf <js_object_get_field_by_name+0x2d8f>
1188db97:      	addq	$0xbfb09, %rax          # imm = 0xBFB09
1188db9d:      	movq	%r13, %rdi
1188dba0:      	cmpq	%rax, 0x8(%r13)
1188dba4:      	jne	0x1188dbaf <js_object_get_field_by_name+0x2d8f>
1188dba6:      	movq	0x10(%r13), %rdi
1188dbaa:      	testq	%rdi, %rdi
1188dbad:      	jle	0x1188dbff <js_object_get_field_by_name+0x2ddf>
1188dbaf:      	movzbl	0x5567042(%rip), %eax   # 0x16df4bf8 <_RNvNtNtCscI5nJwKNRh4_13perry_runtime5timer10ref_states18TIMER_IDS_NONEMPTY.0>
1188dbb6:      	testb	%al, %al
1188dbb8:      	je	0x1188dbff <js_object_get_field_by_name+0x2ddf>
1188dbba:      	callq	0x114fb1f0 <_RNvNtNtCscI5nJwKNRh4_13perry_runtime5timer10ref_states22is_known_timer_id_slow>
1188dbbf:      	testb	%al, %al
1188dbc1:      	je	0x1188dbff <js_object_get_field_by_name+0x2ddf>
1188dbc3:      	movabsq	$0x7ffd000000000000, %rax # imm = 0x7FFD000000000000
1188dbcd:      	orq	%rax, %r13
1188dbd0:      	movq	%r13, %xmm0
1188dbd5:      	movq	%r15, %rdi
1188dbd8:      	movq	%r12, %rsi
1188dbdb:      	callq	*0x3aa2fe7(%rip)        # 0x15330bc8 <_GLOBAL_OFFSET_TABLE_+0x19b48>
1188dbe1:      	jmp	0x1188dbf5 <js_object_get_field_by_name+0x2dd5>
1188dbe3:      	leaq	0x2a5d7ae(%rip), %rdi   # 0x142eb398 <anon.b37f594bd5826585f7e5082f302a037e.5290.llvm.4573768808118376784+0x1c>
1188dbea:      	movl	$0x4, %esi
1188dbef:      	callq	*0x3a89a9b(%rip)        # 0x15317690 <_GLOBAL_OFFSET_TABLE_+0x610>
1188dbf5:      	movq	%xmm0, %r15
1188dbfa:      	jmp	0x1188e18e <js_object_get_field_by_name+0x336e>
1188dbff:      	movq	%r13, %rdi
1188dc02:      	movq	-0x30(%rbp), %r14
1188dc06:      	leaq	0x14(%r14), %rsi
1188dc0a:      	movq	%rbx, %rdx
1188dc0d:      	callq	0x112825f0 <_RNvNtCscI5nJwKNRh4_13perry_runtime4text20text_handle_property>
1188dc12:      	testb	$0x1, %al
1188dc14:      	jne	0x1188da0b <js_object_get_field_by_name+0x2beb>
1188dc1a:      	cmpl	$0xb, %ebx
1188dc1d:      	jne	0x1188de40 <js_object_get_field_by_name+0x3020>
1188dc23:      	leaq	0x14(%r14), %rdx
1188dc27:      	movzwl	0x8(%rdx), %eax
1188dc2b:      	movzbl	0xa(%rdx), %ecx
1188dc2f:      	shll	$0x10, %ecx
1188dc32:      	orq	%rax, %rcx
1188dc35:      	movabsq	$0x63757274736e6f63, %rax # imm = 0x63757274736E6F63
1188dc3f:      	xorq	(%rdx), %rax
1188dc42:      	xorq	$0x726f74, %rcx         # imm = 0x726F74
1188dc49:      	orq	%rax, %rcx
1188dc4c:      	jne	0x1188de40 <js_object_get_field_by_name+0x3020>
1188dc52:      	movabsq	$0xffffffffffff, %r15   # imm = 0xFFFFFFFFFFFF
1188dc5c:      	addq	$-0x7, %r15
1188dc60:      	andq	0x3a961f9(%rip), %r15   # 0x15323e60 <_GLOBAL_OFFSET_TABLE_+0xcde0>
1188dc67:      	movabsq	$0x7ffd000000000000, %rax # imm = 0x7FFD000000000000
1188dc71:      	orq	%rax, %r15
1188dc74:      	jmp	0x1188e18e <js_object_get_field_by_name+0x336e>
1188dc79:      	testl	%r14d, %r14d
1188dc7c:      	movdqa	-0x70(%rbp), %xmm0
1188dc81:      	je	0x1188dcd9 <js_object_get_field_by_name+0x2eb9>
1188dc83:      	movq	(%r13), %rax
1188dc87:      	movabsq	$0x63757274736e6f63, %rcx # imm = 0x63757274736E6F63
1188dc91:      	xorq	%rcx, %rax
1188dc94:      	movq	0x3(%r13), %rcx
1188dc98:      	movabsq	$0x726f746375727473, %rdx # imm = 0x726F746375727473
1188dca2:      	xorq	%rdx, %rcx
1188dca5:      	orq	%rax, %rcx
1188dca8:      	jne	0x1188dcd9 <js_object_get_field_by_name+0x2eb9>
1188dcaa:      	movl	$0xb, %edx
1188dcaf:      	movl	%r14d, %edi
1188dcb2:      	movq	%r13, %rsi
1188dcb5:      	callq	0x1151fcb0 <_RNvNtNtCscI5nJwKNRh4_13perry_runtime6object13native_module20class_has_own_method>
1188dcba:      	movdqa	-0x70(%rbp), %xmm0
1188dcbf:      	testb	%al, %al
1188dcc1:      	je	0x1188dcd9 <js_object_get_field_by_name+0x2eb9>
1188dcc3:      	movl	$0xb, %edx
1188dcc8:      	movl	%r14d, %edi
1188dccb:      	movq	%r13, %rsi
1188dcce:      	callq	*0x3a9422c(%rip)        # 0x15321f00 <_GLOBAL_OFFSET_TABLE_+0xae80>
1188dcd4:      	jmp	0x1188dbf5 <js_object_get_field_by_name+0x2dd5>
1188dcd9:      	testl	%r14d, %r14d
1188dcdc:      	sete	%al
1188dcdf:      	movq	(%r13), %rcx
1188dce3:      	movabsq	$0x63757274736e6f63, %rdx # imm = 0x63757274736E6F63
1188dced:      	xorq	%rdx, %rcx
1188dcf0:      	movq	0x3(%r13), %rdx
1188dcf4:      	movabsq	$0x726f746375727473, %rsi # imm = 0x726F746375727473
1188dcfe:      	xorq	%rsi, %rdx
1188dd01:      	orq	%rcx, %rdx
1188dd04:      	setne	%cl
1188dd07:      	orb	%bl, %al
1188dd09:      	orb	%cl, %al
1188dd0b:      	je	0x1188ddd7 <js_object_get_field_by_name+0x2fb7>
1188dd11:      	xorl	%edx, %edx
1188dd13:      	testb	%bl, %bl
1188dd15:      	je	0x1188ddf9 <js_object_get_field_by_name+0x2fd9>
1188dd1b:      	testq	%r15, %r15
1188dd1e:      	je	0x1188e1a3 <js_object_get_field_by_name+0x3383>
1188dd24:      	movl	%edx, -0xa8(%rbp)
1188dd2a:      	movl	%r14d, %edi
1188dd2d:      	movq	%r13, %rsi
1188dd30:      	movq	%r15, %rdx
1188dd33:      	callq	0x116eaf70 <_RNvNtNtNtCscI5nJwKNRh4_13perry_runtime6object14class_registry5state20class_is_key_deleted>
1188dd38:      	testb	%al, %al
1188dd3a:      	jne	0x1188e184 <js_object_get_field_by_name+0x3364>
1188dd40:      	leaq	-0x34(%rbp), %rax
1188dd44:      	movq	%rax, -0x58(%rbp)
1188dd48:      	movq	%r13, -0x50(%rbp)
1188dd4c:      	movq	%r15, -0x48(%rbp)
1188dd50:      	movl	0x3ac2862(%rip), %ebx   # 0x153505b8 <_RNvNvNtCscI5nJwKNRh4_13perry_runtime6object19CLASS_DYNAMIC_PROPS4SLOT+0x10>
1188dd56:      	cmpl	$0x300, %ebx            # imm = 0x300
1188dd5c:      	jae	0x1188eb2f <js_object_get_field_by_name+0x3d0f>
1188dd62:      	movq	-0x88(%rbp), %rdi
1188dd69:      	cmpq	$0x0, 0x78(%rdi)
1188dd6e:      	je	0x1188eb11 <js_object_get_field_by_name+0x3cf1>
1188dd74:      	movq	0x1e8(%rdi,%rbx,8), %rsi
1188dd7c:      	testq	%rsi, %rsi
1188dd7f:      	je	0x1188eb2f <js_object_get_field_by_name+0x3d0f>
1188dd85:      	leaq	-0x58(%rbp), %rdi
1188dd89:      	callq	0x111490a0 <_RNCNvNtNtNtCscI5nJwKNRh4_13perry_runtime6object13field_get_set17get_field_by_name27js_object_get_field_by_names_0B9_>
1188dd8e:      	cmpq	$0x1, %rax
1188dd92:      	je	0x1188dbf5 <js_object_get_field_by_name+0x2dd5>
1188dd98:      	cmpq	$0x4, %r15
1188dd9c:      	jne	0x1188e215 <js_object_get_field_by_name+0x33f5>
1188dda2:      	cmpl	$0x656d616e, (%r13)     # imm = 0x656D616E
1188ddaa:      	jne	0x1188e237 <js_object_get_field_by_name+0x3417>
1188ddb0:      	jmp	0x1188e3ad <js_object_get_field_by_name+0x358d>
1188ddb5:      	movq	%rax, %r15
1188ddb8:      	movabsq	$0xffffffffffff, %rax   # imm = 0xFFFFFFFFFFFF
1188ddc2:      	andq	%rax, %r15
1188ddc5:      	movabsq	$0x7fff000000000000, %rax # imm = 0x7FFF000000000000
1188ddcf:      	orq	%rax, %r15
1188ddd2:      	jmp	0x1188e18e <js_object_get_field_by_name+0x336e>
1188ddd7:      	movl	%r14d, %edi
1188ddda:      	callq	*0x3a8d840(%rip)        # 0x1531b620 <_GLOBAL_OFFSET_TABLE_+0x45a0>
1188dde0:      	testb	%al, %al
1188dde2:      	je	0x1188ddfe <js_object_get_field_by_name+0x2fde>
1188dde4:      	movl	%r14d, %eax
1188dde7:      	movabsq	$0x7ffe000000000000, %r15 # imm = 0x7FFE000000000000
1188ddf1:      	orq	%rax, %r15
1188ddf4:      	jmp	0x1188e18e <js_object_get_field_by_name+0x336e>
1188ddf9:      	testl	%r14d, %r14d
1188ddfc:      	je	0x1188de24 <js_object_get_field_by_name+0x3004>
1188ddfe:      	movl	%r14d, %edi
1188de01:      	movq	%r13, %rsi
1188de04:      	movq	%r15, %rdx
1188de07:      	callq	0x1151fcb0 <_RNvNtNtCscI5nJwKNRh4_13perry_runtime6object13native_module20class_has_own_method>
1188de0c:      	testb	%al, %al
1188de0e:      	je	0x1188de24 <js_object_get_field_by_name+0x3004>
1188de10:      	movl	%r14d, %edi
1188de13:      	movq	%r13, %rsi
1188de16:      	movq	%r15, %rdx
1188de19:      	callq	*0x3a940e1(%rip)        # 0x15321f00 <_GLOBAL_OFFSET_TABLE_+0xae80>
1188de1f:      	jmp	0x1188dbf5 <js_object_get_field_by_name+0x2dd5>
1188de24:      	leaq	-0x58(%rbp), %rdi
1188de28:      	callq	0x11183880 <_RNvMs1_NtNtCscI5nJwKNRh4_13perry_runtime6object11class_imageINtB5_10ImageTableINtNtNtNtCsjFfivMnupPH_3std4sync6poison6rwlock6RwLockINtNtCs9ueeiBwVTSo_4core6option6OptionINtNtNtNtB1n_11collections4hash3map7HashMapmNtNtNtB7_14class_registry5state11ClassVTableNtNtB9_9fast_hash9PtrHasherEEEE4readB9_>
1188de2d:      	cmpb	$0x0, -0x58(%rbp)
1188de31:      	je	0x1188e059 <js_object_get_field_by_name+0x3239>
1188de37:      	movq	-0x48(%rbp), %rdi
1188de3b:      	jmp	0x1188e16a <js_object_get_field_by_name+0x334a>
1188de40:      	callq	0x1151e160 <_RNvNtNtCscI5nJwKNRh4_13perry_runtime6object13class_handles24handle_property_dispatch>
1188de45:      	testq	%rax, %rax
1188de48:      	je	0x1188de6e <js_object_get_field_by_name+0x304e>
1188de4a:      	movq	%r13, %rdi
1188de4d:      	leaq	0x14(%r14), %rsi
1188de51:      	movq	%rbx, %rdx
1188de54:      	callq	*%rax
1188de56:      	movq	%xmm0, %r15
1188de5b:      	movabsq	$0x7ffc000000000001, %rax # imm = 0x7FFC000000000001
1188de65:      	cmpq	%rax, %r15
1188de68:      	jne	0x1188e18e <js_object_get_field_by_name+0x336e>
1188de6e:      	movq	%r13, %rdi
1188de71:      	movq	%r14, %rsi
1188de74:      	callq	0x116b0470 <_RNvNtNtNtCscI5nJwKNRh4_13perry_runtime6object13field_get_set17get_field_by_name28handle_proto_inherited_field>
1188de79:      	jmp	0x1188da24 <js_object_get_field_by_name+0x2c04>
1188de7e:      	leaq	0x14(%r12), %rdx
1188de83:      	movzbl	0x8(%rdx), %eax
1188de87:      	movabsq	$0x7079746f746f7270, %rcx # imm = 0x7079746F746F7270
1188de91:      	xorq	(%rdx), %rcx
1188de94:      	xorq	$0x65, %rax
1188de98:      	orq	%rcx, %rax
1188de9b:      	movabsq	$0x7ffd000000000000, %r13 # imm = 0x7FFD000000000000
1188dea5:      	je	0x1188df38 <js_object_get_field_by_name+0x3118>
1188deab:      	leaq	0x2ab8404(%rip), %rsi   # 0x143462b6 <anon.b37f594bd5826585f7e5082f302a037e.12135.llvm.4573768808118376784+0x33f6>
1188deb2:      	movl	$0x14, %edx
1188deb7:      	movq	%r14, %rdi
1188deba:      	callq	0x116e1f80 <_RNvNtNtNtCscI5nJwKNRh4_13perry_runtime6object14class_registry13parent_static28class_object_own_field_bytes>
1188debf:      	cmpq	$0x1, %rax
1188dec3:      	jne	0x1188df38 <js_object_get_field_by_name+0x3118>
1188dec5:      	movq	%xmm0, %rbx
1188deca:      	movabsq	$-0x1000000000000, %rax # imm = 0xFFFF000000000000
1188ded4:      	andq	%rbx, %rax
1188ded7:      	cmpq	%r13, %rax
1188deda:      	jne	0x1188df38 <js_object_get_field_by_name+0x3118>
1188dedc:      	andq	%r15, %rbx
1188dedf:      	cmpq	%r14, %rbx
1188dee2:      	setne	%al
1188dee5:      	cmpq	$0x100000, %rbx         # imm = 0x100000
1188deec:      	setae	%cl
1188deef:      	andb	%al, %cl
1188def1:      	cmpb	$0x1, %cl
1188def4:      	jne	0x1188df38 <js_object_get_field_by_name+0x3118>
1188def6:      	movq	%rbx, %rdi
1188def9:      	callq	*0x3a94fb1(%rip)        # 0x15322eb0 <_GLOBAL_OFFSET_TABLE_+0xbe30>
1188deff:      	movabsq	$0x800000000000, %rcx   # imm = 0x800000000000
1188df09:      	decq	%rcx
1188df0c:      	cmpq	%rcx, %rbx
1188df0f:      	seta	%cl
1188df12:      	orb	%al, %cl
1188df14:      	jne	0x1188df38 <js_object_get_field_by_name+0x3118>
1188df16:      	movq	%rbx, %rdi
1188df19:      	movq	%r12, %rsi
1188df1c:      	callq	*0x3a90ec6(%rip)        # 0x1531ede8 <_GLOBAL_OFFSET_TABLE_+0x7d68>
1188df22:      	movq	%rax, %r15
1188df25:      	movabsq	$0x7ffc000000000001, %rax # imm = 0x7FFC000000000001
1188df2f:      	cmpq	%rax, %r15
1188df32:      	jne	0x1188e18e <js_object_get_field_by_name+0x336e>
1188df38:      	movq	%r14, %rdi
1188df3b:      	movq	%r12, %rsi
1188df3e:      	callq	0x116b1d80 <_RNvNtNtNtCscI5nJwKNRh4_13perry_runtime6object13field_get_set22get_field_by_name_tail29get_field_by_name_object_tail>
1188df43:      	movq	%rax, %r15
1188df46:      	movabsq	$0x7ffc000000000001, %rax # imm = 0x7FFC000000000001
1188df50:      	cmpq	%rax, %r15
1188df53:      	jne	0x1188e18e <js_object_get_field_by_name+0x336e>
1188df59:      	movq	%r14, %rax
1188df5c:      	shrq	$0x34, %rax
1188df60:      	orq	%r14, %r13
1188df63:      	cmpl	$0x7ff, %eax            # imm = 0x7FF
1188df68:      	cmovaeq	%r14, %r13
1188df6c:      	testq	%r14, %r14
1188df6f:      	je	0x1188df77 <js_object_get_field_by_name+0x3157>
1188df71:      	movq	%r13, -0x40(%rbp)
1188df75:      	jmp	0x1188df84 <js_object_get_field_by_name+0x3164>
1188df77:      	movsd	0xdde431(%rip), %xmm0   # 0x1266c3b0 <perry_typed_shape_mask_cli_2_1_112_js___e8__class_expr_17991+0x98>
1188df7f:      	movsd	%xmm0, -0x40(%rbp)
1188df84:      	movq	%r14, %rdi
1188df87:      	callq	*0x3a9ba8b(%rip)        # 0x15329a18 <_GLOBAL_OFFSET_TABLE_+0x12998>
1188df8d:      	testl	%eax, %eax
1188df8f:      	je	0x1188e184 <js_object_get_field_by_name+0x3364>
1188df95:      	movl	%eax, %r15d
1188df98:      	movl	0x4(%r12), %ebx
1188df9d:      	leaq	-0x58(%rbp), %rdi
1188dfa1:      	movq	-0x78(%rbp), %rsi
1188dfa5:      	movq	%rbx, %rdx
1188dfa8:      	callq	*0x3a8f8c2(%rip)        # 0x1531d870 <_GLOBAL_OFFSET_TABLE_+0x67f0>
1188dfae:      	movq	-0x48(%rbp), %r14
1188dfb2:      	testq	%r14, %r14
1188dfb5:      	sete	%al
1188dfb8:      	orb	-0x58(%rbp), %al
1188dfbb:      	jne	0x1188e184 <js_object_get_field_by_name+0x3364>
1188dfc1:      	movq	-0x50(%rbp), %r12
1188dfc5:      	movl	%r15d, %edi
1188dfc8:      	movq	%r12, %rsi
1188dfcb:      	movq	%r14, %rdx
1188dfce:      	callq	0x116eaf70 <_RNvNtNtNtCscI5nJwKNRh4_13perry_runtime6object14class_registry5state20class_is_key_deleted>
1188dfd3:      	testb	%al, %al
1188dfd5:      	jne	0x1188e184 <js_object_get_field_by_name+0x3364>
1188dfdb:      	leaq	-0x58(%rbp), %rdi
1188dfdf:      	movl	%r15d, %esi
1188dfe2:      	movq	%r12, %rdx
1188dfe5:      	movq	%r14, %rcx
1188dfe8:      	callq	0x116e2e30 <_RNvNtNtNtCscI5nJwKNRh4_13perry_runtime6object14class_registry13parent_static29lookup_static_method_in_chain>
1188dfed:      	cmpb	$0x2, -0x4c(%rbp)
1188dff1:      	jne	0x1188e1d6 <js_object_get_field_by_name+0x33b6>
1188dff7:      	movl	%r15d, %edi
1188dffa:      	movq	%r12, %rsi
1188dffd:      	movq	%r14, %rdx
1188e000:      	movsd	-0x40(%rbp), %xmm0
1188e005:      	callq	0x116e3610 <_RNvNtNtNtCscI5nJwKNRh4_13perry_runtime6object14class_registry13parent_static34class_static_accessor_getter_value>
1188e00a:      	cmpq	$0x1, %rax
1188e00e:      	je	0x1188dbf5 <js_object_get_field_by_name+0x2dd5>
1188e014:      	movl	%r15d, %edi
1188e017:      	callq	0x116fd740 <_RNvNtNtNtCscI5nJwKNRh4_13perry_runtime6object14class_registry9construct23promise_parent_in_chain>
1188e01c:      	testb	%al, %al
1188e01e:      	je	0x1188e184 <js_object_get_field_by_name+0x3364>
1188e024:      	leaq	-0x58(%rbp), %rdi
1188e028:      	movq	%r12, %rsi
1188e02b:      	movq	%r14, %rdx
1188e02e:      	callq	0x11692fa0 <_RNvNtNtNtCscI5nJwKNRh4_13perry_runtime6object11global_this14bigint_promise28promise_static_function_spec>
1188e033:      	cmpb	$0x2, -0x48(%rbp)
1188e037:      	movabsq	$0x7ffc000000000001, %r15 # imm = 0x7FFC000000000001
1188e041:      	je	0x1188e18e <js_object_get_field_by_name+0x336e>
1188e047:      	movq	-0x78(%rbp), %rdi
1188e04b:      	movq	%rbx, %rsi
1188e04e:      	callq	*0x3a92d4c(%rip)        # 0x15320da0 <_GLOBAL_OFFSET_TABLE_+0x9d20>
1188e054:      	jmp	0x1188dbf5 <js_object_get_field_by_name+0x2dd5>
1188e059:      	movq	%r15, %rbx
1188e05c:      	movq	-0x50(%rbp), %r15
1188e060:      	movq	-0x48(%rbp), %rdi
1188e064:      	cmpq	$0x0, (%r15)
1188e068:      	je	0x1188e16a <js_object_get_field_by_name+0x334a>
1188e06e:      	movq	%rdi, -0x30(%rbp)
1188e072:      	movl	-0x34(%rbp), %r14d
1188e076:      	xorl	%r12d, %r12d
1188e079:      	cmpq	$0x0, 0x18(%r15)
1188e07e:      	je	0x1188e13a <js_object_get_field_by_name+0x331a>
1188e084:      	movl	%r14d, %edx
1188e087:      	movabsq	$-0x61c8864680b583eb, %rax # imm = 0x9E3779B97F4A7C15
1188e091:      	imulq	%rax, %rdx
1188e095:      	movq	%rdx, %rax
1188e098:      	shrq	$0x20, %rax
1188e09c:      	xorq	%rdx, %rax
1188e09f:      	shrq	$0x39, %rdx
1188e0a3:      	movq	(%r15), %rdi
1188e0a6:      	movq	0x8(%r15), %rcx
1188e0aa:      	movd	%edx, %xmm0
1188e0ae:      	punpcklbw	%xmm0, %xmm0    # xmm0 = xmm0[0,0,1,1,2,2,3,3,4,4,5,5,6,6,7,7]
1188e0b2:      	pshuflw	$0x0, %xmm0, %xmm0      # xmm0 = xmm0[0,0,0,0,4,5,6,7]
1188e0b7:      	pshufd	$0x44, %xmm0, %xmm0     # xmm0 = xmm0[0,1,0,1]
1188e0bc:      	xorl	%edx, %edx
1188e0be:      	andq	%rcx, %rax
1188e0c1:      	movdqu	(%rdi,%rax), %xmm1
1188e0c6:      	movdqa	%xmm1, %xmm2
1188e0ca:      	pcmpeqb	%xmm0, %xmm2
1188e0ce:      	pmovmskb	%xmm2, %esi
1188e0d2:      	testl	%esi, %esi
1188e0d4:      	je	0x1188e102 <js_object_get_field_by_name+0x32e2>
1188e0d6:      	tzcntl	%esi, %r8d
1188e0db:      	addq	%rax, %r8
1188e0de:      	andq	%rcx, %r8
1188e0e1:      	negq	%r8
1188e0e4:      	imulq	$0x98, %r8, %r8
1188e0eb:      	cmpl	-0x98(%rdi,%r8), %r14d
1188e0f3:      	je	0x1188e11f <js_object_get_field_by_name+0x32ff>
1188e0f5:      	leal	-0x1(%rsi), %r8d
1188e0f9:      	andw	%si, %r8w
1188e0fd:      	movl	%r8d, %esi
1188e100:      	jne	0x1188e0d6 <js_object_get_field_by_name+0x32b6>
1188e102:      	pcmpeqd	%xmm2, %xmm2
1188e106:      	pcmpeqb	%xmm2, %xmm1
1188e10a:      	pmovmskb	%xmm1, %esi
1188e10e:      	testl	%esi, %esi
1188e110:      	jne	0x1188e13a <js_object_get_field_by_name+0x331a>
1188e112:      	addq	%rdx, %rax
1188e115:      	addq	$0x10, %rax
1188e119:      	addq	$0x10, %rdx
1188e11d:      	jmp	0x1188e0be <js_object_get_field_by_name+0x329e>
1188e11f:      	addq	%r8, %rdi
1188e122:      	addq	$-0x60, %rdi
1188e126:      	movq	%r13, %rsi
1188e129:      	movq	%rbx, %rdx
1188e12c:      	callq	0x1103cba0 <_RINvMs1_NtCsbuoDnTMY902_9hashbrown3mapINtB6_7HashMapNtNtCscv7DEBI70Kq_5alloc6string6StringjNtNtNtCsjFfivMnupPH_3std4hash6random11RandomStateE3geteECscI5nJwKNRh4_13perry_runtime>
1188e131:      	testq	%rax, %rax
1188e134:      	jne	0x1188e371 <js_object_get_field_by_name+0x3551>
1188e13a:      	movl	%r14d, %edi
1188e13d:      	callq	0x115528f0 <_RNvNtNtCscI5nJwKNRh4_13perry_runtime6object19class_meta_registry19get_parent_class_id.llvm.4573768808118376784>
1188e142:      	testb	$0x1, %al
1188e144:      	je	0x1188e15f <js_object_get_field_by_name+0x333f>
1188e146:      	testl	%edx, %edx
1188e148:      	je	0x1188e15f <js_object_get_field_by_name+0x333f>
1188e14a:      	cmpl	%r14d, %edx
1188e14d:      	je	0x1188e15f <js_object_get_field_by_name+0x333f>
1188e14f:      	incq	%r12
1188e152:      	movl	%edx, %r14d
1188e155:      	cmpq	$0x20, %r12
1188e159:      	jne	0x1188e079 <js_object_get_field_by_name+0x3259>
1188e15f:      	movl	$0xffffffff, %esi       # imm = 0xFFFFFFFF
1188e164:      	movq	-0x30(%rbp), %rdi
1188e168:      	jmp	0x1188e16f <js_object_get_field_by_name+0x334f>
1188e16a:      	movl	$0xffffffff, %esi       # imm = 0xFFFFFFFF
1188e16f:      	lock
1188e170:      	xaddl	%esi, (%rdi)
1188e173:      	decl	%esi
1188e175:      	movl	%esi, %eax
1188e177:      	andl	$0xbfffffff, %eax       # imm = 0xBFFFFFFF
1188e17c:      	negl	%eax
1188e17e:      	jo	0x1188ead0 <js_object_get_field_by_name+0x3cb0>
1188e184:      	movabsq	$0x7ffc000000000001, %r15 # imm = 0x7FFC000000000001
1188e18e:      	movq	%r15, %rax
1188e191:      	addq	$0xd8, %rsp
1188e198:      	popq	%rbx
1188e199:      	popq	%r12
1188e19b:      	popq	%r13
1188e19d:      	popq	%r14
1188e19f:      	popq	%r15
1188e1a1:      	popq	%rbp
1188e1a2:      	retq
1188e1a3:      	movl	%r14d, %edi
1188e1a6:      	movq	%r13, %rsi
1188e1a9:      	xorl	%edx, %edx
1188e1ab:      	callq	0x116e3610 <_RNvNtNtNtCscI5nJwKNRh4_13perry_runtime6object14class_registry13parent_static34class_static_accessor_getter_value>
1188e1b0:      	movabsq	$0x7ffc000000000001, %r15 # imm = 0x7FFC000000000001
1188e1ba:      	cmpq	$0x1, %rax
1188e1be:      	je	0x1188dbf5 <js_object_get_field_by_name+0x2dd5>
1188e1c4:      	jmp	0x1188e18e <js_object_get_field_by_name+0x336e>
1188e1c6:      	testq	%r13, %r13
1188e1c9:      	jle	0x1188e184 <js_object_get_field_by_name+0x3364>
1188e1cb:      	movq	%rbx, %rdi
1188e1ce:      	callq	*0x3aa3c1c(%rip)        # 0x15331df0 <_GLOBAL_OFFSET_TABLE_+0x1ad70>
1188e1d4:      	jmp	0x1188e184 <js_object_get_field_by_name+0x3364>
1188e1d6:      	cmpq	$0x1, %rbx
1188e1da:      	movq	%rbx, %rdi
1188e1dd:      	adcq	$0x0, %rdi
1188e1e1:      	movl	$0x1, %esi
1188e1e6:      	callq	*0x3a8c724(%rip)        # 0x1531a910 <_GLOBAL_OFFSET_TABLE_+0x3890>
1188e1ec:      	movq	%rax, %r14
1188e1ef:      	movq	%rax, %rdi
1188e1f2:      	movq	-0x78(%rbp), %rsi
1188e1f6:      	movq	%rbx, %rdx
1188e1f9:      	callq	*0x3a8eb31(%rip)        # 0x1531cd30 <_GLOBAL_OFFSET_TABLE_+0x5cb0>
1188e1ff:      	movsd	-0x40(%rbp), %xmm0
1188e204:      	movq	%r14, %rdi
1188e207:      	movq	%rbx, %rsi
1188e20a:      	callq	*0x3aa29b8(%rip)        # 0x15330bc8 <_GLOBAL_OFFSET_TABLE_+0x19b48>
1188e210:      	jmp	0x1188dbf5 <js_object_get_field_by_name+0x2dd5>
1188e215:      	cmpq	$0x6, %r15
1188e219:      	jne	0x1188e237 <js_object_get_field_by_name+0x3417>
1188e21b:      	movl	$0x676e656c, %eax       # imm = 0x676E656C
1188e220:      	xorl	(%r13), %eax
1188e224:      	movzwl	0x4(%r13), %ecx
1188e229:      	xorl	$0x6874, %ecx           # imm = 0x6874
1188e22f:      	orl	%eax, %ecx
1188e231:      	je	0x1188e3ad <js_object_get_field_by_name+0x358d>
1188e237:      	movl	$0x20, %r14d
1188e23d:      	movl	-0x34(%rbp), %ebx
1188e240:      	jmp	0x1188e24b <js_object_get_field_by_name+0x342b>
1188e242:      	decq	%r14
1188e245:      	je	0x1188e3ad <js_object_get_field_by_name+0x358d>
1188e24b:      	movq	%r15, %r12
1188e24e:      	movl	%ebx, %edi
1188e250:      	callq	0x116eb740 <_RNvNtNtNtCscI5nJwKNRh4_13perry_runtime6object14class_registry5state22class_static_prototype>
1188e255:      	testq	%rax, %rax
1188e258:      	je	0x1188e27d <js_object_get_field_by_name+0x345d>
1188e25a:      	movq	%rax, %rdi
1188e25d:      	movq	-0x30(%rbp), %rsi
1188e261:      	callq	*0x3a90b81(%rip)        # 0x1531ede8 <_GLOBAL_OFFSET_TABLE_+0x7d68>
1188e267:      	movq	%rax, %r15
1188e26a:      	movabsq	$0x7ffc000000000001, %rax # imm = 0x7FFC000000000001
1188e274:      	cmpq	%rax, %r15
1188e277:      	jne	0x1188e18e <js_object_get_field_by_name+0x336e>
1188e27d:      	movl	%ebx, %edi
1188e27f:      	callq	0x116e7bd0 <_RNvNtNtNtCscI5nJwKNRh4_13perry_runtime6object14class_registry17prototype_objects22class_prototype_object>
1188e284:      	testq	%rax, %rax
1188e287:      	je	0x1188e2ac <js_object_get_field_by_name+0x348c>
1188e289:      	movq	%rax, %rdi
1188e28c:      	movq	-0x30(%rbp), %rsi
1188e290:      	callq	*0x3a90b52(%rip)        # 0x1531ede8 <_GLOBAL_OFFSET_TABLE_+0x7d68>
1188e296:      	movq	%rax, %r15
1188e299:      	movabsq	$0x7ffc000000000001, %rax # imm = 0x7FFC000000000001
1188e2a3:      	cmpq	%rax, %r15
1188e2a6:      	jne	0x1188e18e <js_object_get_field_by_name+0x336e>
1188e2ac:      	movl	%ebx, %edi
1188e2ae:      	callq	0x115528f0 <_RNvNtNtCscI5nJwKNRh4_13perry_runtime6object19class_meta_registry19get_parent_class_id.llvm.4573768808118376784>
1188e2b3:      	cmpl	$0x1, %eax
1188e2b6:      	jne	0x1188e3aa <js_object_get_field_by_name+0x358a>
1188e2bc:      	testl	%edx, %edx
1188e2be:      	je	0x1188e3aa <js_object_get_field_by_name+0x358a>
1188e2c4:      	cmpl	%ebx, %edx
1188e2c6:      	je	0x1188e3aa <js_object_get_field_by_name+0x358a>
1188e2cc:      	movl	%edx, %ebx
1188e2ce:      	movl	%edx, -0xac(%rbp)
1188e2d4:      	movl	%edx, %edi
1188e2d6:      	movq	%r13, %rsi
1188e2d9:      	movq	%r12, %r15
1188e2dc:      	movq	%r12, %rdx
1188e2df:      	callq	0x116eaf70 <_RNvNtNtNtCscI5nJwKNRh4_13perry_runtime6object14class_registry5state20class_is_key_deleted>
1188e2e4:      	testb	%al, %al
1188e2e6:      	jne	0x1188e242 <js_object_get_field_by_name+0x3422>
1188e2ec:      	leaq	-0xac(%rbp), %rax
1188e2f3:      	movq	%rax, -0x58(%rbp)
1188e2f7:      	movq	%r13, -0x50(%rbp)
1188e2fb:      	movq	%r15, -0x48(%rbp)
1188e2ff:      	movl	0x3ac22b2(%rip), %r15d  # 0x153505b8 <_RNvNvNtCscI5nJwKNRh4_13perry_runtime6object19CLASS_DYNAMIC_PROPS4SLOT+0x10>
1188e306:      	cmpl	$0x300, %r15d           # imm = 0x300
1188e30d:      	movq	-0x88(%rbp), %rdi
1188e314:      	jae	0x1188e35f <js_object_get_field_by_name+0x353f>
1188e316:      	cmpq	$0x0, 0x78(%rdi)
1188e31b:      	je	0x1188e345 <js_object_get_field_by_name+0x3525>
1188e31d:      	movq	0x1e8(%rdi,%r15,8), %rsi
1188e325:      	testq	%rsi, %rsi
1188e328:      	je	0x1188e35f <js_object_get_field_by_name+0x353f>
1188e32a:      	leaq	-0x58(%rbp), %rdi
1188e32e:      	callq	0x11148e80 <_RNCNvNtNtNtCscI5nJwKNRh4_13perry_runtime6object13field_get_set17get_field_by_name27js_object_get_field_by_names0_0B9_>
1188e333:      	cmpq	$0x1, %rax
1188e337:      	movq	%r12, %r15
1188e33a:      	jne	0x1188e242 <js_object_get_field_by_name+0x3422>
1188e340:      	jmp	0x1188dbf5 <js_object_get_field_by_name+0x2dd5>
1188e345:      	callq	*0x3a950cd(%rip)        # 0x15323418 <_GLOBAL_OFFSET_TABLE_+0xc398>
1188e34b:      	movq	-0x88(%rbp), %rdi
1188e352:      	movq	0x1e8(%rdi,%r15,8), %rsi
1188e35a:      	testq	%rsi, %rsi
1188e35d:      	jne	0x1188e32a <js_object_get_field_by_name+0x350a>
1188e35f:      	leaq	0x39a31da(%rip), %rdi   # 0x15231540 <_RNvNtCscI5nJwKNRh4_13perry_runtime6object19CLASS_DYNAMIC_PROPS>
1188e366:      	callq	*0x3a9e74c(%rip)        # 0x1532cab8 <_GLOBAL_OFFSET_TABLE_+0x15a38>
1188e36c:      	movq	%rax, %rsi
1188e36f:      	jmp	0x1188e32a <js_object_get_field_by_name+0x350a>
1188e371:      	movaps	-0x70(%rbp), %xmm0
1188e375:      	callq	*(%rax)
1188e377:      	movl	$0xffffffff, %esi       # imm = 0xFFFFFFFF
1188e37c:      	movq	-0x30(%rbp), %rdi
1188e380:      	lock
1188e381:      	xaddl	%esi, (%rdi)
1188e384:      	decl	%esi
1188e386:      	movl	%esi, %eax
1188e388:      	andl	$0xbfffffff, %eax       # imm = 0xBFFFFFFF
1188e38d:      	negl	%eax
1188e38f:      	jno	0x1188dbf5 <js_object_get_field_by_name+0x2dd5>
1188e395:      	movsd	%xmm0, -0x30(%rbp)
1188e39a:      	callq	*0x3a89190(%rip)        # 0x15317530 <_GLOBAL_OFFSET_TABLE_+0x4b0>
1188e3a0:      	movsd	-0x30(%rbp), %xmm0
1188e3a5:      	jmp	0x1188dbf5 <js_object_get_field_by_name+0x2dd5>
1188e3aa:      	movq	%r12, %r15
1188e3ad:      	movl	-0x34(%rbp), %esi
1188e3b0:      	leaq	-0x58(%rbp), %rdi
1188e3b4:      	movq	%r13, %rdx
1188e3b7:      	movq	%r15, %rcx
1188e3ba:      	callq	0x116e2e30 <_RNvNtNtNtCscI5nJwKNRh4_13perry_runtime6object14class_registry13parent_static29lookup_static_method_in_chain>
1188e3bf:      	cmpb	$0x2, -0x4c(%rbp)
1188e3c3:      	jne	0x1188e45c <js_object_get_field_by_name+0x363c>
1188e3c9:      	movq	%r15, %r14
1188e3cc:      	movl	-0x34(%rbp), %edi
1188e3cf:      	callq	0x116fd740 <_RNvNtNtNtCscI5nJwKNRh4_13perry_runtime6object14class_registry9construct23promise_parent_in_chain>
1188e3d4:      	testb	%al, %al
1188e3d6:      	je	0x1188e417 <js_object_get_field_by_name+0x35f7>
1188e3d8:      	leaq	-0x58(%rbp), %rdi
1188e3dc:      	movq	%r13, %rsi
1188e3df:      	movq	%r14, %rdx
1188e3e2:      	callq	0x11692fa0 <_RNvNtNtNtCscI5nJwKNRh4_13perry_runtime6object11global_this14bigint_promise28promise_static_function_spec>
1188e3e7:      	cmpb	$0x2, -0x48(%rbp)
1188e3eb:      	je	0x1188e417 <js_object_get_field_by_name+0x35f7>
1188e3ed:      	movq	-0x30(%rbp), %rax
1188e3f1:      	leaq	0x14(%rax), %rdi
1188e3f5:      	movq	-0x40(%rbp), %rsi
1188e3f9:      	callq	*0x3a929a1(%rip)        # 0x15320da0 <_GLOBAL_OFFSET_TABLE_+0x9d20>
1188e3ff:      	movq	%xmm0, %r15
1188e404:      	movabsq	$0x7ffc000000000001, %rax # imm = 0x7FFC000000000001
1188e40e:      	cmpq	%rax, %r15
1188e411:      	jne	0x1188e18e <js_object_get_field_by_name+0x336e>
1188e417:      	movl	-0x34(%rbp), %edi
1188e41a:      	movq	%r13, %rsi
1188e41d:      	movq	%r14, %r15
1188e420:      	movq	%r14, %rdx
1188e423:      	movdqa	-0x70(%rbp), %xmm0
1188e428:      	callq	0x116e3610 <_RNvNtNtNtCscI5nJwKNRh4_13perry_runtime6object14class_registry13parent_static34class_static_accessor_getter_value>
1188e42d:      	testb	$0x1, %al
1188e42f:      	jne	0x1188dbf5 <js_object_get_field_by_name+0x2dd5>
1188e435:      	movabsq	$-0x7ffc000000000003, %rbx # imm = 0x8003FFFFFFFFFFFD
1188e43f:      	cmpq	$0x4, %r15
1188e443:      	jne	0x1188e689 <js_object_get_field_by_name+0x3869>
1188e449:      	cmpl	$0x656d616e, (%r13)     # imm = 0x656D616E
1188e451:      	jne	0x1188e6a7 <js_object_get_field_by_name+0x3887>
1188e457:      	jmp	0x1188e6d2 <js_object_get_field_by_name+0x38b2>
1188e45c:      	movq	-0x40(%rbp), %r14
1188e460:      	cmpq	$0x1, %r14
1188e464:      	movq	%r14, %rdi
1188e467:      	adcq	$0x0, %rdi
1188e46b:      	movl	$0x1, %esi
1188e470:      	callq	*0x3a8c49a(%rip)        # 0x1531a910 <_GLOBAL_OFFSET_TABLE_+0x3890>
1188e476:      	movq	%rax, %rbx
1188e479:      	movq	%rax, %rdi
1188e47c:      	movq	-0x78(%rbp), %rsi
1188e480:      	movq	%r14, %rdx
1188e483:      	callq	*0x3a8e8a7(%rip)        # 0x1531cd30 <_GLOBAL_OFFSET_TABLE_+0x5cb0>
1188e489:      	movaps	-0x70(%rbp), %xmm0
1188e48d:      	movq	%rbx, %rdi
1188e490:      	movq	%r14, %rsi
1188e493:      	callq	*0x3aa272f(%rip)        # 0x15330bc8 <_GLOBAL_OFFSET_TABLE_+0x19b48>
1188e499:      	jmp	0x1188dbf5 <js_object_get_field_by_name+0x2dd5>
1188e49e:      	leaq	0x39902c3(%rip), %rdi   # 0x1521e768 <anon.b37f594bd5826585f7e5082f302a037e.644.llvm.4573768808118376784>
1188e4a5:      	callq	*0x3a9db75(%rip)        # 0x1532c020 <_GLOBAL_OFFSET_TABLE_+0x14fa0>
1188e4ab:      	callq	*0x3a8b71f(%rip)        # 0x15319bd0 <_GLOBAL_OFFSET_TABLE_+0x2b50>
1188e4b1:      	leaq	0x2a6f5c4(%rip), %rdi   # 0x142fda7c <anon.b37f594bd5826585f7e5082f302a037e.395.llvm.4573768808118376784+0x740>
1188e4b8:      	movl	$0xb, %esi
1188e4bd:      	callq	*0x3a96aed(%rip)        # 0x15324fb0 <_GLOBAL_OFFSET_TABLE_+0xdf30>
1188e4c3:      	leaq	0x14(%r14), %rax
1188e4c7:      	cmpb	$0x66, (%rax)
1188e4ca:      	jne	0x1188e184 <js_object_get_field_by_name+0x3364>
1188e4d0:      	cmpb	$0x69, 0x15(%r14)
1188e4d5:      	jne	0x1188e184 <js_object_get_field_by_name+0x3364>
1188e4db:      	cmpb	$0x6e, 0x16(%r14)
1188e4e0:      	jne	0x1188e184 <js_object_get_field_by_name+0x3364>
1188e4e6:      	movq	-0x30(%rbp), %rax
1188e4ea:      	cmpb	$0x61, 0x17(%rax)
1188e4ee:      	jne	0x1188e184 <js_object_get_field_by_name+0x3364>
1188e4f4:      	movq	-0x30(%rbp), %rax
1188e4f8:      	cmpb	$0x6c, 0x18(%rax)
1188e4fc:      	jne	0x1188e184 <js_object_get_field_by_name+0x3364>
1188e502:      	movq	-0x30(%rbp), %rax
1188e506:      	cmpb	$0x6c, 0x19(%rax)
1188e50a:      	jne	0x1188e184 <js_object_get_field_by_name+0x3364>
1188e510:      	movq	-0x30(%rbp), %rax
1188e514:      	cmpb	$0x79, 0x1a(%rax)
1188e518:      	je	0x1188e55e <js_object_get_field_by_name+0x373e>
1188e51a:      	jmp	0x1188e184 <js_object_get_field_by_name+0x3364>
1188e51f:      	leaq	0x14(%r14), %rax
1188e523:      	cmpb	$0x63, (%rax)
1188e526:      	jne	0x1188e184 <js_object_get_field_by_name+0x3364>
1188e52c:      	cmpb	$0x61, 0x15(%r14)
1188e531:      	jne	0x1188e184 <js_object_get_field_by_name+0x3364>
1188e537:      	cmpb	$0x74, 0x16(%r14)
1188e53c:      	jne	0x1188e184 <js_object_get_field_by_name+0x3364>
1188e542:      	movq	-0x30(%rbp), %rax
1188e546:      	cmpb	$0x63, 0x17(%rax)
1188e54a:      	jne	0x1188e184 <js_object_get_field_by_name+0x3364>
1188e550:      	movq	-0x30(%rbp), %rax
1188e554:      	cmpb	$0x68, 0x18(%rax)
1188e558:      	jne	0x1188e184 <js_object_get_field_by_name+0x3364>
1188e55e:      	movq	-0x78(%rbp), %rsi
1188e562:      	movq	%rbx, %rdx
1188e565:      	callq	*0x3a92f7d(%rip)        # 0x153214e8 <_GLOBAL_OFFSET_TABLE_+0xa468>
1188e56b:      	movabsq	$0x7ffc000000000001, %r15 # imm = 0x7FFC000000000001
1188e575:      	cmpq	$0x1, %rax
1188e579:      	je	0x1188dbf5 <js_object_get_field_by_name+0x2dd5>
1188e57f:      	jmp	0x1188e18e <js_object_get_field_by_name+0x336e>
1188e584:      	movq	-0x78(%rbp), %rdx
1188e588:      	movzwl	0x8(%rdx), %eax
1188e58c:      	movzbl	0xa(%rdx), %ecx
1188e590:      	shll	$0x10, %ecx
1188e593:      	movabsq	$0x63757274736e6f63, %rsi # imm = 0x63757274736E6F63
1188e59d:      	xorq	(%rdx), %rsi
1188e5a0:      	orq	%rax, %rcx
1188e5a3:      	xorq	$0x726f74, %rcx         # imm = 0x726F74
1188e5aa:      	orq	%rsi, %rcx
1188e5ad:      	movabsq	$0x7ffc000000000001, %r15 # imm = 0x7FFC000000000001
1188e5b7:      	jne	0x1188e18e <js_object_get_field_by_name+0x336e>
1188e5bd:      	leaq	0x2a96a21(%rip), %rdi   # 0x14324fe5 <anon.b37f594bd5826585f7e5082f302a037e.7425.llvm.4573768808118376784+0x1b9>
1188e5c4:      	movl	$0x7, %esi
1188e5c9:      	jmp	0x1188dbef <js_object_get_field_by_name+0x2dcf>
1188e5ce:      	movq	%rbx, %rdi
1188e5d1:      	callq	*0x3a96af9(%rip)        # 0x153250d0 <_GLOBAL_OFFSET_TABLE_+0xe050>
1188e5d7:      	jmp	0x1188e5e2 <js_object_get_field_by_name+0x37c2>
1188e5d9:      	movq	%rbx, %rdi
1188e5dc:      	callq	*0x3a92676(%rip)        # 0x15320c58 <_GLOBAL_OFFSET_TABLE_+0x9bd8>
1188e5e2:      	movq	-0x90(%rbp), %rcx
1188e5e9:      	cmpq	$0x0, (%rcx)
1188e5ed:      	jne	0x1188e67c <js_object_get_field_by_name+0x385c>
1188e5f3:      	movl	%eax, %eax
1188e5f5:      	xorps	%xmm0, %xmm0
1188e5f8:      	cvtsi2sd	%rax, %xmm0
1188e5fd:      	movq	%xmm0, %r15
1188e602:      	cmpq	0x18(%rcx), %r12
1188e606:      	ja	0x1188e18e <js_object_get_field_by_name+0x336e>
1188e60c:      	movq	%r12, 0x18(%rcx)
1188e610:      	jmp	0x1188e18e <js_object_get_field_by_name+0x336e>
1188e615:      	movl	%ecx, %eax
1188e617:      	xorps	%xmm0, %xmm0
1188e61a:      	cvtsi2sd	%rax, %xmm0
1188e61f:      	jmp	0x1188dbf5 <js_object_get_field_by_name+0x2dd5>
1188e624:      	movq	%r13, %rdi
1188e627:      	callq	0x1150a140 <_RNvNtNtCscI5nJwKNRh4_13perry_runtime6buffer4view10backing_of>
1188e62c:      	movq	%rax, %rdi
1188e62f:      	callq	*0x3a9eecb(%rip)        # 0x1532d500 <_GLOBAL_OFFSET_TABLE_+0x16480>
1188e635:      	testq	%rax, %rax
1188e638:      	je	0x1188e860 <js_object_get_field_by_name+0x3a40>
1188e63e:      	movq	%rax, %r15
1188e641:      	shrq	$0x34, %rax
1188e645:      	cmpl	$0x7fe, %eax            # imm = 0x7FE
1188e64a:      	ja	0x1188e18e <js_object_get_field_by_name+0x336e>
1188e650:      	movabsq	$0xffffffffffff, %rax   # imm = 0xFFFFFFFFFFFF
1188e65a:      	andq	%rax, %r15
1188e65d:      	jmp	0x1188dc67 <js_object_get_field_by_name+0x2e47>
1188e662:      	leaq	0x3990de7(%rip), %rdi   # 0x1521f450 <anon.b37f594bd5826585f7e5082f302a037e.932.llvm.4573768808118376784>
1188e669:      	callq	*0x3a9d9b1(%rip)        # 0x1532c020 <_GLOBAL_OFFSET_TABLE_+0x14fa0>
1188e66f:      	leaq	0x3990df2(%rip), %rdi   # 0x1521f468 <anon.b37f594bd5826585f7e5082f302a037e.933.llvm.4573768808118376784>
1188e676:      	callq	*0x3a9cd74(%rip)        # 0x1532b3f0 <_GLOBAL_OFFSET_TABLE_+0x14370>
1188e67c:      	leaq	0x399c9ed(%rip), %rdi   # 0x1522b070 <anon.b37f594bd5826585f7e5082f302a037e.3973.llvm.4573768808118376784>
1188e683:      	callq	*0x3a9cd67(%rip)        # 0x1532b3f0 <_GLOBAL_OFFSET_TABLE_+0x14370>
1188e689:      	cmpq	$0x6, %r15
1188e68d:      	jne	0x1188e6a7 <js_object_get_field_by_name+0x3887>
1188e68f:      	movl	$0x676e656c, %eax       # imm = 0x676E656C
1188e694:      	xorl	(%r13), %eax
1188e698:      	movzwl	0x4(%r13), %ecx
1188e69d:      	xorl	$0x6874, %ecx           # imm = 0x6874
1188e6a3:      	orl	%eax, %ecx
1188e6a5:      	je	0x1188e6d2 <js_object_get_field_by_name+0x38b2>
1188e6a7:      	movl	-0x34(%rbp), %edi
1188e6aa:      	movq	-0x30(%rbp), %rsi
1188e6ae:      	xorl	%edx, %edx
1188e6b0:      	movl	$0x1, %ecx
1188e6b5:      	callq	0x116e8b00 <_RNvNtNtNtCscI5nJwKNRh4_13perry_runtime6object14class_registry17prototype_objects31resolve_proto_chain_field_inner>
1188e6ba:      	movq	%rdx, %r15
1188e6bd:      	movq	%rdx, %rcx
1188e6c0:      	addq	%rbx, %rcx
1188e6c3:      	cmpq	$-0x2, %rcx
1188e6c7:      	setb	%cl
1188e6ca:      	testb	%al, %cl
1188e6cc:      	jne	0x1188e18e <js_object_get_field_by_name+0x336e>
1188e6d2:      	movl	-0x34(%rbp), %edi
1188e6d5:      	callq	0x116eb210 <_RNvNtNtNtCscI5nJwKNRh4_13perry_runtime6object14class_registry5state20class_parent_closure>
1188e6da:      	cmpq	$0x1, %rax
1188e6de:      	jne	0x1188e706 <js_object_get_field_by_name+0x38e6>
1188e6e0:      	movq	%rdx, %rdi
1188e6e3:      	movq	%r13, %rsi
1188e6e6:      	movq	%r14, %rdx
1188e6e9:      	callq	*0x3a8a891(%rip)        # 0x15318f80 <_GLOBAL_OFFSET_TABLE_+0x1f00>
1188e6ef:      	movq	%xmm0, %r15
1188e6f4:      	leaq	(%rbx,%r15), %rax
1188e6f8:      	addq	$0x2, %rax
1188e6fc:      	cmpq	$0x1, %rax
1188e700:      	ja	0x1188e18e <js_object_get_field_by_name+0x336e>
1188e706:      	cmpq	$0x4, %r14
1188e70a:      	jne	0x1188e872 <js_object_get_field_by_name+0x3a52>
1188e710:      	cmpl	$0x656d616e, (%r13)     # imm = 0x656D616E
1188e718:      	setne	%al
1188e71b:      	movl	-0x34(%rbp), %edi
1188e71e:      	testl	%edi, %edi
1188e720:      	sete	%cl
1188e723:      	orb	%al, %cl
1188e725:      	jne	0x1188e8d0 <js_object_get_field_by_name+0x3ab0>
1188e72b:      	movl	$0x4, %edx
1188e730:      	movq	%r13, %rsi
1188e733:      	callq	0x116eaf70 <_RNvNtNtNtCscI5nJwKNRh4_13perry_runtime6object14class_registry5state20class_is_key_deleted>
1188e738:      	testb	%al, %al
1188e73a:      	jne	0x1188e8d0 <js_object_get_field_by_name+0x3ab0>
1188e740:      	movl	-0x34(%rbp), %esi
1188e743:      	leaq	-0x58(%rbp), %rdi
1188e747:      	callq	*0x3a9c1eb(%rip)        # 0x1532a938 <_GLOBAL_OFFSET_TABLE_+0x138b8>
1188e74d:      	movq	-0x58(%rbp), %r12
1188e751:      	cmpq	$-0x1, %r12
1188e755:      	je	0x1188e8d0 <js_object_get_field_by_name+0x3ab0>
1188e75b:      	movq	-0x50(%rbp), %rbx
1188e75f:      	movl	-0x48(%rbp), %edx
1188e762:      	movq	%rbx, %rdi
1188e765:      	movl	%edx, %esi
1188e767:      	callq	*0x3a8db3b(%rip)        # 0x1531c2a8 <_GLOBAL_OFFSET_TABLE_+0x5228>
1188e76d:      	movq	%rax, %r15
1188e770:      	testq	%rax, %rax
1188e773:      	jne	0x1188e78e <js_object_get_field_by_name+0x396e>
1188e775:      	xorl	%edi, %edi
1188e777:      	callq	0x112a3ca0 <_RNvNtCscI5nJwKNRh4_13perry_runtime6string20string_storage_alloc.llvm.4573768808118376784>
1188e77c:      	movq	%rax, %r15
1188e77f:      	pxor	%xmm0, %xmm0
1188e783:      	movdqu	%xmm0, (%rax)
1188e787:      	movl	$0x0, 0x10(%rax)
1188e78e:      	movabsq	$0xffffffffffff, %rax   # imm = 0xFFFFFFFFFFFF
1188e798:      	andq	%rax, %r15
1188e79b:      	testq	%r12, %r12
1188e79e:      	je	0x1188ddc5 <js_object_get_field_by_name+0x2fa5>
1188e7a4:      	movq	%rbx, %rdi
1188e7a7:      	callq	*0x3aa3643(%rip)        # 0x15331df0 <_GLOBAL_OFFSET_TABLE_+0x1ad70>
1188e7ad:      	jmp	0x1188ddc5 <js_object_get_field_by_name+0x2fa5>
1188e7b2:      	movq	%r13, %rdi
1188e7b5:      	callq	*0x3a99cfd(%rip)        # 0x153284b8 <_GLOBAL_OFFSET_TABLE_+0x11438>
1188e7bb:      	movl	%eax, %eax
1188e7bd:      	xorps	%xmm0, %xmm0
1188e7c0:      	cvtsi2sd	%rax, %xmm0
1188e7c5:      	jmp	0x1188dbf5 <js_object_get_field_by_name+0x2dd5>
1188e7ca:      	movq	%r13, %rdi
1188e7cd:      	callq	0x11508640 <_RNvNtNtCscI5nJwKNRh4_13perry_runtime6buffer11exotic_view26is_non_indexed_buffer_view>
1188e7d2:      	movabsq	$0x7ffc000000000001, %r15 # imm = 0x7FFC000000000001
1188e7dc:      	testb	%al, %al
1188e7de:      	jne	0x1188e18e <js_object_get_field_by_name+0x336e>
1188e7e4:      	movq	%r13, %rax
1188e7e7:      	shrq	$0x33, %rax
1188e7eb:      	movabsq	$0xffffffffffff, %rcx   # imm = 0xFFFFFFFFFFFF
1188e7f5:      	andq	%r13, %rcx
1188e7f8:      	cmpl	$0xfff, %eax            # imm = 0xFFF
1188e7fd:      	cmovbq	%r13, %rcx
1188e801:      	cmpq	$0x1000, %rcx           # imm = 0x1000
1188e808:      	jae	0x1188e9d1 <js_object_get_field_by_name+0x3bb1>
1188e80e:      	xorl	%r15d, %r15d
1188e811:      	jmp	0x1188e18e <js_object_get_field_by_name+0x336e>
1188e816:      	movl	-0x40(%rbp), %eax
1188e819:      	cmpl	$0x3, %eax
1188e81c:      	movl	$0x2, %ebx
1188e821:      	cmovael	%eax, %ebx
1188e824:      	xorl	%ecx, %ecx
1188e826:      	cmpl	%ebx, %edx
1188e828:      	setb	%cl
1188e82b:      	movq	%r13, %rdi
1188e82e:      	movq	-0x30(%rbp), %rsi
1188e832:      	movl	%edx, %r14d
1188e835:      	callq	0x116b0290 <_RNvNtNtNtCscI5nJwKNRh4_13perry_runtime6object13field_get_set17get_field_by_name15prime_read_stub>
1188e83a:      	movl	%r14d, %esi
1188e83d:      	cmpl	%ebx, %r14d
1188e840:      	jae	0x1188ea1e <js_object_get_field_by_name+0x3bfe>
1188e846:      	movq	%r13, %rdi
1188e849:      	addq	$0xd8, %rsp
1188e850:      	popq	%rbx
1188e851:      	popq	%r12
1188e853:      	popq	%r13
1188e855:      	popq	%r14
1188e857:      	popq	%r15
1188e859:      	popq	%rbp
1188e85a:      	jmpq	*0x3a9d968(%rip)        # 0x1532c1c8 <_GLOBAL_OFFSET_TABLE_+0x15148>
1188e860:      	movabsq	$0x7ffc000000000001, %r15 # imm = 0x7FFC000000000001
1188e86a:      	incq	%r15
1188e86d:      	jmp	0x1188e18e <js_object_get_field_by_name+0x336e>
1188e872:      	cmpq	$0x6, %r14
1188e876:      	jne	0x1188e8d0 <js_object_get_field_by_name+0x3ab0>
1188e878:      	movl	$0x676e656c, %eax       # imm = 0x676E656C
1188e87d:      	xorl	(%r13), %eax
1188e881:      	movzwl	0x4(%r13), %ecx
1188e886:      	xorl	$0x6874, %ecx           # imm = 0x6874
1188e88c:      	orl	%eax, %ecx
1188e88e:      	setne	%al
1188e891:      	movl	-0x34(%rbp), %edi
1188e894:      	testl	%edi, %edi
1188e896:      	sete	%cl
1188e899:      	orb	%al, %cl
1188e89b:      	movb	$0x1, %bl
1188e89d:      	cmpb	$0x1, %cl
1188e8a0:      	je	0x1188e8d2 <js_object_get_field_by_name+0x3ab2>
1188e8a2:      	movl	$0x6, %edx
1188e8a7:      	movq	%r13, %rsi
1188e8aa:      	callq	0x116eaf70 <_RNvNtNtNtCscI5nJwKNRh4_13perry_runtime6object14class_registry5state20class_is_key_deleted>
1188e8af:      	testb	%al, %al
1188e8b1:      	jne	0x1188e8d2 <js_object_get_field_by_name+0x3ab2>
1188e8b3:      	movl	-0x34(%rbp), %edi
1188e8b6:      	callq	*0x3a966a4(%rip)        # 0x15324f60 <_GLOBAL_OFFSET_TABLE_+0xdee0>
1188e8bc:      	cmpl	$0x1, %eax
1188e8bf:      	jne	0x1188e8d2 <js_object_get_field_by_name+0x3ab2>
1188e8c1:      	movl	%edx, %eax
1188e8c3:      	xorps	%xmm0, %xmm0
1188e8c6:      	cvtsi2sd	%rax, %xmm0
1188e8cb:      	jmp	0x1188dbf5 <js_object_get_field_by_name+0x2dd5>
1188e8d0:      	xorl	%ebx, %ebx
1188e8d2:      	movq	%r13, %rdi
1188e8d5:      	movq	%r14, %rsi
1188e8d8:      	callq	0x116ae460 <_RNvNtNtNtCscI5nJwKNRh4_13perry_runtime6object13field_get_set12has_property28reified_function_method_name>
1188e8dd:      	testq	%rax, %rax
1188e8e0:      	je	0x1188e903 <js_object_get_field_by_name+0x3ae3>
1188e8e2:      	movaps	-0x70(%rbp), %xmm0
1188e8e6:      	movq	%rax, %rdi
1188e8e9:      	movq	%rdx, %rsi
1188e8ec:      	callq	0x1172a1c0 <_RNvNtNtNtCscI5nJwKNRh4_13perry_runtime7closure8dispatch5bound27reify_function_method_value>
1188e8f1:      	jmp	0x1188dbf5 <js_object_get_field_by_name+0x2dd5>
1188e8f6:      	leaq	0x398edb3(%rip), %rdi   # 0x1521d6b0 <anon.b37f594bd5826585f7e5082f302a037e.196.llvm.4573768808118376784>
1188e8fd:      	callq	*0x3a928bd(%rip)        # 0x153211c0 <_GLOBAL_OFFSET_TABLE_+0xa140>
1188e903:      	testb	%bl, %bl
1188e905:      	je	0x1188e923 <js_object_get_field_by_name+0x3b03>
1188e907:      	movl	$0x6c6c6163, %eax       # imm = 0x6C6C6163
1188e90c:      	xorl	(%r13), %eax
1188e910:      	movzwl	0x4(%r13), %ecx
1188e915:      	xorl	$0x7265, %ecx           # imm = 0x7265
1188e91b:      	orl	%eax, %ecx
1188e91d:      	je	0x1188ec15 <js_object_get_field_by_name+0x3df5>
1188e923:      	cmpb	$0x0, -0xa8(%rbp)
1188e92a:      	je	0x1188e947 <js_object_get_field_by_name+0x3b27>
1188e92c:      	leaq	0x2a6f27b(%rip), %rsi   # 0x142fdbae <anon.b37f594bd5826585f7e5082f302a037e.395.llvm.4573768808118376784+0x872>
1188e933:      	movq	%r13, %rdi
1188e936:      	movq	%r14, %rdx
1188e939:      	callq	*0x3a95b91(%rip)        # 0x153244d0 <_GLOBAL_OFFSET_TABLE_+0xd450>
1188e93f:      	testl	%eax, %eax
1188e941:      	je	0x1188ec15 <js_object_get_field_by_name+0x3df5>
1188e947:      	cmpq	$0xb, %r14
1188e94b:      	jne	0x1188e184 <js_object_get_field_by_name+0x3364>
1188e951:      	movabsq	$0x63757274736e6f63, %rax # imm = 0x63757274736E6F63
1188e95b:      	xorq	(%r13), %rax
1188e95f:      	movabsq	$0x726f746375727473, %rcx # imm = 0x726F746375727473
1188e969:      	xorq	0x3(%r13), %rcx
1188e96d:      	orq	%rax, %rcx
1188e970:      	setne	%al
1188e973:      	movl	-0x34(%rbp), %edi
1188e976:      	testl	%edi, %edi
1188e978:      	sete	%cl
1188e97b:      	orb	%al, %cl
1188e97d:      	jne	0x1188e184 <js_object_get_field_by_name+0x3364>
1188e983:      	callq	*0x3a8cc97(%rip)        # 0x1531b620 <_GLOBAL_OFFSET_TABLE_+0x45a0>
1188e989:      	movabsq	$0x7ffc000000000001, %r15 # imm = 0x7FFC000000000001
1188e993:      	testb	%al, %al
1188e995:      	je	0x1188e18e <js_object_get_field_by_name+0x336e>
1188e99b:      	leaq	0xde4be6(%rip), %rdi    # 0x12673588 <anon.6caf4f70f73897e5f37d36d35ee47d16.255.llvm.15844591618349634503+0x3e8>
1188e9a2:      	movl	$0x8, %esi
1188e9a7:      	jmp	0x1188dbef <js_object_get_field_by_name+0x2dcf>
1188e9ac:      	movabsq	$0x7ffc000000000001, %r15 # imm = 0x7FFC000000000001
1188e9b6:      	movabsq	$0x7ffd000000000000, %rcx # imm = 0x7FFD000000000000
1188e9c0:      	cmpq	%rcx, %rax
1188e9c3:      	je	0x1188e18e <js_object_get_field_by_name+0x336e>
1188e9c9:      	movq	%rax, %r15
1188e9cc:      	jmp	0x1188e18e <js_object_get_field_by_name+0x336e>
1188e9d1:      	xorps	%xmm0, %xmm0
1188e9d4:      	cvtsi2sdl	(%rcx), %xmm0
1188e9d8:      	jmp	0x1188dbf5 <js_object_get_field_by_name+0x2dd5>
1188e9dd:      	movl	-0x40(%rbp), %eax
1188e9e0:      	cmpl	$0x3, %eax
1188e9e3:      	movl	$0x2, %ebx
1188e9e8:      	cmovael	%eax, %ebx
1188e9eb:      	xorl	%ecx, %ecx
1188e9ed:      	cmpl	%ebx, %edx
1188e9ef:      	setb	%cl
1188e9f2:      	movq	%r13, %rdi
1188e9f5:      	movq	-0x30(%rbp), %r14
1188e9f9:      	movq	%r14, %rsi
1188e9fc:      	movl	%edx, %r12d
1188e9ff:      	callq	0x116b0290 <_RNvNtNtNtCscI5nJwKNRh4_13perry_runtime6object13field_get_set17get_field_by_name15prime_read_stub>
1188ea04:      	movq	%r15, %rdi
1188ea07:      	movq	%r14, %rsi
1188ea0a:      	movl	%r12d, %edx
1188ea0d:      	callq	0x115793c0 <_RNvNtNtCscI5nJwKNRh4_13perry_runtime6object9prop_plan16read_plan_record>
1188ea12:      	movl	%r12d, %esi
1188ea15:      	cmpl	%ebx, %r12d
1188ea18:      	jb	0x1188e846 <js_object_get_field_by_name+0x3a26>
1188ea1e:      	movl	%esi, %esi
1188ea20:      	movq	%r13, %rdi
1188ea23:      	callq	0x115691f0 <_RNvNtNtCscI5nJwKNRh4_13perry_runtime6object5spill12overflow_get>
1188ea28:      	jmp	0x1188da24 <js_object_get_field_by_name+0x2c04>
1188ea2d:      	movq	%r13, %rdi
1188ea30:      	callq	*0x3a96a92(%rip)        # 0x153254c8 <_GLOBAL_OFFSET_TABLE_+0xe448>
1188ea36:      	xorps	%xmm0, %xmm0
1188ea39:      	cvtsi2sd	%eax, %xmm0
1188ea3d:      	jmp	0x1188dbf5 <js_object_get_field_by_name+0x2dd5>
1188ea42:      	movq	%r13, %rdi
1188ea45:      	callq	*0x3a90c3d(%rip)        # 0x1531f688 <_GLOBAL_OFFSET_TABLE_+0x8608>
1188ea4b:      	movabsq	$0x7ffc000000000001, %r15 # imm = 0x7FFC000000000001
1188ea55:      	testq	%rax, %rax
1188ea58:      	je	0x1188e18e <js_object_get_field_by_name+0x336e>
1188ea5e:      	movq	%rax, %rcx
1188ea61:      	shrq	$0x34, %rcx
1188ea65:      	movabsq	$0xffffffffffff, %r15   # imm = 0xFFFFFFFFFFFF
1188ea6f:      	andq	%rax, %r15
1188ea72:      	movabsq	$0x7ffd000000000000, %rdx # imm = 0x7FFD000000000000
1188ea7c:      	orq	%rdx, %r15
1188ea7f:      	cmpl	$0x7ff, %ecx            # imm = 0x7FF
1188ea85:      	cmovaeq	%rax, %r15
1188ea89:      	jmp	0x1188e18e <js_object_get_field_by_name+0x336e>
1188ea8e:      	movq	%r13, %rdi
1188ea91:      	callq	0x1150f540 <_RNvNtNtCscI5nJwKNRh4_13perry_runtime6buffer6header22is_shared_array_buffer>
1188ea96:      	testb	%al, %al
1188ea98:      	je	0x1188eaaf <js_object_get_field_by_name+0x3c8f>
1188ea9a:      	movl	$0x11, %esi
1188ea9f:      	leaq	0x2a71097(%rip), %rax   # 0x142ffb3d <anon.b37f594bd5826585f7e5082f302a037e.2838.llvm.4573768808118376784+0x65d>
1188eaa6:      	movq	%rax, -0xa0(%rbp)
1188eaad:      	jmp	0x1188eb05 <js_object_get_field_by_name+0x3ce5>
1188eaaf:      	movq	%r13, %rdi
1188eab2:      	callq	0x1150e2d0 <_RNvNtNtCscI5nJwKNRh4_13perry_runtime6buffer6header15is_array_buffer>
1188eab7:      	testb	%al, %al
1188eab9:      	je	0x1188eadb <js_object_get_field_by_name+0x3cbb>
1188eabb:      	movl	$0xb, %esi
1188eac0:      	leaq	0x2a71087(%rip), %rax   # 0x142ffb4e <anon.b37f594bd5826585f7e5082f302a037e.2838.llvm.4573768808118376784+0x66e>
1188eac7:      	movq	%rax, -0xa0(%rbp)
1188eace:      	jmp	0x1188eb05 <js_object_get_field_by_name+0x3ce5>
1188ead0:      	callq	*0x3a88a5a(%rip)        # 0x15317530 <_GLOBAL_OFFSET_TABLE_+0x4b0>
1188ead6:      	jmp	0x1188e184 <js_object_get_field_by_name+0x3364>
1188eadb:      	movq	%r13, %rdi
1188eade:      	callq	0x1150f540 <_RNvNtNtCscI5nJwKNRh4_13perry_runtime6buffer6header22is_shared_array_buffer>
1188eae3:      	leaq	0x2a71064(%rip), %rcx   # 0x142ffb4e <anon.b37f594bd5826585f7e5082f302a037e.2838.llvm.4573768808118376784+0x66e>
1188eaea:      	testb	%al, %al
1188eaec:      	movq	-0xa0(%rbp), %rdx
1188eaf3:      	cmovneq	%rcx, %rdx
1188eaf7:      	movq	%rdx, -0xa0(%rbp)
1188eafe:      	movzbl	%al, %esi
1188eb01:      	orq	$0xa, %rsi
1188eb05:      	movq	-0xa0(%rbp), %rdi
1188eb0c:      	jmp	0x1188dbef <js_object_get_field_by_name+0x2dcf>
1188eb11:      	callq	*0x3a94901(%rip)        # 0x15323418 <_GLOBAL_OFFSET_TABLE_+0xc398>
1188eb17:      	movq	-0x88(%rbp), %rdi
1188eb1e:      	movq	0x1e8(%rdi,%rbx,8), %rsi
1188eb26:      	testq	%rsi, %rsi
1188eb29:      	jne	0x1188dd85 <js_object_get_field_by_name+0x2f65>
1188eb2f:      	leaq	0x39a2a0a(%rip), %rdi   # 0x15231540 <_RNvNtCscI5nJwKNRh4_13perry_runtime6object19CLASS_DYNAMIC_PROPS>
1188eb36:      	callq	*0x3a9df7c(%rip)        # 0x1532cab8 <_GLOBAL_OFFSET_TABLE_+0x15a38>
1188eb3c:      	movq	%rax, %rsi
1188eb3f:      	leaq	-0x58(%rbp), %rdi
1188eb43:      	callq	0x111490a0 <_RNCNvNtNtNtCscI5nJwKNRh4_13perry_runtime6object13field_get_set17get_field_by_name27js_object_get_field_by_names_0B9_>
1188eb48:      	cmpq	$0x1, %rax
1188eb4c:      	je	0x1188dbf5 <js_object_get_field_by_name+0x2dd5>
1188eb52:      	jmp	0x1188dd98 <js_object_get_field_by_name+0x2f78>
1188eb57:      	movq	%r13, %rdi
1188eb5a:      	callq	*0x3a96968(%rip)        # 0x153254c8 <_GLOBAL_OFFSET_TABLE_+0xe448>
1188eb60:      	cltq
1188eb62:      	imulq	%rax, %r15
1188eb66:      	movq	%r15, %xmm0
1188eb6b:      	punpckldq	0xe1051d(%rip), %xmm0 # xmm0 = xmm0[0],mem[0],xmm0[1],mem[1]
                                                # 0x1269f090 <perry_class_keys_packed_cli_2_1_112_js__1227+0x530>
1188eb73:      	subpd	0xe10525(%rip), %xmm0   # 0x1269f0a0 <perry_class_keys_packed_cli_2_1_112_js__1227+0x540>
1188eb7b:      	movapd	%xmm0, %xmm1
1188eb7f:      	unpckhpd	%xmm0, %xmm1            # xmm1 = xmm1[1],xmm0[1]
1188eb83:      	addsd	%xmm0, %xmm1
1188eb87:      	movq	%xmm1, %r15
1188eb8c:      	jmp	0x1188e18e <js_object_get_field_by_name+0x336e>
1188eb91:      	movq	%r13, %rdi
1188eb94:      	callq	*0x3a8930e(%rip)        # 0x15317ea8 <_GLOBAL_OFFSET_TABLE_+0xe28>
1188eb9a:      	jmp	0x1188e7bb <js_object_get_field_by_name+0x399b>
1188eb9f:      	movq	%r13, %rdi
1188eba2:      	callq	0x11537fb0 <_RNvNtNtCscI5nJwKNRh4_13perry_runtime6object15prototype_chain23object_static_prototype>
1188eba7:      	movabsq	$0x7ffc000000000001, %rcx # imm = 0x7FFC000000000001
1188ebb1:      	incq	%rcx
1188ebb4:      	cmpq	%rcx, %rdx
1188ebb7:      	setne	%cl
1188ebba:      	testb	%cl, %al
1188ebbc:      	je	0x1188ebd4 <js_object_get_field_by_name+0x3db4>
1188ebbe:      	movq	%r13, %rdi
1188ebc1:      	movq	-0x30(%rbp), %rsi
1188ebc5:      	callq	0x115382c0 <_RNvNtNtCscI5nJwKNRh4_13perry_runtime6object15prototype_chain23resolve_inherited_field>
1188ebca:      	cmpq	$0x1, %rax
1188ebce:      	je	0x1188da0b <js_object_get_field_by_name+0x2beb>
1188ebd4:      	movzbl	-0x80(%rbp), %ebx
1188ebd8:      	movl	%ebx, %edi
1188ebda:      	movq	%r13, %rsi
1188ebdd:      	callq	0x11300da0 <_RNvNtNtCscI5nJwKNRh4_13perry_runtime10typedarray7species27prototype_constructor_patch>
1188ebe2:      	testb	$0x1, %al
1188ebe4:      	jne	0x1188dbf5 <js_object_get_field_by_name+0x2dd5>
1188ebea:      	movl	%ebx, %edi
1188ebec:      	callq	0x111d8810 <_RNvNtCscI5nJwKNRh4_13perry_runtime10typedarray13name_for_kind>
1188ebf1:      	movq	%rax, %rdi
1188ebf4:      	movq	%rdx, %rsi
1188ebf7:      	jmp	0x1188dbef <js_object_get_field_by_name+0x2dcf>
1188ebfc:      	movabsq	$0x3ff0000000000000, %r15 # imm = 0x3FF0000000000000
1188ec06:      	jmp	0x1188e18e <js_object_get_field_by_name+0x336e>
1188ec0b:      	cvtsi2sd	%r15d, %xmm0
1188ec10:      	jmp	0x1188dbf5 <js_object_get_field_by_name+0x2dd5>
1188ec15:      	leaq	0x2ab77ea(%rip), %rdi   # 0x14346406 <anon.b37f594bd5826585f7e5082f302a037e.12135.llvm.4573768808118376784+0x3546>
1188ec1c:      	leaq	0x2a6f17d(%rip), %rdx   # 0x142fdda0 <anon.b37f594bd5826585f7e5082f302a037e.1057.llvm.4573768808118376784>
1188ec23:      	movl	$0x23, %esi
1188ec28:      	movl	$0x14, %ecx
1188ec2d:      	callq	*0x3aa30fd(%rip)        # 0x15331d30 <_GLOBAL_OFFSET_TABLE_+0x1acb0>
1188ec33:      	nopw	%cs:(%rax,%rax)
1188ec3d:      	nopl	(%rax)
