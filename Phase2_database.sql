-- CS4400: Introduction to Database Systems: October 31, 2023
-- Simple Airline Management System Course Project Database

/* This is a standard preamble for most of our scripts.  The intent is to establish
a consistent environment for the database behavior. */
set global transaction isolation level serializable;
set global SQL_MODE = 'ANSI,TRADITIONAL';
set names utf8mb4;
set SQL_SAFE_UPDATES = 0;

set @thisDatabase = 'flight_tracking';
drop database if exists flight_tracking;
create database if not exists flight_tracking;
use flight_tracking;

-- Team #71: Meghna Godbole, Savrina Salartash, Snigdha Vettrivelou, Nicole Huang

-- Define the database structures
/* You must enter your tables definitions, along with your primary, unique and foreign key
declarations, and data insertion statements here.  You may sequence them in any order that
works for you.  When executed, your statements must create a functional database that contains
all of the data, and supports as many of the constraints as reasonably possible. */

-- table structure for table airline
DROP TABLE IF EXISTS airline;
CREATE TABLE airline (
	airlineID varchar(30) NOT NULL,
	revenue decimal(5, 0) NOT NULL,
	PRIMARY KEY (airlineID)
) ENGINE = InnoDB;

-- inserting data into table airline
INSERT INTO airline VALUES
	('Delta',53000),
	('United',48000),
	('British Airways',24000),
	('Lufthansa',35000),
	('Air_France',29000),
	('KLM',29000),
	('Ryanair',10000),
	('Japan Airlines',9000),
	('China Southern Airlines',14000),
	('Korean Air Lines',10000),
	('American',52000);

-- table structure for table route
DROP TABLE IF EXISTS route;
CREATE TABLE route (
	routeID varchar(25) NOT NULL,
	PRIMARY KEY (routeID)
) ENGINE = InnoDB;

-- inserting data into table route
INSERT INTO route VALUES
	('americas_hub_exchange'),
	('americas_one'),
	('americas_two'),
	('americas_three'),
	('big_europe_loop'),
	('euro_north'),
	('euro_south'),
	('germany_local'),
	('pacific_rim_tour'),
	('south_euro_loop'),
	('texas_local');

-- table structure for table location
DROP TABLE IF EXISTS location;
CREATE TABLE location (
	locationID varchar(10) NOT NULL,
    primary key (locationID)
) ENGINE =InnoDB;

-- insert data into table location
INSERT INTO location VALUES
	('port_1'),
    ('port_2'),
    ('port_3'),
    ('port_10'),
    ('port_17'),
    ('plane_1'),
    ('plane_5'),
    ('plane_8'),
    ('plane_13'),
    ('plane_20'),
    ('port_12'),
    ('port_14'),
    ('port_15'),
    ('port_20'),
    ('port_4'),
    ('port_16'),
    ('port_11'),
    ('port_23'),
    ('port_7'),
    ('port_6'),
    ('port_13'),
    ('port_21'),
    ('port_18'),
    ('port_22'),
    ('plane_6'),
    ('plane_18'),
    ('plane_7');

-- table structure for table flight
DROP TABLE IF EXISTS flight;
CREATE TABLE flight (
	flightID varchar(5) NOT NULL,
	cost decimal(3, 0) NOT NULL,
	follows_real char(21) NOT NULL,
	PRIMARY KEY (flightID),
	CONSTRAINT fk1 FOREIGN KEY (follows_real) REFERENCES  route (routeID)
) ENGINE = InnoDB;

-- inserting data into table flight
INSERT INTO flight VALUES
	('dl_10', 200, 'americas_one'),
	('un_38', 200, 'americas_three'),
	('ba_61', 200, 'americas_two'),
	('lf_20', 300, 'euro_north'),
	('km_16', 400, 'euro_south'),
	('ba_51', 100, 'big_europe_loop'),
	('ja_35', 300, 'pacific_rim_tour'),
	('ry_34', 100, 'germany_local');

-- table structure for table airport
DROP TABLE IF EXISTS airport;
CREATE TABLE airport (
	airportID varchar(3) NOT NULL,
    airport_name varchar(50) NOT NULL,
    city varchar(20) NOT NULL,
    state varchar(20) NOT NULL,
    country_code varchar(3) NOT NULL,
    locationID varchar(8),
    PRIMARY KEY (airportID),
    CONSTRAINT fk2 FOREIGN KEY (locationID) REFERENCES location (locationID)
) ENGINE = innodb;

