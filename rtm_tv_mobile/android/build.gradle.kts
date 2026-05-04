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

// ⚡ FIX CRITIQUE POUR BETTER_PLAYER
// ... gardez le début du fichier identique ...

subprojects {
    // On applique le correctif immédiatement au lieu d'attendre l'afterEvaluate
    plugins.withType<com.android.build.gradle.api.AndroidBasePlugin> {
        val android = extensions.getByType<com.android.build.gradle.BaseExtension>()
        if (android.namespace == null) {
            android.namespace = "com.example.rtm_tv_mobile"
            println("🔧 Fix Namespace forcé pour : ${project.name}")
        }
    }
}
}
