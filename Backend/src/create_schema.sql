create table info (
    id int,
    name varchar(50),
    gps_lat int,
    gps_long int
);

create table faces (
    id int,
    person_id varchar(50),
    filename varchar(50),
    image blob,
    feature_vector blob
);
