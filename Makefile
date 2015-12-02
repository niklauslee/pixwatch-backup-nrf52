PROJECT_NAME := pixwatch

export OUTPUT_FILENAME
#MAKEFILE_NAME := $(CURDIR)/$(word $(words $(MAKEFILE_LIST)),$(MAKEFILE_LIST))
MAKEFILE_NAME := $(MAKEFILE_LIST)
MAKEFILE_DIR := $(dir $(MAKEFILE_NAME) ) 

TEMPLATE_PATH = ./nrf52_sdk/components/toolchain/gcc
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
CPP             := '$(GNU_INSTALL_ROOT)/bin/$(GNU_PREFIX)-g++'
AS              := '$(GNU_INSTALL_ROOT)/bin/$(GNU_PREFIX)-as'
AR              := '$(GNU_INSTALL_ROOT)/bin/$(GNU_PREFIX)-ar' -r
LD              := '$(GNU_INSTALL_ROOT)/bin/$(GNU_PREFIX)-ld'
NM              := '$(GNU_INSTALL_ROOT)/bin/$(GNU_PREFIX)-nm'
OBJDUMP         := '$(GNU_INSTALL_ROOT)/bin/$(GNU_PREFIX)-objdump'
OBJCOPY         := '$(GNU_INSTALL_ROOT)/bin/$(GNU_PREFIX)-objcopy'
SIZE            := '$(GNU_INSTALL_ROOT)/bin/$(GNU_PREFIX)-size'

#function for removing duplicates in a list
remduplicates = $(strip $(if $1,$(firstword $1) $(call remduplicates,$(filter-out $(firstword $1),$1))))

