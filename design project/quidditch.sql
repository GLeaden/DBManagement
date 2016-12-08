-- Database: hogwarts inter-house quidditch 
-- brought to you by G Leaden

DROP ROLE if exists administrator;
DROP ROLE if exists headmaster;
DROP ROLE if exists referee;
DROP ROLE if exists student;
create role admin; 
grant all on all tables in schema public to admin; 
create role headmaster; 
grant all on all tables in schema public to admin;
create role referee; 
revoke all on all tables in schema public from referee; 
grant select on all tables in schema public to referee; 
grant insert on people, players, referees, matches, game_stats, flys, brooms, plays_for, balls_in_match to referee; 
grant update on people, players, referees, matches, game_stats, flys, brooms, plays_for, balls_in_match, quidditch_cup, teams to referee; 
create role student;  
grant select on all tables in schema public to student; 

 
 
DROP type if exists house cascade;
DROP type if exists wcondition cascade;
CREATE TYPE house AS ENUM ('Gryffindor', 'Hufflepuff', 'Ravenclaw', 'Slytherin');
CREATE TYPE wcondition AS ENUM ('clear','rainy','thunderstormy','snowy','windy','cloudy');
drop table if exists people cascade;
drop table if exists players cascade;
drop table if exists referees cascade;
drop table if exists positions cascade;
drop table if exists brooms cascade;
drop table if exists flys cascade;
drop table if exists teams cascade;
drop table if exists plays_for cascade;
drop table if exists balls cascade;
drop table if exists matches cascade;
drop table if exists balls_in_match cascade;
drop table if exists plays cascade;
drop table if exists game_stats cascade;
drop table if exists quidditch_cup cascade;



CREATE TABLE people(
	PeopleID  int          not null,
	fname     text         not null,
	lname     text         not null,
	dob       DATE         not null,
	height_cm decimal(8,3) not null,
	weight_kg decimal(7,3) not null,
	house 	  house		   not null,
	primary key(PeopleID)
);
 
CREATE TABLE players(
    PeopleID                       int not null references people(PeopleID),
    career_pts_earned              int,
    career_penalties_recieved      int,
    career_games_played_as_starter int,
    season_pts_earned              int,
    season_penalties_recieved      int,
    season_games_played_as_starter int,
    primary key(PeopleID)
);
 
CREATE TABLE referees(
    PeopleID        int   not null references people(PeopleID),
    games_refereed  int   not null,
    primary key(PeopleID)
);
 
CREATE TABLE positions(
	PositionID      int     not null,
	name            text    not null,
	number_per_team int     not null,
	canscore        boolean not null,
	primary key(PositionID)
);
 
CREATE TABLE brooms(
	BroomID                 int          not null,
	name                    text         not null,
	accelerationin10sec_KPH decimal(7,3) not null,
	maxspeed_KPH            decimal(7,3) not null,
	length_CM               decimal(7,3) not null,
	cost_Knuts              int          not null, -- 29 Knuts in a Sickle and 17 Sickles in a Galleon (493 Knuts in Galleon)
	primary key(BroomID)
);
 
CREATE TABLE flys(
    PeopleID int     not null references people(PeopleID),
    BroomID  int     not null references brooms(BroomID),
    primary key(PeopleID, BroomID)
);
 
CREATE TABLE teams(
    TeamID          int     not null,
    name            house   not null,
    primary_color   text    not null,
    secondary_color text    not null,
    mascot          text    not null,
    primary key(TeamID)
);
 
CREATE TABLE plays_for(
    PeopleID   int     not null references people(PeopleID),
    TeamID     int     not null references teams(TeamID),
    PositionID int     not null references positions(PositionID),
    start_date DATE    not null,
    end_date   DATE,
    primary key(PeopleID, TeamID, PositionID)
 
);
 
CREATE TABLE balls(
	BallID       int          not null,
	name         text         not null,
	diameter_CM	 decimal(7,3) not null,
	weight_KG    decimal(7,3) not null,
	avgspeed_KPH decimal(7,3),
	primary key(BallID)
);
 
CREATE TABLE matches(
	match_date DATE         not null,
        peopleid   int          not null references people(peopleid),
	weather    wcondition   not null,
	temp_C     decimal(7,3) not null,
	primary key(match_date)
);
 
