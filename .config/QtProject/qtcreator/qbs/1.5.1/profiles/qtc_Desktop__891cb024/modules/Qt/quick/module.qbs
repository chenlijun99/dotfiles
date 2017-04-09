import qbs 1.0
import '../QtModule.qbs' as QtModule

QtModule {
    qtModuleName: "Quick"
    Depends { name: "Qt"; submodules: ["core", "gui", "qml"]}

    hasLibrary: true
    staticLibsDebug: []
    staticLibsRelease: []
    dynamicLibsDebug: []
    dynamicLibsRelease: ["/home/chen/Qt5.7.0/5.7/gcc_64/lib/libQt5Qml.so.5.7.0", "/home/chen/Qt5.7.0/5.7/gcc_64/lib/libQt5Gui.so.5.7.0", "/home/chen/Qt5.7.0/5.7/gcc_64/lib/libQt5Network.so.5.7.0", "/home/chen/Qt5.7.0/5.7/gcc_64/lib/libQt5Core.so.5.7.0", "pthread"]
    linkerFlagsDebug: []
    linkerFlagsRelease: []
    frameworksDebug: []
    frameworksRelease: []
    frameworkPathsDebug: []
    frameworkPathsRelease: []
    libNameForLinkerDebug: "Qt5Quick"
    libNameForLinkerRelease: "Qt5Quick"
    libFilePathDebug: ""
    libFilePathRelease: "/home/chen/Qt5.7.0/5.7/gcc_64/lib/libQt5Quick.so.5.7.0"
    cpp.defines: {
        var result = ["QT_QUICK_LIB"];
        if (qmlDebugging)
            result.push("QT_QML_DEBUG");
        return result;
    }
    cpp.includePaths: ["/home/chen/Qt5.7.0/5.7/gcc_64/include", "/home/chen/Qt5.7.0/5.7/gcc_64/include/QtQuick"]
    cpp.libraryPaths: ["/usr/lib64", "/home/chen/Qt5.7.0/5.7/gcc_64/lib", "/home/chen/Qt5.7.0/5.7/gcc_64/lib"]
    property bool qmlDebugging: false
    property string qmlPath
    property string qmlImportsPath: ""
}
