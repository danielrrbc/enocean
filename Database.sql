BEGIN TRANSACTION;

DROP TABLE Actions;
DROP TABLE ActuatorTyp;
DROP TABLE Actuators;
DROP TABLE EventType;
DROP TABLE RadioLog;
DROP TABLE SensorTyp;
DROP TABLE Sensors;
DROP TABLE xEventAction;

% Typ of action (on, off , toggle)
CREATE TABLE Actions (
  Id INTEGER PRIMARY KEY,
  Name TEXT);

% Actuator type (device type e.g. REG4x)
CREATE TABLE ActuatorTyp (
  Id INTEGER PRIMARY KEY,
  Typ TEXT,
  Channels INTEGER);

% All known actuators
CREATE TABLE Actuators (
  Id INTEGER PRIMARY KEY,
  GroupId INTEGER,
  Channel INTEGER,
  ActuatorTypId INTEGER,
  Description TEXT,
  State NUMERIC,
  UNIQUE(GroupId, Channel));

% Event type (button pressed, button released)
CREATE TABLE EventType (
  Id INTEGER PRIMARY KEY,
  EventTyp TEXT);

% Log table for radio events
CREATE TABLE RadioLog (
  Id INTEGER PRIMARY KEY,
  TimeStamp TEXT,
  Choice NUMERIC,
  Data BLOB,
  SenderId NUMERIC,
  Status NUMERIC,
  SubTelNum NUMERIC,
  DestinationId NUMERIC,
  dBm NUMERIC,
  SecurityLevel NUMERIC);

% Sensor typ (4ch switch, ...)
CREATE TABLE SensorTyp (
  Id INTEGER PRIMARY KEY,
  Typ TEXT);

% All known sensors 
CREATE TABLE Sensors (
  Id INTEGER PRIMARY KEY,
  SensorTypId INTEGER,
  Description TEXT);

% Map event to action
CREATE TABLE xEventAction (
  % action id
  Id INTEGER PRIMARY KEY,
  % event source
  SensorId INTEGER,
  EventTypId INTEGER,
  SensorButton INTEGER,
  % Action to be taken
  ActuatorId INTEGER,
  ActionId INTEGER,
  % If EnOceanId is set, radio message has to be sent,
  % otherwise we only account for the event (update state)
  EnOceanId INTEGER,
  ActionButton INTEGER);

INSERT INTO Actions VALUES(1,'On');
INSERT INTO Actions VALUES(2,'Off');
INSERT INTO Actions VALUES(3,'Toggle');

INSERT INTO EventType VALUES(1,'ButtonPressed');
INSERT INTO EventType VALUES(2,'ButtonReleased');

INSERT INTO SensorTyp VALUES(1,'Schalter 4fach');

INSERT INTO ActuatorTyp VALUES(1,'REGS24/01', 4);
INSERT INTO ActuatorTyp VALUES(2,'REGS24/02', 8);
INSERT INTO ActuatorTyp VALUES(3,'REGJ24/01', 4);
INSERT INTO ActuatorTyp VALUES(4,'UPS230/08', 1);
INSERT INTO ActuatorTyp VALUES(5,'UPS230/10', 1);
INSERT INTO ActuatorTyp VALUES(6,'UPS230/12', 2);
INSERT INTO ActuatorTyp VALUES(7,'UPD230/01', 1);
INSERT INTO ActuatorTyp VALUES(8,'UPJ230/12', 1);

