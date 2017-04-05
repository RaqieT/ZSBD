create function dbo.PRZYCHODY (@id_biura varchar(4))
returns float
as 
begin
	declare @przychod float;

	select @przychod = sum(w.czynsz * (datediff(month, w.od_kiedy, w.do_kiedy) + 1)) from biuro..wynajecia as w
	inner join biuro..nieruchomosci as n on n.nieruchomoscnr = w.nieruchomoscNr
	where n.biuroNr = @id_biura
	group by n.biuroNr

	return @przychod;
end;