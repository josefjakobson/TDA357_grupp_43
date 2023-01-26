CREATE TABLE Students(
    idnr TEXT PRIMARY KEY,
    name TEXT NOT NULL,
    login TEXT NOT NULL,
    program TEXT NOT NULL
);

CREATE TABLE Branches(
    name TEXT NOT NULL,
    program TEXT NOT NULL,
    PRIMARY KEY(name,program)
);

CREATE TABLE Courses(
    code CHAR(6) PRIMARY KEY,
    name TEXT NOT NULL,
    credits INT NOT NULL,
    department TEXT NOT NULL
);

CREATE TABLE LimitedCourses(
    code CHAR(6) REFERENCES Courses(code) UNIQUE,
    capacity INT NOT NULL
);

CREATE TABLE StudentBranches(
    student TEXT REFERENCES Students(idnr), 
    branch TEXT NOT NULL,
    program TEXT NOT NULL,
    FOREIGN KEY (branch, program) REFERENCES Branches(name, program),
    PRIMARY KEY(student)
);

 
CREATE TABLE Classifications(
    name TEXT PRIMARY KEY
);

CREATE TABLE Classified( 
    course CHAR(6) REFERENCES Courses(code),
    classification TEXT REFERENCES Classifications(name)

);
 
CREATE TABLE MandatoryProgram(
    course CHAR(6) REFERENCES Courses(code),
    program TEXT,
    PRIMARY KEY (course, program)
);

CREATE TABLE MandatoryBranch(
    course CHAR(6) REFERENCES Courses(code),
    program TEXT,
    branch TEXT,
    FOREIGN KEY (branch, program) REFERENCES Branches(name, program)

);

CREATE TABLE RecommendedBranch(
    course CHAR(6) REFERENCES Courses(code),
    program TEXT,
    branch TEXT,
    FOREIGN KEY (branch, program) REFERENCES Branches(name, program)
); 

CREATE TABLE Registered(
    student TEXT REFERENCES Students(idnr),
    course CHAR(6) REFERENCES Courses(code)
);

CREATE TABLE Taken(
    student TEXT REFERENCES Students(idnr),
    course CHAR(6) REFERENCES Courses(code),
    grade CHAR(1) NOT NULL
); 

CREATE TABLE WaitingList(-- position is either a SERIAL, a TIMESTAMP or the actual position 
    student TEXT REFERENCES Students(idnr),
    course CHAR(6) REFERENCES LimitedCourses(code),
    position INT NOT NULL

);

