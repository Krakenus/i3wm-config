import re
import os
import shutil
import subprocess
import argparse

regex = re.compile(r'^Exec=([\w/-]+)(:? +(.*))?$')


def copy_file(source: str, target: str, stat_source: bool = False):
    stat = os.stat(source) if stat_source else os.stat(target)
    shutil.copy2(source, target)
    os.chmod(target, stat.st_mode)
    os.chown(target, stat.st_uid, stat.st_gid)


def make_backup(file_path: str):
    copy_file(file_path, f'{file_path}.backup', stat_source=True)


def _process_file(file_path: str):
    file_name = os.path.basename(file_path)
    tmp_path = os.path.join('/', 'tmp', file_name)
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


def process_file(args: argparse.Namespace, file_path: str):
    if not args.no_backup:
        make_backup(file_path)
    _process_file(file_path)


def get_file_locations(app_name: str):
    proc = subprocess.Popen(['locate', app_name], stdout=subprocess.PIPE)
    while line := proc.stdout.readline():
        yield line.decode().strip()


def main(args: argparse.Namespace):
    for app_name in args.apps:
        if not app_name.endswith('.desktop'):
            app_name = f'{app_name}.desktop'
        print(f'Processing {app_name}...')
        for path in get_file_locations(app_name):
            print(f' - {path}')
            process_file(args, path)


def add_arguments():
    parser = argparse.ArgumentParser()
    parser.add_argument('-c', '--config', type=str, help='Path to config file')
    parser.add_argument('--no-backup', action='store_true', dest='no_backup', help='Do not create backup files')
    parser.add_argument('-a', '--apps', type=str, nargs='*', help='List of applications to be processed (ignored when using -c --config)')
    return parser

if __name__ == '__main__':
    parser = add_arguments()
    args = parser.parse_args()
    main(args)
