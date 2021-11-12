######################################
# Project name
PROJECT = l412-template

######################################
# Build options
DEBUG = 1
OPT = -Og


#######################################
# paths
#######################################
# Build path
BUILD_DIR = build

######################################
# source
HAL = lib/HAL

C_SOURCES =  \
$(HAL)/Src/stm32l4xx_ll_adc.c \
$(HAL)/Src/stm32l4xx_ll_comp.c \
$(HAL)/Src/stm32l4xx_ll_crc.c \
$(HAL)/Src/stm32l4xx_ll_crs.c \
$(HAL)/Src/stm32l4xx_ll_dac.c \
$(HAL)/Src/stm32l4xx_ll_dma.c \
$(HAL)/Src/stm32l4xx_ll_exti.c \
$(HAL)/Src/stm32l4xx_ll_fmc.c \
$(HAL)/Src/stm32l4xx_ll_gpio.c \
$(HAL)/Src/stm32l4xx_ll_i2c.c \
$(HAL)/Src/stm32l4xx_ll_lptim.c \
$(HAL)/Src/stm32l4xx_ll_lpuart.c \
$(HAL)/Src/stm32l4xx_ll_opamp.c \
$(HAL)/Src/stm32l4xx_ll_pwr.c \
$(HAL)/Src/stm32l4xx_ll_rcc.c \
$(HAL)/Src/stm32l4xx_ll_rng.c \
$(HAL)/Src/stm32l4xx_ll_rtc.c \
$(HAL)/Src/stm32l4xx_ll_spi.c \
$(HAL)/Src/stm32l4xx_ll_tim.c \
$(HAL)/Src/stm32l4xx_ll_usart.c \
$(HAL)/Src/stm32l4xx_ll_utils.c \
src/main.c \
src/hardware/nucleo.c \
src/hardware/stm32l4xx_it.c \
src/hardware/system_stm32l4xx.c 

C_INCLUDES =  \
-I. \
-I$(HAL)/Inc \
-Ilib/CMSIS/Device/ST/STM32L4xx/Include \
-Ilib/CMSIS/Include \
-Isrc \
-Isrc/hardware

# ASM sources
ASM_SOURCES = chip/startup_stm32l412xx.s



#######################################
# Toolchain
CC = arm-none-eabi-gcc
AS = arm-none-eabi-gcc -x assembler-with-cpp
CP = arm-none-eabi-objcopy
SZ = arm-none-eabi-size
HEX = $(CP) -O ihex
BIN = $(CP) -O binary -S

# STM32CubeProgrammer, for flashing with `make flash`
CUBEPROG = ~/.STMicroelectronics/STM32Cube/STM32CubeProgrammer/bin/STM32_Programmer.sh
 


#######################################
# CFLAGS
#######################################
# cpu
CPU = -mcpu=cortex-m4
FPU = -mfpu=fpv4-sp-d16
FLOAT-ABI = -mfloat-abi=hard
MCU = $(CPU) -mthumb $(FPU) $(FLOAT-ABI)

# macros for gcc
# AS defines
AS_DEFS = 

# C defines
C_DEFS =  \
-DSTM32L412xx \
-DUSE_FULL_LL_DRIVER

# AS includes
AS_INCLUDES = 

# compile gcc flags
ASFLAGS = $(MCU) $(AS_DEFS) $(AS_INCLUDES) $(OPT) -Wall -fdata-sections -ffunction-sections

CFLAGS = $(MCU) $(C_DEFS) $(C_INCLUDES) $(OPT) -Wall -fdata-sections -ffunction-sections

ifeq ($(DEBUG), 1)
CFLAGS += -g -gdwarf-2
endif


# Generate dependency information
CFLAGS += -MMD -MP -MF"$(@:%.o=%.d)"


#######################################
# LDFLAGS
#######################################
# link script
LDSCRIPT = chip/STM32L412KB.ld

# libraries
LIBS = -lc -lm -lnosys 
LIBDIR = 
LDFLAGS = $(MCU) -specs=nano.specs -T$(LDSCRIPT) $(LIBDIR) $(LIBS) -Wl,-Map=$(BUILD_DIR)/$(PROJECT).map,--cref -Wl,--gc-sections

OBJECTS = $(addprefix $(BUILD_DIR)/,$(notdir $(C_SOURCES:.c=.o)))
vpath %.c $(sort $(dir $(C_SOURCES)))
OBJECTS += $(addprefix $(BUILD_DIR)/,$(notdir $(ASM_SOURCES:.s=.o)))
vpath %.s $(sort $(dir $(ASM_SOURCES)))


#######################################

all: $(BUILD_DIR)/$(PROJECT).elf $(BUILD_DIR)/$(PROJECT).hex $(BUILD_DIR)/$(PROJECT).bin


$(BUILD_DIR)/%.o: %.c Makefile | $(BUILD_DIR) 
	$(CC) -c $(CFLAGS) -Wa,-a,-ad,-alms=$(BUILD_DIR)/$(notdir $(<:.c=.lst)) $< -o $@

$(BUILD_DIR)/%.o: %.s Makefile | $(BUILD_DIR)
	$(AS) -c $(CFLAGS) $< -o $@

$(BUILD_DIR)/$(PROJECT).elf: $(OBJECTS) Makefile
	$(CC) $(OBJECTS) $(LDFLAGS) -o $@
	$(SZ) $@

$(BUILD_DIR)/%.hex: $(BUILD_DIR)/%.elf | $(BUILD_DIR)
	$(HEX) $< $@
	
$(BUILD_DIR)/%.bin: $(BUILD_DIR)/%.elf | $(BUILD_DIR)
	$(BIN) $< $@	
	
$(BUILD_DIR):
	mkdir $@		

flash: all
	@sleep 1
	$(CUBEPROG) -c port=SWD --write `pwd`/$(BUILD_DIR)/$(PROJECT).bin 0x08000000

clean:
	-rm -fR $(BUILD_DIR)
