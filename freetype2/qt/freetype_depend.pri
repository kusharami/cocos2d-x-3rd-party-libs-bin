INCLUDEPATH += $$PWD/include

!win32 {
    INCLUDEPATH += $$PWD/builds/unix
}

DEFINES += FT_CONFIG_OPTION_SYSTEM_ZLIB

LIBS += -L$$[QT_INSTALL_LIBS]
LIBS += -lqtfreetype
