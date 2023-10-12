USE `essentialmode`; -- if you using esx change essentialmode to es_extended
CREATE TABLE fightbans (
    id INT PRIMARY KEY AUTO_INCREMENT,
    player_id INT,
    expire_time INT
);