#!/usr/bin/env bash
python3 -c "
import imaplib, email
from email.utils import parsedate_to_datetime, parseaddr
from email.header import decode_header
with open('$HOME/.gmail-creds') as f:
    user, pwd = f.read().strip().splitlines()
c = imaplib.IMAP4_SSL('imap.gmail.com')
c.login(user, pwd)
c.select('INBOX')
ids = c.search(None, 'UNSEEN')[1][0].split()
for i in ids[-10:]:
    res, data = c.fetch(i, '(RFC822)')
    msg = email.message_from_bytes(data[0][1])
    dt = parsedate_to_datetime(msg['Date'])
    fecha = dt.strftime('%Y/%m/%d %H:%M')
    subj_raw = decode_header(msg['Subject'] or '')
    subj = subj_raw[0][0].decode(subj_raw[0][1] or 'utf-8') if isinstance(subj_raw[0][0], bytes) else subj_raw[0][0]
    nombre, correo = parseaddr(msg['From'])
    remitente = nombre or correo
    print(f'{fecha} - {remitente} - {subj}')
c.logout()
" 2>/dev/null
