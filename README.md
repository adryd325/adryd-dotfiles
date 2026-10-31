<pre>
█ .adryd (adryd-dotfiles)
█ version 8

$ bash -c "`curl -s adryd.co/install.sh`"
$ bash -c "`wget -o- adryd.co/install.sh`"
</pre>

## Installation folder
This should be installed to "~/.adryd".

## Deploying

Steps that require manual intervention should be labeled with 
`# MANUAL INTERVENTION` comments describing what steps must be taken to restore
full functionality. An example of this are when keys are required

### Bash style guide
For the most part just follow 
[Google's style guide](https://google.github.io/styleguide/shellguide.html). 
ShellCheck will warn you about this most of the time and shfmt will normalise 
things.

Although Google's guide specifies to always header with `#!/bin/bash`, don't do
that. Use this:
```bash
#!/usr/bin/env bash
cd "$(dirname "$0")" || exit $?
set -eu
source ../relative/path/to/lib.sh
AR_MODULE="module name for logging"
```

For files executed everywhere like lib, install, and download: Remember that you 
might be running these on weird installations. MacOS's default bash is quite 
out of date for example.

### Structure
This repo is kind of a pain to manage since I'm bearing the weight of 
multiple rewrites and I want to keep some old stuff going. I'm also trying to 
manage both my personal computers and also servers/containers here.

```
|- extra
|- hosts 
| |- container: 
| |- desktop: these should contain *hardware specific* configurations for a 
| |           given machine and import the modules needed
| | |- framework-13: my primary (linux) laptop 
| | |- macbook-pro-2020: a mac I remote into for MacOS exclusive apps like 
| | |                    Excentro
| \ \- iphone-15: iSH alpine for my phone because it's funny
```
</pre>