-- inserting data into table airport
INSERT INTO airport VALUES
	('ATL', 'Atlanta Hartsfield_Jackson International', 'Atlanta', 'Georgia', 'USA', 'port_1'),
	('DXB', 'Dubai International', 'Dubai', 'Al Garhoud', 'UAE', 'port_2'),
	('HND', 'Tokyo International Haneda', 'Ota City', 'Tokyo', 'JPN', 'port_3'),
	('LHR', 'London Heathrow', 'London', 'England', 'GBR', 'port_4'),
	('IST', 'Istanbul International', 'Arnavutkoy', 'Istanbul', 'TUR', null),
	('DFW', 'Dallas_Fort Worth International', 'Dallas', 'Texas', 'USA', 'port_6'),
	('CAN', 'Guangzhou International', 'Guangzhou', 'Guangdong', 'CHN', 'port_7'),
	('DEN', 'Denver International', 'Denver', 'Colorado', 'USA', null),
	('LAX', 'Los Angeles International', 'Los Angeles', 'California', 'USA', null),
	('ORD', 'O_Hare International', 'Chicago', 'Illinois', 'USA', 'port_10'),
	('AMS', 'Amsterdam Schipol International', 'Amsterdam', 'Haarlemmermeer', 'NLD', 'port_11'),
	('CDG', 'Paris Charles de Gaulle', 'Roissy_en_France', 'Paris', 'FRA', 'port_12'),
	('FRA', 'Frankfurt International', 'Frankfurt', 'Frankfurt_Rhine_Main', 'DEU', 'port_13'),
	('MAD', 'Madrid Adolfo Suarez_Barajas', 'Madrid', 'Barajas', 'ESP', 'port_14'),
	('BCN', 'Barcelona International', 'Barcelona', 'Catalonia', 'ESP', 'port_15'),
	('FCO', 'Rome Fiumicino', 'Fiumicino', 'Lazio', 'ITA', 'port_16'),
	('LGW', 'London Gatwick', 'London', 'England', 'GBR', 'port_17'),
	('MUC', 'Munich International', 'Munich', 'Bavaria', 'DEU', 'port_18'),
	('MDW', 'Chicago Midway International', 'Chicago', 'Illinois', 'USA', null),
	('IAH', 'George Bush Intercontinental', 'Houston', 'Texas', 'USA', 'port_20'),
	('HOU', 'William P_Hobby International', 'Houston', 'Texas', 'USA', 'port_21'),
	('NRT', 'Narita International', 'Narita', 'Chiba', 'JPN', 'port_22'),
	('BER', 'Berlin Brandenburg Willy Brandt International', 'Berlin', 'Schonefeld', 'DEU', 'port_23');

-- table structure for table leg
DROP TABLE IF EXISTS leg;
CREATE TABLE leg (
	legID varchar(6) NOT NULL,
	distance char(5) NOT NULL,
	departs char(3) NOT NULL,
	arrives char(3) NOT NULL,
	PRIMARY KEY (legID),
	CONSTRAINT fk3 FOREIGN KEY (departs) REFERENCES  airport (airportID),
	CONSTRAINT fk4 FOREIGN KEY (arrives) REFERENCES  airport (airportID)
) ENGINE = InnoDB;

