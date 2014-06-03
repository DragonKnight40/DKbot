; Script to queue messages to other users

on $*:TEXT:$($+(/^,$DKtrigger,Msg\b/Si)):*:{
  DKcheck $chan
  var %nick = $nick, %user = $2, %time = $ctime, %msg = $3-
  set %DKqueue. [ $+ [ %user ] ] $addtok(%DKqueue. [ $+ [ %user ] ],$+(%nick,$chr(124),%time,$chr(124),%msg),9)
  $iif($chan,notice,msg) %nick Will do.
}

on *:TEXT:*:*:{
  DKcheck $chan
  if (%DKqueue. [ $+ [ $nick ] ] != $null) {
    DKqueue $nick $iif($chan,$chan,$nick)
  }
}

on *:ACTION:*:*:{
  DKcheck $chan
  if (%DKqueue. [ $+ [ $nick ] ] != $null) {
    DKqueue $nick $iif($chan,$chan,$nick)
  }
}

on *:JOIN:#:{
  DKcheck $chan
  if (%DKqueue. [ $+ [ $nick ] ] != $null) {
    DKqueue $nick $chan
  }
}

alias DKqueue {
  var %msgs = %DKqueue. [ $+ [ $1 ] ], %i = 1, %current, %ctime = $ctime, %time
  while (%i <= $numtok(%msgs,9)) {
    %current = $gettok(%msgs,%i,9)
    %time = $calc(%ctime - $gettok(%current,2,124))
    msg $2 $1 (from $gettok(%current,1,124) $simpleTime(%time) ago): $gettok(%current,3-,124)
    inc %i
  }
  unset %DKqueue. [ $+ [ $1 ] ]
}

alias simpleTime {
  var %seconds = $1, %weeks = 0, %days = 0, %hours = 0, %minutes = 0, %msg
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
  if (%weeks > 0) %msg = $addtok(%msg,%weeks weeks,44)
  if (%days > 0) %msg = $addtok(%msg,%days days,44)
  if (%hours > 0) %msg = $addtok(%msg,%hours hours,44)
  if (%minutes > 0) %msg = $addtok(%msg,%minutes minutes,44)
  if (%seconds > 0) %msg = $addtok(%msg,%seconds seconds,44)
  return $replace(%msg,$chr(44),$+($chr(44),$chr(32)))
}