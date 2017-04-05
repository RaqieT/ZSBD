--1
if exists (select 1 from sys.objects where type = 'P' and name = 'DODAJ_WLASCICIELA')
	drop procedure DODAJ_WLASCICIELA;
go
create procedure DODAJ_WLASCICIELA @imie varchar(20), @nazwisko varchar(30), @adres varchar(30), @telefon varchar(9)
as
begin
	declare @max_nr int;
	select @max_nr = max(cast(substring(wlascicielnr, 3, 2) as int)) from biuro..wlasciciele;
	insert into biuro..wlasciciele values (('CO' + cast((@max_nr+1) as varchar)), @imie, @nazwisko, @adres, @telefon);
end;
go
begin
exec DODAJ_WLASCICIELA 'Karolina', 'Pryk', 'Adresik', '123456789';
end;

--2
-- funkcja zadeklarowana w pliku PRZYCHODY.sql
select distinct b.biuroNr,dbo.PRZYCHODY(b.biuroNr) AS przychod
FROM biuro..biura AS b
WHERE b.biuroNr = 'B004'

--3
-- wyzwalacz zadeklarowany w pliku ZMIEN_MAX_CZYNSZ.sql
INSERT INTO biuro..wynajecia VALUES (1111, 'B16', 'CO16', 450, 'gotówka', 1000, 1, GETDATE(), GETDATE())