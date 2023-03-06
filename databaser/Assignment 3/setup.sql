-- TABLES ----------------------------------------------------------------------------------------

CREATE TABLE Programs(
    name TEXT PRIMARY KEY,
    abbr TEXT NOT NULL
);

CREATE TABLE Departments(
    name TEXT PRIMARY KEY,
    abbr TEXT NOT NULL UNIQUE
);



CREATE TABLE Students(
    idnr TEXT PRIMARY KEY,
    name TEXT NOT NULL,
    login TEXT NOT NULL UNIQUE,
    program TEXT REFERENCES Programs(name),
    UNIQUE (idnr, program)
);

CREATE TABLE Branches(
    name TEXT NOT NULL,
    program TEXT REFERENCES Programs(name),
    PRIMARY KEY(name,program)
);

CREATE TABLE Courses(
    code CHAR(6) PRIMARY KEY,
    name TEXT NOT NULL,
    credits FLOAT NOT NULL CHECK (credits > 0),
    department TEXT REFERENCES Departments(name)
);

CREATE TABLE LimitedCourses(
    code CHAR(6) REFERENCES Courses(code) PRIMARY KEY,
    capacity INT NOT NULL CHECK (capacity > 0)
);

CREATE TABLE StudentBranches(
    student TEXT REFERENCES Students(idnr), 
    branch TEXT NOT NULL,
    program TEXT NOT NULL,
    FOREIGN KEY (branch, program) REFERENCES Branches(name, program),
    FOREIGN KEY (student, program) REFERENCES Students(idnr, program),
    PRIMARY KEY (student)
);

CREATE TABLE PrerequisiteCourses(
    course CHAR(6) REFERENCES Courses(code),
    prerequisite CHAR(6),
    PRIMARY KEY(course, prerequisite)
);

CREATE TABLE Classifications(
    name TEXT PRIMARY KEY
);

CREATE TABLE Classified( 
    course CHAR(6) REFERENCES Courses(code),
    classification TEXT REFERENCES Classifications(name),
    PRIMARY KEY(course, classification)
);
 
CREATE TABLE MandatoryProgram(
    course CHAR(6) REFERENCES Courses(code),
    program TEXT REFERENCES Programs(name),
    PRIMARY KEY (course, program)
);

CREATE TABLE MandatoryBranch(
    course CHAR(6) REFERENCES Courses(code),
    branch TEXT,
    program TEXT,
    FOREIGN KEY (branch, program) REFERENCES Branches(name, program),
    PRIMARY KEY(course, branch, program)
);

CREATE TABLE RecommendedBranch(
    course CHAR(6) REFERENCES Courses(code),
    branch TEXT,
    program TEXT,
    FOREIGN KEY (branch, program) REFERENCES Branches(name, program),
    PRIMARY KEY(course, branch, program)
); 

CREATE TABLE Registered(
    student TEXT REFERENCES Students(idnr),
    course CHAR(6) REFERENCES Courses(code),
    PRIMARY KEY(student, course)
);

CREATE TABLE Taken(
    student TEXT REFERENCES Students(idnr),
    course CHAR(6) REFERENCES Courses(code),
    grade CHAR(1) NOT NULL CHECK (grade IN ('U','3','4','5')),
    PRIMARY KEY(student, course)
); 

CREATE TABLE WaitingList(-- position is either a SERIAL, a TIMESTAMP or the actual position 
    student TEXT REFERENCES Students(idnr),
    course CHAR(6) REFERENCES LimitedCourses(code),
    position INT NOT NULL CHECK(position > 0),
    UNIQUE(position, course),
    PRIMARY KEY(student, course)

);

-- INSERTS ----------------------------------------------------------------------------------------

INSERT INTO Programs VALUES ('Prog1', 'P1');
INSERT INTO Programs VALUES ('Prog2', 'P2');
INSERT INTO Programs VALUES ('Prog3', 'P3');

INSERT INTO Departments VALUES ('Dep1', 'D1');
INSERT INTO Programs VALUES ('Dep2', 'D2');


INSERT INTO Branches VALUES ('B1','Prog1');
INSERT INTO Branches VALUES ('B2','Prog1');
INSERT INTO Branches VALUES ('B1','Prog2');
INSERT INTO Branches VALUES ('B3','Prog3');

