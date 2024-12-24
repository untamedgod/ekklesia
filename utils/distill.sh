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
  #continue
  cat ./Dads_Sermons_Alphabetical_Rev3.html \
    | grep 'href="Dads_Sermons' | sed 's@.*<A href="@@' \
    | sort \
    | grep "${i}" \
    | sort -t '=' -n -k2

  echo
done