#jerryscript
CPP_SOURCE_FILES += \
jerryscript/jerry-core/jerry.cpp \
jerryscript/jerry-core/lit/lit-char-helpers.cpp \
jerryscript/jerry-core/lit/lit-literal-storage.cpp \
jerryscript/jerry-core/lit/lit-literal.cpp \
jerryscript/jerry-core/lit/lit-magic-strings.cpp \
jerryscript/jerry-core/lit/lit-strings.cpp \
jerryscript/jerry-core/rcs/rcs-chunked-list.cpp \
jerryscript/jerry-core/rcs/rcs-recordset.cpp \
jerryscript/jerry-core/mem/mem-allocator.cpp \
jerryscript/jerry-core/mem/mem-heap.cpp \
jerryscript/jerry-core/mem/mem-poolman.cpp \
jerryscript/jerry-core/vm/opcodes-agnostic.cpp \
jerryscript/jerry-core/vm/opcodes-ecma-arithmetics.cpp \
jerryscript/jerry-core/vm/opcodes-ecma-bitwise.cpp \
jerryscript/jerry-core/vm/opcodes-ecma-equality.cpp \
jerryscript/jerry-core/vm/opcodes-ecma-relational.cpp \
jerryscript/jerry-core/vm/opcodes-ecma-try-catch-finally.cpp \
jerryscript/jerry-core/vm/opcodes-for-in.cpp \
jerryscript/jerry-core/vm/opcodes-helpers-variables.cpp \
jerryscript/jerry-core/vm/opcodes-varg.cpp \
jerryscript/jerry-core/vm/opcodes.cpp \
jerryscript/jerry-core/vm/pretty-printer.cpp \
jerryscript/jerry-core/vm/vm-stack.cpp \
jerryscript/jerry-core/vm/vm.cpp \
jerryscript/jerry-core/ecma/builtin-objects/ecma-builtin-array-prototype.cpp \
jerryscript/jerry-core/ecma/builtin-objects/ecma-builtin-array.cpp \
jerryscript/jerry-core/ecma/builtin-objects/ecma-builtin-boolean-prototype.cpp \
jerryscript/jerry-core/ecma/builtin-objects/ecma-builtin-boolean.cpp \
jerryscript/jerry-core/ecma/builtin-objects/ecma-builtin-compact-profile-error.cpp \
jerryscript/jerry-core/ecma/builtin-objects/ecma-builtin-date-prototype.cpp \
jerryscript/jerry-core/ecma/builtin-objects/ecma-builtin-date.cpp \
jerryscript/jerry-core/ecma/builtin-objects/ecma-builtin-error-prototype.cpp \
jerryscript/jerry-core/ecma/builtin-objects/ecma-builtin-error.cpp \
jerryscript/jerry-core/ecma/builtin-objects/ecma-builtin-evalerror-prototype.cpp \
jerryscript/jerry-core/ecma/builtin-objects/ecma-builtin-evalerror.cpp \
jerryscript/jerry-core/ecma/builtin-objects/ecma-builtin-function-prototype.cpp \
jerryscript/jerry-core/ecma/builtin-objects/ecma-builtin-function.cpp \
jerryscript/jerry-core/ecma/builtin-objects/ecma-builtin-global.cpp \
jerryscript/jerry-core/ecma/builtin-objects/ecma-builtin-helpers-date.cpp \
jerryscript/jerry-core/ecma/builtin-objects/ecma-builtin-helpers-json.cpp \
jerryscript/jerry-core/ecma/builtin-objects/ecma-builtin-helpers.cpp \
jerryscript/jerry-core/ecma/builtin-objects/ecma-builtin-json.cpp \
jerryscript/jerry-core/ecma/builtin-objects/ecma-builtin-math.cpp \
jerryscript/jerry-core/ecma/builtin-objects/ecma-builtin-number-prototype.cpp \
jerryscript/jerry-core/ecma/builtin-objects/ecma-builtin-number.cpp \
jerryscript/jerry-core/ecma/builtin-objects/ecma-builtin-object-prototype.cpp \
jerryscript/jerry-core/ecma/builtin-objects/ecma-builtin-object.cpp \
jerryscript/jerry-core/ecma/builtin-objects/ecma-builtin-rangeerror-prototype.cpp \
jerryscript/jerry-core/ecma/builtin-objects/ecma-builtin-rangeerror.cpp \
jerryscript/jerry-core/ecma/builtin-objects/ecma-builtin-referenceerror-prototype.cpp \
jerryscript/jerry-core/ecma/builtin-objects/ecma-builtin-referenceerror.cpp \
jerryscript/jerry-core/ecma/builtin-objects/ecma-builtin-regexp-prototype.cpp \
jerryscript/jerry-core/ecma/builtin-objects/ecma-builtin-regexp.cpp \
jerryscript/jerry-core/ecma/builtin-objects/ecma-builtin-string-prototype.cpp \
jerryscript/jerry-core/ecma/builtin-objects/ecma-builtin-string.cpp \
jerryscript/jerry-core/ecma/builtin-objects/ecma-builtin-syntaxerror-prototype.cpp \
jerryscript/jerry-core/ecma/builtin-objects/ecma-builtin-syntaxerror.cpp \
jerryscript/jerry-core/ecma/builtin-objects/ecma-builtin-type-error-thrower.cpp \
jerryscript/jerry-core/ecma/builtin-objects/ecma-builtin-typeerror-prototype.cpp \
jerryscript/jerry-core/ecma/builtin-objects/ecma-builtin-typeerror.cpp \
jerryscript/jerry-core/ecma/builtin-objects/ecma-builtin-urierror-prototype.cpp \
jerryscript/jerry-core/ecma/builtin-objects/ecma-builtin-urierror.cpp \
jerryscript/jerry-core/ecma/builtin-objects/ecma-builtins.cpp \
jerryscript/jerry-core/ecma/base/ecma-alloc.cpp \
jerryscript/jerry-core/ecma/base/ecma-gc.cpp \
jerryscript/jerry-core/ecma/base/ecma-helpers.cpp \
jerryscript/jerry-core/ecma/base/ecma-helpers-conversion.cpp \
jerryscript/jerry-core/ecma/base/ecma-helpers-external-pointers.cpp \
jerryscript/jerry-core/ecma/base/ecma-helpers-number.cpp \
jerryscript/jerry-core/ecma/base/ecma-helpers-string.cpp \
jerryscript/jerry-core/ecma/base/ecma-helpers-value.cpp \
jerryscript/jerry-core/ecma/base/ecma-helpers-values-collection.cpp \
jerryscript/jerry-core/ecma/base/ecma-init-finalize.cpp \
jerryscript/jerry-core/ecma/base/ecma-lcache.cpp \
jerryscript/jerry-core/ecma/operations/ecma-array-object.cpp \
jerryscript/jerry-core/ecma/operations/ecma-boolean-object.cpp \
jerryscript/jerry-core/ecma/operations/ecma-comparison.cpp \
jerryscript/jerry-core/ecma/operations/ecma-conversion.cpp \
jerryscript/jerry-core/ecma/operations/ecma-eval.cpp \
jerryscript/jerry-core/ecma/operations/ecma-exceptions.cpp \
jerryscript/jerry-core/ecma/operations/ecma-function-object.cpp \
jerryscript/jerry-core/ecma/operations/ecma-get-put-value.cpp \
jerryscript/jerry-core/ecma/operations/ecma-lex-env.cpp \
jerryscript/jerry-core/ecma/operations/ecma-number-arithmetic.cpp \
jerryscript/jerry-core/ecma/operations/ecma-number-object.cpp \
jerryscript/jerry-core/ecma/operations/ecma-objects-arguments.cpp \
jerryscript/jerry-core/ecma/operations/ecma-objects-general.cpp \
jerryscript/jerry-core/ecma/operations/ecma-objects.cpp \
jerryscript/jerry-core/ecma/operations/ecma-reference.cpp \
jerryscript/jerry-core/ecma/operations/ecma-regexp-object.cpp \
jerryscript/jerry-core/ecma/operations/ecma-string-object.cpp \
jerryscript/jerry-core/parser/js/jsp-early-error.cpp \
jerryscript/jerry-core/parser/js/jsp-label.cpp \
jerryscript/jerry-core/parser/js/jsp-mm.cpp \
jerryscript/jerry-core/parser/js/lexer.cpp \
jerryscript/jerry-core/parser/js/opcodes-dumper.cpp \
jerryscript/jerry-core/parser/js/parser.cpp \
jerryscript/jerry-core/parser/js/scopes-tree.cpp \
jerryscript/jerry-core/parser/js/serializer.cpp \
jerryscript/jerry-core/parser/js/collections/array-list.cpp \
jerryscript/jerry-core/parser/js/collections/hash-table.cpp \
jerryscript/jerry-core/parser/js/collections/linked-list.cpp \
jerryscript/jerry-core/parser/js/collections/lit-id-hash-table.cpp \
jerryscript/jerry-core/parser/regexp/re-compiler.cpp \
jerryscript/jerry-core/parser/regexp/re-parser.cpp \
jerryscript/jerry-core/jrt/jrt-bit-fields.cpp \
jerryscript/jerry-core/jrt/jrt-fatals.cpp \


