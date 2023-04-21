/*

Daten Komprimieren

Durch Kompression kann die Anzahl der Pages drastisch reduziert werden.
2 Arten der Kompression, entweder Page oder Row

Komprimierte Daten m�ssen beim Abruf nat�rlich wieder dekomprimiert werden, das braucht CPU Leistung
Aber: Fast immer net-positive da viel weniger Reads ben�tigt werden

*/

--Eingebaute Procedure, um Kompressionspotential zu erkennen:

EXEC sp_estimate_data_compression_savings dbo, Bestellungen, NULL, NULL, ROW
EXEC sp_estimate_data_compression_savings dbo, Bestellungen, NULL, NULL, PAGE

--> Page Compression "g�nstiger"

--Compression durchf�hren:

ALTER TABLE Bestellungen
REBUILD PARTITION = ALL --Es k�nnen auch nur einzelne Partitionen compressed werden
WITH (DATA_COMPRESSION = PAGE)--ROW

SET STATISTICS IO, TIME ON

SELECT * FROM Bestellungen
--logische Lesevorg�nge: 66, CPU-Zeit = 15 ms, verstrichene Zeit = 271 ms.

SELECT * FROM Bestellungen
--logische Lesevorg�nge: 45, CPU-Zeit = 31 ms, verstrichene Zeit = 295 ms.

