-- Zadanie 1
USE biuro
SELECT * FROM klienci
SELECT * FROM nieruchomosci
SELECT * FROM nieruchomosci2
SELECT * FROM personel
SELECT * FROM rejestracje
SELECT * FROM wizyty
SELECT * FROM wlasciciele
SELECT * FROM wynajecia
SELECT * FROM biura2
SELECT * FROM biura

-- Zadanie 2 
SELECT 
	(SELECT DISTINCT nieruchomosci.nieruchomoscnr) AS ID,
	(SELECT COUNT(wizyty.nieruchomoscnr)
	FROM wizyty
	WHERE wizyty.nieruchomoscnr = nieruchomosci.nieruchomoscnr) AS ile_wizyt, 
	(SELECT COUNT(wynajecia.nieruchomoscNr)
	FROM wynajecia
	WHERE wynajecia.nieruchomoscNr = nieruchomosci.nieruchomoscnr) AS ile_wynajmow
FROM nieruchomosci 
GROUP BY nieruchomosci.nieruchomoscnr


-- Zadanie 3  
SELECT DISTINCT nieruchomoscNr, STR(((SELECT DISTINCT czynsz FROM nieruchomosci where nieruchomoscnr=wynajecia.nieruchomoscNr GROUP BY czynsz)*100/wynajecia.czynsz)-100)+'%'
FROM wynajecia 
GROUP BY wynajecia.czynsz, nieruchomoscNr
ORDER BY nieruchomoscNr

-- Zadanie 4
SELECT nieruchomoscnr,
(SELECT SUM((DATEDIFF(MONTH, od_kiedy, do_kiedy)+1)*czynsz) FROM wynajecia WHERE nieruchomosci.nieruchomoscnr = nieruchomoscNr) AS ile
FROM nieruchomosci

-- Zadanie 5  
SELECT biuroNr,
	(SELECT SUM((DATEDIFF(MONTH, od_kiedy, do_kiedy)+1)*wynajecia.czynsz*0.3) FROM nieruchomosci, wynajecia
	WHERE biura.biuroNr=nieruchomosci.biuroNr and nieruchomosci.nieruchomoscnr=wynajecia.nieruchomoscNr) AS ile
FROM biura


-- Zadanie 6A
SELECT miasto, COUNT(wynajecia.czynsz) AS ile
FROM nieruchomosci, wynajecia
WHERE wynajecia.nieruchomoscnr = nieruchomosci.nieruchomoscnr
GROUP BY miasto ORDER BY ile DESC

-- Zadanie 6B
SELECT miasto, SUM(DATEDIFF(DAY, od_kiedy, do_kiedy)) AS ile
FROM nieruchomosci, wynajecia
WHERE wynajecia.nieruchomoscnr = nieruchomosci.nieruchomoscnr
GROUP BY miasto ORDER BY ile DESC

-- Zadanie 7
SELECT DISTINCT wizyty.klientnr, wizyty.nieruchomoscnr 
FROM wizyty, wynajecia
WHERE wynajecia.klientnr=wizyty.klientnr
	  AND wynajecia.nieruchomoscNr=wizyty.nieruchomoscnr
ORDER BY wizyty.klientnr

-- Zadanie 8A
SELECT wizyty.klientnr, COUNT(data_wizyty)/16
FROM wizyty, wynajecia 
GROUP BY wizyty.klientnr

-- Zadanie 8B
SELECT DISTINCT klienci.klientnr 
FROM klienci, wynajecia
WHERE wynajecia.klientnr=klienci.klientnr
	  AND klienci.max_czynsz<wynajecia.czynsz

-- Zadanie 9
SELECT biuronr 
FROM biura 
WHERE not exists (SELECT * FROM nieruchomosci WHERE biuroNr = biura.biuroNr)

-- Zadanie 11A
SELECT COUNT(*) AS panie, (SELECT COUNT(imie) FROM personel WHERE plec = 'M') AS panowie 
FROM personel 
WHERE plec = 'K'

-- Zadanie 11B
SELECT biuronr,
(SELECT COUNT(*) FROM personel WHERE plec='K' and biuroNr=biura.biuroNr) AS panie,
(SELECT COUNT(*) FROM personel WHERE plec='M' and biuroNr=biura.biuroNr) AS panowie
FROM biura 
WHERE EXISTS (SELECT * FROM personel WHERE biuroNr=biura.biuroNr)

-- Zadanie 11C
SELECT DISTINCT miasto,
(SELECT COUNT(imie) FROM personel AS p, biura AS b2 WHERE p.plec='K' and p.biuroNr=b2.biuroNr and b2.miasto=b.miasto) AS panie,
(SELECT COUNT(imie) FROM personel AS p, biura AS b2 WHERE p.plec='M' and p.biuroNr=b2.biuroNr and b2.miasto=b.miasto) AS panowie
FROM biura AS b 
ORDER BY miasto

-- Zadanie 11D
SELECT stanowisko,
(SELECT COUNT(*) FROM personel AS p2 WHERE plec='K' and p2.stanowisko=p1.stanowisko) AS panie,
(SELECT COUNT(*) FROM personel AS p2 WHERE plec='M' and p2.stanowisko=p1.stanowisko) AS panowie
FROM personel AS p1 
GROUP BY stanowisko

