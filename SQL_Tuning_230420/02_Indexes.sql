/*

Indizes/Indexes


Arten von Indexes:
- Clustered Index / gruppierter Index / CIX
- Non-Clustered Index / nicht-gruppierter Index / NCIX
- Column-Store Index / "Spalten-gespeicherter" Index

Tabellen können Indexes haben, müssen aber nicht!

Tabelle ohne Index ist ein "Heap" (Haufen unsortierter Daten)

*/



SELECT * FROM Pages
WHERE ID = 50

/*
Clustered Index

- "Sortiert" die Tabelle physikalisch neu
- nur einen pro Tabelle
- "Ist die neue Tabelle" (vorher Heap, jetzt Clustered Index)
- Wird automatisch für die selben Spalten erstellt, wenn ein Primary Key vergeben wird
(und noch kein CIX existiert)

*/

CREATE TABLE CIXAutomatic (
ID int identity PRIMARY KEY,
blabla varchar(50))

INSERT INTO CIXAutomatic
VALUES ('abc')
GO 100

SELECT * FROM CIXAutomatic
WHERE ID = 70

--Grundästzlich wollen wir immer Seek haben; Scan ist "schlecht"!


SELECT * FROM CIXAutomatic
WHERE ID BETWEEN 50 AND 70


/*
Non-Clustered Index

- bis zu 1000 Stück pro Tabelle möglich
- sind "Kopien" der Tabelle, aber nur mit der/den angegebenen Spalte(n)
- verweisen am Ende immer auf den CIX (sog. Lookup)



Ein paar "Faustregeln" für Indizierung:
- CIX macht fast immer Sinn bei ID Spalten (Primary Key)
- NCIX auf zu joinende Spalten (bzw. Fremdschlüssel)
- Tabellen mit vielen Reads = Indexes "besser"; bei vielen Write Vorgängen eher hinderlich
---> Indexes müssen ständig aktualisiert werden um geänderte/neue Records einzusortieren
- Spalten die häufig abgefragt/gefiltert werden, sind vermutlich sinnvoll für Index

*/


CREATE TABLE Bestellungen (
ID int identity,
Datum date,
KundenID int )

CREATE TABLE Kunden (
KundenID int identity,
Firma varchar(20) )


INSERT INTO Bestellungen 
SELECT getdate()-365*4 + (365*2*RAND() - 365), 3
GO 10000

SET STATISTICS TIME, IO OFF

INSERT INTO Kunden
VALUES ('Edeka'), ('Rewe'),('Lidl')

SELECT * FROM Bestellungen
SELECT * FROM Kunden

SET STATISTICS TIME, IO ON


SELECT * FROM Bestellungen WHERE KundenID = 2
--logische Lesevorgänge: 78; CPU-Zeit = 0 ms, verstrichene Zeit = 117 ms.

CREATE CLUSTERED INDEX CIX_ID_Bestellungen ON Bestellungen (ID)

SELECT * FROM Bestellungen WHERE KundenID = 2
--logische Lesevorgänge: 77; CPU-Zeit = 0 ms, verstrichene Zeit = 118 ms.

SELECT * FROM Bestellungen WHERE Datum BETWEEN '20190101' AND '20190131'
--logische Lesevorgänge: 77; CPU-Zeit = 0 ms, verstrichene Zeit = 94 ms.

CREATE NONCLUSTERED INDEX NCIX_Datum_Bestellungen ON Bestellungen (Datum)

SELECT * FROM Bestellungen WHERE Datum BETWEEN '20190101' AND '20190131'
--logische Lesevorgänge: 6; CPU-Zeit = 0 ms, verstrichene Zeit = 101 ms.

SELECT Firma, ID, Datum FROM Kunden k
JOIN Bestellungen b ON k.KundenID = b.KundenID
WHERE b.KundenID = 3
--logische Lesevorgänge: 66; CPU-Zeit = 16 ms, verstrichene Zeit = 173 ms.

SELECT Firma, ID, Datum FROM Kunden k
JOIN Bestellungen b ON k.KundenID = b.KundenID
WHERE k.KundenID = 3
--logische Lesevorgänge: 24; CPU-Zeit = 15 ms, verstrichene Zeit = 206 ms.



/*****************************************************************************************/

SELECT * INTO Bestellungen2 FROM Bestellungen

SET STATISTICS TIME, IO ON

SELECT * FROM Bestellungen2

INSERT INTO Bestellungen2 
SELECT getdate()-365*4 + (365*2*RAND() - 365), 2
GO 100000

CREATE CLUSTERED INDEX CIX_ID_Bestellungen2 ON Bestellungen2 (ID)
CREATE NONCLUSTERED INDEX NCIX_Datum_Bestellungen2 ON Bestellungen2 (Datum)

SELECT * FROM Bestellungen2 WHERE Datum BETWEEN '20190101' AND '20190131'
SELECT Datum FROM Bestellungen2 WHERE Datum BETWEEN '20190101' AND '20190131'


SELECT Bestellungen.Datum, Kunden.*
FROM Bestellungen
INNER JOIN KUNDEN ON Bestellungen.KundenID = Kunden.KundenID
Where Bestellungen.Datum between '2018-08-09' and '2018-08-20'

SELECT Bestellungen2.Datum, Kunden.*
FROM Bestellungen2
INNER JOIN KUNDEN ON Bestellungen2.KundenID = Kunden.KundenID
Where Bestellungen2.Datum between '2018-08-09' and '2018-08-20'

--------------------------

SELECT OBJECT_ID ('Bestellungen')
SELECT * FROM sys.dm_db_index_usage_stats WHERE object_id = 645577338
SELECT * FROM sys.sysindexes
SELECT OBJECT_ID ('[NCIX_Datum_Bestellungen]')

select ixs.name, ixs.object_id, usage.* from sys.dm_db_index_usage_stats usage
inner join sys.indexes ixs on usage.index_id = ixs.index_id
where usage.object_id = 645577338
and ixs.object_id = 645577338

/*

Freeware zur IndexWartung:

Ola Hallengren
Brent Ozar sp_blitz

SQLQueryStress; Tool für Stresstest

*/

