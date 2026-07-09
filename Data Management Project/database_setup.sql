CREATE TABLE Customer (
    cust_id VARCHAR(10) PRIMARY KEY,
    cust_firstname VARCHAR(20),
    cust_lastname VARCHAR(10),
    cust_address VARCHAR(100),
    cust_phone VARCHAR(15),
    cust_email VARCHAR(30),
    constraint chk_email check (REGEXP_LIKE(cust_email,'^[a-zA-Z]\w+@(\S+)$'))
);


CREATE TABLE Booking (
    book_id VARCHAR(10) PRIMARY KEY,
    book_date DATE,
    book_method VARCHAR(10),
    book_status VARCHAR(10),
    cust_id VARCHAR(10),
    CONSTRAINT fk_book_cust FOREIGN KEY (cust_id) REFERENCES Customer(cust_id)
);


CREATE TABLE Training_Type (
    train_type VARCHAR(40) PRIMARY KEY,
    train_fee NUMBER(6,2)
);


CREATE TABLE Trainer (
    trainer_id VARCHAR(10) PRIMARY KEY,
    trainer_firstname VARCHAR(20),
    trainer_lastname VARCHAR(10),
    trainer_phone VARCHAR(15),
    trainer_work_experience NUMBER(2)
);


CREATE TABLE Training (
    train_id VARCHAR(10) PRIMARY KEY,
    train_type VARCHAR(40),
    train_date DATE,
    book_id  VARCHAR(10),
    trainer_id  VARCHAR(10),
    CONSTRAINT fk_train_traintype FOREIGN KEY (train_type) REFERENCES Training_Type(train_type),
    CONSTRAINT fk_train_book FOREIGN KEY (book_id) REFERENCES Booking(book_id),
    CONSTRAINT fk_train_trainer FOREIGN KEY (trainer_id) REFERENCES Trainer(trainer_id)
);


CREATE TABLE Adoption (
    adopt_id  VARCHAR(10)PRIMARY KEY,
    adopt_date DATE,
    delivery_fee NUMBER(4,2),
    adopt_fee NUMBER(6,2),
    adopt_status VARCHAR(10),
    appli_id  VARCHAR(10),
    cust_id  VARCHAR(10),
    payment_id  VARCHAR(10)
);


CREATE TABLE Application (
    appli_id  VARCHAR(10)PRIMARY KEY,
    appli_status VARCHAR(10),
    cust_id  VARCHAR(10),
    CONSTRAINT fk_app_cust FOREIGN KEY (cust_id) REFERENCES Customer(cust_id)
);


CREATE TABLE Consultation (
    consul_id  VARCHAR(10)PRIMARY KEY,
    consul_date DATE,
    counsellor_firstname VARCHAR(20),
    counsellor_lastname VARCHAR(10),
    counsellor_phone VARCHAR(15),
    appli_id VARCHAR(10),
    CONSTRAINT fk_consul_app FOREIGN KEY (appli_id) REFERENCES Application(appli_id)
);


CREATE TABLE Medical_Type (
    medic_type VARCHAR(30) PRIMARY KEY,
    medic_fee NUMBER(6,2)
);


CREATE TABLE Location (
    location_id VARCHAR(10) PRIMARY KEY,
    location_state VARCHAR(15)
);


CREATE TABLE Shelter (
    shelter_id VARCHAR(10) PRIMARY KEY,
    shelter_name VARCHAR(30),  
    shelter_address VARCHAR(100),
    location_id VARCHAR(10),
    CONSTRAINT fk_shelter_location FOREIGN KEY (location_id) REFERENCES Location(location_id)
);


CREATE TABLE Donor (
    donor_id VARCHAR(10) PRIMARY KEY,
    donor_firstname VARCHAR(20),
    donor_lastname VARCHAR(10),
    donor_phone VARCHAR(15),
    donor_address VARCHAR(100),
    cust_id VARCHAR(10),
    CONSTRAINT fk_donor_cust FOREIGN KEY (cust_id) REFERENCES Customer(cust_id)
);


CREATE TABLE Donation (
    donate_id VARCHAR(10) PRIMARY KEY,
    donate_amount NUMBER(10,2),
    donate_date DATE,
    donor_id VARCHAR(10),
    shelter_id VARCHAR(10),
    CONSTRAINT fk_donate_donor FOREIGN KEY (donor_id) REFERENCES Donor(donor_id),
    CONSTRAINT fk_donate_shelter FOREIGN KEY (shelter_id) REFERENCES Shelter(shelter_id)
);


CREATE TABLE Payment (
    payment_id  VARCHAR(10)PRIMARY KEY,
    payment_method VARCHAR(20),
    payment_date DATE,
    payment_amount NUMBER(7,2),
    promotion_id  VARCHAR(10),
    cust_id  VARCHAR(10),
    train_id  VARCHAR(10)
);


CREATE TABLE Animal (
    anm_id VARCHAR(10)PRIMARY KEY,
    anm_name VARCHAR(25),
    anm_year_born NUMBER(4),
    anm_breeds VARCHAR(30),
    anm_gender CHAR,
    shelter_id VARCHAR(10),
    adopt_id VARCHAR(10),
    CONSTRAINT fk_anm_shelter FOREIGN KEY (shelter_id) REFERENCES Shelter(shelter_id),
    CONSTRAINT fk_anm_adopt FOREIGN KEY (adopt_id) REFERENCES Adoption(adopt_id),
    constraint chk_gender check (UPPER(anm_gender) in ('M','F'))
);


CREATE TABLE Medical_Exam (
    medic_id VARCHAR(10) PRIMARY KEY,
    medic_date DATE,
    medic_type VARCHAR(30),
    anm_id VARCHAR(10),
    CONSTRAINT fk_mdc_exam_mdc_type FOREIGN KEY (medic_type) REFERENCES Medical_Type(medic_type),
    CONSTRAINT fk_mdc_exam_anm FOREIGN KEY (anm_id) REFERENCES Animal(anm_id)
);


CREATE TABLE Promotion (
    promotion_id VARCHAR(10) PRIMARY KEY,
    promotion_status VARCHAR(10),
    cust_id VARCHAR(10),
    adopt_id VARCHAR(10),
    CONSTRAINT fk_promo_cust FOREIGN KEY (cust_id) REFERENCES Customer(cust_id),
    CONSTRAINT fk_promo_adopt FOREIGN KEY (adopt_id) REFERENCES Adoption(adopt_id)
);


ALTER TABLE adoption
ADD CONSTRAINT fk_adopt_app FOREIGN KEY (appli_id) REFERENCES Application(appli_id);


ALTER TABLE adoption
ADD CONSTRAINT fk_adopt_cust FOREIGN KEY (cust_id) REFERENCES Customer(cust_id);


ALTER TABLE adoption
ADD CONSTRAINT fk_adopt_payment FOREIGN KEY (payment_id) REFERENCES Payment(payment_id);


ALTER TABLE payment
ADD CONSTRAINT fk_payment_promotion FOREIGN KEY (promotion_id) REFERENCES Promotion(promotion_id);


ALTER TABLE payment
ADD CONSTRAINT fk_payment_cust FOREIGN KEY (cust_id) REFERENCES Customer(cust_id);


ALTER TABLE payment
ADD CONSTRAINT fk_payment_training FOREIGN KEY (train_id) REFERENCES Training(train_id);

view1:
SET LINESIZE 120
SET PAGESIZE 60

COLUMN shelter_name FORMAT A25
COLUMN donor_firstname FORMAT A20
COLUMN donor_lastname FORMAT A20
COLUMN month FORMAT A10
COLUMN total_donations FORMAT $999999.99
BREAK ON shelter_name

CREATE VIEW Shelter_Donation_Report AS
SELECT 
    s.shelter_name AS Shelter_Name,
    d.donor_firstname AS Donor_First_Name,
    d.donor_lastname AS Donor_Last_Name,
    TO_CHAR(dn.donate_date, 'YYYY-MM') AS Month,
    SUM(dn.donate_amount) AS Total_Donations
FROM 
    Shelter s
JOIN 
    Donation dn ON s.shelter_id = dn.shelter_id
JOIN 
    Donor d ON dn.donor_id = d.donor_id
GROUP BY 
    s.shelter_name, 
    d.donor_firstname, 
    d.donor_lastname, 
    TO_CHAR(dn.donate_date, 'YYYY-MM')
ORDER BY 
    Month;

view2:
SET LINESIZE 120
SET PAGESIZE 60

COLUMN cust_firstname FORMAT A20
COLUMN cust_lastname FORMAT A20
COLUMN adopt_status FORMAT A15
COLUMN avg_delivery_fee FORMAT $99999.99
BREAK ON cust_firstname

CREATE VIEW Customer_Delivery_Fee_Report AS
SELECT 
    c.cust_firstname AS Customer_FirstName,
    c.cust_lastname AS Customer_LastName,
    ad.adopt_status AS Adoption_Status,
    AVG(ad.delivery_fee) AS Avg_Delivery_Fee
FROM 
    Customer c
JOIN 
    Adoption ad ON c.cust_id = ad.cust_id
JOIN 
    Application ap ON ad.appli_id = ap.appli_id
GROUP BY 
    c.cust_firstname, 
    c.cust_lastname, 
    ad.adopt_status
ORDER BY 
    Avg_Delivery_Fee DESC;

view3:
SET LINESIZE 120
SET PAGESIZE 60

COLUMN medic_type FORMAT A25
COLUMN total_treatments FORMAT 9999
COLUMN total_animals FORMAT 9999

BREAK ON medic_type

CREATE VIEW Medical_Treatments_Report AS
SELECT 
    mt.medic_type AS Medical_Type,
    COUNT(me.medic_id) AS Total_Treatments,
    COUNT(DISTINCT a.anm_id) AS Total_Animals
FROM 
    Medical_Type mt
JOIN 
    Medical_Exam me ON mt.medic_type = me.medic_type
JOIN 
    Animal a ON me.anm_id = a.anm_id
JOIN 
    Adoption ad ON a.adopt_id = ad.adopt_id
GROUP BY 
    mt.medic_type
ORDER BY 
    Total_Treatments DESC;

view4:
SET LINESIZE 120
SET PAGESIZE 60

COLUMN donor_id FORMAT A15
COLUMN donor_firstname FORMAT A20
COLUMN donor_lastname FORMAT A20
COLUMN shelter_name FORMAT A30
COLUMN donate_amount FORMAT $999,999.99

BREAK ON donor_id

CREATE VIEW Donations_Report AS
SELECT 
    d.donor_id AS Donor_ID,
    d.donor_firstname AS Donor_FirstName,
    d.donor_lastname AS Donor_LastName,
    s.shelter_name AS Shelter_Name,
    SUM(do.donate_amount) AS Total_Donate_Amount
FROM 
    Donor d
JOIN 
    Donation do ON d.donor_id = do.donor_id
JOIN 
    Shelter s ON do.shelter_id = s.shelter_id
GROUP BY 
    d.donor_id, 
    d.donor_firstname, 
    d.donor_lastname, 
    s.shelter_name
ORDER BY 
    d.donor_id;


