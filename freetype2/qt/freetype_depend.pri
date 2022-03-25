FREETYPE_INCLUDE = $$(FREETYPE_INCLUDE)

isEmpty(FREETYPE_INCLUDE) {
    INCLUDEPATH += $$PWD/include

    !win32 {
        INCLUDEPATH += $$PWD/builds/unix
    }
} else {
    INCLUDEPATH += $$FREETYPE_INCLUDE
}

FREETYPE_STATIC = $$(FREETYPE_STATIC)
isEmpty(FREETYPE_STATIC) {
    DEFINES += FT_CONFIG_OPTION_SYSTEM_ZLIB

    LIBS += -L$$[QT_INSTALL_LIBS]


    QTFREETYPE_LIB = qtfreetype

    equals(QT_MAJOR_VERSION, 5):lessThan(QT_MINOR_VERSION, 15) {
    CONFIG(debug, debug|release) {
        win32:QTFREETYPE_LIB = $$join(QTFREETYPE_LIB, , , d)
        else:QTFREETYPE_LIB = $$join(QTFREETYPE_LIB, , , _debug)
    }
    }

    LIBS += -l$$QTFREETYPE_LIB
} else {
    splitted = $$split(FREETYPE_STATIC, ;)
    for(lib, splitted) {
        LIBS += $$lib
    }
}
