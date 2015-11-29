/*
 * display.c
 *
 *  Created on: 2015. 11. 16.
 *      Author: niklaus
 */

#include <stdbool.h>
#include <stdint.h>
#include "nrf_delay.h"
#include "nrf_gpio.h"
#include "app_util_platform.h"
#include "nrf_error.h"
#include "nrf_drv_spi.h"
#include "display.h"

#define SPIM0_SCK_PIN   29  // SPI clock GPIO pin number.
#define SPIM0_MOSI_PIN  25  // SPI Master Out Slave In GPIO pin number.
#define SPIM0_MISO_PIN  28  // SPI Master In Slave Out GPIO pin number.
#define SPIM0_SS_PIN    12  // SPI Slave Select GPIO pin number.

static const nrf_drv_spi_t m_spi_master_0 = NRF_DRV_SPI_INSTANCE(0);

void spi_master_init(void)
{
    nrf_drv_spi_config_t config =
    {
    	.sck_pin      = SPIM0_SCK_PIN,
    	.mosi_pin     = SPIM0_MOSI_PIN,
    	.miso_pin     = SPIM0_MISO_PIN,
        .ss_pin       = SPIM0_SS_PIN,
        .irq_priority = APP_IRQ_PRIORITY_LOW,
        .orc          = 0xCC,
        .frequency    = NRF_DRV_SPI_FREQ_8M,
        .mode         = NRF_DRV_SPI_MODE_3,
        .bit_order    = NRF_DRV_SPI_BIT_ORDER_MSB_FIRST
    };

    //Initialize SPI master.
    uint32_t err_code = nrf_drv_spi_init(&m_spi_master_0, &config, NULL);
    if (err_code != NRF_SUCCESS)
    {
        // Initialization failed. Take recovery action.
    }
}

uint16_t        buf_len = TX_RX_MSG_LENGTH;
uint8_t         tx_buffer[2];    //Transmit buffer to send data from SPI master with sample data.
uint8_t         rx_buffer[0];    //Receive buffer to get data from SPI slave.

void writeCommand(uint8_t c) {
    nrf_gpio_pin_write(DC_PIN, 0); // command
    tx_buffer[0] = c;
    nrf_drv_spi_transfer(&m_spi_master_0, tx_buffer, buf_len, rx_buffer, 0);
}

void writeData(uint8_t c) {
    nrf_gpio_pin_write(DC_PIN, 1); // data
    tx_buffer[0] = c;
    nrf_drv_spi_transfer(&m_spi_master_0, tx_buffer, buf_len, rx_buffer, 0);
}

void spiWrite(uint8_t c) {
    tx_buffer[0] = c;
    nrf_drv_spi_transfer(&m_spi_master_0, tx_buffer, buf_len, rx_buffer, 0);
}


void initDisplay() {
    nrf_gpio_cfg_output(CS_PIN);
    nrf_gpio_cfg_output(DC_PIN);
    nrf_gpio_cfg_output(RESET_PIN);

    nrf_gpio_pin_write(CS_PIN, 1); // disable
    nrf_gpio_pin_write(DC_PIN, 0); // command
    nrf_gpio_pin_write(RESET_PIN, 0); // reset

    nrf_delay_us(20000);
    nrf_gpio_pin_write(RESET_PIN, 1); // un-reset

    // Initialize display
    nrf_delay_us(50000);
    nrf_gpio_pin_write(CS_PIN, 0); // enable
    writeCommand(0xfd); // unlock
    writeData(0x12);
    writeCommand(0xfd); // unlock
    writeData(0xb1);
    writeCommand(0xae); // display off
    writeCommand(0xb3); // clock div
    writeData(0xf1);
    writeCommand(0xca); // Multiplex Ratio
    writeData(0x7f);
    writeCommand(0xa0); // remap
    writeData(0x74);
    writeCommand(0x15); // col 0-127
    writeData(0);
    writeData(0x7f);
    writeCommand(0x65); // row 0-127
    writeData(0);
    writeData(0x7f);
    writeCommand(0xa1); // startline (if height=96)
    writeData(96);
    writeCommand(0xa2); // display offset
    writeData(0);
    writeCommand(0xb5); // GPIO
    writeData(0);
    writeCommand(0xab); // func select
    writeData(1);
    writeCommand(0xB1); // precharge
    writeData(0x32);
    writeCommand(0xBE); // vcomh
    writeData(5);
    writeCommand(0xA6); // normal display
    writeCommand(0xC1); // contrast abc
    writeData(0xC8);
    writeData(0x80);
    writeData(0xC8);
    writeCommand(0xC7); // contrast master
    writeData(0x0F);
    writeCommand(0xB4); // set vsl
    writeData(0xA0);
    writeData(0xB5);
    writeData(0x55);
    writeCommand(0xB6); // precharge2
    writeData(1);
    writeCommand(0xaf); // display on
    nrf_gpio_pin_write(CS_PIN, 1); // disable
}

