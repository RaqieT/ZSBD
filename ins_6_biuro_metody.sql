--1
IF EXISTS (SELECT 1 FROM sys.objects WHERE TYPE = 'P' AND name = 'DODAJWLASCICIELA')
DROP PROCEDURE DODAJWLASCICIELA;
GO

CREATE PROCEDURE DODAJWLASCICIELA
@imie		varchar(25),
@nazwisko	varchar(25),
@adres		varchar(45),
@telefon	varchar(15)
AS
BEGIN
	DECLARE @maks int;
	SELECT @maks = MAX(CAST(SUBSTRING(w.wlascicielnr, 3, 2) AS int)) 
	FROM biuro..wlasciciele AS w;
	INSERT INTO biuro..wlasciciele VALUES (('CO' + CAST((@maks + 1) AS varchar)), @imie, @nazwisko, @adres, @telefon);

END

GO

BEGIN
	EXEC DODAJWLASCICIELA 'Dawid', 'Radczyc', 'Nowa 5', '696696696'
END

GO

SELECT * FROM biuro..wlasciciele

--2
IF OBJECT_ID('dbo.PRZYCHODY') IS NOT NULL
  DROP FUNCTION dbo.PRZYCHODY
GO --METODA
CREATE FUNCTION dbo.PRZYCHODY(@idBiura varchar(4))
RETURNS FLOAT
AS
BEGIN
	DECLARE @przychod float;

	SELECT @przychod = SUM(w.czynsz * (DATEDIFF(MONTH, w.od_kiedy, w.do_kiedy) + 1))
	FROM biuro..wynajecia AS w
	INNER JOIN biuro..nieruchomosci AS n ON n.nieruchomoscnr = w.nieruchomoscNr
	WHERE n.biuroNr = @idBiura
	GROUP BY n.biuroNr
	
	RETURN @przychod;
END
GO --WYWOLANIE
SELECT DISTINCT b.biuroNr, dbo.PRZYCHODY(b.biuroNr) AS przychod
FROM biuro..biura AS b
WHERE b.biuroNr = 'B003'

--3
IF OBJECT_ID('dbo.ZMIENMAXCZYNSZ') IS NOT NULL
  DROP TRIGGER ZMIENMAXCZYNSZ
GO
USE biuro
GO
CREATE TRIGGER ZMIENMAXCZYNSZ
ON biuro..wynajecia
FOR INSERT
AS
	DECLARE @kwota float, @klient varchar(4), @kwotaKlient float;
	SELECT @kwota = i.czynsz, @klient = i.klientnr 
	FROM inserted AS i;
	SELECT @kwotaKlient = k.max_czynsz 
	FROM biuro..klienci
	AS k WHERE k.klientnr = @klient;
	IF (@kwota > @kwotaKlient)
		BEGIN
			UPDATE biuro..klienci
			SET max_czynsz = @kwota
			WHERE klientnr = @klient
			PRINT 'Zaktualizowano max_czynsz klienta';
		END
INSERT INTO biuro..wynajecia VALUES (1111, 'B21', 'CO17', 2000, 'czek', 4000, 1, GETDATE(), GETDATE())

--4
GO
USE biuro
GO
IF OBJECT_ID('dbo.DODAJREJESTRACJE') IS NOT NULL
  DROP TRIGGER DODAJREJESTRACJE
GO
CREATE TRIGGER DODAJREJESTRACJE
ON biuro..klienci
FOR INSERT
AS
	DECLARE @nrKlient varchar(4), @biuro varchar(4), @personel varchar(4)
	SELECT @personel = p.personelNr FROM biuro..personel AS p WHERE p.personelNr = (SELECT TOP 1 personelNr FROM biuro..personel ORDER BY NEWID())
	SELECT @nrKlient = i.klientnr FROM inserted AS i
	SELECT @biuro = p.biuroNr FROM biuro..personel AS p WHERE p.personelNr = @personel

	INSERT INTO biuro..rejestracje
	VALUES (@nrKlient, @biuro, @personel, GETDATE());
GO
INSERT INTO klienci VALUES ('CO05','Dawid','Babla','95-200 Pabianice','69696996','mieszkanie',320);

--5
IF OBJECT_ID('dbo.PROWIZJA') IS NOT NULL
  DROP FUNCTION dbo.PROWIZJA
GO --METODA
CREATE FUNCTION dbo.PROWIZJA(@dataPoczatkowa date, @dataKoncowa date, @idPracownika varchar(4))
RETURNS float
AS
BEGIN
	DECLARE @wynajecia int, @wizyty int, @pensja float;
	SET @wynajecia = 0;
	SET @wizyty = 0;
	SELECT @wynajecia = COUNT(*)
	FROM biuro..wynajecia AS w
	INNER JOIN biuro..nieruchomosci 
	AS n ON n.nieruchomoscnr = w.nieruchomoscNr
	WHERE n.personelNr = @idPracownika 
	AND (w.od_kiedy BETWEEN @dataPoczatkowa AND @dataKoncowa);
	SELECT @wizyty = COUNT(*)
	FROM biuro..wizyty AS w
	INNER JOIN biuro..nieruchomosci 
	AS n ON n.nieruchomoscnr = w.nieruchomoscNr
	WHERE n.personelNr = @idPracownika 
	AND (w.data_wizyty BETWEEN @dataPoczatkowa AND @dataKoncowa);
	SELECT @pensja = p.pensja 
	FROM biuro..personel 
	AS p WHERE p.personelNr = @idPracownika
	RETURN ((@pensja * 0.02) * @wizyty) + ((@pensja * 0.1) * @wynajecia);
END;
GO --WYWOLANIE
SELECT p.personelNr, dbo.PROWIZJA('01-01-1980',GETDATE() , p.personelNr) AS prowizja
FROM biuro..personel AS p
WHERE p.personelNr = 'SB21'
--6
SELECT * FROM biuro..klienci
SELECT * FROM biuro..personel
SELECT * FROM biuro..rejestracje