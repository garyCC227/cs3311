import psycopg2
import sys
import copy

DAYMAP = {
  'Mon':1,
  'Tue':2,
  'Wed':3,
  'Thu':4,
  'Fri':5
}
DAYMAP2 = {
  1:'Mon',
  2:'Tue',
  3:'Wed',
  4:'Thu',
  5:'Fri'
}
class Class:
  def __init__(self, cl_id, cl_ty, code, day, start, end):
    self.cl_id = cl_id
    self.classes = [(start, end, day,code, cl_ty)]
  
  #same class?
  def is_same(self, cl_id):
    return self.cl_id == cl_id
  
  def add(self, cl_ty, code, day, start, end):
    self.classes.append((start, end, day,code, cl_ty))
  
  def __str__(self):
    string = "{}\n".format(self.cl_id)
    for start, end, day,code, cl_ty in self.classes:
      string += "  {} {}:{} {}-{}\n".format(code, cl_ty, day,start, end)
    
    return string
  
class TT:
  def __init__(self):
    '''
    timetable_dict = {
     cl_ids:(include class_id),
     days:(include days)
     lt_day:(latest day)
     timetable:{
       1:[(900, 1000, COMP1511, Lecture, class_id)]
       2:
       ...
     }
    }
    '''
    self.cl_ids = set()
    self.days = set()
    self.t_hours = 0.0
    self.lt_day = 0
    self.tt = {}
  
  def __str__(self):
    string = "Total hours: {0:.1F}\n".format(self.total_hour())
    for day, classes in sorted(self.tt.items(), key=lambda kv:kv[0]):
      string += "  {}\n".format(DAYMAP2[day])
      for start, end, code, cl_type, *_ in sorted(classes, key=lambda x: (x[0], x[1])):
        string +="    {} {}: {}-{}\n".format(code, cl_type, start, end)
    
    return string
  
  
  def total_hour(self):
    self.t_hours = 0.0
    for day, classes in self.tt.items():
      sorted_cl = sorted(classes, key=lambda x:(x[0], x[1]))
      # latest end - earliest start
      self.t_hours += (self.count_time(sorted_cl[-1][1] - sorted_cl[0][0]) + 2)
    
    return self.t_hours
      
  #return true if clash
  def clash(self,cl):
    for start, end, char_day, *_ in cl.classes:
      # check day
      day = DAYMAP[char_day]
      if day not in self.tt.keys():
        continue

      # check all the time in that day
      for old_start, old_end, *_ in self.tt[day]:
        if start >= old_end or end <= old_start:
          continue
        else:
          return True

    return False
  
  # return as hours for wk1-10
  def count_time(self,time):
    #calculating time
    hr = time // 100 
    extra = 0.5 if (time % 100 == 30) or (time % 100 == 70) else 0

    # return as hours
    return hr + extra
  
  def add(self, cl):
    self.cl_ids.add(cl.cl_id)
    for start, end, char_day, code,cl_ty in cl.classes:
      day = DAYMAP[char_day]
      
      self.days.add(day)
      self.lt_day = max(day, self.lt_day)

      # add to timetable
      if day in self.tt.keys():
        self.tt[day].append((start, end, code, cl_ty, cl.cl_id))
      else:
        self.tt[day] = [(start, end, code, cl_ty, cl.cl_id)]
    
def q8(conn, codes):
  cur = conn.cursor()
  # find all possible class time
  class_time = find_class_time(cur,codes)

  #permute all possible timetable
  empty_tt = TT()
  temp_tts = [empty_tt]
  for classes in class_time:
    # if empty classes -> web stream
    if not classes:
      continue
      
    temp_tts = permute_tt(temp_tts, classes)
  
  #find the best timetable
  tt = find_best_tt(temp_tts)
  print(tt)


'''
- In cases where two timetables generate the same number of hours spent on campus or commuting, 
choose the timetable which has the fewer days on campus

'''
def find_best_tt(tts):
  #find the minimal total hours
  min_hr = 1000000
  # calculating the total hours for all timetables
  for tt in tts:
    tt.total_hour()
  
  for tt in tts:
    min_hr = min(tt.t_hours, min_hr)
    
  #get the table with t_total hour == minimal total hours
  min_tts = []
  for tt in tts:
    if tt.t_hours == min_hr:
      min_tts.append(tt)

  if len(min_tts) > 1:
    #find the fewer days
    return find_fewer_days(min_tts)
  elif len(min_tts) == 1:
    return min_tts[0]
  else:
    print("this should never happend")

