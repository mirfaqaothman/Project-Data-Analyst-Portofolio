SELECT * FROM FLIGHT;

SELECT MEMBER_NO, COUNT(*) AS Count
FROM FLIGHT
GROUP BY MEMBER_NO
HAVING COUNT(*) >1;

alter Table FLIGHT 
modify Column GENDER ENUM ('Female', 'Male') NOT NULL;

select * from flight 
WHERE Gender is null or gender = '';

delete from flight 
where gender is null or trim(gender)='';

SET SQL_SAFE_UPDATES = 0;

select * from flight
where AGE IS NULL OR AGE =''
OR WORK_COUNTRY IS NULL OR WORK_COUNTRY = ''
OR BP_SUM IS NULL OR BP_SUM = ''
OR SUM_YR_1 IS NULL OR SUM_YR_1 = ''
OR SUM_YR_2 IS NULL OR SUM_YR_2 = ''
OR SEG_KM_SUM IS NULL OR SEG_KM_SUM =''
OR AVG_INTERVAL IS NULL OR AVG_INTERVAL =''
OR EXCHANGE_COUNT IS NULL OR EXCHANGE_COUNT =''
OR WORK_CITY IS NULL OR WORK_CITY =''
OR avg_discount IS NULL OR avg_discount ='';

Alter Table FLIGHT 
modify Column AGE INT NOT NULL;

SELECT * FROM FLIGHT;

# Menyamakan format penulisan date (sebelumnya beda-beda)
SELECT DISTINCT FIRST_FLIGHT_DATE FROM flight LIMIT 20;

UPDATE flight
SET FIRST_FLIGHT_DATE = CASE 
    WHEN FIRST_FLIGHT_DATE LIKE '%/%/%' THEN 
        CASE 
            WHEN SUBSTRING_INDEX(FIRST_FLIGHT_DATE, '/', 1) > 12 
            THEN STR_TO_DATE(FIRST_FLIGHT_DATE, '%d/%m/%Y') -- Jika formatnya DD/MM/YYYY
            ELSE STR_TO_DATE(FIRST_FLIGHT_DATE, '%m/%d/%Y') -- Jika formatnya MM/DD/YYYY
        END
    ELSE FIRST_FLIGHT_DATE
END;

select * from flight;
#Karena tipe data nyamasih text mau di ubah ke date
ALTER TABLE flight MODIFY FIRST_FLIGHT_DATE DATE;

UPDATE flight
SET FFP_DATE = CASE 
    WHEN FFP_DATE LIKE '%/%/%' THEN 
        CASE 
            WHEN SUBSTRING_INDEX(FFP_DATE, '/', 1) > 12 
            THEN STR_TO_DATE(FFP_DATE, '%d/%m/%Y') -- Jika formatnya DD/MM/YYYY
            ELSE STR_TO_DATE(FFP_DATE, '%m/%d/%Y') -- Jika formatnya MM/DD/YYYY
        END
    ELSE FFP_DATE
END;
ALTER TABLE flight MODIFY FFP_DATE DATE;

UPDATE flight
SET LOAD_TIME = CASE 
    WHEN LOAD_TIME LIKE '%/%/%' THEN 
        CASE 
            WHEN SUBSTRING_INDEX(LOAD_TIME, '/', 1) > 12 
            THEN STR_TO_DATE(LOAD_TIME, '%d/%m/%Y') -- Jika formatnya DD/MM/YYYY
            ELSE STR_TO_DATE(LOAD_TIME, '%m/%d/%Y') -- Jika formatnya MM/DD/YYYY
        END
    ELSE LOAD_TIME
END;

ALTER TABLE flight MODIFY LOAD_TIME DATE;


UPDATE flight
SET LAST_FLIGHT_DATE = 
    CASE 
        WHEN LAST_FLIGHT_DATE LIKE '%/%/%' THEN 
            CASE 
                WHEN SUBSTRING_INDEX(LAST_FLIGHT_DATE, '/', 1) > 12 
                THEN STR_TO_DATE(LAST_FLIGHT_DATE, '%d/%m/%Y') -- Format DD/MM/YYYY
                ELSE STR_TO_DATE(LAST_FLIGHT_DATE, '%m/%d/%Y') -- Format MM/DD/YYYY
            END
        ELSE LAST_FLIGHT_DATE -- Biarkan jika sudah dalam format YYYY-MM-DD
    END;

