#! /usr/bin/python

import os
import subprocess

#
# Update tags files
#

root_dir = '/home/trevor/work/impetus/'
ignore_dirs = ['resources', 'ssl', 'docs', 'scripts']
ctags_cmd = ['ctags', '--langmap=php:.engine.inc.module.theme.install.php', '--php-kinds=cdfi', '--languages=php', '--recurse']

proj_dirs = [x for x in os.listdir(root_dir) if x not in ignore_dirs and os.path.isdir(root_dir + x)]

for dir in proj_dirs:
    os.chdir(root_dir + dir)
    subprocess.call(ctags_cmd)
