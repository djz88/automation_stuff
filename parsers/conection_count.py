#!/usr/bin/python2
# script which print out count of uniq IP connection and all of them
# actual version takes it from file - output of `ss -lt` command

from __future__ import print_function
import os
import sys
import re

if __name__:
    with open("filex", 'r') as stream:
        try:
          storedvalues = []
          data = stream.readlines()
          header = data[0].split()
          data.pop(0)
          print("{} {}\n------------".format(header[4], header[5].split(':')[0]))
          for line in data:
              splitline = line.split('::')
              index = len(splitline) - 1
              if "ffff" in line:
                  value = splitline[index].split()
                  strg =  re.search('ffff:(.*):[0-9]+', str(value))
                  s = strg.group(1)
                  storedvalues.append(s)
                  uniq = set(storedvalues)

          print("\nTotal number of uniq IP connection is: "
                "{}".format(len(uniq)))

          print("\nTotal number of connection is: "
                "{}".format(len(storedvalues)))
        except OSError as exc:
            print(exc)