Task5:
insert into Customer (cust_id, cust_firstname, cust_lastname, cust_address, cust_phone, cust_email) values ('CT001', 'Adelind', 'Extill', '80963 Norway Maple Lane', '8652362362', 'aextill0@mayoclinic.com');
insert into Customer (cust_id, cust_firstname, cust_lastname, cust_address, cust_phone, cust_email) values ('CT002', 'Kimmy', 'Pengilley', '972 Texas Point', '5477594264', 'kpengilley1@techcrunch.com');
insert into Customer (cust_id, cust_firstname, cust_lastname, cust_address, cust_phone, cust_email) values ('CT003', 'Livvy', 'Benedtti', '23 Banding Alley', '2986358470', 'lbenedtti2@hibu.com');
insert into Customer (cust_id, cust_firstname, cust_lastname, cust_address, cust_phone, cust_email) values ('CT004', 'Ranice', 'Clemonts', '99 Twin Pines Hill', '5293790510', 'rclemonts3@hud.gov');
insert into Customer (cust_id, cust_firstname, cust_lastname, cust_address, cust_phone, cust_email) values ('CT005', 'Gnni', 'Deboick', '21845 Pierstorff Road', '5325256023', 'gdeboick4@studiopress.com');
insert into Customer (cust_id, cust_firstname, cust_lastname, cust_address, cust_phone, cust_email) values ('CT006', 'Charissa', 'Ealden', '63 Dunning Junction', '9318192990', 'cealden5@barnesandnoble.com');
insert into Customer (cust_id, cust_firstname, cust_lastname, cust_address, cust_phone, cust_email) values ('CT007', 'Wakefield', 'Alejandri', '9 Arapahoe Court', '4218464470', 'walejandri6@tiny.cc');
insert into Customer (cust_id, cust_firstname, cust_lastname, cust_address, cust_phone, cust_email) values ('CT008', 'Corny', 'Fendley', '1389 Brentwood Avenue', '2978973412', 'cfendley7@washington.edu');
insert into Customer (cust_id, cust_firstname, cust_lastname, cust_address, cust_phone, cust_email) values ('CT009', 'Brand', 'Hrinchenko', '88076 Hayes Avenue', '8662355499', 'bhrinchenko8@51.la');
insert into Customer (cust_id, cust_firstname, cust_lastname, cust_address, cust_phone, cust_email) values ('CT010', 'Valida', 'Caccavari', '14963 Spenser Terrace', '8921418231', 'vcaccavari9@naver.com');
insert into Customer (cust_id, cust_firstname, cust_lastname, cust_address, cust_phone, cust_email) values ('CT011', 'Chrystal', 'Fontell', '6127 Merchant Junction', '4929148422', 'cfontella@merriam-webster.com');
insert into Customer (cust_id, cust_firstname, cust_lastname, cust_address, cust_phone, cust_email) values ('CT012', 'Madelle', 'Marqyes', '3 Graceland Circle', '9236542809', 'mmarqyesb@ucoz.com');
insert into Customer (cust_id, cust_firstname, cust_lastname, cust_address, cust_phone, cust_email) values ('CT013', 'Harmony', 'Jerosch', '34388 Troy Crossing', '1827201507', 'hjeroschc@alibaba.com');
insert into Customer (cust_id, cust_firstname, cust_lastname, cust_address, cust_phone, cust_email) values ('CT014', 'Gretna', 'Rosettini', '004 Longview Park', '3983213234', 'grosettinid@yolasite.com');
insert into Customer (cust_id, cust_firstname, cust_lastname, cust_address, cust_phone, cust_email) values ('CT015', 'Anastasia', 'Oppy', '3 Tennyson Center', '3319031262', 'aoppye@omniture.com');
insert into Customer (cust_id, cust_firstname, cust_lastname, cust_address, cust_phone, cust_email) values ('CT016', 'Carlen', 'Pilley', '630 Thackeray Street', '5792918521', 'cpilleyf@wikia.com');
insert into Customer (cust_id, cust_firstname, cust_lastname, cust_address, cust_phone, cust_email) values ('CT017', 'Allen', 'Filisov', '387 Union Alley', '3445579969', 'afilisovg@bbb.org');
insert into Customer (cust_id, cust_firstname, cust_lastname, cust_address, cust_phone, cust_email) values ('CT018', 'Dede', 'Guilbert', '17546 Lindbergh Point', '4995353416', 'dguilberth@latimes.com');
insert into Customer (cust_id, cust_firstname, cust_lastname, cust_address, cust_phone, cust_email) values ('CT019', 'Mirabelle', 'Dugue', '69 Butternut Road', '3245801996', 'mduguei@ycombinator.com');
insert into Customer (cust_id, cust_firstname, cust_lastname, cust_address, cust_phone, cust_email) values ('CT020', 'Athena', 'Simpkins', '32792 Grover Trail', '5226968871', 'asimpkinsj@sohu.com');
insert into Customer (cust_id, cust_firstname, cust_lastname, cust_address, cust_phone, cust_email) values ('CT021', 'Denna', 'Eyles', '0139 Monument Crossing', '8832664639', 'deylesk@merriam-webster.com');
insert into Customer (cust_id, cust_firstname, cust_lastname, cust_address, cust_phone, cust_email) values ('CT022', 'Nickolaus', 'Gaymar', '2 Fair Oaks Drive', '6427055081', 'ngaymarl@china.com.cn');
insert into Customer (cust_id, cust_firstname, cust_lastname, cust_address, cust_phone, cust_email) values ('CT023', 'Corly', 'Mathiot', '11 Little Fleur Avenue', '8706229432', 'cmathiotm@trellian.com');
insert into Customer (cust_id, cust_firstname, cust_lastname, cust_address, cust_phone, cust_email) values ('CT024', 'Camilla', 'Garrard', '6546 Dryden Road', '9906816910', 'cgarrardn@senate.gov');
insert into Customer (cust_id, cust_firstname, cust_lastname, cust_address, cust_phone, cust_email) values ('CT025', 'Phedra', 'Scud', '1617 Pankratz Terrace', '1693834957', 'pscudo@godaddy.com');
insert into Customer (cust_id, cust_firstname, cust_lastname, cust_address, cust_phone, cust_email) values ('CT026', 'Jannel', 'Caghy', '5785 Golden Leaf Junction', '3775620391', 'jcaghyp@yelp.com');
insert into Customer (cust_id, cust_firstname, cust_lastname, cust_address, cust_phone, cust_email) values ('CT027', 'Padraic', 'Paterson', '4334 Doe Crossing Trail', '5018480959', 'ppatersonq@opensource.org');
insert into Customer (cust_id, cust_firstname, cust_lastname, cust_address, cust_phone, cust_email) values ('CT028', 'Tiler', 'Brosetti', '11826 Northland Pass', '1693499485', 'tbrosettir@miitbeian.gov.cn');
insert into Customer (cust_id, cust_firstname, cust_lastname, cust_address, cust_phone, cust_email) values ('CT029', 'Yard', 'Axon', '26 Judy Parkway', '1025645364', 'yaxons@ask.com');
insert into Customer (cust_id, cust_firstname, cust_lastname, cust_address, cust_phone, cust_email) values ('CT030', 'Annora', 'Kirwin', '94367 Beilfuss Alley', '5452060498', 'akirwint@spiegel.de');
insert into Customer (cust_id, cust_firstname, cust_lastname, cust_address, cust_phone, cust_email) values ('CT031', 'Cristen', 'Kliement', '61791 Hudson Hill', '3468828467', 'ckliementu@yahoo.com');
insert into Customer (cust_id, cust_firstname, cust_lastname, cust_address, cust_phone, cust_email) values ('CT032', 'Jerrie', 'Salmon', '7 Ridgeview Circle', '7815172937', 'jsalmonv@nifty.com');
insert into Customer (cust_id, cust_firstname, cust_lastname, cust_address, cust_phone, cust_email) values ('CT033', 'Georas', 'Redbourn', '512 Armistice Terrace', '3298334871', 'gredbournw@dailymotion.com');
insert into Customer (cust_id, cust_firstname, cust_lastname, cust_address, cust_phone, cust_email) values ('CT034', 'Marcille', 'Lockett', '8529 Oakridge Terrace', '3065905827', 'mlockettx@wikimedia.org');
insert into Customer (cust_id, cust_firstname, cust_lastname, cust_address, cust_phone, cust_email) values ('CT035', 'Raffarty', 'Burrage', '00 Meadow Ridge Hill', '5368852530', 'rburragey@state.tx.us');
insert into Customer (cust_id, cust_firstname, cust_lastname, cust_address, cust_phone, cust_email) values ('CT036', 'Madlin', 'Dabel', '844 Summit Parkway', '3792320651', 'mdabelz@archive.org');
insert into Customer (cust_id, cust_firstname, cust_lastname, cust_address, cust_phone, cust_email) values ('CT037', 'Diena', 'McLaggan', '3 Eastwood Court', '7318805283', 'dmclaggan10@cam.ac.uk');
insert into Customer (cust_id, cust_firstname, cust_lastname, cust_address, cust_phone, cust_email) values ('CT038', 'Sula', 'Trevan', '187 Farragut Trail', '8665255338', 'strevan11@desdev.cn');
insert into Customer (cust_id, cust_firstname, cust_lastname, cust_address, cust_phone, cust_email) values ('CT039', 'Anna', 'Bingley', '4 Browning Avenue', '1937347800', 'abingley12@patch.com');
insert into Customer (cust_id, cust_firstname, cust_lastname, cust_address, cust_phone, cust_email) values ('CT040', 'Sergio', 'Streeter', '6 Shoshone Parkway', '9125461181', 'sstreeter13@devhub.com');
insert into Customer (cust_id, cust_firstname, cust_lastname, cust_address, cust_phone, cust_email) values ('CT041', 'Agretha', 'Knotton', '546 Spohn Park', '8969093403', 'aknotton14@washington.edu');
insert into Customer (cust_id, cust_firstname, cust_lastname, cust_address, cust_phone, cust_email) values ('CT042', 'Nady', 'Jeanon', '0 Eastlawn Point', '6562793925', 'njeanon15@twitpic.com');
insert into Customer (cust_id, cust_firstname, cust_lastname, cust_address, cust_phone, cust_email) values ('CT043', 'Harmonie', 'Gladhill', '879 North Alley', '8561717660', 'hgladhill16@biblegateway.com');
insert into Customer (cust_id, cust_firstname, cust_lastname, cust_address, cust_phone, cust_email) values ('CT044', 'Merrie', 'Relfe', '4681 Kipling Plaza', '4308027718', 'mrelfe17@chron.com');
insert into Customer (cust_id, cust_firstname, cust_lastname, cust_address, cust_phone, cust_email) values ('CT045', 'Gillian', 'Gammett', '3571 Lyons Road', '2644326656', 'ggammett18@pcworld.com');
insert into Customer (cust_id, cust_firstname, cust_lastname, cust_address, cust_phone, cust_email) values ('CT046', 'Ava', 'Jost', '112 Dapin Road', '4307154239', 'ajost19@tripod.com');
insert into Customer (cust_id, cust_firstname, cust_lastname, cust_address, cust_phone, cust_email) values ('CT047', 'Bent', 'Undy', '361 Loftsgordon Crossing', '1863946889', 'bundy1a@infoseek.co.jp');
insert into Customer (cust_id, cust_firstname, cust_lastname, cust_address, cust_phone, cust_email) values ('CT048', 'Chloette', 'Calendar', '40902 Sugar Park', '3455049017', 'ccalendar1b@google.com.br');
insert into Customer (cust_id, cust_firstname, cust_lastname, cust_address, cust_phone, cust_email) values ('CT049', 'Ginelle', 'Nabarro', '62088 Forster Terrace', '3321932356', 'gnabarro1c@toplist.cz');
insert into Customer (cust_id, cust_firstname, cust_lastname, cust_address, cust_phone, cust_email) values ('CT050', 'Gayel', 'Burnhard', '29 Vahlen Crossing', '9209299712', 'gburnhard1d@abc.net.au');


