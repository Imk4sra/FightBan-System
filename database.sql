USE `essentialmode`; -- if you using esx change essentialmode to es_extended
CREATE TABLE fight_ban (
  identifier VARCHAR(255),
  expire_time TIMESTAMP,
  PRIMARY KEY (identifier)
);
