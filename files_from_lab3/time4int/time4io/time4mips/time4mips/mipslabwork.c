/* mipslabwork.c

   This file written 2015 by F Lundevall
   Updated 2017-04-21 by F Lundevall

   This file should be changed by YOU! So you must
   add comment(s) here with your name(s) and date(s):

   This file modified 2017-04-31 by Ture Teknolog 

   For copyright and licensing, see file COPYING */

#include <stdint.h>   /* Declarations of uint_32 and the like */
#include <pic32mx.h>  /* Declarations of system-specific addresses etc */
#include "mipslab.h"  /* Declatations for these labs */

int mytime = 0x5957;
char textstring[] = "text, more text, and even more text!";
int timeoutcounter = 0;
int prime = 1234567;

/* Interrupt Service Routine */
void user_isr( void ) {
  time2string( textstring, mytime );
  display_string( 3, textstring );
  display_update();
  tick( &mytime );
}

/* Lab-specific initialization goes here */
void labinit( void )
{
  volatile int* trise = (volatile int*) 0xbf886100; //sätter upp pointer till addressen för LEDS
  *trise &= ~0xff;

  TRISD = TRISD & 0xfff;
  TRISD = TRISD | 0xfe0; //0x 1111 1110 0000

  T2CON = 0b1000000001110000; // 0b 1000 0000 0111 0000
  TMR2 = 0; // Initierar timervärdet till 0

  /* Anger periodvärdet som TMR2 ska räkna upp till (för 
     100ms beräknas PR2 = 80 000 000 / 256 / 10 = 31 250) */
  PR2 = 31250; // 80M / 256 ger tiden i sekunder, 1/10s = 10

  /* Bit 8 av IFS(0) kollar Timer 2 Interrupt Flag (T2IF) */
  IFS(0) &= ~0x00000100; // Behövs egentligen inte här

  IEC(0) |= 0xffffffff;
  IPC(2) |= 0xffffffff;

  return;
}

void changeTimeWithToggles() {
  if(getbtns() != 0x0) {
    int sw_status_number1 = 0xffff;
    int sw_status_number2 = 0xffff;
    int sw_status_number3 = 0xffff;
    if(getbtns() & 0x1) {
      sw_status_number1 = getsw(); //get digit to replace with
      sw_status_number1 = (sw_status_number1 << 4) | 0xff0f; //sätt på tiotals siffra
      mytime = mytime | 0x00f0; // sätter tiotalssiffran fria
    }
    if(getbtns() & 0x2) {
      sw_status_number2 = getsw(); //
      sw_status_number2 = (sw_status_number2 << 8) | 0xf0ff;
      mytime = mytime | 0x0f00;
    }
    if(getbtns() & 0x4) { //getbtns() = 0x 100 0x
      sw_status_number3 = getsw(); //
      sw_status_number3 = (sw_status_number3 << 12) | 0x0fff;
      mytime = mytime | 0xf000;
    }
    mytime = mytime & sw_status_number1 & sw_status_number2 & sw_status_number3;
  }
}

/* This function is called repetitively from the main program */
void labwork( void ) {
  prime = nextprime( prime );
  display_string( 0, itoaconv( prime ) );
  display_update();
}
