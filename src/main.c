#include "stm32l4xx.h"
#include <stdio.h>
#include <string.h>
#include "main.h"
#include "hardware/nucleo.h"

void SystemClock_Config(void);

int main(void) {
    
    SystemClock_Config();

    nucleo_led_init();
    nucleo_uart_init();

    while (1) {
        LL_GPIO_TogglePin(LED_PORT, LED_PIN);
        LL_mDelay(500);
        printf("Hello, world!\r\n");
    }
}


void SystemClock_Config(void) {

    LL_FLASH_SetLatency(LL_FLASH_LATENCY_4);

    LL_RCC_MSI_Enable();
    while (LL_RCC_MSI_IsReady() != 1);

    // Configure PLL for 80 MHz
    // 4(MSI) / 1(M) * 40(N) / 2(R) = 80
    LL_RCC_PLL_ConfigDomain_SYS(LL_RCC_PLLSOURCE_MSI, LL_RCC_PLLM_DIV_1, 40, LL_RCC_PLLR_DIV_2);
    LL_RCC_PLL_Enable();
    LL_RCC_PLL_EnableDomain_SYS();
    while (LL_RCC_PLL_IsReady() != 1);
  
    LL_RCC_SetAHBPrescaler(LL_RCC_SYSCLK_DIV_1);
    LL_RCC_SetSysClkSource(LL_RCC_SYS_CLKSOURCE_PLL);
    while (LL_RCC_GetSysClkSource() != LL_RCC_SYS_CLKSOURCE_STATUS_PLL);
  
    LL_RCC_SetAPB1Prescaler(LL_RCC_APB1_DIV_1);
    LL_RCC_SetAPB2Prescaler(LL_RCC_APB2_DIV_1);

    /* Set systick to 1ms in using frequency set to 80MHz */
    /* This frequency can be calculated through LL RCC macro */
    /* ex: __LL_RCC_CALC_PLLCLK_FREQ(__LL_RCC_CALC_MSI_FREQ(LL_RCC_MSIRANGESEL_RUN, LL_RCC_MSIRANGE_6), 
                                  LL_RCC_PLLM_DIV_1, 40, LL_RCC_PLLR_DIV_2)*/
    LL_Init1msTick(80000000);
  
    /* Update CMSIS variable (which can be updated also through SystemCoreClockUpdate function) */
    LL_SetSystemCoreClock(80000000);
}