-- inserting data into table leg
INSERT INTO leg VALUES
	('leg_1', 400, 'AMS', 'BER'),
	('leg_10', 1600, 'CAN', 'HND'),
	('leg_11', 500, 'CDG', 'BCN'),
	('leg_12', 600, 'CDG', 'FCO'),
	('leg_13', 200, 'CDG', 'LHR'),
	('leg_14', 400, 'CDG', 'MUC'),
	('leg_15', 200, 'DFW', 'IAH'),
	('leg_16', 800, 'FCO', 'MAD'),
	('leg_17', 300, 'FRA', 'BER'),
	('leg_18', 100, 'HND', 'NRT'),
	('leg_19', 300, 'HOU', 'DFW'),
	('leg_2' , 3900, 'ATL', 'AMS'),
	('leg_20', 100, 'IAH', 'HOU'),
	('leg_21', 600, 'LGW', 'BER'),
	('leg_22', 600, 'LHR', 'BER'),
	('leg_23', 500, 'LHR', 'MUC'),
	('leg_24', 300, 'MAD', 'BCN'),
	('leg_25', 600, 'MAD', 'CDG'),
	('leg_26', 800, 'MAD', 'FCO'),
	('leg_27', 300, 'MUC', 'BER'),
	('leg_28', 400, 'MUC', 'CDG'),
	('leg_29', 400, 'MUC', 'FCO'),
	('leg_3', 3700,	'ATL', 'LHR'),
	('leg_30', 200, 'MUC', 'FRA'),
	('leg_31', 3700, 'ORD', 'CDG'),
	('leg_4', 600, 'ATL', 'ORD'),
	('leg_5', 500, 'BCN', 'CDG'),
	('leg_6', 300, 'BCN', 'MAD'),
	('leg_7', 4700, 'BER', 'CAN'),
	('leg_8', 600, 'BER', 'LGW'),
	('leg_9', 300, 'BER', 'MUC');

-- table structure for table airplane
DROP TABLE IF EXISTS airplane;
CREATE TABLE airplane (
	tailnum varchar(6) NOT NULL,
    seat_cap integer NOT NULL,
    speed integer NOT NULL,
    owner_real varchar(25) NOT NULL,
    locationID varchar(8),
    progress integer,
	flight_status varchar(9),
    next_time varchar(9),
    supports varchar(6),
    PRIMARY KEY (tailnum, owner_real),
    CONSTRAINT fk5 FOREIGN KEY (owner_real) REFERENCES airline (airlineID),
	CONSTRAINT fk6 FOREIGN KEY (locationID) REFERENCES location (locationID),
    CONSTRAINT fk7 FOREIGN KEY (supports) REFERENCES flight (flightID)
) ENGINE = innodb;

-- insert data into table airplane
INSERT INTO airplane VALUES
	('n106js', 4, 800, 'Delta','plane_1', 1, 'in_flight', '08:00:00', 'dl_10'),
	('n110jn', 5, 800, 'Delta', null, null, null, null, null),
	('n127js', 4, 600, 'Delta', null, null, null, null, null),
	('n330ss', 4, 800, 'United', null, null, null, null, null),
	('n380sd', 5, 400, 'United', 'plane_5', 2, 'in_flight', '14;30:00', 'un_38'),
	('n616lt', 7, 600, 'British Airways', 'plane_6', 0, 'on_ground', '09:30:00', 'ba_61'),
	('n517ly', 4, 600, 'British Airways', 'plane_7', 0, 'on_ground', '11:30:00', 'ba_51'),
	('n620la', 4, 800, 'Lufthansa', 'plane_8', 3, 'in_flight', '11:00:00', 'lf_20'),
	('n401fj', 4, 300, 'Lufthansa', null, null, null, null, null),
	('n653fk', 6, 600, 'Lufthansa', null, null, null, null, null),
	('n118fm', 4, 400, 'Air_France', null, null, null, null, null),
	('n815pw', 3, 400, 'Air_France', null, null, null, null, null),
	('n161fk', 4, 600, 'KLM', 'plane_13', 6, 'in_flight', '14:00:00', 'km_16'),
	('n337as', 5, 400, 'KLM', null, null, null, null, null),
	('n256ap', 4, 300, 'KLM', null, null, null, null, null),
	('n156sq', 8, 600, 'Ryanair', null, null, null, null, null),
	('n451fi', 5, 600, 'Ryanair', null, null, null, null, null),
	('n341eb', 4, 400, 'Ryanair', 'plane_18', 0, 'on_ground', '15:00:00', 'ry_34'),
	('n353kz', 4, 400, 'Ryanair', null, null, null, null, null),
	('n305fv', 6, 400, 'Japan Airlines', 'plane_20', 1, 'in_flight', '09:30:00', 'ja_35'),
	('n443wu', 4, 800, 'Japan Airlines', null, null, null, null, null),
	('n454gq', 3, 400, 'China Southern Airlines', null, null, null, null, null),
	('n249yk', 4, 400, 'China Southern Airlines', null, null, null, null, null),
	('n180co', 5, 600, 'Korean Air Lines', null, null, null, null, null),
	('n448cs', 4, 400, 'American', null, null, null, null, null),
	('n225sb', 8, 800, 'American', null, null, null, null, null),
	('n553qn', 5, 800, 'American', null, null, null, null, null);

