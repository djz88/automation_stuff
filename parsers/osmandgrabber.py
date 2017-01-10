#!/usr/bin/python
# script which will download maps for osmand app from osmandwebpage
# script will download files to the maps dir of current dir

from sys import exit
from os import getcwd
from os import path
from os import makedirs
try:
    from HTMLParser import HTMLParser
except:
    from html.parser import HTMLParser

try:
    from urllib import urlretrieve
except:
    from urllib import request as urlretrieve

# create a class and override the handler methods
class MyHTMLParser(HTMLParser):
    def handle_data(self, data):
        for item in country:
            if data.startswith(item):
                maplist.append(data)


def DownloadFiles(maps):
    for item in maps:
        print ("downloading map: {}".format(item))
        urlretrieve("{}{}".format(linkbase,item),"maps/{}".format(item))

def CheckDirForMaps():
    if not path.exists("maps"):
            makedirs("maps")


# base link for download
linkbase = "http://download.osmand.net/download.php?standard=yes&file="

# open a file
try:
    f = open ('x.html','r')
    html = f.read()
    f.close
except IOError:
    print('File not found, permission issue or full disk')
    exit(1)
#    print('File {} doesn\'t exists.'.format(f))


# maps variables
maplist = []
country = ['Czech-republic', 'Slovakia']

# instantiate the parser and fed it some HTML
parser = MyHTMLParser()
parser.feed(html)

# download maps
print ("location for maps is: {}/maps".format(getcwd()))
CheckDirForMaps()
DownloadFiles(maplist)

