CREATE TABLE Students(
    idnr TEXT PRIMARY KEY,
    name TEXT NOT NULL,
    login TEXT NOT NULL UNIQUE,
    program TEXT REFERENCES Programs(name)
);

CREATE TABLE Branches(
    name TEXT NOT NULL,
    program TEXT REFERENCES Programs(name)
    PRIMARY KEY(name,program)
);

CREATE TABLE Courses(
    code CHAR(6) PRIMARY KEY,
    name TEXT NOT NULL,
    credits FLOAT NOT NULL CHECK (credits > 0),
    department TEXT REFRENCES Departments(name)
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
    PRIMARY KEY(student)
);

CREATE TABLE Programs(
    name TEXT PRIMARY KEY,
    abbr TEXT NOT NULL UNIQUE
);

CREATE TABLE Departments(
    name TEXT PRIMARY KEY,
    abbr TEXT NOT NULL UNIQUE
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
    position INT NOT NULL,
    UNIQUE(position, course)
    PRIMARY KEY(student, course)

);

