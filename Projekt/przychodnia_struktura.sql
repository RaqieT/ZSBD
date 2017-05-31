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
placa INT
);

GO

CREATE TABLE przychodnia..specjalizacje (
id_spec INT IDENTITY(1,1) CONSTRAINT spec_PK PRIMARY KEY,
nazwa VARCHAR(20) NOT NULL,
bonus_do_placy INT
);

GO

CREATE TABLE przychodnia..lekarze (
id_lekarza INT IDENTITY(1,1) CONSTRAINT lekarz_PK PRIMARY KEY,
id_pracownika INT,
CONSTRAINT pracownik_lekarza_FK FOREIGN KEY(id_pracownika) REFERENCES przychodnia..pracownicy(id_pracownika)
);

GO

CREATE TABLE przychodnia..specjalizacje_lekarzy (
id_spec INT,
id_lekarza INT,
CONSTRAINT lek_spec_FK FOREIGN KEY(id_lekarza) REFERENCES przychodnia..lekarze(id_lekarza),
CONSTRAINT spec_lek_FK FOREIGN KEY(id_spec) REFERENCES przychodnia..specjalizacje(id_spec)
);

GO

CREATE TABLE przychodnia..pacjenci (
id_pacjenta INT IDENTITY(1,1) CONSTRAINT pacjent_PK PRIMARY KEY,
id_lekarza INT,
imie VARCHAR(20) NOT NULL,
nazwisko VARCHAR(20) NOT NULL,
PESEL VARCHAR(11),
CONSTRAINT pac_PESEL_check CHECK (PESEL LIKE '%[0-9]%'),
CONSTRAINT pil_druzyny_FK FOREIGN KEY(id_lekarza) REFERENCES przychodnia..lekarze(id_lekarza)
); 

GO

CREATE TABLE przychodnia..wizyta (
id_wizyty INT IDENTITY(1,1) CONSTRAINT wizytka_PK PRIMARY KEY,
id_pacjenta INT,
id_lekarza INT,
opis VARCHAR(500),
data_wizyty datetime,
CONSTRAINT lek_wizyty_FK FOREIGN KEY(id_lekarza) REFERENCES przychodnia..lekarze(id_lekarza),
CONSTRAINT pacjent_wizyty_FK FOREIGN KEY(id_pacjenta) REFERENCES przychodnia..pacjenci(id_pacjenta)
);