CREATE TABLE balls_in_match(
	match_date DATE not null references matches(match_date),
	BallID     int  not null references balls(BallID),
	count      int  not null,
	primary key(match_date, BallID)
);
 
CREATE TABLE plays(
	match_date       DATE    not null references matches(match_date),
	TeamID           int     not null references teams(TeamID),
	totalpts         int     not null,
	caught_snitch    boolean not null,
	primary key(match_date, TeamID)
);

CREATE TABLE game_stats(
    PeopleID           int not null references people(PeopleID),
    match_date         DATE not null references matches(match_date),
	pts_earned         int not null,
	penalties_recieved int not null,
	did_play           boolean not null,
    primary key(PeopleID,match_date)
);
 
CREATE TABLE quidditch_cup(
    season_start int not null,
    season_end   int not null,
    TeamID       int not null references teams(TeamID),
    totalpts     int not null,
    primary key(season_start, season_end, TeamID)
);

DROP VIEW IF EXISTS current_rosters;
CREATE VIEW current_rosters as
	SELECT   fname as first_name,lname as last_name,positions.name as position, teams.name as team, brooms.name as current_broom
	FROM     players 
		 INNER JOIN people    ON players.peopleid=people.peopleid
		 INNER JOIN plays_for ON players.peopleid=plays_for.peopleid
		 INNER JOIN positions ON plays_for.positionid=positions.positionid
		 INNER JOIN teams     ON plays_for.teamid=teams.teamid
		 INNER JOIN flys      ON players.peopleid=flys.peopleid
		 INNER JOIN brooms    ON flys.broomid=brooms.broomid
	WHERE    plays_for.end_date   IS NULL
	ORDER BY teams ASC, people ASC;


DROP VIEW IF EXISTS highest_scorer;
CREATE VIEW highest_scorer as
	SELECT   fname as first_name,lname as last_name, career_pts_earned as total_points, positions.name as position, teams.name as team, brooms.name as current_broom
	FROM     players 
		 INNER JOIN people    ON players.peopleid=people.peopleid
		 INNER JOIN plays_for ON players.peopleid=plays_for.peopleid
		 INNER JOIN positions ON plays_for.positionid=positions.positionid
		 INNER JOIN teams     ON plays_for.teamid=teams.teamid
		 INNER JOIN flys      ON players.peopleid=flys.peopleid
		 INNER JOIN brooms    ON flys.broomid=brooms.broomid
	WHERE    players.career_pts_earned = (SELECT   players.career_pts_earned 
	                                      FROM     players
	                                      WHERE    career_pts_earned IS NOT NULL
	                                      ORDER BY career_pts_earned DESC
	                                      LIMIT 1)
	ORDER BY career_pts_earned DESC, teams ASC;



 
CREATE OR REPLACE FUNCTION gamedata_to_plays() RETURNS trigger AS $to_plays$
    DECLARE
		my_teamID          int;
		totalpoints        int;
		snitch             boolean;
		seekerid	   int;
    BEGIN
		snitch=false;
		my_teamID=(SELECT teamID
			   FROM   plays_for
		           WHERE  NEW.PeopleID=plays_for.PeopleID AND ((end_date IS NULL) OR (NEW.match_date BETWEEN start_date AND end_date)));
	        seekerid= (SELECT players.peopleid
			   FROM players right outer join plays_for on players.peopleid=plays_for.peopleid right outer join positions on positions.positionid=plays_for.positionid
			   WHERE name='seeker' AND teamid=my_teamid AND end_date IS NULL);
	        

		IF ((SELECT teamid from plays where match_date=NEW.match_date ORDER BY teamid DESC LIMIT 1) <> my_teamID AND (SELECT teamid from plays where match_date=NEW.match_date ORDER BY teamid ASC LIMIT 1) <> my_teamID) OR ((SELECT teamid from plays where match_date=NEW.match_date ORDER BY teamid DESC LIMIT 1) IS NULL AND (SELECT teamid from plays where match_date=NEW.match_date ORDER BY teamid ASC LIMIT 1) IS NULL) THEN
				INSERT INTO plays(match_date, teamID, totalpts, caught_snitch)
					VALUES(NEW.match_date,my_teamID,NEW.pts_earned,snitch);
		END IF;
		
		UPDATE plays SET totalpts=totalpts+NEW.pts_earned WHERE teamid=my_teamID AND match_date=NEW.match_date;
		
		IF (seekerid=NEW.peopleID) AND (NEW.pts_earned>0) THEN
				UPDATE plays SET caught_snitch=true WHERE teamid=my_teamID AND match_date=NEW.match_date;
			END IF;

	RETURN NEW;
    END;
