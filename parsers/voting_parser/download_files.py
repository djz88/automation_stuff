#!/usr/bin/python3

# parse "ciselnik_okresu - NUTS" data from html
# and download files with votes of "okresy" by n1djz88@ygg.cz
# under GNU/GPL v3

import urllib.request
from urllib.error import URLError, HTTPError
from html_table_parser import HTMLTableParser
from sys import argv
import xml.etree.ElementTree as ET
import csv

# ------- ELECTION ID --------
volby = "kz2020"   # z url volby.cz
shortcut_volby = "KZ"
# ----------------------------

# --- vars ---
group_name = []
#NUTS
ciselnik_okresu_url = "https://volby.cz/opendata/{}/{}_nuts.htm".format(
                       volby,shortcut_volby)
file_ciselnik_okresu  = "./ciselnik_obci.csv"
urlbase_votes_okresu = "https://volby.cz/pls/{}/vysledky_okres?nuts=".format(
                       volby)
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


def getData(file_ciselnik_okresu,coding="windows-1250"):
    try:
        data = getUrl(ciselnik_okresu_url).decode(coding)
        parser = HTMLTableParser()
        parser.feed(data)
        return parser

    except OSError:
        raise OSError


def saveToFile(urlbase_votes_okresu, index_name, index_number):
    filedata = []
#    filedata = getUrl(url_votes_okresu).decode('utf-8')
    filedata = getUrl(url_votes_okresu).decode('windows-1250')
    with open("./dataokresy/" + index_number + ".xml", "w") as file1:
        file1.writelines(filedata)

    print('saved')


if __name__ == '__main__':

    with open(file_with_regions,'r') as f:
        bus_regions_visited = f.readlines()


    parser = getData(ciselnik_okresu_url)
    for index in parser.tables[0]:
        # set names from nested list and strip brackets
        index_name = str(index[2:3])[2:-2]
        index_number =  str(index[1:2])[2:-2]
        url_votes_okresu =  urlbase_votes_okresu + index_number
        print("--------------" + index_name + " ------------------")
        print(index_number)
        saveToFile(url_votes_okresu, index_name, index_number)
