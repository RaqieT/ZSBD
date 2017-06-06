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

--4.imie i nazwisko wszystkich pacjentow urodzonych w kwietniu
SELECT CONCAT(p.imie,' ', p.nazwisko) AS 'Imie Nazwisko'  
FROM pacjenci p WHERE
SUBSTRING(p.PESEL,3,2) = '04'

--5.nazwisko pacjenta u ktorego stwierdzono ta sama chorobe w przeciagu 6 miesiecy
SELECT DISTINCT p.nazwisko AS 'Nazwisko'
FROM pacjenci p, wizyty w1, wizyty w2, choroby ch, choroby_wizyty cw, choroby ch2, choroby_wizyty cw2
WHERE p.id_pacjenta = w1.id_pacjenta 
AND p.id_pacjenta = w2.id_pacjenta 
AND w1.id_wizyty != w2.id_wizyty 
AND w1.id_wizyty = cw.id_wizyty
AND cw.id_choroby = ch.id_choroby 
AND w2.id_wizyty = cw2.id_wizyty 
AND cw2.id_choroby = ch2.id_choroby 
AND ch.id_choroby = ch2.id_choroby
AND DATEDIFF(m,w1.data_wizyty,w2.data_wizyty) <= 6 AND DATEDIFF(m,w1.data_wizyty,w2.data_wizyty) >= -6
--tutaj sa dwa diffy, jedna data jest o 6 mies starsza a druga o 6 miesiecy mlodsza i dlatego przedzial od -6 do 6

--6. opis wizyty i nazwisko pacjenta, ktoremu nie zdiagnozowano choroby podczas wizyty
SELECT p.nazwisko AS 'Nazwisko', w.opis AS 'Opis wizyty'
FROM pacjenci p, wizyty w
WHERE w.id_pacjenta = p.id_pacjenta 
AND w.id_wizyty NOT IN(SELECT id_wizyty FROM choroby_wizyty)
ORDER BY p.nazwisko

--7. imie, nazwisko i data urodzenia pacjenta
SELECT p.imie AS 'Imie', p.nazwisko AS 'Nazwisko', CAST(CONCAT(
CASE 
	WHEN SUBSTRING(p.PESEL,1,2) <= SUBSTRING(CAST(DATEPART(YY,GETDATE()) AS VARCHAR(4)),3,2)
		THEN '20'
	ELSE '19'
END
,SUBSTRING(p.PESEL,1,2),'/',SUBSTRING(p.PESEL,3,2),'/',SUBSTRING(p.PESEL,5,2))AS DATE) AS 'Data urodzenia'
FROM pacjenci p

--8. Alergie zdiagnozowane przez danego lekarza

SELECT p.nazwisko, STUFF(
                   (SELECT
                        ', ' + SUBSTRING(ch.nazwa,10,LEN(ch.nazwa)-9)
                        FROM  lekarze l, wizyty w, choroby_wizyty cw, choroby ch
						WHERE
						
						p.id_pracownika = l.id_pracownika AND
						l.id_lekarza = w.id_lekarza AND
						w.id_wizyty = cw.id_wizyty AND
						ch.id_choroby = cw.id_choroby AND
						ch.nazwa LIKE 'Alergia%'
                        ORDER BY ch.nazwa
                        FOR XML PATH(''), TYPE
                   ).value('.','varchar(max)')
                   ,1,2, ''
              ) AS 'Alergie'
FROM pracownicy p, lekarze l2, wizyty w2, choroby_wizyty cw2, choroby ch2
WHERE
	p.id_pracownika = l2.id_pracownika AND
	l2.id_lekarza = w2.id_lekarza AND
	w2.id_wizyty = cw2.id_wizyty AND
	ch2.id_choroby = cw2.id_choroby AND
	ch2.nazwa LIKE 'Alergia%' 
GROUP BY p.nazwisko, p.id_pracownika

--9. wizyty z miesiacami ktore maja 31 dni
--10. place i nazwiska pracownikow ktorzy zarabiaja wiecej niz 50% sredniej placy lekarzy
--11. pacjentow urodzonych w roku przestepnym
--12. ile emerytow, dzieci i ludzi
--13. ile ludzikow odwiedzilo lekarza ktory nie ma zadnej specjalizacji, w ciagu jakiegos tam okresu czasu
--14. lekarze zarabiajacych wiecej niz lekarz ktory ma najwiecej przyjec w miesiacu
--15. leki najczesciej przepisywane (dla danej choroby)