$to_plays$ LANGUAGE plpgsql;

CREATE TRIGGER gamedata_to_plays AFTER INSERT ON game_stats
    FOR EACH ROW EXECUTE PROCEDURE gamedata_to_plays();

CREATE OR REPLACE FUNCTION plays_to_cup() RETURNS trigger AS $to_cup$
    DECLARE
	my_start_date int;
	my_end_date   int;
    BEGIN
	IF ((date_part('month', NEW.match_date) >= 9) AND (date_part('month', NEW.match_date) <> 12)) THEN
		my_start_date = date_part('year', NEW.match_date);
		my_end_date = date_part('year', NEW.match_date)+1;
	ELSIF date_part('month', NEW.match_date) < 6 THEN
		my_end_date = date_part('year', NEW.match_date);
		my_start_date = date_part('year', NEW.match_date)-1;
	ELSE
		RETURN NEW;
	END IF;
	
	IF (SELECT teamid from quidditch_cup WHERE season_start=my_start_date AND teamid=NEW.teamid) IS NULL THEN
		INSERT INTO quidditch_cup(season_start, season_end, teamID, totalpts)
			VALUES(my_start_date, my_end_date, NEW.teamid, 0);
	END IF;
	RETURN NEW;
    END;
$to_cup$ LANGUAGE plpgsql;

CREATE TRIGGER plays_to_cup AFTER UPDATE ON plays
    FOR EACH ROW EXECUTE PROCEDURE plays_to_cup();

CREATE OR REPLACE FUNCTION matchtoref() RETURNS trigger AS $m2r$
    BEGIN
          UPDATE referees SET games_refereed=games_refereed+1 WHERE peopleid=NEW.peopleid;
    RETURN NEW;
    END;
$m2r$ LANGUAGE plpgsql;

CREATE TRIGGER m2r BEFORE INSERT ON matches
    FOR EACH ROW EXECUTE PROCEDURE matchtoref();
    
CREATE OR REPLACE FUNCTION update_player_stats() RETURNS trigger AS $update_player_stats$
    BEGIN
    		-- if the player has not yet played a game as a starter they will have NULL stats, this checks to see if they have NULL stats and are on the starting roster
		IF (select career_pts_earned from players where peopleID=NEW.PeopleID) IS NULL THEN
			IF NEW.did_play THEN
				-- if the check passes it then initalizes the player with all 0s for stats. fun!
				UPDATE players
				SET    career_pts_earned=0, career_penalties_recieved=0, career_games_played_as_starter=0, season_pts_earned=0, season_penalties_recieved=0, season_games_played_as_starter=0
				WHERE  players.peopleID=NEW.peopleID;
			END IF;
		END IF;
		-- the bread and butter
		UPDATE players 
		SET    career_pts_earned=career_pts_earned+NEW.pts_earned, career_penalties_recieved=career_penalties_recieved+NEW.penalties_recieved, career_games_played_as_starter=career_games_played_as_starter+1, season_pts_earned=season_pts_earned+NEW.pts_earned, season_penalties_recieved=season_penalties_recieved+NEW.penalties_recieved, season_games_played_as_starter=season_games_played_as_starter+1
		WHERE  players.peopleID=NEW.peopleID;
	RETURN NEW;
    END;
$update_player_stats$ LANGUAGE plpgsql;

CREATE TRIGGER update_player_stats BEFORE INSERT ON game_stats
    FOR EACH ROW EXECUTE PROCEDURE update_player_stats();


