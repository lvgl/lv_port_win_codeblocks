######################################
# includes
######################################
include lv_drivers/lv_drivers.mk
LVGL_DIR=.
LVGL_DIR_NAME=lvgl
include lvgl/lvgl.mk
include main.mk

######################################
# target
######################################
TARGET = lvgl_main


######################################
# building variables
######################################
# debug build?
DEBUG ?= 1
# optimization
ifeq ($(DEBUG),1)
OPT = -Og
else
OPT = -O3
endif


#######################################
# paths
#######################################
# Build path
ifeq ($(DEBUG), 1)
BUILD_DIR ?= debug
else
BUILD_DIR ?= release
endif


######################################
# source
######################################
# C++ sources
CPP_SOURCES +=
# C sources
C_SOURCES   += $(CSRCS)

# ASM sources
ASM_SOURCES +=


#######################################
# binaries
#######################################
PREFIX ?=
# The gcc compiler bin path can be either defined in make command via GCC_PATH variable (> make GCC_PATH=xxx)
# either it can be added to the PATH environment variable.
ifdef GCC_PATH
CC = $(GCC_PATH)/$(PREFIX)gcc
CXX= $(GCC_PATH)/$(PREFIX)g++
AS = $(GCC_PATH)/$(PREFIX)gcc -x assembler-with-cpp
CP = $(GCC_PATH)/$(PREFIX)objcopy
SZ = $(GCC_PATH)/$(PREFIX)size
else
CC = $(PREFIX)gcc
CXX= $(PREFIX)g++
AS = $(PREFIX)gcc -x assembler-with-cpp
CP = $(PREFIX)objcopy
SZ = $(PREFIX)size
endif
HEX = $(CP) -O ihex
BIN = $(CP) -O binary -S

#######################################
# CFLAGS
#######################################
# macros for gcc
# AS defines
AS_DEFS +=

# C defines
C_DEFS  += -DWIN32

# AS includes
AS_INCLUDES +=

# C includes
C_INCLUDES += -I.

# C++ includes
CPP_INCLUDES += \
-I$(BUILD_DIR)

# compile gcc flags
ASFLAGS = $(AS_DEFS) $(AS_INCLUDES) $(OPT) -Wall -fdata-sections -ffunction-sections

CFLAGS  = $(C_DEFS) $(C_INCLUDES) $(OPT) -Wall -fno-strict-aliasing -fdata-sections -ffunction-sections -Werror-implicit-function-declaration
CXXFLAGS = $(CPP_DEFS) $(CPP_INCLUDES) $(OPT) -Wall -fdata-sections -ffunction-sections

CFLAGS += -g -gdwarf-2

# Generate dependency information 
CFLAGS += -MMD -MP -MF"$(@:%.o=%.d)"
CXXFLAGS += $(CPP_INCLUDES) -std=c++11 -MMD -MP -MF"$(@:%.o=%.d)"

#######################################
# LDFLAGS
#######################################
# link script
LDSCRIPT =

# libraries
LIBS += -lpthread -lm -lgdi32 -lmingw32
LIBDIR += -L.
LDFLAGS = $(MCU) $(LIBDIR) $(LIBS) -Wl,-Map=$(BUILD_DIR)/$(TARGET).map,--cref -Wl,--gc-sections

# list of CPP objects
OBJECTS += $(addprefix $(BUILD_DIR)/,$(CPP_SOURCES:.cpp=.o))
# list of C objects
OBJECTS += $(addprefix $(BUILD_DIR)/,$(C_SOURCES:.c=.o))
# list of ASM program objects
OBJECTS += $(addprefix $(BUILD_DIR)/,$(ASM_SOURCES:.s=.o))
DEPENDENCY += $(OBJECTS:.o=.d)


.PHONY: all clean preprocession
# default action: build all
all: $(BUILD_DIR)/$(TARGET)

#######################################
# build the application
#######################################
.PRECIOUS: $(BUILD_DIR)/. $(BUILD_DIR)%/.
# generate build directory
$(BUILD_DIR)/.:
ifdef OS
ifdef MSYSTEM
	mkdir -p $@
else
	MKDIR $(subst /,\,$@)
endif
else
	mkdir -p $@
endif

$(BUILD_DIR)%/.:
ifdef OS
ifdef MSYSTEM
	mkdir -p $@
else
	MKDIR $(subst /,\,$@)
endif
else
	mkdir -p $@
endif

.SECONDEXPANSION:
# file | dir, | means type of prerequisites in order
# compile arguments including -Wa, -a, -ad, -alms (pass arguments to assembler) generate a file of assembly
$(BUILD_DIR)/%.o: %.cpp | $$(@D)/.
	$(CXX) -c $(CXXFLAGS) -Wa,-a,-ad,-alms=$(@:%.o=%.lst) $< -o $@

$(BUILD_DIR)/%.o: %.c Makefile | $$(@D)/.
	$(CC) -c $(CFLAGS) -Wa,-a,-ad,-alms=$(@:%.o=%.lst) $< -o $@

$(BUILD_DIR)/%.o: %.s Makefile | $$(@D)/.
	$(AS) -c $(CFLAGS) $< -o $@

$(BUILD_DIR)/$(TARGET): $(OBJECTS) Makefile
	$(CXX) $(OBJECTS) $(LDFLAGS) -o $@


#######################################
# clean up
#######################################
clean:
# OS var only appears on windows
ifdef OS
# check if mingw bash is used
ifdef MSYSTEM
	rm -rf $(BUILD_DIR)
else
	rd /s /q $(BUILD_DIR)
endif
else
# linux
	rm -rf $(BUILD_DIR)
endif


#######################################
# dependencies
#######################################
-include $(wildcard $(DEPENDENCY))

# *** EOF ***