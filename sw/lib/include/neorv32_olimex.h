#ifndef olimex_neorv32_h
#define olimex_neorv32_h
#include "neorv32.h"


//#io devices#
#include "olimex_led.h"

//#memory mapped io#
//LED base address
#define OLIMEX_LED_BASE (0xF0000000UL) 
//LED output port 8-bit (r/w) */
#define OLIMEX_LED (*((volatile uint8_t*) (OLIMEX_LED_BASE)))

#endif // olimex_neorv32_h
