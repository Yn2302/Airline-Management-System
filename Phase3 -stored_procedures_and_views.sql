-- CS4400: Introduction to Database Systems: Tuesday, September 12, 2023
-- Simple Airline Management System Course Project Mechanics [TEMPLATE] (v0)
-- Views, Functions & Stored Procedures
-- Savrina Salartash, Meghna Godbole, Nicole Huang, Snigdha Vettrivelou
-- Group 71
/* This is a standard preamble for most of our scripts. The intent is to establish
a consistent environment for the database behavior. */
set global transaction isolation level serializable;
set global SQL_MODE = 'ANSI,TRADITIONAL';
set names utf8mb4;
set SQL_SAFE_UPDATES = 0;
set @thisDatabase = 'flight_tracking';
use flight_tracking;
-- -----------------------------------------------------------------------------
-- stored procedures and views
-- -----------------------------------------------------------------------------
/* Standard Procedure: If one or more of the necessary conditions for a procedure
to be executed is false, then simply have the procedure halt execution without
changing the database state. Do NOT display any error messages, etc. */
-- [_] supporting functions, views and stored procedures
-- -----------------------------------------------------------------------------
/* Helpful library capabilities to simplify the implementation of the required
views and procedures. */
-- -----------------------------------------------------------------------------
drop function if exists leg_time;
delimiter //
create function leg_time (ip_distance integer, ip_speed integer)
returns time reads sql data
begin
declare total_time decimal(10,2);
declare hours, minutes integer default 0;
set total_time = ip_distance / ip_speed;
set hours = truncate(total_time, 0);
set minutes = truncate((total_time - hours) * 60, 0);
return maketime(hours, minutes, 0);
end //
delimiter ;
-- [1] add_airplane()
-- -----------------------------------------------------------------------------
/* This stored procedure creates a new airplane. A new airplane must be sponsored
by an existing airline, and must have a unique tail number for that airline.
username. An airplane must also have a non-zero seat capacity and speed. An
airplane might also have other factors depending on it's type, like skids or some number
of engines. Finally, an airplane must have a new and database-wide unique location
since it will be used to carry passengers. */
-- -----------------------------------------------------------------------------

drop procedure if exists add_airplane;
delimiter //
create procedure add_airplane (in ip_airlineID varchar(50), in ip_tail_num varchar(50),
	in ip_seat_capacity integer, in ip_speed integer, in ip_locationID varchar(50),
    in ip_plane_type varchar(100), in ip_skids boolean, in ip_propellers integer,
    in ip_jet_engines integer)
sp_main: begin
	declare airline_exists int;
    declare tail_num_exists int;
    declare location_exists int;
    
    -- check if the airline exists
    select count(*) into airline_exists from airline where airlineID = ip_airlineID;
    if airline_exists = 0 then leave sp_main; end if;
    
    -- check if tail number is unique for the airline
    select count(*) into tail_num_exists from airplane where airlineID = ip_airlineID and tail_num = ip_tail_num;
    if tail_num_exists > 0 then leave sp_main; end if;
    
    -- check that the plane has non-zero seat capacity + speed
    if ip_seat_capacity <= 0 or ip_speed <= 0 then leave sp_main; end if;
    
    -- check unique location (locationID must be new + unique to this entity, an airplane)
    select count(*) into location_exists from location where locationID = ip_locationID;
    if location_exists > 0 then 
		leave sp_main;
	else
		-- insert the new location into location table if it doesn't exist
        insert into location (locationID) values (ip_locationID);
	end if;
    
    insert into airplane (airlineID, tail_num, seat_capacity, speed, locationID, plane_type, skids, propellers, jet_engines)
	values (ip_airlineID, ip_tail_num, ip_seat_capacity, ip_speed, ip_locationID, ip_plane_type, ip_skids, ip_propellers, ip_jet_engines);
    
end //
delimiter ;

-- [2] add_airport()
-- -----------------------------------------------------------------------------
/* This stored procedure creates a new airport. A new airport must have a unique
identifier along with a new and database-wide unique location if it will be used
to support airplane takeoffs and landings. An airport may have a longer, more
descriptive name. An airport must also have a city, state, and country
designation. */
-- -----------------------------------------------------------------------------

drop procedure if exists add_airport;
delimiter //
create procedure add_airport (in ip_airportID char(3), in ip_airport_name varchar(200),
    in ip_city varchar(100), in ip_state varchar(100), in ip_country char(3), in ip_locationID varchar(50))
sp_main: begin
	declare airportID_exists int;
    declare location_exists int;
    
    -- check that airportID does not already exist
    select count(*) into airportID_exists from airport where airportID = ip_airportID;
    if airportID_exists > 0 then leave sp_main; end if;
    
    -- check unique location (locationID must be new + unique to this entity, an airport)
    select count(*) into location_exists from location where locationID = ip_locationID;
    if location_exists > 0 then
		leave sp_main;
	else
		-- insert the new location into the location table if it doesn't exist
        insert into location (locationID) values (ip_locationID);
	end if;
    
    insert into airport (airportID, airport_name, city, state, country, locationID)
    values (ip_airportID, ip_airport_name, ip_city, ip_state, ip_country, ip_locationID);
    
