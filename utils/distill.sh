#!/bin/bash

_extract_sermon() {

  local readonly pdf_file="$1"
  local readonly sermon_pages="$2"
  local readonly sermon_title="$3"

  echo "${pdf_file} pg ${sermon_pages}"
}

_catalog_namespaces() {

  local accum=''

  while read line; do
    namespace="${line%%.pdf#page=*}"
    selection="${accum}${accum:+ }${namespace}"
    if [[ $(echo -n "${selection}" | tr ' ' '\n' | uniq -d) ]]; then
      true
    else
      accum="${selection}"
    fi
  done <<-__EOT__
	$( cat ./Dads_Sermons_Alphabetical_Rev3.html \
	    | grep 'href="Dads_Sermons' \
	    | sed 's@.*<A href="@@' \
	    | sort \
	)
	__EOT__

  NAMESPACE_CATALOG="${accum}"
}

_enumerate_indices() {

  for namespace in $(echo "$NAMESPACE_CATALOG" | tr ' ' '\n'); do
    echo "${namespace}"

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
	    | grep "${namespace}" \
	    | sort -t '=' -n -k2 \
	  )
		__EOT__

    compl_set=''

    # complement set of page numbers
    for j in $(seq 1 ${sermon_page_begin}); do
      if [[ -z $(echo -n "${j} ${index_set}" | tr ' ' '\n' | sort -n | uniq -d) ]]; then
        compl_set="${compl_set}${compl_set:+ }${j}"
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
}



#  compl_set=''

  # complement set of page numbers
#  echo -n "extract_image() ${i}.pdf pg 1"
#  for j in $(seq 2 ${sermon_page_begin}); do
#    if [[ -z $(echo -n "${j} ${index_set}" | tr ' ' '\n' | sort -n | uniq -d) ]]; then
#      echo -n ",${j}"
#      compl_set="${compl_set}${compl_set:+ }${j}"
#    else
#      echo
#      #echo -n "extract_image() ${i}.pdf pg ${j}"
#      _extract_sermon "${i}.pdf" "${j}" "xxyyzz"
#    fi
#  done






_catalog_namespaces
_enumerate_indices


