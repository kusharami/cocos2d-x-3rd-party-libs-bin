INCLUDEPATH += $$PWD/include

!win32 {
    INCLUDEPATH += $$PWD/builds/unix
}

DEFINES += FT_CONFIG_OPTION_SYSTEM_ZLIB

LIBS += -L$$[QT_INSTALL_LIBS]


QTFREETYPE_LIB = qtfreetype

CONFIG(debug, debug|release) {
    win32:QTFREETYPE_LIB = $$join(QTFREETYPE_LIB, , , d)
    else:QTFREETYPE_LIB = $$join(QTFREETYPE_LIB, , , _debug)
}

LIBS += -l$$QTFREETYPE_LIB