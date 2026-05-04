allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

val newBuildDir: Directory =
    rootProject.layout.buildDirectory
        .dir("../../build")
        .get()
rootProject.layout.buildDirectory.value(newBuildDir)

subprojects {
    val newSubprojectBuildDir: Directory = newBuildDir.dir(project.name)
    project.layout.buildDirectory.value(newSubprojectBuildDir)
}

subprojects {
    project.evaluationDependsOn(":app")
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}

// ⚡ FIX DÉFINITIF POUR LE NAMESPACE (BETTER_PLAYER)
subprojects {
    // On utilise withType pour agir dès que le plugin Android est détecté
    plugins.withType<com.android.build.gradle.BasePlugin> {
        val android = project.extensions.getByType<com.android.build.gradle.BaseExtension>()
        // On force le namespace si absent pour éviter l'erreur de build
        if (android.namespace == null) {
            android.namespace = "com.jhomlala.better_player"
        }
    }
}
