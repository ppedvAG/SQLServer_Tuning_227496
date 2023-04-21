/*

Normalisierung einer DB

1. Normalform
Atomare Werte in Spalten 
(Ganzer Name - Nicolas Seidel - in 2 Spalten Vor- und Nachname aufteilen)

2. Normalform 
Eindeutige Zeilen/Rows --> Primary Keys/ID Spalten
Jeder Datensatz in einer Tabelle muss eindeutig zuweisbar/einzigartig sein

3. Normalform
Keine Spalten die von nicht Prim�rschl�ssel abgh�ngig sind 
--> Verwenden von Fremdschl�sseln und Splitting in mehrere Tabellen

*****************************************************************************

Wie werden unsere Daten physisch gespeichert?

Datens�tze werden in sogenannten Seiten/Pages gespeichert
Eine Page hat bis zu 8kb (8060 Bytes f�r Daten) Speicherplatz, Rest ist reserviert f�r Metadaten/Header
Unabh�ngig vom Speicherplatz maximal 700 Rows pro Page

Datens�tze m�ssen vollst�ndig auf eine Seite passen
Wenn gr��er als 8kb, dann nur durch variable Datentypen (bspw. varchar)
Variable Datentypen werden auf sog. Row-Overflow Pages gespeichert.

Wenn eine einzige Spalte gr��er als 8kb ist, dann nur durch sog. LOB Datentypen (bspw. varchar(MAX))
Diese werden auf LOB Pages gespeichert.

8 Pages ergeben eine logische Einheit (Block).

1. Pages (In_row_Data)
2. Row-Overflow Pages
3. LOB Pages

Warum relevant? Pages werden 1:1 von Disc in Memory geladen, daher je weniger Pages desto besser.
Da Datens�tze grunds�tzlich auf eine Page passen m�ssen, werden Pages zwangsl�ufig nicht vollst�ndig bef�llt.
--> Wir wollen Seiten so voll wie m�glich haben; >80% ist gut als Richtwert

*/
USE Northwind
dbcc showcontig('Customers')

SELECT OBJECT_ID('Customers')
SELECT * FROM sys.dm_db_index_physical_stats(DB_ID(), 677577452, -1, 0, 'DETAILED')
--SELECT * FROM sys.dm_db_index_physical_stats


/*

Datentypen

char(20) = 20 Zeichen pro String, es werden auch 20 Zeichen abgespeichert = 20 Bytes
varchar(20) = BIS ZU 20 Zeichen, nur ben�tigte Zeichen gespeichert = bis zu 20 Bytes

nchar(20) = 2 Byte pro Character, weil andere Codierung (UTF-8)
nvarchar(20) = 2 Byte pro Character, weil andere Codierung (UTF-8)

varchar(MAX) = kann bis zu 2GB gro� sein

*/


CREATE DATABASE Test

USE Test
CREATE TABLE Pages (
ID int identity,
Zeug char(4100) )

INSERT INTO Pages
VALUES ('Hallo')
GO 100

SELECT * FROM Pages

dbcc showcontig('Pages')

CREATE TABLE Pages2 (
ID int identity,
Zeug varchar(4100) )

INSERT INTO Pages2
VALUES ('Hallo')
GO 100

dbcc showcontig('Pages2')

SET STATISTICS Time, IO ON

SELECT * FROM Pages2


