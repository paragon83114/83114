#!/usr/bin/env bash
python3 -c "
import imaplib
with open('$HOME/.gmail-creds') as f:
    user, pwd = f.read().strip().splitlines()
c = imaplib.IMAP4_SSL('imap.gmail.com')
c.login(user, pwd)
c.select('INBOX')
print(len(c.search(None, 'UNSEEN')[1][0].split()))
c.logout()
" 2>/dev/null || echo "0"
