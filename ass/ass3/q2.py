import psycopg2
import sys

def q2(conn, incommon):
  cur = conn.cursor()
  query = '''
    select code from subjects;
  '''
  cur.execute(query)
  rows = cur.fetchall()
  
  # Common dictionary.
  # structure:
  #  {
  #   "code":{
  #       count:int,
  #       char:[]
  #     }
  #   }
  common_dict = dict()

  #set up the common_dict
  for (code,) in rows:
    #char code, numeric code
    char_code ,num_code = code[:4], code[4:]
    
    if num_code in common_dict.keys():
      common_dict[num_code]['count'] +=1
      common_dict[num_code]['char'].append(char_code)
    else:
      common_dict[num_code] = {
        'count':1,
        'char':[char_code]
      }
  
  for num_code in sorted(common_dict):
    if(common_dict[num_code]['count'] == incommon):
      print("{}: {}".format(num_code, sorted(common_dict[num_code]['char'])))


def connect(incommon):
  try:
    conn = psycopg2.connect("dbname=a3 user=postgres password=chenqq227") #TODO: delete

    q2(conn, incommon)

    conn.close()
  except Exception as e:
    print("Cannot connect the database: ", e)

if __name__ == "__main__":
    # get incommon number from command line
    incommon = 2
    if len(sys.argv) > 1:
      try:
        incommon = int(sys.argv[1])
      except Exception as e:
        raise e

    connect(incommon)
