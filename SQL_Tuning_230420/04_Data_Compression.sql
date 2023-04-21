/*

Daten Komprimieren

Durch Kompression kann die Anzahl der Pages drastisch reduziert werden.
2 Arten der Kompression, entweder Page oder Row

Komprimierte Daten müssen beim Abruf natürlich wieder dekomprimiert werden, das braucht CPU Leistung
Aber: Fast immer net-positive da viel weniger Reads benötigt werden

*/

--Eingebaute Procedure, um Kompressionspotential zu erkennen:

EXEC sp_estimate_data_compression_savings dbo, Bestellungen, NULL, NULL, ROW
EXEC sp_estimate_data_compression_savings dbo, Bestellungen, NULL, NULL, PAGE

--> Page Compression "günstiger"

--Compression durchführen:

ALTER TABLE Bestellungen
REBUILD PARTITION = ALL --Es können auch nur einzelne Partitionen compressed werden
WITH (DATA_COMPRESSION = PAGE)--ROW

SET STATISTICS IO, TIME ON

SELECT * FROM Bestellungen
--logische Lesevorgänge: 66, CPU-Zeit = 15 ms, verstrichene Zeit = 271 ms.

SELECT * FROM Bestellungen
--logische Lesevorgänge: 45, CPU-Zeit = 31 ms, verstrichene Zeit = 295 ms.