CREATE OR REPLACE FUNCTION add_data_to_cup() RETURNS trigger AS $data_to_cup$
    DECLARE
	rec     record;
	cnt     int;
	temppts int;
	tempid  int;
	sdate   date;
	edate   date;
    BEGIN
	
		sdate = '9-1-' || (select season_start from quidditch_cup order by season_start DESC limit 1);
		edate = '6-1-' || (select season_end from quidditch_cup order by season_end DESC limit 1);
		temppts=0;
		cnt=1;
		while (cnt <5) LOOP
			update quidditch_cup set totalpts = (SELECT SUM(totalpts) FROM plays WHERE teamID=cnt AND match_date BETWEEN sdate AND edate) WHERE season_start=(select season_start from quidditch_cup order by season_start desc limit 1) AND season_end=(select season_end from quidditch_cup order by season_end desc limit 1) AND teamid=cnt;
			cnt = cnt+1;
		
		END LOOP;
		cnt=1;
		
		RETURN NEW;
    END;
$data_to_cup$ LANGUAGE plpgsql;

CREATE TRIGGER data_to_cup AFTER INSERT ON quidditch_cup
    FOR EACH ROW EXECUTE PROCEDURE add_data_to_cup();

 
INSERT INTO positions(PositionID, name, number_per_team,canscore)
    values
        (1,'beater', 2,false),
        (2,'chaser', 3,true),
        (3,'keeper', 1,false),
        (4,'seeker', 1,true);
INSERT INTO teams(TeamID, name, primary_color, secondary_color, mascot)
    values
        (1,'Gryffindor', 'crimson','gold','lion'),
        (2,'Hufflepuff', 'mustard','black','badger'),
        (3,'Ravenclaw','royal blue','bronze','eagle'),
        (4,'Slytherin', 'green','silver','serpent');
INSERT INTO brooms(BroomID, name, accelerationin10sec_KPH, maxspeed_KPH, length_CM, cost_Knuts)
	values
		(1,'Nimbus 2000',144.841,241.402,155.88,167620),
		(2,'Nimbus 2001',177.028,273.588,150.667,197200),
		(3,'Firebolt',241.402,354.056,153.718,4930000),
		(4, 'Comet 180',65.886,110.692,201.222,46835),
		(5,'Comet 290',96.561,180.247,160.005,128180),
		(6,'Cleansweep 7',90.603,168.995,175.374,118320),
		(7,'Cleansweep 11',112.654,197.949,158.713,147900);

INSERT INTO balls(BallID, name, diameter_CM, weight_KG, avgspeed_KPH)
	values
		(1,'Quaffle',30.48,2.268, NULL),
		(2,'Bludger',25.4,66.885,97.204),
		(3,'Snitch',4.445,3.0395,340);