end //
delimiter ;

-- [3] add_person()
-- -----------------------------------------------------------------------------
/* This stored procedure creates a new person. A new person must reference a
unique identifier along with a database-wide unique location used to determine where the
person is currently located: either at an airport, or on an airplane, at any given
time. A person must have a first name, and might also have a last name.
A person can hold a pilot role or a passenger role (exclusively). As a pilot,
a person must have a tax identifier to receive pay, and an experience level. As a
passenger, a person will have some amount of frequent flyer miles, along with a
certain amount of funds needed to purchase tickets for flights. */
-- -----------------------------------------------------------------------------

drop procedure if exists add_person;
delimiter //
create procedure add_person (in ip_personID varchar(50), in ip_first_name varchar(100),
    in ip_last_name varchar(100), in ip_locationID varchar(50), in ip_taxID varchar(50),
    in ip_experience integer, in ip_miles integer, in ip_funds integer)
sp_main: begin
	declare v_role varchar(10);
    declare personID_exists int;
    declare location_exists int;
    declare taxID_exists int;
    
    -- set variable role: passenger or pilot
    if ip_taxID is not null and ip_experience is not null then set v_role = 'pilot';
    elseif ip_miles is not null and ip_funds is not null then set v_role = 'passenger';
    else leave sp_main;
    end if;
    
    -- check that personID is unique
    select count(*) into personID_exists from person where personID = ip_personID;
    if personID_exists > 0 then leave sp_main; end if;
    
    -- check if location exists
    select count(*) into location_exists from location where locationID = ip_locationID;
    if location_exists = 0 then leave sp_main; end if;
    
    -- insert new person into person table
    insert into person (personID, first_name, last_name, locationID)
    values (ip_personID, ip_first_name, ip_last_name, ip_locationID);
    
    -- check that if pilot, taxID is unique
    if v_role = 'pilot' then
		select count(*) into taxID_exists from pilot where taxID = ip_taxID;
        if taxID_exists > 0 then leave sp_main; end if;
	end if;

    -- enter role-specific information (pilot or passenger)
    if v_role = 'pilot' then
		insert into pilot (personID, taxID, experience, commanding_flight)
		values (ip_personID, ip_taxID, ip_experience, null);
    elseif v_role = 'passenger' then
		insert into passenger (personID, miles, funds) values (ip_personID, ip_miles, ip_funds);
	end if;
    
end //
delimiter ;

-- [4] grant_or_revoke_pilot_license()
-- -----------------------------------------------------------------------------
/* This stored procedure inverts the status of a pilot license. If the license
doesn't exist, it must be created; and, if it laready exists, then it must be
removed. */
-- -----------------------------------------------------------------------------

drop procedure if exists grant_or_revoke_pilot_license;
delimiter //
create procedure grant_or_revoke_pilot_license (in ip_personID varchar(50), in ip_license varchar(100))
sp_main: begin

	declare v_license_count int;
    
    -- check if the person has a license
    select count(*) into v_license_count
    from pilot_licenses
    where personID = ip_personID and license = ip_license;
    
    -- if the person has the license, remove it. if they do not, add it.
    if v_license_count > 0 then
		delete from pilot_licenses
        where personID = ip_personID and license = ip_license;
	else
		insert into pilot_licenses (personID, license)
        values (ip_personID, ip_license);
	end if;

end //
delimiter ;

-- [5] offer_flight()
-- -----------------------------------------------------------------------------
/* This stored procedure creates a new flight. The flight can be defined before
an airplane has been assigned for support, but it must have a valid route. And
the airplane, if designated, must not be in use by another flight. The flight
can be started at any valid location along the route except for the final stop,
and it will begin on the ground. You must also include when the flight will
takeoff along with its cost. */
-- -----------------------------------------------------------------------------

drop procedure if exists offer_flight;
delimiter //
create procedure offer_flight (in ip_flightID varchar(50), in ip_routeID varchar(50),
    in ip_support_airline varchar(50), in ip_support_tail varchar(50), in ip_progress integer,
    in ip_next_time time, in ip_cost integer)
sp_main: begin
	declare flightID_exists int;
    declare route_exists int;
    declare airplane_in_use int;
    declare max_sequence int;
    
    -- check that flightID does not already exist
    select count(*) into flightID_exists from flight where flightID = ip_flightID;
    if flightID_exists > 0 then leave sp_main; end if;
    
    -- check that routeID exists
    select count(*) into route_exists from route where routeID = ip_routeID;
    if route_exists = 0 then leave sp_main; end if;
    
    -- check if airplane is in use by another flight
    if ip_support_tail is not null and ip_support_airline is not null then 
		select count(*) into airplane_in_use from flight where support_airline = ip_support_airline
		and support_tail = ip_support_tail;
        if airplane_in_use > 0 then leave sp_main; end if;
	end if;
    
    -- flight can be started at any valid location along the route except for the final stop
    select max(sequence) into max_sequence from route_path where routeID = ip_routeID;
    if ip_progress < 0 or ip_progress >= max_sequence then leave sp_main; end if;
    
    -- ensure next_time and cost are not null
    if ip_next_time is null or ip_cost is null then leave sp_main; end if;
    
    -- hard-code on ground status when insert values !!!
    insert into flight (flightID, routeID, support_airline, support_tail, progress, airplane_status, next_time, cost)
    values (ip_flightID, ip_routeID, ip_support_airline, ip_support_tail, ip_progress, 'on_ground', ip_next_time, ip_cost);
    
