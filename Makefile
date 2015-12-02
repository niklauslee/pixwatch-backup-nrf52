PROJECT_NAME := pixwatch

export OUTPUT_FILENAME
#MAKEFILE_NAME := $(CURDIR)/$(word $(words $(MAKEFILE_LIST)),$(MAKEFILE_LIST))
MAKEFILE_NAME := $(MAKEFILE_LIST)
MAKEFILE_DIR := $(dir $(MAKEFILE_NAME) ) 

TEMPLATE_PATH = nrf52_sdk/components/toolchain/gcc
ifeq ($(OS),Windows_NT)
include $(TEMPLATE_PATH)/Makefile.windows
else
include $(TEMPLATE_PATH)/Makefile.posix
endif

MK := mkdir
RM := rm -rf

#echo suspend
ifeq ("$(VERBOSE)","1")
NO_ECHO := 
else
NO_ECHO := @
endif

# Toolchain commands
CC              := '$(GNU_INSTALL_ROOT)/bin/$(GNU_PREFIX)-gcc'
AS              := '$(GNU_INSTALL_ROOT)/bin/$(GNU_PREFIX)-as'
AR              := '$(GNU_INSTALL_ROOT)/bin/$(GNU_PREFIX)-ar' -r
LD              := '$(GNU_INSTALL_ROOT)/bin/$(GNU_PREFIX)-ld'
NM              := '$(GNU_INSTALL_ROOT)/bin/$(GNU_PREFIX)-nm'
OBJDUMP         := '$(GNU_INSTALL_ROOT)/bin/$(GNU_PREFIX)-objdump'
OBJCOPY         := '$(GNU_INSTALL_ROOT)/bin/$(GNU_PREFIX)-objcopy'
SIZE            := '$(GNU_INSTALL_ROOT)/bin/$(GNU_PREFIX)-size'

#function for removing duplicates in a list
remduplicates = $(strip $(if $1,$(firstword $1) $(call remduplicates,$(filter-out $(firstword $1),$1))))

# Espruino wrapper sources
ESPRUINO_WRAPPER_SOURCES += \
espruino/src/jswrap_array.c \
espruino/src/jswrap_arraybuffer.c \
espruino/src/jswrap_date.c \
espruino/src/jswrap_error.c \
espruino/src/jswrap_espruino.c \
espruino/src/jswrap_flash.c \
espruino/src/jswrap_functions.c \
espruino/src/jswrap_interactive.c \
espruino/src/jswrap_io.c \
espruino/src/jswrap_json.c \
espruino/src/jswrap_modules.c \
espruino/src/jswrap_number.c \
espruino/src/jswrap_object.c \
espruino/src/jswrap_onewire.c \
espruino/src/jswrap_pin.c \
espruino/src/jswrap_pipe.c \
espruino/src/jswrap_process.c \
espruino/src/jswrap_serial.c \
espruino/src/jswrap_spi_i2c.c \
espruino/src/jswrap_stream.c \
espruino/src/jswrap_string.c \
espruino/src/jswrap_waveform.c

# Espruino sources
ESPRUINO_SOURCES += \
espruino/src/jsvar.c \
espruino/src/jslex.c \
espruino/src/jsvariterator.c \
espruino/src/jsutils.c \
espruino/src/jsnative.c \
espruino/src/jsparse.c \
espruino/src/jspin.c \
espruino/src/jsinteractive.c \
espruino/src/jsdevices.c \
espruino/src/jstimer.c \
espruino/src/jsspi.c \
espruino/gen/jswrapper.c \
espruino/gen/jspininfo.c \
espruino/targets/nrf5x/jshardware.c \
espruino/targets/nrf5x/nrf5x_utils.c \
espruino/libs/math/jswrap_math.c \
espruino/libs/math/acosh.c \
espruino/libs/math/asin.c \
espruino/libs/math/asinh.c \
espruino/libs/math/atan.c \
espruino/libs/math/atanh.c \
espruino/libs/math/cbrt.c \
espruino/libs/math/chbevl.c \
espruino/libs/math/clog.c \
espruino/libs/math/cmplx.c \
espruino/libs/math/const.c \
espruino/libs/math/cosh.c \
espruino/libs/math/drand.c \
espruino/libs/math/exp10.c \
espruino/libs/math/exp2.c \
espruino/libs/math/exp.c \
espruino/libs/math/fabs.c \
espruino/libs/math/floor.c \
espruino/libs/math/isnan.c \
espruino/libs/math/log10.c \
espruino/libs/math/log2.c \
espruino/libs/math/log.c \
espruino/libs/math/mtherr.c \
espruino/libs/math/polevl.c \
espruino/libs/math/pow.c \
espruino/libs/math/powi.c \
espruino/libs/math/round.c \
espruino/libs/math/setprec.c \
espruino/libs/math/sin.c \
espruino/libs/math/sincos.c \
espruino/libs/math/sindg.c \
espruino/libs/math/sinh.c \
espruino/libs/math/sqrt.c \
espruino/libs/math/tan.c \
espruino/libs/math/tandg.c \
espruino/libs/math/tanh.c \
espruino/libs/math/unity.c \

