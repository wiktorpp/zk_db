-- Drop the view and tables if they exist
DROP VIEW IF EXISTS Produkty_Widok;
DROP VIEW IF EXISTS Sprzedaze_Widok;
DROP TABLE IF EXISTS Produkty;
DROP TABLE IF EXISTS Sprzedaze;
DROP TABLE IF EXISTS Dostawy;

CREATE TABLE Dostawy (
    id SERIAL PRIMARY KEY,
    data DATE,
    godzina TIME,
    dostawca VARCHAR(50)
);

CREATE TABLE Sprzedaze (
    id SERIAL PRIMARY KEY,
    data DATE,
    godzina TIME,
    rabat DECIMAL(10, 2),
    id_klienta VARCHAR(20)
);

CREATE TABLE Produkty (
    id SERIAL PRIMARY KEY,
    waga DECIMAL(10, 2),
    cena_na_metce DECIMAL(10, 2),
    deskryminator INT,
    opis VARCHAR(100),
    rodzaj INT,
    cena_zakupu DECIMAL(10, 2) NULL,
    dostawa INT,
    sprzedaz INT,
    lokalizacja INT,
    FOREIGN KEY (dostawa) REFERENCES Dostawy(id),
    FOREIGN KEY (sprzedaz) REFERENCES Sprzedaze(id)
);

-- Create the view
CREATE VIEW Produkty_Widok AS
SELECT 
    p.id AS produkt_id,
    CONCAT(p.waga, ';', p.cena_na_metce, p.deskryminator) AS kod,
    p.waga,
    p.cena_na_metce,
    p.deskryminator,
    p.opis,
    p.rodzaj,
    p.cena_zakupu,
    p.dostawa,
    d.data AS data_dostawy,
    d.godzina AS godzina_dostawy,
    d.dostawca,
    p.sprzedaz,
    s.data AS data_sprzedarzy,
    s.godzina AS godzina_sprzedarzy,
    s.rabat,
    p.lokalizacja
FROM 
    Produkty p
LEFT JOIN 
    Dostawy d ON p.dostawa = d.id
LEFT JOIN 
    Sprzedaze s ON p.sprzedaz = s.id;

CREATE VIEW Sprzedaze_Widok AS
SELECT 
    s.id AS sprzedaz_id,
    s.data AS data_sprzedazy,
    s.godzina AS godzina_sprzedazy,
    s.klient_id,
    SUM(p.cena_na_metce) AS suma_cen_na_metce,
    SUM(p.cena_na_metce) - COALESCE(s.rabat, 0) AS suma_cen_po_rabacie,
    SUM(p.cena_zakupu) AS suma_cen_zakupu
FROM 
    Sprzedaze s
JOIN 
    Produkty p ON s.id = p.sprzedaz
GROUP BY 
    s.id, s.data, s.godzina, s.klient_id;
