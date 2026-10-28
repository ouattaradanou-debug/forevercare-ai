"""Indexation des documents de la bibliothèque et des archives (phase 9).

Tourne en tâche de fond (GitHub, toutes les 15 minutes) avec la clé de
service du serveur, qui n'existe JAMAIS dans l'application :
  * prend les documents envoyés en entier et « en attente » ;
  * extrait le texte page par page (PDF texte, sinon reconnaissance de
    texte Tesseract en français ; images ; Word, Excel, PowerPoint, texte) ;
  * découpe en passages (~800 caractères) pour la recherche plein texte ;
  * note l'état (indexé / échec, 3 essais), le nombre de pages et le coût
    (temps de calcul) ;
  * vide la corbeille de plus de 30 jours (fichier effacé, fiche gardée).
Les vecteurs pour l'assistant IA seront ajoutés en phase 12.

Variables : SUPABASE_URL, SUPABASE_SERVICE_ROLE_KEY ; facultatif
INDEXATION_LOT (documents par passage, 20 par défaut).
Dépendances : tesseract-ocr (+ fra), poppler-utils, python-docx, openpyxl,
python-pptx ; libreoffice pour les anciens formats (.doc, .xls, .ppt, .odt).
"""

import datetime as dt
import json
import os
import shutil
import subprocess
import sys
import tempfile
import time
import urllib.error
import urllib.parse
import urllib.request
from pathlib import Path

URL = os.environ.get("SUPABASE_URL", "").rstrip("/")
CLE = os.environ.get("SUPABASE_SERVICE_ROLE_KEY", "")
LOT = int(os.environ.get("INDEXATION_LOT", "20"))
TAILLE_PASSAGE = 800
ESSAIS_MAX = 3
CORBEILLE_JOURS = 30
# Coût indicatif du calcul : minute de machine GitHub (Linux) à 0,008 $.
MICRODOLLARS_PAR_SECONDE = 8000 / 60


def appel(methode, chemin, corps=None, entetes=None, brut=False):
    req = urllib.request.Request(URL + chemin, method=methode)
    req.add_header("apikey", CLE)
    req.add_header("Authorization", f"Bearer {CLE}")
    for k, v in (entetes or {}).items():
        req.add_header(k, v)
    donnees = None
    if corps is not None:
        donnees = json.dumps(corps).encode()
        req.add_header("Content-Type", "application/json")
    with urllib.request.urlopen(req, donnees, timeout=120) as r:
        contenu = r.read()
    if brut:
        return contenu
    return json.loads(contenu) if contenu else None


def executer(cmd, **kw):
    return subprocess.run(cmd, check=True, capture_output=True, **kw)


# ----------------------------- Extraction -----------------------------

def ocr_image(chemin):
    r = executer(["tesseract", str(chemin), "-", "-l", "fra", "--psm", "3"])
    return r.stdout.decode("utf-8", "replace")


def pages_pdf(chemin, dossier):
    info = executer(["pdfinfo", str(chemin)]).stdout.decode("utf-8", "replace")
    n = next((int(l.split()[-1]) for l in info.splitlines() if l.startswith("Pages:")), 0)
    pages = []
    for p in range(1, n + 1):
        texte = executer(["pdftotext", "-f", str(p), "-l", str(p), "-layout",
                          str(chemin), "-"]).stdout.decode("utf-8", "replace")
        if len(texte.strip()) < 20:
            # Page scannée : reconnaissance de texte.
            base = dossier / f"p{p}"
            executer(["pdftoppm", "-r", "200", "-f", str(p), "-l", str(p),
                      "-png", "-singlefile", str(chemin), str(base)])
            texte = ocr_image(base.with_suffix(".png"))
        pages.append(texte)
    return pages


def pages_office(chemin, ext, dossier):
    if ext == ".docx":
        import docx
        d = docx.Document(str(chemin))
        return ["\n".join(p.text for p in d.paragraphs)]
    if ext == ".xlsx":
        import openpyxl
        wb = openpyxl.load_workbook(str(chemin), read_only=True, data_only=True)
        return ["\n".join(" ".join(str(c) for c in ligne if c is not None)
                          for ligne in ws.iter_rows(values_only=True)) for ws in wb.worksheets]
    if ext == ".pptx":
        import pptx
        pres = pptx.Presentation(str(chemin))
        return ["\n".join(sh.text_frame.text for sh in diapo.shapes if sh.has_text_frame)
                for diapo in pres.slides]
    # Anciens formats : conversion en PDF par LibreOffice.
    if not shutil.which("libreoffice"):
        raise RuntimeError(f"format {ext} : LibreOffice absent")
    executer(["libreoffice", "--headless", "--convert-to", "pdf", "--outdir",
              str(dossier), str(chemin)], timeout=180)
    return pages_pdf(chemin.with_suffix(".pdf").parent / (chemin.stem + ".pdf"), dossier)


