// ══════════════════════════════════════════════════════════════
// CONFIGURATION DES RÉPERTOIRES ET DEPÔTS
// ══════════════════════════════════════════════════════════════
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

// ══════════════════════════════════════════════════════════════
// ⚡ FIX CRITIQUE : NAMESPACE POUR LES PLUGINS (BETTER_PLAYER)
// ══════════════════════════════════════════════════════════════
// Ce bloc force un namespace sur chaque plugin qui n'en possède pas,
// réglant ainsi l'erreur "Namespace not specified".
subprojects {
    afterEvaluate {
        if (project.hasProperty("android")) {
            val android = project.extensions.getByName("android") as com.android.build.gradle.BaseExtension
            // Si le plugin (comme better_player) n'a pas de namespace, on lui en génère un
            if (android.namespace == null) {
                val generatedNamespace = "com.rtm.tv.${project.name.replace(":", ".")}"
                android.namespace = generatedNamespace
                println("🔧 Fix Namespace appliqué pour : ${project.name} -> $generatedNamespace")[cite: 3]
            }
        }
    }
}