INSERT INTO Sensors VALUES(1223706,	1, 'Bastelraum Alex/Waschküche');
INSERT INTO Sensors VALUES(1136502,	1, 'Keller/Bastelraum Myly');
INSERT INTO Sensors VALUES(1145476,	1, 'Haustüre (für Innen)');
INSERT INTO Sensors VALUES(1134685,	1, 'Haustüre (für Aussen), Alles aus');
INSERT INTO Sensors VALUES(1136735,	1, 'Bad EG');
INSERT INTO Sensors VALUES(1140874,	1, 'Treppe EG/UG');
INSERT INTO Sensors VALUES(1223600,	1, 'Büro');
INSERT INTO Sensors VALUES(1223734,	1, 'Durchgang Küche/Essen');
INSERT INTO Sensors VALUES(1151006,	1, 'Durchgang Wohnen/Essen');
INSERT INTO Sensors VALUES(1139008,	1, 'Schiebefenster Essen');
INSERT INTO Sensors VALUES(1224181,	1, 'Rollladen Schiebefenster Essen');
INSERT INTO Sensors VALUES(1223651,	1, 'Rolladen Schiebefenster Wohnen');
INSERT INTO Sensors VALUES(1249054,	1, 'Kaffemaschine');
INSERT INTO Sensors VALUES(39384,	1, 'Garagentorkontakt');
INSERT INTO Sensors VALUES(1210243,	1, 'Treppe OG/EG');
INSERT INTO Sensors VALUES(1153576,	1, 'Eltern Galerie');
INSERT INTO Sensors VALUES(1224208,	1, 'Rolladen Galerie');
INSERT INTO Sensors VALUES(1150619,	1, 'Elternzimmer');
INSERT INTO Sensors VALUES(1146012,	1, 'Bett Alex');
INSERT INTO Sensors VALUES(1145837,	1, 'Bett Myly');
INSERT INTO Sensors VALUES(1223730,	1, 'Elternzimmer/Bad');
INSERT INTO Sensors VALUES(1135145,	1, 'Bad OG');
INSERT INTO Sensors VALUES(1145877,	1, 'Zimmer Robin');
INSERT INTO Sensors VALUES(1150905,	1, 'Zimmer Lana');
INSERT INTO Sensors VALUES(1210928,	1, 'Gallerie vor Bad OG');
INSERT INTO Sensors VALUES(4286583038, 1, 'Präsenzmelder Wohnzimmer');
INSERT INTO Sensors VALUES(4286583036, 1, 'Präsenzmelder Aussen Haustüre');

INSERT INTO Actuators (GroupId, Channel, ActuatorTypId, Description, State) VALUES(96, 0, 3, 'Rollladen Küche', 0);
INSERT INTO Actuators (GroupId, Channel, ActuatorTypId, Description, State) VALUES(96, 1, 3, 'Rollladen Essen', 0);
INSERT INTO Actuators (GroupId, Channel, ActuatorTypId, Description, State) VALUES(96, 2, 3, 'Rollladen Wohnen (gross)', 0);
INSERT INTO Actuators (GroupId, Channel, ActuatorTypId, Description, State) VALUES(96, 3, 3, 'Rollladen Balkon OG', 0);

INSERT INTO Actuators (GroupId, Channel, ActuatorTypId, Description, State) VALUES(97, 0, 2, 'Seilbeleuchtung Galerie', 0);
INSERT INTO Actuators (GroupId, Channel, ActuatorTypId, Description, State) VALUES(97, 1, 2, 'unknown', 0);
INSERT INTO Actuators (GroupId, Channel, ActuatorTypId, Description, State) VALUES(97, 2, 2, 'Zimmer Lana', 0);
INSERT INTO Actuators (GroupId, Channel, ActuatorTypId, Description, State) VALUES(97, 3, 2, 'Zimmer Robin', 0);
INSERT INTO Actuators (GroupId, Channel, ActuatorTypId, Description, State) VALUES(97, 4, 2, 'Terrasse Garage', 0);
INSERT INTO Actuators (GroupId, Channel, ActuatorTypId, Description, State) VALUES(97, 5, 2, 'Tor Garage', 0);
INSERT INTO Actuators (GroupId, Channel, ActuatorTypId, Description, State) VALUES(97, 6, 2, 'Elternzimmer', 0);
INSERT INTO Actuators (GroupId, Channel, ActuatorTypId, Description, State) VALUES(97, 7, 2, 'Spiegel Bad OG', 0);

INSERT INTO Actuators (GroupId, Channel, ActuatorTypId, Description, State) VALUES(98, 0, 2, 'Spot Gang EG', 0);
INSERT INTO Actuators (GroupId, Channel, ActuatorTypId, Description, State) VALUES(98, 1, 2, 'Lampe Balkonuntersicht', 0);
INSERT INTO Actuators (GroupId, Channel, ActuatorTypId, Description, State) VALUES(98, 2, 2, 'Spot WC EG', 0);
INSERT INTO Actuators (GroupId, Channel, ActuatorTypId, Description, State) VALUES(98, 3, 2, 'Wand Treppe EG-OG', 0);
INSERT INTO Actuators (GroupId, Channel, ActuatorTypId, Description, State) VALUES(98, 4, 2, 'Vorplatz UG / Wand Treppe EG-UG', 0);
INSERT INTO Actuators (GroupId, Channel, ActuatorTypId, Description, State) VALUES(98, 5, 2, 'Gang??', 0);
INSERT INTO Actuators (GroupId, Channel, ActuatorTypId, Description, State) VALUES(98, 6, 2, 'Seilbeleuchtung Treppe', 0);
INSERT INTO Actuators (GroupId, Channel, ActuatorTypId, Description, State) VALUES(98, 7, 2, 'Spot Bad OG', 0);

