; Script to scan pastebins for matches

/*
 * on pastebin.com event
 * Connects to pastebin links
 */
on $*:TEXT:/pastebin\.com\/([a-z0-9]{8})/Si:*:{
  DKcheck $nick
  echo -st 12START PASTE: %countpaste
  unset %paste*
  set %pastestart %countpaste
  set %paste $regml(1)
  set %pastenick $nick
  set %pastesite pastebin.com
  set %pastemsg $iif($chan != $null,msg $chan,msg $nick)
  sockclose Paste
  sockopen Paste %pastesite 80
}

/*
 * on SOCKOPEN event
 * Sends an HTTP GET request to pastebin
 */
on *:SOCKOPEN:Paste:{
  var %s = sockwrite -nt Paste
  %s GET $+($chr(47),raw.php?i=,%paste) HTTP/1.1
  %s Host: %pastesite
  %s Connection: Close
  %s $crlf
}

/*
 * on SOCKREAD event
 * Scans text received from pastebin
 */
on *:SOCKREAD:Paste:{
  var %text
  sockread %text
  while ($sockbr) {
    echo -st  $+ %text
    if (!$sock($sockname).mark && %text == $null) sockmark $sockname 1
    elseif ($sock($sockname).mark) pasteAction %text
    sockread %text
  }
}

/*
 * on SOCKCLOSE event
 * Informs the user of any matches found
 */
on *:SOCKCLOSE:Paste:{
  if ($eggsScanned) {
    if (%pastefound) {
      %pastemsg $+($getNicks(%pastefoundindex,paste),:) you have a match!
    }
    %pastemsg $iif(%pastefound,,No results found.) Eggs scanned: $+(07,$commas($eggsScanned),,.) Total eggs scanned thus far: $+(07,$commas(%countpaste),,.)
  }
  unset %paste*
  echo -st 12END PASTE: %countpaste
}

/*
 * addFound
 * Very similar to addFound in Giveaway.mrc
 * Adds indexes to %pastefoundindex and SV's to %pastefoundsv
 * $1: Comma-separated list of indexes to add
 * $2: Comma-separated list of SV's to add
 */
alias -l addFound {
  var %i = 1
  while (%i <= $numtok($1,44)) {
    if (%pastefoundindex == $null) set %pastefoundindex $gettok($1,%i,44)
    else set %pastefoundindex $+(%pastefoundindex,$chr(44),$gettok($1,%i,44))
    if (%pastefoundsv == $null) set %pastefoundsv $2
    else set %pastefoundsv $+(%pastefoundsv,$chr(44),$2)
    inc %i 1
  }
  DKlog $2 PASTE %pastenick $gettok(%pastemsg,2,32) %paste
  inc %pastefound 1
}

/*
 * eggsScanned
 * Because I am lazy :)
 * Returns: Amount of eggs scanned in current pastebin
 */
alias -l eggsScanned {
  return $calc(%countpaste - %pastestart)
}

/*
 * pasteAction
 * Called once for every line in current pastebin
 * $1-: Line of current pastebin
 */
alias -l pasteAction {
  if (!$1-) return
  if ($regex(chunk,$1-,/^[0-9a-f]+$/)) set %pastechunk 1
  elseif (%pastechunk) {
    unset %pastechunk
    var %brokenSV = $+(%pasteedge,$left($1-,3))
    var %current, %i = 1
    while (%i < 4) {
      %current = $mid(%brokenSV,%i,4)
      if ($validSV(%current)) {
        inc %countpaste 1
        var %indexList = $getSVIndex(%current)
        if (%indexList != $null) addFound %indexList %current
      }
      inc %i 1
    }
  }
  else set %pasteedge $right($1-,3)
  if (!$regex(paste,$1-,/\b(\d{4})\b/)) return
  inc %countpaste 1
  var %sv = $regml(paste,1)
  var %indexList = $getSVIndex(%sv)
  if (%indexList != $null) addFound %indexList %sv
}