import psycopg2
import sys

def q5(conn,key):
  cur = conn.cursor()
  query = '''
    select ct.name as type, c.tag, ce.num, c.quota from classes c
    join classEnroll ce on c.id = ce.class_id
    join classtypes ct on ct.id = c.type_id
    join courses cr on cr.id = c.course_id
    join subjects s on cr.subject_id = s.id
    where s.code = '{}';
  '''.format(key)

  # execute queury 
  cur.execute(query)
  rows = cur.fetchall()

  result = []
  for (class_type, tag, num, quota) in rows:
    if (num/quota) < 0.5:
      result.append( (class_type, tag, num/quota) )

  #print result
  for class_type, tag, percen in sorted(result, key=lambda x:(x[0], x[1], x[2])):
    print("{0} {1} is {2:.0%} full".format(class_type, tag.strip(), percen))
    
    
def connect(key):
  try:
    conn = psycopg2.connect("dbname=a3 user=postgres password=chenqq227") #TODO: delete

    #run q5
    q5(conn, key)

    conn.close()
  except Exception as e:
    print("Couldn't connect the database.", e)

if __name__ == "__main__":
  # get incommon number from command line
  key = 'COMP1521'
  if len(sys.argv) > 1:
    key = sys.argv[1]
  connect(key)