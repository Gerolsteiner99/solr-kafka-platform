# Git Workflow – Solr‑Kafka Platform

Dieser Workflow beschreibt den vollständigen, empfohlenen Ablauf für die tägliche Arbeit mit Git im Solr‑Kafka‑Projekt. Er fasst alle Schritte in einem einzigen, klaren Ablauf zusammen, der ohne weitere Unterteilung genutzt werden kann.

Der typische Arbeitsablauf beginnt damit, dass der aktuelle Stand aus dem Remote‑Repository geholt wird. Dazu wird git pull ausgeführt, um sicherzustellen, dass die lokale Arbeitskopie auf dem neuesten Stand ist. Anschließend werden Änderungen im Projekt vorgenommen, beispielsweise das Bearbeiten von Helm‑Charts, YAML‑Dateien oder Dokumentation. Sobald Änderungen vorgenommen wurden, kann mit git status überprüft werden, welche Dateien verändert wurden. Wenn die Änderungen korrekt sind, werden sie mit git add . zur Staging‑Area hinzugefügt. Danach werden die Änderungen mit git commit -m "Beschreibung" dauerhaft gespeichert.

Wenn ein neuer Branch benötigt wird, etwa für ein Feature oder eine Korrektur, wird dieser mit git checkout -b <branchname> erstellt und direkt gewechselt. Nach Abschluss der Arbeiten wird der Branch mit git push -u origin <branchname> zum Remote‑Repository hochgeladen. Falls bereits ein Branch existiert, genügt git push, um die neuen Commits hochzuladen.

Bevor ein Branch in den Hauptzweig integriert wird, sollte erneut git pull ausgeführt werden, um sicherzustellen, dass keine Konflikte entstehen. Falls Konflikte auftreten, werden diese lokal gelöst und anschließend erneut committet. Danach kann der Branch über GitHub in einen Pull Request überführt werden, wo die Änderungen überprüft und gemerged werden.

Wenn der Pull Request akzeptiert wurde, wird der Branch lokal mit git checkout main und git pull aktualisiert. Anschließend kann der alte Feature‑Branch mit git branch -d <branchname> gelöscht werden. Falls der Branch auch auf GitHub gelöscht werden soll, wird git push origin --delete <branchname> verwendet.

Wenn versehentlich Änderungen vorgenommen wurden, die nicht behalten werden sollen, kann git restore <datei> genutzt werden, um eine Datei auf den letzten Commit zurückzusetzen. Falls die Staging‑Area geleert werden soll, wird git restore --staged <datei> verwendet. Um alle lokalen Änderungen vollständig zu verwerfen, kann git reset --hard genutzt werden, wobei alle nicht committeten Änderungen verloren gehen.

Um die Commit‑Historie einzusehen, wird git log oder für eine kompakte Ansicht git log --oneline verwendet. Wenn Dateien gelöscht oder umbenannt werden müssen, stehen git rm <datei> und git mv <alt> <neu> zur Verfügung. Für Releases können Tags gesetzt werden, beispielsweise mit git tag v1.0 und anschließend mit git push --tags hochgeladen werden.

Wenn neue Dateien wie GitHub‑Actions‑Workflows hinzugefügt werden, werden diese wie gewohnt mit git add, git commit und git push versioniert. Dadurch wird die CI‑Pipeline automatisch aktiviert.

Dieser Workflow stellt sicher, dass alle Änderungen sauber versioniert, nachvollziehbar dokumentiert und konfliktfrei in das Projekt integriert werden. Er bildet die Grundlage für eine stabile und professionelle Git‑Arbeitsweise im gesamten Solr‑Kafka‑Projekt.

