allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

val newBuildDir: Directory = rootProject.layout.buildDirectory.dir("../../build").get()
rootProject.layout.buildDirectory.value(newBuildDir)

subprojects {
    val newSubprojectBuildDir: Directory = newBuildDir.dir(project.name)
    project.layout.buildDirectory.value(newSubprojectBuildDir)
}

subprojects {
    project.evaluationDependsOn(":app")

    // Some Flutter plugins use the Flutter SDK's older compileSdk value instead
    // of the app module's value. Align Android library plugins with the app SDK.
    afterEvaluate {
        val androidExtension = extensions.findByName("android") ?: return@afterEvaluate
        val compileSdkSetter = androidExtension.javaClass.methods.firstOrNull {
            it.name == "setCompileSdkVersion" &&
                it.parameterTypes.size == 1 &&
                it.parameterTypes[0] == String::class.java
        }
        compileSdkSetter?.invoke(androidExtension, "android-36")
    }
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
