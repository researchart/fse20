ENDING EVENTS
and (event = 8 or event = 12 or event = 13)

FAILED COMPILES
and (event = 9)

CODE START AND CODE ENDS
and (event = 8 or event = 12 or event = 13 or event = 6)

OVERALL START AND FINISH
and (event = 1 or event = 11)

ALL START EVENTS AND END
and (event = 1 or event = 5 or event = 6 or event = 11)

CLEAR DATABASE OUT
UPDATE language SET Lang1=0, Lang2=0;
DELETE FROM events WHERE 1;
DELETE FROM participants WHERE 1;
DELETE FROM survey WHERE 1;