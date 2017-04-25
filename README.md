This is a collection of miscellaneous notes on unix, bash and some code samples for the latter.

# Terminals and Shells
* A computer terminal is an electronic or electromechanical hardware device that is used for entering data into, and displaying data from, a computer or a computing system.
* One can think of terminal as the interface between physical I/O and the software
side of it. 

## Login process and shell
Before login prompt is shown, when the linux boots, it executes `init` process,
sets the run level (single user (root), multi-user, multi-user with network etc) in 
`/etc/inittab`. The applciations that are started by *init* are located in
`/etc/rc.d` folder. Withing this directory there is a separate folder for each
run level.

`init` is the mother of all processes, PID=0.
After init() executes /etc/inittab it will run `getty` (terminal device).

### What happens when I log in?
After the user logs in, `login` program is executed. The loging program does
the following:
1. It checks whether one is the root user and whether the file `/etc/nologin`
exists (it is created by *shutdown* command to indicate that the system is down
for maintenance). If the latter is true and the user is not a root user, login
fails.
2. Linux systems often check special conditions, e.g. defined in `/etc/usertty`
or `/etc/securetty`. BSD systems for example check `/etc/fbtab` and may restrict
your access to any devices listed in that file. Some systems may also log failed
login attempts to a file, such as `/var/log/failedlogin`, if it exists.
3. The login program may also check last login, duration of login etc. Interesting
files to look at are: `/var/log/lastlog`, `/var/log/wtmp`, `/var/run/utmp`
4. If the system is non-quiet (`~/.hushlogin` does not exist), the system will
display copyright information, message of the day (lcoated in `/etc/motd`).
5. If all of the checks above pass, the user will be logged in. The *login*
program starts a shell for the user. The type of shell depends on `/etc/passwd`.
If the specified shell is non-interactive, the command-line may be denied. 
`/bin/true` and `/bin/false` are example of non-interactive shells.



### Shells
* **Bourne Shell**
* **C Shell** - very similar to Bourne shell, but the syntax is C-like.
* **Bourne Again Shell** (bash) is a cross between Bourne and C shells.

