import psycopg2
import sys
from collections import OrderedDict

def q3(conn,key):
  cur = conn.cursor()
  query = '''
    select b.name, T2C.code from classes cl 
    join
    (select c.id, s.code from courses c
    join subjects s on s.id = c.subject_id   
    where term_id = 5196 and s.code ~* '^{}.*') as T2C
    on T2C.id = cl.course_id
    join meetings m on m.class_id = cl.id
    join rooms r on r.id = m.room_id
    join buildings b on b.id = r.within
    group by b.name, T2C.code
    order by b.name, T2C.code;
  '''.format(key)

  # execute queury 
  cur.execute(query)
  rows = cur.fetchall()

  #store into a Ordered dict
  result = OrderedDict()
  for (building, code) in rows:
    if not building in result.keys():
      result[building] = [code]
    else:
      result[building].append(code)
  
  #print result
  for key, codes in result.items():
    print(key)
    for code in codes:
      print(" " + code)

def connect(key):
  try:
    conn = psycopg2.connect("dbname=a3 user=postgres password=chenqq227") #TODO: delete

    #run q3
    q3(conn, key)

    conn.close()
  except Exception as e:
    print("Couldn't connect the database.", e)

if __name__ == "__main__":
  # get incommon number from command line
  key = 'ENGG'
  if len(sys.argv) > 1:
    key = sys.argv[1]
  connect(key)