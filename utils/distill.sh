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

for i in $(echo "${accum}" | tr ' ' '\n'); do
  echo "${i}"

  index_set=''

  # index pages from pdf
  while read line; do
    echo "${line}"
    read -r page_begin <<< $(echo "${line}" | grep -oE '#page=[0-9]+' | grep -oE '[0-9]+')
    index_set="${index_set}${index_set:+ }${page_begin}"
  done <<-__EOT__
	$( \
	  cat ./Dads_Sermons_Alphabetical_Rev3.html \
	  | grep 'href="Dads_Sermons' | sed 's@.*<A href="@@' \
	  | sort \
	  | grep "${i}" \
	  | sort -t '=' -n -k2 \
	)
	__EOT__
  echo
  echo "${index_set}"
  echo
done

