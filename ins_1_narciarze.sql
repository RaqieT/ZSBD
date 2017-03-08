use narciarze

--1
SELECT * from kraje
SELECT * from skocznie
SELECT * from trenerzy
SELECT * from zawodnicy
SELECT * from zawody
SELECT * from uczestnictwa_w_zawodach

--2
SELECT DISTINCT k.kraj from zawodnicy as z, kraje as k WHERE z.id_kraju=k.id_kraju AND z.id_skoczka IS NOT NULL

--3
SELECT k.kraj, COUNT (z.id_skoczka) as Liczba  from zawodnicy as z, kraje as k WHERE z.id_kraju=k.id_kraju GROUP BY k.kraj

--4
SELECT z.nazwisko from zawodnicy as z, uczestnictwa_w_zawodach as u WHERE u.id_skoczka=z.id_skoczka AND u.id_zawodow IS NULL GROUP BY z.nazwisko

--5
SELECT z.nazwisko, COUNT (u.id_zawodow) as ile from zawodnicy as z, uczestnictwa_w_zawodach as u WHERE u.id_skoczka=z.id_skoczka GROUP BY z.nazwisko

--6
SELECT z.nazwisko, s.nazwa from zawodnicy as z, skocznie as s, uczestnictwa_w_zawodach as u, zawody as zd 
WHERE z.id_skoczka=u.id_skoczka AND u.id_zawodow=zd.id_zawodow AND zd.id_skoczni=s.id_skoczni
GROUP BY z.nazwisko, s.nazwa

--7
SELECT z.nazwisko, (YEAR(GETDATE()) - YEAR(z.data_ur)) as wiek from zawodnicy as z ORDER BY wiek DESC

--8
SELECT z.nazwisko, (YEAR(min(zd.DATA)) - YEAR(z.data_ur)) as ile_lat from zawodnicy as z, zawody as zd, uczestnictwa_w_zawodach as u  
WHERE z.id_skoczka=u.id_skoczka AND u.id_zawodow=zd.id_zawodow
GROUP BY z.nazwisko, z.data_ur ORDER BY z.nazwisko

--9
SELECT s.nazwa, (s.sedz-s.k) as odl from skocznie as s ORDER BY odl DESC

--10
SELECT TOP 1 s.nazwa, s.k from skocznie as s, zawody as zd WHERE s.id_skoczni=zd.id_skoczni AND zd.id_zawodow IS NOT NULL ORDER BY s.k DESC

--11
SELECT k.kraj from kraje as k, skocznie as s, zawody as zd WHERE k.id_kraju=s.id_kraju AND s.id_skoczni=zd.id_skoczni GROUP BY k.kraj

--12
SELECT z.nazwisko, k.kraj, COUNT(s.id_skoczni) as ile from zawodnicy as z, kraje as k, skocznie as s, zawody as zd WHERE z.id_kraju=k.id_kraju AND z.id_kraju=s.id_kraju AND s.id_skoczni=zd.id_skoczni GROUP BY z.nazwisko, k.kraj

--13
INSERT INTO trenerzy(id_kraju,imie_t,nazwisko_t,data_ur_t) 
VALUES (7,'Corby','Fisher', '1975-07-20')

--14
ALTER TABLE zawodnicy ADD trener int

--15
UPDATE zawodnicy SET trener=id_trenera FROM trenerzy WHERE trenerzy.id_kraju = zawodnicy.id_kraju;

--16
ALTER TABLE zawodnicy
ADD FOREIGN KEY (trener)
REFERENCES trenerzy(id_trenera)

--17

UPDATE trenerzy SET data_ur_t=
DATEADD(year,-5, (SELECT MIN(data_ur) FROM zawodnicy z1 WHERE z1.trener = t1.id_trenera)) 
FROM trenerzy t1 WHERE data_ur_t is null