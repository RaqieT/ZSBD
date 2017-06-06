--FUNKCJA
IF object_id(N'zwroc_date_urodzenia_z_PESELu', N'FN') IS NOT NULL
    DROP FUNCTION dbo.zwroc_date_urodzenia_z_PESELu
GO
CREATE FUNCTION dbo.zwroc_date_urodzenia_z_PESELu (@PESEL VARCHAR(20))  
RETURNS DATE 
AS
BEGIN
declare @dataurodzenia as DATE 
 
  set @dataurodzenia = (CONVERT(DATE,CONCAT(
CASE 
	WHEN SUBSTRING(@PESEL,1,2) <= SUBSTRING(CAST(DATEPART(YY,GETDATE()) AS VARCHAR(4)),3,2)
		THEN '20'
	ELSE '19'
END
,SUBSTRING(@PESEL,1,2),'-',SUBSTRING(@PESEL,3,2),'-',SUBSTRING(@PESEL,5,2))))
return @dataurodzenia
END
--TEST
GO
SELECT dbo.zwroc_date_urodzenia_z_PESELu(p.PESEL) AS 'Data ur.', p.PESEL FROM pacjenci p;


--PROCEDURY
--1
GO
CREATE OR ALTER PROCEDURE dodaj_lekarza 
	@imie VARCHAR(20), 
	@nazwisko VARCHAR(20), 
	@nrpokoju INT
AS 
	DECLARE @ID INT;
	INSERT INTO pracownicy(imie,nazwisko,placa) VALUES (@imie,@nazwisko,2000);
	SET @ID = (SELECT TOP 1 p.id_pracownika FROM pracownicy p ORDER BY p.id_pracownika DESC);
	IF (EXISTS(SELECT TOP 1 * FROM pokoje p WHERE p.nr_pokoju = @nrpokoju) AND 
		NOT EXISTS(SELECT TOP 1 * FROM lekarze l WHERE l.nr_pokoju = @nrpokoju))
		INSERT INTO lekarze(nr_pokoju,id_pracownika) VALUES (@nrpokoju,@ID);
	ELSE
		DELETE FROM pracownicy WHERE id_pracownika = @ID;
	SELECT * FROM pracownicy p
	INNER JOIN lekarze l ON l.id_pracownika = p.id_pracownika
GO
--TEST
EXEC dodaj_lekarza @imie = 'Dadeko', @nazwisko = 'Koreo', @nrpokoju = 101;

--2

GO
CREATE OR ALTER PROCEDURE dodaj_spec_lekarzowi_i_zwieksz_pensje
	@idLekarza INT, 
	@nazwaSpec VARCHAR(20)
AS 
	SELECT * FROM lekarze l
	INNER JOIN pracownicy p ON l.id_pracownika = p.id_pracownika
	INNER JOIN specjalizacje_lekarzy sl ON l.id_lekarza = sl.id_lekarza
	INNER JOIN specjalizacje s ON sl.id_spec = s.id_spec
	WHERE l.id_lekarza = @idLekarza;
	DECLARE @IDSPEC INT;
	DECLARE @idPracownika INT;
	DECLARE @bonus INT;
	SET @bonus = (SELECT TOP 1 bonus_do_placy FROM specjalizacje WHERE nazwa = @nazwaSpec);
	SET @IDSPEC = (SELECT TOP 1 id_spec FROM specjalizacje WHERE nazwa = @nazwaSpec);
	SET @idPracownika = (SELECT TOP 1 id_pracownika FROM lekarze WHERE id_lekarza = @idLekarza);
	IF (EXISTS(SELECT TOP 1 * FROM specjalizacje WHERE nazwa = @nazwaSpec) AND EXISTS(SELECT TOP 1 * FROM lekarze WHERE id_lekarza = @idLekarza))
	BEGIN
		INSERT INTO specjalizacje_lekarzy(id_lekarza, id_spec) VALUES (@idLekarza, @IDSPEC);
		UPDATE pracownicy SET placa = placa + @bonus WHERE id_pracownika = @idPracownika;
	END
	SELECT * FROM lekarze l
	INNER JOIN pracownicy p ON l.id_pracownika = p.id_pracownika
	INNER JOIN specjalizacje_lekarzy sl ON l.id_lekarza = sl.id_lekarza
	INNER JOIN specjalizacje s ON sl.id_spec = s.id_spec
	WHERE l.id_lekarza = @idLekarza;
GO
--TEST
EXEC dodaj_spec_lekarzowi_i_zwieksz_pensje @idLekarza = 1, @nazwaSpec = 'Laryngolog'

--3 a
GO
CREATE OR ALTER PROCEDURE usun_lekarza_pracownika_id
	@idLekarza INT
AS 
	DECLARE @idPracownika INT;
	SET @idPracownika = (SELECT TOP 1 l.id_pracownika FROM lekarze l 
		WHERE l.id_lekarza = @idLekarza)
	ALTER TABLE lekarze NOCHECK CONSTRAINT pracownik_lekarza_FK;
	ALTER TABLE specjalizacje_lekarzy NOCHECK CONSTRAINT ALL;
	ALTER TABLE wizyty NOCHECK CONSTRAINT ALL;
	ALTER TABLE pacjenci NOCHECK CONSTRAINT ALL;
	DELETE FROM lekarze WHERE id_lekarza = @idLekarza;
	DELETE FROM pracownicy WHERE id_pracownika = @idPracownika;
	DELETE FROM specjalizacje_lekarzy WHERE id_lekarza = @idLekarza;
		UPDATE pacjenci SET id_lekarza = (SELECT TOP 1 licznik.IDLEK FROM
				(SELECT COUNT(p.id_lekarza) AS value, p.id_lekarza AS IDLEK FROM pacjenci p GROUP BY p.id_lekarza) licznik ORDER BY value) 
	WHERE id_lekarza = @idLekarza;
	ALTER TABLE pacjenci CHECK CONSTRAINT ALL;
	ALTER TABLE pacjenci CHECK CONSTRAINT ALL;
	ALTER TABLE specjalizacje_lekarzy CHECK CONSTRAINT ALL;
	ALTER TABLE lekarze CHECK CONSTRAINT pracownik_lekarza_FK;
GO

--3 b
CREATE OR ALTER PROCEDURE usun_lekarza_pracownika_dane
	@imie VARCHAR(20),
	@nazwisko VARCHAR(20)
AS 
	DECLARE @idLekarza2 INT;
	
	IF ((SELECT COUNT(*) FROM pracownicy WHERE imie = @imie AND nazwisko = @nazwisko) = 1)
	BEGIN
		SET @idLekarza2 = (SELECT TOP 1 l.id_lekarza FROM lekarze l, pracownicy p 
		WHERE l.id_pracownika = p.id_pracownika AND p.imie = @imie AND p.nazwisko = @nazwisko);
		EXEC usun_lekarza_pracownika_id @idLekarza = @idLekarza2;
	END
	ELSE
		PRINT 'Istnieje co najmniej dwoch lekarzy o takim samym imieniu i nazwisku, usun poprzez usun_lekarza_pracownika_id';
	SELECT * FROM pracownicy;
GO

EXEC usun_lekarza_pracownika_dane @imie ='Barbara', @nazwisko = 'Wafel';
