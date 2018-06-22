;******************** (C) COPYRIGHT 2018 IoTality ********************
;* File Name          : main.s
;* Author             : Gopal
;* Date               : 22-June-2018
;* Description        : Main code to demonstrate Privileged and Unprivileged access levels
;*                      - Starts in unprivileged access level 
;*                      - Writes to and reads from special registers
;*						- are ignored in this mode. 
;*						- Attempt to write to SysTick registers results
;*						- in Hard fault. (Actually a bus usage fault but
;*						- since bus usage fault is disabled by default, this
;*						- vectors to hard fault).
;*						- A service handler function (0x05) is provided to switch
;*						- to privileged mode. Set USE_SVC to TRUE and then
;*						- rebuild the code and try again. Systick should start working and
;*						- blink LED at PD12 on STM32F4 Discovery Board.
;*********************************************************************
	GET reg_stm32f407xx.inc

	GBLL	USE_SVC
	
;*********************************************************************		
; * To switch to privileged level, Set USE_SVC to TRUE and rebuild the code
USE_SVC		SETL	{FALSE}
;*********************************************************************

; Export functions so they can be called from other file

	EXPORT SystemInit
	EXPORT __main

	AREA	MYCODE, CODE, READONLY
		
; ******* Function SystemInit *******
; * Called from startup code
; * Calls - None
; * Enables GPIO clock 
; * Configures GPIO-D Pins 12 to 15 as:
; ** Output
; ** Push-pull (Default configuration)
; ** High speed
; ** Pull-up enabled

; **************************

SystemInit FUNCTION

	; Enable GPIO clock
	LDR		R1, =RCC_AHB1ENR	;Pseudo-load address in R1
	LDR		R0, [R1]			;Copy contents at address in R1 to R0
	ORR.W 	R0, #0x08			;Bitwise OR entire word in R0, result in R0
	STR		R0, [R1]			;Store R0 contents to address in R1

	; Set mode as output
	LDR		R1, =GPIOD_MODER	;Two bits per pin so bits 24 to 31 control pins 12 to 15
	LDR		R0, [R1]			
	ORR.W 	R0, #0x55000000		;Mode bits set to '01' makes the pin mode as output
	AND.W	R0, #0x55FFFFFF		;OR and AND both operations reqd for 2 bits
	STR		R0, [R1]

	; Set type as push-pull	(Default)
	LDR		R1, =GPIOD_OTYPER	;Type bit '0' configures pin for push-pull
	LDR		R0, [R1]
	AND.W 	R0, #0xFFFF0FFF	
	STR		R0, [R1]
	
	; Set Speed slow
	LDR		R1, =GPIOD_OSPEEDR	;Two bits per pin so bits 24 to 31 control pins 12 to 15
	LDR		R0, [R1]
	AND.W 	R0, #0x00FFFFFF		;Speed bits set to '00' configures pin for slow speed
	STR		R0, [R1]	
	
	; Set pull-up
	LDR		R1, =GPIOD_PUPDR	;Two bits per pin so bits 24 to 31 control pins 12 to 15
	LDR		R0, [R1]
	AND.W	R0, #0x00FFFFFF		;Clear bits to disable pullup/pulldown
	STR		R0, [R1]

	BX		LR					;Return from function
	
	ENDFUNC
	

; ******* Function main *******
;* Called from startup code after SystemInit
;* Never returns. 
;* Starts in unprivileged mode.
;* See the comment block at top of this file for details
;* Debug the code step by step and observe registers values.
;* such as PRIMASK, FAULTMASK, BASEPRI and CONTROL
; **************************

__main FUNCTION



; Start in unprivileged mode
	MOV		R0, #01
	MSR		CONTROL, R0


; Getting back to privileged mode via 
; write to CONTROL register isn't possible now
; Writes to CONTROL register are simply ignored
	MOV		R0, #0x00
	MSR		CONTROL, R0

; Correct way of switching back to privileged level
	IF USE_SVC = {TRUE}
	SVC	#0x05
	ENDIF

; Writes to some special registers are ignored in unprivileged mode
; Reads from these registers return zero
	
	MOV		R0, #0x01
	
	MSR		BASEPRI, R0
	MSR		PRIMASK, R0
	MSR		FAULTMASK, R0
	
	MRS		R0, BASEPRI
	MRS		R0, PRIMASK
	MRS		R0, FAULTMASK


; Similarly, the CPS instructions have no effect in unprivileged mode

	CPSIE	i
	CPSID	i
	CPSIE	f
	CPSID	f

;Finally re-enable interrupts and faults
	CPSIE	i
	CPSIE	f

; Writing to SysTick control register 
; results in Fault in unprivileged mode

	LDR		R1, =SYSTICK_RELOADR
	LDR		R2,	=SYST_RELOAD_500MS
	STR		R2, [R1]


; Writing to SysTick reload register 
; results in Fault in unprivileged mode

	MOV		R7, #0x00
	
	LDR		R1, =SYSTICK_CONTROLR
	LDR 	R0, [R1]
	ORR.W	R0, #ENABLE_SYSTICK
	STR		R0, [R1]


	B	.

	ENDFUNC
	
	ALIGN	
SYST_RELOAD_500MS	EQU 0x007A1200
SYST_RELOAD_1000MS	EQU	0X00F42400
ENABLE_SYSTICK		EQU	0x07	
	
	END
