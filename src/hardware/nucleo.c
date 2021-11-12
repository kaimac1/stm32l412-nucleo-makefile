#include "nucleo.h"
#include "stm32l4xx.h"
#include "stm32l4xx_hal_rcc.h"
#include "main.h"

void nucleo_led_init(void) {

    __HAL_RCC_GPIOB_CLK_ENABLE();

    // LL_GPIO_SetPinMode(LED_PORT, LED_PIN, LL_GPIO_MODE_OUTPUT);

    LL_GPIO_InitTypeDef gpio;
    gpio.Pin = LED_PIN;
    gpio.Mode = LL_GPIO_MODE_OUTPUT;
    gpio.Speed = LL_GPIO_SPEED_HIGH;
    gpio.OutputType = LL_GPIO_OUTPUT_PUSHPULL;
    gpio.Pull = 0;
    gpio.Alternate = 0;
    LL_GPIO_Init(LED_PORT, &gpio);  
    
}

void nucleo_uart_init(void) {

    __HAL_RCC_GPIOA_CLK_ENABLE();

    // UART TX pin
    LL_GPIO_InitTypeDef gpio;
    gpio.Pin = LL_GPIO_PIN_2;
    gpio.Mode = LL_GPIO_MODE_ALTERNATE;
    gpio.Speed = LL_GPIO_SPEED_HIGH;
    gpio.OutputType = LL_GPIO_OUTPUT_PUSHPULL;
    gpio.Pull = 0;    
    gpio.Alternate = LL_GPIO_AF_7;
    LL_GPIO_Init(GPIOA, &gpio);

    __HAL_RCC_USART2_CLK_ENABLE();
    LL_USART_InitTypeDef usart;
    usart.BaudRate = 115200;
    usart.DataWidth = LL_USART_DATAWIDTH_8B;
    usart.StopBits = LL_USART_STOPBITS_1;
    usart.Parity = LL_USART_PARITY_NONE;
    usart.TransferDirection = LL_USART_DIRECTION_TX_RX;
    usart.HardwareFlowControl = LL_USART_HWCONTROL_NONE;
    usart.OverSampling = LL_USART_OVERSAMPLING_16; 
    LL_USART_Init(DEBUG_UART, &usart);

    LL_USART_Enable(DEBUG_UART);    

}


void uart_send(uint8_t *ptr, int len) {
    for (int i=0; i<len; i++) {
        while (!LL_USART_IsActiveFlag_TXE(DEBUG_UART));
        LL_USART_TransmitData8(DEBUG_UART, *ptr++);
    }
}

// retarget newlib
int _write(int file, char * ptr, int len) {
    uart_send((uint8_t*)ptr, len);
    return len;
}
