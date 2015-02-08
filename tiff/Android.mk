LOCAL_PATH := $(call my-dir)

include $(CLEAR_VARS)

LOCAL_MODULE := tiff

ifeq ($(TARGET_ARCH_ABI),armeabi-v7a)
LOCAL_ARM_MODE := arm
LOCAL_ARM_NEON := true
endif

LOCAL_SRC_FILES := \
	$(subst $(LOCAL_PATH)/libtiff/tif_win32.c,, \
	$(wildcard $(LOCAL_PATH)/libtiff/*.c)) \
	$(wildcard $(LOCAL_PATH)/port/lfind.c)

LOCAL_CFLAGS += -Wno-pointer-to-int-cast -Wno-int-to-pointer-cast
LOCAL_SHARED_LIBRARIES := -lz
LOCAL_EXPORT_C_INCLUDES := $(LOCAL_PATH)/libtiff

include $(BUILD_STATIC_LIBRARY)