# ERROR KARENA ADA YANG 2014/2/29

DELETE FROM flight 
WHERE LAST_FLIGHT_DATE LIKE '%29/2%' OR LAST_FLIGHT_DATE LIKE '%2/29%';

ALTER TABLE flight MODIFY LAST_FLIGHT_DATE DATE;

SELECT * FROM FLIGHT;

# Mengecek penulisan di column WORK_COUNTRY, WORK_PROVINCE, WORK_CITY
SELECT DISTINCT WORK_COUNTRY FROM FLIGHT;
SELECT DISTINCT WORK_PROVINCE FROM FLIGHT;
SELECT DISTINCT WORK_CITY FROM FLIGHT;

# Menghapus spasi ekstra di awal dan akhir
UPDATE FLIGHT
SET WORK_COUNTRY = TRIM(WORK_COUNTRY),
    WORK_PROVINCE = TRIM(WORK_PROVINCE),
    WORK_CITY = TRIM(WORK_CITY);
# Mengubah ke Format Konsisten (Capitalization)
UPDATE FLIGHT
SET WORK_COUNTRY = UPPER(WORK_COUNTRY),
    WORK_PROVINCE = UPPER(WORK_PROVINCE),
    WORK_CITY = UPPER(WORK_CITY);
# Menghapus Karakter Tidak diinginkan
UPDATE FLIGHT
SET WORK_COUNTRY = REGEXP_REPLACE(WORK_COUNTRY, '[^a-zA-Z ]', ''),
    WORK_PROVINCE = REGEXP_REPLACE(WORK_PROVINCE, '[^a-zA-Z ]', ''),
    WORK_CITY = REGEXP_REPLACE(WORK_CITY, '[^a-zA-Z ]', '');
SELECT DISTINCT WORK_COUNTRY FROM FLIGHT ORDER BY WORK_COUNTRY;
SELECT DISTINCT WORK_PROVINCE FROM FLIGHT ORDER BY WORK_PROVINCE;
SELECT DISTINCT WORK_CITY FROM FLIGHT ORDER BY WORK_CITY;

select * from flight;

##### ANALISIS

#1. Loyalitas Pelanggan

select member_no, -- lama seseorang menjadi member
	Datediff(load_time , FFP_DATE) AS Loyalty_days
From Flight; 

Alter Table flight add column Loyalty_Days INT not null;

Update flight
SET Loyalty_days = Datediff(load_time , FFP_DATE);

select member_no, Loyalty_days
from flight;

SELECT MEMBER_NO, 
       Flight_Count,
       CASE 
           WHEN Flight_Count >= 50 THEN 'Frequent Flyer'
           WHEN Flight_Count BETWEEN 10 AND 49 THEN 'Moderate Flyer'
           ELSE 'Rare Flyer'
       END AS Flight_Category
FROM flight;
# Membuat Coumn baru untuk kategori frekuensi flight
Alter Table flight add column Flight_Category varchar(100) not null;
Update flight
SET Flight_Category = 
	CASE
           WHEN Flight_Count >= 50 THEN 'Frequent Flyer'
           WHEN Flight_Count BETWEEN 10 AND 49 THEN 'Moderate Flyer'
           ELSE 'Rare Flyer'
       END;
select  Flight_Category FROM FLIGHT;

#2. Analisis Asal Pelanggan (Negara/Provinsi/Kota)
-- Jumlah Pelanggan Per Negara, Provinsi, Kota
SELECT WORK_COUNTRY, COUNT(*) AS total_customers
FROM flight
GROUP BY WORK_COUNTRY
ORDER BY total_customers DESC;

select * from flight;

#3. Pengeluaran Tahunan
SELECT MEMBER_NO, SUM_YR_1, SUM_YR_2, 
       (SUM_YR_1 + SUM_YR_2) AS total_spent
FROM flight
ORDER BY total_spent DESC;

alter table flight add column total_spent_member int;
update flight
set total_spent_member =  (SUM_YR_1 + SUM_YR_2);

select total_spent_member from flight;