end //
delimiter ;

-- [6] flight_landing()
-- -----------------------------------------------------------------------------
/* This stored procedure updates the state for a flight landing at the next airport
along it's route. The time for the flight should be moved one hour into the future
to allow for the flight to be checked, refueled, restocked, etc. for the next leg
of travel. Also, the pilots of the flight should receive increased experience, and
the passengers should have their frequent flyer miles updated. */
-- -----------------------------------------------------------------------------

drop procedure if exists flight_landing;
delimiter //
create procedure flight_landing (in ip_flightID varchar(50))
sp_main: begin

	declare is_flight_in_air int;
    declare pilot_experience_increase int;
    declare passenger_miles_update int;
    declare leg_distance int;

    -- check if flight is currently in the air
    select count(*)
    into is_flight_in_air
    from flight
    where flightID = ip_flightID and airplane_status = 'in_flight';
    if is_flight_in_air = 0 then leave sp_main; end if;

    -- if flight is in the air, update its state upon landing
	-- get the distance of the leg of the flight just completed
	select distance into leg_distance
	from leg
	where legID = (select legID from route_path as rp join flight as f on rp.routeID = f.routeID 
					where f.flightID = ip_flightID and rp.sequence = f.progress);

	-- increase the next_time value by 1 hour
	update flight
	set next_time = addtime(next_time, '01:00:00'),
		airplane_status = 'on_ground'
	where flightID = ip_flightID;

	-- create a temporary table to store the list of personIDs for pilots
	create temporary table temp_pilots as
		select personID
		from pilot
		where commanding_flight = ip_flightID;

	-- increase pilot experience for each pilot commanding the flight
	set pilot_experience_increase = 1;
	update pilot
	set experience = experience + pilot_experience_increase
	where personID in (select * from temp_pilots);

	-- drop the temporary table
	drop temporary table if exists temp_pilots;

	-- update frequent flyer miles for each passenger on the flight
	update passenger
	set miles = miles + leg_distance
	where personID in (
		select personID
		from (select * from flight join airplane on 
        flight.support_airline = airplane.airlineID and flight.support_tail = airplane.tail_num) as a
		join person on a.locationID = person.locationID
		where flightID = ip_flightID);

end //
delimiter ;

-- [7] flight_takeoff()
-- -----------------------------------------------------------------------------
/* This stored procedure updates the state for a flight taking off from its current
airport towards the next airport along it's route. The time for the next leg of
the flight must be calculated based on the distance and the speed of the airplane.
And we must also ensure that propeller driven planes have at least one pilot
assigned, while jets must have a minimum of two pilots. If the flight cannot take
off because of a pilot shortage, then the flight must be delayed for 30 minutes. */
-- -----------------------------------------------------------------------------

