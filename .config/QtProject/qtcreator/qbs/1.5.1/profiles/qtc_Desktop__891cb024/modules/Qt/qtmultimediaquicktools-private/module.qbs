import qbs 1.0
import '../QtModule.qbs' as QtModule

QtModule {
    qtModuleName: "MultimediaQuick_p"
    Depends { name: "Qt"; submodules: ["core", "quick", "multimedia-private"]}

    hasLibrary: true
    staticLibsDebug: []
    staticLibsRelease: []
    dynamicLibsDebug: []
    dynamicLibsRelease: ["/home/chen/Qt5.7.0/5.7/gcc_64/lib/libQt5Multimedia.so.5.7.0", "/home/chen/Qt5.7.0/5.7/gcc_64/lib/libQt5Quick.so.5.7.0", "/home/chen/Qt5.7.0/5.7/gcc_64/lib/libQt5Gui.so.5.7.0", "/home/chen/Qt5.7.0/5.7/gcc_64/lib/libQt5Qml.so.5.7.0", "/home/chen/Qt5.7.0/5.7/gcc_64/lib/libQt5Network.so.5.7.0", "/home/chen/Qt5.7.0/5.7/gcc_64/lib/libQt5Core.so.5.7.0", "pthread"]
    linkerFlagsDebug: []
    linkerFlagsRelease: []
    frameworksDebug: []
    frameworksRelease: []
    frameworkPathsDebug: []
    frameworkPathsRelease: []
    libNameForLinkerDebug: "Qt5MultimediaQuick_p"
    libNameForLinkerRelease: "Qt5MultimediaQuick_p"
    libFilePathDebug: ""
    libFilePathRelease: "/home/chen/Qt5.7.0/5.7/gcc_64/lib/libQt5MultimediaQuick_p.so.5.7.0"
    cpp.defines: ["QT_QTMULTIMEDIAQUICKTOOLS_LIB"]
    cpp.includePaths: ["/home/chen/Qt5.7.0/5.7/gcc_64/include", "/home/chen/Qt5.7.0/5.7/gcc_64/include/QtMultimediaQuick_p", "/home/chen/Qt5.7.0/5.7/gcc_64/include/QtMultimediaQuick_p/5.7.0", "/home/chen/Qt5.7.0/5.7/gcc_64/include/QtMultimediaQuick_p/5.7.0/QtMultimediaQuick_p"]
    cpp.libraryPaths: ["/usr/lib64", "/home/chen/Qt5.7.0/5.7/gcc_64/lib", "/home/chen/Qt5.7.0/5.7/gcc_64/lib"]
    
}
