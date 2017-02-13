#!/bin/bash

# init config array
typeset -A config
config=()

# secure config file
CONFIG_SYNTAX='^\w*=[^;&*]*'
ROOT="$(cd "$(dirname "$0")"; pwd -P)"
#echo $ROOT

while read line; do 
  if (echo $line | grep -q -F =) 
  #or more secure?
  #if (echo $line | egrep -q "${CONFIG_SYNTAX}") 
    then
      varname=$(echo "$line" | cut -d '=' -f 1)
      config[$varname]=$(echo "$line" | cut -d '=' -f 2-)
      #echo $varname -- ${config[$varname]}
  fi
done < ${ROOT}/config.cfg
 
(LDAPTLS_REQCERT=never ldapsearch -H ${config[master_uri]} -D ${config[binddn]} -w ${config[password]} -b ${config[searchbase]} -s base + -Z; LDAPTLS_REQCERT=never ldapsearch -H ${config[slave_uri]} -D ${config[binddn]} -w ${config[password]} -b ${config[searchbase]} -s base + -Z) |  \
grep contextCSN  | sed 's/#/ /g' | awk '{print $4,$2 }' | sort -r -k2 -k1 | sed 's/\..*Z$//'  > /tmp/grep_context.$$

ids=$(cat /tmp/grep_context.$$ | cut -f 1 -d ' ' | sort | uniq)

for id in $ids; do
  /bin/echo -n $id
  delta=0

  while read -r line; do
    date=$(/bin/echo -n $line | grep $id | cut -d' ' -f 2 )
    if [ -n "$date" ]; then
      year=${date:0:4}
      month=${date:4:2}
      day=${date:6:2}
      hour=${date:8:2}
      min=${date:10:2}
      sec=${date:12:2}
      
      if uname -a | grep -q Darwin; then 
        # OS X date
        epoch=`date -j -f "%Y %m %d %H %M %S" "$year $month $day $hour $min $sec" "+%s"`
      else
        # GNU date
        epoch=`date -d "$year-$month-$day $hour:$min:$sec" "+%s"`
      fi
      if [ $delta -gt 0 ]; then
	delta=$(( delta - epoch ))
      else 
	delta=$(( delta + epoch ))
      fi
    fi
  done < /tmp/grep_context.$$
  echo " delta: $delta"
done

rm -f /tmp/grep_context.$$
