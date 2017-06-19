CREATE FUNCTION dbo.PRZYCHODY(@id_biura varchar(4))
RETURNS FLOAT
AS
BEGIN
	DECLARE @przychod float;

	SELECT @przychod = SUM(w.czynsz * (DATEDIFF(MONTH, w.od_kiedy, w.do_kiedy) + 1))
	FROM biuro..wynajecia AS w
	INNER JOIN biuro..nieruchomosci AS n ON n.nieruchomoscnr = w.nieruchomoscNr
	WHERE n.biuroNr = @id_biura
	GROUP BY n.biuroNr
	
	RETURN @przychod;
END

