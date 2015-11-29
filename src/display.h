/*
 * display.h
 *
 *  Created on: 2015. 11. 16.
 *      Author: niklaus
 */

#ifndef DISPLAY_H__
#define DISPLAY_H__

#define BLACK           0x0000
#define BLUE            0x001F
#define RED             0xF800
#define GREEN           0x07E0
#define CYAN            0x07FF
#define MAGENTA         0xF81F
#define YELLOW          0xFFE0
#define WHITE           0xFFFF
#define LIGHT_GREY      0xC618
#define DARK_GREY       0x7BEF


#define CS_PIN 24
#define DC_PIN 23
#define RESET_PIN 20
#define TX_RX_MSG_LENGTH 1



/** SPI init */
void spi_master_init(void);

/** Init display */
void initDisplay();

/** draw rectangle */
void drawRectangle(uint8_t x1, uint8_t y1, uint8_t x2, uint8_t y2, uint16_t color);

/** put a pixel on 3x screen. */
void putPixel(uint8_t x, uint8_t y, uint16_t c);


void putDigit(uint8_t x, uint8_t y, uint8_t digit, uint16_t color, uint16_t bkcolor);

#endif /* DISPLAY_H__ */
