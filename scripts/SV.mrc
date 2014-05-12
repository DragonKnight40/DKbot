alias sv {
  if (%sv) {
    echo -at 2* A search is already in progress; please try again after it has finished.
    return
  }
  set %sv $noLeadZeros($$1-).multi
  set %nick $me
  echo -at 2* Searching...
  sockopen SV www.reddit.com 80
}
on $*:TEXT:/^[!.^](SV|ShinyValue)\s[0-9]+/Si:#svexchange:{
  if (DKBot ison $chan && $me != DKbot) halt
  if (%sv) {
    notice $nick A search is already in progress; please try again after it has finished.
    return
  }
  set %sv $noLeadZeros($$2-).multi
  set %nick $nick
  notice %nick Searching...
  sockopen SV www.reddit.com 80
}
on *:SOCKOPEN:SV:{
  var %s = sockwrite -nt SV
  %s GET /r/pokemontrades/wiki/shinyids HTTP/1.1
  %s Host: www.reddit.com
  %s $crlf
}
on *:SOCKREAD:SV:{
  if (!%sv) halt
  var %text
  sockread %text
  if (%text == <th>Username</th>) set %start 1
  elseif (%start) {
    if ($regex(link,%text,/^<td><a href="/u/.+" rel=".*">/u/(.+)</a></td>$/)) {
      set %result $regml(link,1)
    }
    elseif ($regex(data,%text,/^<td>(?!<a)(.*)</td>$/)) {
      set %result $+(%result,$chr(44),$regml(data,1))
    }
    elseif (</tr> isin %text) {
      if ($istok(%sv,$noLeadZeros($gettok(%result,4,44)),32)) {
        var %user = $+(/u/,3,$gettok(%result,1,44),,$chr(32),$chr(40),$gettok(%result,4,44),$chr(41))
        if (%user !isin %resultset) {
          set %resultset $iif(%resultset != $null,$+(%resultset,$chr(32),$chr(124),$chr(32)),$null) %user
        }
      }
      unset %result
    }
    elseif (</tbody></table> isin %text) {
      $iif(%nick == $me,echo -at 2*,notice %nick) $iif(%resultset,%resultset, $+ $iif(%nick == $me,2,4) $+ No results found.)
      unset %nick
      unset %SV
      unset %start
      unset %result
      unset %resultset
      sockclose SV
      halt
    }
  }
}

alias noLeadZeros {
  var %return = $1
  if ($prop == multi) {
    var %i = 1, %end = $numtok(%return,32), %current
    while (%i <= %end) {
      %current = $gettok(%return,%i,32)
      while ($left(%current,1) == 0) {
        %current = $right(%current,-1)
      }
      %return = $puttok(%return,%current,%i,32)
      inc %i 1
    }
  }
  else {
    while ($left(%return,1) == 0) {
      %return = $right(%return,-1)
    }
  }
  return %return
}

alias recursiveNoLeadZeros {
  return $noLeadZeros($1)
}