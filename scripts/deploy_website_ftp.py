#!/usr/bin/env python3
"""
Deploy Alkitab Harmoni Suara & OktamaDnsFilter Showcase to InfinityFree
Website: https://oktama.freedev.app/?i=1
Account: if0_42237716
"""

import ftplib
import os
import sys

if sys.platform == 'win32':
    sys.stdout.reconfigure(encoding='utf-8')

FTP_HOST = 'ftpupload.net'
FTP_USER = 'if0_42237716'
FTP_PASS = '5ZC75f3WCvb7'
REMOTE_DIR = 'oktama.freedev.app/htdocs'
LOCAL_DIR = r'D:\App\Alkitab\installer\website'

print("=" * 60)
print("🚀 DEPLOYING TO INFINITYFREE (oktama.freedev.app)")
print(f"Target: ftp://{FTP_HOST}/{REMOTE_DIR}")
print(f"Domain: https://oktama.freedev.app/?i=1")
print("=" * 60)

ftp = ftplib.FTP(FTP_HOST, timeout=40)
ftp.login(FTP_USER, FTP_PASS)
ftp.set_pasv(True)
print("[1/3] Logged into FTP successfully!")

ftp.cwd(REMOTE_DIR)
print(f"[2/3] Switched to remote directory: /{REMOTE_DIR}")

files_to_upload = ['index.html', 'alkitab_banner.png', 'alkitab_icon.png']

print("\n[3/3] Uploading website assets...")
for fname in files_to_upload:
    lpath = os.path.join(LOCAL_DIR, fname)
    fsize = os.path.getsize(lpath)
    print(f"  -> Uploading {fname} ({fsize / 1024:.1f} KB)...")
    with open(lpath, 'rb') as f:
        ftp.storbinary(f'STOR {fname}', f)
    print(f"  [OK] Uploaded {fname}")

print("\nRemote directory listing after deployment:")
ftp.dir()
ftp.quit()

print("\n" + "=" * 60)
print("🎉 Deployment completed successfully!")
print("🌐 Check live site at: https://oktama.freedev.app/?i=1")
print("=" * 60)
