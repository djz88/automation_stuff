#!/usr/bin/python
# Script which will download maps for osmand application  from osmand webpage.
# Script will download files to the maps dir of current dir.
# Put desired maps in country variable (e.g. Czech-Republic, Slovakia)
# and it will download all(including regions in that countries).
# Should work with python2 and python3


from sys import exit
from os import getcwd
from os import path
from os import makedirs
from zipfile import ZipFile
try:
    from BytesIO import BytesIO
except:
    from io import BytesIO as BytesIO

try:
    from HTMLParser import HTMLParser
except:
    from html.parser import HTMLParser

try:
    from urllib import urlopen
    from urllib import urlretrieve
except:
    from urllib.request import urlopen
    from urllib.request import urlretrieve
    #from urllib.request import urlretrieve as urlopen

# create a class and override the handler methods
class MyHTMLParser(HTMLParser):
    def handle_data(self, data):
        for item in country:
            if data.startswith(item):
                maplist.append(data)

def DownloadIndexFile():
        print ("downloading rawindexes file")
        urlretrieve("{}".format(linkbaseindex),'maps/index.file')

def DownloadFiles(maps):
    for item in maps:
        print ("downloading map: {}".format(item))
        url = urlopen("{}{}".format(linkbase,item),
                      data=None)
        zipfile = ZipFile(BytesIO(url.read()))
        extractedfile = ZipFile.extractall(zipfile,path='maps/')

def CheckDirForMaps():
    if not path.exists("maps"):
            makedirs("maps")

#def UnpackMapFiles():
#    zf = zipfile.ZipFIle("$")

# base link for download
linkbaseindex = "http://download.osmand.net/rawindexes"
linkbase = "http://download.osmand.net/download.php?standard=yes&file="


# maps variables
maplist = []
country = ['Czech-republic', 'Slovakia']


DownloadIndexFile()

# open a file
try:
    f = open ('maps/index.file','r')
    html = f.read()
    f.close
except IOError:
    print('File not found, permission issue or full disk')
    exit(1)

# instantiate the parser and fed it some HTML
parser = MyHTMLParser()
parser.feed(html)
parser.close()
# download maps
print ("location for maps is: {}/maps".format(getcwd()))
CheckDirForMaps()
DownloadFiles(maplist)