def extraire(chemin, dossier):
    ext = chemin.suffix.lower()
    if ext == ".pdf":
        return pages_pdf(chemin, dossier)
    if ext in (".jpg", ".jpeg", ".png"):
        return [ocr_image(chemin)]
    if ext == ".txt":
        return [chemin.read_bytes().decode("utf-8", "replace")]
    return pages_office(chemin, ext, dossier)


def passages(pages):
    """Découpe chaque page en passages d'environ 800 caractères, sur des
    fins de phrase ou de ligne quand c'est possible."""
    sortie = []
    for num, texte in enumerate(pages, start=1):
        texte = " ".join(texte.split())
        while texte:
            if len(texte) <= TAILLE_PASSAGE:
                morceau, texte = texte, ""
            else:
                coupe = max(texte.rfind(". ", 0, TAILLE_PASSAGE),
                            texte.rfind(" ", 0, TAILLE_PASSAGE))
                coupe = coupe + 1 if coupe > TAILLE_PASSAGE // 2 else TAILLE_PASSAGE
                morceau, texte = texte[:coupe], texte[coupe:].lstrip()
            if morceau.strip():
                sortie.append((num, morceau.strip()))
    return sortie


# ----------------------------- Traitement -----------------------------

def indexer(doc):
    debut = time.monotonic()
    with tempfile.TemporaryDirectory() as tmp:
        dossier = Path(tmp)
        nom = doc.get("original_name") or Path(doc["storage_path"]).name
        fichier = dossier / ("source" + Path(nom).suffix.lower())
        chemin = urllib.parse.quote(doc["storage_path"])
        fichier.write_bytes(appel("GET", f"/storage/v1/object/documents/{chemin}", brut=True))
        pages = extraire(fichier, dossier)
    lignes = passages(pages)
    appel("DELETE", f"/rest/v1/document_chunks?document_id=eq.{doc['id']}")
    for i in range(0, len(lignes), 200):
        appel("POST", "/rest/v1/document_chunks", [
            {"school_id": doc["school_id"], "document_id": doc["id"], "page": p,
             "chunk_index": i + k, "content": c}
            for k, (p, c) in enumerate(lignes[i:i + 200])
        ], {"Prefer": "return=minimal"})
    secondes = time.monotonic() - debut
    appel("PATCH", f"/rest/v1/documents?id=eq.{doc['id']}", {
        "index_status": "indexe",
        "index_error": None,
        "page_count": len(pages),
        "indexed_at": dt.datetime.now(dt.timezone.utc).isoformat(),
        "index_cost_microusd": round(secondes * MICRODOLLARS_PAR_SECONDE),
    }, {"Prefer": "return=minimal"})
    return len(pages), len(lignes), secondes


def vider_corbeille():
    limite = (dt.datetime.now(dt.timezone.utc) - dt.timedelta(days=CORBEILLE_JOURS)).isoformat()
    docs = appel("GET", "/rest/v1/documents?select=id,storage_path&deleted_at=is.null"
                 f"&trashed_at=lt.{urllib.parse.quote(limite)}&limit=100") or []
    for d in docs:
        if d.get("storage_path"):
            try:
                appel("DELETE", "/storage/v1/object/documents/" + urllib.parse.quote(d["storage_path"]))
            except urllib.error.HTTPError:
                pass
        appel("DELETE", f"/rest/v1/document_chunks?document_id=eq.{d['id']}")
        appel("PATCH", f"/rest/v1/documents?id=eq.{d['id']}",
              {"deleted_at": dt.datetime.now(dt.timezone.utc).isoformat()},
              {"Prefer": "return=minimal"})
    return len(docs)


def main():
    if not URL or not CLE:
        print("SUPABASE_URL et SUPABASE_SERVICE_ROLE_KEY sont nécessaires.")
        return 2
    docs = appel("GET", "/rest/v1/documents?select=id,school_id,storage_path,original_name,index_attempts"
                 "&index_status=eq.en_attente&uploaded_at=not.is.null&deleted_at=is.null"
                 f"&trashed_at=is.null&storage_path=not.is.null&index_attempts=lt.{ESSAIS_MAX}"
                 f"&order=uploaded_at.asc&limit={LOT}") or []
    total_pages = total_s = 0
    for doc in docs:
        try:
            pages, n, s = indexer(doc)
            total_pages += pages
            total_s += s
            print(f"indexé {doc['id']} : {pages} page(s), {n} passage(s), {s:.1f} s")
        except Exception as e:  # noqa: BLE001 - chaque document est indépendant
            essais = doc["index_attempts"] + 1
            appel("PATCH", f"/rest/v1/documents?id=eq.{doc['id']}", {
                "index_attempts": essais,
                "index_status": "echec" if essais >= ESSAIS_MAX else "en_attente",
                "index_error": str(e)[:500],
            }, {"Prefer": "return=minimal"})
            print(f"échec {doc['id']} (essai {essais}) : {e}")
    purges = vider_corbeille()
    print(f"{len(docs)} document(s), {total_pages} page(s), {total_s:.1f} s ; "
          f"{purges} document(s) retiré(s) de la corbeille.")
    return 0


if __name__ == "__main__":
    sys.exit(main())
