/*BasicInformation(idnr, name, login, program, branch)

FinishedCourses(student, course, grade, credits)

PassedCourses(student, course, credits)

Registrations(student, course, status)

UnreadMandatory(student, course)

PathToGraduation(student, totalCredits, mandatoryLeft, mathCredits, researchCredits, seminarCourses, qualified)

ALL VIEWS
*/

CREATE VIEW BasicInformation AS
    SELECT 
    Students.idnr as idnr,
    Students.name as name,
    Students.login as login,
    Students.program as program,
    StudentBranches.branch as branch
    FROM Students
    LEFT JOIN StudentBranches ON idnr = student
    ORDER BY idnr;


CREATE VIEW FinishedCourses AS
    SELECT 
    Taken.student,
    Taken.course,
    Taken.grade,
    Courses.credits FROM Taken
    LEFT JOIN Courses ON Taken.course = Courses.code
    ORDER BY student;
    

CREATE VIEW PassedCourses AS
    SELECT 
    Taken.student AS student,
    Taken.course AS course,
    Courses.credits FROM Taken
    LEFT JOIN Courses ON Taken.course = Courses.code WHERE Taken.grade != 'U'
    ORDER BY student;


CREATE VIEW Registrations AS
    SELECT
    student, course, 'registered' AS status FROM Registered
    UNION
    SELECT student, course, 'waiting' AS status FROM WaitingList;

CREATE VIEW MandatoryCourses AS
    SELECT
    student, MandatoryBranch.course
    FROM StudentBranches, MandatoryBranch
    WHERE StudentBranches.branch = MandatoryBranch.branch
    AND StudentBranches.program = MandatoryBranch.program
    UNION
    SELECT student, MandatoryProgram.course
    FROM StudentBranches, MandatoryProgram
    WHERE StudentBranches.program = MandatoryProgram.program;
    
    
CREATE VIEW UnreadMandatory AS
    SELECT
    student, course
    FROM MandatoryCourses
    EXCEPT 
    SELECT 
    student, course
    FROM PassedCourses;

CREATE VIEW TotalCredits AS
    SELECT SUM(credits)
    FROM PassedCourses
    Group by student;

CREATE VIEW MandatoryLeft AS
    SELECT COUNT(course)
    FROM UnreadMandatory
    Group by student;

CREATE VIEW MathCredits AS
    SELECT SUM(credits)
    FROM PassedCourses, Classified
    WHERE PassedCourses.course = Classified.course
    AND Classified.classification = 'Math'
    Group by student;

/*CREATE VIEW ResearchCredits AS

CREATE VIEW SeminarCourses AS

CREATE VIEW PathToGraduation AS


CREATE VIEW Qualified AS*/
