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

// Register SDK alignment before forcing evaluation of the app project.
// The app evaluation can trigger evaluation of plugin projects as well.
subprojects {
    afterEvaluate {
        val androidLibrary =
            extensions.findByType(com.android.build.gradle.LibraryExtension::class.java)
        if (androidLibrary != null) {
            androidLibrary.compileSdk = 36
        }
    }
}

subprojects {
    project.evaluationDependsOn(":app")
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
