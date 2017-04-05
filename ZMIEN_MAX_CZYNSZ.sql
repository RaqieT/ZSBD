create trigger ZMIEN_MAX_CZYNSZ
on biuro..wynajecia
for insert
as 
	DECLARE @kwota float, @klient varchar(4), @kwota_klienta float;
	SELECT @kwota = i.czynsz, @klient = i.klientnr FROM inserted AS i;
	SELECT @kwota_klienta = k.max_czynsz FROM biuro..klienci AS k WHERE k.klientnr = @klient;
	
	IF (@kwota > @kwota_klienta)
		BEGIN
			UPDATE biuro..klienci
			SET max_czynsz = @kwota
			WHERE klientnr = @klient

			PRINT 'Zaktualizowano max_czynsz klienta';
		END