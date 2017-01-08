#!/usr/bin/python3
# script which will download maps for osmand app from osmandwebpage
# script will download files to the maps dir of current dir
from os import getcwd
from os import path
from os import makedirs
from HTMLParser import HTMLParser
from urllib import urlretrieve

# create a subclass and override the handler methods
class MyHTMLParser(HTMLParser):
    def handle_data(self, data):
        for item in country:
            if data.startswith(item):
                maplist.append(data)


def DownloadFiles(maps):
    for item in maps:
        print "downloading map: {}".format(item)
        urlretrieve("{}{}".format(linkbase,item),"maps/{}".format(item))

def CheckDirForMaps():
    if not path.exists("maps"):
            makedirs("maps")


# base link for download
linkbase = "http://download.osmand.net/download.php?standard=yes&file="

# open a file
f = open ('x.html','r')
html = f.read()

# maps variables
maplist = []
country = ['Czech-republic', 'Slovakia']

# instantiate the parser and fed it some HTML
parser = MyHTMLParser()
parser.feed(html)

# download maps
print "location for maps is: {}/maps".format(getcwd())
CheckDirForMaps()
DownloadFiles(maplist)

