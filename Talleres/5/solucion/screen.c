/* ** por compatibilidad se omiten tildes **
================================================================================
 TALLER System Programming - ORGANIZACION DE COMPUTADOR II - FCEN
================================================================================

  Definicion de funciones de impresion por pantalla.
*/

#include "screen.h"

void print(const char* text, uint32_t x, uint32_t y, uint16_t attr) {
  ca(*p)[VIDEO_COLS] = (ca(*)[VIDEO_COLS])VIDEO; 
  int32_t i;
  for (i = 0; text[i] != 0; i++) {
    p[y][x].c = (uint8_t)text[i];
    p[y][x].a = (uint8_t)attr;
    x++;
    if (x == VIDEO_COLS) {
      x = 0;
      y++;
    }
  }
}

void print_dec(uint32_t numero, uint32_t size, uint32_t x, uint32_t y,
               uint16_t attr) {
  ca(*p)[VIDEO_COLS] = (ca(*)[VIDEO_COLS])VIDEO; 
  uint32_t i;
  uint8_t letras[16] = "0123456789";

  for (i = 0; i < size; i++) {
    uint32_t resto = numero % 10;
    numero = numero / 10;
    p[y][x + size - i - 1].c = letras[resto];
    p[y][x + size - i - 1].a = attr;
  }
}

void print_hex(uint32_t numero, int32_t size, uint32_t x, uint32_t y,
               uint16_t attr) {
  ca(*p)[VIDEO_COLS] = (ca(*)[VIDEO_COLS])VIDEO; 
  int32_t i;
  uint8_t hexa[8];
  uint8_t letras[16] = "0123456789ABCDEF";
  hexa[0] = letras[(numero & 0x0000000F) >> 0];
  hexa[1] = letras[(numero & 0x000000F0) >> 4];
  hexa[2] = letras[(numero & 0x00000F00) >> 8];
  hexa[3] = letras[(numero & 0x0000F000) >> 12];
  hexa[4] = letras[(numero & 0x000F0000) >> 16];
  hexa[5] = letras[(numero & 0x00F00000) >> 20];
  hexa[6] = letras[(numero & 0x0F000000) >> 24];
  hexa[7] = letras[(numero & 0xF0000000) >> 28];
  for (i = 0; i < size; i++) {
    p[y][x + size - i - 1].c = hexa[i];
    p[y][x + size - i - 1].a = attr;
  }
}

void screen_draw_box(uint32_t fInit, uint32_t cInit, uint32_t fSize,
                     uint32_t cSize, uint8_t character, uint8_t attr) {
  ca(*p)[VIDEO_COLS] = (ca(*)[VIDEO_COLS])VIDEO;
  uint32_t f;
  uint32_t c;
  for (f = fInit; f < fInit + fSize; f++) {
    for (c = cInit; c < cInit + cSize; c++) {
      p[f][c].c = character;
      p[f][c].a = attr;
    }
  }
}

void screen_draw_layout(void) {
  screen_draw_box(0, 0, VIDEO_FILS, VIDEO_COLS, 0x20, 0); //limpiar pantalla
  char* msg = "Bienvenido a Orga2, somos Esteban Mena, Mateo Lazarte y Axel Campoverde. Esto es una prueba.";
  print(msg, 0, 0, 0x4A);
print("                       .",15,6,0x2);
print("                       M",15,7,0x2);
print("                      dM",15,8,0x2);
print("                      MMr",15,9,0x2);
print("                     4MMML                  .",15,10,0x2);
print("                     MMMMM.                xf",15,11,0x2);
print("     .              'MMMMM               .MM-",15,12,0x2);
print("      Mh..          +MMMMMM            .MMMM",15,13,0x2);
print("      .MMM.         .MMMMML.          MMMMMh",15,14,0x2);
print("       )MMMh.        MMMMMM         MMMMMMM",15,15,0x2);
print("        3MMMMx.     'MMMMMMf      xnMMMMMM'",15,16,0x2);
print("        '*MMMMM      MMMMMM.     nMMMMMMP'",15,17,0x2);
print("          *MMMMMx    'MMMMM\\    .MMMMMMM=",15,18,0x2);
print("           *MMMMMh   'MMMMM'   JMMMMMMP",15,19,0x2);
print("             MMMMMM   3MMMM.  dMMMMMM            .",15,20,0x2);
print("              MMMMMM  'MMMM  .MMMMM(        .nnMP'",15,21,0x2);
print("  =..          *MMMMx  MMM'  dMMMM'    .nnMMMMM*",15,22,0x2);
print("    'MMn...     'MMMMr 'MM   MMM'   .nMMMMMMM*'",15,23,0x2);
print("     '4MMMMnn..   *MMM  MM  MMP'  .dMMMMMMM''",15,24,0x2);
print("        '*MMMMMMMMx.  *ML 'M .M*  .MMMMMM**'",15,25,0x2);
print("           *PMMMMMMhn. *x > M  .MMMM**''",15,26,0x2);
print("              ''**MMMMhx/.h/ .=''",15,27,0x2);
print("                      .3P''0....",15,28,0x2);
print("                    nP'     '*MMnx",15,29,0x2);
}