#source common to all targets
C_SOURCE_FILES += \
./nrf52_sdk/components/libraries/button/app_button.c \
./nrf52_sdk/components/libraries/util/app_error.c \
./nrf52_sdk/components/libraries/util/nrf_assert.c \
./nrf52_sdk/components/libraries/fifo/app_fifo.c \
./nrf52_sdk/components/libraries/scheduler/app_scheduler.c \
./nrf52_sdk/components/libraries/timer/app_timer.c \
./nrf52_sdk/components/libraries/timer/app_timer_appsh.c \
./nrf52_sdk/components/libraries/trace/app_trace.c \
./nrf52_sdk/components/libraries/uart/retarget.c \
./nrf52_sdk/components/libraries/uart/app_uart_fifo.c \
./nrf52_sdk/components/drivers_nrf/delay/nrf_delay.c \
./nrf52_sdk/components/drivers_nrf/common/nrf_drv_common.c \
./nrf52_sdk/components/drivers_nrf/gpiote/nrf_drv_gpiote.c \
./nrf52_sdk/components/drivers_nrf/uart/nrf_drv_uart.c \
./nrf52_sdk/components/drivers_nrf/pstorage/pstorage.c \
./nrf52_sdk/components/drivers_nrf/spi_master/nrf_drv_spi.c \
./nrf52_sdk/components/ble/ble_advertising/ble_advertising.c \
./nrf52_sdk/components/ble/ble_db_discovery/ble_db_discovery.c \
./nrf52_sdk/components/ble/common/ble_advdata.c \
./nrf52_sdk/components/ble/common/ble_conn_params.c \
./nrf52_sdk/components/ble/common/ble_srv_common.c \
./nrf52_sdk/components/ble/device_manager/device_manager_peripheral.c \
./nrf52_sdk/components/softdevice/common/softdevice_handler/softdevice_handler.c \
./nrf52_sdk/components/toolchain/system_nrf52.c \
./src/main.c \
./src/ble_pixwatch_c.c \
./src/display.c \

