LOCAL_PATH := $(call my-dir)

include $(CLEAR_VARS)

LOCAL_MODULE := websockets

ifeq ($(TARGET_ARCH_ABI),armeabi-v7a)
LOCAL_ARM_MODE := arm
endif

LOCAL_CFLAGS    := -DLWS_BUILTIN_GETIFADDRS
LWS_LIB_PATH	:= ./libwebsockets/lib
LOCAL_C_INCLUDES:= $(LOCAL_PATH)/$(LWS_LIB_PATH)
LOCAL_SRC_FILES := \
	$(subst $(LWS_LIB_PATH)/extension.c,, \
	$(subst $(LWS_LIB_PATH)/extension-deflate-frame.c,, \
	$(subst $(LWS_LIB_PATH)/extension-deflate-stream.c,, \
	$(subst $(LWS_LIB_PATH)/libev.c,, \
	$(subst $(LWS_LIB_PATH)/hpack.c,, \
	$(subst $(LWS_LIB_PATH)/http2.c,, \
	$(subst $(LWS_LIB_PATH)/ssl.c,, \
	$(subst $(LWS_LIB_PATH)/ssl-http2.c,, \
	$(subst $(LWS_LIB_PATH)/lws-plat-win.c,, \
	$(wildcard $(LWS_LIB_PATH)/*.c))))))))))

LOCAL_SHARED_LIBRARIES := -lz
LOCAL_EXPORT_C_INCLUDES := $(LOCAL_C_INCLUDES)

include $(BUILD_STATIC_LIBRARY)