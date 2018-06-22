;******************** (C) COPYRIGHT 2018 IoTality ********************
;* File Name          : isr.s
;* Author             : IoTality
;* Date               : 22-June-2018
;* Description        : Exception handler for SVC
;*                      - Executes when SVC instruction is executed from main code
;*                      - SVC parameter is used to switch ON LED on GPIO-D pins PD12 to PD15
;*                      - Parameter 1 to 5 switches on LEDs on PD12-PD15 respectively
;*                      - Any other Parameter switches on all LEDs

;*                      - Service call 5 is special. It switches the processor to privileged mode.

;*********************************************************************


	GET reg_stm32f407xx.inc

	AREA	ISRCODE, CODE, READONLY
	

	IMPORT	Service_Call_1
	IMPORT	Service_Call_2
	IMPORT	Service_Call_3
	IMPORT	Service_Call_4
	IMPORT	Service_Call_5
	IMPORT	Service_Call_Default


;*********************************************************************
;* SVC exception handler
;* Redefined here (startup code contains a weak definition)
;* Extracts the parameter passed on in SVC instruction.
;* The parameter is stored in lower byte of SVC encoding
;* and it is retrieved in the following way.

;* Before switching to exception handler execution, the 
;* processor puts a number of registers on stack. This is 
;* called the stacking process. The registers stacked are as below,
;* in the same order as listed.

;* PSR
;* PC (Of the next instruction to be executed)
;* LR
;* R12
;* R3
;* R2
;* R1
;* R0

;* The execption handler first finds out which stack pointer
;* is being used (either MSP or PSP). Then it reads the value
;* of the stack pointer being used.
;* 
;* It then traverses the stack 24 bytes (6 registers R0-R3, R12, LR  
;* on stack with 4 bytes each) to retrieve stacked PC.
;* This stacked PC is the address of next instruction to be executed
;* after the handler returns to application code.
;* 
;* Once it gets the PC, it reads the lower byte of the earlier instruction
;* which is precisely the SVC instruction. The parameter is stored in 
;* lower byte of SVC encoding (Little Endian). Thus we get the SVC parameter
;* in R0 now.
;* 
;* Based on this parameter value, different functions are called from the
;* file services.s. This is quite straightforward as it compares the parameter
;* to a value between 1 to 5. If the value is other than these values,
;* a default handler is called.
;*********************************************************************

	
	
SVC_Handler PROC
	EXPORT  SVC_Handler
	EXPORT  SysTick_Handler
	EXPORT	HardFault_Handler
		
; Extract the SVC parameter
	TST		LR, #4
	MRSEQ	R0, MSP
	MRSNE	R0, PSP
	
	LDR		R0, [R0, #24]
	LDRB	R0, [R0, #-2]
	
	CMP		R0, #01
	LDREQ	R1, =Service_Call_1
	BEQ		DoneService
	
	CMP		R0, #02
	LDREQ	R1, =Service_Call_2
	BEQ		DoneService
	
	CMP		R0, #03
	LDREQ	R1, =Service_Call_3
	BEQ		DoneService
	
	CMP		R0, #04
	LDREQ	R1, =Service_Call_4
	BEQ		DoneService

	CMP		R0, #05
	LDREQ	R1, =Service_Call_5
	BEQ		DoneService
	
	LDR		R1, =Service_Call_Default
	
DoneService	
	PUSH 	{LR}
	BLX		R1
	POP		{PC}
	
	
	ENDP
	

		
SysTick_Handler PROC
	
	
	LDR		R1, =GPIOD_BSRR

	CBZ		R7, Turn_OFF
Turn_ON
	MOV		R0, #LEDs_ON
	B		DoneSysTick
Turn_OFF
	MOV		R0, #LEDs_OFF
DoneSysTick
	STR		R0, [R1]
	EOR		R7, R7, #0x01
	
	BX	LR

	ENDP


HardFault_Handler PROC
	
	LDR		R1, =GPIOD_BSRR
	LDR		R3, =LED2
	STR		R3, [R1]
	
	B		.

	ENDP

	ALIGN
		
LEDs_ON		EQU	0x00001000
LEDs_OFF	EQU	0x10000000

LED2		EQU	0xD0002000		;Switch on LED at PD13 and switch off PD12,PD14,PD15
	
	
	
	END
