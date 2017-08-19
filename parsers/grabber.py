#!/usr/bin/python3
# TODO: better multiple files handling
# TODO: searched text via input
# TODO: create function which count occurence of a pattern
# TODO: occurence pattern from file

from __future__ import print_function
import os
import sys
import re
import argparse

f = '/home/_NOT_BACKED_UP/mesto/zastupitelstvo_kraje/txt/Zapis03.txt'

class TextManupulation:
    def __init__(self):
        self.getlines(f)

    def getlines(self, pfile):
        '''
        Get wanted lines from the file
        '''
        print('\n\n=====\nActual file: {}'.format(pfile))
        with open(pfile,'r') as ofile:
            data = ofile.read()
            #search_regexp_pattern = '(V rozprav vystoup.*| le vystoup.*)(\.|\s.*\.)'
            vytah = re.findall('(V rozpravě vystoup.*| Dále vystoup.*)(\.|\s.*\.)', data)
            llength = len(vytah)
            i = 0
            print('{} records found\n=====\n'.format(llength))
            regexp = re.compile(r"^\(\'|\', '|\'\)$|\\n")
            while i < llength:
                string = str(vytah[i])
                string = regexp.sub('',string)
                print (string)
                string = ''
                i += 1
        ofile.close()

def Arguments():
        '''
        Handle arguments given from the cli
        '''
        parser = argparse.ArgumentParser()
        parser.add_argument('print', action='store', default=False,
                            help='print-out text')
        parser.add_argument('-f', '--file', nargs='+',
                           help='File to be parsed')
        _args = parser.parse_args()
        return( _args.print,  _args.file)


if __name__ == '__main__':
    # handle arguments
    Arguments()
    action_print, argument_file = Arguments()
    if argument_file:
        f = argument_file
    if action_print:
        if len(argument_file) > 1:
            for files in argument_file:
                f = files
                TextManupulation()
        else:
            TextManupulation()
