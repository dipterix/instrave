#!/usr/bin/python
from __future__ import print_function
from __future__ import unicode_literals

import sys
import os
import shutil
import subprocess
import re
import tempfile
import atexit
import time
import errno
import zipfile
try:
    from shlex import quote
except ImportError:
    from pipes import quote

def debug(s):
  # print( '[DEBUG]: %s' % s )
  pass

# ------------------------- check python version ------------------------------

if sys.version_info[0] == 2:
  import urllib as urllib
  scan = raw_input
else:
  import urllib.request as urllib
  scan = input

# -------------------- register global variables -------------------------

R_VER_MAJOR=3
R_VER_MINOR=6
R_VER_DEV=0
R_MIN_VER = R_VER_MAJOR * 10000 + R_VER_MINOR * 100 + R_VER_DEV
N27_PATH=os.path.expanduser("~/rave_data/others/three_brain/N27/")
HOME_BSLASH=os.path.expanduser('~')
DEMO_SUBS=['All', 'All_that_are_not_installed', 'KC', 'YAB', 'YAD', 'YAF', 'YAH', 'YAI', 'YAJ', 'YAK']
RUN_R="Rscript --no-save --no-restore --no-site-file --no-init-file"
ALLYES=1

# ------------------------- Check sudo status ------------------------------

def quote_shell(args):
  return " ".join(quote(arg) for arg in args)


def quote_applescript(string):
  charmap = {
    "\n": "\\n",
    "\r": "\\r",
    "\t": "\\t",
    "\"": "\\\"",
    "\\": "\\\\",
  }
  return '"%s"' % "".join(charmap.get(char, char) for char in string)


def elevate(show_console=True, graphical=True):
  if os.getuid() == 0:
      return
  args = [sys.executable] + sys.argv
  commands = []
  if graphical:
    if sys.platform.startswith("darwin"):
      commands.append([
        "osascript",
        "-e",
        "do shell script %s "
        "with administrator privileges "
        "without altering line endings"
        % quote_applescript(quote_shell(args))])
    if sys.platform.startswith("linux") and os.environ.get("DISPLAY"):
      commands.append(["pkexec"] + args)
      commands.append(["gksudo"] + args)
      commands.append(["kdesudo"] + args)
  commands.append(["sudo"] + args)
  for args in commands:
    try:
      os.execlp(args[0], *args)
    except OSError as e:
      if e.errno != errno.ENOENT or args[0] == "sudo":
        raise

def check_sudo():
  is_sudo = os.getuid() == 0
  return is_sudo

# ---------------------------- Register functions ----------------------

### Common

def check_R_version():
  '''Check if R installed or R version is too low.'''
  r_need_install=0
  try:
    process = subprocess.Popen(["/usr/bin/env Rscript --version"],
                              stdout=subprocess.PIPE,
                              stderr=subprocess.PIPE,
                              shell=True)
    out, err = process.communicate()
    r_ver = out.decode("utf-8") + " " + err.decode("utf-8")
    m = re.search(r'([0-9])\.([0-9])\.([0-9])', r_ver)
    r_ver = int(m.group(1)) * 10000 + int(m.group(2)) * 100 + int(m.group(3))
    if r_ver < R_MIN_VER :
      # R version too small
      print("[RAVE]: R version (%s) is too low." % m.group(0))
      r_need_install = 1
    pass
  except Exception as e:
    print("[RAVE]: Warning while trying to obtain R version number: %s." % e.message)
    r_need_install = 1
  return r_need_install


def run_cmd(cmd):
  process = subprocess.Popen(cmd, stdout=subprocess.PIPE, stderr=subprocess.PIPE, shell=True)
  out, err = process.communicate()
  out = out.decode("utf-8")
  err = err.decode("utf-8")
  return (out, err,)

def run_r(cmd, verbose = False):
  rcmd = RUN_R + ' -e "%s"' % cmd
  debug(rcmd)
  out, err = run_cmd(rcmd)
  if verbose:
    print(out)
    print(err)
  return (out, err,)

