--1
print 'Czesc, to ja'
--2
DECLARE @zmienna int
set @zmienna = 5
print 'Zmienna jest rowna ' + CAST(@zmienna as varchar)
--3
if @zmienna = 5 
begin
	print 'Zmienna jest rowna 5'
end
else
begin
	print 'Zmienna nie jest rowna 5'
end
--4
set @zmienna = 1
while @zmienna != 5
begin 
print 'zmienna jest rowna ' + cast(@zmienna as varchar)
set @zmienna = @zmienna + 1
end
--5

set @zmienna = 3
while @zmienna != 8
begin
print CASE @zmienna 
WHEN 3 THEN 'poczatek'
WHEN 5 THEN 'srodek'
WHEN 7 THEN  'koniec'
end
set @zmienna = @zmienna +1 ;
end

--6
use test_cwiczenia
Create table oddzialy ( nr_odd int , nazwa_odd varchar(30))
--7 
INSERT INTO oddzialy VALUES(1,'KSIEGOWOSC');
declare @var int;
set @var=1;
declare @tempquery varchar(30);
SELECT @tempquery = nazwa_odd from oddzialy where nr_odd = @var;
print 'Nazwa oddzialu to: ' +  @tempquery;

--8
DECLARE @I INT
DECLARE @n varchar(30)
declare kur SCROLL cursor for 
select nr_odd,nazwa_odd from oddzialy ORDER BY nr_odd
OPEN kur;
FETCH NEXT FROM kur INTO @I, @n;
WHILE @@FETCH_STATUS=0
	BEGIN
    PRINT 'numer oddzialu ' + cast(@I as varchar) + ' nazwa oddzialu ' + @n;
    FETCH NEXT FROM kur INTO @I, @n;
    END
CLOSE kur   
DEALLOCATE kur

--9
Insert into oddzialy Values ( 2, 'sprzatanie')
Insert into oddzialy values ( 3, 'malowanie')
declare @x int
declare @counter int
set @counter = 0;
declare kur SCROLL cursor for 
select nr_odd from oddzialy ORDER BY nr_odd
OPEN kur;
FETCH NEXT FROM kur INTO @x;
WHILE @@FETCH_STATUS=0
	BEGIN
     if @x > 2 
		begin
		DELETE FROM oddzialy where nr_odd = @x;
		set @counter= @counter + 1;
		END
    FETCH NEXT FROM kur INTO @x;
    END
print 'usuniete oddzialy ' + cast(@counter as varchar(2))
CLOSE kur   
DEALLOCATE kur

--10
declare @d int
declare @bylemWIfie int
set @bylemWIfie = 0
declare kur SCROLL cursor for 
select nr_odd from oddzialy ORDER BY nr_odd
OPEN kur;
FETCH NEXT FROM kur INTO @d;
WHILE @@FETCH_STATUS=0
	BEGIN
		if @d = 3
			begin
				Update oddzialy set nazwa_odd = 'jakis tam' where nr_odd = @d
				set @bylemWIfie = 1
			END
	
    FETCH NEXT FROM kur INTO @d;
    END
CLOSE kur   
DEALLOCATE kur
IF @bylemWIfie = 0
BEGIN
	INSERT INTO oddzialy VALUES (3, 'Nie bylo 3');
END
