/*
 * Private Timer with Interruptions Class Example - vitis 2025.2
 *
 * System configures and uses Private Timer with Interruptions
 * in Zybo Z7 Teaching System 
 *
 * The application toggles the leds read from the switches using interruptions
 * every second
 *
 * Alberto Sanchez, Oct 2026
 *
*/


#include <xinterrupt_wrap.h>
#include <xgpio.h>
#include <xscutimer.h>


#define GPIO_0_ADDRESS              XPAR_AXI_GPIO_0_BASEADDR
#define GPIO0_INTRPT_ID             XPAR_AXI_GPIO_0_INTERRUPTS
#define GPIO0_INTRPT_PARENT         XPAR_AXI_GPIO_0_INTERRUPT_PARENT

#define LEDS                1
#define SWITCHES            2

#define PRIV_TIMER_ADDR             XPAR_SCUTIMER_BASEADDR
#define PRIV_TIMER_INTRPT_ID        XPAR_SCUTIMER_INTERRUPTS
#define PRIV_TIMER_INTERPT_PARENT   XPAR_SCUTIMER_INTERRUPT_PARENT

#define PERIOD                      83374999         /* to measure 1 second  */
#define PRESCALER                   3

/* Driver instances */

XGpio Gpio0;    // gpio instance
XScuTimer Tmr;  // tmr instance


/* Interrupt Flag - Globally accessible */
volatile u32 IntrptFlag = 0;

/* gpio interrupt handler */
static void gpioIntrptHandler(void * CallBackRef);

/* timer interrupt handler */
static void tmrIntrptHandler(void * CallBackRef);


int main(){
    u32 status;
    u32 leds;

    XScuTimer_Config * priv_tmrCfgPtr;

    /* Gpio 0 Configuration */
    status = XGpio_Initialize(&Gpio0,GPIO_0_ADDRESS);
    if(status != XST_SUCCESS){
        return 0;
    }

    XGpio_SetDataDirection(&Gpio0, LEDS, 0x0);        // outputs
    XGpio_SetDataDirection(&Gpio0, SWITCHES, 0xF);    // inputs

    XGpio_InterruptEnable(&Gpio0, SWITCHES);
    XGpio_InterruptGlobalEnable(&Gpio0);


    /* Private Timer configuration */
    priv_tmrCfgPtr = XScuTimer_LookupConfig(PRIV_TIMER_ADDR);
    status = XScuTimer_CfgInitialize(&Tmr,
			                        priv_tmrCfgPtr,
                                    priv_tmrCfgPtr->BaseAddr);
    if(status != XST_SUCCESS){
        return 0;
    }
    
    XScuTimer_LoadTimer(&Tmr,PERIOD);
    XScuTimer_SetPrescaler(&Tmr,PRESCALER);
    XScuTimer_EnableAutoReload(&Tmr);
    XScuTimer_EnableInterrupt(&Tmr);	


    /* Gpio Interrupt system configuration */
    XSetupInterruptSystem(&Gpio0, 
                        &gpioIntrptHandler,
                        GPIO0_INTRPT_ID,
                        GPIO0_INTRPT_PARENT,
                        XINTERRUPT_DEFAULT_PRIORITY);
    
    
    /* Private Timer Interrupt system configuration */
    XSetupInterruptSystem(&Tmr, 
                        &tmrIntrptHandler,
                        PRIV_TIMER_INTRPT_ID,
                        PRIV_TIMER_INTERPT_PARENT,
                        XINTERRUPT_DEFAULT_PRIORITY);

    /* Start Timer */
    XScuTimer_Start(&Tmr);

    /* Initial output */
    leds = XGpio_DiscreteRead(&Gpio0, SWITCHES);
    XGpio_DiscreteWrite(&Gpio0,LEDS,leds);

    
    while(1){
        switch(IntrptFlag){
            case 1: 
                IntrptFlag = 0;
                leds = XGpio_DiscreteRead(&Gpio0, SWITCHES);
                break;
            case 2:
                IntrptFlag = 0;
                leds = ~leds;
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

/* private timer interrupt handler */
static void tmrIntrptHandler(void * CallBackRef){
    IntrptFlag = 2;
}