INSERT INTO people(PeopleID, fname, lname, dob, height_cm, weight_kg,house)   -- make a trigger for house check with teams and playing for
    values
		(1, 'marcus','zimmermann','01-22-1997', 167.64, 63.503,'Hufflepuff'),
		(2, 'alan','labouseur','01-01-1970',9999,9999,'Slytherin'),
		(3, 'rolanda','hooch','01-01-1900',160.02,50.802,'Hufflepuff'),
		(4, 'skittles', 'taylor', '1997-03-07', 165.100, 65.3173, 'Slytherin'),
		(5, 'jeff', 'lupia', '1997-09-14', 199.581, 102.058, 'Gryffindor'),
		(6, 'anton', 'zimmermann', '1997-01-21', 167.65, 63.504, 'Slytherin'),
		(7, 'ron', 'weasley', '1980-02-29', 172.72, 66.83, 'Gryffindor'),
		(8, 'fred', 'weasley', '1978-03-31', 190.5, 87.87, 'Gryffindor'),
		(9, 'george', 'weasley', '1978-03-31', 190.5, 87.87, 'Gryffindor'),
		(10, 'ginerva', 'weasley', '1981-08-10', 167.64, 61.44, 'Gryffindor'),
		(11, 'charlie', 'weasley', '1972-12-11', 182.88, 88.462, 'Gryffindor'),
		(12, 'oliver', 'wood', '1975-10-04', 175.26, 83.124, 'Gryffindor'),
		(13, 'james', 'potter', '1960-03-26', 177.8, 77.651, 'Gryffindor'),
		(14, 'dean', 'thomas', '1980-06-10', 190.5, 80, 'Gryffindor'),
		(15, 'john', 'doe', '1999-11-19', 188.96, 87.332, 'Slytherin'),
		(16, 'john', 'deer', '1998-03-04', 166.388, 59.14, 'Slytherin'),
		(17, 'mary', 'smith', '1998-06-05', 120.7, 72.991, 'Slytherin'),
		(18, 'doug', 'smith', '1997-02-04', 199.691, 101.803, 'Slytherin'),
		(19, 'sample', 'data', '1999-12-31', 177.8, 80.556, 'Slytherin'),
		(20, 'albus', 'weasley', '1999-02-28', 148.371, 81.584, 'Gryffindor'),
		(21, 'the', 'doctor', '1066-12-24', 183.439, 95.467, 'Hufflepuff'),
		(22, 'draco', 'malfoy', '1980-05-05', 160.83, 73.465, 'Slytherin'),
		(23, 'cedric', 'diggory', '1977-09-09', 149.0, 66.177, 'Hufflepuff'),
		(24, 'bartemius', 'crouch', '1962-02-19', 141.092, 82.145, 'Slytherin'),
		(25, 'ian', 'sniffen', '1996-12-31', 203.124, 73.295, 'Hufflepuff'),
		(26, 'dank', 'memes', '2012-01-31', 1.000, 1.000, 'Hufflepuff'),
		(27, 'son', 'goku', '1984-11-19', 192.14, 71.771, 'Gryffindor'),
		(28, 'son', 'gohan', '1988-10-23', 162.327, 89.490, 'Ravenclaw'),
		(29, 'son', 'goten', '1993-11-08', 178.457, 85.319, 'Hufflepuff'),
		(30, 'troy', 'capybara', '1996-12-31', 164, 76.434, 'Hufflepuff'),
		(31, 'myrtle', 'scamander', '1999-05-04', 162.24, 85.270, 'Hufflepuff'),
		(32, 'kevin', 'kliendshmidt', '1996-11-18', 144.913, 103.645, 'Gryffindor'),
		(33, 'daniel', 'hardcastle', '1982-12-31', 158.547, 70.050, 'Hufflepuff'),
		(34, 'reingald', 'weasley', '1999-02-28', 198.527, 76.111, 'Gryffindor'),
		(35, 'regina', 'weasley', '1999-02-28', 177.55, 90.693, 'Gryffindor'),
		(36, 'gabe', 'newell', '1962-11-02', 144.014, 104.335, 'Ravenclaw'),
		(37, 'soren', 'bjerg', '1996-02-20', 152.743, 68.233, 'Gryffindor'),
		(38, 'vincent', 'wang', '1996-12-31', 200.2, 86.443, 'Ravenclaw'),
		(39, 'william', 'li', '1989-11-24', 136.11, 78.839, 'Ravenclaw'),
		(40, 'joshua', 'leesman', '1987-06-07', 139.7, 89.299, 'Ravenclaw'),
		(41, 'marcus-anton', 'zimmermann', '1997-01-21', 167.6, 63.502, 'Ravenclaw'),
		(42, 'the', 'vision', '1940-10-31', 160.330, 68.102, 'Ravenclaw');
	
INSERT INTO referees(PeopleID,games_refereed)
	values
		(2,42),
		(3,251);

