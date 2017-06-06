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

SELECT p.nazwisko AS 'Nazwisko', STUFF(
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

--9. wizyty ktore odbyly sie w miesiacu z liczba dni 30
SELECT p.nazwisko AS 'Lekarz', pa.nazwisko AS 'Pacjent', w.opis AS 'Opis'
FROM wizyty w, lekarze l, pracownicy p, pacjenci pa
WHERE w.id_lekarza = l.id_lekarza AND p.id_pracownika = l.id_pracownika AND w.id_pacjenta = pa.id_pacjenta
AND DAY(DATEADD(DD,-1,DATEADD(MM,DATEDIFF(MM,-1,w.data_wizyty),0))) = 30

--10. place i nazwiska pracownikow (nie lekarzy) ktorzy zarabiaja wiecej niz 1/3 sredniej placy lekarzy
SELECT p.nazwisko AS 'Nazwisko', p.placa AS 'Placa'
FROM pracownicy p
LEFT JOIN lekarze lek ON lek.id_pracownika = p.id_pracownika
WHERE p.placa > (SELECT AVG(p2.placa)/3 FROM  pracownicy p2, lekarze l WHERE p2.id_pracownika = l.id_pracownika)
AND lek.id_lekarza IS NULL

--11. pacjenci urodzonych w roku przestepnym
SELECT p.nazwisko AS 'Nazwisko'
FROM pacjenci p 
WHERE CAST(CONCAT(
CASE 
	WHEN SUBSTRING(p.PESEL,1,2) <= SUBSTRING(CAST(DATEPART(YY,GETDATE()) AS VARCHAR(4)),3,2)
		THEN '20'
	ELSE '19'
END
,SUBSTRING(p.PESEL,1,2)) AS FLOAT) / CAST(4 AS FLOAT) -
CAST(CONCAT(
CASE 
	WHEN SUBSTRING(p.PESEL,1,2) <= SUBSTRING(CAST(DATEPART(YY,GETDATE()) AS VARCHAR(4)),3,2)
		THEN '20'
	ELSE '19'
END
,SUBSTRING(p.PESEL,1,2)) AS INT) / 4 = 0

--12. ile emerytow (od 65 lat), dzieci (do 18 lat)
SELECT COUNT(p1.id_pacjenta) AS 'Emeryci',
	(SELECT COUNT(p2.id_pacjenta) FROM pacjenci p2 WHERE
		DATEDIFF(YY,CAST(CONCAT(
		CASE 
			WHEN SUBSTRING(p2.PESEL,1,2) <= SUBSTRING(CAST(DATEPART(YY,GETDATE()) AS VARCHAR(4)),3,2)
				THEN '20'
			ELSE '19'
		END
		,SUBSTRING(p2.PESEL,1,2),'-',SUBSTRING(p2.PESEL,3,2),'-',SUBSTRING(p2.PESEL,5,2))AS DATE), CONVERT(datetimeoffset, GETDATE())) < 18
) AS 'Dzieci'
FROM pacjenci p1
WHERE DATEDIFF(YY,CAST(CONCAT(
CASE 
	WHEN SUBSTRING(p1.PESEL,1,2) <= SUBSTRING(CAST(DATEPART(YY,GETDATE()) AS VARCHAR(4)),3,2)
		THEN '20'
	ELSE '19'
END
,SUBSTRING(p1.PESEL,1,2),'-',SUBSTRING(p1.PESEL,3,2),'-',SUBSTRING(p1.PESEL,5,2))AS DATE), CONVERT(datetimeoffset, GETDATE())) > 65

--13. ile pacjentow odwiedzilo lekarza ktory nie ma zadnej specjalizacji, w ciagu jakiegos tam okresu czasu
SELECT DISTINCT COUNT(p.id_pacjenta) AS 'Pacjenci lekarza bez spec. w ciagu ostatniego roku'
FROM pacjenci p
INNER JOIN wizyty w ON w.id_pacjenta = p.id_pacjenta
INNER JOIN lekarze l ON w.id_lekarza = l.id_lekarza
LEFT JOIN specjalizacje_lekarzy sl ON sl.id_lekarza = l.id_lekarza 
WHERE sl.id_spec IS NULL AND DATEDIFF(d,w.data_wizyty ,GETDATE())/365.25 < 1

--14. lekarze zarabiajacy wiecej niz lekarz ktory ma najwiecej przyjec
SELECT p.nazwisko AS 'Nazwisko'
FROM pracownicy p, lekarze l
WHERE
p.id_pracownika = l.id_pracownika AND
p.placa > (SELECT TOP 1 best.placa FROM (
SELECT TOP 1 p2.id_pracownika AS idprac, COUNT(w2.id_wizyty) AS wiz, p2.placa AS placa FROM pracownicy p2, lekarze l2, wizyty w2 WHERE
p2.id_pracownika = l2.id_pracownika AND w2.id_lekarza = l2.id_lekarza GROUP BY p2.id_pracownika, placa ORDER BY wiz DESC) best)

--15. pokoje, w ktorych stwierdzono Zapalenie ucha œrodkowego (przez lekarza specjaliste (taki ktory na specjalizacje)) lub Zapalenie p³uc (stwierdzone przez lekarza bez specjalizacji)
SELECT pok.nr_pokoju AS 'Nr pokoju'
FROM pokoje pok, lekarze l, wizyty w, choroby_wizyty cw, choroby c WHERE 
l.nr_pokoju = pok.nr_pokoju AND w.id_lekarza = l.id_lekarza AND
w.id_wizyty = cw.id_wizyty AND cw.id_choroby = c.id_choroby AND
((c.nazwa = 'Zapalenie ucha œrodkowego' AND l.id_lekarza IN (SELECT sc.id_lekarza FROM specjalizacje_lekarzy sc)) 
OR (c.nazwa = 'Zapalenie p³uc' AND l.id_lekarza NOT IN(SELECT sc.id_lekarza FROM specjalizacje_lekarzy sc)))