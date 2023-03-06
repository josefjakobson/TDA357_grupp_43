CREATE VIEW CourseQueuePositions AS
    SELECT
    course, student, position AS place FROM WaitingList;



-- TRIGGERS



CREATE OR REPLACE FUNCTION add_to_waiting_list() RETURNS TRIGGER AS $add_to_waiting_list$
    DECLARE newposition INT;
    
    BEGIN
    IF EXISTS (SELECT student
    FROM Registrations
    WHERE student = NEW.student AND course = NEW.course)
        THEN
        RAISE EXCEPTION 'You are already registered for this course.'; END IF;

    IF EXISTS (SELECT student
    FROM Taken
    WHERE student = NEW.student AND course = NEW.course)
        THEN
        RAISE EXCEPTION 'You have already taken this course.'; END IF;

    IF (SELECT COUNT(*) 
    FROM PrerequisiteCourses LEFT JOIN PassedCourses 
    ON PassedCourses.student = NEW.student AND PassedCourses.course = prerequisite
    WHERE PrerequisiteCourses.course = NEW.course AND PassedCourses.student IS NULL) > 0
        THEN
        RAISE EXCEPTION 'You have not read all the prerequistes for this particular course.'; END IF;

        RAISE EXCEPTION 'You have not read all the prerequistes for this particular course.'; END IF;

    IF EXISTS (SELECT code 
    FROM LimitedCourses
    WHERE code = NEW.course) AND (SELECT COUNT(student)
    FROM Registrations
    WHERE course = NEW.course AND status = 'registered') >= (SELECT capacity FROM LimitedCourses
    WHERE code = NEW.course)
        THEN
        SELECT COALESCE(MAX(position), 0) + 1   -- Selects the first available queue position.
        INTO newposition
        FROM WaitingList
        WHERE course = NEW.course;
        INSERT INTO WaitingList VALUES (NEW.student, NEW.course, newposition); END IF;
    
    IF NOT EXISTS (SELECT * FROM WaitingList WHERE NEW.student = WaitingList.student AND WaitingList.course = NEW.course) THEN
    INSERT INTO Registered VALUES (NEW.student, NEW.course); END IF;
    RETURN NULL;
    END;
$add_to_waiting_list$ LANGUAGE plpgsql;


CREATE TRIGGER add_to_waiting_list INSTEAD OF INSERT OR UPDATE ON Registrations
    FOR EACH ROW EXECUTE FUNCTION add_to_waiting_list();


CREATE FUNCTION remove_from_waiting_list() RETURNS trigger AS $remove_from_waiting_list$
    BEGIN

        IF EXISTS (SELECT * FROM Registered WHERE OLD.student = Registered.student AND Registered.course = OLD.course) THEN
        DELETE FROM Registered WHERE OLD.student = Registered.student AND Registered.course = OLD.course; END IF;
        
        IF EXISTS (SELECT * FROM WaitingList WHERE OLD.student = WaitingList.student AND WaitingList.course = OLD.course) THEN
        DELETE FROM WaitingList WHERE OLD.student = WaitingList.student AND WaitingList.course = OLD.course; END IF;

        IF (SELECT COUNT(student) FROM Registered WHERE Registered.course = OLD.course) < 
           (SELECT capacity FROM LimitedCourses WHERE OLD.course = LimitedCourses.code) 
            THEN
            INSERT INTO Registered SELECT student, course FROM WaitingList WHERE WaitingList.course = OLD.course AND WaitingList.position = 1;
            DELETE FROM WaitingList WHERE OLD.course = WaitingList.course AND WaitingList.position = 1;
        END IF;
    RETURN NULL;
    END;
$remove_from_waiting_list$ LANGUAGE plpgsql;

CREATE TRIGGER remove_from_waiting_list INSTEAD OF DELETE ON Registrations
    FOR EACH ROW EXECUTE FUNCTION remove_from_waiting_list();

