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

## Ostatnie poprawki (15.12)
- Blokada zapisu pustego wpisu w edycji emocji (Historia → Rekord → Wpis).
- Usunięty `_situationController`; opis sytuacji wycięty z podsumowania.
- Wyrównany tytuł pop-upa podsumowania do ikony zamknięcia.

## Roadmap / Backlog
- Dopracować pop-up „Wybrane emocje”.
- Po edycji emocji z historii wracać do historii/podglądu.
- Zachować datę utworzenia, dodać datę ostatniej edycji.
- Ustawienia: imię użytkownika, regulacja natężenia emocji, eksport danych (zębatka).
- Wyróżnianie kontenera z wybraną emocją/podemocją; sygnalizacja wybranych podemocji.
- Dodanie 8. okna z notatką i podkreśleniem, że coś już zapisano.
- Dodawanie notatki bezpośrednio na głównym ekranie.
- Testy na fizycznym Androidzie.
- Lupa/haptic na kafelku z emocją (lepszy feedback dotykowy).
- Integracja Riverpod.
