import psycopg2
import sys
from collections import OrderedDict

def q4(conn,key):
  cur = conn.cursor()
  query = '''
    select t.name as term_name, s.code, n.num from terms t 
    join courses c on c.term_id = t.id
    join subjects s on s.id = c.subject_id
    join NumEnroll n on c.id = n.course_id
    where s.code ~* '^{}.*'
    order by term_name, s.code;
  '''.format(key)

  # execute queury 
  cur.execute(query)
  rows = cur.fetchall()

  #store into a Ordered dict
  result = OrderedDict()
  # e.g
  # {
  #   'Term':[(code, num of enroll)]
  # }
  for (term, code, num) in rows:
    if not term in result.keys():
      result[term] = [(code, num)]
    else:
      result[term].append((code,num))
  
  #print result
  for key, pairs in result.items():
    print(key)
    for code, num in pairs:
      print(" " + code + "("+str(num)+")")

def connect(key):
  try:
    conn = psycopg2.connect("dbname=a3") 

    #run q4
    q4(conn, key)

    conn.close()
  except Exception as e:
    print("Couldn't connect the database.", e)

if __name__ == "__main__":
  # get incommon number from command line
  key = 'ENGG'
  if len(sys.argv) > 1:
    key = sys.argv[1]
  connect(key)