INSERT INTO Students VALUES ('1111111111','N1','ls1','Prog1');
INSERT INTO Students VALUES ('2222222222','N2','ls2','Prog1');
INSERT INTO Students VALUES ('3333333333','N3','ls3','Prog2');
INSERT INTO Students VALUES ('4444444444','N4','ls4','Prog1');
INSERT INTO Students VALUES ('5555555555','Nx','ls5','Prog2');
INSERT INTO Students VALUES ('6666666666','Nx','ls6','Prog2');
INSERT INTO Students VALUES ('7777777777','Nx','ls7','Prog2');

INSERT INTO Courses VALUES ('CCC111','C1',22.5,'Dep1');
INSERT INTO Courses VALUES ('CCC222','C2',20,'Dep1');
INSERT INTO Courses VALUES ('CCC333','C3',30,'Dep1');
INSERT INTO Courses VALUES ('CCC444','C4',60,'Dep1');
INSERT INTO Courses VALUES ('CCC555','C5',50,'Dep1');
INSERT INTO Courses VALUES ('CCC666','C6',50,'Dep1');


INSERT INTO LimitedCourses VALUES ('CCC222',1);
INSERT INTO LimitedCourses VALUES ('CCC333',2);
INSERT INTO LimitedCourses VALUES ('CCC444',4);
INSERT INTO LimitedCourses VALUES ('CCC666',1);


INSERT INTO Classifications VALUES ('math');
INSERT INTO Classifications VALUES ('research');
INSERT INTO Classifications VALUES ('seminar');

INSERT INTO Classified VALUES ('CCC333','math');
INSERT INTO Classified VALUES ('CCC444','math');
INSERT INTO Classified VALUES ('CCC444','research');
INSERT INTO Classified VALUES ('CCC444','seminar');


INSERT INTO StudentBranches VALUES ('2222222222','B1','Prog1');
INSERT INTO StudentBranches VALUES ('3333333333','B1','Prog2');
INSERT INTO StudentBranches VALUES ('4444444444','B1','Prog1');
INSERT INTO StudentBranches VALUES ('5555555555','B1','Prog2');
--INSERT INTO StudentBranches VALUES ('6666666666','B3','Prog3'); Tests if constraint works


INSERT INTO MandatoryProgram VALUES ('CCC111','Prog1');

INSERT INTO MandatoryBranch VALUES ('CCC333', 'B1', 'Prog1');
INSERT INTO MandatoryBranch VALUES ('CCC444', 'B1', 'Prog2');

INSERT INTO RecommendedBranch VALUES ('CCC222', 'B1', 'Prog1');
INSERT INTO RecommendedBranch VALUES ('CCC333', 'B1', 'Prog2');

INSERT INTO Registered VALUES ('1111111111','CCC111');
INSERT INTO Registered VALUES ('1111111111','CCC222');
INSERT INTO Registered VALUES ('1111111111','CCC333');
INSERT INTO Registered VALUES ('2222222222','CCC222');
INSERT INTO Registered VALUES ('5555555555','CCC222');
INSERT INTO Registered VALUES ('5555555555','CCC333');
INSERT INTO Registered VALUES ('4444444444','CCC666');


INSERT INTO Taken VALUES('4444444444','CCC111','5');
INSERT INTO Taken VALUES('4444444444','CCC222','5');
INSERT INTO Taken VALUES('4444444444','CCC333','5');
INSERT INTO Taken VALUES('4444444444','CCC444','5');


INSERT INTO Taken VALUES('5555555555','CCC111','5');
INSERT INTO Taken VALUES('5555555555','CCC222','4');
INSERT INTO Taken VALUES('5555555555','CCC444','3');

INSERT INTO Taken VALUES('2222222222','CCC111','U');
INSERT INTO Taken VALUES('2222222222','CCC222','U');
INSERT INTO Taken VALUES('2222222222','CCC444','U');

INSERT INTO WaitingList VALUES('3333333333','CCC222',1);
INSERT INTO WaitingList VALUES('7777777777','CCC222',2);
INSERT INTO WaitingList VALUES('6666666666','CCC222',3);

INSERT INTO WaitingList VALUES('3333333333','CCC333',1);
INSERT INTO WaitingList VALUES('2222222222','CCC333',2);

INSERT INTO PrerequisiteCourses VALUES ('CCC555', 'CCC444');
INSERT INTO PrerequisiteCourses VALUES ('CCC555', 'CCC111');

-- VIEWS ----------------------------------------------------------------------------------------

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
    FROM WaitingList
    ORDER BY course;


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




