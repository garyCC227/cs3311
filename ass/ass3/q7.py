import psycopg2
import sys


DAYMAP = {
  'Mon':1,
  'Tue':2,
  'Wed':3,
  'Thu':4,
  'Fri':5,
  'Sat':6,
  'Sun':7
}

DAYMAP2 = {
  1:'Mon',
  2:'Tue',
  3:'Wed',
  4:'Thu',
  5:'Fri',
  6:'Sat',
  7:'Sun'
}

class Room:
  def __init__(self, room, day, starting, ending, wk):
    self.room = room
    self.tt = {}
    day = DAYMAP[day]
    #tt is timetable -> list of (day, start, end, weeks binary)
    self.tt[day] = [(day, starting, ending, wk)]
  
  def __str__(self):
    string = "{}\n".format(self.room)
    for num_day, classes in self.tt.items():
      string += "  {}\n".format(DAYMAP2[num_day])
      for day, start, end, wk in classes:
        string += "    {}-{}: {}\n".format(start, end, wk)
    
    return string
  
  def get_avg_hour(self):
    t_hour = 0
    for day_cls in self.tt.values():
      for day, starting, ending, wk in day_cls:
        t_hour += count_time(ending - starting, wk)
  
    return t_hour/10
    
  def add(self, day, starting ,ending ,wk):
    day = DAYMAP[day]
    if day not in self.tt.keys():
      self.tt[day] = [(day, starting, ending, wk)]
    else:
      #remove overlap class
      temp_cls = [(day, starting, ending, wk)]
      for cl in self.tt[day]:
        temp_cls = self.solve(temp_cls, cl)

      #update timetable
      for cls in temp_cls:
        self.tt[day].append(cls)
  
  #only called from add -> day is formatted from DAYMAP already
  def solve(self,temp_cls, cl):
    new_cls = []
    old_day, old_starting, old_ending, old_wk = cl
    
    for day, starting, ending, wk in temp_cls:
      #if overlap
      if old_starting <= starting and starting < old_ending:
        #diff wk
        count, diff_cls = self.get_exceed_with_diff_wks(day, starting, ending, wk, cl)
        if count > 0:
          new_cls.append(diff_cls)
        
        #exceed same week
        count, same_cls = self.get_exceed_with_same_wks(day, starting, ending, wk, cl)
        if count > 0:
#           print(self.room, cl, (day, starting, ending, wk))
          new_cls.append(same_cls)
    
    if not new_cls:
      return temp_cls
    else:
      return new_cls
  
  def get_exceed_with_same_wks(self, day, starting, ending, wk, cl):
    old_day, old_starting, old_ending, old_wk = cl
    #check exceed time
    exceed_time = ending - old_ending
    if exceed_time <= 0:
      return -1, (day,0,0,"00000000000")
    
    #exceed_time > 0 
    new_starting = old_ending
    
    result = ""
    count = 0
    for i in range(11):
      if wk[i] == "1" and old_wk[i] == "1":
        result += '1'
        count += 1
      else:
        result += '0'

    return count, (day, new_starting, ending, result)
    
  def get_exceed_with_diff_wks(self, day,starting, ending, wk, cl):
    old_day, old_starting, old_ending, old_wk = cl
    result = ""
    count = 0
    for i in range(11):
      if wk[i] == "1" and old_wk[i] == "0":
        result += '1'
        count += 1
      else:
        result += '0'
    
    return count, (day, starting, ending, result)

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
  select room, day, starting, ending, weeks from T{}rooms2;
  '''.format(key)

  cur.execute(query)
  rows = cur.fetchall() #the rows is order by room, day, start_time, end_time
                        # so start_time of next row always >= start_time of previous
  rooms = reformat(rows)

  underused = 0
  for r in rooms:
    if r.get_avg_hour() < 20:
      underused +=1
  
  print(underused)
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

def reformat(rows):
  store = {}
  for room, day, start, end, wk in rows:
    if room in store.keys():
      store[room].add(day, start, end, wk)
    else:
      store[room] = Room(room, day, start, end, wk)
  
  return list(store.values())
      
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