INSERT INTO players(PeopleID, career_pts_earned, career_penalties_recieved, career_games_played_as_starter, season_pts_earned, season_penalties_recieved, season_games_played_as_starter)
    values
	    (1, NULL, NULL, NULL, NULL, NULL, NULL),
	    (4, NULL, NULL, NULL, NULL, NULL, NULL),
	    (5, NULL, NULL, NULL, NULL, NULL, NULL),
	    (6, NULL, NULL, NULL, NULL, NULL, NULL),
	    (7, NULL, NULL, NULL, NULL, NULL, NULL),
	    (8, NULL, NULL, NULL, NULL, NULL, NULL),
	    (9, NULL, NULL, NULL, NULL, NULL, NULL),
	    (10, NULL, NULL, NULL, NULL, NULL, NULL),
	    (11, NULL, NULL, NULL, NULL, NULL, NULL),
	    (12, NULL, NULL, NULL, NULL, NULL, NULL),
	    (13, NULL, NULL, NULL, NULL, NULL, NULL),
	    (14, NULL, NULL, NULL, NULL, NULL, NULL),
	    (15, NULL, NULL, NULL, NULL, NULL, NULL),
	    (16, NULL, NULL, NULL, NULL, NULL, NULL),
	    (17, NULL, NULL, NULL, NULL, NULL, NULL),
	    (18, NULL, NULL, NULL, NULL, NULL, NULL),
	    (19, NULL, NULL, NULL, NULL, NULL, NULL),
	    (20, NULL, NULL, NULL, NULL, NULL, NULL),
	    (21, NULL, NULL, NULL, NULL, NULL, NULL),
	    (22, NULL, NULL, NULL, NULL, NULL, NULL),
	    (23, NULL, NULL, NULL, NULL, NULL, NULL),
	    (24, NULL, NULL, NULL, NULL, NULL, NULL),
	    (25, NULL, NULL, NULL, NULL, NULL, NULL),
	    (26, NULL, NULL, NULL, NULL, NULL, NULL),
	    (27, NULL, NULL, NULL, NULL, NULL, NULL),
	    (28, NULL, NULL, NULL, NULL, NULL, NULL),
	    (29, NULL, NULL, NULL, NULL, NULL, NULL),
	    (30, NULL, NULL, NULL, NULL, NULL, NULL),
	    (31, NULL, NULL, NULL, NULL, NULL, NULL),
	    (32, NULL, NULL, NULL, NULL, NULL, NULL),
	    (33, NULL, NULL, NULL, NULL, NULL, NULL),
	    (34, NULL, NULL, NULL, NULL, NULL, NULL),
	    (35, NULL, NULL, NULL, NULL, NULL, NULL),
	    (36, NULL, NULL, NULL, NULL, NULL, NULL),
	    (37, NULL, NULL, NULL, NULL, NULL, NULL),
	    (38, NULL, NULL, NULL, NULL, NULL, NULL),
	    (39, NULL, NULL, NULL, NULL, NULL, NULL),
	    (40, NULL, NULL, NULL, NULL, NULL, NULL),
	    (41, NULL, NULL, NULL, NULL, NULL, NULL),
	    (42, NULL, NULL, NULL, NULL, NULL, NULL);

INSERT INTO plays_for(PeopleID, TeamID, PositionID, start_date, end_date)
    values
		(1 , 2, 1, '2015-08-31', NULL),
		(4 , 4, 4, '2015-08-31', NULL),
		(5 , 1, 1, '2015-08-31', NULL),
		(6 , 4, 2, '2015-08-31', NULL),
		(7 , 1, 3, '1995-08-31', '6-1-1997'),
		(8 , 1, 1, '1990-08-31', '6-1-1995'),
		(9 , 1, 1, '1990-08-31', '6-1-1995'),
		(10, 1, 2, '1996-08-31', '6-1-1997'),
		(10, 1, 4, '1995-08-31', '6-1-1996'),
		(11, 1, 4, '1985-08-31', '6-1-1991'),
		(12, 1, 3, '1988-08-31', '6-1-1993'),
		(13, 1, 2, '1974-08-31', '6-1-1975'),
		(14, 1, 2, '1996-08-31', '6-1-1997'),
		(15, 4, 1, '2014-08-31', NULL),
		(16, 4, 1, '2015-08-31', NULL),
		(17, 4, 3, '2015-08-31', NULL),
		(18, 4, 2, '2013-08-31', NULL),
		(19, 4, 2, '2013-08-31', NULL),
		(20, 1, 4, '2015-08-31', NULL),
		(21, 2, 3, '2015-08-31', NULL),
		(22, 4, 4, '1992-08-31', '6-1-1997'),
		(23, 2, 4, '1993-08-31', '6-1-1995'),
		(24, 4, 1, '1972-08-31', '6-1-1980'),
		(25, 2, 2, '2015-08-31', NULL),
		(26, 2, 4, '2015-08-31', NULL),
		(27, 1, 2, '2014-08-31', NULL),
		(28, 3, 3, '2015-08-31', NULL),
		(29, 2, 2, '2014-08-31', NULL),
		(30, 2, 1, '2015-08-31', NULL),
		(31, 2, 2, '2015-08-31', NULL),
		(32, 1, 2, '2015-08-31', NULL),
		(33, 2, 1, '2015-08-31', '2015-09-02'),
		(34, 1, 1, '2015-08-31', NULL),
		(35, 1, 1, '2015-08-31', NULL),
		(36, 3, 4, '2015-08-31', NULL),
		(37, 1, 2, '2015-08-31', NULL),
		(38, 3, 1, '2015-08-31', NULL),
		(39, 3, 2, '2015-08-31', NULL),
		(40, 3, 1, '2015-08-31', NULL),
		(41, 3, 2, '2015-08-31', NULL),
		(42, 3, 2, '2015-08-31', NULL);