-- table structure for table prop
DROP TABLE IF EXISTS prop;
CREATE TABLE prop (
	props integer NOT NULL,
    skids bool NOT NULL,
    tailnum varchar(6) NOT NULL,
    owner_real varchar(25) NOT NULL,
    PRIMARY KEY (tailnum, owner_real),
    CONSTRAINT fk8 FOREIGN KEY (tailnum, owner_real) REFERENCES airplane (tailnum, owner_real)
) ENGINE = innodb;

-- inserting data into table prop
INSERT INTO prop VALUES
	(2, FALSE, 'n118fm', 'Air_France'),
	(2, FALSE, 'n256ap', 'KLM'),
	(2, TRUE, 'n341eb', 'Ryanair'),
	(2, TRUE, 'n353kz', 'Ryanair'),
	(2, FALSE, 'n249yk', 'China Southern Airlines'),
	(2, TRUE, 'n448cs', 'American');

-- table structure for table jet
DROP TABLE IF EXISTS jet;
CREATE TABLE jet (
	numengines integer NOT NULL,
    tailnum varchar(6) NOT NULL,
    owner_real varchar(25) NOT NULL,
    PRIMARY KEY (tailnum, owner_real),
    CONSTRAINT fk9 FOREIGN KEY (tailnum, owner_real) REFERENCES airplane (tailnum, owner_real)
) ENGINE = innodb;

-- inserting data into table jet
INSERT INTO jet VALUES
	(2, 'n106js', 'Delta'),
	(2, 'n110jn', 'Delta'),
	(4, 'n127js', 'Delta'),
	(2, 'n330ss', 'United'),
	(2, 'n380sd', 'United'),
	(2, 'n616lt', 'British Airways'),
	(2, 'n517ly', 'British Airways'),
	(4, 'n620la', 'Lufthansa'),
	(2, 'n653fk', 'Lufthansa'),
	(2, 'n815pw', 'Air_France'),
	(4, 'n161fk', 'KLM'),
	(2, 'n337as', 'KLM'),
	(2, 'n156sq', 'Ryanair'),
	(4, 'n451fi', 'Ryanair'),
	(2, 'n305fv', 'Japan Airlines'),
	(4, 'n443wu', 'Japan Airlines'),
	(2, 'n180co', 'Korean Air Lines'),
	(2, 'n225sb', 'American'),
	(2, 'n553qn', 'American');

-- table structure for table person
DROP TABLE IF EXISTS person;
CREATE TABLE person (
	personID varchar(3) NOT NULL,
    first_name varchar(100) NOT NULL,
    last_name varchar(100),
    occupies varchar(8) NOT NULL,
    PRIMARY KEY (personID),
    CONSTRAINT fk10 FOREIGN KEY (occupies) REFERENCES location (locationID)
) ENGINE = innodb;

-- inserting data into table person
INSERT INTO person VALUES
	('p1','Jeanne','Nelson','port_1'),
	('p10','Lawrence','Morgan','port_3'),
	('p11','Sandra','Cruz','port_3'),
	('p12','Dan','Ball','port_3'),
	('p13','Bryant','Figueroa','port_3'),
	('p14','Dana','Perry','port_3'),
	('p15','Matt','Hunt','port_10'),
	('p16','Edna','Brown','port_10'),
	('p17','Ruby','Burgess','port_10'),
	('p18','Esther','Pittman','port_10'),
	('p19','Doug','Fowler','port_17'),
	('p2','Roxanne','Byrd','port_1'),
	('p20','Thomas','Olson','port_17'),
	('p21','Mona','Harrison','plane_1'),
	('p22','Arlene','Massey','plane_1'),
	('p23','Judith','Patrick','plane_1'),
	('p24','Reginald','Rhodes','plane_5'),
	('p25','Vincent','Garcia','plane_5'),
	('p26','Cheryl','Moore','plane_5'),
	('p27','Michael','Rivera','plane_8'),
	('p28','Luther','Matthews','plane_8'),
	('p29','Moses','Parks','plane_13'),
	('p3','Tanya','Nguyen','port_1'),
	('p30','Ora','Steele','plane_13'),
	('p31','Antonio','Flores','plane_13'),
	('p32','Glenn','Ross','plane_13'),
	('p33','Irma','Thomas','plane_20'),
	('p34','Ann','Maldonado','plane_20'),
	('p35','Jeffrey','Cruz','port_12'),
	('p36','Sonya','Price','port_12'),
	('p37','Tracy','Hale','port_12'),
	('p38','Albert','Simmons','port_14'),
	('p39','Karen','Terry','port_15'),
	('p4','Kendra','Jacobs','port_1'),
	('p40','Glen','Kelley','port_20'),
	('p41','Brooke','Little','port_3'),
	('p42','Daryl','Nguyen','port_4'),
	('p43','Judy','Willis','port_14'),
	('p44','Marco','Klein','port_15'),
	('p45','Angelica','Hampton','port_16'),
	('p5','Jeff','Burton','port_1'),
	('p6','Randal','Parks','port_1'),
	('p7','Sonya','Owens','port_2'),
	('p8','Bennie','Palmer','port_2'),
	('p9','Marlene','Warner','port_3');