#assembly files common to all targets
ASM_SOURCE_FILES  = ./nrf52_sdk/components/toolchain/gcc/gcc_startup_nrf52.s

#includes common to all targets
INC_PATHS  = -I./config
INC_PATHS += -I./nrf52_sdk/components/libraries/scheduler
INC_PATHS += -I./nrf52_sdk/components/drivers_nrf/config
INC_PATHS += -I./nrf52_sdk/components/libraries/fifo
INC_PATHS += -I./nrf52_sdk/components/drivers_nrf/delay
INC_PATHS += -I./nrf52_sdk/components/softdevice/s132/headers/nrf52
INC_PATHS += -I./nrf52_sdk/components/libraries/util
INC_PATHS += -I./nrf52_sdk/components/drivers_nrf/pstorage
INC_PATHS += -I./nrf52_sdk/components/drivers_nrf/uart
INC_PATHS += -I./nrf52_sdk/components/ble/common
INC_PATHS += -I./nrf52_sdk/components/ble/device_manager
INC_PATHS += -I./nrf52_sdk/components/libraries/uart
INC_PATHS += -I./nrf52_sdk/components/device
INC_PATHS += -I./nrf52_sdk/components/ble/ble_db_discovery
INC_PATHS += -I./nrf52_sdk/components/libraries/button
INC_PATHS += -I./nrf52_sdk/components/libraries/timer
INC_PATHS += -I./nrf52_sdk/components/softdevice/s132/headers
INC_PATHS += -I./nrf52_sdk/components/drivers_nrf/gpiote
INC_PATHS += -I./nrf52_sdk/components/drivers_nrf/hal
INC_PATHS += -I./nrf52_sdk/components/toolchain/gcc
INC_PATHS += -I./nrf52_sdk/components/toolchain
INC_PATHS += -I./nrf52_sdk/components/drivers_nrf/common
INC_PATHS += -I./nrf52_sdk/components/drivers_nrf/spi_master
INC_PATHS += -I./nrf52_sdk/components/ble/ble_advertising
INC_PATHS += -I./nrf52_sdk/components/libraries/trace
INC_PATHS += -I./nrf52_sdk/components/softdevice/common/softdevice_handler
INC_PATHS += -I./src
INC_PATHS += -I./jerryscript/jerry-core
INC_PATHS += -I./jerryscript/jerry-core/lit
INC_PATHS += -I./jerryscript/jerry-core/rcs
INC_PATHS += -I./jerryscript/jerry-core/mem
INC_PATHS += -I./jerryscript/jerry-core/vm
INC_PATHS += -I./jerryscript/jerry-core/ecma/builtin-objects
INC_PATHS += -I./jerryscript/jerry-core/ecma/base
INC_PATHS += -I./jerryscript/jerry-core/ecma/operations
INC_PATHS += -I./jerryscript/jerry-core/parser/js
INC_PATHS += -I./jerryscript/jerry-core/parser/js/collections
INC_PATHS += -I./jerryscript/jerry-core/parser/regexp
INC_PATHS += -I./jerryscript/jerry-core/jrt
INC_PATHS += -I./jerryscript/third-party/fdlibm/include

