CREATE TRIGGER DODAJREJESTRACJE
ON biuro..klienci
FOR INSERT
AS
	DECLARE @nr_klienta varchar(4), @biuro varchar(4), @personel varchar(4)
	SET @personel = 'SB20'
	SELECT @nr_klienta = i.klientnr FROM inserted AS i
	SELECT @biuro = p.biuroNr FROM biuro..personel AS p WHERE p.personelNr = @personel

	INSERT INTO biuro..rejestracje
	VALUES (@nr_klienta, @biuro, @personel, GETDATE());