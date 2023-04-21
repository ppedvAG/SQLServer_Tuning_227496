/*

Partitionen erstellen

Nützlich für folgendes:
- Partitionen können einzeln gewartet werden, d.h. Index-Wartung, Backup/Restore,
Compressions usw. (Wartungs- und Downtime- Optimierung)
- Da jede Partition eigenes File ist, können aktuelle Daten auf schnelle Laufwerke,
alte Archivdaten auf langsame Laufwerke gelegt werden (Hardware Optimierung)
- Netter Zusatzeffekt: Partition Elimination
---> Query Optimizer muss u.U. nur eine Partition aufrufen, daher viel weniger Reads/bessere Performance

*/

--1. Schritt: Files und Filegroups erstellen; benötigte Partitionen erfassen

SELECT MIN(Datum), MAX(Datum) FROM Bestellungen


--2. Schritt: Partitionsfunktion erstellen

CREATE PARTITION FUNCTION f_PartitionBestellungen (Date)
AS
RANGE LEFT FOR VALUES (
'20181231', '20191231', '20201231')


--3. Schritt: Partitions Schema erstellen

CREATE PARTITION SCHEME ps_PartitionBestellungen
AS PARTITION f_PartitionBestellungen
TO ('Bestellungen2018', 'Bestellungen2019', 'Bestellungen2020', [PRIMARY])


--4. Schritt: CIX löschen und neu erstellen um Datensätze in Filegroups zu sortieren

CREATE CLUSTERED INDEX CIX_ID_Bestellungen 
ON Bestellungen (ID)
ON ps_PartitionBestellungen (Datum)


SELECT COUNT(*), $PARTITION.f_PartitionBestellungen(Datum), YEAR(Datum) FROM Bestellungen
GROUP BY $PARTITION.f_PartitionBestellungen(Datum), YEAR(Datum) 


INSERT INTO Bestellungen
VALUES ('20210131', 2)

INSERT INTO Bestellungen
VALUES ('20190101', 2)

SELECT * FROM sys.dm_db_index_physical_stats(DB_ID(), 645577338, -1, 0, 'DETAILED')

SELECT OBJECT_ID('Bestellungen')


--Partitionen erweitern mit SPLIT

ALTER DATABASE TEst
ADD FILEGROUP Bestellungen2022

ALTER DATABASE TEst
ADD FILE (NAME = Bestellungen2022, 
FILENAME = 'C:\Program Files\Microsoft SQL Server\MSSQL15.MSSQLSERVER\MSSQL\DATA\Bestellungen2022.ndf')
TO FILEGROUP Bestellungen2022

ALTER PARTITION SCHEME ps_PartitionBestellungen NEXT USED 'Bestellungen2021'

ALTER PARTITION FUNCTION f_PartitionBestellungen() SPLIT RANGE ('20211231')

INSERT INTO Bestellungen
VALUES ('20210131', 2)

INSERT INTO Bestellungen
VALUES ('20220131', 2)




