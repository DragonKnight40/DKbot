; Script to handle FC's, IGN's and SV's

/*
 * on .FC event
 * Determines the type of input and acts accordingly
 */
on $*:TEXT:$($+(/^,$chr(40),$DKtrigger,$chr(41),FC\b/Si)):*:{
  DKcheck $nick
  var %datum, %msg = $iif($chan != $null,msg $chan,msg $nick), %notice = $iif($chan != $null,notice $nick,msg $nick), %c = $regml(1)
  echo -st $+(%c,FC) used by $nick $iif($chan != $null,on $chan,(PM))
  
  if ($2 == help && $3 == $null) {
    %msg Syntax: $+(%c,FC) $chr(124) $+(%c,FC) Nick or IGN or FC or SV $chr(124) $+(%c,FC) IGN FC SV,SV2,SV3 (SV2+ optional)
    return
  }
  
  if ($2 == stats && $3 == $null) {
    %msg Number of registered users: $+(07,$commas($lines($main)),,.)
    %msg Number of registered SVs: $+(07,$commas($lines($sv)),,.)
    %msg Most recent registration: $asctime($file($main).mtime,mm/dd/yy HH:nn:ss) (GMT $+ $asctime($file($main).mtime,z) $+ ).
    return
  }
  
  if ($2 == $null) {
    %datum = $getDatum($nick).nick
    if (%datum) sendMsg $iif($chan != $null,$chan,$nick) %datum
    else %msg No results found for $nick $+ .
  }
  elseif ($2 != $null && $3 == $null) {
    if ($regex($2,/^(delete|del|remove|rem|erase)$/i)) {
      if ($deleteDatum($nick)) %notice Deleted.
      else %notice No results found for $nick $+ .
      return
    }
    if ($isFC($2)) %datum = $getDatum($2).FC
    elseif ($isSV($2)) {
      %datum = $getDatum($zeroSV($2)).SV
      DKlog $zeroSV($2) FC $nick $gettok(%msg,2,32)
    }
    else {
      echo -st nick/IGN
      %datum = $getDatum($2).nick
      if (!%datum) %datum = $getDatum($2).IGN
    }
    if (%datum) sendMsg $iif($chan != $null,$chan,$nick) %datum
    else %msg No results found for $+($iif($isSV($2),$+(07,$2,),$2),.)
  }
  elseif ($3 != $null && $4 == $null) {
    if ($regex($2,/^(delete|del|remove|rem|erase)$/i)) {
      var %op = $left($nick($chan,$nick).pnick,1)
      if ($nick != $mnick && %op != $chr(37) && %op != $chr(64) && %op != $chr(38) && %op != $chr(126)) {
        notice $nick Lolno.
        return
      }
      if ($deleteDatum($3)) %notice Deleted.
      else %notice No results found for $3 $+ .
      return
    }
  }
  elseif ($4 != $null) {
    var %IGN, %FC, %SV
    if ($isFC($2)) {
      %FC = $2
    }
    elseif ($isFC($3)) {
      %FC = $3
    }
    elseif ($isFC($4)) {
      %FC = $4
    }
    else {
      %notice Syntax error. Syntax: $+(%c,FC) $chr(124) $+(%c,FC) Nick or IGN or FC or SV $chr(124) $+(%c,FC) IGN FC SV,SV2,SV3 (SV2+ optional)
      return
    }
    if ($isSVmulti($2) || $2 == none) {
      %SV = $2
    }
    elseif ($isSVmulti($3) || $3 == none) {
      %SV = $3
    }
    elseif ($isSVmulti($4) || $4 == none) {
      %SV = $4
    }
    else {
      %notice Syntax error. Syntax: $+(%c,FC) $chr(124) $+(%c,FC) Nick or IGN or FC or SV $chr(124) $+(%c,FC) IGN FC SV,SV2,SV3 (SV2+ optional)
      return
    }
    if ($2 != %SV && $2 != %FC) {
      %IGN = $2
    }
    elseif ($3 != %SV && $3 != %FC) {
      %IGN = $3
    }
    elseif ($4 != %SV && $4 != %FC) {
      %IGN = $4
    }
    else {
      %notice Syntax error. Syntax: $+(%c,FC) $chr(124) $+(%c,FC) Nick or IGN or FC or SV $chr(124) $+(%c,FC) IGN FC SV,SV2,SV3 (SV2+ optional)
      return
    }
    if ($chr(44) isin %IGN) {
      %notice Syntax error. Syntax: $+(%c,FC) $chr(124) $+(%c,FC) Nick or IGN or FC or SV $chr(124) $+(%c,FC) IGN FC SV,SV2,SV3 (SV2+ optional)
      return
    }
    %SV = $zeroSVmulti(%SV)
    echo -st 1: $1 2: $2 3: $3 4: $4
    echo -st IGN: %IGN FC: %FC SV: %SV
    if ($setDatum($nick,%IGN,%FC,%SV)) %notice Added.
    else %notice Edited.
  }
  else {
    %notice Syntax error. Syntax: $+(%c,FC) $chr(124) $+(%c,FC) Nick or IGN or FC or SV $chr(124) $+(%c,FC) IGN FC SV,SV2,SV3 (SV2+ optional)
  }
}