def install_rpkg(pkg, ptype = 'binary'):
  print("[RAVE]: Installing `%s` ..." % pkg)
  out, err = run_r('''utils::install.packages('%s',type='%s',repos='https://cloud.r-project.org',lib='%s')''' % (pkg, ptype, libpath))
  debug(out)
  debug(err)
  if out == '':
    print("%s" % out)
    print("%s" % err)
    print("[RAVE-WARNING]: R Package `%s` was not installed properly!" % pkg)
  return (out, err, )

def install_github(repo, upgrade = False, force = True, ptype = 'binary'):
  print("[RAVE]: Installing `%s` from Github..." % repo)
  out, err = run_r('''remotes::install_github('%s', upgrade = %s, force = %s, type = '%s')''' % (
    repo, "TRUE" if upgrade else "FALSE", "TRUE" if force else "FALSE", ptype
  ))
  debug(out)
  debug(err)
  if out == '':
    print(out)
    print(err)
    print("[RAVE-WARNING]: R Package `%s` was not installed properly!" % repo)
  return (out, err, )

### MacOSX
# check if macosx

def verify_rstudio():
  cmd = '''
  if [ ! -d "/Applications/RStudio.app" ]; then
    echo 0
  else
    echo 1
  fi
  '''
  out, err = run_cmd(cmd)
  return out[:1] == '1'

def download_install_R(INST_PATH):
  # download R
  target = os.path.join(INST_PATH, 'R-latest.pkg')
  urllib.urlretrieve('https://cran.r-project.org/bin/macosx/base/R-release.pkg', filename = target)
  # install R
  out, err = run_cmd('sudo installer -pkg "%s" -target "/usr/local/bin"' % target)
  return target

def check_commandline():
  cmd='''
flag=0
which -s brew
if [[ $? != 0 ]] ; then
  flag=1
fi
if type xcode-select >&- && xpath=$( xcode-select --print-path ) &&
   test -d "${xpath}" && test -x "${xpath}" ; then
   flag1=0
else
   flag=1
fi
echo $flag
'''
  out, err = run_cmd(cmd)
  return out[:1] == '0'

def install_build_tools(INST_PATH):
  # check if installed
  if not check_commandline():
    print('\n[RAVE]: Installing Homebrew and xcode command line tools')
    print('[RAVE]: Please enter your password so I can install compilers. (This might take a while to install)')
    # wait one sec and tell process to accept the installation
    cmd = '''
CI=1 /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install.sh)" </dev/null
'''
    os.system(cmd)
    if not check_commandline():
      raise Exception("xcode commandline tool has not been installed successfully")
  else:
    print("[RAVE]: xcode command line tools detected.")
  return None

def install_rstudio(INST_PATH):
  target = os.path.join(INST_PATH, 'rstudio.html')
  urllib.urlretrieve('https://rstudio.com/products/rstudio/download/#download', filename = target)
  url = ''
  fname = 'RStudio.dmg'
  with open(target, 'r') as f:
    for s in f:
      m = re.match(r'.*(http[s]{0,1}://download1\.rstudio\.org/desktop/macos/(RStudio-[0-9.]+)\.dmg)', s)
      if m:
        gp = m.groups()
        url = gp[0]
        fname = gp[1]
        break
  if url != '':
    target = os.path.join(INST_PATH, 'rstudio.dmg')
    print('Downloading %s \n\t=> %s' % (url, target))
    urllib.urlretrieve(url, filename = target)
    cmd = '''open "%s"
#hdiutil attach "%s"
#volume="/Volumes/%s"
#open -R "$volume"
  ''' % (target, target, fname)
    run_cmd(cmd)
  
# ------------------------- Main  -------------------------

