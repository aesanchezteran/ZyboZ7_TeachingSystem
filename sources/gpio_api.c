/*
 * Basic example to drive the leds from the switches
 * using xgpio.h without interruptions.
 *
 * */


#include <xparameters.h>
#include <xgpio.h>

#define GPIO_0_ADDRESS  XPAR_AXI_GPIO_0_BASEADDR
#define LEDS    1
#define SWITCHES    2

XGpio gpio0;    // global variable - globally accesible


int main(){
    u32 status;
    u32 switches;

    status = XGpio_Initialize(&gpio0,GPIO_0_ADDRESS);
    if(status != XST_SUCCESS){
        return 0;
    }

    while(1){
        
        /* Read from switches */
        switches = XGpio_DiscreteRead(&gpio0, SWITCHES);

        /* Write to leds */
        XGpio_DiscreteWrite(&gpio0,LEDS,switches);
        
    }

    return 0;
}

