#! /usr/bin/python

import os
import subprocess

#
# Update tags files
#

root_dir = '/home/trevor/work/impetus/'
proj_dirs = ['amgen', 'astellas', 'astrazeneca', 'chs-portal', 'drops-7', 
    'impetus-clean', 'impetusmaster', 'impetuspagebuilder', 'impetus-test',
    'janssen', 'janssen4', 'behat-testing']
ctags_cmd = ['ctags', '--langmap=php:.engine.inc.module.theme.install.php', '--php-kinds=cdfi', '--languages=php', '--recurse']

for dir in proj_dirs:
    os.chdir(root_dir + dir)
    subprocess.call(ctags_cmd)

