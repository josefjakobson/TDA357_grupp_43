CREATE TABLE Students(
    idnr INT PRIMARY KEY,
    name TEXT NOT NULL,
    login TEXT NOT NULL,
    program CHAR(2) NOT NULL
);

CREATE TABLE Branches(
    name TEXT,
    program CHAR(2),
    PRIMARY KEY(name,program)
);

CREATE TABLE Courses(
    code CHAR(6) PRIMARY KEY,
    name TEXT NOT NULL,
    credits INT NOT NULL,
    department TEXT NOT NULL
);

CREATE TABLE LimitedCourses(
    code CHAR(6) REFERENCES Courses(code),
    capacity INT NOT NULL
);

CREATE TABLE StudentBranches(
    student INT REFERENCES Students(idnr), 
    branch TEXT REFERENCES Branches(name),
    program CHAR(2) REFERENCES Branches(program)
    );

 
CREATE TABLE Classifications(
    name TEXT PRIMARY KEY
);

Classified( 
    course CHAR(6) REFERENCES Courses(code),
    classification TEXT REFERENCES Classifications(name)

);
 
MandatoryProgram(
    course CHAR(6) REFERENCES Courses(code),
    program CHAR(2) REFERENCES Branches(program)
);

MandatoryBranch(
    course CHAR(6) REFERENCES Courses(code),
    branch TEXT REFERENCES Branches(name),
    program CHAR(2) REFERENCES Branches(program)
);

RecommendedBranch(
    course CHAR(6) REFERENCES Courses(code),
    branch TEXT REFERENCES Branches(name),
    program CHAR(2) REFERENCES Branches(program)
); 

Registered(
    student INT REFERENCES Students(idnr),
    course CHAR(6) REFERENCES Courses(code)
);

Taken(
    student INT REFERENCES Students(idnr),
    course CHAR(6) REFERENCES Courses(code),
    grade CHAR(1) NOT NULL
); 

WaitingList(-- position is either a SERIAL, a TIMESTAMP or the actual position 
    student INT REFERENCES Students(idnr),
    course CHAR(6) REFERENCES LimitedCourses(code),
    position INT NOT NULL

);

