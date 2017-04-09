import qbs 1.0
import '../QtModule.qbs' as QtModule

QtModule {
    qtModuleName: "PlatformSupport"
    Depends { name: "Qt"; submodules: ["core-private", "gui-private"]}

    hasLibrary: true
    staticLibsDebug: []
    staticLibsRelease: ["fontconfig", "freetype", "/home/chen/Qt5.7.0/5.7/gcc_64/lib/libQt5Gui.so.5.7.0", "/home/chen/Qt5.7.0/5.7/gcc_64/lib/libQt5DBus.so.5.7.0", "/home/chen/Qt5.7.0/5.7/gcc_64/lib/libQt5Core.so.5.7.0", "pthread", "dl", "gthread-2.0", "rt", "glib-2.0", "Xrender", "Xext", "X11", "m", "EGL", "GL"]
    dynamicLibsDebug: []
    dynamicLibsRelease: []
    linkerFlagsDebug: []
    linkerFlagsRelease: ["-pthread"]
    frameworksDebug: []
    frameworksRelease: []
    frameworkPathsDebug: []
    frameworkPathsRelease: []
    libNameForLinkerDebug: "Qt5PlatformSupport"
    libNameForLinkerRelease: "Qt5PlatformSupport"
    libFilePathDebug: ""
    libFilePathRelease: "/home/chen/Qt5.7.0/5.7/gcc_64/lib/libQt5PlatformSupport.a"
    cpp.defines: ["QT_PLATFORMSUPPORT_LIB"]
    cpp.includePaths: ["/home/chen/Qt5.7.0/5.7/gcc_64/include", "/home/chen/Qt5.7.0/5.7/gcc_64/include/QtPlatformSupport", "/home/chen/Qt5.7.0/5.7/gcc_64/include/QtPlatformSupport/5.7.0", "/home/chen/Qt5.7.0/5.7/gcc_64/include/QtPlatformSupport/5.7.0/QtPlatformSupport"]
    cpp.libraryPaths: ["/usr/lib64", "/home/chen/Qt5.7.0/5.7/gcc_64/lib"]
    isStaticLibrary: true
}