drop procedure if exists flight_takeoff;
delimiter //
create procedure flight_takeoff (in ip_flightID varchar(50))
sp_main: begin
	DECLARE is_flight_on_ground INT;
    DECLARE leg_distance INT;
    DECLARE flight_speed INT;
    DECLARE departure_time DATETIME;
    DECLARE propeller_plane_pilot_count INT;
    DECLARE jet_plane_pilot_count INT;
    DECLARE required_pilot_count INT;
    DECLARE pilot_count INT;

    -- Check if flight is currently on the ground
    SELECT COUNT(*)
    INTO is_flight_on_ground
    FROM flight
    WHERE flightID = ip_flightID AND airplane_status = 'on_ground';

    IF is_flight_on_ground = 0 THEN
        LEAVE sp_main;
    END IF;

    -- Get the distance of the leg of the flight about to take off
    SELECT distance
    INTO leg_distance
    FROM leg
    WHERE legID = (
            SELECT legID
            FROM route_path AS rp
                     JOIN flight AS f ON rp.routeID = f.routeID
            WHERE f.flightID = ip_flightID AND rp.sequence = f.progress + 1
        );

    -- Check if the flight is at the end of the route
    IF (
		SELECT progress
		FROM flight
		WHERE flightID = ip_flightID AND airplane_status = 'on_ground'
	) = (
		SELECT MAX(sequence)
		FROM route_path
		WHERE routeID = (
			SELECT routeID
			FROM flight
			WHERE flightID = ip_flightID
		)
	) THEN
		LEAVE sp_main;
	END IF;

    -- Get the speed of the airplane
    SELECT speed
    INTO flight_speed
    FROM airplane
    WHERE tail_num = (
            SELECT support_tail
            FROM flight
            WHERE flightID = ip_flightID
        )
        AND airlineID = (
            SELECT support_airline
            FROM flight
            WHERE flightID = ip_flightID
        );

    -- Calculate the required time for the next leg of the flight using leg_time function
    SET departure_time = ADDTIME(
            (SELECT next_time FROM flight WHERE flightID = ip_flightID),
            leg_time(leg_distance, flight_speed)
        );

    -- Check if the airplane is a propeller-driven plane or a jet
    SELECT propellers
    INTO propeller_plane_pilot_count
    FROM airplane
    WHERE tail_num = (
            SELECT support_tail
            FROM flight
            WHERE flightID = ip_flightID
        );

    SELECT jet_engines
    INTO jet_plane_pilot_count
    FROM airplane
    WHERE tail_num = (
            SELECT support_tail
            FROM flight
            WHERE flightID = ip_flightID
        );

    -- Determine the required number of pilots based on the airplane type
    SET required_pilot_count = 
        CASE
            WHEN propeller_plane_pilot_count > 0 THEN 1
            WHEN jet_plane_pilot_count > 0 THEN 2
            ELSE 0
        END;

    -- Check the actual count of pilots
    SELECT COUNT(*)
    INTO pilot_count
    FROM pilot
    WHERE commanding_flight = ip_flightID;

    -- Update the flight status based on the pilot availability
    IF pilot_count < required_pilot_count THEN
        -- Delay the flight for 30 minutes due to pilot shortage
        UPDATE flight
        SET next_time = ADDTIME(next_time, '00:30:00')
        WHERE flightID = ip_flightID;
    ELSE
        -- Update the flight status for takeoff
        UPDATE flight
        SET next_time = departure_time,
            airplane_status = 'in_flight',
            progress = progress + 1
        WHERE flightID = ip_flightID;
    END IF;

    
end //
delimiter ;

-- [8] passengers_board()
-- -----------------------------------------------------------------------------
/* This stored procedure updates the state for passengers getting on a flight at
its current airport. The passengers must be at the same airport as the flight,
and the flight must be heading towards that passenger's desired destination.
Also, each passenger must have enough funds to cover the flight. Finally, there
must be enough seats to accommodate all boarding passengers. */
-- -----------------------------------------------------------------------------

drop procedure if exists passengers_board;
delimiter //
create procedure passengers_board (in ip_flightID varchar(50))
sp_main: begin
	DECLARE passenger_airport VARCHAR(50);
    DECLARE passenger_destination VARCHAR(50);
    DECLARE flight_airport VARCHAR(50);
    DECLARE seats VARCHAR(50);
    DECLARE p_personID VARCHAR(50);
	DECLARE p_sufficient_funds BOOLEAN;
    DECLARE p_enough_seats BOOLEAN;
    DECLARE p_flight_cost DECIMAL(10, 2);

    -- find passenger location
    SELECT airport.airportID into passenger_airport
    FROM person
    JOIN airport ON airport.locationID = person.locationID
    where person.personID not in (select personID from pilot) limit 1;
    
    -- find location of the flight/airplane
    SELECT 
    CASE WHEN flight.progress = route_path.sequence AND flight.airplane_status = 'on_ground' THEN arrival
         WHEN flight.progress = 0 AND flight.progress + 1 = route_path.sequence THEN departure
    END into flight_airport
	FROM 
    flight
    LEFT JOIN airplane ON airplane.tail_num = flight.support_tail
    LEFT JOIN location ON location.locationID = airplane.locationID
    JOIN route_path ON flight.routeID = route_path.routeID
    JOIN leg ON leg.legID = route_path.legID
	WHERE flight.flightID = ip_flightID and
    (flight.progress = route_path.sequence AND flight.airplane_status = 'on_ground')
    OR (flight.progress = 0 AND flight.progress + 1 = route_path.sequence) limit 1;
    
    -- find passenger destination
    select airportID into passenger_destination from passenger_vacations where sequence = 1
    limit 1;
    
    -- check if passenger is in same place
    if passenger_airport = flight_airport then
		-- check if flight is going to passenger vacation
		if flight_airport = passenger_destination then
		    -- check if passenger has enough funds for flight
			SET p_sufficient_funds = (SELECT funds >= (SELECT cost FROM flight WHERE flightID = ip_flightID) FROM passenger AS p
            JOIN passenger_vacations AS pv ON p.personID = pv.personID
            WHERE p.personID = p_personID AND pv.sequence = 1);
			IF p_sufficient_funds THEN
            -- Check if there are enough seats to accommodate all boarding passengers
            SET p_enough_seats = (
            SELECT a.seat_capacity > ( SELECT COUNT(*) FROM passenger_vacations AS pv
            JOIN leg AS l ON pv.airportID = l.departure
            JOIN route_path AS rp ON l.legID = rp.legID
            JOIN flight AS f ON f.routeID = rp.routeID
            JOIN airplane AS a ON f.support_tail = a.tail_num
            WHERE f.flightID = ip_flightID) FROM flight AS f JOIN airplane AS a ON f.support_tail = a.tail_num WHERE f.flightID = ip_flightID);
			IF p_enough_seats THEN
            -- Get the cost of the flight
            SELECT cost INTO p_flight_cost FROM flight WHERE flightID = ip_flightID;
            
            -- Update the location of the passenger in the person table
			UPDATE person
            SET locationID = passenger_destination
			WHERE personID = p_personID;
            
            -- delete from passenger_vacations
            DELETE FROM passenger_vacations
			WHERE personID = p_personID;
            
			-- Deduct the flight cost from the passenger's funds
            UPDATE passenger
            SET funds = funds - p_flight_cost
            WHERE personID = p_personID;
		end if;
        end if;
        end if;
        end if;
    
    