# NRF52 sdk sources
NRF_SOURCES += \
nrf52_sdk/components/libraries/button/app_button.c \
nrf52_sdk/components/libraries/util/app_error.c \
nrf52_sdk/components/libraries/util/nrf_assert.c \
nrf52_sdk/components/libraries/fifo/app_fifo.c \
nrf52_sdk/components/libraries/scheduler/app_scheduler.c \
nrf52_sdk/components/libraries/timer/app_timer.c \
nrf52_sdk/components/libraries/timer/app_timer_appsh.c \
nrf52_sdk/components/libraries/trace/app_trace.c \
nrf52_sdk/components/libraries/uart/retarget.c \
nrf52_sdk/components/libraries/uart/app_uart_fifo.c \
nrf52_sdk/components/drivers_nrf/delay/nrf_delay.c \
nrf52_sdk/components/drivers_nrf/common/nrf_drv_common.c \
nrf52_sdk/components/drivers_nrf/gpiote/nrf_drv_gpiote.c \
nrf52_sdk/components/drivers_nrf/uart/nrf_drv_uart.c \
nrf52_sdk/components/drivers_nrf/pstorage/pstorage.c \
nrf52_sdk/components/drivers_nrf/spi_master/nrf_drv_spi.c \
nrf52_sdk/components/ble/ble_advertising/ble_advertising.c \
nrf52_sdk/components/ble/ble_db_discovery/ble_db_discovery.c \
nrf52_sdk/components/ble/common/ble_advdata.c \
nrf52_sdk/components/ble/common/ble_conn_params.c \
nrf52_sdk/components/ble/common/ble_srv_common.c \
nrf52_sdk/components/ble/device_manager/device_manager_peripheral.c \
nrf52_sdk/components/softdevice/common/softdevice_handler/softdevice_handler.c \
nrf52_sdk/components/toolchain/system_nrf52.c \

# pixwatch sources
SOURCES += \
src/main.c \
src/ble_pixwatch_c.c \
src/display.c \

#source common to all targets
C_SOURCE_FILES += \
$(NRF_SOURCES) \
$(ESPRUINO_SOURCES) \
$(ESPRUINO_WRAPPER_SOURCES) \
$(SOURCES)

#assembly files common to all targets
ASM_SOURCE_FILES  = nrf52_sdk/components/toolchain/gcc/gcc_startup_nrf52.s

#includes common to all targets
INC_PATHS  = -Iconfig
INC_PATHS += -Inrf52_sdk/components/libraries/scheduler
INC_PATHS += -Inrf52_sdk/components/drivers_nrf/config
INC_PATHS += -Inrf52_sdk/components/libraries/fifo
INC_PATHS += -Inrf52_sdk/components/drivers_nrf/delay
INC_PATHS += -Inrf52_sdk/components/softdevice/s132/headers/nrf52
INC_PATHS += -Inrf52_sdk/components/libraries/util
INC_PATHS += -Inrf52_sdk/components/drivers_nrf/pstorage
INC_PATHS += -Inrf52_sdk/components/drivers_nrf/uart
INC_PATHS += -Inrf52_sdk/components/ble/common
INC_PATHS += -Inrf52_sdk/components/ble/device_manager
INC_PATHS += -Inrf52_sdk/components/libraries/uart
INC_PATHS += -Inrf52_sdk/components/device
INC_PATHS += -Inrf52_sdk/components/ble/ble_db_discovery
INC_PATHS += -Inrf52_sdk/components/libraries/button
INC_PATHS += -Inrf52_sdk/components/libraries/timer
INC_PATHS += -Inrf52_sdk/components/softdevice/s132/headers
INC_PATHS += -Inrf52_sdk/components/drivers_nrf/gpiote
INC_PATHS += -Inrf52_sdk/components/drivers_nrf/hal
INC_PATHS += -Inrf52_sdk/components/toolchain/gcc
INC_PATHS += -Inrf52_sdk/components/toolchain
INC_PATHS += -Inrf52_sdk/components/drivers_nrf/common
INC_PATHS += -Inrf52_sdk/components/drivers_nrf/spi_master
INC_PATHS += -Inrf52_sdk/components/ble/ble_advertising
INC_PATHS += -Inrf52_sdk/components/libraries/trace
INC_PATHS += -Inrf52_sdk/components/softdevice/common/softdevice_handler
INC_PATHS += -Isrc
INC_PATHS += -Iespruino/src
INC_PATHS += -Iespruino/gen
INC_PATHS += -Iespruino/targets/nrf5x
INC_PATHS += -Iespruino/libs/math

