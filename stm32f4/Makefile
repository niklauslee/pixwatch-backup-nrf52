PROJ_NAME=main

SRCS = \
drivers/STM32F4xx_HAL_Driver/Src/stm32f4xx_hal.c \
drivers/STM32F4xx_HAL_Driver/Src/stm32f4xx_hal_cortex.c \
drivers/STM32F4xx_HAL_Driver/Src/stm32f4xx_hal_rcc.c \
drivers/STM32F4xx_HAL_Driver/Src/stm32f4xx_hal_pwr_ex.c \
drivers/STM32F4xx_HAL_Driver/Src/stm32f4xx_hal_gpio.c \
drivers/CMSIS/Device/ST/STM32F4xx/Source/Templates/system_stm32f4xx.c \
src/main.c \
src/stm32f4xx_it.c \
src/startup_stm32f446xx.s \

CC=arm-none-eabi-gcc
OBJCOPY=arm-none-eabi-objcopy

OBJDIR = _build

CFLAGS += -DSTM32F446xx
CFLAGS += -DUSE_HAL_DRIVER
CFLAGS += -g -Wall -Wno-missing-braces -std=c99
CFLAGS += -mthumb -mcpu=cortex-m4
#CFLAGS += -mlittle-endian -mthumb -mcpu=cortex-m4 -mthumb-interwork
#CFLAGS += -mfloat-abi=hard -mfpu=fpv4-sp-d16
CFLAGS += -mfloat-abi=soft
# TODO: hard float was causing an exception; see what's up.
LDFLAGS = --specs=nosys.specs -Wl,-Map,$(OBJDIR)/$(PROJ_NAME).map -g -Tldscripts/STM32F446RETx_FLASH.ld

INC_PATHS += -Idrivers/BSP/STM32F4xx-Nucleo
INC_PATHS += -Idrivers/STM32F4xx_HAL_Driver/Inc
INC_PATHS += -Idrivers/CMSIS/Device/ST/STM32F4xx/Include
INC_PATHS += -Idrivers/CMSIS/Include
INC_PATHS += -Isrc

OBJS := $(SRCS:.c=.o)
OBJS := $(OBJS:.s=.o)
OBJS := $(addprefix $(OBJDIR)/,$(OBJS))


all: $(OBJDIR)/$(PROJ_NAME).elf $(OBJDIR)/$(PROJ_NAME).hex $(OBJDIR)/$(PROJ_NAME).bin

$(OBJDIR)/%.elf: $(OBJS)
	$(CC) $(CFLAGS) $(INC_PATHS) -o $@ $^ $(LDFLAGS)

%.hex: %.elf
	$(OBJCOPY) -O ihex $^ $@

%.bin: %.elf
	$(OBJCOPY) -O binary $^ $@

$(OBJDIR)/%.o: %.c
	mkdir -p $(dir $@)
	$(CC) -c $(CFLAGS) $(INC_PATHS) -o $@ $^

$(OBJDIR)/%.o: %.s
	$(CC) -c $(CFLAGS) $(INC_PATHS) -o $@ $^

$(OBJDIR):
	mkdir -p $@

clean:
	rm -rf $(OBJDIR)

program: $(OBJDIR)/$(PROJ_NAME).elf
	openocd-0.6.1 -f program.cfg


# Dependdencies
$(OBJDIR)/$(PROJ_NAME).elf: $(OBJS) | $(OBJDIR)