-- table structure for table pilot
DROP TABLE IF EXISTS pilot;
CREATE TABLE pilot (
	personID varchar(3) NOT NULL,
    taxID varchar(11) NOT NULL,
    experience integer NOT NULL,
    commands varchar(5),
    PRIMARY KEY (personID, taxID),
    CONSTRAINT fk11 FOREIGN KEY (personID) REFERENCES person (personID),
    CONSTRAINT fk12 FOREIGN KEY (commands) REFERENCES flight (flightID)
) ENGINE = innodb;

-- inserting data into table pilot
insert into pilot values
	('p1', '330-12-6907','31','dl_10'),
	('p10','769-60-1266','15','lf_20'),
	('p11','369-22-9505','22','km_16'),
	('p12','680-92-5329','24','ry_34'),
	('p13','513-40-4168','24','km_16'),
	('p14','454-71-7847','13','km_16'),
	('p15','153-47-8101','30','ja_35'),
	('p16','598-47-5172','28','ja_35'),
	('p17','865-71-6800','36', null),
	('p18','250-86-2784','23', null),
	('p19','386-39-7881','2', null),
	('p2','842-88-1257','9','dl_10'),
	('p20','522-44-3098','28', null),
	('p3','750-24-7616','11','un_38'),
	('p4','776-21-8098','24','un_38'),
	('p5','933-93-2165','27','ba_61'),
	('p6','707-84-4555','38','ba_61'),
	('p7','450-25-5617','13','lf_20'),
	('p8','701-38-2179','12','ry_34'),
	('p9','936-44-6941','13','lf_20');

-- table structure for table passenger
DROP TABLE IF EXISTS passenger;
CREATE TABLE passenger (
	personID varchar(3) NOT NULL,
    miles integer NOT NULL,
    funds integer NOT NULL,
    PRIMARY KEY (personID),
    CONSTRAINT fk13 FOREIGN KEY (personID) REFERENCES person (personID)
) ENGINE = innodb;

-- inserting data into table passenger
INSERT INTO passenger VALUES
	('p21','771','700'),
	('p22','374','200'),
	('p23','414','400'),
	('p24','292','500'),
	('p25','390','300'),
	('p26','302','600'),
	('p27','470','400'),
	('p28','208','400'),
	('p29','292','700'),
	('p30','686','500'),
	('p31','547','400'),
	('p32','257','500'),
	('p33','564','600'),
	('p34','211','200'),
	('p35','233','500'),
	('p36','293','400'),
	('p37','552','700'),
	('p38','812','700'),
	('p39','541','400'),
	('p40','441','700'),
	('p41','875','300'),
	('p42','691','500'),
	('p43','572','300'),
	('p44','572','500'),
	('p45','663','500');

-- table structure for table license
DROP TABLE IF EXISTS license;
CREATE TABLE license (
	personID varchar(3) NOT NULL,
    taxID varchar(11) NOT NULL,
    license_types varchar(20) NOT NULL,
    PRIMARY KEY (personID, taxID, license_types),
    CONSTRAINT fk14 FOREIGN KEY (personID, taxID) REFERENCES pilot (personID, taxID)
) ENGINE = innodb;

