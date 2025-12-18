# FeelingsApp
Name your emotions, capture context, and track how you feel over time.

## Run the app
- Start emulator: `emulator -avd pixel_emulator`
- Launch: `flutter run`

## Milestones (2025)
- 01.11 — postawiony szkielet aplikacji.
- 10.11 — uporządkowana lista emocji (PL) i refaktoryzacja.
- 20.11 — dodany cubit bazy danych, repo na GitHubie.
- 23.11 — naprawy po pierwszym rozjechaniu projektu.
- 24.11 — podział na dwa ekrany (wybór emocji | historia); edycja wybranych emocji; podsumowanie w historii; pierwsze usprawnienia UX.
- 24.11 — przycisk zapisz na głównym ekranie po wyborze emocji; w pop-upie z podemocjami przycisk „Zatwierdź” (zamyka pop-up, jeszcze bez zapisu do DB); po „Zapisz” wyskakuje pop-up z podsumowaniem; dodane notatki w nowym pop-upie.
- 25.11 — merge branchy experimental; wiele TODO zamkniętych, notatki i kolejne usprawnienia UX.

## Co działa teraz
- Wybór emocji, edycja i podsumowanie w historii dwóch ekranów.
- Przepływ z popupem podemocji i podsumowaniem po „Zapisz”.
- Dodawanie notatek w dedykowanym pop-upie.

## Eksperymenty (branch experimental)
- Szersze pop-upy, glassmorphism/neumorphism, animated gradient border.
- Definicje emocji w oddzielnym oknie ustawień.
- Kosz na wpisy z auto-usuwaniem po 30 dniach (umiejscowienie w ustawieniach).
- Podsumowanie pokazujące, spod jakiej emocji głównej pochodzą wybrane podemocje.
- Nazewnictwo notatek w historii i na głównym ekranie do dopracowania.

## Poprawki (15.12)
- Blokada zapisu pustego wpisu w edycji emocji (Historia → Rekord → Wpis).
- Usunięty `_situationController`; opis sytuacji wycięty z podsumowania.
- Wyrównany tytuł pop-upa podsumowania do ikony zamknięcia.


## Poprawki (18.12)
- Dopracowany pop-up „Wybrane emocje”.
- po anulowaniu usunięcia karty emocji wracaj do ekranu z podsumowaniem wybranych emcji
- Dodanie 8. okna z notatką i podkreśleniem, że coś już zapisano. Dodawanie notatki na głównym ekranie.
- Po edycji emocji z historii wracać do historii/podglądu wyedytowanej karty emocji
- obsłuzenie UX uzytkownika - po zapisie emocji - przekierowanie do ekranu historii emocji i podświetlenie chwilowe i powiekszanie zapisanego rekordu - zamiast pop up ze sie udalo.
- Wyróżnianie kontenera z wybraną emocją/podemocją; sygnalizacja wybranych podemocji.

## Roadmap / Backlog
- Wyrównać kafelki z emocjami w środku emocji głównych 
- Zachować datę utworzenia, dodać datę ostatniej edycji. Zmienić połoenie na kafelku: górny prawy róg.
- Ustawienia: imię użytkownika, regulacja natężenia emocji, eksport danych (zębatka).

- Testy na fizycznym Androidzie.
- Lupa/haptic na kafelku z emocją (lepszy feedback dotykowy).
- Integracja Riverpod.
- Dodać pytania do usera - co w Tobie? Co tam się wydarzyło?