LIBS += $(GNU_INSTALL_ROOT)/arm-none-eabi/lib/fpu/libm.a

OBJECT_DIRECTORY = _build
LISTING_DIRECTORY = $(OBJECT_DIRECTORY)
OUTPUT_BINARY_DIRECTORY = $(OBJECT_DIRECTORY)

# Sorting removes duplicates
BUILD_DIRECTORIES := $(sort $(OBJECT_DIRECTORY) $(OUTPUT_BINARY_DIRECTORY) $(LISTING_DIRECTORY) )

# Optimize flags
OPTIMIZE_FLAGS += -fno-common -fno-exceptions -fdata-sections -ffunction-sections
# Enable link-time optimisations (inlining across files)
OPTIMIZE_FLAGS += -flto -fno-fat-lto-objects -Wl,--allow-multiple-definition
# Limit code size growth via inlining to 8% Normally 30% it seems... This reduces code size while still being able to use -O3
OPTIMIZE_FLAGS += --param inline-unit-growth=6

#flags common to all targets
CFLAGS  = -DSWI_DISABLE0
CFLAGS += -DSOFTDEVICE_PRESENT
CFLAGS += -DNRF52
CFLAGS += -DCONFIG_GPIO_AS_PINRESET
CFLAGS += -DS132
CFLAGS += -DBLE_STACK_SUPPORT_REQD
CFLAGS += -DLINK_TIME_OPTIMISATION
CFLAGS += -mcpu=cortex-m4
CFLAGS += -mthumb -mabi=aapcs -std=gnu99 -lm
CFLAGS += -Wall -O3 -Werror=implicit-function-declaration
CFLAGS += -mfloat-abi=hard -mfpu=fpv4-sp-d16
# keep every function in separate section. This will allow linker to dump unused functions
CFLAGS += $(OPTIMIZE_FLAGS) -fno-strict-aliasing
CFLAGS += -fno-builtin --short-enums

# keep every function in separate section. This will allow linker to dump unused functions
LDFLAGS += -Winline
LDFLAGS += -Xlinker -Map=$(LISTING_DIRECTORY)/$(OUTPUT_FILENAME).map
LDFLAGS += -mthumb -mabi=aapcs -L $(TEMPLATE_PATH) -T$(LINKER_SCRIPT)
LDFLAGS += -mcpu=cortex-m4
LDFLAGS += -mfloat-abi=hard -mfpu=fpv4-sp-d16
# let linker to dump unused sections
LDFLAGS += -Wl,--gc-sections
# use newlib in nano version
LDFLAGS += --specs=nano.specs -lc -lm -lnosys

# Assembler flags
ASMFLAGS += -x assembler-with-cpp
ASMFLAGS += -DSWI_DISABLE0
ASMFLAGS += -DSOFTDEVICE_PRESENT
ASMFLAGS += -DNRF52
ASMFLAGS += -DCONFIG_GPIO_AS_PINRESET
ASMFLAGS += -DS132
ASMFLAGS += -DBLE_STACK_SUPPORT_REQD
#default target - first one defined
default: clean nrf52832_xxaa_s132

#building all targets
all: clean
	$(NO_ECHO)$(MAKE) -f $(MAKEFILE_NAME) -C $(MAKEFILE_DIR) -e cleanobj
	$(NO_ECHO)$(MAKE) -f $(MAKEFILE_NAME) -C $(MAKEFILE_DIR) -e nrf52832_xxaa_s132 

#target for printing all targets
help:
	@echo following targets are available:
	@echo 	nrf52832_xxaa_s132
	@echo 	flash_softdevice


C_SOURCE_FILE_NAMES = $(notdir $(C_SOURCE_FILES))
C_PATHS = $(call remduplicates, $(dir $(C_SOURCE_FILES) ) )
C_OBJECTS = $(addprefix $(OBJECT_DIRECTORY)/, $(C_SOURCE_FILE_NAMES:.c=.o) )

ASM_SOURCE_FILE_NAMES = $(notdir $(ASM_SOURCE_FILES))
ASM_PATHS = $(call remduplicates, $(dir $(ASM_SOURCE_FILES) ))
ASM_OBJECTS = $(addprefix $(OBJECT_DIRECTORY)/, $(ASM_SOURCE_FILE_NAMES:.s=.o) )

vpath %.c $(C_PATHS)
vpath %.s $(ASM_PATHS)

OBJECTS = $(C_OBJECTS) $(ASM_OBJECTS)