[This link](http://hyperpolyglot.org/unix-shells) provides a good comparison of different shells. This document will
focus solely on **bash**.

A shell can act as login or non-login. The login shell does some special setup
that one does not want to repeat on other shells. For example, the login shell
sets up things like terminal type. In order to start a shell as login shell
one can add -l flag: `bash -l`. Other shell on the terminal should be non-login
shells. 

A login shell is typically the top-level shell in the 'tree' of processes
that starts with the `init` process.

Nonlogin shells are either subshells (started from the login shell), shells 
started by the window system, or 'disconnected' shells started by `at`, `rsh`,
etc. Thse shells don't read *.login* or *.profile*. In addition, *bash* allows 
nonlogin shell to read *~/.bashrc* or not, depending whether *-norc* or *-rcfile*
options have been passed as arguments during invocation. The former disables reading
of the file, and the latter allows a substitute file to be specified as an argument.

**bash**'s login shell will read the following files:
1. `/etc/profile`
2. `.bash_profile`
3. `.bash_login`
4. `.profile`
5. A non-interactive bash shell will read `.bashrc` file.

On `logout` (called when one exists login shell), bash will read `.bash_logout`
file

#### Interactive shells
Shell is interactive when it handles commands that you type at a prompt. Other times
a shell reads commands from a file - a shell script. In this case, the shell doesn't
need to print the prompt, to handle command-line editing, and so on. Interactive
shells ties STDOUT and STDERR to the current terminal, unless otherwise specified.

To find out whether one is running an interactive shell or not, execute
`$ echo $-`, which will display the flags set for the shell. If *i* is present,
the shell is interactive.

# Man page
The linux manual used to come in books and there used to be 7 books. Running
`man printf` will display the manual found in the first available manual page. In 
fact it's no. 1. If one does `man -a printf` it searched all manual pages. On my
ubuntu box, there was an entry in 1 and 3.

# Processes Basics
* Processes turn a single CPU into multiple virtual CPUs.
* Each process runs on a virtual CPU.
* Why do we need processes?
    * Provide (illusion) of concurrency
    * Simplicity of Porgramming
    * Allow better utilisation of machines resources - different processes 
    require different resources at a certain time.
* Each process has environment variables, file descriptors, and other properties
associated with it.
* Enviroment variables are inherited.
* Current working directory is inherited as well.
* File descriptors and fd tables (simulteneous access, append mode, accessing after removal)
* There is limitaion of arguments to the program. `xargs(1) --show-limits`
shows the limits

![Inheritance of Processes](https://github.com/cinsk/bash-playground/blob/master/figures/Inheritance%20of%20Process%20Information.png?raw=true)

In Linux, with proc file system, you can read
* /proc/{PID}/cwd – current directory of the process
* /proc/{PID}/environ – environment variables for the process. Use 
`cat environ | xargs -0 -n 1 echo` to list env variables.
* /proc/{PID}/fd/ – list of file descriptors of the process
* /proc/{PID}/limits – list soft/hard limits of resources for the process
* See also the man page of proc(5).

## Processes and files, sockets
* `/usr/bin/lsof` lists files for a specific process
    * `-p PID`
    * `-i` 
    * `a` and operator
    * `-p` write out the port numbers
* `/bin/fuser <FILE_NAME>` can help identify processes using files or sockets
    * example: `sudo /bin/fuser -n tcp 8080`
    * example: `sudo /bin/fuser -n udp 8080`
    * see more at fuser(1)

# Miscellaneous Unix utilities
## ```xargs```
```xargs``` is used to build and execute command lines from standard input. There are commands such as `grep` and `awk` that can accept standard input as a parameter, or argument by using a pipe. However, others such as `cp` and `echo` disregard standard input stream and rely solely on the arguments found after the command.

For example, the command below can return and error due to **Argument list too long**.
```bash
rm `find /path -type f`
```

In order to solve it, one can use `xargs` in order to split it into sublists and execute the commands separately for each sublist.

```bash
find /path -type f -print | xargs rm
```

### `xargs` examples
```
seq 10 | xargs echo
seq 10 | xargs -n 1 echo
seq 10 | xargs -I {} echo 'hello - {}'
seq 10 | xargs -I {} bash -c 'echo "$$ - {}"'
seq 10 | xargs -I {} bash -c 'sleep 1; echo "$$ - {}"'
# check /proc/cpuinfo to get the proper number of parallelism
seq 10 | xargs -I {} -P 4 bash -c 'sleep 1; echo "$$ - {}"'
 
find . -name '*.java' | xargs grep PATTERN
find . -name '*.java' | xargs -I {} grep PATTERN {}
find . -name '*.java' | xargs -P 4 -n 1 -grep PATTERN
 
 
find . -path './tst' -prune -o -name '*.java' -print | xargs grep -n config
find . -path './tst' -prune -o -name '*.java' -print -o -name '*.cfg' -print | xargs grep -n inPath
 
 
findstr() {
  find . -path './tst' -prune -o -name '*.java' -print -o -name '*.cfg' -print | xargs grep "$@"
}
 
find . ! -path . -maxdepth 2 -name 'Config' | xargs grep log4j | grep '= *1[.0-9]*'
 
find . ! -path . -maxdepth 1 -type d | xargs -I {} bash -c 'cd {}; git status'
find . ! -path . -maxdepth 1 -type d | xargs -P 4 -I {} bash -c 'cd {}; git fetch
find . ! -path . -maxdepth 1 -type d | parallel --progress 'cd {}; git fetch'
 
top -b -n 1 -U jp2011 | grep jp2011
```


## Terminal customisation commands
* tput is used for terminal customisation
* TERM variable is inherited by bash. It doesn't set it.

# Bash Scripting

## General Bash Notes
* bash scripts only have lists
* careful with versions
* most linux systems have version 4, which includes map

## Scripts
### Shebang
* `#!interpreter [optional-arg]`.
* One must provide an absolute path to the interpreter.

### Argument passing
* usually just a single character `-f -l`
* in order to finish the options and expect arguments you use `--`
* `--` can be used for long flags
* `[KEY=[VAL]] [command-name[argument...]]` (no blank between blank KEY=VAL)
* `LD_LIBRARY_PATH=.... sudo yum install ....`
* K1='hello world' or K2="hello world"
* `echo \f` will print `f`.
* `echo '\f'` will print the string `\f`.


### execve(2)
It executes a file which contains a script.
Execve() transforms the calling process into a new process.  The new process is constructed from an ordinary file, whose name is pointed to by path, called the new process file.  This file is either an executable object file, or a file of data for an interpreter.

### Question
```awk
#!/usr/bin/awk -F: -f

{ print $1 }
```
Executed as: `cat /etc/passwd | ./script`.  First of all it tries to define colon `:` as the separator and using `-f` to read the AWK program source from the provided file. The "program" specified is always executed once for each line (or "record" in awk parlance) of input.

Why is this a bad script?
Because `awk` does not know option `-F: -f`. This however works fine on Mac's shell. Not in ubuntu.


## Redirection
See this [link](http://www.tldp.org/LDP/abs/html/io-redirection.html) for more information. 

```
>         ls > xxx
<         cat < hello.java
2> file.txt   //redirect STDOUT to some file      
1>&2  redirecting standard output to the std error
2>&1  redirecting std error to std output
&> /dev/null  // redirect both STDOUT and STDERR to some file
```

| I/O    | File Descriptor         |
|--------|-------------------------|
| STDIN  | fd0 (usually keyboard)  |
| STDOUT | fd1  (usually terminal) |
| STDERR | fd2 (usually terminal)  |

```
if xxx; then
	echo "error" 1>&2
    exit 1
fi 
```

```
xxxx > out.txt 2>err.txt
```


```
xxx 1>&2 2>/dev/null
```
fd1 -> old fd2
fd2 -> null

### Disable input using redirection
`./script.sh > /dev/null` removes the output from the shell completely. Then take an example of this script:
```
...
exec > /dev/null # swallow all the output
exec < /dev/null # any attempt to read from standard input will fail
```


### Redirection examples
See [here](http://www.tldp.org/LDP/abs/html/io-redirection.html) for more examples.
```
COMMAND >FILE   # redirect the stdout of COMMAND to FILE
COMMAND 1>FILE  #
 
  ls > file.lst
 
COMMAND >>FILE  # redirect the stdout of COMMAND, and append to FILE
COMMAND 1>>FILE #
 
  echo "log line..." >> output.log
 
COMMAND 2>FILE  # redirect the stderr of COMMAND to FILE
COMMAND 2>>FILE # redirect the stderr of COMMAND, and append to FILE
 
  which python 2>/dev/null
 
COMMAND &>FILE  # redirect the stdout/stderr of COMMAND to FILE (i.e. redirect all output)
 
  javac Hello.java &> output.txt
 
COMMAND M>&N    # redirect the file descriptor M to the file descriptor N.
                # M defaults to 1, if not provided
 
  COMMAND 1>&2    # redirect the stdout(1) to stderr(2)
  COMMAND 2>&1    # redirect the stderr(2) to stdout(1)
 
    echo "error: file not found" 1>&2
    gcc hello.c 2>&1 | less
 
COMMAND <FILE   # redirect the stdin of COMMAND from FILE (i.e. accepting input from FILE as stdin)
COMMAND 0<FILE  #
 
    cat <input.txt
 
COMMAND <&N     # redirect the file descriptor N to stdin (i.e. Link stdin with the file descriptor)
COMMAND 0<&N    #
 
 
exec J<>FILE # open FILE for read/write, assign the file desciptor J.
 
exec J>&-    # close output file descriptor J
exec J<&-    # close input file descriptor J
 
    exec 0<&-   # close stdin
    exec 1>&-   # close stdout
    exec 2>&-   # close stderr
 
        exec 3<> /dev/tcp/google.com/80
 
        echo -e "GET / HTTP/1.0\r\n\r\n" >&3
        while read line <&3; do
            echo "$line"
        done
        exec 3>&-
```

## Special Files


```
/dev/fd/N              # N is integer starting from 0
/dev/stdin             # identical to /dev/fd/0
/dev/stdout            # identical to /dev/fd/1
/dev/stderr            # identical to /dev/fd/2
/dev/tcp/HOST/PORT     # bash attempt to open the corresponding TCP socket
/dev/udp/HOST/PORT     # bash attempt to open the corresponding UDP socket
/dev/null
/dev/zero
/dev/random
/dev/urandom
/dev/ttyN              # N is an integer
```



### Quiz
Assuming that in your system, has additional hard disk which is assigned to /dev/disk2, which is not mounted yet. What is the meaning of `cat /dev/zero > /dev/disk2`?

This will wipe out all the bits in the hard drive.

Assuming that in your system, has two additional hard disks, which have exactly same specification. The first one is assigned to /dev/disk2, and the second one is to /dev/disk3. What is the meaning of `cat /dev/disk2 > /dev/disk3`?

This will create a replica of the hard drive.

### Device file
```
/dev/disk*                      # Hard disk (MacOS)
 
/dev/hda                        # IDE hard disks
/dev/hda1
/dev/hdb
/dev/hdb1
 
/dev/sda                        # SCSI hard disks
/dev/sda1
/dev/sda2
/dev/sdb
 
/dev/xvd*                       # Xen Virtual Block devices (VM)
 
/dev/pts/0 ... /dev/pts/30      # Pseudo terminal devices
/dev/tty0                       # Terminal devices
 
   
 
/dev/random                     # Random number generator (slow, more randomness)
/dev/urandom                    # Random number generator (fast, less randomness)
 
   head -c 4 /dev/random | od -An -t u4 # print a random 32-bit integer.
```

One can write into another terminal:
```
# In terminal #1
$ tty
/dev/pts/3
 
# In terminal #2
$ echo "hello world" > /dev/pts/3   # this will write into terminal 1
```





## Pipes

* ```set -euxo pipefail```  makes sure that if any of the commands in the pipeline fail, that error code will be returned.
    * `e`: This option will cause a script to exit immediatelly when one of its command fails. By default, the script just ignores failing commands and continues with executing the next line. If you do not want a failing command to trigger an exit, you can use `command || true`, or you can disable it temporarily by `set +e` (the plus sign works on all flags, and you can find the current flag statuses by running echo `$-`). 
    * `o`: The shell by default looks only at the exit code of the last command of the pipeline. This option ensures that the exit code of a pipeline will be the same as the exit code of its right-most command to exit with a non-zero status (if any), or zero. 
    * `u`: This option causes shell to exit whenever an undefined variable is used.
    * `x`: This option causes bash to print every command before executing it. This is a great help while debugging the script, but beware, it is also very verbose. 


## Control Directives
### if
```
if command; then
   -----
elif command; then
   -----
else
   -----
fi
```
**One line version:**

``` if command; then true-part-command; fi ```

**Example:**
```
if which python3; then
    python3 ~.py
else
    python legacy.py
fi
```

### for
``` 
for f in *.java *.c ; do
	echo "$f"
done
```

### test
It only returns 0 or 1 based on the expression.

e.g. ```test -f xx.java``` will return 0 if it finds the file, non-zero otherwise
```test -d a.sh```, ```test -x  a.sh```

```
test arg1 -eq arg2
test arg1 -ne arg2
test arg1 -gt arg2
test arg1 -ge arg2
test arg1 -lt arg2
test arg1 -le arg2
```


```if [xxxxx]; then```
is identical to
```if test xxxxx; then```

other things include: `[[, ~=`

```
if cmd          # check the return status of cmd
if [[ $(cmd) ]] # check if cmd has any output
```

**Examples**

```
PYTHON2=$(which python 2>/dev/null)
if [ -z "$PYTHON2" ]; then
    if [ -x "/apollo/env/envImprovement/bin/python" ]; then
        PYTHON2="/apollo/env/envImprovement/bin/python"
    fi
fi
 
if [ -z "$PYTHON2" ]; then
    error 1 "python2 not found"
fi
```

```
PY = $(which python 2>/dev/null)
if [ -z "$PY"]; then 
    echo "error" 1&>2
    exit 1
fi
```

`-z` means if variable is empty/non-defined


```
if ! which python3 2>/dev/null; then
    echo
fi
```

**Test function flags**
* -f : file exists
* -x : file exists and is executable


`if xx --version 2>&1 | grep "2\.[0-9]" then ...` to find out whether there is python version 2.


## [Expansions](https://www.gnu.org/software/bash/manual/html_node/Shell-Expansions.html)
* brace expansions
    * a mechanism by which arbitrary strings may be produced.
    * `bash$ echo a{d,c,b}e`
    * Official notation is ` {x..y[..incr]}`, where x and y are integers or chars
    and  incr is an optional integer to specify increment.
* tilde expansion `ls ~/.bashrc`, `ls ~jp2011/Documents`
* variable/parameter expansion $PATH ${PATH}H ${PATH:-/bin}
    * The `$` character introduces parameter expansion, command substitution,
    or arithmetic expansion. The parameter name or symbol to be expanded may be
    enclosed in braces, which are optional but serve to protect the variable to
    be expanded from characters immediately following it which could be
    interpreted as part of the name.
    * `${parameter:-word}`: if the parameter is unset or null, the expansion
    of *word* is substuted.
    * `${parameter:=word}`: if parameter is unset or null, the expansions of word
    is assigned to parameter.
    * `${parameter:?word}`: if parameter is unset or null, the expansions of word
    (or a message to that effect if word is not present) is written to the standard
    error and the shell, if it is not interactive, exits. Otherwise, the value 
    of parameter is substituted.
    * `${parameter:+word}`: if parameter is null or unset, nothing is substituted,
    otherwise the expansion of word is substituted
    * and more...
* command substitution - allows the output of a command to replace the command 
itself. Command substitution happens when the command is enclosed as follows:
    * `$(command)` or `\`command\``. E.g. `\`ls\`` or  `$(ls)`
    * `$()` cannot be nested.
* arithmetic expansion `echo $((expression))`
* process substitution: allows a process's input or output to be reffered to using
a filename. It takses the form:
    * `<(proc_name): the file passes as an argument should be read to obtan 
    the output of proc_name<
    * `>(proc_name)`: writing to the file will provide input for proc_name.
  * e.g. `cat <(echo hello)`
  * `>()`
* Filename expansions
    * After word splitting, unless -f option has been set, Bash scans each word
    for characters `*`, `?`, `[`. If one of the characters appears, then the word
    is regarded as a pattern and replaces with an alphabetically sorted list of 
    filenames matching the pattern.
* ```$?``` refers to the exit code of the last command
* string concatentation just means no spaces
* $' ' supports printf syntax


## Arguments
* `$1`, `${10}` etc. used to refere to arguments to the script/function
* `$#` refers to number of arguments in bash
* `"$@"` when expanded looks like `"$1" "$2" "$3" ...` 
* `"$*"` when expanded looks like `"$1 $2 $3 ..."`
* `$*` when expanded looks like `$1_$2_$3` (assuming IFS=_)

`IFS` is a env variable with all the input separators. Defaults to 
*<space><tab><newline>*.

## Combining commands
* `echo "A"; echo "B"` called in the same shell
* `(echo "A"; echo "B")` creates a subshell and executes contents of the () in it.
    * e.g. `$ (cd A; ls)` will return back to the original directory
* `cat <(echo A; echo B)` will create a temportaty file (*named FIFO pipe*)
with the output of the command in the brackets. It is thus translated into something
like this: `cat /tmp/tmp/1234`.


### Passing arguments
* `curl -L o- out.json 'http://example.com'`  (-L follows the redirect)
* `python hi.py a b c` it will execute the file hi.py and pass in the parameters a,b,c

Notice that the example below invokes `cat` without providing an argument. `cat`
command requires file as an argument. In this case, a temp file is created
with the string content of 'hello'.
```
$ cat CR
hello
^D
hello
$_
```

**TODO:  What is the difference?**

```
$ cat < hello.txt
$ cat hello.txt
```


```
$ cat << EOF
.........
.........
EOF
```
EOF doesn't have special meaning. It's just a delimiter. If there is a line 
beginning with that character, consider it as the end of the input.


**<()**
* `<()` will be replaced by a temporary FIFO file after executing the ... part

```
ruby <( cat << EOF
require 'json'      # ruby source code
json.parse();       # ruby source code   
...                 # ruby source code
EOF
) out.json | .... | python <(cat << EOF
...
EOF)
```
**Why not writing Ruby directly?**
- e.g. we don't need to use HTTP client from Ruby. Curl is much more lightweight.
- just use what's easy in Ruby and what's easy in Bash.
- `awk` can't parse xml or json.


```
ruby <( cat << 'EOF' 
require 'json'      # ruby source code
json.parse();       # ruby source code   
...                 # ruby source code
EOF
) out.json | .... | python <(cat << 'EOF'
 ...
EOF)
```
Same as above but DON'T try to parse/substitute any of the data in between! This
is to alleviate a problem of bash trying to parse and do expansions on the 
ruby/python code. Sometimes this could be desirable though.

## Functions
```
error() {  # no space between error and '('. No function params allowed.

}
```
or
```
function error() {

}
```


"$*" put all in one string
"$@" separate into multiple


```
error() {
  errorcode="$1"
  shift
  echo "error: $*"
  if [ "$errorcode" -ne 0 ]; then
    exit "$errorcode"
  fi
}
```

## Parameter Shifts

|state  | $0    | $1    | $2    | $3      |
|-------| ------|-------|-------|---------|
| before| error | 1     | hi    |there    |
| after | error | hi    | there | <BLANK> |




# Temporary Files
Most UNIX system provides `/tmp` for storing temporary files. Some time ago, this directory was persistent, but nowadays, it is a memory mapped file system. In other words, when the system is rebooted, all previous files in /tmp will be erased.

In bash, the variable `$$` contains the current process id.
```
$ echo $$
123445
$ _
```

You can use `$$` to create a temporary file like this:
```
#!/bin/bash
 
TMPFILE=/tmp/mytmp.$$
 
curl -sL 'some-url-that-gives-data' > "$TMPFILE"
 
processing_command "$TMPFILE"
 
rm -f "$TMPFILE"
```

If you need to create multiple temporary files, you have two options:
* use different name pattern, e.g. `/tmp/mytmp.$$` for one and `/tmp/mytmp2.$$` for the other.
* use `mktemp(1)` command to create temporary files. `mktemp(1)` requires a pathname template, which need to have at least 3 "X" in the end of the template. `mktemp(1)` will create an empty file, and print the pathname of the temporary file. For example:
```
$ mktemp tmp.XXXXXX             # create temporary file in current directory
tmp.da4r23
$ mktemp -t tmp.XXXXXX          # create temporary file in system temporary directory (i.e. /tmp)
/tmp/tmp.Xsaw6r
```
You can create a script like this to use `mktemp(1)`:
```
#!/bin/bash
 
TMPFILE=$(mktemp -t tmp.XXXXXX)
 
curl -sL 'some-url-that-gives-data' > "$TMPFILE"
 
processing_command "$TMPFILE"
 
rm -f "$TMPFILE"
```


## Words of advice
* To create a temporary file, use $$ as part of the filename, and place it in /tmp/.
* Or, use mktemp -t to create temporary files.
* Make sure to delete the temporary files. (See following section for trap command)

# Signals
In general (UNIX based system), you can configure your process to ignore/block/handle signals except SIGKILL and SIGSTOP.

* If you configure your process to ignore specific signal, the signal will be ignored.
* If you configure your process to block specific signal, the signal will be blocked, so your process will not get notified. However, if you unblock the signal, your process will be immediately notified if there was a signal.
* If you install signal handler, then when your process get signal, the signal handler will be executed.

Here's a table of signals and meanings. In the 'Action' columns, 'Term' means that process will be terminated, 'Core' means that process will be terminated with core dump, 'Stop' means the process will be stopped (suspended), and 'Ign' means that the signal will be ignored.

You may not need to understand all signal types. The key signals on scripting will be `SIGHUP`, `SIGINT`, `SIGTERM`, and `SIGKILL`.
* When the connection between your terminal and the system terminated (e.g. ssh connection closed), most processes that uses the same controlling terminal will receive `SIGHUP`. (i.e. any process you created in that terminal) By default, processes will die on `SIGHUP` signal.
* When you press Control+C in the terminal, all processes in the foreground process group will receive `SIGINT`. By default, processes will die on `SIGINT` singnal.
* `SIGTERM` is manually generate by running `kill(1)` command. By default, processes will die on SIGTERM signal.

| Name    | Value    | Action | Comment                                                                 | 
|---------|----------|--------|-------------------------------------------------------------------------| 
| SIGHUP  | 1        | Term   | Hangup detected on controlling terminal or death of controlling process | 
| SIGINT  | 2        | Term   | Interrupt from keyboard                                                 | 
| SIGQUIT | 3        | Core   | Quit from keyboard                                                      | 
| SIGILL  | 4        | Core   | Illegal Instruction                                                     | 
| SIGABRT | 6        | Core   | Abort signal from abort(3)                                              | 
| SIGFPE  | 8        | Core   | Floating point exception                                                | 
| SIGKILL | 9        | Term   | Kill signal                                                             | 
| SIGSEGV | 11       | Core   | Invalid memory reference                                                | 
| SIGPIPE | 13       | Term   | Broken pipe: write to pipe with no readers                              | 
| SIGALRM | 14       | Term   | Timer signal from alarm(2)                                              | 
| SIGTERM | 15       | Term   | Termination signal                                                      | 
| SIGUSR1 | 30,10,16 | Term   | User-defined signal 1                                                   | 
| SIGUSR2 | 31,12,17 | Term   | User-defined signal 2                                                   | 
| SIGCHLD | 20,17,18 | Ign    | Child stopped or terminated                                             | 
| SIGCONT | 19,18,25 | Cont   | Continue if stopped                                                     | 
| SIGSTOP | 17,19,23 | Stop   | Stop process                                                            | 
| SIGTSTP | 18,20,24 | Stop   | Stop typed at tty                                                       | 
| SIGTTIN | 21,21,26 | Stop   | tty input for background process                                        | 
| SIGTTOU | 22,22,27 | Stop   | tty output for background process                                       | 


If you press `^Z`, the process will receive `SIGSTOP`, which makes it stopped(suspended). If you run `fg` built-in, the process will receive `SIGCONT`, which makes it running again.

You can manually send a signal to process(es), by using `kill(1)` command.

```
$ ​kill -TERM 1234               # send SIGTERM to the process (pid:1234)
$ kill 1234                     # the same
 
$ kill -KILL 1234               # send SIGKILL to the process (pid:1234)
$ kill -9    1234               # the same.
 
$ kill -0    1234               # send no signal, instead error checking
                                # which allows you to check whether the process alive or not.
 
$ kill -KILL -1                 # send SIGKILL to all process except init(1)
$ kill -TERM -1234              # send SIGTERM to all process belong to the process group 1234
```

## trap built-in command
`trap` is to register/deregister signal handler to your script.

Proper format will be
```
trap -l                         # list all known signals
trap -p                         # list all registerd handlers
 
trap COMMAND SIGNAL...          # register COMMAND as a handler of SIGNAL...
 
trap - SIGNAL...                # deregister the handler of SIGNAL...
trap "" SINGAL...               # the same
trap '' SIGNAL...               # the same
#!/bin/bash
 
# This script will ignore
trap "echo INTERRUPTED" INT
 
sleep 10                        # point A
# point B
sleep 20                        # point C
# point D
```

You run above script in bash prompt, then the processes are look like this:
| USER     | PID  | PPID | PGID | CMD       | description | 
|----------|------|------|------|-----------|-------------| 
| povalajp | 1000 | 999  | 1000 | -bash     | login shell | 
| povalajp | 1001 | 1000 | 1001 | ./intr.sh | the script  | 
| povalajp | 1002 | 1001 | 1001 | sleep 10  |             | 


You pressed ^C at the point A
Your terminal will send `SIGINT` to all processes belong to the foreground process group of the terminal where PGID is 1001, which means the processs 1001 and 1002.

By default, if your program is not configured to catch `SIGINT`, it will be terminated. Hence `sleep 10` command will receive `SIGINT`, and will terminate.

Your script, `./intr.sh` registered handler code for `SIGINT` using `trap`, so when the script (bash) received `SIGINT`, it will execute the bash command, `echo INTERRUPTED`.

Since `sleep 10` is terminated, your script (bash) will execute the next command, `sleep 20`.

### How do we know whether the previous command received a signal?
In short, by looking at the exit code of previous command.
```
$ do_some_command
$ echo $?                       # $? will contains the exit status of the last executed command.
0
```

* The possible range of the exit status code is between 0 to 255.
* 0 means the command was successful.
* Generally, non-zero means the command was failed.
* If the command not found, bash will return 127.
* If the command was found, but not executable, bash will return 126.
* If the command terminated on a fatal signal N, bash will return 128 + N as the exit status.

### Example
```
#!/bin/bash
 
TMPFILE="/tmp/tmp.$$"
 
curl -sL 'http://some-url-gives-data/' > "$TMPFILE"
 
some-command1-that-process-output "$TMPFILE" # point A
 
rm -f "$TMPFILE"
```
What will happen if you press ^C at the point A?

```
#!/bin/bash
 
TMPFILE="/tmp/tmp.$$"
 
trap "rm -f $TMPFILE" INT
 
curl -sL 'http://some-url-gives-data/' > "$TMPFILE"
 
some-command1-that-process-output "$TMPFILE" # point A
 
rm -f "$TMPFILE"
```
Think about whether it is possible that this script may not remove the temporary file.

### trap `"…"` 0

### trap - `...`
This will remove any registered handler for signals `...`
```
trap - INT HUP TERM             # remove any handler code for signals
                                # SIGINT, SIGHUP, and SIGTERM.
```

### words of advice
* When you need to create a temporary file (or any side effect), always register signal handler to clean up properly.
* In most case, your signal handler code need to end with `exit`. Otherwise the signal may be ignored, which makes it difficult to terminate.
* Your signal handler supposed to finish quickly. Do not put any long timed operation there.
* You could ignore certain signals if you intent to create a daemon using shell script, which is rarely the occasion.
* Bash may not perform any syntax check on the handler.


## nohup and disown
Processes will die on SIGHUP.

There are processes that should not die on SIGHUP. For example, daemon processes such as HTTP server(e.g. apache, ngnix), or terminal session manager such as screen(1) or tmux(1).

You can use `trap` to ignore SIGHUP, but there are better ways to do it.

### nohup
If you want to run COMMAND, and if you think it will take a long time, and you do not want to terminate it even if you disconnect the connection, you could use
```
$ nohup COMMAND
$ nohup COMMAND &
$ nohup COMMAND > FILE &
```
* stdin of COMMAND automatically bound to /dev/null.
* stdout of COMMAND automatically bound to nohup.out (if that's not possible, $HOME/nohup.out)
* stderr of COMMAND automatically bound to stdout.



### disown
If you already have a process, and if you want to make it resistant from `SIGHUP`, use `disown`.
```
$ COMMAND &                     # Run COMMAND in background
[1] 12345
$ disown %1                     # make the job ignoring SIGHUP
```
Or
```
$ COMMAND                       # take too long
^Z                              # press control+Z to stop(suspend) it
[1]+  Stopped       COMMAND
$ bg                            # make COMMAND as a background job
[1]+ COMMAND &
$ disown %1                     # make the job ignoring SIGHUP
```



# Misc Notes
* use `set -o vi` in order to use vi editining mode.







