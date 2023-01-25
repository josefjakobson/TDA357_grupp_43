/*BasicInformation(idnr, name, login, program, branch)

FinishedCourses(student, course, grade, credits)

PassedCourses(student, course, credits)

Registrations(student, course, status)

UnreadMandatory(student, course)

PathToGraduation(student, totalCredits, mandatoryLeft, mathCredits, researchCredits, seminarCourses, qualified)

ALL VIEWS
*/

CREATE VIEW BasicInformation AS
SELECT Students, StudentBranches
JOIN Students ON StudentBranches.branch WHERE StudentBranches.student = Students.idnr

CREATE VIEW FinishedCourses AS
SELECT student, course, grade, credits
FROM Taken, Courses
WHERE condition???;

CREATE VIEW PassedCourses AS
SELECT student, course, credits
FROM FinishedCourses
WHERE condition???;

CREATE VIEW Registrations AS
SELECT student, course, status
FROM Registered /*status är jag fundersam över*/
WHERE condition???;

CREATE VIEW UnreadMandatory AS
SELECT student, course
FROM /*osäker*/
WHERE condition???;

CREATE VIEW PathToGraduation AS
SELECT /*osäker*/
FROM /*osäker*/
WHERE /*osäker*/;