-- hubungan Tier Keanggotaan dengan Pengeluaran 
SELECT FFP_TIER, AVG(SUM_YR_1 + SUM_YR_2) AS avg_spending
FROM flight
GROUP BY FFP_TIER
ORDER BY avg_spending DESC;

select * from flight;

SELECT * 
FROM flight
ORDER BY SUM_YR_1 DESC
LIMIT 10;

## 2. Analisis Geografis Pelanggan
# Melihat Provinsi dengan Jumlah Penerbangan Tertinggi

select work_province, count(*) AS Num_Members, Sum(flight_count) AS Total_Flight
From flight
group by work_province
order by total_flight;

# Negara dengan julah penerbagan tertinggi
SELECT WORK_COUNTRY, COUNT(*) AS num_members, SUM(FLIGHT_COUNT) AS total_flights
FROM flight
GROUP BY WORK_COUNTRY
ORDER BY total_flights DESC;


## 3. Analisis Pengeluaran dan Diskon

# Rata-rata diskon yang diterima pelanggan
SELECT AVG(avg_discount) AS avg_discount_rate
FROM flight;

#Hubungan tingkat keanggotaan dengan pengeluaran
SELECT FFP_TIER, AVG(SUM_YR_1) AS avg_spending_year1, AVG(SUM_YR_2) AS avg_spending_year2
FROM flight
GROUP BY FFP_TIER
ORDER BY FFP_TIER DESC;

#Hubungan tingkat keanggotaan dengan Pengeluaran

SELECT FFP_TIER, AVG(SUM_YR_1) AS avg_spending_year1, AVG(SUM_YR_2) AS avg_spending_year2
FROM flight
GROUP BY FFP_TIER
ORDER BY FFP_TIER DESC;

## 4. Analisis Profitabilitas dan Pengeluaran

# Pelanggan dengan pendapatan pertinggi

SELECT MEMBER_NO, SUM_YR_1, SUM_YR_2, (SUM_YR_1 + SUM_YR_2) AS total_spent
FROM flight
ORDER BY total_spent DESC
LIMIT 10;

# Pengaruh Diskon terhadap pengeluaran
SELECT avg_discount, AVG(SUM_YR_1 + SUM_YR_2) AS avg_spending
FROM flight
GROUP BY avg_discount
ORDER BY avg_discount DESC;

# Tren Pengeluaran baru vs lama

SELECT *
FROM flight
WHERE FIRST_FLIGHT_DATE = (SELECT MIN(FIRST_FLIGHT_DATE) FROM flight);

SELECT CASE
         WHEN FIRST_FLIGHT_DATE > '2010-01-01' THEN 'New Customer'
         ELSE 'Old Customer'
       END AS customer_type,
       AVG(SUM_YR_1 + SUM_YR_2) AS avg_spending
FROM flight
GROUP BY customer_type;

## Analisis Retensi Pelanggan
SELECT AVG(LAST_TO_END) AS avg_days_since_last_flight
FROM flight;

# Jumlah pelanggan yang belum terbang dalam waktu lama

SELECT COUNT(*) AS inactive_customers
FROM flight
WHERE LAST_TO_END > 200; --  lebih dari 200 hari

#rata-rata jarak tempuh penerbagan perpelanggan
SELECT MEMBER_NO, (SEG_KM_SUM / FLIGHT_COUNT) AS avg_km_per_flight
FROM flight
WHERE FLIGHT_COUNT > 0
ORDER BY avg_km_per_flight DESC;

#Customer dengan diskon lebih tinggi lebih sering terbang?
SELECT CASE
         WHEN avg_discount < 0.1 THEN 'Low Discount'
         WHEN avg_discount BETWEEN 0.1 AND 0.3 THEN 'Medium Discount'
         ELSE 'High Discount'
       END AS discount_segment,
       AVG(FLIGHT_COUNT) AS avg_flights
FROM flight
GROUP BY discount_segment;

# Tingkat tier anggota berpengaruh terhadap frekuensi terbang?
SELECT FFP_TIER, AVG(FLIGHT_COUNT) AS avg_flights
FROM flight
GROUP BY FFP_TIER
ORDER BY FFP_TIER DESC;

# Rata-rata interval waktu antar penerbangan pelanggan

SELECT AVG(AVG_INTERVAL) AS avg_flight_interval, 
       MAX(MAX_INTERVAL) AS longest_interval
FROM flight;