/*
 * deleteDatum
 * $1: Nick of record to be deleted
 * Returns: 1 if success, 0 if fail
 */
alias -l deleteDatum {
  var %currentLine, %index = $getMainIndex($1).nick, %regex = $+(/^,%index,$chr(44),/i)
  if (%index == $null) return 0
  echo -st %regex
  %currentLine = $read($main,r,%regex)
  write $+(-dl,$readn) $main
  %currentLine = $read($sv,r,%regex)
  while (%currentLine != $null) {
    write $+(-dl,$readn) $sv
    %currentLine = $read($sv,r,%regex,$readn)
  }
  return 1
}

/*
 * getDatum
 * $1: Datum to search for
 * $prop: Type of datum given
 * Returns: Slash-separated list of all records with the given datum
 */
alias -l getDatum {
  var %indexList, %RS, %currentIndex, %i = 1
  if ($prop == SV) %indexList = $getSVIndex($1)
  else %indexList = $getMainIndex($1). [ $+ [ $prop ] ]
  while (%i <= $numtok(%indexList,44)) {
    %currentIndex = $gettok(%indexList,%i,44)
    %RS = $addtok(%RS,$+($getMain(%currentIndex),$chr(44),$getSV(%currentIndex)),47)
    inc %i
  }
  return %RS
}

/*
 * isFC
 * $1: String to validate
 * Returns: 1 if $1 is a valid FC, 0 otherwise
 */
alias -l isFC {
  return $regex($1,/^\d{4}-\d{4}-\d{4}$/)
}

/*
 * nextIndex
 * Returns and increases the global variable %nextIndex
 * Returns: Global variable %nextIndex
 */
alias -l nextIndex {
  var %return = %nextIndex
  inc %nextIndex
  return %return
}

/*
 * sendMsg
 * $1: Channel or nick to message
 * $2: Slash-separated list of all records to display
 */
alias -l sendMsg {
  var %current, %i = 1
  while (%i <= $numtok($2,47)) {
    %current = $gettok($2,%i,47)
    msg $1 Nick: $gettok(%current,2,44) $chr(124) IGN: $gettok(%current,3,44) $chr(124) FC: $gettok(%current,4,44) $iif($gettok(%current,5-,44) == $null,,$chr(124) SV: $+(07,$replace($gettok(%current,5-,44),$chr(44),$+(,$chr(44),07)),))
    inc %i
  }
}

/*
 * setDatum
 * $1: nick
 * $2: IGN
 * $3: FC
 * $4: Comma-separated list of SV's
 * Returns: 1 if brand new record, 0 if updated record
 */
alias -l setDatum {
  var %new = 0, %i = 1, %index = $getMainIndex($1).nick
  if (%index == $null) {
    %new = 1
    %index = $nextIndex
  }
  else $deleteDatum($1)
  write $main $+(%index,$chr(44),$1,$chr(44),$2,$chr(44),$3)
  while ($4 != none && %i <= $numtok($4,44)) {
    write $sv $+(%index,$chr(44),$zeroSV($gettok($4,%i,44)))
    inc %i
  }
  return %new
}