insert into Booking (book_id, book_date, book_method, book_status, cust_id) values ('BK001', '01-Sep-2023', 'Physical', 'Rejected', 'CT003');
insert into Booking (book_id, book_date, book_method, book_status, cust_id) values ('BK002', '16-Sep-2023', 'Online', 'Approved', 'CT007');
insert into Booking (book_id, book_date, book_method, book_status, cust_id) values ('BK003', '04-Jun-2023', 'Physical', 'Rejected', 'CT012');
insert into Booking (book_id, book_date, book_method, book_status, cust_id) values ('BK004', '03-Sep-2023', 'Online', 'Approved', 'CT018');
insert into Booking (book_id, book_date, book_method, book_status, cust_id) values ('BK005', '15-Jun-2023', 'Physical', 'Rejected', 'CT023');
insert into Booking (book_id, book_date, book_method, book_status, cust_id) values ('BK006', '13-Nov-2023', 'Online', 'Approved', 'CT045');
insert into Booking (book_id, book_date, book_method, book_status, cust_id) values ('BK007', '09-Aug-2023', 'Physical', 'Pending', 'CT004');
insert into Booking (book_id, book_date, book_method, book_status, cust_id) values ('BK008', '16-Mar-2023', 'Online', 'Approved', 'CT017');
insert into Booking (book_id, book_date, book_method, book_status, cust_id) values ('BK009', '12-May-2023', 'Physical', 'Approved', 'CT008');
insert into Booking (book_id, book_date, book_method, book_status, cust_id) values ('BK010', '06-Nov-2023', 'Online', 'Approved', 'CT030');
insert into Booking (book_id, book_date, book_method, book_status, cust_id) values ('BK011', '18-Feb-2023', 'Physical', 'Approved', 'CT002');
insert into Booking (book_id, book_date, book_method, book_status, cust_id) values ('BK012', '09-Nov-2023', 'Online', 'Approved', 'CT039');
insert into Booking (book_id, book_date, book_method, book_status, cust_id) values ('BK013', '07-Apr-2023', 'Physical', 'Approved', 'CT022');
insert into Booking (book_id, book_date, book_method, book_status, cust_id) values ('BK014', '16-Nov-2023', 'Online', 'Approved', 'CT028');
insert into Booking (book_id, book_date, book_method, book_status, cust_id) values ('BK015', '18-Aug-2023', 'Physical', 'Approved', 'CT014');
insert into Booking (book_id, book_date, book_method, book_status, cust_id) values ('BK016', '08-Nov-2023', 'Online', 'Rejected', 'CT046');
insert into Booking (book_id, book_date, book_method, book_status, cust_id) values ('BK017', '30-Dec-2023', 'Physical', 'Rejected', 'CT011');
insert into Booking (book_id, book_date, book_method, book_status, cust_id) values ('BK018', '11-Sep-2023', 'Online', 'Approved', 'CT015');
insert into Booking (book_id, book_date, book_method, book_status, cust_id) values ('BK019', '23-Nov-2023', 'Physical', 'Approved', 'CT021');
insert into Booking (book_id, book_date, book_method, book_status, cust_id) values ('BK020', '30-Dec-2023', 'Online', 'Approved', 'CT050');
insert into Booking (book_id, book_date, book_method, book_status, cust_id) values ('BK021', '03-Jun-2023', 'Physical', 'Approved', 'CT034');
insert into Booking (book_id, book_date, book_method, book_status, cust_id) values ('BK022', '30-Jan-2023', 'Online', 'Approved', 'CT005');
insert into Booking (book_id, book_date, book_method, book_status, cust_id) values ('BK023', '25-Oct-2023', 'Physical', 'Approved', 'CT043');
insert into Booking (book_id, book_date, book_method, book_status, cust_id) values ('BK024', '23-Jan-2023', 'Online', 'Rejected', 'CT006');
insert into Booking (book_id, book_date, book_method, book_status, cust_id) values ('BK025', '01-May-2023', 'Physical', 'Rejected', 'CT013');
insert into Booking (book_id, book_date, book_method, book_status, cust_id) values ('BK026', '31-May-2023', 'Online', 'Approved', 'CT025');
insert into Booking (book_id, book_date, book_method, book_status, cust_id) values ('BK027', '03-Jan-2023', 'Physical', 'Approved', 'CT036');
insert into Booking (book_id, book_date, book_method, book_status, cust_id) values ('BK028', '27-May-2023', 'Online', 'Approved', 'CT031');
insert into Booking (book_id, book_date, book_method, book_status, cust_id) values ('BK029', '02-Feb-2023', 'Physical', 'Approved', 'CT009');
insert into Booking (book_id, book_date, book_method, book_status, cust_id) values ('BK030', '18-Mar-2023', 'Online', 'Pending', 'CT048');
insert into Booking (book_id, book_date, book_method, book_status, cust_id) values ('BK031', '28-Mar-2023', 'Physical', 'Approved', 'CT027');
insert into Booking (book_id, book_date, book_method, book_status, cust_id) values ('BK032', '25-Jul-2023', 'Online', 'Approved', 'CT038');
insert into Booking (book_id, book_date, book_method, book_status, cust_id) values ('BK033', '05-Jul-2023', 'Physical', 'Approved', 'CT041');
insert into Booking (book_id, book_date, book_method, book_status, cust_id) values ('BK034', '13-Jul-2023', 'Online', 'Approved', 'CT010');
insert into Booking (book_id, book_date, book_method, book_status, cust_id) values ('BK035', '17-Jun-2023', 'Physical', 'Approved', 'CT033');
insert into Booking (book_id, book_date, book_method, book_status, cust_id) values ('BK036', '19-Feb-2023', 'Online', 'Approved', 'CT020');
insert into Booking (book_id, book_date, book_method, book_status, cust_id) values ('BK037', '30-Apr-2023', 'Physical', 'Rejected', 'CT047');
insert into Booking (book_id, book_date, book_method, book_status, cust_id) values ('BK038', '27-Jan-2023', 'Online', 'Approved', 'CT044');
insert into Booking (book_id, book_date, book_method, book_status, cust_id) values ('BK039', '11-Feb-2023', 'Physical', 'Approved', 'CT024');
insert into Booking (book_id, book_date, book_method, book_status, cust_id) values ('BK040', '21-Feb-2023', 'Online', 'Approved', 'CT016');


insert into Trainer (trainer_id, trainer_firstname, trainer_lastname, trainer_phone, trainer_work_experience) values ('TR001', 'Selinda', 'Stoltz', '3042057289', 18);
insert into Trainer (trainer_id, trainer_firstname, trainer_lastname, trainer_phone, trainer_work_experience) values ('TR002', 'Keene', 'Gribble', '4821834133', 10);
insert into Trainer (trainer_id, trainer_firstname, trainer_lastname, trainer_phone, trainer_work_experience) values ('TR003', 'Lenora', 'Stairmand', '4325028172', 15);
insert into Trainer (trainer_id, trainer_firstname, trainer_lastname, trainer_phone, trainer_work_experience) values ('TR004', 'Amalia', 'Sabati', '5821932041', 5);
insert into Trainer (trainer_id, trainer_firstname, trainer_lastname, trainer_phone, trainer_work_experience) values ('TR005', 'Frayda', 'Zwicker', '6589602928', 3);
insert into Trainer (trainer_id, trainer_firstname, trainer_lastname, trainer_phone, trainer_work_experience) values ('TR006', 'Jami', 'Belleny', '3587547052', 8);
insert into Trainer (trainer_id, trainer_firstname, trainer_lastname, trainer_phone, trainer_work_experience) values ('TR007', 'Ardelle', 'Christophe', '6772395349', 18);
insert into Trainer (trainer_id, trainer_firstname, trainer_lastname, trainer_phone, trainer_work_experience) values ('TR008', 'Kimble', 'Wilkes', '8696732613', 3);
insert into Trainer (trainer_id, trainer_firstname, trainer_lastname, trainer_phone, trainer_work_experience) values ('TR009', 'Marni', 'Blythin', '6645110003', 13);
insert into Trainer (trainer_id, trainer_firstname, trainer_lastname, trainer_phone, trainer_work_experience) values ('TR010', 'Lorenzo', 'Janusik', '2767432363', 18);

insert into Training_type (train_type, train_fee) values ('Potty Training', 400);
insert into Training_type (train_type, train_fee) values ('Obedience Training', 300);
insert into Training_type (train_type, train_fee) values ('Protection Training', 2000);
insert into Training_type (train_type, train_fee) values ('Agility Training', 350);
insert into Training_type (train_type, train_fee) values ('Clicker Training', 200);
insert into Training_type (train_type, train_fee) values ('Trick Training', 250);
insert into Training_type (train_type, train_fee) values ('Leash Training', 360);
insert into Training_type (train_type, train_fee) values ('Behavioral Modification Training', 800);
insert into Training_type (train_type, train_fee) values ('Scent Detection Training', 3500);
insert into Training_type (train_type, train_fee) values ('Target Training', 340);

insert into Training (train_id, train_date, train_type, book_id, trainer_id) values ('TN001', '08-Jan-2023', 'Target Training', 'BK002', 'TR003');
insert into Training (train_id, train_date, train_type, book_id, trainer_id) values ('TN002', '27-Apr-2023', 'Trick Training', 'BK004', 'TR002');
insert into Training (train_id, train_date, train_type, book_id, trainer_id) values ('TN003', '26-Dec-2023', 'Target Training', 'BK006', 'TR007');
insert into Training (train_id, train_date, train_type, book_id, trainer_id) values ('TN004', '05-Jan-2023', 'Target Training', 'BK008', 'TR009');
insert into Training (train_id, train_date, train_type, book_id, trainer_id) values ('TN005', '18-Aug-2023', 'Target Training', 'BK009', 'TR005');
insert into Training (train_id, train_date, train_type, book_id, trainer_id) values ('TN006', '24-Mar-2023', 'Clicker Training', 'BK010', 'TR005');
insert into Training (train_id, train_date, train_type, book_id, trainer_id) values ('TN007', '03-Sep-2023', 'Behavioral Modification Training', 'BK011', 'TR003');
insert into Training (train_id, train_date, train_type, book_id, trainer_id) values ('TN008', '28-Jun-2023', 'Agility Training', 'BK012', 'TR003');
insert into Training (train_id, train_date, train_type, book_id, trainer_id) values ('TN009', '23-Jun-2023', 'Trick Training', 'BK013', 'TR010');
insert into Training (train_id, train_date, train_type, book_id, trainer_id) values ('TN010', '08-May-2023', 'Trick Training', 'BK014', 'TR003');
insert into Training (train_id, train_date, train_type, book_id, trainer_id) values ('TN011', '26-May-2023', 'Leash Training', 'BK015', 'TR005');
insert into Training (train_id, train_date, train_type, book_id, trainer_id) values ('TN012', '21-Apr-2023', 'Target Training', 'BK018', 'TR006');
insert into Training (train_id, train_date, train_type, book_id, trainer_id) values ('TN013', '14-Dec-2023', 'Trick Training', 'BK019', 'TR009');
insert into Training (train_id, train_date, train_type, book_id, trainer_id) values ('TN014', '18-Oct-2023', 'Leash Training', 'BK020', 'TR008');
insert into Training (train_id, train_date, train_type, book_id, trainer_id) values ('TN015', '08-Mar-2023', 'Clicker Training', 'BK021', 'TR002');
insert into Training (train_id, train_date, train_type, book_id, trainer_id) values ('TN016', '05-Jan-2023', 'Scent Detection Training', 'BK022', 'TR004');
insert into Training (train_id, train_date, train_type, book_id, trainer_id) values ('TN017', '10-Feb-2023', 'Protection Training', 'BK023', 'TR010');
insert into Training (train_id, train_date, train_type, book_id, trainer_id) values ('TN018', '13-Jul-2023', 'Obedience Training', 'BK026', 'TR009');
insert into Training (train_id, train_date, train_type, book_id, trainer_id) values ('TN019', '07-Jan-2023', 'Scent Detection Training', 'BK027', 'TR008');
insert into Training (train_id, train_date, train_type, book_id, trainer_id) values ('TN020', '28-Aug-2023', 'Clicker Training', 'BK028', 'TR006');
insert into Training (train_id, train_date, train_type, book_id, trainer_id) values ('TN021', '24-May-2023', 'Clicker Training', 'BK029', 'TR006');
insert into Training (train_id, train_date, train_type, book_id, trainer_id) values ('TN022', '30-Oct-2023', 'Behavioral Modification Training', 'BK031', 'TR005');
insert into Training (train_id, train_date, train_type, book_id, trainer_id) values ('TN023', '02-Aug-2023', 'Leash Training', 'BK032', 'TR004');
insert into Training (train_id, train_date, train_type, book_id, trainer_id) values ('TN024', '26-Sep-2023', 'Obedience Training', 'BK033', 'TR001');
insert into Training (train_id, train_date, train_type, book_id, trainer_id) values ('TN025', '13-Jun-2023', 'Potty Training', 'BK034', 'TR006');
insert into Training (train_id, train_date, train_type, book_id, trainer_id) values ('TN026', '18-Jul-2023', 'Scent Detection Training', 'BK035', 'TR005');
insert into Training (train_id, train_date, train_type, book_id, trainer_id) values ('TN027', '07-Nov-2023', 'Agility Training', 'BK036', 'TR002');
insert into Training (train_id, train_date, train_type, book_id, trainer_id) values ('TN028', '25-Jan-2023', 'Clicker Training', 'BK038', 'TR002');
insert into Training (train_id, train_date, train_type, book_id, trainer_id) values ('TN029', '21-Jan-2023', 'Scent Detection Training', 'BK039', 'TR004');
insert into Training (train_id, train_date, train_type, book_id, trainer_id) values ('TN030', '31-Jul-2023', 'Agility Training', 'BK040', 'TR003');


