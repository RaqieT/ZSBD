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
---procedura:
create procedure PIERWSZA @arg int
as
begin
print ('Wartoœæ parametru wynosi³a ' + cast(@arg as varchar));
end; 
go
---wywo³anie:
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
---wywo³anie
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
create procedure TRZECIA @id_dzialu int = 0, @procent int = 15
as
begin
declare @licznik int;
set @licznik = 0;

if (@id_dzialu <>0)
	begin
	select @licznik = count(*) from test_pracownicy..pracownicy where id_dzialu = @id_dzialu
	
	update test_pracownicy..pracownicy set placa += (placa *(@procent/100.0)) where id_dzialu = @id_dzialu;
	
	insert into test_pracownicy..dziennik values ('pracownicy', getdate(), @licznik, 'Wprowadzono podwyzke o ' + cast(@procent as varchar) + '%')
	end;
else
	
end;