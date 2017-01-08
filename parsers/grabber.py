#!/usr/bin/python3
# TODO: multiple files input
# TODO: searched text via input
# TODO: create function which count occurence of a pattern
# TODO: occurence pattern from file

import os;
import sys;
import re;

f = '/home/_NOT_BACKED_UP/mesto/zastupitelstvo_kraje/txt/Zapis03.txt'

def print_help():
	'''
	prints out help, no argument 
	'''
	sys.exit("help of " + sys.argv[0] + "\n"
		"----------------------\n"
		"usage: " + sys.argv[0] +" argument [parameters]\n"
		"\n"
		"argument:\n"
		"print      prints out line containing regex\n"
		"\n"
		"parameters:\n"
		"--file     files(fullpath) to be examine are in file"
		"\n")

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

def arguments_given(sys_args):
	'''
	arguments and parameters handling
	'''
	if len(sys_args) < 2:
		sys.exit(print_help())

	operation = {'print': print_regex}
	argument_choosed = operation.get(sys_args[1],None)
	if argument_choosed is None:
		return  print_help()
	return argument_choosed

def print_regex():
    getlines(f)


def main(argv):
    arguments_given(sys.argv)




if __name__ == '__main__': main(sys.argv)

