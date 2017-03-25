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

## Pipes

* ```set -o pipefail```  makes sure that if any of the commands in the pipeline fail, that error code will be returned.


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

## Parameter Shifts

|state  | $0    | $1    | $2    | $3      |
|-------| ------|-------|-------|---------|
| before| error | 1     | hi    |there    |
| after | error | hi    | there | <BLANK> |


# Misc Notes

* use `set -o vi` in order to use vi editining mode.







