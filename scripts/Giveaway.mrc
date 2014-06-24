; Script to scan new giveaway threads posted on reddit for matches

/*
 * on .Start/.Stop event
 * Starts/stops searching for giveaways
 */
on $*:TEXT:$($+(/^,$DKtrigger,(Start|Stop)\b/Si)):*:{
  if (!($nick == $mnick && $me == DKbot)) halt
  var %action = $regml(1)
  if (%action == start && !$timer(reddit)) {
    timerreddit 0 60 reddit
    msg $nick Now searching for new giveaways.
  }
  elseif (%action == stop && $timer(reddit)) {
    timerreddit off
    msg $nick No longer searching for new giveaways.
  }
}

on *:SOCKOPEN:Give:{
  var %s = sockwrite -nt Give
  %s GET /r/SVexchange/new.xml?sort=new&limit=1 HTTP/1.0
  %s Host: www.reddit.com
  %s Connection: Close
  %s $crlf
}
on *:SOCKREAD:Give:{
  if ($sockerr) halt
  else {
    var &temp, &text
    write -c tempGiveaway
    while ($sock($sockname).rq) {
      sockread &temp
      bwrite tempGiveaway -1 -1 &temp
    }
    bread tempGiveaway 0 $file(tempGiveaway).size &text
    if ($bfind(&text,$calc($file(tempGiveaway).size - 6),</rss>)) {
      var %startLink = $calc($bfind(&text,0,<guid isPermaLink="true">) + 25), %endLink = $bfind(&text,0,</guid>)
      var %link = $bvar(&text,%startLink,$calc(%endLink - %startLink)).text
      echo -st Link: %link
      if (%link == %lastlink) {
        echo -st Same link
      }
      else {
        if (%link != $null) {
          set %lastlink %link
        }

        var %i = $calc($bfind(&text,0,</pubDate><description>) + 23), %end = $calc($bfind(&text,0,</description></item>) - 3), %current
        var %type = $bvar(&text,%i,128).text
        echo -st Type: %type
        if (!$regex(%type,/\[g\]/i)) {
          %i = %end
          ; This is to make sure that we do not enter the loop
          echo -st Not a giveaway
        }
        while (%i < %end) {
          %current = $bvar(&text,%i,4).text
          if ($validSV(%current)) {
            echo -st VALID SV: %current
            var %indexList = $getSVIndex(%current)
            if (%indexList != $null) addFound %indexList %current
          }
          inc %i 1
        }
      }
    }
  }
}

/*
 * on SOCKCLOSE event
 * If matches were found, inform #SVeXchange, otherwise do nothing
 */
on *:SOCKCLOSE:Give:{
  if (%givefound != $null) {
    var %msg = New giveaway thread posted $+($chr(40),%lastlink,$chr(41),$chr(46)) $+($getNicks(%givefoundindex,give),:) you have a match!
    msg #SVeXchange %msg
    msg #smogonwifi %msg
  }
  unset %give*
  echo -st 4END REDDIT
}

/*
 * addFound
 * Very similar to addFound in Pastebin.mrc
 * Adds indexes to %givefoundindex and SV's to %givefoundsv
 * $1: Comma-separated list of indexes to add
 * $2: Comma-separated list of SV's to add
 */
alias -l addFound {
  var %i = 1
  while (%i <= $numtok($1,44)) {
    if (%givefoundindex == $null) set %givefoundindex $gettok($1,%i,44)
    else set %givefoundindex $+(%givefoundindex,$chr(44),$gettok($1,%i,44))
    if (%givefoundsv == $null) set %givefoundsv $2
    else set %givefoundsv $+(%givefoundsv,$chr(44),$2)
    inc %i 1
  }
  DKlog $2 GIVE %lastlink
  inc %givefound 1
}

/*
 * checkString
 * Scans $1- for SVs, checks them for matches, and calls addFound for every match found
 * $1-: String to scan
 */
alias -l checkString {
  var %current, %i = 1, %end = $calc($len($1-) - 3)
  while (%i <= %end) {
    %current = $mid($1-,%i,4)
    if ($validSV(%current)) {
      echo -st VALID SV: %current
      var %indexList = $getSVIndex(%current)
      if (%indexList != $null) addFound %indexList %current
    }
    inc %i 1
  }
}

/*
 * reddit
 * Searches for the newest post on /r/SVeXchange
 */
alias reddit {
  echo -st 4START REDDIT
  sockclose Give
  sockopen Give www.reddit.com 80
}