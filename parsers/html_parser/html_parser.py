#!/usr/bin/python3

# voting data html parser by n1djz88@ygg.cz
# under GNU/GPL v3

import urllib.request
from html_table_parser import HTMLTableParser
import json

# ------- ELECTION ID --------
election_id = 'ecbe2072-fa31-11e9-bf56-00000a2a0114'
# ----------------------------

# --- vars ---
voters = []
non_voters = []
username = ''
krajska_sdruzeni = {"KS Kralovehradecky kraj": "deadbeef-babe-f002-000000000032",
        "KS Praha" : "deadbeef-babe-f002-000000000033",
        "KS Moravskoslezsky kraj" : "deadbeef-babe-f002-000000000034",
        "KS Pardubicky kraj" : "deadbeef-babe-f002-000000000035",
        "KS Jihomoravsky kraj" : "deadbeef-babe-f002-000000000036",
        "KS Vysocina" : "deadbeef-babe-f002-000000000037",
        "KS Olomoucky kraj" : "deadbeef-babe-f002-000000000038",
        "KS Ustecky kraj" : "deadbeef-babe-f002-000000000042",
        "KS Zlinsky kraj" : "deadbeef-babe-f002-000000000039",
        "KS Jihocesky kraj" : "deadbeef-babe-f002-000000000040",
        "KS Liberecky kraj" : "deadbeef-babe-f002-000000000041",
        "KS Karlovarsky kraj": "deadbeef-babe-f002-000000000043",
        "KS Plzensky kraj" : "deadbeef-babe-f002-000000000044",}
members_ks = krajska_sdruzeni
voters_ks = {}
graph_url = "https://graph.pirati.cz/"
helios_url = "https://helios.pirati.cz/"
# -----------


def getVoting(election_id):
    voting_url = helios_url + urllib.parse.quote('/helios/elections/') + urllib.parse.quote(election_id) + urllib.parse.quote('/voters/list') + '?limit=5000'
    return  urllib.request.urlopen(voting_url).read()

def addVoter(name, action=None):
    if action == 'non':
        non_voters.append(name)
    else:
        voters.append(name)

def getKSMembers(group_name, group_id):
    list_of_members = []
    members_url = graph_url + urllib.parse.quote(group_id) + urllib.parse.quote('/members')
    content = urllib.request.urlopen(members_url).read()

    members_data = json.loads(content)
    for i in members_data:
        list_of_members.append(i['username'])
#        print(i['username'])

    members_ks[group_name] = list_of_members

def addVotersInKS(group_name):
    voters_per_ks = []
    for i in members_ks[group_name]:
        if i in voters:
            voters_per_ks.append(i)

    voters_ks[group_name] = voters_per_ks


if __name__ == '__main__':

# ----- handling voting -----
# open from html file (e.g. wget)
#    with open('helios_jakub.html', 'r') as myfile:
#        data = myfile.read()

    data = getVoting(election_id).decode('utf-8')
    parser = HTMLTableParser()
    parser.feed(data)
    for index in parser.tables[0]:
        if len(index[1]) != 1:
            addVoter(index[0])
        else:
            addVoter(index[0], 'non')
#            print(' SHAME! -',index[0])
# ---------------------------

# ----- get group members from graph.pirati.cz -----
    for i, v in krajska_sdruzeni.items():
        getKSMembers(i, v)
        addVotersInKS(i)
# --------------------------------------------------

# ----- print results -----
    for i, v in voters_ks.items():
        number_members = int(len(members_ks[i]))
        number_voters = int(len(voters_ks[i]))
        percent = (number_voters / number_members)
        print ('---', i,'---')
        print('Members:', number_members)
        print('Voters:', number_voters)
        print("Percent voted: {0:.0f}%".format(percent * 100))
        print()

    # global numbers
    print('----- Global numbers\nEligible voters:', len(voters) + len(non_voters))
    print('All voters:',len(voters))
    print('Nonvoters:', len(non_voters))
# -------------------------