INSERT INTO flys(PeopleID, BroomID)
	values
		(1, 1),
		(2, 1),
		(3, 4),
		(4, 1),
		(5, 1),
		(6, 3),
		(7, 4),
		(8, 6),
		(9, 6),
		(10, 4),
		(11, 6),
		(12, 6),
		(13, 4),
		(14, 7),
		(15, 2),
		(16, 2),
		(17, 2),
		(18, 2),
		(19, 2),
		(20, 4),
		(21, 1),
		(22, 2),
		(23, 1),
		(24, 4),
		(25, 1),
		(26, 4),
		(27, 2),
		(28, 7),
		(29, 2),
		(30, 3),
		(31, 7),
		(32, 7),
		(33, 1),
		(34, 2),
		(35, 2),
		(36, 3),
		(37, 3),
		(38, 1),
		(39, 5),
		(40, 5),
		(41, 7),
		(42, 3);

INSERT INTO Matches(match_date,weather,temp_C,peopleid)
	values
		('2015-11-07', 'clear', 7.222,3),
		('2015-11-28', 'cloudy', 2.778,3),
		('2015-12-25', 'snowy', 0.000,3),
		('2016-02-20', 'clear', 3.333,3),
		('2016-03-12', 'rainy', 8.889,3),
		('2016-05-07', 'clear', 8.889,3),
		('2016-05-28', 'clear', 12.778,3),
		('1996-05-25', 'clear', 25,3),
		('1995-02-04', 'snowy', -1.512,3),
		('1988-11-05', 'rainy', 2.21,3),
		('1975-05-25', 'cloudy', 9.874,3),
		('1997-02-24', 'thunderstormy', 4.665,3),
		('1992-11-05', 'thunderstormy', 9.644,3),
		('1994-03-15', 'clear', 2.843,3);
INSERT INTO balls_in_match(match_date, ballid, count)
	values
		('2016-05-28', 1, 1),
		('2016-05-28', 2, 2),
		('2016-05-28', 3, 1),
		('2016-05-07', 1, 1),
		('2016-05-07', 2, 2),
		('2016-05-07', 3, 1),
		('2016-03-12', 1, 1),
		('2016-03-12', 2, 2),
		('2016-03-12', 3, 1),
		('2016-02-20', 1, 1),
		('2016-02-20', 2, 2),
		('2016-02-20', 3, 1),
		('2015-12-25', 1, 1),
		('2015-12-25', 2, 2),
		('2015-12-25', 3, 1),
		('2015-11-28', 1, 1),
		('2015-11-28', 2, 2),
		('2015-11-28', 3, 1),
		('2015-11-07', 1, 1),
		('2015-11-07', 2, 2),
		('2015-11-07', 3, 1),
		('1997-02-24', 1, 1),
		('1997-02-24', 2, 2),
		('1997-02-24', 3, 1),
		('1996-05-25', 1, 1),
		('1996-05-25', 2, 2),
		('1996-05-25', 3, 1),
		('1995-02-04', 1, 1),
		('1995-02-04', 2, 2),
		('1995-02-04', 3, 1),
		('1994-03-15', 1, 1),
		('1994-03-15', 2, 2),
		('1994-03-15', 3, 1),
		('1992-11-05', 1, 1),
		('1992-11-05', 2, 2),
		('1992-11-05', 3, 1),
		('1988-11-05', 1, 1),
		('1988-11-05', 2, 2),
		('1988-11-05', 3, 1),
		('1975-05-25', 1, 1),
		('1975-05-25', 2, 2),
		('1975-05-25', 3, 1);

		
