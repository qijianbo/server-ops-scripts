#!/usr/bin/python
import smtplib,subprocess
from email.mime.text import MIMEText

#about_mail_server
mail_server = 'smtp.gmail.com'
mail_server_port = 587

#about_user
from_addr = 'xxx@gmail.com'
password = 'xxx'
to_addr = 'xxx'

#about_content
p = subprocess.Popen("du -sh /data/backup/*",shell=True,stdout=subprocess.PIPE)
body = p.stdout.read()
email_message = '%s' % (body)

#about_mime
msg = MIMEText(email_message)
msg['Subject'] = "214-backup-stats"
msg['From'] = from_addr
msg['To'] = to_addr

#about_smtp
s = smtplib.SMTP(mail_server, mail_server_port)
s.ehlo
s.starttls()
s.login(from_addr, password)
s.sendmail(from_addr, to_addr, msg.as_string())
s.quit()
