import psycopg2


class PortalConnection:
    def __init__(self):
        self.conn = psycopg2.connect(
            host="localhost",
            user="postgres",
            password="Fik6r3Nc")
        self.conn.autocommit = True

    def getInfo(self,student):
      with self.conn.cursor() as cur:
        # Here's a start of the code for this part
        sql = """
                SELECT jsonb_build_object(
                     'student', s.idnr
                    ,'name', s.name
                ) :: TEXT
                FROM BasicInformation AS s
                WHERE s.idnr = %s;"""
        cur.execute(sql, (student,))
        res = cur.fetchone()
        if res:
            return (str(res[0]))
        else:
            return """{"student":"Not found :("}"""

    def register(self, student, courseCode):
        query = f"INSERT INTO Registrations Values('{student}', '{courseCode}')"
        with self.conn.cursor() as cursor:
            try:
                cursor.execute(query)
                return '{"success":true}'
            except psycopg2.Error as e:
                message = getError(e)
                return '{"success":false, "error": "'+message+'"}'

    def unregister(self, student, courseCode):
        query = f"DELETE FROM Registrations WHERE student = '{student}' AND course = '{courseCode}'"
        with self.conn.cursor() as cursor:
            try:
                cursor.execute(query)
                return '{"success":true}'
            except psycopg2.Error as e:
                message = getError(e)
                return '{"success":false, "error": "'+message+'"}'

def getError(e):
    message = repr(e)
    message = message.replace("\\n"," ")
    message = message.replace("\"","\\\"")
    return message

