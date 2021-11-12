#pragma once

#define LED_PORT    GPIOB
#define LED_PIN     LL_GPIO_PIN_3
#define DEBUG_UART  USART2

void nucleo_led_init(void);
void nucleo_uart_init(void);
int _write(int file, char * ptr, int len);
