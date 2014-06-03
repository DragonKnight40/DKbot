; File for aliases used in more than one file

/*
 * Files
 */
alias main return D:\SVeXDatabase\Main.csv
alias sv return D:\SVeXDatabase\SV.csv
alias dk return D:\SVeXDatabase\DK.log

/*
 * commas
 * $1: The number to convert
 * Returns: $1 with commas inserted at every third digit
 */
alias commas {
  var %return = $1, %i = $len($1) - 3
  while (%i > 0) {
    %return = $+($left(%return,%i),$chr(44),$right(%return,$calc(-1 * %i)))
    dec %i 3
  }
  return %return
}

/*
 * DKcheck
 * Halts execution unless the current user is DKbot
 */
alias DKcheck {
  if ($me != DKbot || $1 == Rhythm || $1 == #smogonwifi) {
    halt
  }
}

/*
 * DKlog
 * Writes the current time as well as the given text to DK.log
 * $1-: The text to write
 */
alias DKlog {
  write $dk $asctime(mm/dd/yy HH:nn:ss) $1-
}

/*
 * DKtrigger
 * Returns: Character set that activates DKbot commands
 */
alias DKtrigger {
  return [.~@]
}

/*
 * getMain
 * $1: Index of record to look up
 * Returns: Main record with the given index
 */
alias getMain {
  var %nick = [^ $+ $chr(44) $+ ]+, %ign = [^ $+ $chr(44) $+ ]+, %fc = \d{4}-\d{4}-\d{4}
  var %regex = $+(/^,$1,$chr(44),%nick,$chr(44),%ign,$chr(44),%fc,$chr(36),/i)
  echo -st %regex
  return $read($main,r,%regex)
}

/*
 * getMainIndex
 * $1: Datum to search for
 * $prop: Type of datum given
 * Returns: Comma-separated list of all indexes with the given datum
 */
alias getMainIndex {
  var %nick = [^ $+ $chr(44) $+ ]+, %ign = [^ $+ $chr(44) $+ ]+, %fc = \d{4}-\d{4}-\d{4}
  if ($prop == nick) %nick = $1
  elseif ($prop == IGN) %ign = $1
  elseif ($prop == FC) %fc = $1
  else return $null
  var %regex = $+(/^\d+,$chr(44),%nick,$chr(44),%ign,$chr(44),%fc,$chr(36),/i)
  echo -st %regex
  var %indexList, %mainRS = $read($main,r,%regex)
  while (%mainRS != $null) {
    %indexList = $addtok(%indexList,$gettok(%mainRS,1,44),44)
    %mainRS = $read($main,r,%regex,$calc($readn + 1))
  }
  return %indexList
}

/*
 * getNicks
 * $1: Comma-separated list of indexes to search for
 * $2: Either "paste" (for %pastefoundindex) or "give" (for %givefoundindex)
 * Returns: List of nicknames and matching SVs (in orange)
 */
alias getNicks {
  var %i = 1, %current, %new, %nick, %sv, %nicks
  while (%i <= $numtok($1,44)) {
    %current = $gettok($1,%i,44)
    %nick = $gettok($getMain(%current),2,44)
    %sv = $gettok(% [ $+ [ $2 ] $+ ] foundsv,%i,44)
    if ($regex(%nicks,$+(/,\b,%nick,\b,/))) {
      var %regex = (\([^\)]+)\)
      %nicks = $regsubex(%nicks,$+(/,%nick,$chr(32),%regex,/),$+(%nick,$chr(32),\1,$chr(44),$chr(32),07,%sv,,$chr(41)))
    }
    else {
      %new = $+(%nick,$chr(32),$chr(40),07,%sv,,$chr(41))
      if (!%nicks) set %nicks %new
      else set %nicks $+(%nicks,$chr(44),$chr(32),%new)
    }
    inc %i 1
  }
  return %nicks
}

/*
 * getS
 * $1: Any number
 * Returns: s if $1 is 1, nothing otherwise
 */
alias getS {
  return $iif($1 != 1,s,)
}

/*
 * getSV
 * $1: Index of record to look up
 * Returns: Comma-separated list of all SV's with the given index
 */
alias getSV {
  var %regex = $+(/^,$1,$chr(44),\d{4},$chr(36),/i)
  echo -st %regex
  var %SVlist, %SVRS = $read($sv,r,%regex)
  while (%SVRS != $null) {
    %SVlist = $addtok(%SVlist,$gettok(%SVRS,2,44),44)
    %SVRS = $read($sv,r,%regex,$calc($readn + 1))
  }
  return %SVlist
}

/*
 * getSVIndex
 * $1: SV to search for
 * Returns: Comma-separated list of all index's with the given SV
 */
alias getSVIndex {
  var %regex = $+(/^\d+,$chr(44),$1,$chr(36),/i)
  echo -st %regex
  var %indexList, %SVRS = $read($sv,r,%regex)
  while (%SVRS != $null) {
    %indexList = $addtok(%indexList,$gettok(%SVRS,1,44),44)
    %SVRS = $read($sv,r,%regex,$calc($readn + 1))
  }
  return %indexList
}

/*
 * isSV
 * $1: String to validate
 * Returns: 1 if $1 is a valid SV, 0 otherwise
 */
alias isSV {
  return $iif($1 isnum 0000-4096 && $int($1) == $1 && !$pos($1,$chr(46)),1,0)
}

/*
 * isSVmulti
 * $1: String to validate
 * Returns: 1 if $1 is a valid string of comma-separated SV's, 0 otherwise
 */
alias isSVmulti {
  if ($isSV($1)) return 1
  var %i = 1
  while (%i <= $numtok($1,44)) {
    if (!$isSV($gettok($1,%i,44))) return 0
    inc %i
  }
  return 1
}

/*
 * validSV
 * $1: String to validate
 * Returns: 1 if $1 is a valid 4-digit SV, 0 otherwise
 */
alias validSV {
  return $iif($isSV($1) && $len($1) == 4,1,0)
}

/*
 * zeroSV
 * $1: SV to convert
 * Returns: $1 with 0's prepended to make it 4 digits wide
 */
alias zeroSV {
  return $right(000 $+ $1,4)
}

/*
 * zeroSVMulti
 * $1: SV list to convert
 * Returns: $1 with 0's prepended to make each SV 4 digits wide
 */
alias zeroSVmulti {
  var %return = $1, %current, %i = 1
  while (%i <= $numtok($1,44)) {
    %current = $gettok($1,%i,44)
    %return = $puttok(%return,$zeroSV(%current),%i,44)
    inc %i
  }
  return %return
}