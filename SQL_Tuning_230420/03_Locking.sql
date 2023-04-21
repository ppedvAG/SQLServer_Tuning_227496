/*

Locking + Blocking + Deadlock

SQL Server ist ein transaktionales System;
Jede Transaktion sperrt (=lockt) ihre benötigte Ressource, damit andere Transaktionen
diese nicht während des Vorgangs verändern/beeinflussen können.

Wenn eine Transaktion eine bereits gelockte Ressource benötigt, muss sie warten (=blocking)

Sperren 2 oder mehrere Transaktionen gegenseitig ihre benötigten Ressourcen, spricht man von
einem Deadlock (= Situation die sich von alleine niemals auflöst)

Es gibt verschiedene Arten von Locks, sowie Einstellungen und Query Hints um mit diesen umzugehen.
Näheres in MS Doku, Stichworte: 'Type of Locks', 'Isolation Level'

*/


CREATE TABLE links (
ID int identity,
Zeug varchar(10) )
GO

CREATE TABLE rechts (
ID int identity,
Zeug varchar(10) )
GO

INSERT INTO links
VALUES ('links')

INSERT INTO rechts
VALUES ('rechts')


BEGIN TRAN 

UPDATE rechts 
SET Zeug = 'xyz'
WHERE ID = 1

UPDATE links
SET Zeug = 'xyz'
WHERE ID = 1

ROLLBACK

/*

SQL Server prüft alle 5 Sekunden auf Deadlock Situationen und terminiert eine der blockenden Transaktionen

Wie Deadlocks vermeiden?
- Anwendungen/Skripte/Procedures immer im selben "Logikfluss" schreiben:
	Erst Tabelle A, dann Tabelle B
- Mit Retry on Error Msg 1205 coden (Deadlock Error Message)
- Transaktionen möglichst kurz halten, und nur kernrelevante Schritte in die selbe Transaktion stecken
BEGIN TRAN Step1, Step2, Step3, Step4 COMMIT OR ROLLBACK
Besser (wenn sinnvoll): BEGIN TRAN Step1, Step2 COMMIT OR ROLLBACK; BEGIN TRAN Step3, Step4 COMMIT OR ROLLBACK usw...



WITH NOLOCK an SELECT Statements können Read Statements "immer durchgeführt" werden, da sie die
benötigte Ressource nicht sperren
Aber Vorsicht: Eventuell veraltete/falsche Daten

