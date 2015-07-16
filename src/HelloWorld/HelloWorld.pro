TEMPLATE = app

QT += qml quick widgets

SOURCES += main.cpp \
    maintenancetool.cpp

RESOURCES += qml.qrc

# Additional import path used to resolve QML modules in Qt Creator's code model
QML_IMPORT_PATH =

# Default rules for deployment.
include(deployment.pri)

# icon
win32{
    RC_FILE = HelloWorld.rc
}
mac{
    ICON = HelloWorld.icns
}

HEADERS += \
    maintenancetool.h
