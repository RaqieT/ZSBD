if exists(select 1 from master.dbo.sysdatabases where name = 'przychodnia')
BEGIN
	USE master
	drop database przychodnia 
END
GO
CREATE DATABASE przychodnia
GO
USE przychodnia
GO

CREATE TABLE przychodnia..pracownicy (
id_pracownika INT IDENTITY(1,1) CONSTRAINT pracownik_PK PRIMARY KEY,
imie VARCHAR(20) NOT NULL,
nazwisko VARCHAR(20) NOT NULL,
placa INT NOT NULL
);

GO

CREATE TABLE przychodnia..specjalizacje (
id_spec INT IDENTITY(1,1) CONSTRAINT spec_PK PRIMARY KEY,
nazwa VARCHAR(20) NOT NULL,
bonus_do_placy INT NOT NULL
);

GO

CREATE TABLE przychodnia..pokoje (
nr_pokoju INT IDENTITY(1,1) CONSTRAINT pokoj_PK PRIMARY KEY,
id_pracownika_zarzadzajacego INT NOT NULL,
CONSTRAINT id_pracownika_zarzadzajacego_FK FOREIGN KEY(id_pracownika_zarzadzajacego) REFERENCES przychodnia..pracownicy(id_pracownika)
);
GO

CREATE TABLE przychodnia..lekarze (
id_lekarza INT IDENTITY(1,1) CONSTRAINT lekarz_PK PRIMARY KEY,
id_pracownika INT NOT NULL,
nr_pokoju INT NOT NULL,
CONSTRAINT pracownik_lekarza_FK FOREIGN KEY(id_pracownika) REFERENCES przychodnia..pracownicy(id_pracownika),
CONSTRAINT nr_pokoju_lekarza_FK FOREIGN KEY(nr_pokoju) REFERENCES przychodnia..pokoje(nr_pokoju)
);

GO

CREATE TABLE przychodnia..specjalizacje_lekarzy (
id_spec INT NOT NULL,
id_lekarza INT NOT NULL,
CONSTRAINT lek_spec_FK FOREIGN KEY(id_lekarza) REFERENCES przychodnia..lekarze(id_lekarza),
CONSTRAINT spec_lek_FK FOREIGN KEY(id_spec) REFERENCES przychodnia..specjalizacje(id_spec)
);

GO

CREATE TABLE przychodnia..pacjenci (
id_pacjenta INT IDENTITY(1,1) CONSTRAINT pacjent_PK PRIMARY KEY,
id_lekarza INT NOT NULL,
imie VARCHAR(20) NOT NULL,
nazwisko VARCHAR(20) NOT NULL,
PESEL VARCHAR(11),
CONSTRAINT PESEL_pacjenta_FK CHECK (PESEL LIKE '%[0-9]%'),
CONSTRAINT lekarz_pacjenta_FK FOREIGN KEY(id_lekarza) REFERENCES przychodnia..lekarze(id_lekarza)
); 
GO

CREATE TABLE przychodnia..wizyty (
id_wizyty INT IDENTITY(1,1) CONSTRAINT wizyta_PK PRIMARY KEY,
id_pacjenta INT NOT NULL,
id_lekarza INT NOT NULL,
nr_pokoju INT NOT NULL,
opis VARCHAR(500),
data_wizyty datetime,
CONSTRAINT lek_wizyty_FK FOREIGN KEY(id_lekarza) REFERENCES przychodnia..lekarze(id_lekarza),
CONSTRAINT pacjent_wizyty_FK FOREIGN KEY(id_pacjenta) REFERENCES przychodnia..pacjenci(id_pacjenta),
CONSTRAINT nr_pokoju_wizyty_FK FOREIGN KEY(nr_pokoju) REFERENCES przychodnia..pokoje(nr_pokoju)
);

GO

CREATE TABLE przychodnia..leki (
id_leku INT IDENTITY(1,1) CONSTRAINT lek_PK PRIMARY KEY,
nazwa_leku VARCHAR(32)
);

GO

CREATE TABLE przychodnia..choroby (
id_choroby INT IDENTITY(1,1) CONSTRAINT choroba_PK PRIMARY KEY,
nazwa VARCHAR(32)
);

GO

CREATE TABLE przychodnia..leki_choroby (
id_leku INT NOT NULL,
id_choroby INT NOT NULL,
CONSTRAINT lek_choroby_FK FOREIGN KEY(id_leku) REFERENCES przychodnia..leki(id_leku),
CONSTRAINT choroba_leku_FK FOREIGN KEY(id_choroby) REFERENCES przychodnia..choroby(id_choroby)
);
GO

CREATE TABLE przychodnia..choroby_wizyty (
id_wizyty INT NOT NULL,
id_choroby INT NOT NULL,
CONSTRAINT wizyta_choroby_FK FOREIGN KEY(id_wizyty) REFERENCES przychodnia..wizyty(id_wizyty),
CONSTRAINT choroba_wiizyty_FK FOREIGN KEY(id_choroby) REFERENCES przychodnia..choroby(id_choroby)
);