INSERT INTO Actuators (GroupId, Channel, ActuatorTypId, Description, State) VALUES(99, 0, 2, 'Büro EG', 0);
INSERT INTO Actuators (GroupId, Channel, ActuatorTypId, Description, State) VALUES(99, 1, 2, 'Spot Küche', 0);
INSERT INTO Actuators (GroupId, Channel, ActuatorTypId, Description, State) VALUES(99, 2, 2, 'Essen', 0);
INSERT INTO Actuators (GroupId, Channel, ActuatorTypId, Description, State) VALUES(99, 3, 2, 'Spot Wohnen', 0);
INSERT INTO Actuators (GroupId, Channel, ActuatorTypId, Description, State) VALUES(99, 4, 2, 'Aussenlicht Balkon', 0);
INSERT INTO Actuators (GroupId, Channel, ActuatorTypId, Description, State) VALUES(99, 5, 2, 'Spot Windfang', 0);
INSERT INTO Actuators (GroupId, Channel, ActuatorTypId, Description, State) VALUES(99, 6, 2, 'Elternzimmer Wandlampe Alex', 0);
INSERT INTO Actuators (GroupId, Channel, ActuatorTypId, Description, State) VALUES(99, 7, 2, 'Elternzimmer Wandlampe Myly', 0);

INSERT INTO Actuators (GroupId, Channel, ActuatorTypId, Description, State) VALUES(100, 0, 3, 'Rollladen Wohnen (klein)', 0);

INSERT INTO Actuators (GroupId, Channel, ActuatorTypId, Description, State) VALUES(110, 0, 2, 'Aussenscheinwerfer', 0);
INSERT INTO Actuators (GroupId, Channel, ActuatorTypId, Description, State) VALUES(110, 1, 2, 'Hobbyraum rechts', 0);
INSERT INTO Actuators (GroupId, Channel, ActuatorTypId, Description, State) VALUES(110, 2, 2, 'Garage', 0);
INSERT INTO Actuators (GroupId, Channel, ActuatorTypId, Description, State) VALUES(110, 3, 2, 'Keller', 0);
INSERT INTO Actuators (GroupId, Channel, ActuatorTypId, Description, State) VALUES(110, 4, 2, 'Hobbyraum mitte', 0);
INSERT INTO Actuators (GroupId, Channel, ActuatorTypId, Description, State) VALUES(110, 5, 2, 'Waschküche', 0);
INSERT INTO Actuators (GroupId, Channel, ActuatorTypId, Description, State) VALUES(110, 6, 2, 'Steckdose Wohnen', 0);
INSERT INTO Actuators (GroupId, Channel, ActuatorTypId, Description, State) VALUES(110, 7, 2, 'Spiegel Bad EG', 0);

INSERT INTO Actuators (GroupId, Channel, ActuatorTypId, Description, State) VALUES(111, 0, 1, 'Reserve', 0);
INSERT INTO Actuators (GroupId, Channel, ActuatorTypId, Description, State) VALUES(111, 1, 1, 'Reduit', 0);
INSERT INTO Actuators (GroupId, Channel, ActuatorTypId, Description, State) VALUES(111, 2, 1, 'Küche Untersicht', 0);

INSERT INTO xEventAction
  (SensorId, EventTypId, SensorButton, ActuatorId, ActionId, EnOceanId, ActionButton)
VALUES
  (1249054, 1, 1, 1, 1, NULL, NULL);

INSERT INTO xEventAction
  (SensorId, EventTypId, SensorButton, ActuatorId, ActionId, EnOceanId, ActionButton)
VALUES
  (1249054, 1, 0, 1, 2, NULL, NULL);

COMMIT;

