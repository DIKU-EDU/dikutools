# Rettefordelingsscript 

Bruges når eksamen er afleveret, og opgaverne skal fordeles på instruktorer.

Scriptet kræver Mathematica. (Er lavet til Mathematica 8, kører muligvis på
tidligere versioner.)

## Brug af scriptet

* Gå ind på Absalon og copy-paste deltager-tabellen fra *Participants* ind
  i filen `studerende-raw.txt`.
    - Husk at filtrere efter rollen *Student*.
    - I bunden kan man sætte den til at vise flere deltagere end 100 ved at
      inspecte HTML'en på dropdown-menuen og sætte værdien til noget
      passende højt. (Fx 250).
* Gå ind på Absalon og copy-paste afleverings-tabellen fra afleveringspunktet
  ind i filen `afleveringer.txt`.
    - Husk at filtrere efter dem der har afleveret.
    - Samme trick kan bruges som under *Participants*.
* Download en zip-fil indeholdende alle afleveringer og udpak dem et passende
  sted.
* Ret instruktorlisten i scriptet. (*Navne på instruktorer*)
    - Instruktorlisten skal være ordnet efter holdnummer, og den nulindexerer.
      (Dvs, første plads er instruktoren på hold 0, etc...)
* Hvis antallet af instruktorer ikke er 10, da vil nogle konstanter skulle
  rettes i koden.
* Ret værdien af `opgaveMappe`, så den peger på mappen du har downloadet
  opgaverne i. Hvis opgaverne ligger i flere mapper, da kan wildcards bruges.
* Kør scriptet. Hvis det fejler, da har du sikkert ikke rettet konstanterne helt.