// put a pixel on 3x screen.
void putPixel(uint8_t x, uint8_t y, uint16_t c) {
    uint8_t x1 = x * 3;
    uint8_t x2 = x1 + 2;
    uint8_t y1 = y * 3;
    uint8_t y2 = y1 + 2;
    nrf_gpio_pin_write(CS_PIN, 0);
    nrf_gpio_pin_write(DC_PIN, 0); spiWrite(0x15);
    nrf_gpio_pin_write(DC_PIN, 1); spiWrite(x1); spiWrite(x2);
    nrf_gpio_pin_write(DC_PIN, 0); spiWrite(0x75);
    nrf_gpio_pin_write(DC_PIN, 1); spiWrite(y1); spiWrite(y2);
    nrf_gpio_pin_write(DC_PIN, 0); spiWrite(0x5c);
    nrf_gpio_pin_write(DC_PIN, 1);

    uint8_t pix_buffer[18];
    for (uint8_t i=0; i < 9; i++) {
      pix_buffer[i*2] = c >> 8;
      pix_buffer[i*2+1] = c;
    }
    nrf_drv_spi_transfer(&m_spi_master_0, pix_buffer, 18, rx_buffer, 0);
}

void drawRectangle(uint8_t x1, uint8_t y1, uint8_t x2, uint8_t y2, uint16_t color) {
    nrf_gpio_pin_write(CS_PIN, 0);
    nrf_gpio_pin_write(DC_PIN, 0); spiWrite(0x15);
    nrf_gpio_pin_write(DC_PIN, 1); spiWrite(x1); spiWrite(x2);
    nrf_gpio_pin_write(DC_PIN, 0); spiWrite(0x75);
    nrf_gpio_pin_write(DC_PIN, 1); spiWrite(y1); spiWrite(y2);
    nrf_gpio_pin_write(DC_PIN, 0); spiWrite(0x5c);
    nrf_gpio_pin_write(DC_PIN, 1);

    uint16_t len = ((x2-x1+1)*(y2-y1+1));
    for (uint16_t i=0; i < len; i++) {
        tx_buffer[0] = color >> 8;
        tx_buffer[1] = color;
        nrf_drv_spi_transfer(&m_spi_master_0, tx_buffer, 2, rx_buffer, 0);
    }
}


uint8_t digits[10][5][3] = {
	{
			{1, 1, 1},
			{1, 0, 1},
			{1, 0, 1},
			{1, 0, 1},
			{1, 1, 1}
	},
	{
			{0, 1, 0},
			{0, 1, 0},
			{0, 1, 0},
			{0, 1, 0},
			{0, 1, 0}
	},
	{
			{1, 1, 1},
			{0, 0, 1},
			{1, 1, 1},
			{1, 0, 0},
			{1, 1, 1}
	},
	{
			{1, 1, 1},
			{0, 0, 1},
			{1, 1, 1},
			{0, 0, 1},
			{1, 1, 1}
	},
	{
			{1, 0, 1},
			{1, 0, 1},
			{1, 1, 1},
			{0, 0, 1},
			{0, 0, 1}
	},
	{
			{1, 1, 1},
			{1, 0, 0},
			{1, 1, 1},
			{0, 0, 1},
			{1, 1, 1}
	},
	{
			{1, 1, 1},
			{1, 0, 0},
			{1, 1, 1},
			{1, 0, 1},
			{1, 1, 1}
	},
	{
			{1, 1, 1},
			{0, 0, 1},
			{0, 0, 1},
			{0, 0, 1},
			{0, 0, 1}
	},
	{
			{1, 1, 1},
			{1, 0, 1},
			{1, 1, 1},
			{1, 0, 1},
			{1, 1, 1}
	},
	{
			{1, 1, 1},
			{1, 0, 1},
			{1, 1, 1},
			{0, 0, 1},
			{1, 1, 1}
	}
};

void putDigit(uint8_t x, uint8_t y, uint8_t digit, uint16_t color, uint16_t bkcolor) {
    for (uint8_t i=0; i < 5; i++) {
        for (uint8_t j=0; j < 3; j++) {
            if (digits[digit][i][j] == 1) {
                putPixel(x+j, y+i, color);
            } else {
                putPixel(x+j, y+i, bkcolor);
            }
        }
    }
}