end //
delimiter ;

-- [9] passengers_disembark()
-- -----------------------------------------------------------------------------
/* This stored procedure updates the state for passengers getting off of a flight
at its current airport. The passengers must be on that flight, and the flight must
be located at the destination airport as referenced by the ticket. */
-- -----------------------------------------------------------------------------

drop procedure if exists passengers_disembark;
delimiter //
create procedure passengers_disembark (in ip_flightID varchar(50))
sp_main: begin

    DECLARE p_personID VARCHAR(50);
    DECLARE p_destination_airport VARCHAR(3);

    -- Get the person who is disembarking from the flight
    SELECT personID
    INTO p_personID
    FROM passenger_vacations AS pv
    JOIN leg AS l ON pv.airportID = l.arrival
    JOIN route_path AS rp ON l.legID = rp.legID
    JOIN flight AS f ON f.routeID = rp.routeID
    WHERE f.flightID = ip_flightID AND pv.sequence = 1;

    -- Check if a passenger is available to disembark
    IF p_personID IS NULL THEN
        LEAVE sp_main;
    END IF;

    -- Get the destination airport for the ticket
    SELECT arrival
    INTO p_destination_airport
    FROM leg AS l
    JOIN route_path AS rp ON l.legID = rp.legID
    JOIN flight AS f ON rp.routeID = f.routeID
    WHERE f.flightID = ip_flightID AND rp.sequence = 1;

    -- Check if the flight is at the correct destination for disembarking
    IF p_destination_airport IS NULL THEN
        LEAVE sp_main;
    END IF;

    -- Update the location of the passenger in the person table
    UPDATE person
    SET locationID = (
        SELECT locationID
        FROM airport
        WHERE airportID = p_destination_airport
    )
    WHERE personID = p_personID;

    -- Update Vacation Destinations
    DELETE FROM passenger_vacations
    WHERE personID = p_personID AND sequence = 1;

    -- Decrement the sequence for other vacation destinations
    UPDATE passenger_vacations
    SET sequence = sequence - 1
    WHERE personID = p_personID;

end //
delimiter ;

-- [10] assign_pilot()
-- -----------------------------------------------------------------------------
/* This stored procedure assigns a pilot as part of the flight crew for a given
flight. The pilot being assigned must have a license for that type of airplane,
and must be at the same location as the flight. Also, a pilot can only support
one flight (i.e. one airplane) at a time. The pilot must be assigned to the flight
and have their location updated for the appropriate airplane. */
-- -----------------------------------------------------------------------------

drop procedure if exists assign_pilot;
delimiter //
create procedure assign_pilot (in ip_flightID varchar(50), ip_personID varchar(50))
sp_main: begin
		
    DECLARE pilot_license VARCHAR(100);
    DECLARE airplane_type VARCHAR(100);
    DECLARE pilot_location VARCHAR(50);
    DECLARE airplane_location VARCHAR(50);
    
    -- Get the pilot's license for the airplane type
    SELECT group_concat(license) INTO pilot_license
    FROM pilot_licenses
    WHERE personID = ip_personID;
    
    -- Get the airplane type for the given flight
    SELECT concat(plane_type) INTO airplane_type
    FROM airplane
    JOIN flight ON flight.support_tail = airplane.tail_num
    WHERE flight.flightID = ip_flightID;

    -- Get the location of the pilot
    SELECT locationID INTO pilot_location
    FROM person
    WHERE personID = ip_personID;
    
    -- Get the location of the airplane
    SELECT locationID into airplane_location
    from airplane
    where airplane.locationID = ip_flightID;
    
    -- Check if the pilot has the required license and is at the same location
    if not find_in_set(airplane_type, pilot_license) then
        leave sp_main; -- Leave the procedure without throwing an error
    end if;
    
    -- Check if the pilot is at the specified location and if pilot is already assigned to another flight
    if airplane_location != pilot_location then
        leave sp_main; -- Leave the procedure without throwing an error
    ELSE 
        If EXISTS (SELECT 1 FROM pilot WHERE personID = ip_personID AND commanding_flight IS NOT NULL) THEN
            leave sp_main; -- Leave the procedure without throwing an error
        END IF;
    END IF;
    
    -- Assign the pilot to the flight and update their location
	UPDATE pilot
	SET commanding_flight = ip_flightID
	WHERE personID = ip_personID;
    
	-- update pilot location
	UPDATE person
	SET locationID = (
		SELECT locationID
		FROM flight
		JOIN airplane ON flight.support_tail = airplane.tail_num
		WHERE flight.flightID = ip_flightID
	)
	WHERE personID = ip_personID;
       
