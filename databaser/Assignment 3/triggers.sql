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
        RAISE EXCEPTION 'You are already registered for this course.';
    END IF;
    
    IF EXISTS (SELECT student
    FROM Taken
    WHERE student = NEW.student AND course = NEW.course)
        THEN
        RAISE EXCEPTION 'You have already taken this course.';
    END IF;
    
    IF (SELECT COUNT(*) 
    FROM PrerequisiteCourses LEFT JOIN Taken 
    ON Taken.student = NEW.student AND Taken.course = prerequisite
    WHERE PrerequisiteCourses.prerequisite = NEW.course AND Taken.student IS NULL) > 0
        THEN
        RAISE EXCEPTION 'You have not read all the prerequistes for this particular course.';
    END IF;
    
    IF EXISTS (SELECT code 
    FROM LimitedCourses
    WHERE code = NEW.course) AND (SELECT COUNT(student)
    FROM Registrations
    WHERE course = NEW.course AND status = 'registered') >= (SELECT capacity FROM LimitedCourses
    WHERE code = NEW.course)
        
        THEN

        SELECT COALESCE(MAX(position), 0) + 1
        INTO newposition
        FROM WaitingList
        WHERE course = NEW.course;

        UPDATE WaitingList
        SET student = NEW.student, course = NEW.course
        WHERE position = newposition AND course = NEW.course;
        
    END IF;
    RETURN NULL;
    END;
    
$add_to_waiting_list$ LANGUAGE plpgsql;

/*CREATE FUNCTION remove_from_waiting_list() RETURNS trigger AS $$
    BEGIN
        DELETE FROM Registered WHERE OLD.student = Registered.student;
        IF (SELECT COUNT(student) FROM Registrations WHERE OLD.course = Registrations.course) < (SELECT capacity FROM LimitedCourses WHERE OLD.course = LimitedCourses.course) THEN
            INSERT INTO Registered VALUES (SELECT student, course FROM WaitingList WHERE WaitingList.student = OLD.student AND WaitingList.course = OLD.course)
    END;
$$ LANGUAGE plpgsql;*/

CREATE TRIGGER add_to_waiting_list INSTEAD OF INSERT OR UPDATE ON Registrations
    FOR EACH ROW EXECUTE FUNCTION add_to_waiting_list();
