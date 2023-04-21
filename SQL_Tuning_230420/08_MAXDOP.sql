/*

Maximum Degree of Parallelism (MAXDOP)

"Wieviele Cores dürfen maximal an einer Abfrage arbeiten"


Zuviele Cores unter Umständen langsamer

"Weniger ist wie so oft mehr"; zuviele Cores bei relativ kostengünstigen Abfragen
machen das Ergebnis u.U sogar langsamer
'Gathering Threads' ist sehr kostenintensiv

Analogie: 1000 Personen zählen 1000 Schrauben; Bis jede Person seine gezählte Anzahl
gesagt hat, und das Ergebnis aufsummiert wurde, vergeht sehr viel Zeit.
Vermutlich wären 4 Personen insgesamt schneller gewesen.

Weiteres Problem:
Arbeitsverteilung auf die Cores ist nicht ausgewogen.
Bis alle Threads zusammengeführt werden können, muss immer auf den "langsamsten" Core gewartet werden
(Der Core mit der meisten Arbeitslast)


Einstellungen zu MAXDOP unter Server Properties.
Wieviele Cores dürfen maximal verwendet werden? (0 = Automatische Zuweisung)
Threshold: Ab welchen Kosten ("SQL Dollar") darf Parallelismus verwendet werden


In Query können Server Settings überschrieben werden mit MAXDOP HINT:

SELECT * FROM Table
OPTION (MAXDOP n)