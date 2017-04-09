import qbs 1.0
import '../QtModule.qbs' as QtModule

QtModule {
    qtModuleName: "QuickTemplates2"
    Depends { name: "Qt"; submodules: ["core", "gui", "quick"]}

    hasLibrary: true
    staticLibsDebug: []
    staticLibsRelease: []
    dynamicLibsDebug: []
    dynamicLibsRelease: ["/home/chen/Qt5.7.0/5.7/gcc_64/lib/libQt5Quick.so.5.7.0", "/home/chen/Qt5.7.0/5.7/gcc_64/lib/libQt5Gui.so.5.7.0", "/home/chen/Qt5.7.0/5.7/gcc_64/lib/libQt5Qml.so.5.7.0", "/home/chen/Qt5.7.0/5.7/gcc_64/lib/libQt5Network.so.5.7.0", "/home/chen/Qt5.7.0/5.7/gcc_64/lib/libQt5Core.so.5.7.0", "pthread"]
    linkerFlagsDebug: []
    linkerFlagsRelease: []
    frameworksDebug: []
    frameworksRelease: []
    frameworkPathsDebug: []
    frameworkPathsRelease: []
    libNameForLinkerDebug: "Qt5QuickTemplates2"
    libNameForLinkerRelease: "Qt5QuickTemplates2"
    libFilePathDebug: ""
    libFilePathRelease: "/home/chen/Qt5.7.0/5.7/gcc_64/lib/libQt5QuickTemplates2.so.5.7.0"
    cpp.defines: ["QT_QUICKTEMPLATES2_LIB"]
    cpp.includePaths: ["/home/chen/Qt5.7.0/5.7/gcc_64/include", "/home/chen/Qt5.7.0/5.7/gcc_64/include/QtQuickTemplates2", "/home/chen/Qt5.7.0/5.7/gcc_64/include/QtQuickTemplates2/5.7.0", "/home/chen/Qt5.7.0/5.7/gcc_64/include/QtQuickTemplates2/5.7.0/QtQuickTemplates2"]
    cpp.libraryPaths: ["/usr/lib64", "/home/chen/Qt5.7.0/5.7/gcc_64/lib"]
    
}