if __name__ == "__main__":
  #
  # temporary installation path
  INST_PATH = tempfile.mkdtemp(prefix='rave-installer')
  if not os.path.exists(INST_PATH):
    os.mkdir(INST_PATH)
  def remove_tmpfiles():
    if os.path.exists(INST_PATH):
      # remove this path
      shutil.rmtree(INST_PATH, ignore_errors=True)
  # atexit.register(remove_tmpfiles)
  print("Temporary path ======> %s" % INST_PATH)
  #
  # Install RStudio
  if not verify_rstudio():
    install_rstudio(INST_PATH)
  #
  # Check install xcode command line
  install_build_tools(INST_PATH)
  #
  # Get sudo
  is_sudo = check_sudo()
  #
  # Start!
  print("============ Welcome to RAVE installer (MacOS) ============\n")
  print("[RAVE]: Step 1: check system requirement...")
  if check_R_version() == 0:
    print("[RAVE]: R version is OK.")
  else:
    print("[RAVE]: Installing R")
    download_install_R(INST_PATH)
    # check R again!
    if check_R_version() != 0:
      raise Exception("I cannot detect any R installed. Please make sure R is installed and then run this script again.")
  # Download shell script for RAVE  
  rave_zip = os.path.join(INST_PATH, 'RAVE.zip')
  urllib.urlretrieve("https://raw.githubusercontent.com/dipterix/instrave/master/RAVE.zip", filename = rave_zip)
  #
  #
  print("[RAVE]: Step 2: Install/Update RAVE and its dependencies")
  libpath, err = run_r('''cat(normalizePath(Sys.getenv('R_LIBS_USER'), mustWork=FALSE))''')
  print("[RAVE]: Found R user lib -- %s" % libpath)
  if not os.path.exists(libpath):
    os.makedirs(libpath, exist_ok=True)
  # remove all 00LOCK files
  run_cmd('rm -rf %s' % os.path.join(libpath, "00LOCK*"))
  install_rpkg('Rcpp')
  install_rpkg('stringr')
  install_rpkg('devtools')
  install_rpkg('reticulate')
  install_rpkg('fftwtools')
  install_rpkg('hdf5r')
  install_rpkg('dipsaus')
  install_rpkg('threeBrain')
  install_rpkg('raveio')
  install_rpkg('lazyarray')
  run_cmd('rm -rf %s' % os.path.join(libpath, "00LOCK*"))
  install_github('dipterix/dipsaus')
  run_cmd('rm -rf %s' % os.path.join(libpath, "00LOCK*"))
  install_github('beauchamplab/raveio')
  run_cmd('rm -rf %s' % os.path.join(libpath, "00LOCK*"))
  install_github('beauchamplab/rave')
  run_cmd('rm -rf %s' % os.path.join(libpath, "00LOCK*"))
  install_github('dipterix/rutabaga@develop')
  run_cmd('rm -rf %s' % os.path.join(libpath, "00LOCK*"))
  install_github('beauchamplab/ravebuiltins@migrate2')
  run_cmd('rm -rf %s' % os.path.join(libpath, "00LOCK*"))
  install_github('dipterix/threeBrain')
  # 
  # RAVE settings
  out, err = run_r("require(rave); rave::arrange_modules(refresh = TRUE, reset = FALSE); rave::arrange_data_dir(TRUE, FALSE)", verbose=True)
  # check data_dir
  data_dir, err = run_r("cat(as.character(rave::rave_options('data_dir')))")
  raw_dir, err = run_r("cat(as.character(rave::rave_options('raw_data_dir')))")
  if not os.path.exists(data_dir) or not os.path.exists(raw_dir):
    # data or raw directory is missing
    pass
  else:
    print('[RAVE] Raw data path - %s' % raw_dir)
    print('[RAVE] Main data path - %s' % data_dir)
  run_cmd('tar -xzpf "%s" -C "%s"' % (rave_zip, os.path.expanduser("~/Desktop")))
  # 0o777 (oct) is 511 
  rave_exec = os.path.expanduser("~/Desktop/RAVE")
  os.chmod(rave_exec, 511)
  #
  # write to rave module dir
  rave_module_dir = os.path.expanduser("~/rave_module")
  if not os.path.exists(rave_module_dir):
    os.mkdir(rave_module_dir)
  start_file = os.path.join(rave_module_dir, "rave_startup.R")
  with open(start_file, "w+") as f:
    f.writelines('''
# Select a line, use 'command + return' to run that line

# Install demo data, finalize installation (optional)
rave::finalize_installation()

# To launch RAVE - main application
rave::start_rave()

# To open preprocess app
rave::rave_preprocess()

# To set option
rave::rave_options()
''')
  run_cmd('open -a rstudio "%s"' % start_file)
  run_r("rave::start_rave(launch.browser = TRUE)")

