create table info (
    id int,
    name varchar(50),
    gpslat int,
    gpslong int
);

create table images (
    id int PRIMARY KEY,
    person_id varchar(50),
    filename varchar(50),
    numfaces int,
    image blob
);
