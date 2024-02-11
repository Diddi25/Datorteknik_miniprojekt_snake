
#include <stdint.h>
#include <pic32mx.h>
#include "mipslab.h"

int getsw( void ) {
    int return_value = 0xfff;
    return_value = PORTD & 0xf00;     // 0xf00 = 0x 1111 0000 0000
    return_value = return_value >> 8;
    return return_value;              //returnerar status koder i 4 bitar
}

int getbtns(void) {
    int return_value = 0xff;
    return_value = PORTD & 0xe0;     // 0xf00 = 0x 1110 0000
    return_value = return_value >> 5;
    return return_value;
}