nrf52832_xxaa_s132: OUTPUT_FILENAME := pixwatch
nrf52832_xxaa_s132: LINKER_SCRIPT=ldscripts/pixwatch.ld
nrf52832_xxaa_s132: $(BUILD_DIRECTORIES) $(OBJECTS)
	@echo Linking target: $(OUTPUT_FILENAME).out
	$(NO_ECHO)$(CC) $(LDFLAGS) $(OBJECTS) $(LIBS) -o $(OUTPUT_BINARY_DIRECTORY)/$(OUTPUT_FILENAME).out
	$(NO_ECHO)$(MAKE) -f $(MAKEFILE_NAME) -C $(MAKEFILE_DIR) -e finalize

## Create build directories
$(BUILD_DIRECTORIES):
	echo $(MAKEFILE_NAME)
	$(MK) $@

# Create objects from C SRC files
$(OBJECT_DIRECTORY)/%.o: %.c
	@echo Compiling file: $(notdir $<)
	$(NO_ECHO)$(CC) $(CFLAGS) $(INC_PATHS) -c -o $@ $<

# Assemble files
$(OBJECT_DIRECTORY)/%.o: %.s
	@echo Compiling file: $(notdir $<)
	$(NO_ECHO)$(CC) $(ASMFLAGS) $(INC_PATHS) -c -o $@ $<


# Link
$(OUTPUT_BINARY_DIRECTORY)/$(OUTPUT_FILENAME).out: $(BUILD_DIRECTORIES) $(OBJECTS)
	@echo Linking target: $(OUTPUT_FILENAME).out
	$(NO_ECHO)$(CC) $(LDFLAGS) $(OBJECTS) $(LIBS) -o $(OUTPUT_BINARY_DIRECTORY)/$(OUTPUT_FILENAME).out


## Create binary .bin file from the .out file
$(OUTPUT_BINARY_DIRECTORY)/$(OUTPUT_FILENAME).bin: $(OUTPUT_BINARY_DIRECTORY)/$(OUTPUT_FILENAME).out
	@echo Preparing: $(OUTPUT_FILENAME).bin
	$(NO_ECHO)$(OBJCOPY) -O binary $(OUTPUT_BINARY_DIRECTORY)/$(OUTPUT_FILENAME).out $(OUTPUT_BINARY_DIRECTORY)/$(OUTPUT_FILENAME).bin

## Create binary .hex file from the .out file
$(OUTPUT_BINARY_DIRECTORY)/$(OUTPUT_FILENAME).hex: $(OUTPUT_BINARY_DIRECTORY)/$(OUTPUT_FILENAME).out
	@echo Preparing: $(OUTPUT_FILENAME).hex
	$(NO_ECHO)$(OBJCOPY) -O ihex $(OUTPUT_BINARY_DIRECTORY)/$(OUTPUT_FILENAME).out $(OUTPUT_BINARY_DIRECTORY)/$(OUTPUT_FILENAME).hex

finalize: genbin genhex echosize

genbin:
	@echo Preparing: $(OUTPUT_FILENAME).bin
	$(NO_ECHO)$(OBJCOPY) -O binary $(OUTPUT_BINARY_DIRECTORY)/$(OUTPUT_FILENAME).out $(OUTPUT_BINARY_DIRECTORY)/$(OUTPUT_FILENAME).bin

## Create binary .hex file from the .out file
genhex: 
	@echo Preparing: $(OUTPUT_FILENAME).hex
	$(NO_ECHO)$(OBJCOPY) -O ihex $(OUTPUT_BINARY_DIRECTORY)/$(OUTPUT_FILENAME).out $(OUTPUT_BINARY_DIRECTORY)/$(OUTPUT_FILENAME).hex

echosize:
	-@echo ''
	$(NO_ECHO)$(SIZE) $(OUTPUT_BINARY_DIRECTORY)/$(OUTPUT_FILENAME).out
	-@echo ''

clean:
	$(RM) $(BUILD_DIRECTORIES)

cleanobj:
	$(RM) $(BUILD_DIRECTORIES)/*.o

flash: $(MAKECMDGOALS)
	@echo Flashing: $(OUTPUT_BINARY_DIRECTORY)/$(PROJECT_NAME).hex
	./nrfjprog.sh --program $(OUTPUT_BINARY_DIRECTORY)/$(PROJECT_NAME).hex 0x1f000

## Flash softdevice
flash_softdevice:
	@echo Flashing: s132_nrf52_1.0.0-3.alpha_softdevice.hex
	./nrfjprog.sh --erasepage 0x0-0x1f000 -f nrf52
	./nrfjprog.sh --program ./src/components/softdevice/s132/hex/s132_nrf52_1.0.0-3.alpha_softdevice.hex -f nrf52
	./nrfjprog.sh --reset