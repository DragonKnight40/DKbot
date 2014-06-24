; Script to scan logs for matches made in the past

/*
 * on .Recap event
 * Scans logs for SV matches and reports them to the user
 */
on $*:TEXT:$($+(/^,$chr(40),$DKtrigger,$chr(41),Recap,$chr(40),\d,$chr(41),?\b/Si)):*:{
  DKcheck $nick
  var %svlist, %regex, %current, %records = 0, %i = 1, %c = $regml(1), %amount = $regml(2)
  if (!%amount) {
    %amount = 3
  }
  if ($2) {
    if ($isSVmulti($2)) {
      %svlist = $zeroSVmulti($2)
    }
    else {
      msg $nick Invalid $+(parameter,$getS($numtok($2-,32)),.)
      halt
    }
  }
  else {
    %svlist = $getSV($getMainIndex($nick).nick)
  }
  if (%svlist == $null) {
    $iif($chan,notice,msg) $nick You are not registered with me. Type " $+ %c $+ FC help" for help.
    return
  }
  %regex = /^\d{2}\/\d{2}\/\d{2}\s\d{2}:\d{2}:\d{2}\s( $+ $replace(%svlist,$chr(44),$chr(124)) $+ )/
  while (%records < %amount) {
    %current = $read($dk,r,%regex,%i)
    if ($readn) {
      explainResult $nick %current
      inc %records 1
      %i = $readn + 1
    }
    else {
      msg $nick No $iif(%records > 0,other,) results found for $+(07,$replace(%svlist,$chr(44),$+(,$chr(44),07)),,.)
      halt
    }
  }
}

/*
 * explainResult
 * Messages the given nick an understandable version of the matched record
 * $1: nick
 * $2: record to decode
 */
alias -l explainResult {
  var %text = $2-
  var %time = $gettok(%text,1-2,32), %sv = $gettok(%text,3,32), %type = $gettok(%text,4,32)
  var %svtext = $+($chr(40),07,%sv,,$chr(41))
  if (%type == FC) {
    var %nick = $gettok(%text,5,32), %chan = $gettok(%text,6,32)
    msg $1 %time %svtext %nick used ".FC $+(07,%sv,) $+ " $+($iif(%nick == %chan,in PM,on %chan),.)
  }
  elseif (%type == PASTE) {
    var %nick = $gettok(%text,5,32), %chan = $gettok(%text,6,32), %link = $gettok(%text,7,32)
    msg $1 %time %svtext %nick pasted $+(http://pastebin.com/,%link) $+($iif(%nick == %chan,in PM,on %chan),.)
  }
  elseif (%type == GIVE) {
    var %link = $gettok(%text,5,32)
    msg $1 %time %svtext %link was posted.
  }
  else {
    msg $1 $mnick fucked up, mate. Give him shit for it. % $+ type == %type $+ . % $+ text == %text $+ .
  }
}