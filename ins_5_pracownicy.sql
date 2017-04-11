--1
create table test_pracownicy..dziennik(tabela varchar(15), data date, l_wierszy int, komunikat varchar(300));

--2
begin
declare @licznik int, @premia int;
set @licznik = 0;
set @premia = 500;
declare kursor cursor for select nr_akt from test_pracownicy..pracownicy where nr_akt in (select distinct kierownik from test_pracownicy..pracownicy);
declare @id_prac int;
open kursor;
fetch next from kursor into @id_prac;
while @@FETCH_STATUS = 0
	begin
	update test_pracownicy..pracownicy set dod_funkcyjny += @premia where nr_akt = @id_prac;
	set @licznik += 1;
	fetch next from kursor into @id_prac;
	end;
close kursor;
deallocate kursor;
insert into test_pracownicy..dziennik values ('pracownicy', getdate(), @licznik, 'Wproadzono dodatek funkcyjny w wysokoœci: ' + cast(@licznik as varchar));
end;

--3
begin 
declare @licznik2 int, @rok int;
set @rok = 1986; 
set @licznik2 = (select count(nr_akt) from test_pracownicy..pracownicy where DATEPART(year, data_zatr) = @rok);
if (@licznik2 > 0)
	insert into test_pracownicy..dziennik values ('', getdate(), 0, 'W ' + cast(@rok as varchar) + 'roku zatrudniono ' + cast(@licznik2 as varchar) + ' pracowników');
else
	insert into test_pracownicy..dziennik values ('', getdate(), 0, 'W ' + cast(@rok as varchar) + 'roku nikogo nie zatrudniono');
end;

--4
begin
declare @ile_lat int;
set @ile_lat = (select DATEDIFF(year, data_zatr, getdate()) from test_pracownicy..pracownicy where nr_akt = 8902)
if (@ile_lat > 15)
	insert into test_pracownicy..dziennik values ('', getdate(), 0, 'Pracownik 8902 pracuje d³u¿ej ni¿ 15 lat');
else
	insert into test_pracownicy..dziennik values ('', getdate(), 0, 'Pracownik 8902 pracuje krócej ni¿ 15 lat');
end;

--5
if exists (select 1 from sys.objects where type = 'P' and name = 'PIERWSZA')
drop procedure PIERWSZA;
go
---procedura
create procedure PIERWSZA @arg int
as
begin
print ('Wartoœæ parametru wynosi³a ' + cast(@arg as varchar));
end; 
go
---uzycie
begin
exec PIERWSZA 24;
end;

--6
if exists (select 1 from sys.objects where type = 'P' and name = 'DRUGA')
drop procedure DRUGA;
go
---procedura
create procedure DRUGA @arg1 varchar(255) = NULL, @arg2 varchar(255) output, @arg3 int = 1
as
begin
declare @lokalna varchar(20);
set @lokalna = 'DRUGA';
set @arg2 = (@lokalna + @arg1 + cast(@arg3 as varchar));
end; 
go
---uzycie
begin
declare @wynik varchar(255);
exec DRUGA ' zmienna wejsciowa ', @wynik output, 2;
print @wynik;
end;

--7
if exists (select 1 from sys.objects where type = 'P' and name = 'TRZECIA')
drop procedure TRZECIA;
go
---procedura
create procedure trzecia @id_dzialu int = 0, @procent int = 15
as
begin
declare @licznik int;
set @licznik = 0;

if (@id_dzialu <>0)
	begin
	select @licznik = count(*) from test_pracownicy..pracownicy where id_dzialu = @id_dzialu
	
	update test_pracownicy..pracownicy set placa += (placa *(@procent/100.0)) where id_dzialu = @id_dzialu;
	
	insert into test_pracownicy..dziennik values ('pracownicy', getdate(), @licznik, 'wprowadzono podwyzke o ' + cast(@procent as varchar) + '%')
	end;
end;
--8
go
--tworzenie funkcji
create function dbo.wyliczUdzial(@id_dzialu int)
returns float
as
begin
	declare @udzial float, @wszystkie_koszta float, @koszta_dzialu float;
	set @wszystkie_koszta = 0;
	set @koszta_dzialu = 0;

	select @koszta_dzialu = (sum(p.placa) + sum(p.dod_funkcyjny))
	from test_pracownicy..pracownicy as p
	where p.id_dzialu = @id_dzialu;

	select @wszystkie_koszta = (sum(p.placa) + sum(p.dod_funkcyjny))
	from test_pracownicy..pracownicy as p;

	set @udzial = (@koszta_dzialu / @wszystkie_koszta) * 100;

	return @udzial;
end

go

--wykorzystanie
select distinct p.id_dzialu, dbo.wyliczUdzial(p.id_dzialu) as udzial_w_budzecie
from test_pracownicy..pracownicy as p
where p.id_dzialu = 10;

--9
USE test_pracownicy
GO
create trigger dbo.archiwizuj
on test_pracownicy..pracownicy
for delete
as
	declare @nr_pracownika int;
	set @nr_pracownika = (select d.nr_akt from deleted as d);
	IF @nr_pracownika IS NULL
		begin
			return
		end;
	insert into test_pracownicy..prac_archiw select * from deleted as d

	update test_pracownicy..prac_archiw
	set data_zwol = getdate()
	where nr_akt = @nr_pracownika

	insert into test_pracownicy..dziennik
	values ('pracownicy', getdate(), 1, 'zwolniono pracownika o numerze  ' + cast(@nr_pracownika as varchar));

GO

delete from test_pracownicy..pracownicy
where nr_akt = 9731;