/*
 * Interruption Class Example - vitis 2025.2
 *
 * System configures and uses Gpio0 Interruptions
 * in Zybo Z7 Teaching System 
 *
 * Alberto Sanchez, Oct 2026
 *
*/


#include <xgpio.h>
#include <xinterrupt_wrap.h>


#define GPIO_0_ADDRESS      XPAR_AXI_GPIO_0_BASEADDR
#define GPIO0_INTRPT_ID     XPAR_AXI_GPIO_0_INTERRUPTS
#define GPIO0_INTRPT_PARENT XPAR_AXI_GPIO_0_INTERRUPT_PARENT


#define LEDS                1
#define SWITCHES            2

XGpio Gpio0;    // gpio instance

/* Interrupt Flag - Globally accessible */
volatile u32 IntrptFlag = 0;

/* gpio interrupt handler */
static void gpioIntrptHandler(void * CallBackRef);


int main(){
    u32 status;
    u32 leds;

    /* Gpio 0 Configuration */
    status = XGpio_Initialize(&Gpio0,GPIO_0_ADDRESS);
    if(status != XST_SUCCESS){
        return 0;
    }

    XGpio_SetDataDirection(&Gpio0, LEDS, 0x0);        // outputs
    XGpio_SetDataDirection(&Gpio0, SWITCHES, 0xF);    // inputs

    XGpio_InterruptEnable(&Gpio0, SWITCHES);
    XGpio_InterruptGlobalEnable(&Gpio0);

    /* Interrupt system configuration */
    XSetupInterruptSystem(&Gpio0, 
                        &gpioIntrptHandler,
                        GPIO0_INTRPT_ID,
                        GPIO0_INTRPT_PARENT,
                        XINTERRUPT_DEFAULT_PRIORITY);
    
    
    while(1){
        switch(IntrptFlag){
            case 1: 
                IntrptFlag = 0;
                leds = XGpio_DiscreteRead(&Gpio0, SWITCHES);
                XGpio_DiscreteWrite(&Gpio0,LEDS,leds);
                break;
            default:
                break;    
        }        
    }

    return 0;
}

/* gpio interrupt handler implementation */
static void gpioIntrptHandler(void * CallBackRef){

   /* Sets flag to signal main program that the interrupt has occured */
   XGpio *g = (XGpio *)CallBackRef;
   XGpio_InterruptClear(g, SWITCHES);   // SWITCHES = channel 2 mask
   IntrptFlag = 1;
}