insert into Application (appli_id, appli_status, cust_id) values ('AP001', 'Pending', 'CT009');
insert into Application (appli_id, appli_status, cust_id) values ('AP002', 'Rejected', 'CT023');
insert into Application (appli_id, appli_status, cust_id) values ('AP003', 'Approved', 'CT045');
insert into Application (appli_id, appli_status, cust_id) values ('AP004', 'Approved', 'CT011');
insert into Application (appli_id, appli_status, cust_id) values ('AP005', 'Rejected', 'CT017');
insert into Application (appli_id, appli_status, cust_id) values ('AP006', 'Rejected', 'CT032');
insert into Application (appli_id, appli_status, cust_id) values ('AP007', 'Rejected', 'CT004');
insert into Application (appli_id, appli_status, cust_id) values ('AP008', 'Approved', 'CT035');
insert into Application (appli_id, appli_status, cust_id) values ('AP009', 'Pending', 'CT014');
insert into Application (appli_id, appli_status, cust_id) values ('AP010', 'Pending', 'CT049');
insert into Application (appli_id, appli_status, cust_id) values ('AP011', 'Rejected', 'CT001');
insert into Application (appli_id, appli_status, cust_id) values ('AP012', 'Rejected', 'CT028');
insert into Application (appli_id, appli_status, cust_id) values ('AP013', 'Approved', 'CT005');
insert into Application (appli_id, appli_status, cust_id) values ('AP014', 'Approved', 'CT042');
insert into Application (appli_id, appli_status, cust_id) values ('AP015', 'Approved', 'CT030');
insert into Application (appli_id, appli_status, cust_id) values ('AP016', 'Rejected', 'CT018');
insert into Application (appli_id, appli_status, cust_id) values ('AP017', 'Approved', 'CT008');
insert into Application (appli_id, appli_status, cust_id) values ('AP018', 'Rejected', 'CT044');
insert into Application (appli_id, appli_status, cust_id) values ('AP019', 'Approved', 'CT022');
insert into Application (appli_id, appli_status, cust_id) values ('AP020', 'Approved', 'CT012');
insert into Application (appli_id, appli_status, cust_id) values ('AP021', 'Rejected', 'CT039');
insert into Application (appli_id, appli_status, cust_id) values ('AP022', 'Rejected', 'CT046');
insert into Application (appli_id, appli_status, cust_id) values ('AP023', 'Pending', 'CT003');
insert into Application (appli_id, appli_status, cust_id) values ('AP024', 'Rejected', 'CT050');
insert into Application (appli_id, appli_status, cust_id) values ('AP025', 'Rejected', 'CT010');
insert into Application (appli_id, appli_status, cust_id) values ('AP026', 'Pending', 'CT016');
insert into Application (appli_id, appli_status, cust_id) values ('AP027', 'Rejected', 'CT043');
insert into Application (appli_id, appli_status, cust_id) values ('AP028', 'Rejected', 'CT026');
insert into Application (appli_id, appli_status, cust_id) values ('AP029', 'Rejected', 'CT007');
insert into Application (appli_id, appli_status, cust_id) values ('AP030', 'Rejected', 'CT019');
insert into Application (appli_id, appli_status, cust_id) values ('AP031', 'Approved', 'CT002');
insert into Application (appli_id, appli_status, cust_id) values ('AP032', 'Approved', 'CT006');
insert into Application (appli_id, appli_status, cust_id) values ('AP033', 'Approved', 'CT013');
insert into Application (appli_id, appli_status, cust_id) values ('AP034', 'Approved', 'CT015');
insert into Application (appli_id, appli_status, cust_id) values ('AP035', 'Approved', 'CT020');
insert into Application (appli_id, appli_status, cust_id) values ('AP036', 'Approved', 'CT031');

insert into Consultation (consul_id, consul_date, counsellor_firstname, counsellor_lastname, counsellor_phone, appli_id) values ('CL001', '19-Jun-2023', 'Alene', 'Guidi', '5894016983', 'AP003');
insert into Consultation (consul_id, consul_date, counsellor_firstname, counsellor_lastname, counsellor_phone, appli_id) values ('CL002', '12-Mar-2023', 'Stevy', 'Bindon', '8472610466', 'AP004');
insert into Consultation (consul_id, consul_date, counsellor_firstname, counsellor_lastname, counsellor_phone, appli_id) values ('CL003', '08-Dec-2023', 'Shana', 'Gosswell', '7543538904', 'AP008');
insert into Consultation (consul_id, consul_date, counsellor_firstname, counsellor_lastname, counsellor_phone, appli_id) values ('CL004', '05-Jan-2023', 'Conrade', 'Duckers', '5933039922', 'AP013');
insert into Consultation (consul_id, consul_date, counsellor_firstname, counsellor_lastname, counsellor_phone, appli_id) values ('CL005', '03-Dec-2023', 'Stephannie', 'Kryszicz', '2074732711', 'AP014');
insert into Consultation (consul_id, consul_date, counsellor_firstname, counsellor_lastname, counsellor_phone, appli_id) values ('CL006', '15-Apr-2023', 'Hyacinthie', 'Ridsdole', '2631181274', 'AP015');
insert into Consultation (consul_id, consul_date, counsellor_firstname, counsellor_lastname, counsellor_phone, appli_id) values ('CL007', '16-Dec-2023', 'Kata', 'Junkin', '5577127349', 'AP017');
insert into Consultation (consul_id, consul_date, counsellor_firstname, counsellor_lastname, counsellor_phone, appli_id) values ('CL008', '12-Nov-2023', 'Lief', 'Copestick', '4351072218', 'AP019');
insert into Consultation (consul_id, consul_date, counsellor_firstname, counsellor_lastname, counsellor_phone, appli_id) values ('CL009', '01-Oct-2023', 'Nicole', 'Ivery', '3496246409', 'AP020');
insert into Consultation (consul_id, consul_date, counsellor_firstname, counsellor_lastname, counsellor_phone, appli_id) values ('CL010', '11-Jul-2023', 'Caryn', 'Renoden', '8352497929', 'AP031');
insert into Consultation (consul_id, consul_date, counsellor_firstname, counsellor_lastname, counsellor_phone, appli_id) values ('CL011', '20-Nov-2023', 'Diahann', 'Cadwaladr', '3836328536', 'AP032');
insert into Consultation (consul_id, consul_date, counsellor_firstname, counsellor_lastname, counsellor_phone, appli_id) values ('CL012', '22-Feb-2023', 'Augusta', 'Edgeworth', '6194910478', 'AP033');
insert into Consultation (consul_id, consul_date, counsellor_firstname, counsellor_lastname, counsellor_phone, appli_id) values ('CL013', '10-Sep-2023', 'Keen', 'Scranedge', '3172191560', 'AP034');
insert into Consultation (consul_id, consul_date, counsellor_firstname, counsellor_lastname, counsellor_phone, appli_id) values ('CL014', '22-Mar-2023', 'Kala', 'Arthan', '1344091736', 'AP035');
insert into Consultation (consul_id, consul_date, counsellor_firstname, counsellor_lastname, counsellor_phone, appli_id) values ('CL015', '13-Dec-2023', 'Stephannie', 'Kryszicz', '2074732711', 'AP036');


insert into Location (location_id, location_state) values ('LC001', 'Johor Bahru');
insert into Location (location_id, location_state) values ('LC002', 'Kuala Lumpur');
insert into Location (location_id, location_state) values ('LC003', 'Georgetown');
insert into Location (location_id, location_state) values ('LC004', 'Alor Setar');
insert into Location (location_id, location_state) values ('LC005', 'Kota Bharu');
insert into Location (location_id, location_state) values ('LC006', 'Putrajaya');
insert into Location (location_id, location_state) values ('LC007', 'Seremban');
insert into Location (location_id, location_state) values ('LC008', 'Kuantan');
insert into Location (location_id, location_state) values ('LC009', 'Ipoh');
insert into Location (location_id, location_state) values ('LC010', 'Kangar');
insert into Location (location_id, location_state) values ('LC011', 'Shah Alam');

insert into Shelter (shelter_id, shelter_name, shelter_address, location_id) values ('ST001', 'Fivespan', '7252 Glendale Lane', 'LC001');
insert into Shelter (shelter_id, shelter_name, shelter_address, location_id) values ('ST002', 'Brainverse', '86894 Eliot Way', 'LC003');
insert into Shelter (shelter_id, shelter_name, shelter_address, location_id) values ('ST003', 'Eazzy', '8 Granby Alley', 'LC004');
insert into Shelter (shelter_id, shelter_name, shelter_address, location_id) values ('ST004', 'Yakijo', '831 Banding Terrace', 'LC003');
insert into Shelter (shelter_id, shelter_name, shelter_address, location_id) values ('ST005', 'Lazz', '4 Leroy Lane', 'LC001');
insert into Shelter (shelter_id, shelter_name, shelter_address, location_id) values ('ST006', 'Photolist', '04 Forest Dale Junction', 'LC002');
insert into Shelter (shelter_id, shelter_name, shelter_address, location_id) values ('ST007', 'Jamia', '4459 South Park', 'LC006');
insert into Shelter (shelter_id, shelter_name, shelter_address, location_id) values ('ST008', 'Divavu', '85 Continental Alley', 'LC002');
insert into Shelter (shelter_id, shelter_name, shelter_address, location_id) values ('ST009', 'Chatterbridge', '59 Northridge Crossing', 'LC009');
insert into Shelter (shelter_id, shelter_name, shelter_address, location_id) values ('ST010', 'Tagopia', '374 Bay Center', 'LC002');
insert into Shelter (shelter_id, shelter_name, shelter_address, location_id) values ('ST011', 'Roombo', '96 Portage Crossing', 'LC001');
insert into Shelter (shelter_id, shelter_name, shelter_address, location_id) values ('ST012', 'Realcube', '4960 Northfield Junction', 'LC002');
insert into Shelter (shelter_id, shelter_name, shelter_address, location_id) values ('ST013', 'Twitterbridge', '16 Beilfuss Way', 'LC008');
insert into Shelter (shelter_id, shelter_name, shelter_address, location_id) values ('ST014', 'Voolia', '1 Oakridge Trail', 'LC002');
insert into Shelter (shelter_id, shelter_name, shelter_address, location_id) values ('ST015', 'Yotz', '49 Rowland Place', 'LC003');
insert into Shelter (shelter_id, shelter_name, shelter_address, location_id) values ('ST016', 'Jaxnation', '3 Continental Pass', 'LC011');
insert into Shelter (shelter_id, shelter_name, shelter_address, location_id) values ('ST017', 'Voomm', '3016 Spohn Trail', 'LC005');
insert into Shelter (shelter_id, shelter_name, shelter_address, location_id) values ('ST018', 'Kwimbee', '87970 Sloan Center', 'LC002');
insert into Shelter (shelter_id, shelter_name, shelter_address, location_id) values ('ST019', 'Vitz', '51 Dakota Hill', 'LC002');
insert into Shelter (shelter_id, shelter_name, shelter_address, location_id) values ('ST020', 'Viva', '89 Dunning Terrace', 'LC004');
insert into Shelter (shelter_id, shelter_name, shelter_address, location_id) values ('ST021', 'Eayo', '9015 Dorton Road', 'LC006');
insert into Shelter (shelter_id, shelter_name, shelter_address, location_id) values ('ST022', 'Browsezoom', '49 Caliangt Crossing', 'LC003');
insert into Shelter (shelter_id, shelter_name, shelter_address, location_id) values ('ST023', 'Quatz', '725 Elgar Road', 'LC010');
insert into Shelter (shelter_id, shelter_name, shelter_address, location_id) values ('ST024', 'Edgetag', '93075 Red Cloud Way', 'LC007');
insert into Shelter (shelter_id, shelter_name, shelter_address, location_id) values ('ST025', 'Avamm', '67833 Dryden Center', 'LC002');
insert into Shelter (shelter_id, shelter_name, shelter_address, location_id) values ('ST026', 'Skyble', '71 Summerview Drive', 'LC006');
insert into Shelter (shelter_id, shelter_name, shelter_address, location_id) values ('ST027', 'Jazzy', '672 Tennessee Crossing', 'LC002');
insert into Shelter (shelter_id, shelter_name, shelter_address, location_id) values ('ST028', 'Skimia', '04705 Melrose Plaza', 'LC009');
insert into Shelter (shelter_id, shelter_name, shelter_address, location_id) values ('ST029', 'Gabspot', '23694 Coolidge Place', 'LC010');
insert into Shelter (shelter_id, shelter_name, shelter_address, location_id) values ('ST030', 'Flashdog', '20095 Lotheville Terrace', 'LC002');

