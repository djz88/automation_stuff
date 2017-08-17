#!/usr/bin/python
from __future__ import print_function
import yaml
import sys

if __name__:
    with open("file.yml", 'r') as stream:
        try:
            print('Listing hosts which are not virtual guests:\n')
            data=yaml.load(stream)
            for keys in data.keys():
                print ('\nSection: {}'.format(keys))
                for host in data[keys]:
                    try:
                        if 'guest' in host['virtual']['mode']:
                            break
                    except:
                        pass
                    for k, v in host.items():
                        if k == 'name' or k == 'description':
                            print ('{0:12}  {1}'.format(k,v))

        except yaml.YAMLError as exc:
            print(exc)
