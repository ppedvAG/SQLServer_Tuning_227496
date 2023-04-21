/*

Maximum Degree of Parallelism (MAXDOP)

"Wieviele Cores d�rfen maximal an einer Abfrage arbeiten"


Zuviele Cores unter Umst�nden langsamer

"Weniger ist wie so oft mehr"; zuviele Cores bei relativ kosteng�nstigen Abfragen
machen das Ergebnis u.U sogar langsamer
'Gathering Threads' ist sehr kostenintensiv

Analogie: 1000 Personen z�hlen 1000 Schrauben; Bis jede Person seine gez�hlte Anzahl
gesagt hat, und das Ergebnis aufsummiert wurde, vergeht sehr viel Zeit.
Vermutlich w�ren 4 Personen insgesamt schneller gewesen.

Weiteres Problem:
Arbeitsverteilung auf die Cores ist nicht ausgewogen.
Bis alle Threads zusammengef�hrt werden k�nnen, muss immer auf den "langsamsten" Core gewartet werden
(Der Core mit der meisten Arbeitslast)


Einstellungen zu MAXDOP unter Server Properties.
Wieviele Cores d�rfen maximal verwendet werden? (0 = Automatische Zuweisung)
Threshold: Ab welchen Kosten ("SQL Dollar") darf Parallelismus verwendet werden


In Query k�nnen Server Settings �berschrieben werden mit MAXDOP HINT:

SELECT * FROM Table
OPTION (MAXDOP n)