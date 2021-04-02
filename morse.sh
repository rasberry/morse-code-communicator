#!/bin/bash

function send {
	if [[ -z "$1" ]]; then >&2 echo "missing m-code"; return; fi
	local loc="https://xkcd.com/2445/morse/..."
	curl -s "$loc/$1" \
		-H "User-Agent: Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:87.0) Gecko/20100101 Firefox/87.0" \
		-H "Accept: */*" -H "Accept-Language: en-US,en;q=0.5" \
		-H "Referer: https://xkcd.com/2445/"
}

function mapatom {
	if [[ -z "$1" ]]; then >&2 echo "missing character"; return; fi
	local c=$(echo "$1" | tr '[:upper:]' '[:lower:]')
	case "$1" in
		# alphabet
		"a") echo -n ".-" ;;   "b") echo -n "-..." ;; "c") echo -n "-.-." ;;
		"d") echo -n "-.." ;;  "e") echo -n "." ;;    "f") echo -n "..-." ;;
		"g") echo -n "--." ;;  "h") echo -n "...." ;; "i") echo -n ".." ;;
		"j") echo -n ".---" ;; "k") echo -n "-.-" ;;  "l") echo -n ".-.." ;;
		"m") echo -n "--" ;;   "n") echo -n "-." ;;   "o") echo -n "---" ;;
		"p") echo -n ".--." ;; "q") echo -n "--.-" ;; "r") echo -n ".-." ;;
		"s") echo -n "..." ;;  "t") echo -n "-" ;;    "u") echo -n "..-" ;;
		"v") echo -n "...-" ;; "w") echo -n ".--" ;;  "x") echo -n "-..-" ;;
		"y") echo -n "-.--" ;; "z") echo -n "--.." ;;
		# numbers
		"0") echo -n "-----" ;; "1") echo -n ".----" ;; "2") echo -n "..---" ;;
		"3") echo -n "...--" ;; "4") echo -n "....-" ;; "5") echo -n "....." ;;
		"6") echo -n "-...." ;; "7") echo -n "--..." ;; "8") echo -n "---.." ;;
		"9") echo -n "----." ;;
		# punctuation
		".") echo -n ".-.-.-" ;; ",") echo -n "--..--" ;;  "?") echo -n "..--.." ;;
		"'") echo -n ".----." ;; "!") echo -n "-.-.--" ;;  "/") echo -n "-..-." ;;
		"(") echo -n "-.--." ;;  ")") echo -n "-.--.-" ;;  "&") echo -n ".-..." ;;
		":") echo -n "---..." ;; ";") echo -n "-.-.-." ;;  "=") echo -n "-...-" ;;
		"+") echo -n ".-.-." ;;  "-") echo -n "-....-" ;;  "_") echo -n "..--.-" ;;
		'"') echo -n ".-..-." ;; "$") echo -n "...-..-" ;; "@") echo -n ".--.-." ;;
		# extras and catch-all
		" ") echo -n "/" ;;
		*) echo -n "" ;;
	esac
}

function mapmtoa {
	if [[ -z "$1" ]]; then >&2 echo "missing codeword"; return; fi
	case "$1" in
		# alphabet
		".-")   echo -n "a" ;; "-...") echo -n "b" ;; "-.-.") echo -n "c" ;;
		"-..")  echo -n "d" ;; ".")    echo -n "e" ;; "..-.") echo -n "f" ;;
		"--.")  echo -n "g" ;; "....") echo -n "h" ;; "..")   echo -n "i" ;;
		".---") echo -n "j" ;; "-.-")  echo -n "k" ;; ".-..") echo -n "l" ;;
		"--")   echo -n "m" ;; "-.")   echo -n "n" ;; "---")  echo -n "o" ;;
		".--.") echo -n "p" ;; "--.-") echo -n "q" ;; ".-.")  echo -n "r" ;;
		"...")  echo -n "s" ;; "-")    echo -n "t" ;; "..-")  echo -n "u" ;;
		"...-") echo -n "v" ;; ".--")  echo -n "w" ;; "-..-") echo -n "x" ;;
		"-.--") echo -n "y" ;; "--..") echo -n "z" ;;
		# numbers
		"-----") echo -n "0" ;; ".----") echo -n "1" ;; "..---") echo -n "2" ;;
		"...--") echo -n "3" ;; "....-") echo -n "4" ;; ".....") echo -n "5" ;;
		"-....") echo -n "6" ;; "--...") echo -n "7" ;; "---..") echo -n "8" ;;
		"----.") echo -n "9" ;;
		# punctuation
		".-.-.-") echo -n "." ;; "--..--")  echo -n "," ;; "..--..") echo -n "?" ;;
		".----.") echo -n "'" ;; "-.-.--")  echo -n "!" ;; "-..-.")  echo -n "/" ;;
		"-.--.")  echo -n "(" ;; "-.--.-")  echo -n ")" ;; ".-...")  echo -n "&" ;;
		"---...") echo -n ":" ;; "-.-.-.")  echo -n ";" ;; "-...-")  echo -n "=" ;;
		".-.-.")  echo -n "+" ;; "-....-")  echo -n "-" ;; "..--.-") echo -n "_" ;;
		".-..-.") echo -n '"' ;; "...-..-") echo -n "$" ;; ".--.-.") echo -n "@" ;;
		# extras catch-all
		"/") echo -n " " ;;
		*) echo -n "" ;;
	esac
}

function encode {
	if [[ -z "$1" ]]; then >&2 echo "missing raw message"; return; fi

	local txt="${1//[$'\n\r\t']}"
	local c=0
	local len="${#txt}"
	local isfirst=1
	local m=""
	while [[ "$c" -lt "$len" ]]; do
		local ch="${txt:c:1}"
		if [[ "$isfirst" == "1" ]]; then
			m=$(mapatom "$ch")
		else
			m=$m"_"$(mapatom "$ch")
		fi
		((c++))
		isfirst=0
	done
	echo -n "$m"
}

function decode {
	if [[ -z "$1" ]]; then >&2 echo "missing encoded message"; return; fi
	IFS=' _'
	read -ra all <<< "$1"
	for w in "${all[@]}"; do
		mapmtoa "$w"
	done
}

if [[ -z "$1" ]]; then
	echo "USAGE: $0 \"message\""
	exit 1
fi

mess=$(encode "$1")
resp=$(send "$mess")
decode "$resp"
