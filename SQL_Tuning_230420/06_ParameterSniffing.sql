USE test

SELECT * FROM Bestellungen WHERE ID = 50 --adhoc Abfrage
--Bei adhoc (non parameterized) Queries kann SQL Server den Abfrageplan nicht wiederverwenden

--> Abfrage als SP umbauen, da Wiederverwendung grundsätzlich gut ist:

CREATE PROCEDURE sp_BestellID @ID int
AS
SELECT * FROM Bestellungen WHERE ID = @ID
GO

EXEC sp_BestellID 200


--Aber evtl. Problem:
--PARAMETER SNIFFING = Werteverteilung kann extrem ungleichmäßig sein
--Der Parameter, der beim erstmaligen ausführen einer Prozedur angegeben wurde, bestimmt den Abfrageplan
--Dieser Plan ist u.U suboptimal für andere Werte

SELECT * FROM Bestellungen
WHERE KundenID =3

CREATE TABLE Tiere (
ID int identity,
Tier varchar(20) )

ALTER TABLE Tiere
ADD Zeug varchar(10)

INSERT INTO Tiere
SELECT 'Maus'
GO 10

INSERT INTO Tiere
SELECT 'Elephant'
GO 100000

UPDATE Tiere
SET Zeug = CASE WHEN Tier = 'Maus' THEN 1
ELSE 2
END

SET STATISTICS IO,TIME ON

SELECT * FROM Tiere WHERE Tier = 'Maus'
SELECT * FROm Tiere WHERE Tier = 'Elephant'

CREATE PROCEDURE sp_AnzahlTier @Tier varchar(20)
AS
SELECT * FROM Tiere WHERE Tier = @Tier


--Maus: logische Lesevorgänge: 35, , CPU-Zeit = 0 ms, verstrichene Zeit = 38 ms.; NCIX SEEK + LOOKUP

--Elephant: logische Lesevorgänge: 740;  CPU-Zeit = 62 ms, verstrichene Zeit = 926 ms.; CIX SCAN


EXEC sp_AnzahlTier 'Elephant'

EXEC sp_AnzahlTier 'Maus' -- logische Lesevorgänge: 740, CPU-Zeit = 15 ms, verstrichene Zeit = 14 ms.

ALTER PROCEDURE sp_AnzahlTier @Tier varchar(20) 
AS
SELECT * FROM Tiere WHERE Tier = @Tier

EXEC sp_AnzahlTier 'Elephant'

EXEC sp_AnzahlTier 'Maus'

--Lösung (leider auch nicht 100% optimal, da Plan-ReUse eigentlich gut ist):
--Wiederverwenden des gespeicherten Plans umgehen über HINT: WITH RECOMPILE
ALTER PROCEDURE sp_BestellID @ID int WITH RECOMPILE
AS
SELECT * FROM Bestellungen WHERE ID = @ID
--Abfrageplan wird bei jeder Ausführung neu berechnet

--Alternative Lösung:
--"Mittelwert" definieren, der "schon einigermaßen passt für alle Werte"
INSERT INTO Tiere
SELECT 'Giraffe', 2
GO 50000

SET STATISTICS TIME, IO ON


ALTER PROCEDURE sp_AnzahlTier @Tier varchar(20) 
AS
SELECT * FROM Tiere WHERE Tier = @Tier 
OPTION (OPTIMIZE FOR (@Tier = 'Giraffe'))

EXEC sp_AnzahlTier 'Giraffe'
EXEC sp_AnzahlTier 'Elephant'
EXEC sp_AnzahlTier 'Maus'


--3. "alternative Lösung", aber eher schlecht: Mehr als eine Procedure

CREATE PROCEDURE sp_AnzahlTierGross @Tier varchar(20)
AS
SELECT * FROM Tiere WHERE Tier = @Tier
OPTION (OPTIMIZE FOR (@Tier = 'Elephant'))

CREATE PROCEDURE sp_AnzahlTierKlein @Tier varchar(20)
AS
SELECT * FROM Tiere WHERE Tier = @Tier
OPTION (OPTIMIZE FOR (@Tier = 'Maus'))


-----

SELECT * FROM Tiere
WHERE Tier = 'Maus'
GO 10


SELECT * FROM Tiere
WHERE ID = 100

EXEC sp_AnzahlTierGross 'Giraffe'