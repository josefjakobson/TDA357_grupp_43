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
