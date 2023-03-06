-- TEST #1: Register for an unlimited course.
-- EXPECTED OUTCOME: Pass
SELECT * FROM Registrations;

INSERT INTO Registrations VALUES ('4444444444', 'CCC555'); 

-- TEST #2: Register an already registered student.
-- EXPECTED OUTCOME: Fail
--INSERT INTO Registrations VALUES ('1111111111', 'CCC111'); 

-- TEST #3: Unregister from an unlimited course. 
-- EXPECTED OUTCOME: Pass
DELETE FROM Registrations WHERE student = '1111111111' AND course = 'CCC111';

-- TEST #4: Register to a limited course with places left
-- EXPECTED OUTCOME: Pass
INSERT INTO Registrations VALUES ('1111111111', 'CCC444'); 

-- TEST #5: Register to a limited course which is full (student should be added to waitinglist)
-- EXPECTED OUTCOME: Pass
INSERT INTO Registrations VALUES ('1111111111', 'CCC666'); 

-- TEST #6: Remove from Waiting List
-- EXPECTE OUTCOME: Pass
DELETE FROM Registrations WHERE student = '2222222222' AND course = 'CCC333';

-- TEST #7: Unregister from Limited course with empty waiting list
-- EXPECTE OUTCOME: Pass
DELETE FROM Registrations WHERE student = '1111111111' AND course = 'CCC666';

SELECT * FROM WaitingList;

-- TEST #8: Unregister from Limited course with waiting list
-- EXPECTE OUTCOME: Pass
DELETE FROM Registrations WHERE student = '5555555555' AND course = 'CCC333';
SELECT * FROM WaitingList;

SELECT * FROM WaitingList;