'''
- In cases where two timetables have the same number of days on campus, 
choose the timetable that has all of the classes done as early as possible in the week,
'''
def find_fewer_days(tts):
  min_days = 10000
  for tt in tts:
    min_days = min(len(tt.days), min_days)
  
  min_tts = []
  for tt in tts:
    if len(tt.days) == min_days:
      min_tts.append(tt)
  
  if len(min_tts) > 1:
    return find_early_class(min_tts)
  elif len(min_tts) == 1:
    return min_tts[0]
  else:
    print("this should never happend")

    
def find_early_class(tts):
  lt_day = 10000
  for tt in tts:
    lt_day = min(tt.lt_day, lt_day)
  
  min_tts = []
  for tt in tts:
    if tt.lt_day == lt_day:
      min_tts.append(tt)
  
  if len(min_tts) > 1:
    return find_final_tt(min_tts, lt_day)
  elif len(min_tts) == 1:
    return min_tts[0]
  else:
    print("this should never happend")

    
def find_final_tt(tts, lt_day): 
  curr_t = tts[0]
  lt_hr =  sorted(curr_t.tt[lt_day], key=lambda x:(x[0], x[1]))[-1][1]
  for t in tts[1:]:
    curr_lt_hr = sorted(t.tt[lt_day], key=lambda x:(x[0], x[1]))[-1][1]
    if curr_lt_hr < lt_hr:
      lt_hr = curr_lt_hr
      curr_t = t
  
  return curr_t
  
#tt = timetable
def permute_tt(tts, classes):
  # build time table dict
  new_tts = []
  seen_class = set()
  for cl in classes:
#     print(cl_id, code, cl_ty, day, start, end)
    # if the class in not seen 
    if cl.cl_id not in seen_class:
      for tt in tts:
        # if not clash, we build a new timetable
        if not tt.clash(cl):
          #add to seen class
          seen_class.add(cl.cl_id)
          temp_tt = copy.deepcopy(tt)
          temp_tt.add(cl)
          new_tts.append(temp_tt)
        else:
        # if clash, we ignore this timetable
          continue
          
      
    else:
    # if the class is seen
      # loop through the new_tt, and add the class into that tt
      pending_remove = []
      for tt in new_tts:
        #ignore the irrelevant timetable
        if cl_id not in tt.cl_ids:
          continue
        
        #so we find the timetable here
        if tt.clash(cl):
          pending_remove.append(tt)
        else:
          tt.add(cl)
      
      if not pending_remove:
        for rm_tt in pending_remove:
          new_tts.remove(rm_tt)
      
    seen_class.add(cl.cl_id)
    
  return new_tts
          
def find_class_time(cur, codes):
  #format
  #[[one dimension for all classes time for the one of the class type of one course ]]
  classes = []
  
  for code in codes:
    # find all possible class type
    query = '''
      select ct.name from courses c
      join classes cl on cl.course_id = c.id
      join classtypes ct on cl.type_id = ct.id
      join subjects s on c.subject_id = s.id
      where c.term_id = 5199 and s.code='{}'
      group by ct.name;
    '''.format(code)
    cur.execute(query)
    rows = cur.fetchall()

    #each class type find all the possible class time
    for cl_type, in rows:
      query = '''
        select cl.id as class_id, s.code, ct.name, m.day, m.start_time, m.end_time from courses c
        join subjects s on c.subject_id = s.id
        join classes cl on c.id = cl.course_id
        join classtypes ct on cl.type_id = ct.id
        join meetings m on m.class_id = cl.id
        where c.term_id = 5199 and s.code='{}' and ct.name='{}'
        order by ct.name,  m.day,cl.tag desc,m.start_time, m.end_time;
      '''.format(code, cl_type)
      cur.execute(query)
      rows = cur.fetchall()
      if cl_type == 'Lecture':
        classes.insert(0, rows)
      else:
        classes.append(rows)    
  
  
  return reset_format(classes)

def reset_format(classes):
  result = []
  for cls in classes: 
    #each rows
    each_cl = {}
    for cl_id, code, cl_ty, day, start, end in cls:
      if cl_id not in each_cl.keys():
        each_cl[cl_id] = Class(cl_id, cl_ty, code, day, start, end)
      else:
        each_cl[cl_id].add(cl_ty, code, day, start, end)
    
    result.append(list(each_cl.values()))
  
  return result
    
def connect(codes):
  try:
    conn = psycopg2.connect("dbname=a3") #TODO: delete

    q8(conn, codes)

    conn.close()
  except Exception as e:
    print("Cannot connect the database: ", e)


if __name__ == "__main__":
  codes = ['COMP1511', 'MATH1131']
  if len(sys.argv) > 1:
    codes = sys.argv[1:4]
  # print(key)
  connect(codes)
