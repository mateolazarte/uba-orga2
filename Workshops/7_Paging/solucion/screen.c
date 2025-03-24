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
  char* msg = "Bienvenido a Orga2, somos Esteban Mena, Mateo Lazarte y Axel Campoverde.";
  print(msg, 0, 0, 0x5);
  print("  ___                    ____  ",25,10,0x5);
  print(" / _ \\ _ __ __ _  __ _  |___ \\ ",25,11,0x5);
  print("| | | | '__/ _` |/ _` |   __) |",25,12,0x5);
  print("| |_| | | | (_| | (_| |  / __/ ",25,13,0x5);
  print(" \\___/|_|  \\__, |\\__,_| |_____|",25,14,0x5);
  print("           |___/               ",25,15,0x5);

  print("_____________________                              _____________________",4,20,0xF);
  print("`-._:  .:'   `:::  .:\\           |\\__/|           /::  .:'   `:::  .:.-'",4,21,0xF);
  print("    \\      :          \\          |:   |          /         :       /    ",4,22,0xF);
  print("     \\     ::    .     `-_______/ ::   \\_______-'   .      ::   . /      ",4,23,0xF);
  print("      |  :   :: ::'  :   :: ::'  :   :: ::'      :: ::'  :   :: :|       ",4,24,0xF);
  print("      |     ;::         ;::         ;::         ;::         ;::  |       ",4,25,0xF);
  print("      |  .:'   `:::  .:'   `:::  .:'   `:::  .:'   `:::  .:'   `:|       ",4,26,0xF);
  print("      /     :           :           :           :           :    \\       ",4,27,0xF);
  print("     /______::_____     ::    .     ::    .     ::   _____._::____\\      ",4,28,0xF);
  print("                   `----._:: ::'  :   :: ::'  _.----'                    ",4,29,0xF);
  print("                          `--.       ;::  .--'                           ",4,30,0xF);
  print("                              `-. .:'  .-'                               ",4,31,0xF);
  print("                                 \\    /                                  ",4,32,0xF);
  print("                                  \\  /                                   ",4,33,0xF);
  print("                                   \\/                                    ",4,34,0xF);
}