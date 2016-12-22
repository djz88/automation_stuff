#!/usr/bin/python3
# TODO: multiple files input
# TODO: searched text via input
# TODO: create function which count occurence of a pattern
# TODO: occurence pattern from file

import os;
import re;


def getlines(pfile):
    '''
    Get lines from file
    '''
    i = 0
    with open(pfile,'r') as f:
        data = f.read()
        rozprava = re.findall('(V rozpravě vystoup.*| Dále vystoup.*)(\.|\s.*\.)',data)
        llength = len(rozprava)
        regexp = re.compile(r"^\(\'|\', '|\'\)$|\\n")
        while i < llength:
            string = str(rozprava[i])
            string = regexp.sub("",string)
            print (string)
            string = ""
            i += 1
    f.close()


def main():
    getlines('/home/_NOT_BACKED_UP/mesto/zastupitelstvo_kraje/txt/Zapis03.txt')



if __name__ == '__main__': main()

