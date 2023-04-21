/*

Locking + Blocking + Deadlock

SQL Server ist ein transaktionales System;
Jede Transaktion sperrt (=lockt) ihre ben�tigte Ressource, damit andere Transaktionen
diese nicht w�hrend des Vorgangs ver�ndern/beeinflussen k�nnen.

Wenn eine Transaktion eine bereits gelockte Ressource ben�tigt, muss sie warten (=blocking)

Sperren 2 oder mehrere Transaktionen gegenseitig ihre ben�tigten Ressourcen, spricht man von
einem Deadlock (= Situation die sich von alleine niemals aufl�st)

Es gibt verschiedene Arten von Locks, sowie Einstellungen und Query Hints um mit diesen umzugehen.
N�heres in MS Doku, Stichworte: 'Type of Locks', 'Isolation Level'

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

SQL Server pr�ft alle 5 Sekunden auf Deadlock Situationen und terminiert eine der blockenden Transaktionen

Wie Deadlocks vermeiden?
- Anwendungen/Skripte/Procedures immer im selben "Logikfluss" schreiben:
	Erst Tabelle A, dann Tabelle B
- Mit Retry on Error Msg 1205 coden (Deadlock Error Message)
- Transaktionen m�glichst kurz halten, und nur kernrelevante Schritte in die selbe Transaktion stecken
BEGIN TRAN Step1, Step2, Step3, Step4 COMMIT OR ROLLBACK
Besser (wenn sinnvoll): BEGIN TRAN Step1, Step2 COMMIT OR ROLLBACK; BEGIN TRAN Step3, Step4 COMMIT OR ROLLBACK usw...



WITH NOLOCK an SELECT Statements k�nnen Read Statements "immer durchgef�hrt" werden, da sie die
ben�tigte Ressource nicht sperren
Aber Vorsicht: Eventuell veraltete/falsche Daten

