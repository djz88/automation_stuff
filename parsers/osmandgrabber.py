#!/usr/bin/python
# Script which will download maps for osmand application  from osmand webpage.
# Script will download files to the maps dir of current dir.
# Put desired maps in country variable (e.g. Czech-Republic, Slovakia)
# and it will download all(including regions in that countries).
# Should work with python2 and python3
# Raw indexes - source of countries http://download.osmand.net/rawindexes/


from sys import exit
from os import getcwd
from os import path
from os import chdir
from os import makedirs
from os import listdir
from os import rename
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
    """
    Download index file which contains all the maps indexes
    """
    print ("downloading rawindexes file")
    urlretrieve("{}".format(linkbaseindex),'maps/index.file')

def DownloadFiles(maps):
    """
    Download map files and unzip them.
    """
    if not maps:
        print ("no maps found - check the country name")
    for item in maps:
#        filename_name = item.format(item[:-4])
        print ("downloading map: {}".format(item))
        url = urlopen("{}{}".format(linkbase,item),
                      data=None)
        zipfile = ZipFile(BytesIO(url.read()))
        extractedfile = ZipFile.extractall(zipfile,path='maps/')
        RenameV2MapFiles("./maps/" + item[:-4])

def CheckDirForMaps():
    """
    Check for maps dir or create it.
    """
    if not path.exists("./maps"):
            print("making dir")
            makedirs("./maps")

def RenameV2MapFiles(filename):
    """
    Rename map files which ends with v2
    because they are not recognized by osmand
    """
    print ("filename will be renamed to: {}".format(filename))
#    for filename in listdir("./maps"):
    if filename.endswith("_2.obf"):
        new_filename = filename[:-6] + ".obf"
        print ("renaming files ending v2")
        print ("filename is: {}".format(new_filename))
        rename (filename,new_filename)
       # print ("new_filename is: {}".format(filename[:-6]))


#def UnpackMapFiles():
#    zf = zipfile.ZipFIle("$")

# base link for download
linkbaseindex = "http://download.osmand.net/rawindexes"
linkbase = "http://download.osmand.net/download.php?standard=yes&file="


# maps variables
maplist = []
#country = ['Czech-republic', 'Slovakia', 'France', 'Germany', 'Us_virginia',
#           'Us_washington']

country = ['Gb', 'Austria', 'Netherlands', 'Poland']
# main
print ("Countries which will be downloaded: {}".format(country))
print ("location for maps is: {}/maps".format(getcwd()))
CheckDirForMaps()

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
DownloadFiles(maplist)
#RenameV2MapFiles()

