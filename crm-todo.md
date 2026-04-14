# TODO

## Calendar Page
- Diese Page soll als Kalendar komplett weg kann aber direkt benutzt werden um eine andere neue Page zu etablieren.

## Verträge Page
- Dies ist die Seite die da hin soll, wo die Verträge waren.
- Sehr simples Schema was die optik angeht. Card identisch zu den anderen drei Datensätzen. Titel untertitel, onclick () => unterroute (details)
- collection: contracts -> id (int)keyword(text), is_active(bool), amount(number), customer(foreign key; wie auch in den anderen beiden Datensätzen schon mit der Relation zum customer)
- Diese müssen auch in der Akte vertreten sein, wenn man im Kunden ist in der Aktenansicht

## Dashboard Page
- KPIS weg
- Dafür eine solide darstellung (wenn möglich in shadcn components) für eine todo (aufgaben) ansicht. hier sollen später dynamisch todos erzeugt werden (also keine hinzufügen funktion im frontend) aber es muss die möglichkeit geben, diese als erledigt zu markieren. hier stelle ich mir nicht spezielles vor. 
- collection: todo -> id (int), keyword (text), is_finished(bool)


## Search Page
- Eine neue Page oberhalb vom Dashboard in der nav.
- Ein Suchfeld mit platzhalter daten die nicht vom api kommen und auf diese Platzhalterdaten eine suchfunktion