INSERT INTO game_stats(PeopleID,match_date,pts_earned,penalties_recieved,did_play)
	values
		(5,'11-7-2015',0,6,true),
		(20,'11-7-2015',150,2,true),
		(27,'11-7-2015',100,0,true),
		(32,'11-7-2015',10,0,true),
		(35,'11-7-2015',0,1,true),
		(34,'11-7-2015',0,0,true),
		(37,'11-7-2015',100,1,true),
		(4,'11-7-2015',150,0,true),
		(6,'11-7-2015',0,3,true),
		(19,'11-7-2015',0,4,true),
		(18,'11-7-2015',0,0,true),
		(17,'11-7-2015',0,1,true),
		(16,'11-7-2015',0,1,true),
		(15,'11-7-2015',0,1,true),
		(29,'11-28-2015',300,0,true),
		(1,'11-28-2015',0,0,true),
		(30,'11-28-2015',0,1,true),
		(26,'11-28-2015',0,0,true),
		(31,'11-28-2015',580,0,true),
		(21,'11-28-2015',0,0,true),
		(25,'11-28-2015',210,0,true),
		(41,'11-28-2015',410,0,true),
		(42,'11-28-2015',480,0,true),
		(28,'11-28-2015',0,0,true),
		(36,'11-28-2015',150,0,true),
		(38,'11-28-2015',0,0,true),
		(39,'11-28-2015',90,0,true),
		(40,'11-28-2015',0,0,true),
		(41,'02-20-2016',440,0,true),
		(42,'02-20-2016',310,0,true),
		(28,'02-20-2016',0,0,true),
		(36,'02-20-2016',150,0,true),
		(38,'02-20-2016',0,0,true),
		(39,'02-20-2016',180,0,true),
		(40,'02-20-2016',0,3,true),
		(4,'02-20-2016',0,0,true),
		(6,'02-20-2016',10,0,true),
		(19,'02-20-2016',40,0,true),
		(18,'02-20-2016',100,0,true),
		(17,'02-20-2016',0,0,true),
		(16,'02-20-2016',0,1,true),
		(15,'02-20-2016',0,0,true),
		(37,'03-12-2016',170,1,true),
		(20,'03-12-2016',150,1,true),
		(35,'03-12-2016',0,3,true),
		(34,'03-12-2016',0,0,true),
		(5,'03-12-2016',0,0,true),
		(27,'03-12-2016',350,0,true),
		(32,'03-12-2016',100,0,true),
		(29,'03-12-2016',430,0,true),
		(1,'03-12-2016',0,0,true),
		(30,'03-12-2016',0,2,true),
		(31,'03-12-2016',670,0,true),
		(21,'03-12-2016',0,0,true),
		(25,'03-12-2016',10,0,true),
		(26,'03-12-2016',0,0,true),
		(29,'05-07-2016',100,0,true),
		(1,'05-07-2016',0,1,true),
		(30,'05-07-2016',0,0,true),
		(31,'05-07-2016',30,2,true),
		(21,'05-07-2016',0,0,true),
		(25,'05-07-2016',80,0,true),
		(26,'05-07-2016',0,1,true),
		(15,'05-07-2016',0,1,true),
		(4,'05-07-2016',150,0,true),
		(6,'05-07-2016',0,0,true),
		(19,'05-07-2016',0,0,true),
		(18,'05-07-2016',0,0,true),
		(17,'05-07-2016',0,0,true),
		(16,'05-07-2016',0,0,true),
		(37,'05-28-2016',130,0,true),
		(20,'05-28-2016',150,0,true),
		(35,'05-28-2016',0,0,true),
		(34,'05-28-2016',0,0,true),
		(27,'05-28-2016',70,0,true),
		(32,'05-28-2016',0,0,true),
		(5,'05-28-2016',0,0,true),
		(28,'05-28-2016',0,0,true),
		(36,'05-28-2016',0,0,true),
		(38,'05-28-2016',0,0,true),
		(39,'05-28-2016',120,0,true),
		(40,'05-28-2016',0,0,true),
		(41,'05-28-2016',400,0,true),
		(42,'05-28-2016',400,0,true),
		(7,'05-25-1996',0,2,true),
		(8,'02-04-1995',0,9,true),
		(9,'02-04-1995',0,10,true),
		(10,'05-25-1996',150,0,true),
		(11,'11-5-1988',150,0,true),
		(12,'11-5-1988',0,0,true),
		(13,'05-25-1975',210,5,true),
		(14,'02-24-1997',180,0,true),
		(22,'11-5-1992',0,2,true),
		(23,'03-15-1994',150,0,true),
		(24,'05-25-1975',0,2,true);
select * from people;