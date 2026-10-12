package com.atelierplus.atelier_plus

import android.content.ActivityNotFoundException
import android.content.Intent
import androidx.core.content.FileProvider
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.io.File

/// Envoie un fichier directement sur la conversation WhatsApp d'un numéro
/// précis (sans passer par le menu de partage générique où le tailleur doit
/// choisir WhatsApp puis le contact) : WhatsApp s'ouvre déjà sur la bonne
/// conversation avec le fichier joint, le tailleur n'a plus qu'à confirmer
/// l'envoi. Utilise l'extra "jid" de l'intent de partage de WhatsApp
/// (mécanisme non documenté officiellement mais stable et largement utilisé
/// depuis des années pour présélectionner un contact) combiné au
/// FileProvider déclaré dans AndroidManifest.xml pour joindre le fichier —
/// aucune API officielle ne permet de contourner la confirmation d'envoi
/// elle-même, qui reste affichée par WhatsApp.
class MainActivity : FlutterActivity() {
    private val canalWhatsApp = "atelier_plus/whatsapp"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, canalWhatsApp)
            .setMethodCallHandler { call, result ->
                if (call.method != "envoyerFichier") {
                    result.notImplemented()
                    return@setMethodCallHandler
                }
                val cheminFichier = call.argument<String>("cheminFichier")
                val jid = call.argument<String>("jid")
                if (cheminFichier == null || jid == null) {
                    result.error("ARGUMENTS_MANQUANTS", "cheminFichier ou jid manquant", null)
                    return@setMethodCallHandler
                }
                try {
                    val uri = FileProvider.getUriForFile(
                        this,
                        "$packageName.fileprovider",
                        File(cheminFichier),
                    )
                    val intent = Intent(Intent.ACTION_SEND).apply {
                        type = "image/png"
                        putExtra(Intent.EXTRA_STREAM, uri)
                        putExtra("jid", jid)
                        setPackage("com.whatsapp")
                        addFlags(Intent.FLAG_GRANT_READ_URI_PERMISSION)
                    }
                    startActivity(intent)
                    result.success(true)
                } catch (e: ActivityNotFoundException) {
                    result.error("WHATSAPP_INTROUVABLE", "WhatsApp n'est pas installé", null)
                } catch (e: Exception) {
                    result.error("ERREUR", e.message, null)
                }
            }
    }
}
