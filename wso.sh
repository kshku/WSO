#!/bin/sh

# Storage file
file="$HOME/.wso"

# checking the existance of the tools
command -v getopt > /dev/null 2>&1 || { echo "Error: getopt is not found. Exiting..." >&2 ; exit 1; }
command -v xdg-settings > /dev/null 2>&1 || { echo "Error: xdg-settings is not found. Exiting..." >&2 ; exit 1; }

# using getopt to evaluate the input and setting it as the arguments of this script
temp=$(getopt -o 'hla:n:r:b:' -l 'help,list,address:,name:,remove:,browser:' -n "wso" -- "$@")
# in case of error in getopt it will print the error message, and we need to exit
[ $? -ne 0 ] && { echo "Exiting..." >&2; exit 1; }
eval set -- "$temp"
unset temp

# functions
list() {
    # Check the file's existance
    if [ ! -f "$file" ] || [ -z "$(cat "$file")" ]; then
        echo "No saved links"
        return
    fi
    # using awk to list the links
    awk 'BEGIN { printf "%-26s%s\n", "name", "link(s)" }; {list[$1] = list[$1] " " $2 ";" }; END { for (name in list) printf "%-24s %s\n", name, list[name] }' "$file"
}

print_usage()  {
    cat << EOF >&1
NAME
    wso - script to save and open webpage links in a browser
USAGE
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
EOF
}

remove_name_or_link() {
    # Check the file's existance
    [ -f "$file" ] || { echo "No links are saved"; return; }
    # pick the lines not containing given string and override the file with collected lines
    r="$(awk -v r="$1" '{ if ( $1 != r && $2 != r) print $0}' "$file")"
    # if r is same as file content then the given string is not found
    [ "$r" = "$(cat "$file")" ] && { echo "$1 is not found"; return; }
    echo "$r" > "$file"
    echo "$1 is removed successfully"
}

remove_links_from_name() {
    # Check the file's existance
    [ -f "$file" ] || { echo "No links are saved"; return; }
    # For all the links given to remove from the name
    # pick the links not conataining given name and given link and overried the file with collected lines
    links=
    for link in $1; do
        r="$(awk -v r="$link" -v f="$2" '{ if ($1 != f || $2 != r) print $0 }' "$file")"
        # if r is same as file content then the given link is not saved in that name
        [ "$r" = "$(cat "$file")" ] && { echo "$link is not saved in $2"; continue; }
        echo "$r" > "$file"
        links="$links $link"
    done
    [ -n "$links" ] && echo "$links removed from $2"
}

save_links() {
    # if file is not present create the file or the content of file is empty then remove the file and create a new file(else the file will have a empty line which affects the listing of links).
    [ -f "$file" ] && { [ -z "$(cat "$file")" ] && \rm "$file"; touch "$file"; } || touch "$file"
    # for all the given links to save in the name
    # Check whether the link already exists.
    # If not add it
    links=
    for link in $2; do
        f="$(awk -v sa="$1" -v sb="$link" '{ if ($1 == sa && $2 == sb) print $0 }' "$file")"
        [ -z "$f" ] && { echo "$1 $link" >> "$file"; links="$links $link"; } || echo "$(echo $f | awk '{ printf "%s is already in %s", $2, $1 }')"
    done
    [ -n "$links" ] && echo "$links saved in $1"
}

# check whether arguments are given or not
if [ $# -eq 1 ]; then
    print_usage
    exit 0
fi

# variables to store data
addr=
browser="$(xdg-settings get default-web-browser | awk -F'[.]' '{print $1}')"

# Check the arguments
while true; do
    case "$1" in
        '-a' | '--address')
            # all the links are stored in addr until -n or -r option is given
            addr="$addr $2"
            shift 2
            continue
        ;;
        '-b' | '--browser')
            # override the default browser
            browser="$2" 
            shift 2
            continue
        ;;
        '-h' | '--help')
            print_usage
            exit 0
        ;;
        '-l' | '--list')
            list
            shift
            continue
        ;;
        '-n' | '--name')
            # check whether the links are given before giving name
            [ -n "$addr" ] || { echo "Error: No links are given before -n option" >&2 ; shift 2; continue; }
            save_links "$2" "$addr"
            # after saving empty the addr variable
            addr=
            shift 2
            continue
        ;;
        '-r' | '--remove')
            # if links are not given then we need to remove the name or the perticular link from all names
            # else we will remove the perticular link from perticular name
            [ -n "$addr" ] && { remove_links_from_name "$addr" "$2"; addr=; } || remove_name_or_link "$2"
            shift 2
            continue
        ;;
        '--')
            # options are completed. names may be present after this argument
            shift
            break
        ;;
        *)
            echo "Error: Internal error! Exiting..." >&2
            exit 1
        ;;
    esac
done

# Check whether the address is given but no name is given to save it
[ -n "$addr" ] && echo "Warning: Ignoring $addr"
# If no file is found then there is no link to open
[ ! -f "$file" ] && [ $# -ne 0 ] && { echo "No saved links are found. Exiting..." >&2 ; exit 1; }
# If no name is given just exit(exit code is zero. Because the user may have added or remvoed addresses or asked to list addresses).
[ $# -eq 0 ] && exit 0
# in my system google-chrome is present as google-chrome-stable but xdg-settings gives browser name as google-chrome
# so if the browser is google-chrome, it should be changed to google-chrome-stable
# If you have problems like this, you can solve it here by adding similar statements
[ "$browser" = "google-chrome" ] && browser="google-chrome-stable"
# Check whether the browser exitst or not
command -v "$browser" > /dev/null 2>&1 || { echo "Error: $browser is not found. Exiting..." >&2 ; exit 1; }

# collect all the links saved in name
links=
for n; do
    link="$(awk -v s="$n" '{ if ($1 == s) print $2 }' "$file")"
    [ -z "$link" ] && { echo "No link is saved in $n"; continue; }
    links="$links $link"
done

# Open the links in the browser
# If the browser support other features to open the links you may need to change this line
[ -n "$links" ] && "$browser" $links
