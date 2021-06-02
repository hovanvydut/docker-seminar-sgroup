create database seminar_sgroup;

use seminar_sgroup;

create table members (
    id INTEGER NOT NULL AUTO_INCREMENT, 
    name VARCHAR(60) NOT NULL, 
    PRIMARY KEY(id)
);

insert into members (name) values ("Phu"), ("Tu"), ("Hoa"), ("Huy"), ("Kha"), ("Vy");