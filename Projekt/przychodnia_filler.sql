USE przychodnia
GO

--pracownicy
INSERT INTO pracownicy(imie,nazwisko,placa) VALUES 
('Dawid','Rakieta',1400),--normalny
('Martinez','Lopez',1500),--normalny
('Karol','Balon',1200),--normalny
('Barbara','Wafel',3200),--alergolog
('Pawe³','Tergog',4600),--laryngolog,alergolog
('Micha³','Lambada',2000),--lekarz
('Karolina','Rodnik',7200)--kazda specjalizacja

--specjalizacje
--kazdy lekarz na start ma 2000 + bonusy odnosnie spec.
INSERT INTO specjalizacje(nazwa,bonus_do_placy) VALUES 
('Laryngolog',1400),
('Kardiolog',1500),
('Pediatra',1100),
('Alergolog',1200)

--pokoje
INSERT INTO pokoje(nr_pokoju,id_pracownika_zarzadzajacego) VALUES
(100,1),
(101,1),
(102,2),
(103,1),
(104,3),
(105,2),
(106,2),
(107,3),
(108,3)

--lekarze
INSERT INTO lekarze(id_pracownika,nr_pokoju) VALUES
(4,100),
(5,102),
(6,104),
(7,105)

--specjalizacje_lekarzy
INSERT INTO specjalizacje_lekarzy(id_lekarza,id_spec) VALUES
(1,4),
(2,1),
(2,4),
(4,1),
(4,2),
(4,3),
(4,4)

--pacjenci
INSERT INTO pacjenci(id_lekarza,imie,nazwisko,PESEL) VALUES
(1,'Danuta','Benger','55080803397'),
(2,'Kamila','Koñ','58040107122'),
(3,'Bartosz','Keke','20041813638'),
(3,'Ireneusz','Polipeus','80100809185'),
(1,'Eliasz','Nielodom','78022314045'),
(1,'Konrad','Bezele','01051711534')

--wizyty
INSERT INTO wizyty(id_pacjenta,id_lekarza,opis,data_wizyty) VALUES
(1,1,'Wykryto uczulenia na kilka zwierz¹t',2016/05/21),
(1,1,'Powstanie dodatkowego uczulenia',2016/06/20),
(2,1,'Brak jakichkolwiek uczuleñ',2016/07/01),
(2,2,'Nasilaj¹ce siê bóle ucha',2016/05/15),
(3,2,'Wykryto kilka alergii na roœliny i zwierzêta',2016/08/07),
(4,3,'Wysoka gor¹czka, dreszcze, kaszel, bóle g³owy',2016/09/29),
(5,4,'Bóle serca, nasilaj¹ce siê',2016/05/29),
(6,4,'Ostry ból gard³a',2016/12/12),
(4,4,'Wysoka gor¹czka, bóle g³owy',2017/01/04),
(1,4,'Pacjent symulowa³',2017/01/05)

--leki
INSERT INTO leki(nazwa_leku) VALUES
('Orefor'),
('SerceFixer'),
('AlergMinimizer'),
('AlergMoc'),
('Zwierzalerg'),
('Rivenal'),
('Augumantin'),
('Bakatar'),
('Nitroglicernix')

--choroby
INSERT INTO choroby(nazwa) VALUES
('Niedoczynnoœæ przestawki komory'),
('Alergia: koty'),
('Alergia: chomiki'),
('Alergia: króliki'),
('Alergia: zbo¿a'),
('Alergia: ró¿e'),
('Zapalenie gard³a'),
('Zapalenie ucha œrodkowego'),
('Zapalenie p³uc')

--leki_choroby
INSERT INTO leki_choroby(id_leku,id_choroby) VALUES
(1,7),
(2,1),
(3,2),
(3,3),
(3,4),
(3,5),
(3,6),
(4,2),
(4,3),
(4,4),
(4,5),
(5,2),
(5,3),
(5,4),
(6,8),
(7,7),
(7,8),
(7,9),
(8,7),
(9,1)

--choroby_wizyty
INSERT INTO choroby_wizyty(id_wizyty,id_choroby) VALUES
(1,2),
(1,3),
(2,4),
(4,8),
(5,2),
(5,3),
(5,5),
(5,6),
(6,9),
(7,1),
(8,7),
(9,9)
