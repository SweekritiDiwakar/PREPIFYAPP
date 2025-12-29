allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

// Replace the problematic build directory redirection with standard Flutter configuration
// Deleted:val newBuildDir: Directory =
// Deleted:    rootProject.layout.buildDirectory
// Deleted:        .dir("../../build")
// Deleted:        .get()
// Deleted:rootProject.layout.buildDirectory.value(newBuildDir)
//
// Deleted:subprojects {
// Deleted:    val newSubprojectBuildDir: Directory = newBuildDir.dir(project.name)
// Deleted:    project.layout.buildDirectory.value(newSubprojectBuildDir)
// Deleted:}

subprojects {
    project.evaluationDependsOn(":app")
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}