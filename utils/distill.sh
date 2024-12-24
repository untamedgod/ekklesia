#!/bin/bash

accum=''

while read line; do
  pdf="${line%%.pdf#page=*}"
  conj="${accum}${accum:+ }${pdf}"
  if [[ $(echo -n "${conj}" | tr ' ' '\n' | uniq -d) ]]; then
    true
  else
    accum="${conj}"
  fi
done <<__EOT__
$( cat ./Dads_Sermons_Alphabetical_Rev3.html | grep 'href="Dads_Sermons' | sed 's@.*<A href="@@' | sort )
__EOT__

echo
echo

# <A href="Dads_Sermons_Warren2_i.pdf#page=10" target="contents" >Acts 10:38</a><br>

for i in $(echo "${accum}" | tr ' ' '\n'); do
  echo "${i}"

  index_set=''

  # index pages from pdf
  while read line; do
    #echo "${line}"
    read -r sermon_page_begin  <<< $(echo "${line}" | grep -oE '#page=[0-9]+' | grep -oE '[0-9]+')
    read -r sermon_title       <<< $(echo "${line}" | grep -oE '.*>.*</a>' )
    index_set="${index_set}${index_set:+ }${sermon_page_begin}"
  done <<-__EOT__
	$( \
	  cat ./Dads_Sermons_Alphabetical_Rev3.html \
	  | grep 'href="Dads_Sermons' | sed 's@.*<A href="@@' \
	  | sort \
	  | grep "${i}" \
	  | sort -t '=' -n -k2 \
	)
	__EOT__

  compl_set=''

  # complement set of page numbers
  echo -n "extract_image() ${i}.pdf pg 1"
  for j in $(seq 2 ${sermon_page_begin}); do
    if [[ -z $(echo -n "${j} ${index_set}" | tr ' ' '\n' | sort -n | uniq -d) ]]; then
      echo -n ",${j}"
      compl_set="${compl_set}${compl_set:+ }${j}"
    else
      echo
      echo -n "extract_image() ${i}.pdf pg ${j}"
    fi
  done
  echo
  echo
  echo
  echo "${index_set}"
  echo
  echo "${compl_set}"
  echo

done



