# WSO - Web Shortcuts Open
A Web shortcut manager

wso is a simple shell script for managing and opening webpages links in a browser. It allows you to save, list, and, open web pages with ease. You can group links together and using the group name you can open multiple links together.

## Install
Either run
```bash
sudo sh -c "$(curl -fsSL https://raw.githubusercontent.com/kshku/WSO/main/install.sh)"
```
or run
```bash
sudo sh -c "$(wget -qO- https://raw.githubusercontent.com/kshku/WSO/main/install.sh)"
```
or manually install by copying and pasting the wso.sh file

## Usage
```txt
wso [OPTIONS] [ARGS] [NAMES]

OPTIONS
    -a <link> | --address <link>    Webpage link
    -b <browser> | --browser <browser>
                                    specify the browser to use (if non-specified uses the default one)
    -h | --help                     Show help and exit
    -l | --list                     List saved links
    -n <name> | --name <name>       Save all links given with -a option in <name>. All links should be given before this option
    -r <link | name> | --remove <link | name>
                                    1) If <link> is given then removes the <link> from all the names.
                                    2) If <name> is given then removes the <name>
                                    3) If <name> is given and <link> is given using -a(need to give before -r) then removes all the links given in  <link> from <name>
                                    Can't give <link> and <name> using -n option. (It removes <link> from all names and prints error)
NOTE
    HERE THE NAME REFERS TO THE NAME OF THE GROUP
```

## Exammples

Save the link https://github.com as github
```bash
wso -a https://github.com -n github
```

Saving multiple links together
```bash
wso -a https://somedocumentations.com -a https://someotherdocumentations.com -n work
```
Can specify as many links as you want, but separate the links using -a option.

Listing saved links
```bash
wso -l
```
Removing a group
```bash
wso -r work
```
Removing a link **FROM ALL THE GROUPS**
```bash
wso -r https://github.com
```
Removing a perticular link from perticular group
```bash
wso -a https://somedecumentation.com -r work
```
Opening the saved groups
```bash
wso github
```
Opening multiple groups
```bash
wso github work
```
To open the link in perticular browser instead of using default browser
```bash
wso -b browser_name group name
```

## Note
In my system google-chrome is present as google-chrome-stable,
but xdg-settings gives browser name as google-chrome.
So it should be changed to google-chrome-stable. So I added this line of code.
```bash
[ "$browser" = "google-chrome" ] && browser="google-chrome-stable"
```
If you have problems like this, you can fix it by adding similar statements in the wso.sh script.
