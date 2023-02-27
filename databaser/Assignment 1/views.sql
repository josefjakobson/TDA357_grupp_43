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
    student, 
    course, 
    'registered' AS status 
    FROM Registered
    UNION
    SELECT 
    student, 
    course, 
    'waiting' AS status 
    FROM WaitingList;


CREATE VIEW MandatoryCourses AS
    SELECT
    StudentBranches.student, 
    MandatoryBranch.course AS course
    FROM StudentBranches, MandatoryBranch
    WHERE StudentBranches.branch = MandatoryBranch.branch
    AND StudentBranches.program = MandatoryBranch.program
    UNION
    SELECT 
    idnr, 
    MandatoryProgram.course
    FROM BasicInformation, MandatoryProgram
    WHERE BasicInformation.program = MandatoryProgram.program;

CREATE VIEW UnreadMandatory AS
    SELECT
    student,
    course
    FROM MandatoryCourses
    EXCEPT 
    SELECT 
    student, 
    course
    FROM PassedCourses;

CREATE VIEW TotalCredits AS
    SELECT 
    PassedCourses.student AS student, 
    COALESCE(SUM(credits), 0) AS credits
    FROM PassedCourses
    Group by student;

CREATE VIEW MandatoryLeft AS
    SELECT 
    UnreadMandatory.student, 
    COUNT(course) as mandatoryleft
    FROM UnreadMandatory
    Group by student;

CREATE VIEW MathCredits AS
    SELECT 
    PassedCourses.student, 
    SUM(credits) as credits
    FROM PassedCourses, Classified
    WHERE PassedCourses.course = Classified.course
    AND Classified.classification = 'math'
    Group by student;



CREATE VIEW ResearchCredits AS
    SELECT 
    PassedCourses.student, 
    SUM(credits) as credits
    FROM PassedCourses, Classified
    WHERE PassedCourses.course = Classified.course
    AND Classified.classification = 'research'
    Group by student;


CREATE VIEW SeminarCourses AS
    SELECT 
    PassedCourses.student, 
    COUNT(PassedCourses.course)
    FROM PassedCourses, Classified
    WHERE PassedCourses.course = Classified.course
    AND Classified.classification = 'seminar'
    Group by student;


CREATE VIEW RecommendedCourses AS
    SELECT
    StudentBranches.student, 
    RecommendedBranch.course AS course,
    Courses.credits
    FROM StudentBranches, RecommendedBranch, Courses
    WHERE StudentBranches.branch = RecommendedBranch.branch AND RecommendedBranch.course = Courses.code
    AND StudentBranches.program = RecommendedBranch.program;


CREATE VIEW ReadRecommended AS
    SELECT
    student,
    course, 
    credits
    FROM RecommendedCourses
    INTERSECT 
    SELECT 
    student, 
    course,
    Courses.credits
    FROM PassedCourses, Courses;

CREATE VIEW RecommendedCredits AS
    SELECT 
    ReadRecommended.student, 
    SUM(credits)
    FROM ReadRecommended
    Group by student;

    
CREATE VIEW RequirementsForGraduation AS
    SELECT idnr AS student, 
    COALESCE(TotalCredits.credits, 0) AS totalcredits,
    COALESCE(MandatoryLeft.mandatoryleft, 0) AS mandatoryleft,
    COALESCE(MathCredits.credits, 0) AS mathcredits,
    COALESCE(ResearchCredits.credits, 0) AS researchcredits,
    COALESCE(SeminarCourses.count, 0) AS seminarcourses,
    COALESCE(RecommendedCredits.sum, 0) AS recommendedcredits
    FROM Students
    LEFT JOIN TotalCredits ON idnr = TotalCredits.student
    LEFT JOIN MandatoryLeft ON idnr = MandatoryLeft.student
    LEFT JOIN MathCredits ON idnr = MathCredits.student
    LEFT JOIN ResearchCredits ON idnr = ResearchCredits.student
    LEFT JOIN seminarCourses ON idnr = SeminarCourses.student
    LEFT JOIN RecommendedCredits ON idnr = RecommendedCredits.student
    ORDER BY student;


CREATE VIEW Qualified AS
    SELECT
    RequirementsForGraduation.student,
    CASE
        WHEN RequirementsForGraduation.mandatoryleft = 0 AND
            RequirementsForGraduation.recommendedcredits >= 10 AND
            RequirementsForGraduation.mathcredits >= 20 AND
            RequirementsForGraduation.researchcredits >= 10 AND
            RequirementsForGraduation.seminarcourses > 0 THEN true
        ELSE false
    END AS qualified
    FROM RequirementsForGraduation
    ORDER BY student;

CREATE VIEW PathToGraduation AS
    SELECT
    RequirementsForGraduation.student,
    RequirementsForGraduation.totalcredits,
    RequirementsForGraduation.mandatoryleft,
    RequirementsForGraduation.mathcredits,
    RequirementsForGraduation.researchcredits,
    RequirementsForGraduation.seminarcourses,
    Qualified.qualified
    FROM RequirementsForGraduation
    LEFT JOIN Qualified ON Qualified.student = RequirementsForGraduation.student;

CREATE VIEW CourseQueuePositions AS
    SELECT
    course, student, position AS place FROM WaitingList;



-- TRIGGERS

CREATE FUNCTION add_to_waiting_list() RETURNS trigger AS $add_to_waiting_list$
    BEGIN
        RAISE EXCEPTION 'test';
    END;
$add_to_waiting_list$ LANGUAGE plpgsql;


CREATE TRIGGER add_to_waiting_list INSTEAD OF INSERT OR UPDATE ON Registrations
    FOR EACH ROW EXECUTE FUNCTION add_to_waiting_list();
CREATE VIEW CourseQueuePositions AS
    SELECT 
    WaitingList.student AS student,
    WaitingList.course AS course,
    WaitingList.position AS place
    FROM WaitingList
