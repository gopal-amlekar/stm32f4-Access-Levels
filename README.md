### Understanding Access-Levels in ARM Cortex-M

This repository contains code to demonstrate access levels (Privileged and Unprivileged) in ARM Cortex-M processor core. The code is written in ARM Assembly for STM32F4 using the STM32F4-Discovery board.

For detailed explanation of the code, refer blog post - [ https://iotality.com/armcm-access-levels/]( https://iotality.com/armcm-access-levels/)

Entire source code is contained in this repository in the [src](/src) folder. The project files (for Keil uVision IDE) are in the [mdk-arm](/mdk-arm) folder.

This README contains instructions to build and download the code to STM32F4 discovery board.


#### Prerequisites and Steps

Most of the steps for executing this code are same as the steps mentioned in README file for the SVC Demo project. Hence these steps are not repeated here. Here is an overview of the steps to execute this code.

1. Clone this repository and open the project in Keil uVision IDE.
2. Build and download the code without any change.
3. Start debugging the code via Keil uVision IDE.
4. Single step through the code follow along the blog post referred above. Watch the registers as you execute the code.
5. After the proessor leads to a hard fault, stop debugging.
6. Now build the code with *_USE_SVC_* variable to TRUE and repeat debugging step by step.
7. This time the processor should not go to hard fault but instead the SysTick timer will be running blinking the green user LED on the Discovery Board at 500 msec interval.

For more details, refer the video below and read the blog post.

[![Video showing ARM Cortex-M access levels in action](https://img.youtube.com/vi/OeLvAIEkW4w/0.jpg)](https://youtube.com/watch?v=OeLvAIEkW4w)


 [ https://iotality.com/armcm-access-levels/]( https://iotality.com/armcm-access-levels/)