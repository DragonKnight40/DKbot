; Script to scan new giveaway threads posted on reddit for matches

/*
 * on CONNECT event
 * Start searching for giveaways as soon as a connection is established
 */
on *:CONNECT:{
  DKcheck $null
  timerreddit 0 60 reddit
}

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

/*
 * on SOCKOPEN event
 * Sends an HTTP GET request to reddit
 */
on *:SOCKOPEN:Reddit:{
  var %s = sockwrite -nt Reddit
  %s GET /r/SVexchange/new.xml?sort=new&limit=1 HTTP/1.1
  %s Host: www.reddit.com
  %s Connection: Close
  %s $crlf
}

/*
 * on SOCKREAD event
 * Scans text received from reddit
 */
on *:SOCKREAD:Reddit:{
  var %text, %desc, %string, %oldthree, %stillgiveaway = 0
  sockread -f %text
  while ($sockbr) {
    if ($regex(%text,/<link>(http:\/\/www\.reddit\.com\/r\/SVExchange\/comments\/.*?)<\/link>/gi)) {
      var %currentlink = $regml(1)
      echo -st LINK: %currentlink
      
      if (%currentlink == %lastlink) {
        sockclose Reddit
        echo -st 4HALTED
        halt
      }
      if ($gettok(%currentlink,7,47) == 2979) {
        msg ExpertEvan DUDE %currentlink
        msg #Battle EE: %currentlink
      }
      set %lastlink $regml(1)
    }
    if (%stillgiveaway) {
      echo -st Desc broken up
      %stillgiveaway = 0
      if (!$regex(%text,/^(.+?)<\/description>/gi)) %stillgiveaway = 1
      else %string = $regml(1)
      %desc = $remove($replace($iif(%stillgiveaway,%text,%string),&lt;,<,&gt;,>),[link],[comment])
      %desc = $regsubex(%desc,/<[^>]*?>/gi,$null)
      echo -st Desc: %desc
      checkString %desc
      var %brokenSV = $+(%oldthree,$left(%desc,3))
      var %current, %i = 1
      while (%i < 4) {
        %current = $mid(%brokenSV,%i,4)
        if ($validSV(%current)) {
          echo -st BROKEN SV: %current
        }
        inc %i 1
      }
    }
    elseif ($regex(%text,/<\/pubDate><description>([^\[\]]+?\[g\].+)$/gi)) {
      %string = $regml(1)
      if (!$regex(%string,/^(.+?)<\/description>/gi)) %stillgiveaway = 1
      %desc = $remove($replace(%string,&lt;,<,&gt;,>),[link],[comment])
      %desc = $regsubex(%desc,/<[^>]*?>/gi,$null)
      echo -st Desc: %desc
      checkString %desc
      %oldthree = $right(%desc,3)
      ;$regex(%desc,/(?<!-)\b\d{4}\b(?!-)/)
    }
    sockread -f %text
  }
}

/*
 * on SOCKCLOSE event
 * If matches were found, inform #SVeXchange, otherwise do nothing
 */
on *:SOCKCLOSE:Reddit:{
  if (%givefound != $null) {
    msg #SVeXchange New giveaway thread posted $+ $iif(%lastlink,$+($chr(32),$chr(40),%lastlink,$chr(41)),) $+ . $+($getNicks(%givefoundindex,give),:) you have a match!
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
    if (!%givefoundindex) set %givefoundindex $gettok($1,%i,44)
    else set %givefoundindex $+(%givefoundindex,$chr(44),$gettok($1,%i,44))
    if (!%givefoundsv) set %givefoundsv $2
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
  sockclose Reddit
  sockopen Reddit www.reddit.com 80
}