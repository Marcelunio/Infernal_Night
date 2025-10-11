# Infernal Night

Gra typu rougelike w stylistyce pixel art o mrocznym klimacie, w której główna postać jest właścicielem firmy która eliminuje demony z mieszkań. 

## DEV STACK:

**Game engine:** godot engine
**Język programowania:** gdscript
**System kontroli wersji:** git, github
**Program do grafiki:** aseprite

## Gameplay loop:

Zaczynamy z pustym hideoutem firmy, z niej startujemy nasze kontrakty(kontrakt = run). Dostajemy w nim liste domow do "oczyszczenia". Z tej listy mamy do wybrania 1 z 3 losowych domow(specydficznie 3 
zeby gracz sie nie przerazil za duzym wyborem). 

### Przebieg:

"Oczyszczanie" domu zaczyna sie przy drzwiach wejściowych. Wbijasz, zabijasz i przechodzisz do nastepnego domu. Dostajemy po kontrakcie market value naszej firmy. Im wiekszy market value, tym lepsze kontrakty otrzymujemy, moga one zawierac side quest ktory da ci dodatkowe nagrody.
