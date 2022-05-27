import sys
import re
import os
import shutil
import subprocess

regex = re.compile(r'^Exec=([\w/-]+)(:? +(.*))?$')


def copy_file(source: str, target: str, stat_source: bool = False):
    stat = os.stat(source) if stat_source else os.stat(target)
    shutil.copy2(source, target)
    os.chmod(target, stat.st_mode)
    os.chown(target, stat.st_uid, stat.st_gid)


def process_file(file_path: str):
    file_name = os.path.basename(file_path)
    tmp_path = os.path.join('/', 'tmp', file_name)
    
    copy_file(file_path, f'{file_path}.backup', stat_source=True)
    with open(file_path) as infile, open(tmp_path, 'w') as outfile:
        for line in infile:
            re_match = regex.match(line)
            if re_match and '--password-store=gnome' not in line:
                command = re_match.group(1)
                args = re_match.group(2) or ''
                command = command.strip()
                args = args.strip()
                line = f'Exec={command} --password-store=gnome {args}\n'
            outfile.write(line)
    copy_file(tmp_path, file_path)


def get_file_locations(app_name: str):
    proc = subprocess.Popen(['locate', app_name], stdout=subprocess.PIPE)
    while line := proc.stdout.readline():
        yield line.decode().strip()


def main():
    apps = sys.argv[1:]
    for app_name in apps:
        if not app_name.endswith('.desktop'):
            app_name = f'{app_name}.desktop'
        for path in get_file_locations(app_name):
            print(path)
            process_file(path)


if __name__ == '__main__':
    main()