end //
delimiter ;

-- [11] recycle_crew()
-- -----------------------------------------------------------------------------
/* This stored procedure releases the assignments for a given flight crew. The
flight must have ended, and all passengers must have disembarked. */
-- -----------------------------------------------------------------------------

drop procedure if exists recycle_crew;
DELIMITER //
CREATE PROCEDURE recycle_crew(IN ip_flightID VARCHAR(50))
sp_main: BEGIN
    DECLARE flight_status VARCHAR(50);
    DECLARE passengers_count INT;
    DECLARE flight_location VARCHAR(50);

    -- Check if the flight has ended
    select distinct flight.flightID into flight_status
    from flight
    join route_path on flight.routeID = route_path.routeID
    where flightID = ip_flightID and flight.airplane_status = 'on_ground' and flight.progress = (select max(sequence) from route_path where routeID = flight.routeID);
    
    -- find flight location
    SELECT airport.locationID into flight_location FROM flight
    inner JOIN airplane ON airplane.tail_num = flight.support_tail
    inner JOIN location ON location.locationID = airplane.locationID
    JOIN route_path ON flight.routeID = route_path.routeID
    JOIN leg ON leg.legID = route_path.legID
    join airport on airport.airportID = leg.arrival 
	WHERE flight.flightID = ip_flightID and flight.progress = route_path.sequence AND flight.airplane_status = 'on_ground';

    IF flight_status is not null THEN
        -- Check if all passengers have disembarked
        select (count(person.personID) - count(pilot.personID)) into passengers_count from flight
		join airplane on airplane.tail_num = flight.support_tail
		join person on person.locationID = airplane.locationID
        left join pilot on pilot.personID = person.personID
        where flightID = ip_flightID;

		IF passengers_count = 0 THEN
    -- set commanding flight of that pilot to null
    UPDATE pilot
    SET commanding_flight = NULL
    WHERE commanding_flight = ip_flightID;

    -- create a temporary table to store the location updates
    CREATE TEMPORARY TABLE temp_location_updates (
        old_location VARCHAR(50),
        new_location VARCHAR(50)
    );

    -- populate the temporary table with location updates
    INSERT INTO temp_location_updates (old_location, new_location)
    SELECT DISTINCT person.locationID AS old_location, flight_location
    FROM flight
    JOIN airplane ON airplane.tail_num = flight.support_tail
    JOIN person ON person.locationID = airplane.locationID
    WHERE flight.flightID = ip_flightID;

    -- update the person table using the temporary table
    UPDATE person
    JOIN temp_location_updates ON person.locationID = temp_location_updates.old_location
    SET person.locationID = temp_location_updates.new_location;

    -- drop the temporary table
    DROP TEMPORARY TABLE IF EXISTS temp_location_updates;
END IF;

END IF;

END //
DELIMITER ;

-- [12] retire_flight()
-- -----------------------------------------------------------------------------
/* This stored procedure removes a flight that has ended from the system. The
flight must be on the ground, and either be at the start its route, or at the
end of its route. And the flight must be empty - no pilots or passengers. */
-- -----------------------------------------------------------------------------

drop procedure if exists retire_flight;
delimiter //
create procedure retire_flight (in ip_flightID varchar(50))
sp_main: begin

	declare is_flight_on_ground int;
    declare is_flight_empty int;
    declare is_at_start_or_end int;

    -- Check if the flight is on the ground
    select count(*)
    into is_flight_on_ground
    from flight
    where flightID = ip_flightID and airplane_status = 'on_ground';

    if is_flight_on_ground = 0 then
        leave sp_main; -- Flight is not on the ground, exit procedure
    end if;

    -- Check if the flight is empty (no pilots or passengers)
    select count(*)
    into is_flight_empty
    from flight
    where flightID = ip_flightID
      and not exists (
          select 1
          from pilot
          where commanding_flight = ip_flightID
      )
      and not exists (
          select 1
          from passenger
          join person on passenger.personID = person.personID
          where locationID = (
              select locationID
              from airplane
              where tail_num = (
                  select support_tail
                  from flight
                  where flightID = ip_flightID
              )
          )
      );

    if is_flight_empty = 0 then
        leave sp_main; -- Flight is not empty, exit procedure
    end if;

    -- Check if the flight is at the start or end of its route
    select count(*)
    into is_at_start_or_end
    from flight
    join route_path as rp on flight.routeID = rp.routeID
    where flight.flightID = ip_flightID
      and (
          flight.progress = 0 -- At the start of the route
          or flight.progress = (select max(sequence) from route_path where routeID = flight.routeID) -- At the end of the route
      );

    if is_at_start_or_end = 0 then
        leave sp_main; -- Flight is not at the start or end of its route, exit procedure
    end if;

    -- Remove the flight from the flight table
    delete from flight where flightID = ip_flightID;

