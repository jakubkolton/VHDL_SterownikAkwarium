# VHDL_SterownikAkwarium

Na wejście sterownika jest podawana temperatura wody. Sterownik powinien włączać światło w akwarium co 12 godzin, na 8 godzin.  Gdy temperatura wody spadnie poniżej temp. 10 stopni powinna zostać włączona grzałka.  
Układ za pomocą zewnętrznego zegara wytwarza swój własny zegarek 24-godzinny. Dzięki niemu, o odpowiednich porach dnia włącza i wyłącza światło. Ponadto, na bazie odczytu temperatury, włącza i wyłącza grzałkę tak, aby temperatura wody nie spadła poniżej 10 stopni Celsjusza.

#### Fragment przebiegu symulacji:
![](./Symulacja.jpg?raw=true "Symulacja")

Dokładny opis działania kodu i przebieg symulacji znajdują się w pliku PDF.
