#!/usr/bin/python3
import smtplib
#from __future__ import print_function
from email.message import EmailMessage
from email.utils import formatdate

emails = ['test', 'test2']
smtp_host = ''
mails = {}
incnumber = 1

def mapQrToMail(emails,incnumber):
    for m in emails:
        mails[m]=incnumber
        incnumber+=1
    return(mails)


if __name__:
    db=mapQrToMail(emails,incnumber)
 # me == the sender's email address
 # you == the recipient's email address
    for m,q in db.items():
        with open("textfile") as fp:
         # Create a text/plain message
            data = fp.read()
            msg = EmailMessage()
        data = data.replace('RCPT_ID', m)
        data = data.replace('QR_ID', str(q))
        msg.set_content(data)
        msg['Subject'] = 'Testing mail - {}'.format(m)
        msg['From'] = "root"
        msg['To'] = m
        msg['Date'] = formatdate(localtime=True)
        print(msg, "------------------------------")

        s = smtplib.SMTP(smtp_host)
        s.send_message(msg)
        s.quit()
        msg.clear()

