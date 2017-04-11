CREATE FUNCTION dbo.PROWIZJA(@data_od date, @data_do date, @id_pracownika varchar(4))
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
	WHERE n.personelNr = @id_pracownika 
	AND (w.od_kiedy BETWEEN @data_od AND @data_do);
	SELECT @wizyty = COUNT(*)
	FROM biuro..wizyty AS w
	INNER JOIN biuro..nieruchomosci 
	AS n ON n.nieruchomoscnr = w.nieruchomoscNr
	WHERE n.personelNr = @id_pracownika 
	AND (w.data_wizyty BETWEEN @data_od AND @data_do);
	SELECT @pensja = p.pensja 
	FROM biuro..personel 
	AS p WHERE p.personelNr = @id_pracownika
	RETURN ((@pensja * 0.02) * @wizyty) + ((@pensja * 0.1) * @wynajecia);
END;