LIBS += $(GNU_INSTALL_ROOT)/arm-none-eabi/lib/fpu/libm.a

OBJECT_DIRECTORY = _build
LISTING_DIRECTORY = $(OBJECT_DIRECTORY)
OUTPUT_BINARY_DIRECTORY = $(OBJECT_DIRECTORY)

# Sorting removes duplicates
BUILD_DIRECTORIES := $(sort $(OBJECT_DIRECTORY) $(OUTPUT_BINARY_DIRECTORY) $(LISTING_DIRECTORY) )

#flags common to all targets
CFLAGS  = -DSWI_DISABLE0
CFLAGS += -DSOFTDEVICE_PRESENT
CFLAGS += -DNRF52
CFLAGS += -DCONFIG_GPIO_AS_PINRESET
CFLAGS += -DS132
CFLAGS += -DBLE_STACK_SUPPORT_REQD
CFLAGS += -mcpu=cortex-m4
CFLAGS += -mthumb -mabi=aapcs --std=gnu99
CFLAGS += -Wall -Werror -O3
CFLAGS += -mfloat-abi=hard -mfpu=fpv4-sp-d16
# keep every function in separate section. This will allow linker to dump unused functions
CFLAGS += -ffunction-sections -fdata-sections -fno-strict-aliasing
CFLAGS += -fno-builtin --short-enums

#flags common to all targets
CPPFLAGS += -mcpu=cortex-m4
CPPFLAGS += -mthumb -mabi=aapcs -std=c++11
CPPFLAGS += -Wall -Os
CPPFLAGS += -mfloat-abi=hard -mfpu=fpv4-sp-d16
CPPFLAGS += -fno-exceptions -fno-rtti -fno-implicit-templates -fno-implicit-inline-templates

# keep every function in separate section. This will allow linker to dump unused functions
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

CPP_SOURCE_FILE_NAMES = $(notdir $(CPP_SOURCE_FILES))
CPP_PATHS = $(call remduplicates, $(dir $(CPP_SOURCE_FILES) ) )
CPP_OBJECTS = $(addprefix $(OBJECT_DIRECTORY)/, $(CPP_SOURCE_FILE_NAMES:.cpp=.o) )

ASM_SOURCE_FILE_NAMES = $(notdir $(ASM_SOURCE_FILES))
ASM_PATHS = $(call remduplicates, $(dir $(ASM_SOURCE_FILES) ))
ASM_OBJECTS = $(addprefix $(OBJECT_DIRECTORY)/, $(ASM_SOURCE_FILE_NAMES:.s=.o) )

vpath %.c $(C_PATHS)
vpath %.cpp $(CPP_PATHS)
vpath %.s $(ASM_PATHS)

OBJECTS = $(C_OBJECTS) $(ASM_OBJECTS) $(CPP_OBJECTS)

nrf52832_xxaa_s132: OUTPUT_FILENAME := pixwatch
nrf52832_xxaa_s132: LINKER_SCRIPT=./ldscripts/pixwatch.ld
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

# Create objects from C++ SRC files
$(OBJECT_DIRECTORY)/%.o: %.cpp
	@echo Compiling file: $(notdir $<)
	$(NO_ECHO)$(CPP) $(CPPFLAGS) $(INC_PATHS) -c -o $@ $<

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