insert into Donor (donor_id, donor_firstname, donor_lastname, donor_address, donor_phone) values ('DR001', 'Ravid', 'Hacquoil', '4744 Kennedy Alley', '7612065496');
insert into Donor (donor_id, donor_firstname, donor_lastname, donor_address, donor_phone) values ('DR002', 'Michelle', 'Stubs', '8473 Buhler Parkway', '4489165131');
insert into Donor (donor_id, donor_firstname, donor_lastname, donor_phone, donor_address, cust_id) values ('DR003', 'Gayel', 'Burnhard', '9209299712', '29 Vahlen Crossing', 'CT050');
insert into Donor (donor_id, donor_firstname, donor_lastname, donor_address, donor_phone) values ('DR004', 'Muffin', 'Aubray', '858 Truax Plaza', '2138683574');
insert into Donor (donor_id, donor_firstname, donor_lastname, donor_address, donor_phone) values ('DR005', 'Lyndsey', 'Sonley', '474 Everett Place', '2961766262');
insert into Donor (donor_id, donor_firstname, donor_lastname, donor_address, donor_phone, cust_id) values ('DR006', 'Gillian', 'Gammett', '3571 Lyons Road', '2644326656', 'CT045');
insert into Donor (donor_id, donor_firstname, donor_lastname, donor_address, donor_phone, cust_id) values ('DR007', 'Gretna', 'Rosettini', '004 Longview Park', '3983213234', 'CT014');
insert into Donor (donor_id, donor_firstname, donor_lastname, donor_address, donor_phone) values ('DR008', 'Mateo', 'Guitel', '7447 Mitchell Park', '7726585367');
insert into Donor (donor_id, donor_firstname, donor_lastname, donor_address, donor_phone, cust_id) values ('DR009', 'Jannel', 'Caghy', '5785 Golden Leaf Junction', '3775620391', 'CT026');
insert into Donor (donor_id, donor_firstname, donor_lastname, donor_address, donor_phone, cust_id) values ('DR010', 'Raffarty', 'Burrage', '00 Meadow Ridge Hill', '5368852530', 'CT035');
insert into Donor (donor_id, donor_firstname, donor_lastname, donor_address, donor_phone) values ('DR011', 'Kristopher', 'Kassel', '74 Dottie Point', '4655565816');
insert into Donor (donor_id, donor_firstname, donor_lastname, donor_address, donor_phone) values ('DR012', 'Carmita', 'Crippin', '73739 Canary Road', '9715817530');
insert into Donor (donor_id, donor_firstname, donor_lastname, donor_address, donor_phone) values ('DR013', 'Fidel', 'Howen', '53233 Oriole Court', '5879810344');
insert into Donor (donor_id, donor_firstname, donor_lastname, donor_address, donor_phone) values ('DR014', 'Gerhardt', 'Bellenger', '45 Garrison Place', '3806189729');
insert into Donor (donor_id, donor_firstname, donor_lastname, donor_address, donor_phone) values ('DR015', 'Judie', 'Kubacek', '5 Badeau Road', '7042624937');

insert into Donation (donate_id, donate_amount, donate_date, donor_id, shelter_id) values ('DN001', 3367, '03-Oct-2023', 'DR001', 'ST009');
insert into Donation (donate_id, donate_amount, donate_date, donor_id, shelter_id) values ('DN002', 72881, '12-Jan-2023', 'DR002', 'ST010');
insert into Donation (donate_id, donate_amount, donate_date, donor_id, shelter_id) values ('DN003', 92764, '08-Feb-2023', 'DR003', 'ST015');
insert into Donation (donate_id, donate_amount, donate_date, donor_id, shelter_id) values ('DN004', 36081, '23-Jun-2023', 'DR004', 'ST030');
insert into Donation (donate_id, donate_amount, donate_date, donor_id, shelter_id) values ('DN005', 92232, '16-Apr-2023', 'DR005', 'ST004');
insert into Donation (donate_id, donate_amount, donate_date, donor_id, shelter_id) values ('DN006', 437, '13-Aug-2023', 'DR006', 'ST005');
insert into Donation (donate_id, donate_amount, donate_date, donor_id, shelter_id) values ('DN007', 11805, '06-May-2023', 'DR007', 'ST027');
insert into Donation (donate_id, donate_amount, donate_date, donor_id, shelter_id) values ('DN008', 79634, '23-Dec-2023', 'DR008', 'ST030');
insert into Donation (donate_id, donate_amount, donate_date, donor_id, shelter_id) values ('DN009', 93658, '03-Mar-2023', 'DR009', 'ST005');
insert into Donation (donate_id, donate_amount, donate_date, donor_id, shelter_id) values ('DN010', 7827, '10-Dec-2023', 'DR010', 'ST016');
insert into Donation (donate_id, donate_amount, donate_date, donor_id, shelter_id) values ('DN011', 9909, '19-Jan-2023', 'DR011', 'ST001');
insert into Donation (donate_id, donate_amount, donate_date, donor_id, shelter_id) values ('DN012', 20993, '03-May-2023', 'DR012', 'ST013');
insert into Donation (donate_id, donate_amount, donate_date, donor_id, shelter_id) values ('DN013', 75234, '30-May-2023', 'DR013', 'ST029');
insert into Donation (donate_id, donate_amount, donate_date, donor_id, shelter_id) values ('DN014', 53344, '14-Dec-2023', 'DR014', 'ST019');
insert into Donation (donate_id, donate_amount, donate_date, donor_id, shelter_id) values ('DN015', 16528, '23-Jul-2023', 'DR015', 'ST006');


insert into Medical_type (medic_type, medic_fee) values ('Neutering', 300);
insert into Medical_type (medic_type, medic_fee) values ('Dental Cleaning', 300);
insert into Medical_type (medic_type, medic_fee) values ('Deworming', 50);
insert into Medical_type (medic_type, medic_fee) values ('Vaccination', 80);
insert into Medical_type (medic_type, medic_fee) values ('Euthanasia', 250);
insert into Medical_type (medic_type, medic_fee) values ('Surgery (Major)', 1000);
insert into Medical_type (medic_type, medic_fee) values ('Surgery (Minor)', 500);
insert into Medical_type (medic_type, medic_fee) values ('Ultrasound', 400);
insert into Medical_type (medic_type, medic_fee) values ('X-Ray', 300);
insert into Medical_type (medic_type, medic_fee) values ('Blood Test', 100);

