import os
from PIL import Image, ImageDraw, ImageFont

def create_terminal_screenshot(title, content, output_path):
    width = 1000
    line_height = 24
    padding = 20
    lines = content.split('\n')
    height = (len(lines) + 2) * line_height + padding * 2
    
    img = Image.new('RGB', (width, height), color=(30, 30, 30))
    draw = ImageDraw.Draw(img)
    
    try:
        font = ImageFont.truetype("/usr/share/fonts/truetype/dejavu/DejaVuSansMono.ttf", 18)
    except:
        font = ImageFont.load_default()
    
    draw.rectangle([0, 0, width, 40], fill=(50, 50, 50))
    draw.text((padding, 10), title, fill=(200, 200, 200), font=font)
    
    draw.ellipse([width-30, 12, width-15, 27], fill=(255, 95, 87))
    draw.ellipse([width-55, 12, width-40, 27], fill=(255, 189, 46))
    draw.ellipse([width-80, 12, width-65, 27], fill=(39, 201, 63))
    
    y = 60
    for line in lines:
        color = (255, 255, 255)
        if "binwalk" in line or "nmap" in line or "mksquashfs" in line: color = (100, 255, 100)
        elif "Squashfs" in line or "MIPS" in line: color = (100, 200, 255)
        elif "open" in line or "successfully" in line: color = (100, 255, 100)
        elif "DECIMAL" in line or "---" in line: color = (255, 255, 100)
        
        draw.text((padding, y), line, fill=color, font=font)
        y += line_height
        
    img.save(output_path)
    print(f"Image générée : {output_path}")

# Logs pour les images
tp1_logs = """ubuntu@sandbox:~/tp-firmware$ binwalk dir601_revB_FW_201.bin

DECIMAL       HEXADECIMAL     DESCRIPTION
--------------------------------------------------------------------------------
84            0x54            uImage header, header size: 64 bytes, created: 2012-02-10, OS: Linux, CPU: MIPS, image type: OS Kernel Image, compression type: lzma
148           0x94            LZMA compressed data, dictionary size: 8388608 bytes
917588        0xE0054         Squashfs filesystem, little endian, version 4.0, compression:lzma, size: 2588388 bytes, 375 inodes, blocksize: 16384 bytes"""

tp2_logs = """ubuntu@sandbox:~/.../squashfs-root$ file bin/busybox
bin/busybox: ELF 32-bit LSB executable, MIPS, MIPS-I version 1 (SYSV), dynamically linked, interpreter /lib/ld-uClibc.so.0, stripped

ubuntu@sandbox:~/.../squashfs-root$ strings bin/busybox | grep -i "password" | head -n 3
/etc/passwd
/etc/shadow
chpasswd

ubuntu@sandbox:~/.../squashfs-root$ cat etc/passwd
root:x:0:0:root:/root:/bin/sh
admin:x:0:0:admin:/www:/bin/sh"""

tp4_logs = """ubuntu@sandbox:~$ nmap 192.168.0.1
Starting Nmap 7.80 ( https://nmap.org )
Nmap scan report for 192.168.0.1
PORT   STATE SERVICE
80/tcp open  http
23/tcp open  telnet

Nmap done: 1 IP address (1 host up) scanned in 0.05 seconds"""

tp5_logs = """ubuntu@sandbox:~/.../squashfs-root$ chmod -x usr/sbin/telnetd
ubuntu@sandbox:~/.../squashfs-root$ vi etc/passwd
# Changement du shell de root en /bin/false pour restreindre l'accès direct
ubuntu@sandbox:~/.../squashfs-root$ mksquashfs . ../patched_firmware.squashfs
Parallel mksquashfs: Using 2 processors
Creating 4.0 filesystem on ../patched_firmware.squashfs, block size 131072.
[==================================================================|] 375/375 100%"""

os.makedirs("/home/ubuntu/tp-firmware/images", exist_ok=True)
create_terminal_screenshot("TP1: Binwalk Analysis", tp1_logs, "/home/ubuntu/tp-firmware/images/tp1_binwalk.png")
create_terminal_screenshot("TP2: Reverse Engineering", tp2_logs, "/home/ubuntu/tp-firmware/images/tp2_reverse.png")
create_terminal_screenshot("TP4: Nmap Dynamic Analysis", tp4_logs, "/home/ubuntu/tp-firmware/images/tp4_nmap.png")
create_terminal_screenshot("TP5: Patching & Rebuild", tp5_logs, "/home/ubuntu/tp-firmware/images/tp5_patching.png")
