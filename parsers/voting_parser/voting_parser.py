#!/usr/bin/python3

# find voting data from specific regions for specific party by n1djz88@ygg.cz
# under GNU/GPL v3

import urllib.request
from urllib.error import URLError, HTTPError
from html_table_parser import HTMLTableParser
import json
from sys import argv
import xml.etree.ElementTree as ET
import csv
from pathlib import Path

# ------- ELECTION ID --------
volby = "kz2020"   # z url volby.cz
shortcut_volby = "KZ"
# ----------------------------

# --- vars ---
group_name = []
datafromcsv = []
#NUTS
ciselnik_okresu_url = "https://volby.cz/opendata/{}/{}_nuts.htm".format(
                       volby,shortcut_volby)
# xml dump inside zip archve for KZ2020:
#https://volby.cz/opendata/kz2020/KZ2020ciselniky20201002.zip
file_ciselnik_okresu  = "./ciselnik_obci.csv"
# one region per line
file_with_regions = "./bus_regions.csv"
# -----------

def getRegion(group_name):
    for arg in (argv[1:]):
            del group_name[-1]
    return arg

def getUrl(ciselnik_okresu_url):
    ciselnik_url = ciselnik_okresu_url
    try:
        return urllib.request.urlopen(ciselnik_url).read()
    except HTTPError as e:
        print('The server couldn\'t fulfill the request.')
        print('Error code: ', e.code)
    except URLError as e:
        print('We failed to reach a server.')
        print('Reason: ', e.reason)


def getOkresVotesCount(file_okresu, okresNumber, townName):
    #data2 = urllib.request.urlopen('https://volby.cz/pls/kz2020/vysledky_okres?nuts=CZ0531')
#    data2 = getUrl(url_votes_okresu).decode('utf-8')
    data2 = './' + file_okresu
    #data2 = urllib.request.urlopen(url_votes_okresu)
    xmldoc = ET.parse(data2)
    root = xmldoc.getroot()
#    root = xmldoc
    #print("\n" + url_votes_okresu)
    for item in root:
        #print("--- Start okres ---")
        #print(item.attrib.get('NAZ_OBEC'))
        #print(townName)
        #print(type(townName))
        if item.attrib.get('NAZ_OBEC') == townName:
            #print("*******************************if match")
            #print(item.attrib.get('NAZ_OBEC'))
            #print(item)
            #print(townName)
            for subitem in item:
                # party number to get numbers
                if (subitem.attrib.get('KSTRANA') == '19'):
                    print ("Mesto: " + item.attrib.get('NAZ_OBEC')
                            + ";Pirati hlasu: "
                            + subitem.attrib.get('HLASY')
                            + ";Pirati %: "
                            + subitem.attrib.get('PROC_HLASU'))
                elif (subitem.attrib.get('KSTRANA') == '21'):
                    print ("Mesto: " + item.attrib.get('NAZ_OBEC')
                            + ";Pir + STAN hlasu: "
                            + subitem.attrib.get('HLASY')
                            + ";Pir + STAN %: "
                            + subitem.attrib.get('PROC_HLASU'))
        #print("---")


def getFile(region, coding="windows-1250"):

    folder = Path('./dataokresy').rglob('*.xml')
    files = [x for x in folder]
    try:
        for name in files:
            with open(name, newline='') as myfile:
                datareader = myfile.read()
                if region in datareader:
                    #when using csv
                    #datafromcsv.append(row)
                    return name

# when using csv
#    try:
#        with open(file_ciselnik_okresu, newline='') as csvfile:
#            datareader = csv.reader(csvfile, delimiter=';')
#            for row in datareader:
#                datafromcsv.append(row)
#            return datafromcsv

# when using http
#    try:
#        data = getUrl(ciselnik_okresu_url).decode(coding)
#        parser = HTMLTableParser()
#        parser.feed(data)
#        return parser
    except OSError:
        raise OSError


def getData():
    filename = getFile()

# when using http
#    data = ET.parse(filename)
#    root = data.getroot()
#    for item in root:
#        print(root.tag)



if __name__ == '__main__':

    with open(file_with_regions,'r') as f:
        bus_regions_visited = f.readlines()


#    parser = getData()
    for region in bus_regions_visited:
        region = region.strip('\n')
        print("--------------" + region + " ------------------")
        townName = region
        okresNumber = str(getFile(region))

# when using http
#        for index in parser:
#        for index in parser.tables[0]:
            # set names from nested list and strip brackets
#            index_name = str(index[1])
#            index_number = str(index[0])
#            print(index_number)
##            index_name = str(index[2:3])[2:-2]
##            index_number =  str(index[1:2])[2:-2]
##            print(index_number)

        if townName == region:
           file_okresu =  okresNumber
           getOkresVotesCount(file_okresu, okresNumber, townName)