insert into Animal (anm_id, anm_name, anm_gender, anm_year_born, anm_breeds, shelter_id) values ('AN001', 'Allsun', 'F', 2019, 'Dachshund', 'ST005');
insert into Animal (anm_id, anm_name, anm_gender, anm_year_born, anm_breeds, shelter_id) values ('AN002', 'Cody', 'F', 2007, 'Boxer', 'ST014');
insert into Animal (anm_id, anm_name, anm_gender, anm_year_born, anm_breeds, shelter_id) values ('AN003', 'Meier', 'M', 2014, 'Scottish Fold', 'ST024');
insert into Animal (anm_id, anm_name, anm_gender, anm_year_born, anm_breeds, shelter_id) values ('AN004', 'Kylynn', 'F', 2003, 'Scottish Fold', 'ST026');
insert into Animal (anm_id, anm_name, anm_gender, anm_year_born, anm_breeds, shelter_id) values ('AN005', 'Terry', 'M', 2011, 'Maine Coon', 'ST004');
insert into Animal (anm_id, anm_name, anm_gender, anm_year_born, anm_breeds, shelter_id) values ('AN006', 'Norby', 'M', 2014, 'Siamese', 'ST012');
insert into Animal (anm_id, anm_name, anm_gender, anm_year_born, anm_breeds, shelter_id) values ('AN007', 'Twyla', 'F', 2017, 'Golden Retriever', 'ST028');
insert into Animal (anm_id, anm_name, anm_gender, anm_year_born, anm_breeds, shelter_id) values ('AN008', 'Nico', 'M', 2021, 'Persian', 'ST026');
insert into Animal (anm_id, anm_name, anm_gender, anm_year_born, anm_breeds, shelter_id) values ('AN009', 'Siusan', 'F', 2013, 'British Shorthair', 'ST028');
insert into Animal (anm_id, anm_name, anm_gender, anm_year_born, anm_breeds, shelter_id) values ('AN010', 'Matti', 'F', 2016, 'Golden Retriever', 'ST006');
insert into Animal (anm_id, anm_name, anm_gender, anm_year_born, anm_breeds, shelter_id) values ('AN011', 'Robinia', 'F', 2014, 'Bengal', 'ST009');
insert into Animal (anm_id, anm_name, anm_gender, anm_year_born, anm_breeds, shelter_id) values ('AN012', 'Cris', 'M', 2018, 'American Shorthair', 'ST021');
insert into Animal (anm_id, anm_name, anm_gender, anm_year_born, anm_breeds, shelter_id) values ('AN013', 'Marlin', 'M', 2013, 'Poodle', 'ST003');
insert into Animal (anm_id, anm_name, anm_gender, anm_year_born, anm_breeds, shelter_id) values ('AN014', 'Sutton', 'M', 2014, 'Sphynx', 'ST028');
insert into Animal (anm_id, anm_name, anm_gender, anm_year_born, anm_breeds, shelter_id) values ('AN015', 'Mychal', 'M', 2007, 'Golden Retriever', 'ST021');
insert into Animal (anm_id, anm_name, anm_gender, anm_year_born, anm_breeds, shelter_id) values ('AN016', 'Jackie', 'F', 2018, 'Sphynx', 'ST020');
insert into Animal (anm_id, anm_name, anm_gender, anm_year_born, anm_breeds, shelter_id) values ('AN017', 'Aile', 'F', 2020, 'Ragdoll', 'ST027');
insert into Animal (anm_id, anm_name, anm_gender, anm_year_born, anm_breeds, shelter_id) values ('AN018', 'Lindie', 'F', 2014, 'Golden Retriever', 'ST028');
insert into Animal (anm_id, anm_name, anm_gender, anm_year_born, anm_breeds, shelter_id) values ('AN019', 'Galvan', 'M', 2013, 'American Shorthair', 'ST016');
insert into Animal (anm_id, anm_name, anm_gender, anm_year_born, anm_breeds, shelter_id) values ('AN020', 'Euell', 'M', 2011, 'Scottish Fold', 'ST021');
insert into Animal (anm_id, anm_name, anm_gender, anm_year_born, anm_breeds, shelter_id) values ('AN021', 'Jacquelin', 'F', 2019, 'Scottish Fold', 'ST005');
insert into Animal (anm_id, anm_name, anm_gender, anm_year_born, anm_breeds, shelter_id) values ('AN022', 'Allistir', 'M', 2015, 'Siberian Husky', 'ST028');
insert into Animal (anm_id, anm_name, anm_gender, anm_year_born, anm_breeds, shelter_id) values ('AN023', 'Killy', 'M', 2007, 'Beagle', 'ST003');
insert into Animal (anm_id, anm_name, anm_gender, anm_year_born, anm_breeds, shelter_id) values ('AN024', 'Yelena', 'F', 2009, 'Rottweiler', 'ST011');
insert into Animal (anm_id, anm_name, anm_gender, anm_year_born, anm_breeds, shelter_id) values ('AN025', 'Marcus', 'M', 2006, 'Boxer', 'ST027');
insert into Animal (anm_id, anm_name, anm_gender, anm_year_born, anm_breeds, shelter_id) values ('AN026', 'Ali', 'F', 2009, 'Persian', 'ST005');
insert into Animal (anm_id, anm_name, anm_gender, anm_year_born, anm_breeds, shelter_id) values ('AN027', 'Sheeree', 'F', 2007, 'Labrador Retriever', 'ST011');
insert into Animal (anm_id, anm_name, anm_gender, anm_year_born, anm_breeds, shelter_id) values ('AN028', 'Karalee', 'F', 2010, 'Ragdoll', 'ST021');
insert into Animal (anm_id, anm_name, anm_gender, anm_year_born, anm_breeds, shelter_id) values ('AN029', 'Lane', 'F', 2011, 'Bulldog', 'ST011');
insert into Animal (anm_id, anm_name, anm_gender, anm_year_born, anm_breeds, shelter_id) values ('AN030', 'Skylar', 'M', 2015, 'Abyssinian', 'ST005');
insert into Animal (anm_id, anm_name, anm_gender, anm_year_born, anm_breeds, shelter_id) values ('AN031', 'Henderson', 'M', 2007, 'Poodle', 'ST021');
insert into Animal (anm_id, anm_name, anm_gender, anm_year_born, anm_breeds, shelter_id) values ('AN032', 'Clarie', 'F', 2004, 'Rottweiler', 'ST021');
insert into Animal (anm_id, anm_name, anm_gender, anm_year_born, anm_breeds, shelter_id) values ('AN033', 'Pincus', 'M', 2014, 'Bulldog', 'ST025');
insert into Animal (anm_id, anm_name, anm_gender, anm_year_born, anm_breeds, shelter_id) values ('AN034', 'Gonzales', 'M', 2017, 'Abyssinian', 'ST005');
insert into Animal (anm_id, anm_name, anm_gender, anm_year_born, anm_breeds, shelter_id) values ('AN035', 'Dawn', 'F', 2015, 'Abyssinian', 'ST014');
insert into Animal (anm_id, anm_name, anm_gender, anm_year_born, anm_breeds, shelter_id) values ('AN036', 'Colan', 'M', 2016, 'Rottweiler', 'ST011');
insert into Animal (anm_id, anm_name, anm_gender, anm_year_born, anm_breeds, shelter_id) values ('AN037', 'Carolin', 'F', 2013, 'Golden Retriever', 'ST008');
insert into Animal (anm_id, anm_name, anm_gender, anm_year_born, anm_breeds, shelter_id) values ('AN038', 'Ashlee', 'F', 2019, 'Siberian Husky', 'ST003');
insert into Animal (anm_id, anm_name, anm_gender, anm_year_born, anm_breeds, shelter_id) values ('AN039', 'Laurence', 'M', 2008, 'German Shepherd', 'ST018');
insert into Animal (anm_id, anm_name, anm_gender, anm_year_born, anm_breeds, shelter_id) values ('AN040', 'Aymer', 'M', 2006, 'Rottweiler', 'ST011');
insert into Animal (anm_id, anm_name, anm_gender, anm_year_born, anm_breeds, shelter_id) values ('AN041', 'Horace', 'M', 2016, 'Siberian Husky', 'ST021');
insert into Animal (anm_id, anm_name, anm_gender, anm_year_born, anm_breeds, shelter_id) values ('AN042', 'Barnaby', 'M', 2003, 'Rottweiler', 'ST028');
insert into Animal (anm_id, anm_name, anm_gender, anm_year_born, anm_breeds, shelter_id) values ('AN043', 'Giorgia', 'F', 2011, 'Poodle', 'ST009');
insert into Animal (anm_id, anm_name, anm_gender, anm_year_born, anm_breeds, shelter_id) values ('AN044', 'Garrick', 'M', 2012, 'Ragdoll', 'ST005');
insert into Animal (anm_id, anm_name, anm_gender, anm_year_born, anm_breeds, shelter_id) values ('AN045', 'Andeee', 'F', 2008, 'Scottish Fold', 'ST011');
insert into Animal (anm_id, anm_name, anm_gender, anm_year_born, anm_breeds, shelter_id) values ('AN046', 'Alford', 'M', 2005, 'Siamese', 'ST005');
insert into Animal (anm_id, anm_name, anm_gender, anm_year_born, anm_breeds, shelter_id) values ('AN047', 'Annemarie', 'F', 2017, 'American Shorthair', 'ST011');
insert into Animal (anm_id, anm_name, anm_gender, anm_year_born, anm_breeds, shelter_id) values ('AN048', 'Wilt', 'M', 2006, 'Siamese', 'ST019');
insert into Animal (anm_id, anm_name, anm_gender, anm_year_born, anm_breeds, shelter_id) values ('AN049', 'Tarrah', 'F', 2019, 'Dachshund', 'ST005');
insert into Animal (anm_id, anm_name, anm_gender, anm_year_born, anm_breeds, shelter_id) values ('AN050', 'Jany', 'F', 2009, 'Scottish Fold', 'ST028');


insert into Medical_exam (medic_id, medic_date, medic_type, anm_id) values ('MD001', '24-Dec-2023', 'Neutering', 'AN008');
insert into Medical_exam (medic_id, medic_date, medic_type, anm_id) values ('MD002', '24-Aug-2023', 'Surgery (Minor)', 'AN039');
insert into Medical_exam (medic_id, medic_date, medic_type, anm_id) values ('MD003', '30-Jul-2023', 'Deworming', 'AN009');
insert into Medical_exam (medic_id, medic_date, medic_type, anm_id) values ('MD004', '21-Apr-2023', 'Blood Test', 'AN022');
insert into Medical_exam (medic_id, medic_date, medic_type, anm_id) values ('MD005', '29-Aug-2023', 'Surgery (Major)', 'AN013');
insert into Medical_exam (medic_id, medic_date, medic_type, anm_id) values ('MD006', '10-Oct-2023', 'Deworming', 'AN024');
insert into Medical_exam (medic_id, medic_date, medic_type, anm_id) values ('MD007', '27-Apr-2023', 'Blood Test', 'AN021');
insert into Medical_exam (medic_id, medic_date, medic_type, anm_id) values ('MD008', '27-Sep-2023', 'Euthanasia', 'AN005');
insert into Medical_exam (medic_id, medic_date, medic_type, anm_id) values ('MD009', '11-Apr-2023', 'Neutering', 'AN010');
insert into Medical_exam (medic_id, medic_date, medic_type, anm_id) values ('MD010', '14-Aug-2023', 'Deworming', 'AN040');
insert into Medical_exam (medic_id, medic_date, medic_type, anm_id) values ('MD011', '07-Sep-2023', 'Surgery (Minor)', 'AN044');
insert into Medical_exam (medic_id, medic_date, medic_type, anm_id) values ('MD012', '09-Jan-2023', 'Surgery (Minor)', 'AN019');
insert into Medical_exam (medic_id, medic_date, medic_type, anm_id) values ('MD013', '18-Sep-2023', 'Vaccination', 'AN019');
insert into Medical_exam (medic_id, medic_date, medic_type, anm_id) values ('MD014', '22-Jun-2023', 'Neutering', 'AN046');
insert into Medical_exam (medic_id, medic_date, medic_type, anm_id) values ('MD015', '28-Mar-2023', 'Surgery (Minor)', 'AN010');
insert into Medical_exam (medic_id, medic_date, medic_type, anm_id) values ('MD016', '10-Jul-2023', 'Dental Cleaning', 'AN007');
insert into Medical_exam (medic_id, medic_date, medic_type, anm_id) values ('MD017', '25-Jun-2023', 'X-Ray', 'AN041');
insert into Medical_exam (medic_id, medic_date, medic_type, anm_id) values ('MD018', '30-May-2023', 'Surgery (Major)', 'AN005');
insert into Medical_exam (medic_id, medic_date, medic_type, anm_id) values ('MD019', '15-Oct-2023', 'X-Ray', 'AN033');
insert into Medical_exam (medic_id, medic_date, medic_type, anm_id) values ('MD020', '13-Jan-2023', 'Dental Cleaning', 'AN025');
insert into Medical_exam (medic_id, medic_date, medic_type, anm_id) values ('MD021', '15-May-2023', 'Blood Test', 'AN030');
insert into Medical_exam (medic_id, medic_date, medic_type, anm_id) values ('MD022', '26-Oct-2023', 'Dental Cleaning', 'AN027');
insert into Medical_exam (medic_id, medic_date, medic_type, anm_id) values ('MD023', '18-Mar-2023', 'Blood Test', 'AN048');
insert into Medical_exam (medic_id, medic_date, medic_type, anm_id) values ('MD024', '22-Dec-2023', 'Vaccination', 'AN021');
insert into Medical_exam (medic_id, medic_date, medic_type, anm_id) values ('MD025', '25-Jul-2023', 'Dental Cleaning', 'AN049');
insert into Medical_exam (medic_id, medic_date, medic_type, anm_id) values ('MD026', '02-May-2023', 'Vaccination', 'AN019');
insert into Medical_exam (medic_id, medic_date, medic_type, anm_id) values ('MD027', '17-Mar-2023', 'Blood Test', 'AN013');
insert into Medical_exam (medic_id, medic_date, medic_type, anm_id) values ('MD028', '13-May-2023', 'Surgery (Major)', 'AN040');
insert into Medical_exam (medic_id, medic_date, medic_type, anm_id) values ('MD029', '26-Sep-2023', 'Vaccination', 'AN043');
insert into Medical_exam (medic_id, medic_date, medic_type, anm_id) values ('MD030', '05-Oct-2023', 'Vaccination', 'AN017');
insert into Medical_exam (medic_id, medic_date, medic_type, anm_id) values ('MD031', '30-Oct-2023', 'Surgery (Major)', 'AN018');
insert into Medical_exam (medic_id, medic_date, medic_type, anm_id) values ('MD032', '29-Sep-2023', 'Neutering', 'AN050');
insert into Medical_exam (medic_id, medic_date, medic_type, anm_id) values ('MD033', '04-Dec-2023', 'Dental Cleaning', 'AN008');
insert into Medical_exam (medic_id, medic_date, medic_type, anm_id) values ('MD034', '22-Dec-2023', 'X-Ray', 'AN023');
insert into Medical_exam (medic_id, medic_date, medic_type, anm_id) values ('MD035', '28-Jan-2023', 'Deworming', 'AN044');
insert into Medical_exam (medic_id, medic_date, medic_type, anm_id) values ('MD036', '05-Feb-2023', 'Deworming', 'AN035');
insert into Medical_exam (medic_id, medic_date, medic_type, anm_id) values ('MD037', '06-Mar-2023', 'Ultrasound', 'AN025');
insert into Medical_exam (medic_id, medic_date, medic_type, anm_id) values ('MD038', '21-Apr-2023', 'Surgery (Minor)', 'AN019');
insert into Medical_exam (medic_id, medic_date, medic_type, anm_id) values ('MD039', '04-Apr-2023', 'Euthanasia', 'AN039');
insert into Medical_exam (medic_id, medic_date, medic_type, anm_id) values ('MD040', '17-Oct-2023', 'X-Ray', 'AN037');
insert into Medical_exam (medic_id, medic_date, medic_type, anm_id) values ('MD041', '15-Oct-2023', 'Dental Cleaning', 'AN012');
insert into Medical_exam (medic_id, medic_date, medic_type, anm_id) values ('MD042', '21-Oct-2023', 'Neutering', 'AN003');
insert into Medical_exam (medic_id, medic_date, medic_type, anm_id) values ('MD043', '14-Oct-2023', 'X-Ray', 'AN002');
insert into Medical_exam (medic_id, medic_date, medic_type, anm_id) values ('MD044', '28-Sep-2023', 'Vaccination', 'AN020');
insert into Medical_exam (medic_id, medic_date, medic_type, anm_id) values ('MD045', '23-Nov-2023', 'Euthanasia', 'AN002');
insert into Medical_exam (medic_id, medic_date, medic_type, anm_id) values ('MD046', '30-Jan-2023', 'Deworming', 'AN038');
insert into Medical_exam (medic_id, medic_date, medic_type, anm_id) values ('MD047', '28-Aug-2023', 'Neutering', 'AN027');
insert into Medical_exam (medic_id, medic_date, medic_type, anm_id) values ('MD048', '05-Oct-2023', 'Surgery (Minor)', 'AN020');
insert into Medical_exam (medic_id, medic_date, medic_type, anm_id) values ('MD049', '11-May-2023', 'Surgery (Minor)', 'AN001');
insert into Medical_exam (medic_id, medic_date, medic_type, anm_id) values ('MD050', '26-Apr-2023', 'Surgery (Major)', 'AN024');


