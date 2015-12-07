GNU_INSTALL_ROOT := /usr/local/gcc_arm/gcc-arm-none-eabi-4_9-2015q3/bin/
GNU_VERSION := 4.9.3
GNU_PREFIX := arm-none-eabi

PROJ_NAME=main

# echo suspend
ifeq ("$(VERBOSE)","1")
NO_ECHO := 
else
NO_ECHO := @
endif

# toolchain commands
CC      := '$(GNU_INSTALL_ROOT)$(GNU_PREFIX)-gcc'
GDB     := '$(GNU_INSTALL_ROOT)$(GNU_PREFIX)-gdb'
OBJCOPY := '$(GNU_INSTALL_ROOT)$(GNU_PREFIX)-objcopy'

SRCS = \
drivers/STM32F4xx_HAL_Driver/Src/stm32f4xx_hal.c \
drivers/STM32F4xx_HAL_Driver/Src/stm32f4xx_hal_cortex.c \
drivers/STM32F4xx_HAL_Driver/Src/stm32f4xx_hal_rcc.c \
drivers/STM32F4xx_HAL_Driver/Src/stm32f4xx_hal_pwr_ex.c \
drivers/STM32F4xx_HAL_Driver/Src/stm32f4xx_hal_gpio.c \
drivers/STM32F4xx_HAL_Driver/Src/stm32f4xx_hal_uart.c \
drivers/STM32F4xx_HAL_Driver/Src/stm32f4xx_hal_dma.c \
drivers/STM32F4xx_HAL_Driver/Src/stm32f4xx_hal_dma_ex.c \
drivers/CMSIS/Device/ST/STM32F4xx/Source/Templates/system_stm32f4xx.c \
duktape/duktape.c \
src/main.c \
src/stm32f4xx_it.c \
src/startup_stm32f446xx.s \

OBJDIR = _build

CFLAGS += -DSTM32F446xx
CFLAGS += -DUSE_HAL_DRIVER
CFLAGS += -DUSE_STM32F4XX_NUCLEO
CFLAGS += -DUSE_IOEXPANDER
CFLAGS += -D_ARM -DDUK_OPT_DEBUG_BUFSIZE=2048
CFLAGS += -g -Wall -Os -Wno-missing-braces -std=gnu99
CFLAGS += -mthumb -mcpu=cortex-m4
CFLAGS += -mfloat-abi=hard -mfpu=fpv4-sp-d16

# TODO: hard float was causing an exception; see what's up.
LDFLAGS  = -specs=rdimon.specs -lc -lrdimon
LDFLAGS += -Wl,-Map,$(OBJDIR)/$(PROJ_NAME).map -g -Tldscripts/STM32F446RETx_FLASH.ld

INC_PATHS += -Idrivers/BSP/STM32F4xx-Nucleo
INC_PATHS += -Idrivers/STM32F4xx_HAL_Driver/Inc
INC_PATHS += -Idrivers/CMSIS/Device/ST/STM32F4xx/Include
INC_PATHS += -Idrivers/CMSIS/Include
INC_PATHS += -Iduktape
INC_PATHS += -Isrc

OBJS := $(SRCS:.c=.o)
OBJS := $(OBJS:.s=.o)
OBJS := $(addprefix $(OBJDIR)/,$(OBJS))


all: $(OBJDIR)/$(PROJ_NAME).elf $(OBJDIR)/$(PROJ_NAME).hex $(OBJDIR)/$(PROJ_NAME).bin

$(OBJDIR)/%.elf: $(OBJS)
	@echo Linking target: $(PROJ_NAME).elf
	$(NO_ECHO)$(CC) $(CFLAGS) $(INC_PATHS) -o $@ $^ $(LDFLAGS)

%.hex: %.elf
	@echo Preparing: $(PROJ_NAME).hex
	$(NO_ECHO)$(OBJCOPY) -O ihex $^ $@

%.bin: %.elf
	@echo Preparing: $(PROJ_NAME).bin
	$(NO_ECHO)$(OBJCOPY) -O binary $^ $@

$(OBJDIR)/%.o: %.c
	$(NO_ECHO)mkdir -p $(dir $@)
	@echo Compiling file: $(notdir $<)
	$(NO_ECHO)$(CC) -c $(CFLAGS) $(INC_PATHS) -o $@ $^

$(OBJDIR)/%.o: %.s
	@echo Compiling file: $(notdir $<)
	$(NO_ECHO)$(CC) -c $(CFLAGS) $(INC_PATHS) -o $@ $^

$(OBJDIR):
	mkdir -p $@

clean:
	$(NO_ECHO)rm -rf $(OBJDIR)

gdb:
	echo "tar ext: 3333" > gdbinit
	echo "file $(OBJDIR)/$(PROJ_NAME).elf" >> gdbinit
	echo "mon reset halt" >> gdbinit
	echo "mon arm semihosting enable" >> gdbinit
	echo "load" >> gdbinit
	$(GDB) -x gdbinit
	rm gdbinit	

# Dependdencies
$(OBJDIR)/$(PROJ_NAME).elf: $(OBJS) | $(OBJDIR)