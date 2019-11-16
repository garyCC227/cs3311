import psycopg2
import sys

def q7(conn, key):
  # select term
  if key == '19T1':
    key = '1'
  elif key == '19T2':
    key = '2'
  elif key == '19T3':
    key = '3'
  else:
    raise ValueError("Invalid Term", key)

  cur = conn.cursor()
  query = '''
  select room, day, starting, ending, weeks from T{}rooms;
  '''.format(key)

  cur.execute(query)
  rows = cur.fetchall() #the rows is order by room, day, start_time, end_time
                        # so start_time of next row always >= start_time of previous
  store = dict()
  for room, day, start, end, wk in rows:
    if room in store.keys():
      store[room] += count_time((end-start), wk)   
    else:
      #first see this room
      #calculating total hour normally, and store data into dict 
      store[room] = count_time((end - start),wk)
      
  
  underused = 0
  for hours in store.values():
    if (hours/10) < 20:
      underused += 1
  
  # get total_rooms
  sum_query = '''
  select sum(count) from (
    (select count(*) from rooms where code ~* '^K-.*' group by id)) as Foo;
  '''
  cur.execute(sum_query)
  total_rooms = cur.fetchone()[0]
  
  #get how many rooms used in T?
  T_rooms_query = '''
  select count(*) from (
  (select distinct room from T{}rooms)) as Foo; 
  '''.format(key)
  cur.execute(T_rooms_query)
  T_rooms = cur.fetchone()[0]
  
  #unused room + underused room / total_ rooms
  result = ((total_rooms - T_rooms) + underused) / total_rooms
  print("{:.1%}".format(result))
  
# return as hours for wk1-10
def count_time(time, wk):
  count = 0
  # dont care about wk11
  for i in range(10):
    if wk[i] == '1':
      count += 1
  
  #calculating time
  hr = time // 100 * count 
  extra = 0.5 if (time % 100 == 30) or (time % 100 == 70) else 0
  extra *= count
  
  # return as hours
  return hr + extra
  
def connect(key):
  try:
    conn = psycopg2.connect("dbname=a3 ") #TODO: delete

    q7(conn, key)

    conn.close()
  except Exception as e:
    print("Cannot connect the database: ", e)


if __name__ == "__main__":
  key = '19T1'
  if len(sys.argv) > 1:
    key = sys.argv[1]
  connect(key)

  
# def get_no_overlap(start, end, wk, classes):
#   final_wk = list(wk)
#   for old_start, old_end, old_wk in classes:
#     # if overlap
#     if old_start <= start and start < old_end:
      
      

# def extra_time(end, old_end):
#   extra = end - old_end
#   if extra <= 0:
#     return 0
#   else:
#     return extra
