# Git‑Befehle für das Solr‑Kafka‑Projekt

Dieses Dokument enthält alle Git‑Befehle, die im Rahmen des Projekts verwendet wurden oder typischerweise benötigt werden.  
Jeder Befehl ist kurz erklärt und kann direkt ausgeführt werden.

---

## Git‑Repository initialisieren

git init  
Erstellt ein neues Git‑Repository im aktuellen Ordner. Wird nur einmal benötigt, wenn das Projekt neu beginnt.

---

## Dateien zum Commit vormerken

git add .  
Fügt alle neuen oder geänderten Dateien zur Staging‑Area hinzu, damit sie committed werden können.

git add <datei>  
Fügt nur eine bestimmte Datei hinzu.

---

## Änderungen committen

git commit -m "Beschreibung der Änderung"  
Speichert alle vorgemerkten Änderungen dauerhaft in der Git‑Historie.

---

## Status anzeigen

git status  
Zeigt an, welche Dateien geändert wurden, welche gestaged sind und welche untracked sind.

---

## Änderungen anzeigen

git diff  
Zeigt alle Änderungen im Vergleich zum letzten Commit.

git diff --staged  
Zeigt Änderungen, die bereits gestaged wurden.

---

## Repository mit GitHub verbinden

git remote add origin <URL>  
Verknüpft das lokale Repository mit einem GitHub‑Repository.

git remote -v  
Zeigt alle verbundenen Remotes an.

---

## Änderungen zu GitHub hochladen

git push -u origin main  
Lädt den aktuellen Stand auf den Branch *main* hoch und setzt ihn als Standard‑Upstream.

git push  
Lädt zukünftige Änderungen hoch.

---

## Änderungen von GitHub herunterladen

git pull  
Holt die neuesten Änderungen vom Remote‑Repository und merged sie in den lokalen Stand.

---

## Branches verwalten

git branch  
Listet alle lokalen Branches auf.

git branch <name>  
Erstellt einen neuen Branch.

git checkout <name>  
Wechselt in einen anderen Branch.

git checkout -b <name>  
Erstellt einen neuen Branch und wechselt direkt hinein.

---

## Änderungen rückgängig machen

git restore <datei>  
Setzt eine Datei auf den Zustand des letzten Commits zurück.

git restore --staged <datei>  
Entfernt eine Datei aus der Staging‑Area.

git reset --hard  
Setzt das gesamte Arbeitsverzeichnis auf den letzten Commit zurück (Vorsicht: Änderungen gehen verloren).

---

## Commit‑Historie anzeigen

git log  
Zeigt die Commit‑Historie an.

git log --oneline  
Zeigt die Historie kompakt an.

---

## Dateien löschen

git rm <datei>  
Löscht eine Datei aus dem Repository und dem Dateisystem.

---

## Dateien umbenennen

git mv <alt> <neu>  
Benennt eine Datei um und merkt die Änderung für den nächsten Commit vor.

---

## Tags setzen (z. B. für Releases)

git tag v1.0  
Erstellt einen einfachen Tag.

git push --tags  
Lädt alle Tags zu GitHub hoch.

---

## GitHub Actions Workflow aktualisieren

git add .github/workflows/helm-lint.yaml  
git commit -m "Add/update CI pipeline"  
git push  

Damit wird die Pipeline aktiv.

---

## Repository klonen

git clone <URL>  
Lädt ein GitHub‑Repository lokal herunter.

---

## Zusammenfassung

Diese Datei enthält alle Git‑Befehle, die du für dein Solr‑Kafka‑Projekt brauchst:  
Repository erstellen, Änderungen committen, Branches verwalten, Push/Pull, Rückgängig machen, Tags setzen und CI‑Workflows aktualisieren.

Damit kannst du dein Projekt vollständig versionieren und sauber verwalten.
