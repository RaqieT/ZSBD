-- 01 --
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
	DECLARE @maxNumer int;
	SELECT @maxNumer = MAX(CAST(SUBSTRING(w.wlascicielnr, 3, 2) AS int)) 
	FROM biuro..wlasciciele AS w;
	INSERT INTO biuro..wlasciciele VALUES (('CO' + CAST((@maxNumer + 1) AS varchar)), @imie, @nazwisko, @adres, @telefon);

END

BEGIN
	EXEC DODAJWLASCICIELA 'aa', 'ss', 'dd', 'jj'
END

-- 02 --
-- funkcja zadeklarowana w pliku PRZYCHODY.sql
SELECT DISTINCT b.biuroNr, dbo.PRZYCHODY(b.biuroNr) AS przychod
FROM biuro..biura AS b
WHERE b.biuroNr = 'B007'

-- 03 --
-- wyzwalacz zadeklarowany w pliku ZMIENMAXCZYNSZ.sql
INSERT INTO biuro..wynajecia VALUES (1111, 'B16', 'CO16', 450, 'gotówka', 1000, 1, GETDATE(), GETDATE())

-- 04 --
-- wyzwalacz zadeklarowany w pliku DODAJREJESTRACJE.sql
INSERT INTO klienci VALUES ('CO99','aaaa','bbbb','26-300 Opoczno','0-85-333 2222','mieszkanie',400);

-- 05 --
-- funkcja zadeklarowana w pliku PROWIZJA.sql
SELECT p.personelNr, dbo.PROWIZJA('01-01-1980',GETDATE() , p.personelNr) AS prowizja
FROM biuro..personel AS p
WHERE p.personelNr = 'SB21'
-- 06 --

SELECT * FROM biuro..klienci
SELECT * FROM biuro..personel
SELECT * FROM biuro..rejestracje