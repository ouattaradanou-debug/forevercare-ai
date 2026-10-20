"""Banc d'essai de reconnaissance de texte (Tesseract, français).

Deux modes :
  * sans argument : génère des pages SIMULÉES (texte original en français,
    dégradé comme une photo de téléphone : rotation, flou, bruit, éclairage
    inégal, JPEG) et mesure le taux d'erreur par caractère (CER) ;
  * avec un dossier : python3 bench_tesseract.py DOSSIER
    où chaque image `page.jpg` a sa transcription exacte `page.txt` :
    mesure sur de VRAIS scans (procédure : docs/BIBLIOTHEQUE_ET_IA.md).

Dépendances : tesseract-ocr, tesseract-ocr-fra, Pillow.
"""

import io
import random
import subprocess
import sys
import tempfile
import time
import unicodedata
from pathlib import Path

from PIL import Image, ImageDraw, ImageFilter, ImageFont

FONT = "/usr/share/fonts/truetype/dejavu/DejaVuSerif.ttf"

PARAGRAPHES = [
    "Leçon de calcul : la multiplication des nombres décimaux. Pour multiplier "
    "un nombre décimal par 10, on déplace la virgule d'un rang vers la droite.",
    "Exercice 1. Le maraîcher a récolté 12,5 kg de tomates le lundi et 8,75 kg "
    "le mardi. Quelle quantité a-t-il récoltée en tout ? Écris l'opération.",
    "Dictée préparée : Pendant l'hivernage, les élèves aident leurs parents aux "
    "champs. Le soir, ils révisent leurs leçons à la lumière de la lampe.",
    "Objectif spécifique : à la fin de la séance, l'élève doit être capable de "
    "nommer trois céréales cultivées dans sa région et d'expliquer leur rôle.",
    "Évaluation : complète les phrases avec « à », « où » ou « ou ». Le marché "
    "se tient chaque samedi près de l'école, là où se trouve le grand karité.",
    "Problème : une classe de 48 élèves reçoit 6 boîtes de 24 craies. Combien de "
    "craies chaque groupe de 8 élèves aura-t-il si on partage équitablement ?",
]


def levenshtein(a: str, b: str) -> int:
    prev = list(range(len(b) + 1))
    for i, ca in enumerate(a, 1):
        cur = [i]
        for j, cb in enumerate(b, 1):
            cur.append(min(prev[j] + 1, cur[j - 1] + 1, prev[j - 1] + (ca != cb)))
        prev = cur
    return prev[-1]


def normalise(t: str) -> str:
    t = unicodedata.normalize("NFC", t).replace("’", "'")
    return " ".join(t.split())


def page_simulee(texte: str, rng: random.Random, niveau: int) -> bytes:
    """Rend une page A4 à ~150 ppp puis la dégrade (niveau 0 = propre, 2 = difficile)."""
    w, h = 1240, 1754
    img = Image.new("L", (w, h), 250)
    d = ImageDraw.Draw(img)
    font = ImageFont.truetype(FONT, 30)
    y, ligne = 120, ""
    for mot in texte.split():
        essai = (ligne + " " + mot).strip()
        if d.textlength(essai, font=font) > w - 240:
            d.text((120, y), ligne, font=font, fill=20)
            y += 46
            ligne = mot
        else:
            ligne = essai
    d.text((120, y), ligne, font=font, fill=20)
    # Éclairage inégal (dégradé d'ombre), rotation, flou, bruit
    ombre = Image.linear_gradient("L").resize((w, h)).point(lambda v: int(v * 0.25 * niveau))
    img = Image.eval(Image.merge("L", [img]), lambda v: v)
    img = Image.composite(Image.new("L", (w, h), 0), img, ombre)
    img = img.rotate(rng.uniform(-1.5, 1.5) * niveau, expand=False, fillcolor=235)
    if niveau:
        img = img.filter(ImageFilter.GaussianBlur(0.6 * niveau))
        px = img.load()
        for _ in range(4000 * niveau):
            x, yy = rng.randrange(w), rng.randrange(h)
            px[x, yy] = rng.choice((30, 220))
    buf = io.BytesIO()
    img.convert("RGB").save(buf, "JPEG", quality=max(35, 80 - 20 * niveau))
    return buf.getvalue()


def ocr(image: bytes) -> tuple[str, float]:
    with tempfile.NamedTemporaryFile(suffix=".jpg") as f:
        f.write(image)
        f.flush()
        t0 = time.perf_counter()
        out = subprocess.run(
            ["tesseract", f.name, "stdout", "-l", "fra", "--psm", "3"],
            capture_output=True, text=True, check=True,
        ).stdout
        return out, time.perf_counter() - t0


def mesurer(cas: list[tuple[str, bytes, str]]) -> None:
    print(f"{'cas':<28} {'Ko':>6} {'s':>6} {'CER %':>7}")
    for nom, image, verite in cas:
        texte, duree = ocr(image)
        v, t = normalise(verite), normalise(texte)
        cer = 100 * levenshtein(v, t) / max(1, len(v))
        print(f"{nom:<28} {len(image) / 1024:6.0f} {duree:6.2f} {cer:7.1f}")


def main() -> None:
    if len(sys.argv) > 1:
        dossier = Path(sys.argv[1])
        cas = [
            (p.name, p.read_bytes(), p.with_suffix(".txt").read_text(encoding="utf-8"))
            for p in sorted(dossier.glob("*.jpg"))
            if p.with_suffix(".txt").exists()
        ]
    else:
        rng = random.Random(42)
        cas = []
        for niveau in (0, 1, 2):
            for i, para in enumerate(PARAGRAPHES):
                texte = " ".join([para] * 3)
                cas.append((f"simulee_n{niveau}_p{i + 1}", page_simulee(texte, rng, niveau), texte))
    mesurer(cas)


if __name__ == "__main__":
    main()