insert into Promotion (promotion_id, promotion_status, cust_id) values ('PM001', 'Yes', 'CT001');
insert into Promotion (promotion_id, promotion_status, cust_id) values ('PM002', 'No', 'CT002');
insert into Promotion (promotion_id, promotion_status, cust_id) values ('PM003', 'Yes', 'CT003');
insert into Promotion (promotion_id, promotion_status, cust_id) values ('PM004', 'No', 'CT004');
insert into Promotion (promotion_id, promotion_status, cust_id) values ('PM005', 'No', 'CT005');
insert into Promotion (promotion_id, promotion_status, cust_id) values ('PM006', 'No', 'CT006');
insert into Promotion (promotion_id, promotion_status, cust_id) values ('PM007', 'Yes', 'CT007');
insert into Promotion (promotion_id, promotion_status, cust_id) values ('PM008', 'No', 'CT008');
insert into Promotion (promotion_id, promotion_status, cust_id) values ('PM009', 'Yes', 'CT009');
insert into Promotion (promotion_id, promotion_status, cust_id) values ('PM010', 'No', 'CT010');
insert into Promotion (promotion_id, promotion_status, cust_id) values ('PM011', 'Yes', 'CT011');
insert into Promotion (promotion_id, promotion_status, cust_id) values ('PM012', 'No', 'CT012');
insert into Promotion (promotion_id, promotion_status, cust_id) values ('PM013', 'No', 'CT013');
insert into Promotion (promotion_id, promotion_status, cust_id) values ('PM014', 'Yes', 'CT014');
insert into Promotion (promotion_id, promotion_status, cust_id) values ('PM015', 'No', 'CT015');
insert into Promotion (promotion_id, promotion_status, cust_id) values ('PM016', 'No', 'CT016');
insert into Promotion (promotion_id, promotion_status, cust_id) values ('PM017', 'No', 'CT017');
insert into Promotion (promotion_id, promotion_status, cust_id) values ('PM018', 'Yes', 'CT018');
insert into Promotion (promotion_id, promotion_status, cust_id) values ('PM019', 'Yes', 'CT019');
insert into Promotion (promotion_id, promotion_status, cust_id) values ('PM020', 'Yes', 'CT020');
insert into Promotion (promotion_id, promotion_status, cust_id) values ('PM021', 'Yes', 'CT021');
insert into Promotion (promotion_id, promotion_status, cust_id) values ('PM022', 'No', 'CT022');
insert into Promotion (promotion_id, promotion_status, cust_id) values ('PM023', 'Yes', 'CT023');
insert into Promotion (promotion_id, promotion_status, cust_id) values ('PM024', 'Yes', 'CT024');
insert into Promotion (promotion_id, promotion_status, cust_id) values ('PM025', 'No', 'CT025');
insert into Promotion (promotion_id, promotion_status, cust_id) values ('PM026', 'Yes', 'CT026');
insert into Promotion (promotion_id, promotion_status, cust_id) values ('PM027', 'Yes', 'CT027');
insert into Promotion (promotion_id, promotion_status, cust_id) values ('PM028', 'No', 'CT028');
insert into Promotion (promotion_id, promotion_status, cust_id) values ('PM029', 'No', 'CT029');
insert into Promotion (promotion_id, promotion_status, cust_id) values ('PM030', 'No', 'CT030');
insert into Promotion (promotion_id, promotion_status, cust_id) values ('PM031', 'Yes', 'CT031');
insert into Promotion (promotion_id, promotion_status, cust_id) values ('PM032', 'No', 'CT032');
insert into Promotion (promotion_id, promotion_status, cust_id) values ('PM033', 'Yes', 'CT033');
insert into Promotion (promotion_id, promotion_status, cust_id) values ('PM034', 'Yes', 'CT034');
insert into Promotion (promotion_id, promotion_status, cust_id) values ('PM035', 'Yes', 'CT035');
insert into Promotion (promotion_id, promotion_status, cust_id) values ('PM036', 'Yes', 'CT036');
insert into Promotion (promotion_id, promotion_status, cust_id) values ('PM037', 'Yes', 'CT037');
insert into Promotion (promotion_id, promotion_status, cust_id) values ('PM038', 'No', 'CT038');
insert into Promotion (promotion_id, promotion_status, cust_id) values ('PM039', 'No', 'CT039');
insert into Promotion (promotion_id, promotion_status, cust_id) values ('PM040', 'Yes', 'CT040');
insert into Promotion (promotion_id, promotion_status, cust_id) values ('PM041', 'No', 'CT041');
insert into Promotion (promotion_id, promotion_status, cust_id) values ('PM042', 'Yes', 'CT042');
insert into Promotion (promotion_id, promotion_status, cust_id) values ('PM043', 'Yes', 'CT043');
insert into Promotion (promotion_id, promotion_status, cust_id) values ('PM044', 'No', 'CT044');
insert into Promotion (promotion_id, promotion_status, cust_id) values ('PM045', 'Yes', 'CT045');
insert into Promotion (promotion_id, promotion_status, cust_id) values ('PM046', 'No', 'CT046');
insert into Promotion (promotion_id, promotion_status, cust_id) values ('PM047', 'Yes', 'CT047');
insert into Promotion (promotion_id, promotion_status, cust_id) values ('PM048', 'No', 'CT048');
insert into Promotion (promotion_id, promotion_status, cust_id) values ('PM049', 'No', 'CT049');
insert into Promotion (promotion_id, promotion_status, cust_id) values ('PM050', 'Yes', 'CT050');


insert into Adoption (adopt_id, adopt_date, adopt_status, cust_id, appli_id) values ('AD001', '30-May-2023', 'Approved', 'CT037', 'AP007');
insert into Adoption (adopt_id, adopt_date, adopt_status, cust_id, appli_id) values ('AD002', '21-Jun-2023', 'Pending', 'CT027', 'AP022');
insert into Adoption (adopt_id, adopt_date, delivery_fee, adopt_status, cust_id, appli_id) values ('AD003', '22-Nov-2023', 50, 'Approved', 'CT046', 'AP013');
insert into Adoption (adopt_id, adopt_date, delivery_fee, adopt_status, cust_id, appli_id) values ('AD004', '04-Aug-2023', 50, 'Approved', 'CT048', 'AP001');
insert into Adoption (adopt_id, adopt_date, adopt_status, cust_id, appli_id)  values ('AD005', '11-Oct-2023', 'Pending', 'CT028', 'AP029');
insert into Adoption (adopt_id, adopt_date, adopt_status, cust_id, appli_id) values ('AD006', '24-Aug-2023', 'Approved', 'CT024', 'AP019');
insert into Adoption (adopt_id, adopt_date, adopt_status, cust_id, appli_id)  values ('AD007', '05-May-2023', 'Pending', 'CT042', 'AP035');
insert into Adoption (adopt_id, adopt_date, delivery_fee, adopt_status, cust_id, appli_id) values ('AD008', '16-Nov-2023', 50, 'Approved', 'CT031', 'AP012');
insert into Adoption (adopt_id, adopt_date, adopt_status, cust_id, appli_id)  values ('AD009', '24-Mar-2023', 'Pending', 'CT033', 'AP027');
insert into Adoption (adopt_id, adopt_date, adopt_status, cust_id, appli_id) values ('AD010', '22-Oct-2023', 'Approved', 'CT043', 'AP005');
insert into Adoption (adopt_id, adopt_date, delivery_fee, adopt_status, cust_id, appli_id) values ('AD011', '08-Mar-2023', 50, 'Approved', 'CT016', 'AP023');
insert into Adoption (adopt_id, adopt_date, adopt_status, cust_id, appli_id) values ('AD012', '15-Oct-2023', 'Pending', 'CT033', 'AP028');
insert into Adoption (adopt_id, adopt_date, adopt_status, cust_id, appli_id) values ('AD013', '25-Sep-2023', 'Approved', 'CT007', 'AP032');
insert into Adoption (adopt_id, adopt_date, adopt_status, cust_id, appli_id)  values ('AD014', '16-Sep-2023', 'Pending', 'CT031', 'AP015');
insert into Adoption (adopt_id, adopt_date, adopt_status, cust_id, appli_id) values ('AD015', '20-Jul-2023', 'Pending', 'CT045', 'AP009');
insert into Adoption (adopt_id, adopt_date, adopt_status, cust_id, appli_id)  values ('AD016', '27-Feb-2023', 'Pending', 'CT026', 'AP007');
insert into Adoption (adopt_id, adopt_date, delivery_fee, adopt_status, cust_id, appli_id) values ('AD017', '24-Nov-2023', 50, 'Approved', 'CT031', 'AP022');
insert into Adoption (adopt_id, adopt_date, adopt_status, cust_id, appli_id) values ('AD018', '16-Jun-2023', 'Rejected', 'CT027', 'AP013');
insert into Adoption (adopt_id, adopt_date, delivery_fee, adopt_status, cust_id, appli_id) values ('AD019', '28-May-2023', 50, 'Approved', 'CT008', 'AP001');
insert into Adoption (adopt_id, adopt_date, adopt_status, cust_id, appli_id)  values ('AD020', '02-May-2023', 'Pending', 'CT012', 'AP029');
insert into Adoption (adopt_id, adopt_date, adopt_status, cust_id, appli_id) values ('AD021', '22-Nov-2023', 'Pending', 'CT034', 'AP019');
insert into Adoption (adopt_id, adopt_date, adopt_status, cust_id, appli_id) values ('AD022', '24-Aug-2023', 'Approved', 'CT020', 'AP035');
insert into Adoption (adopt_id, adopt_date, adopt_status, cust_id, appli_id) values ('AD023', '06-Oct-2023', 'Approved', 'CT028', 'AP012');
insert into Adoption (adopt_id, adopt_date, adopt_status, cust_id, appli_id)  values ('AD024', '11-Jan-2023', 'Approved', 'CT043', 'AP027');
insert into Adoption (adopt_id, adopt_date, delivery_fee, adopt_status, cust_id, appli_id) values ('AD025', '12-Feb-2023', 50, 'Approved', 'CT015', 'AP005');
insert into Adoption (adopt_id, adopt_date, adopt_status, cust_id, appli_id) values ('AD026', '19-Apr-2023', 'Pending', 'CT025', 'AP023');
insert into Adoption (adopt_id, adopt_date, adopt_status, cust_id, appli_id)  values ('AD027', '09-May-2023', 'Pending', 'CT008', 'AP028');
insert into Adoption (adopt_id, adopt_date, adopt_status, cust_id, appli_id)  values ('AD028', '08-Jun-2023', 'Pending', 'CT030', 'AP032');
insert into Adoption (adopt_id, adopt_date, adopt_status, cust_id, appli_id)  values ('AD029', '19-Jan-2023', 'Approved', 'CT013', 'AP015');
insert into Adoption (adopt_id, adopt_date, adopt_status, cust_id, appli_id)  values ('AD030', '27-Sep-2023', 'Pending', 'CT039', 'AP009');


