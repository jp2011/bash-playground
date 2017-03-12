# bash-playground
This is a collection of miscellaneous notes on unix, bash and some code samples for the latter.




## Man page
The linux manual used to come in books and there used to be 7 books.

```xargs``` is used to build and execute command lines from standard input. There are commands such as `grep` and `awk` that can accept standard input as a parameter, or argument by using a pipe. However, others such as `cp` and `echo` disregard standard input stream and rely solely on the arguments found after the command.

For example, the command below can return and error due to **Argument list too long**.
```bash
rm `find /path -type f`
```

In order to solve it, one can use `xargs` in order to split it into sublists and execute the commands separately for each sublist.

```bash
find /path -type f -print | xargs rm
```


## Shebang
* `#!interpreter [optional-arg]`.
* One must provide an absolute path to the interpreter.


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

## Process information
Explains about Environment, File descriptor, File descriptor table, Current directory, spaces for the argments.

* inheritance of environment variables
* file descriptors and fd tables (explain on simulteneous access, append mode, accessing after removal)
* inheritance of current directory
* limitaion of arguments to the program. GNU xargs(1) --show-limits option

In Linux, with proc file system, you can read
* /proc/{PID}/cwd – current directory of the process
* /proc/{PID}/environ – environment variables for the process.
  Use `cat environ | xargs -0 -n 1 echo`
* /proc/{PID}/fd/ – list of file descriptors of the process
* /proc/{PID}/limits – list soft/hard limits of resources for the process

See also the man page of proc(5).

I have a question about `cwd`. I took a process which runs a java process
on my machine. In there, the `cwd` is pointing to the root folder, even though I
use povalajp user. Is that a reason why I have to run it with `sudo`.



## UNIX

* `init` is the mother of all processes, PID=0.
* `runLevel`
* after init() executes /etc/inittab it will run `getty` (terminal device).


shell can be in
* login / non-login shell
* interactive / non-interactive

when I run `bash -l` it runs
* /etc/profile
* ~/.bash-profile
* ~/.bash-login
* ...
* ~/.bash-login
* ~/.

Bash executes /etc/profile and bash-profile only on login shell.


Argument passing
* usually just a single character `-f -l`
* in order to finish the options and expect arguments you use `--`
* `--` can be used for long flags
* `[KEY=[VAL]] [command-name[argument...]]` (no blank between blank KEY=VAL)
* `LD_LIBRARY_PATH=.... sudo yum install ....`
* K1='hello world' or K2="hello world"
* echo \f
* echo '\f' (it will print a chara)


* string concatentation just means no spaces
* $' ' supports printf syntax



* \` \` is equivalent to $(). The former cannot be nested
* tput is used for terminal customisation


* TERM variable is inherited by bash. It doesn't set it.


Expansions
* brace expansions
* tilde expansion ls ~/.bashrc ls ~povalajp/.bashrc
* variable/parameter expansion $PATH ${PATH}H ${PATH:-/bin}
* command substitution (standard output only) `ls` $(ls)
* arithmetic expansion `echo #((1 + 3))`
* process substitution:
  * <() cat <(echo hello):
  * >()



python <()






























# Bash Scripting

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

``` if command; then true-part-command; fi ```

```
if which python3; then
    python3 ~.py
else
    python legacy.py
fi



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

other things include: ```[[, ~=```


## Variables
```$?``` refers to the last command



## Redirection Operators
```
>         ls > xxx
<         cat < hello.java
2> file.txt   //redirect STDOUT to some file      
1>&2  redirecting standard output to the std error
2>&1  redirecting std error to std output
&> /dev/null  // redirect both STDOUT and STDERR to some file
```

* STDIN   fd 0
* STDOUT  fd 1  (one can override fd1 to output to something else than terminal)
* STDERR  fd 2

fd0 keyboard
fd1 terminal
fd2 terminal


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






# Pipes

* ```set -o pipefail```  makes sure that if any of the commands in the pipeline fail, that error code will be returned.











