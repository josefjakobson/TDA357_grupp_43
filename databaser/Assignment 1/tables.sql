CREATE TABLE Students(
    idnr INT PRIMARY KEY,
    name TEXT NOT NULL,
    login TEXT NOT NULL,
    program TEXT NOT NULL
);

CREATE TABLE Branches(
    name TEXT PRIMARY KEY,
    program TEXT NOT NULL
);

CREATE TABLE Courses(
    code TEXT PRIMARY KEY,
    name TEXT NOT NULL,
    credits TEXT NOT NULL,
    department TEXT NOT NULL
);

CREATE TABLE LimitedCourses(
    code TEXT PRIMARY KEY,
    capacity 
);