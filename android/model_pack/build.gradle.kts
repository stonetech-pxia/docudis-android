// Play Asset Delivery pack carrying the NER model (install-time: on disk
// right after install, but outside the 150 MB base-APK limit).
//
// The model files are written to the git-ignored assets/models/xlmr_ner_docudis
// by tool/fetch_models.sh (from the pinned docudis-ner revision) and are synced
// here at build time. Only `flutter build appbundle` packages this pack; a plain APK build
// gets the model through the app module's debug source set instead.
plugins {
    id("com.android.asset-pack")
}

assetPack {
    packName.set("model_pack")
    dynamicDelivery {
        deliveryType.set("install-time")
    }
}

val syncModelAssets by tasks.registering(Sync::class) {
    from(rootProject.file("../assets/models/xlmr_ner_docudis")) {
        include("model.json", "tokenizer.json", "model_quantized.onnx")
    }
    into(layout.projectDirectory.dir("src/main/assets/models/xlmr_ner_docudis"))
}

afterEvaluate {
    tasks.matching { it.name != "syncModelAssets" }.configureEach {
        dependsOn(syncModelAssets)
    }
}
