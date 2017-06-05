USE przychodnia
GO

--1. wybierz nazwiska pracownikow - lekarzy, ktorzy przepisal Augumantin
SELECT DISTINCT nazwisko AS 'Nazwisko - Augumantin' FROM pracownicy p
INNER JOIN lekarze l on l.id_pracownika = p.id_pracownika
INNER JOIN wizyty w on w.id_lekarza = l.id_lekarza
INNER JOIN choroby_wizyty cw on w.id_wizyty = cw.id_wizyty
INNER JOIN choroby c on c.id_choroby = cw.id_choroby
INNER JOIN leki_choroby lc on lc.id_choroby = c.id_choroby
INNER JOIN leki lek on lek.id_leku = lc.id_leku
WHERE lek.nazwa_leku = 'Augumantin'

--2. ilosc chorob zdiagnozowanych w roku 2016
SELECT COUNT(c.id_choroby) AS 'Liczba chorób 2016' FROM choroby c, choroby_wizyty cw, wizyty w WHERE 
c.id_choroby = cw.id_choroby AND cw.id_wizyty = w.id_wizyty AND
FORMAT(w.data_wizyty, 'yyyy') = '2016'

--3. podstawowa pensja kazdego lekarza (bez bonusu specjalizacji), nazwisko, pensja
SELECT p.nazwisko AS 'Nazwisko', p.placa-SUM(ISNULL(s.bonus_do_placy,0)) AS 'Placa bez stanowiska' FROM 
pracownicy p 
INNER JOIN lekarze l ON l.id_pracownika = p.id_pracownika
LEFT JOIN specjalizacje_lekarzy sl ON l.id_lekarza = sl.id_lekarza
LEFT JOIN specjalizacje s ON s.id_spec = sl.id_spec
GROUP BY p.nazwisko, p.placa
