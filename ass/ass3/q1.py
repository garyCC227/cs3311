import psycopg2
import time

def q1(conn):
  cur=conn.cursor()
  #get the courses as required
  # as term_id 5199 = 19T3
  solution_query='''
  select s.code, c.quota, e.num from courses c
  join Enrolled e on c.id = e.course_id
  join subjects s on c.subject_id = s.id
  where c.quota > 50 and c.term_id = 5199
        and e.num > c.quota
  order by s.code;
  '''
  cur.execute(solution_query)
  result_table=cur.fetchall()
  for row in result_table:
    print("{0} {1:.0%}".format(row[0], row[2]/row[1]))



def connect():
  try:
    conn = psycopg2.connect("dbname=a3 user=postgres password=chenqq227") #TODO: delete
    # run q1() for solutions
    q1(conn)
  except Exception as e:
    print("Couldn't connect to the database:", e)



if __name__ == "__main__":
  connect()
  
