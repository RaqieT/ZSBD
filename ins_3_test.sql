--- Slajd 1
declare @x int, @s varchar (10)

set @x=10
set @s='napis'

print @x+2
print @s
 
declare @imieP varchar(20), @nazwiskoP varchar(20)
select @imieP=imie, @nazwiskoP=nazwisko from biblioteka.dbo.pracownicy where id=7
print @imieP + ' ' + @nazwiskoP


--- Slajd 2
declare @imieP varchar(20), @nazwiskoP varchar(20)
select @imieP=imie, @nazwiskoP=nazwisko from biblioteka.dbo.pracownicy
print @imieP + ' ' + @nazwiskoP
 
declare @imieP varchar(20), @nazwiskoP varchar (20)
set @imieP='Teofil'
set @nazwiskoP='Szczerbaty'
select @imieP=imie, @nazwiskoP=nazwisko from biblioteka.dbo.pracownicy where id=1
print @imieP + ' ' + @nazwiskoP

declare @imieP varchar(20), @nazwiskoP varchar (20)
set @imieP='Teofil'
set @nazwiskoP='Szczerbaty'
select @imieP=imie, @nazwiskoP=nazwisko from biblioteka.dbo.pracownicy where id=20
print @imieP + ' ' + @nazwiskoP

--- Slajd 3
CREATE TABLE biblioteka.dbo.liczby (licz1 int, czas datetime default getdate());
GO

declare @x int
set @x=2
insert into biblioteka.dbo.liczby(licz1) values (@x);
waitfor delay '00:00:10'
insert into biblioteka.dbo.liczby(licz1) values (@x+2);
select * from biblioteka.dbo.liczby
--IF..ELSE
if EXISTS (select * from biblioteka.dbo.wypozyczenia) print ('By³y wypo¿yczenia')
else print ('Nie by³o ¿adnych wypo¿yczeñ')

--- Slajd 4
--WHILE
declare @y int
set @y=0
while ( @y<10 )
begin
	print @y
	if ( @y=5 ) break
	set @y=@y+1
end
--CASE
select tytul as tytulK, cena as cenaK, [cena jest]=CASE
	when cena<20.00 then 'Niska'
	when cena between 20.00 and 40.00 then 'Przystêpna'
	when cena>40.00 then 'Wysoka'
	else 'Nieznana'
	end
from biblioteka.dbo.ksiazki

--- Slajd 5
--NULLIF
select	count(*) as [Liczba ksiazek],
		avg(nullif( strony, 35)) as [Srednia stron NULL],
		avg(strony) as [Srednia stron],
		avg(cena) as [Srednia cena]
from biblioteka.dbo.ksiazki
--ISNULL
select sygn, id_cz, isnull(data_z, getdate())
from biblioteka.dbo.wypozyczenia

--- Slajd 6
--Komunikat o b³êdzie
raiserror (21000, 10, 1)
print @@error

raiserror (21000, 10, 1) with seterror
print @@error

raiserror (21000, 11, 1)
print @@error

raiserror ('Ala ma kota', 11, 1)
print @@error

--- Slajd 7
--DATA
declare @d1 datetime, @d2 datetime
set @d1='20091020'
set @d2='20091025'

select dateadd(hour, 112, @d1)
select dateadd(day, 112, @d1)

select datediff(minute, @d1, @d2)
select datediff(day, @d1, @d2)

select datename(month, @d1)
select datepart(month, @d1)

select cast(day(@d1) as varchar)+'-'+cast(month(@d1) as varchar)+'-'+cast(year(@d1) as varchar)
--


--- Slajd 8
select col_length('biblioteka.dbo.pracownicy', 'imie')
select datalength(2+3.4)
select db_id('master')
select db_name(1)
select user_id()
select user_name()
select host_id()
select host_name()
use biblioteka;
select object_id('Pracownicy')
select object_name(object_id('Pracownicy'))



--- Saljd 9
--1. Step
if exists(select 1 from master.dbo.sysdatabase where name = 'test_cwiczenia') drop database test_cwiczenia
GO
create database test_cwiczenia
GO
use test_cwiczenia
GO
create table test_cwiczenia.dbo.liczby (liczba int)
GO
declare @i int
set @i=1
while @i<100
begin
	insert test_cwiczenia.dbo.liczby values (@i)
	set @i = @i + 1
end
GO
select * from test_cwiczenia.dbo.liczby

--- Slajd 10
--2
use test_cwiczenia
GO
if exists(select 1 from sys.objects where TYPE = 'P' and name = 'proc_liczby') drop procedure proc_liczby
GO
create procedure proc_liczby @max int = 10
as
begin
	select liczba from test_cwiczenia.dbo.liczby
	where liczba<=@max
end
GO
exec test_cwiczenia.dbo.proc_liczby 3
exec test_cwiczenia.dbo.proc_liczby
GO

--- Slajd 11
--3
use test_cwiczenia
GO
if exists(select 1 from sys.objects where TYPE = 'P' and name = 'proc_statystyka') drop procedure proc_statystyka
GO
create procedure proc_statystyka @max int output, @min int output, @aux int output
as
begin
	set @max=(select max(liczba) from test_cwiczenia.dbo.liczby)
	set @min=(select min(liczba) from test_cwiczenia.dbo.liczby)
	set @aux=10
end
GO
declare @max int, @min int, @aux2 int
exec test_cwiczenia.dbo.proc_statystyka @max output, @min output, @aux=@aux2 output
select @max 'Max', @min 'Min', @aux2 'Aux'
GO


 
--1
use test_cwiczenia
--go
--drop function dbo.fn_srednia;
 GO
create function fn_srednia(@rodzaj int) returns int
begin
	return (select avg(cena) from biblioteka.dbo.ksiazki where id_wyd=@rodzaj)
end

select dbo.fn_srednia(3)
--2
drop function funkcja
create function funkcja(@max int) returns table
return (select * from test_cwiczenia.dbo.liczby where liczba<=@max)

select liczba from funkcja(3)