end //
delimiter ;

-- [13] simulation_cycle()
-- -----------------------------------------------------------------------------
/* This stored procedure executes the next step in the simulation cycle. The
flight with the smallest next time in chronological order must be identified and selected.
If multiple flights have the same time, then flights that are landing should be
preferred over flights that are taking off. Similarly, flights with the lowest
identifier in alphabetical order should also be preferred.
If an airplane is in flight and waiting to land, then the flight should be allowed
to land, passengers allowed to disembark, and the time advanced by one hour until
the next takeoff to allow for preparations.
If an airplane is on the ground and waiting to takeoff, then the passengers should
be allowed to board, and the time should be advanced to represent when the airplane
will land at its next location based on the leg distance and airplane speed.
If an airplane is on the ground and has reached the end of its route, then the
flight crew should be recycled to allow rest, and the flight itself should be
retired from the system. */
-- -----------------------------------------------------------------------------

drop procedure if exists simulation_cycle;
delimiter //
create procedure simulation_cycle ()
sp_main: begin

    DECLARE min_time TIME;
    DECLARE min_flightID VARCHAR(50);
    DECLARE min_flight_status VARCHAR(20);
    DECLARE min_flight_progress INT;

    -- Get the flight with the smallest next_time
    SELECT f.next_time, f.flightID, f.airplane_status, f.progress
    INTO min_time, min_flightID, min_flight_status, min_flight_progress
    FROM flight f
    WHERE f.next_time IS NOT NULL
    ORDER BY f.next_time ASC, 
             CASE WHEN f.airplane_status = 'in_flight' THEN 1 ELSE 0 END DESC,
             f.flightID ASC
    LIMIT 1;

    -- If no flights are scheduled, exit the procedure
    IF min_time IS NULL THEN
        LEAVE sp_main;
    END IF;

    -- Check the state of the airplane based on progress
    CASE
        WHEN min_flight_status = 'in_flight' AND min_flight_progress > 0 THEN
            -- Flight is in flight and waiting to land
            CALL flight_landing(min_flightID);
            CALL passengers_disembark(min_flightID);
            -- Advance time by one hour until the next takeoff
            UPDATE flight SET next_time = ADDTIME(min_time, '01:00:00') WHERE flightID = min_flightID;
        WHEN min_flight_status = 'on_ground' AND min_flight_progress = 0 THEN
            -- Flight is on the ground and waiting to takeoff
            CALL passengers_boarding(min_flightID);
            CALL flight_takeoff(min_flightID);
        WHEN min_flight_status = 'on_ground' AND min_flight_progress > 0 AND min_flight_progress < (SELECT MAX(sequence) FROM route_path WHERE routeID = (SELECT routeID FROM flight WHERE flightID = min_flightID)) THEN
            -- Flight is on the ground and in progress along the route
            -- Advance time to represent when the airplane will land at its next location
            UPDATE flight f
            SET f.next_time = ADDTIME(min_time, 
                (SELECT SEC_TO_TIME(rp.leg_distance / f.airplane_speed * 3600) 
                 FROM route_path rp 
                 WHERE rp.routeID = f.routeID AND rp.legID = 'leg_' || (min_flight_progress + 1)))
            WHERE f.flightID = min_flightID;
        WHEN min_flight_status = 'on_ground' AND min_flight_progress = (SELECT MAX(sequence) FROM route_path WHERE routeID = (SELECT routeID FROM flight WHERE flightID = min_flightID)) THEN
            -- Flight has reached the end of its route
            CALL recycle_crew(min_flightID);
            CALL retire_flight(min_flightID);
    END CASE;

end //
delimiter ;

-- [14] flights_in_the_air()
-- -----------------------------------------------------------------------------
/* This view describes where flights that are currently airborne are located. */
-- -----------------------------------------------------------------------------

create or replace view flights_in_the_air(departing_from, arriving_at, num_flights, flight_list, earliest_arrival, latest_arrival, airplane_list)
as
SELECT departure as departing_from, arrival as arriving_at, COUNT(*) as num_flights, flight.flightID as flight_list,  MIN(flight.next_time) AS earliest_arrival, MAX(flight.next_time) AS latest_arrival, location.locationID as airplane_list
FROM flight
LEFT JOIN airplane ON airplane.tail_num = flight.support_tail
LEFT JOIN location ON location.locationID = airplane.locationID
JOIN route_path on flight.routeID = route_path.routeID
JOIN leg on leg.legID = route_path.legID
WHERE flight.flightID IS NOT NULL and flight.progress = route_path.sequence and flight.airplane_status = 'in_flight'
GROUP BY
    location.locationID,
    flight.flightID,
    flight.routeID;