insert into Payment (payment_id, payment_method, payment_date, payment_amount, promotion_id, cust_id, train_id) values ('PY001', 'TNG', '05-Mar-2023', 827, 'PM015', 'CT016', 'TN007');
insert into Payment (payment_id, payment_method, payment_date, payment_amount, promotion_id, cust_id, train_id) values ('PY002', 'E-Wallet', '12-Feb-2023', 776, 'PM015', 'CT028', 'TN009');
insert into Payment (payment_id, payment_method, payment_date, payment_amount, promotion_id, cust_id, train_id) values ('PY003', 'Online Banking', '27-Aug-2023', 916, 'PM001', 'CT005', 'TN006');
insert into Payment (payment_id, payment_method, payment_date, payment_amount, promotion_id, cust_id, train_id) values ('PY004', 'E-Wallet', '27-Nov-2023', 553, 'PM018', 'CT012', 'TN013');
insert into Payment (payment_id, payment_method, payment_date, payment_amount, promotion_id, cust_id, train_id) values ('PY005', 'TNG', '18-Jun-2023', 842, 'PM004', 'CT009', 'TN013');
insert into Payment (payment_id, payment_method, payment_date, payment_amount, promotion_id, cust_id, train_id) values ('PY006', 'Online Banking', '29-Jun-2023', 556, 'PM019', 'CT045', 'TN009');
insert into Payment (payment_id, payment_method, payment_date, payment_amount, promotion_id, cust_id, train_id) values ('PY007', 'TNG', '11-May-2023', 547, 'PM017', 'CT008', 'TN010');
insert into Payment (payment_id, payment_method, payment_date, payment_amount, promotion_id, cust_id, train_id) values ('PY008', 'TNG', '10-Aug-2023', 436, 'PM017', 'CT037', 'TN012');
insert into Payment (payment_id, payment_method, payment_date, payment_amount, promotion_id, cust_id, train_id) values ('PY009', 'TNG', '28-Mar-2023', 458, 'PM017', 'CT046', 'TN009');
insert into Payment (payment_id, payment_method, payment_date, payment_amount, promotion_id, cust_id, train_id) values ('PY010', 'TNG', '02-Apr-2023', 352, 'PM001', 'CT048', 'TN010');
insert into Payment (payment_id, payment_method, payment_date, payment_amount, promotion_id, cust_id, train_id) values ('PY011', 'E-Wallet', '22-May-2023', 389, 'PM004', 'CT024', 'TN006');
insert into Payment (payment_id, payment_method, payment_date, payment_amount, promotion_id, cust_id, train_id) values ('PY012', 'Online Banking', '26-Feb-2023', 487, 'PM003', 'CT031', 'TN010');
insert into Payment (payment_id, payment_method, payment_date, payment_amount, promotion_id, cust_id, train_id) values ('PY013', 'TNG', '13-Jan-2023', 919, 'PM001', 'CT043', 'TN010');
insert into Payment (payment_id, payment_method, payment_date, payment_amount, promotion_id, cust_id, train_id) values ('PY014', 'E-Wallet', '28-Mar-2023', 977, 'PM001', 'CT007', 'TN006');
insert into Payment (payment_id, payment_method, payment_date, payment_amount, promotion_id, cust_id, train_id) values ('PY015', 'E-Wallet', '11-Aug-2023', 217, 'PM014', 'CT020', 'TN012');
insert into Payment (payment_id, payment_method, payment_date, payment_amount, promotion_id, cust_id, train_id) values ('PY016', 'Online Banking', '20-Dec-2023', 883, 'PM004', 'CT015', 'TN004');
insert into Payment (payment_id, payment_method, payment_date, payment_amount, promotion_id, cust_id, train_id) values ('PY017', 'E-Wallet', '16-Aug-2023', 181, 'PM015', 'CT013', 'TN005');


UPDATE animal SET adopt_id = 'AD019' WHERE anm_id = 'AN001';
UPDATE animal SET adopt_id = 'AD005' WHERE anm_id = 'AN002';
UPDATE animal SET adopt_id = 'AD012' WHERE anm_id = 'AN003';
UPDATE animal SET adopt_id = 'AD003' WHERE anm_id = 'AN004';
UPDATE animal SET adopt_id = 'AD022' WHERE anm_id = 'AN005';
UPDATE animal SET adopt_id = 'AD008' WHERE anm_id = 'AN006';
UPDATE animal SET adopt_id = 'AD018' WHERE anm_id = 'AN007';
UPDATE animal SET adopt_id = 'AD009' WHERE anm_id = 'AN008';
UPDATE animal SET adopt_id = 'AD015' WHERE anm_id = 'AN009';
UPDATE animal SET adopt_id = 'AD002' WHERE anm_id = 'AN010';
UPDATE animal SET adopt_id = 'AD011' WHERE anm_id = 'AN011';
UPDATE animal SET adopt_id = 'AD023' WHERE anm_id = 'AN012';
UPDATE animal SET adopt_id = 'AD027' WHERE anm_id = 'AN013';
UPDATE animal SET adopt_id = 'AD006' WHERE anm_id = 'AN014';
UPDATE animal SET adopt_id = 'AD030' WHERE anm_id = 'AN015';
UPDATE animal SET adopt_id = 'AD013' WHERE anm_id = 'AN016';
UPDATE animal SET adopt_id = 'AD007' WHERE anm_id = 'AN017';
UPDATE animal SET adopt_id = 'AD001' WHERE anm_id = 'AN018';
UPDATE animal SET adopt_id = 'AD025' WHERE anm_id = 'AN019';
UPDATE animal SET adopt_id = 'AD004' WHERE anm_id = 'AN020';
UPDATE animal SET adopt_id = 'AD021' WHERE anm_id = 'AN021';
UPDATE animal SET adopt_id = 'AD029' WHERE anm_id = 'AN022';
UPDATE animal SET adopt_id = 'AD017' WHERE anm_id = 'AN023';
UPDATE animal SET adopt_id = 'AD020' WHERE anm_id = 'AN024';
UPDATE animal SET adopt_id = 'AD014' WHERE anm_id = 'AN025';
UPDATE animal SET adopt_id = 'AD016' WHERE anm_id = 'AN026';
UPDATE animal SET adopt_id = 'AD010' WHERE anm_id = 'AN027';
UPDATE animal SET adopt_id = 'AD026' WHERE anm_id = 'AN028';
UPDATE animal SET adopt_id = 'AD030' WHERE anm_id = 'AN029';
UPDATE animal SET adopt_id = 'AD018' WHERE anm_id = 'AN030';
UPDATE animal SET adopt_id = 'AD009' WHERE anm_id = 'AN031';
UPDATE animal SET adopt_id = 'AD002' WHERE anm_id = 'AN032';
UPDATE animal SET adopt_id = 'AD027' WHERE anm_id = 'AN033';
UPDATE animal SET adopt_id = 'AD022' WHERE anm_id = 'AN034';
UPDATE animal SET adopt_id = 'AD006' WHERE anm_id = 'AN035';
UPDATE animal SET adopt_id = 'AD011' WHERE anm_id = 'AN036';
UPDATE animal SET adopt_id = 'AD024' WHERE anm_id = 'AN037';
UPDATE animal SET adopt_id = 'AD015' WHERE anm_id = 'AN038';
UPDATE animal SET adopt_id = 'AD003' WHERE anm_id = 'AN039';
UPDATE animal SET adopt_id = 'AD012' WHERE anm_id = 'AN040';
UPDATE animal SET adopt_id = 'AD013' WHERE anm_id = 'AN041';
UPDATE animal SET adopt_id = 'AD007' WHERE anm_id = 'AN042';
UPDATE animal SET adopt_id = 'AD004' WHERE anm_id = 'AN043';
UPDATE animal SET adopt_id = 'AD025' WHERE anm_id = 'AN044';
UPDATE animal SET adopt_id = 'AD021' WHERE anm_id = 'AN045';
UPDATE animal SET adopt_id = 'AD020' WHERE anm_id = 'AN046';
UPDATE animal SET adopt_id = 'AD016' WHERE anm_id = 'AN047';
UPDATE animal SET adopt_id = 'AD005' WHERE anm_id = 'AN048';
UPDATE animal SET adopt_id = 'AD001' WHERE anm_id = 'AN049';
UPDATE animal SET adopt_id = 'AD017' WHERE anm_id = 'AN050';


UPDATE adoption SET payment_id = 'PY001' WHERE cust_id = 'CT016';
UPDATE adoption SET payment_id = 'PY002' WHERE cust_id = 'CT028';
UPDATE adoption SET payment_id = 'PY007' WHERE cust_id = 'CT008';
UPDATE adoption SET payment_id = 'PY008' WHERE cust_id = 'CT037';
UPDATE adoption SET payment_id = 'PY009' WHERE cust_id = 'CT046';
UPDATE adoption SET payment_id = 'PY010' WHERE cust_id = 'CT048';
UPDATE adoption SET payment_id = 'PY011' WHERE cust_id = 'CT024';
UPDATE adoption SET payment_id = 'PY012' WHERE cust_id = 'CT031';
UPDATE adoption SET payment_id = 'PY013' WHERE cust_id = 'CT043';
UPDATE adoption SET payment_id = 'PY014' WHERE cust_id = 'CT007';
UPDATE adoption SET payment_id = 'PY015' WHERE cust_id = 'CT020';
UPDATE adoption SET payment_id = 'PY016' WHERE cust_id = 'CT015';
UPDATE adoption SET payment_id = 'PY017' WHERE cust_id = 'CT013';

UPDATE adoption SET adopt_fee = 1300 WHERE adopt_id = 'AD001';
UPDATE adoption SET adopt_fee = 750 WHERE adopt_id = 'AD003';
UPDATE adoption SET adopt_fee = 660 WHERE adopt_id = 'AD004';
UPDATE adoption SET adopt_fee = 50 WHERE adopt_id = 'AD006';
UPDATE adoption SET adopt_fee = 0 WHERE adopt_id = 'AD008';
UPDATE adoption SET adopt_fee = 600 WHERE adopt_id = 'AD010';
UPDATE adoption SET adopt_fee = 0 WHERE adopt_id = 'AD011';
UPDATE adoption SET adopt_fee = 300 WHERE adopt_id = 'AD013';
UPDATE adoption SET adopt_fee = 600 WHERE adopt_id = 'AD017';
UPDATE adoption SET adopt_fee = 500 WHERE adopt_id = 'AD019';
UPDATE adoption SET adopt_fee = 1250 WHERE adopt_id = 'AD022';
UPDATE adoption SET adopt_fee = 300 WHERE adopt_id = 'AD023';
UPDATE adoption SET adopt_fee = 300 WHERE adopt_id = 'AD024';
UPDATE adoption SET adopt_fee = 1710 WHERE adopt_id = 'AD025';
UPDATE adoption SET adopt_fee = 100 WHERE adopt_id = 'AD029';


UPDATE promotion SET adopt_id = 'AD013' WHERE cust_id = 'CT007';
UPDATE promotion SET adopt_id = 'AD019' WHERE cust_id = 'CT008';
UPDATE promotion SET adopt_id = 'AD029' WHERE cust_id = 'CT013';
UPDATE promotion SET adopt_id = 'AD025' WHERE cust_id = 'CT015';
UPDATE promotion SET adopt_id = 'AD011' WHERE cust_id = 'CT016';
UPDATE promotion SET adopt_id = 'AD022' WHERE cust_id = 'CT020';
UPDATE promotion SET adopt_id = 'AD006' WHERE cust_id = 'CT024';
UPDATE promotion SET adopt_id = 'AD023' WHERE cust_id = 'CT028';
UPDATE promotion SET adopt_id = 'AD008' WHERE cust_id = 'CT031';
UPDATE promotion SET adopt_id = 'AD017' WHERE cust_id = 'CT031';
UPDATE promotion SET adopt_id = 'AD001' WHERE cust_id = 'CT037';
UPDATE promotion SET adopt_id = 'AD010' WHERE cust_id = 'CT043';
UPDATE promotion SET adopt_id = 'AD024' WHERE cust_id = 'CT043';
UPDATE promotion SET adopt_id = 'AD003' WHERE cust_id = 'CT046';
UPDATE promotion SET adopt_id = 'AD004' WHERE cust_id = 'CT048';

