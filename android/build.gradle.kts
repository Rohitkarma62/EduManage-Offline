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
}

// Apply this after each plugin module has evaluated its own build script.
// Otherwise the Flutter plugin can overwrite this value back to Flutter's
// older default compileSdk (34) during its own configuration.
gradle.projectsEvaluated {
    subprojects.forEach { subproject ->
        val androidLibrary =
            subproject.extensions.findByType(com.android.build.gradle.LibraryExtension::class.java)
        if (androidLibrary != null) {
            androidLibrary.compileSdk = 36
        }
    }
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