-- [15] flights_on_the_ground()
-- -----------------------------------------------------------------------------
/* This view describes where flights that are currently on the ground are located. */
-- -----------------------------------------------------------------------------

create or replace view flights_on_the_ground(departing_from, num_flights, flight_list, earliest_arrival, latest_arrival, airplane_list)
as
SELECT 
    CASE WHEN flight.progress = route_path.sequence AND flight.airplane_status = 'on_ground' THEN arrival
         WHEN flight.progress = 0 AND flight.progress + 1 = route_path.sequence THEN departure
    END AS departing_from,
    COUNT(flight.flightID) AS flight_count,
    GROUP_CONCAT(flight.flightID) AS flight_list,
    MIN(flight.next_time) AS earliest_arrival_time,
    MAX(flight.next_time) AS latest_arrival_time,
    GROUP_CONCAT(location.locationID) AS airplane_list
FROM 
    flight
    LEFT JOIN airplane ON airplane.tail_num = flight.support_tail
    LEFT JOIN location ON location.locationID = airplane.locationID
    JOIN route_path ON flight.routeID = route_path.routeID
    JOIN leg ON leg.legID = route_path.legID
WHERE 
    (flight.progress = route_path.sequence AND flight.airplane_status = 'on_ground')
    OR (flight.progress = 0 AND flight.progress + 1 = route_path.sequence)
GROUP BY 
    departing_from;

-- [16] people_in_the_air()
-- -----------------------------------------------------------------------------
/* This view describes where people who are currently airborne are located. */
-- -----------------------------------------------------------------------------

create or replace view people_in_the_air(departing_from, arriving_at, num_airplanes, airplane_list, flight_list, earliest_arrival, latest_arrival, num_pilots, num_passengers, joint_pilots_passengers, person_list)
as
select departure as departing_from, arrival as arriving_at, COUNT(DISTINCT airplane.locationID) AS num_airplanes,
airplane.locationID as airplane_list, flight.flightID as flight_list, MIN(flight.next_time) AS earliest_arrival, MAX(flight.next_time) AS latest_arrival,
count(pilot.personID) as num_pilots, (COUNT(person.personID) - COUNT(pilot.personID)) AS num_passengers, count(person.personID) as joint_pilots_passengers,
GROUP_CONCAT(person.personID) as joint_pilot_passengers
from airplane
join person on person.locationID = airplane.locationID
join flight on flight.support_tail = airplane.tail_num
join route_path on flight.routeID = route_path.routeID
join leg on leg.legID = route_path.legID
left join pilot on pilot.personID = person.personID
where flight.progress = route_path.sequence and flight.airplane_status = 'in_flight'
group by airplane.locationID, flight.flightID;

-- [17] people_on_the_ground()
-- -----------------------------------------------------------------------------
/* This view describes where people who are currently on the ground are located. */
-- -----------------------------------------------------------------------------

create or replace view people_on_the_ground(departing_from, airport, airport_name, city, state, country, num_pilots, num_passengers, num_pilots_passengers, person_list)
as
SELECT airport.airportID as departing_from, person.locationID as airport, airport_name, city, state, country,
count(pilot.personID) as num_pilots, (COUNT(person.personID) - COUNT(pilot.personID)) AS num_passengers, count(person.personID) as num_pilots_passengers,
group_concat(person.personID) as person_list 
From person
JOIN airport ON airport.locationID = person.locationID
left join pilot on pilot.personID = person.personID
group by person.locationID, airport.airportID;

-- [18] route_summary()
-- -----------------------------------------------------------------------------
/* This view describes how the routes are being utilized by different flights. */
-- -----------------------------------------------------------------------------

create or replace view route_summary (
    route, 
    num_legs, 
    leg_sequence, 
    route_length, 
    num_flights, 
    flight_list,
    airport_sequence
) as
select
    route_path.routeID as route,
    count(distinct route_path.legID) as num_legs,
    group_concat(distinct route_path.legID order by route_path.sequence) as leg_sequence,
    case 
        when max(route_path.routeID = 'americas_hub_exchange') > 0 
        then 600
        else sum(distance)
    end as route_length,
    count(distinct flightID) as num_flights,
    group_concat(distinct flightID) as flight_list,
    group_concat(distinct concat(departure, '->',arrival) order by route_path.sequence) as airport_sequence
from
    leg 
	join route_path on route_path.legID = leg.legID 
    left join flight on route_path.routeID = flight.routeID
group by
    route;

-- [19] alternative_airports()
-- -----------------------------------------------------------------------------
/* This view displays airports that share the same city and state. */
-- -----------------------------------------------------------------------------

create or replace view alternative_airports (
    city, 
    state, 
    country, 
    num_airports, 
    airport_code_list, 
    airport_name_list
) as
select
    city,
    state,
    country,
    count(*) as num_airports,
    group_concat(airportID) as airport_code_list,
    group_concat(airport_name) as airport_name_list
from
    airport
group by
    city, state, country
having
    count(*) >= 2;