-- inserting data into table license
INSERT INTO license VALUES
	('p1','330-12-6907','jets'),
	('p10','769-60-1266','jets'),
	('p11','369-22-9505','jets, props'),
	('p12','680-92-5329','props'),
	('p13','513-40-4168','jets'),
	('p14','454-71-7847','jets'),
	('p15','153-47-8101','jets, props, testing'),
	('p16','598-47-5172','jets'),
	('p17','865-71-6800','jets, props'),
	('p18','250-86-2784','jets'),
	('p19','386-39-7881','jets'),
	('p2','842-88-1257','jets, props'),
	('p20','522-44-3098','jets'),
	('p3','750-24-7616','jets'),
	('p4','776-21-8098','jets, props'),
	('p5','933-93-2165','jets'),
	('p6','707-84-4555','jets, props'),
	('p7','450-25-5617','jets'),
	('p8','701-38-2179','props'),
	('p9','936-44-6941','jets, props, testing');

-- table structure for table vacation
DROP TABLE IF EXISTS vacation;
CREATE TABLE vacation (
	personID varchar(5) NOT NULL,
    destination char(3) NOT NULL,
    sequence decimal(1,0) NOT NULL,
    PRIMARY KEY (personID, destination, sequence),
    CONSTRAINT fk15 FOREIGN KEY (personID) REFERENCES passenger (personID)
) ENGINE =InnoDB;

-- inserting data into table vacation
INSERT INTO vacation VALUES
	('p21','AMS',1),
    ('p22','AMS',1),
    ('p23','BER',1),
    ('p24','MUC',1),
    ('p24','CDG',2),
    ('p25','MUC',1),
    ('p26','MUC',1),
    ('p27','BER',1),
    ('p28','LGW',1),
    ('p29','FCO',1),
    ('p29','LHR',2),
    ('p30','FCO',1),
    ('p30','MAD',2),
    ('p31','FCO',1),
    ('p32','FCO',1),
    ('p33','CAN',1),
    ('p34','HND',1),
    ('p35','LGW',1),
    ('p36','FCO',1),
    ('p37','FCO',1),
    ('p37','LGW',2),
    ('p37','CDG',3),
    ('p38','MUC',1),
    ('p39','MUC',1),
    ('p40','HND',1);
    
-- table structure for table containing
DROP TABLE IF EXISTS containing;
CREATE TABLE containing (
	routeID varchar(30) NOT NULL,
    legID char(6) NOT NULL,
    sequence decimal(1,0) NOT NULL,
    PRIMARY KEY (routeID, legID, sequence),
    CONSTRAINT fk16 FOREIGN KEY (routeID) REFERENCES route (routeID),
    CONSTRAINT fk17 FOREIGN KEY (legID) REFERENCES leg (legID)
) engine=InnoDB;

-- inserting data into table containing
INSERT INTO containing VALUES
	('americas_hub_exchange','leg_4',1),
    ('americas_one','leg_2',1),
    ('americas_one','leg_1',2),
    ('americas_three','leg_31',1),
    ('americas_three','leg_14',2),
    ('americas_two','leg_3',1),
    ('americas_two','leg_22',2),
    ('big_europe_loop','leg_23',1),
    ('big_europe_loop','leg_29',2),
    ('big_europe_loop','leg_16',3),
    ('big_europe_loop','leg_25',4),
    ('big_europe_loop','leg_13',5),
    ('euro_north','leg_16',1),
    ('euro_north','leg_24',2),
    ('euro_north','leg_5',3),
    ('euro_north','leg_14',4),
    ('euro_north','leg_27',5),
    ('euro_north','leg_8',6),
    ('euro_south','leg_21',1),
    ('euro_south','leg_9',2),
    ('euro_south','leg_28',3),
    ('euro_south','leg_11',4),
    ('euro_south','leg_6',5),
    ('euro_south','leg_26',6),
    ('germany_local','leg_9',1),
    ('germany_local','leg_30',2),
    ('germany_local','leg_17',3),
    ('pacific_rim_tour','leg_7',1),
    ('pacific_rim_tour','leg_10',2),
    ('pacific_rim_tour','leg_18',3),
    ('south_euro_loop','leg_16',1),
    ('south_euro_loop','leg_24',2),
    ('south_euro_loop','leg_5',3),
    ('south_euro_loop','leg_12',4),
    ('texas_local','leg_16',1),
    ('texas_local','leg_24',2),
    ('texas_local','leg_5',3),
    ('texas_local','leg_12',4);