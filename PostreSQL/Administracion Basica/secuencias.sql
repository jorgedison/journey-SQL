SELECT MAX(iapplicationid) FROM application;

SELECT nextval('application_seq');

SELECT setval('application_seq', (SELECT MAX(iapplicationid) FROM application));
 
SELECT setval('application_seq', COALESCE((SELECT MAX(iapplicationid)+1 FROM application), 1), false);
