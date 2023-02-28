CREATE VIEW CourseQueuePositions AS
    SELECT
    course, student, position AS place FROM WaitingList;



-- TRIGGERS

CREATE FUNCTION add_to_waiting_list() RETURNS trigger AS $$
    BEGIN
        RAISE EXCEPTION 'test';
    END;
$$ LANGUAGE plpgsql;


CREATE TRIGGER add_to_waiting_list INSTEAD OF INSERT OR UPDATE ON Registrations
    FOR EACH ROW EXECUTE FUNCTION add_to_waiting_list();



CREATE FUNCTION remove_from_waiting_list() RETURNS trigger AS $$
    BEGIN
        DELETE FROM Registered WHERE OLD.student = Registered.student;
        IF (SELECT COUNT(student) FROM Registrations WHERE OLD.course = Registrations.course) < (SELECT capacity FROM LimitedCourses WHERE OLD.course = LimitedCourses.course) THEN
            INSERT INTO Registered VALUES (SELECT student, course FROM WaitingList WHERE WaitingList.student = OLD.student AND WaitingList.course = OLD.course)
    END;
$$ LANGUAGE plpgsql;
 
