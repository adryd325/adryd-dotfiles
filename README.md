<pre>
█ .adryd (adryd-dotfiles)
█ version 7

$ bash -c "`curl -s adryd.co/install.sh`"
$ bash -c "`wget -Qo- adryd.co/install.sh`"

<b>DISCLAIMER</b>: These scripts are mostly public for reference on how my 
system is configured, or for others to extend them for their own use. These 
scripts are very opinionated and you may not like what they do.

<b>Components</b>
 - "/modules" contains components that should compatible with 2 or more families
of operating systems / distros. Many of these assume operating systems with
systemd and GNU utilities.
 - "/hosts" scripts 

<b>Installation folder</b>
This should be installed to "~/.adryd".

<b>Windows manual instructions</b>
Since I can't be bothered automating this
 - Install Windows IoT Enterprise LTSC
 - Bypass security questions by not entering a password at user creation stage
 - Fix Windows Store by running `wsreset -i`
 - Install Windows Terminal and App Installer
 - Install the following:
    - 1Password
    - Parsec
    - ImHex
    - disassembler of choice
    - dnSpy
    - USB/IP client
    - Visual Studio Code
    - JetBrains Rider
    - NodeJS
    - msbuild
    - cmake
    - various radio software
