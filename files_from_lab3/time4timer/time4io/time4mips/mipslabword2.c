#include <stdint.h>   /* Declarations of uint_32 and the like */
#include <pic32mx.h>  /* Declarations of system-specific addresses etc */
#include "mipslab.h"  /* Declatations for these labs */

int mytime = 0x5957;
int timeoutcount = 0; // Global timeoutvariabel för uppgift c

char textstring[] = "text, more text, and even more text!";

/* Interrupt Service Routine */

void user_isr( void ) {
  return;
}

/* Lab-specific initialization goes here */
void labinit( void )
{
  volatile int* trise = (volatile int*) 0xbf886100;
  *trise &= ~0xff;

  TRISD &= ~0xfff; 
  TRISD |= 0xfe0;

  /* Controll register. Bit 15 = clock start, bit 4-6 anger prescale value (1:256 i detta fall) */ 
  T2CON = 0b1000000001110000; // 0b 1000 0000 0111 0000
  TMR2 = 0; // Initierar timervärdet till 0

  /* Anger periodvärdet som TMR2 ska räkna upp till (för 
     100ms beräknas PR2 = 80 000 000 / 256 / 10 = 31 250) */
  PR2 = 31250; // 80M / 256 ger tiden i sekunder, 

  /* Bit 8 av IFS(0) kollar Timer 2 Interrupt Flag (T2IF) */
  IFS(0) &= ~0x00000100; // Behövs egentligen inte här

  return;
}

/* This function is called repetitively from the main program */
void labwork( void ) {
  volatile int* porte = (volatile int*) 0xbf886110;
  if (mytime == 0x5957) { //denna sätter alla bitar till 0 om mytime är detdär
    *porte &= ~0xff; 
  }
  //delay( 1000 ); // Kallar ej på delay()

  if (IFS(0) & 0x00000100){ // Om T2IF-bit:en blir 1 (användning av "&" :D )
    timeoutcount++; // timeoutcount ökas med 1
    if (timeoutcount == 10){ // När timeoutcount blir 10
      time2string( textstring, mytime );
      display_string( 3, textstring );
      display_update();
      tick( &mytime );
      timeoutcount = 0; // Reset'ar timeoutcount till 0
    }
    IFS(0) &= ~0x00000100; // Sätter T2IF-bit:en tillbaka till 0
  }

  // För att se switcharna och knapparna på LED
  int btns = getbtns();
  btns = (btns << 5);
  *porte = btns | getsw();

  // Uhm... aa
  if (getbtns != 0x0){
    int bn1Time = 0xffff;
    int bn2Time = 0xffff;
    int bn3Time = 0xffff;

    if (getbtns() & 0x1){
      bn1Time = getsw();
      bn1Time = (bn1Time << 4) | 0xff0f;
      mytime = mytime | 0x00f0;
    }

    if (getbtns() & 0x2){
      bn2Time = getsw();
      bn2Time = (bn2Time << 8) | 0xf0ff;
      mytime = mytime | 0x0f00;
    }

    if (getbtns() & 0x4){
      bn3Time = getsw();
      bn3Time = (bn3Time << 12) | 0xfff;
      mytime = mytime | 0xf000;
    }

    mytime = mytime & bn1Time & bn2Time & bn3Time;
  }

  display_image(96, icon);

}