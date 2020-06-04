* Encoding: UTF-8.

* Dit script is te vinden op https://github.com/Wienche/TweetToEdgelist
* Dit script is gelicenceerd onder een Creative Commons Naamsvermelding-NietCommercieel 4.0 Internationaal-licentie.
* Wanneer je gebruik wilt maken van dit script, hanteer dan de volgende methode van naamsvermelding:
* Lidwien van de Wijngaert, Tweets to Edgelist (2020). cc-nc 4.0. https://github.com/Wienche/TweetToEdgelist
* Kijk voor meer informatie over de voorwaarden voor het gebruik van dit script op http://creativecommons.org/licenses/by-nc/4.0/

* Stap 1. File openen. 
* Zet je file ergens neer. Ik gebruik hier de desktop van mijn Mac. Als je een windows machine gebruikt of de file ergens anders zet, dan moet je natuurlijk een ander pad schrijven. 

GET FILE '/Users/Lidwien/Desktop/Familie.sav'. 

* Voor de overzichtelijkeheid heb ik in dit voorbeeld file heb ik alleen de twee relevante variabelen 'auteur' en 'berichttekst' overgenomen. 

* Stap 2. Een nieuwe variabele maken.  

* Om ervoor te zorgen dat de oorspronkelijke tweet in stand blijft kopieer ik de inhoud van de tweet naar een nieuwe variabele 'tweet'. 
* In dezelfde stap zorg ik ervoor dat alle kapitalen worden verwijderd. 

STRING  tweet (A200). 
COMPUTE tweet=LOWER(berichttekst). 
EXECUTE. 

* Stap 3. Alle rare tekens verwijderen. 

COMPUTE tweet=REPLACE(tweet,","," ").
COMPUTE tweet=REPLACE(tweet,"."," ").
COMPUTE tweet=REPLACE(tweet,"?"," ").
COMPUTE tweet=REPLACE(tweet,"!"," ").
COMPUTE tweet=REPLACE(tweet,";"," ").
COMPUTE tweet=REPLACE(tweet,":"," ").
COMPUTE tweet=REPLACE(tweet,"'"," ").
COMPUTE tweet=REPLACE(tweet,'"'," ").
COMPUTE tweet=REPLACE(tweet,'('," ").
COMPUTE tweet=REPLACE(tweet,')'," ").
COMPUTE tweet=REPLACE(tweet,'['," ").
COMPUTE tweet=REPLACE(tweet,']'," ").
COMPUTE tweet=REPLACE(tweet,'-'," ").

LOOP.
COMPUTE tweet = REPLACE(tweet,'  ',' ').
END LOOP IF char.index(tweet,'  ') = 0.
EXECUTE. 

* Ik plaats er een spatie en een x achter zodat ook de laatste @Mention straks wordt gevonden. 

COMPUTE Tweet=CONCAT(Tweet," x").
EXECUTE.

* Stap 4. Mentions filteren*

* Eerst kijken wat het maximale aantal @Mention in 1 Tweet is.

NUMERIC AantalMentions(F2.0).
COMPUTE AantalMentions = 0.
LOOP #i=1 to 250.
. COMPUTE AantalMentions = AantalMentions + INDEX(SUBSTR(Tweet,#i,1),"@").
END LOOP.

FREQUENCIES VARIABLES=AantalMentions 
  /ORDER=ANALYSIS.
EXECUTE.

* In dit geval zijn dat er drie. Als er meer @Mentions zijn moet je de lijst hieronder uitbreiden (zoveel als je wilt). 
* Die doe je door * weg te halen en/of nog extra mentions toe te voegen (gewoon doornummeren

NUMERIC ZoekMention(F2.0).
NUMERIC ZoekSpatie(F2.0).
STRING Mention1(A25).
STRING Mention2(A25).
STRING Mention3(A25).
*STRING Mention4(A25).
*STRING Mention5(A25).
*STRING Mention6(A25).
*STRING Mention7(A25).
*STRING Mention8(A25).
*STRING Mention9(A25).
*STRING Mention10(A25).

DO REPEAT Mention = Mention1 Mention2 Mention3.

* Als je meer dan drie mentions hebt moet je het DO REPEAT commando ook uitbreiden met het aantal mentions dat je nodig hebt. 

* Hieronder wordt voor elke mention een kolom aangemaakt en de naam erin gezet (indien aanwezig). 

COMPUTE ZoekMention=0. 
COMPUTE ZoekSpatie=0. 
COMPUTE ZoekMention=CHAR.INDEX(Tweet,"@").
COMPUTE Mention=CHAR.SUBSTR(Tweet,ZoekMention,25).
COMPUTE ZoekSpatie=CHAR.INDEX(Mention," ").
COMPUTE ZoekSpatie=ZoekSpatie - 2.
RECODE ZoekSpatie (-1=1) (-2=1) (0=1).
COMPUTE Mention=CHAR.SUBSTR(Mention,2,Zoekspatie).
COMPUTE Tweet=REPLACE(Tweet,"@"," ",1).
END REPEAT print. 
EXECUTE. 
DELETE VARIABLES ZoekMention ZoekSpatie.

* In de output ontstaat een error melding. 
* >Warning # 650 
* >The second argument to the CHAR.SUBSTR function is invalid. 
* >Command line: 394  Current case: 3  Current splitfile group: 1

* Deze melding kun je negeren. SPSS is geen chique programmeertaal. Ik had even geen andere oplossing. 

* Stap 5. Rename auteur en lower maken. 

RENAME VARIABLES (Auteur = Source).
COMPUTE Source=LOWER(Source).
EXECUTE.

* Bewaar de file onder een andere naam. 
* Ook hier weer je eigen pad goed aanpassen. 

SAVE OUTFILE='/Users/Lidwien/Desktop/FamilieEdgelist.sav'
  /COMPRESSED.

* Herstructureer de file zodat de mentions onder elkaar komen te staan. 
* Ook hier eventueel het aantal Mentions weer uitbreiden. 

  VARSTOCASES
  /MAKE Target FROM Mention1 Mention2 Mention3
  /INDEX=Index1(14) 
  /KEEP=Source 
  /NULL=DROP.

* Bewaar opnieuw, maar nu het definitieve resultaat. 

SAVE OUTFILE='/Users/Lidwien/Desktop/FamilieEdgelist.sav'
  /COMPRESSED.

