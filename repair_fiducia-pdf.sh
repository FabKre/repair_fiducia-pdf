#!/bin/bash
# script to replace all RFont inside fiducia-pdf using qpdf

# SETUP
my_needed_commands="cp cut grep rm sed sort strings tr qpdf uniq"

# SETUP: font substitutions
font_mono="DejaVuSansMono"
font_mono_bold="DejaVuSansMono-Bold"
font_sans="DejaVuSans"
font_sans_bold="DejaVuSans-Bold"

print_help() {
  echo "Usage: repair_fiduca-pdf.sh [Options] FILE"
  echo "Options:"
  echo " -h	help text"
  echo " -v	verbose"	
}

check_commands() {
  missing_counter=0
  for needed_command in $my_needed_commands; do
    if ! hash "$needed_command" >/dev/null 2>&1; then
      printf "Command not found in PATH: %s\n" "$needed_command" >&2
      ((missing_counter++))
    fi
  done

  if ((missing_counter > 0)); then
    printf "Minimum %d commands are missing in PATH, aborting\n" "$missing_counter" >&2
    exit 1
  fi
}

extractFontData () {
  i=0
  while read -r lineFlags ; do
      num=$(echo "$lineFlags"|sed 's/^[[:space:]]*//'|cut -d ' ' -f2)
      read -r lineFont
      font=$(echo "$lineFont"|sed 's/^[[:space:]]*//'|cut -d ' ' -f2)
      if grep -q 'RFont' <<<"$font"; then
        rfonts[i]=$font
        if [ $((num%2)) = 1 ]; then
          if grep -q 'Bold' <<<"$font"; then
            fonts[i]=$font_mono_bold
          else
            fonts[i]=$font_mono
          fi
        else
          if grep -q 'Bold' <<<"$font"; then
            fonts[i]=$font_sans_bold
          else
            fonts[i]=$font_sans
          fi
        fi
        if [ "$verbose" == 1 ]; then
          echo "font ${rfonts[i]} will be substituted for ${fonts[i]}"
        fi
        ((i++))
      fi
    done < <(sed -n '/<</{:a;N;/>>/!ba;/Flags/{/FontName/p;}}' <"$1"|grep '/Flags\|/FontName')
}

replaceFont () {
  length=${#fonts[@]}
  for (( i=0; i<length; i++)); do
    sed -i "s:${rfonts[$i]}:/${fonts[$i]}:g" "$1"
  done
}

#
# main
#
check_commands

OPTIND=1
verbose=0

while getopts "vh" opt; do
  case "$opt" in
  h) print_help; exit 0;;
  v) verbose=1;;
  *) ;;
  esac
done
shift $((OPTIND-1))

if [ "$1" = "" ]; then echo "FILE missing"; print_help; exit 1; fi
if [ ! -f "$1" ]; then echo "file $1 does not exist."; exit 1; fi

declare -a rfonts
declare -a fonts
cp -n "$1"{,.bak} # backup file
qpdf -decrypt -qdf "$1" "$1_" # decrypt and convert to qdf
extractFontData "$1_"
replaceFont "$1_"
qpdf -linearize "$1_" "$1"
rm "$1_"