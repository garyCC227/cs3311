import psycopg2
import re

# we assume all the string only contains the char [1-11, <, N]
# I checked it already
def convert(string):
  wk_binary = ['0','0','0','0','0','0','0','0','0','0','0']
  
  # check if invalid char in the string
  if '<' in string or 'N' in string:
    return "".join(wk_binary)
  
  #NOTE: Assume there is only two possible and valid format in wks
  # "1-5", or "1", "5"
  wks = string.split(',')
  
  #update wk_binary
  for wk in wks:
    # if is "1-5" format
    if '-' in wk:
      start, end = wk.split('-')
      for w in range(int(start)-1, int(end)):
        wk_binary[w] = "1"
    
    # format "1" or "5"
    else:
        wk_binary[int(wk)-1] = "1"
  
  return "".join(wk_binary)
  
def q6(conn):
  cur=conn.cursor()
  #get the courses as required
  # as term_id 5199 = 19T3
  solution_query='''
  select id,weeks from meetings;
  '''
  cur.execute(solution_query)
  result_table=cur.fetchall()
  for mid, wks in result_table:
    my_binary = convert(wks)
    
    # TEST convert()
    #if binary != my_binary:
    #  print("my:{}, actual:{}".format(my_binary, binary))
    #  raise ValueError("No Match-> my:{}, actual:{}".format(my_binary, binary))
    
    #update table
#     print(my_binary)
    query = '''
    update meetings 
    set 
      weeks_binary='{0}'
    where
      id={1}
    '''.format(my_binary,mid)
    cur.execute(query)

  conn.commit()

def connect():
  try:
    conn = psycopg2.connect("dbname=a3")
    q6(conn)
    conn.close()
  except Exception as e:
    print("Couldn't connect to the database:", e)


if __name__ == "__main__":
    connect()
