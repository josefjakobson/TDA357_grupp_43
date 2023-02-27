CREATE VIEW CourseQueuePositions AS
    SELECT
    course, student, position AS place FROM WaitingList;



-- TRIGGERS

    SELECT COUNT(*) FROM PrerequisiteCourses LEFT JOIN PassedCourses
    ON  PassedCourses.student = '1111111111' AND PassedCourses.course = prerequisite
    WHERE  PrerequisiteCourses.prerequisite = 'CCC444' AND PassedCourses.student is NULL;







CREATE OR REPLACE FUNCTION add_to_waiting_list() RETURNS TRIGGER AS $add_to_waiting_list$
    BEGIN
    /*IF EXISTS (SELECT student
    FROM Registrations
    WHERE student = NEW.student AND course = NEW.course)
        THEN
        RAISE EXCEPTION 'you are already registered for this course.';
    END IF;*/
    IF (SELECT COUNT(*) 
    FROM PrerequisiteCourses LEFT JOIN PassedCourses 
    ON PassedCourses.student = NEW.student AND PassedCourses.course = prerequisite
    WHERE PrerequisiteCourses.prerequisite = NEW.course AND PassedCourses.student IS NULL) > 0 
        THEN
        RAISE EXCEPTION 'You have not read all the prerequistes for this particular course.';
    END IF;
    /*IF EXISTS (SELECT code 
    FROM LimitedCourses
    WHERE code = NEW.course) AND (SELECT COUNT(student)
    FROM Registrations
    WHERE course = NEW.course AND status = 'registered') >= (SELECT capacity FROM LimitedCourses
    WHERE code = NEW.course)
        THEN
        RAISE EXCEPTION 'The course is full.';
    END IF;*/
    RETURN NULL;
    END;
    
$add_to_waiting_list$ LANGUAGE plpgsql;


CREATE TRIGGER add_to_waiting_list INSTEAD OF INSERT OR UPDATE ON Registrations
    FOR EACH ROW EXECUTE FUNCTION add_to_waiting_list();
