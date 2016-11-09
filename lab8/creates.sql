DROP TABLE IF EXISTS Persons;
DROP TABLE IF EXISTS Actors;
DROP TABLE IF EXISTS Directors;
DROP TABLE IF EXISTS ActsIn;
DROP TABLE IF EXISTS Directs;
DROP TABLE IF EXISTS Movies;


CREATE TABLE Persons(
	PID char(4) not null,
	NAME text not null,
	ADDRESS text,
	SPOUSE text,
	primary key(PID)
);

CREATE TABLE Actors(
	AID char(4) not null,
	PID char(4) not null references Persons(PID),
	DOB date,
	HAIR_COLOR text not null,
	EYE_COLOR text not null,
	HEIGHT_IN integer not null,
	WEIGHT_LBS integer not null,
	COLOR text,
	SAGUILD_ANNIVERSARY date,
	primary key(AID)
);

CREATE TABLE Directors(
	DID char(4) not null,
	PID char(4) not null references Persons(PID),
	FILMSCHOOL text,
	DGUILD_ANNIVERSARY date,
	LENS_MAKER text,
	primary key(DID)
);

CREATE TABLE ActsIn(
	AID char(4) not null references Actors(AID),
	MPAANUM int not null references Movies(MPAANUM),
	primary key(AID,MPAANUM)
);

CREATE TABLE Directs(
	DID char(4) not null references Directors(DID),
	MPAANUM int not null references Movies(MPAANUM),
	primary key(DID,MPAANUM)
);

CREATE TABLE Movies(
	MPAANUM int not null,
	NAME text not null,
	YEAR_RELEASED int not null,
	DOMESTIC_BOX_USD int,
	FOREIGN_BOX_USD int,
	DVD_BLURAY_USD int,
	primary key(MPAANUM)
);