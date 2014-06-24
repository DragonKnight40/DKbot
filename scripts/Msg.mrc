; Script to queue messages to other users

on $*:TEXT:$($+(/^,$DKtrigger,Msg\b/Si)):*:{
  DKcheck $chan
  var %nick = $nick, %user = $2, %time = $ctime, %msg = $3-, %respond = $iif($chan,notice,msg)
  if (%user == $me || %user == is || %user == in) {
    %respond %nick Lolno.
    halt
  }
  set %DKqueue. [ $+ [ %user ] ] $addtok(%DKqueue. [ $+ [ %user ] ],$+(%nick,$chr(124),%time,$chr(124),%msg),9)
  %respond %nick Message queued for %user $+ .
}

on *:TEXT:*:*:{
  DKcheck $chan
  DKqueue $nick $iif($chan,$chan,$nick)
}

on *:ACTION:*:*:{
  DKcheck $chan
  DKqueue $nick $iif($chan,$chan,$nick)
}

on *:JOIN:#:{
  DKcheck $chan
  DKqueue $nick $chan
}

on *:NICK:{
  DKcheck $newnick
  if (%DKqueue. [ $+ [ $newnick ] ] != $null) {
    var %i = 1, %chan
    while (%i <= $chan(0)) {
      if ($newnick ison $chan(%i)) {
        %chan = $chan(%i)
        break
      }
      inc $i 1
    }
    DKqueue $newnick %chan
  }
}

alias -l DKqueue {
  if (%DKqueue. [ $+ [ $1 ] ] != $null) {
    var %msgs = %DKqueue. [ $+ [ $1 ] ], %i = 1, %current, %ctime = $ctime, %time
    while (%i <= $numtok(%msgs,9)) {
      %current = $gettok(%msgs,%i,9)
      %time = $calc(%ctime - $gettok(%current,2,124))
      msg $2 $1 (from $gettok(%current,1,124) $simpleTime(%time) $+ ): $gettok(%current,3-,124)
      inc %i
    }
    unset %DKqueue. [ $+ [ $1 ] ]
  }
}

alias -l simpleTime {
  var %seconds = $1, %weeks = 0, %days = 0, %hours = 0, %minutes = 0, %msg
  if (%seconds == 0) {
    return just now
  }
  while (%seconds > 604800) {
    inc %weeks
    dec %seconds 604800
  }
  while (%seconds > 86400) {
    inc %days
    dec %seconds 86400
  }
  while (%seconds > 3600) {
    inc %hours
    dec %seconds 3600
  }
  while (%seconds > 60) {
    inc %minutes
    dec %seconds 60
  }
  if (%weeks > 0) %msg = $addtok(%msg,%weeks $+(week,$getS(%weeks)),44)
  if (%days > 0) %msg = $addtok(%msg,%days $+(day,$getS(%days)),44)
  if (%hours > 0) %msg = $addtok(%msg,%hours $+(hour,$getS(%hours)),44)
  if (%minutes > 0) %msg = $addtok(%msg,%minutes $+(minute,$getS(%minutes)),44)
  if (%seconds > 0) %msg = $addtok(%msg,%seconds $+(second,$getS(%seconds)),44)
  return $replace(%msg,$chr(44),$+($chr(44),$chr(32))) ago
}