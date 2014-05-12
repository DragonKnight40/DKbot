; Type Game (lame title lol)

/*
 * on .On/.Off event
 * Activates/deactivates the Type Game on the current channel
 * Requires at least halfop to use
 */
on $*:TEXT:$($+(/^,$DKtrigger,(On|Off)\b/Si)):#:{
  DKcheck $nick
  var %op = $left($nick($chan,$nick).pnick,1)
  if ($nick != $mnick && %op != $chr(37) && %op != $chr(64) && %op != $chr(38) && %op != $chr(126)) {
    notice $nick Lolno.
    halt
  }
  if ($regml(1) == on && %playtype. [ $+ [ $chan ] ] == 0) {
    set %playtype. [ $+ [ $chan ] ] 1
    msg $chan $nick has activated the Type Game on $chan $+ !
  }
  if ($regml(1) == off && (%playtype. [ $+ [ $chan ] ] == 1 || %playtype. [ $+ [ $chan ] ] == $null)) {
    set %playtype. [ $+ [ $chan ] ] 0
    msg $chan $nick has deactivated the Type Game on $chan $+ !
    unset %type*
  }
}

/*
 * on .Type event
 * Starts the game on the current channel
 */
on $*:TEXT:$($+(/^,$DKtrigger,(Type|Type\sGame|Types)\b/Si)):#:{
  DKcheck $nick
  if ($chan == #smogonwifi) halt
  if (%playtype. [ $+ [ $chan ] ] == 0) {
    msg $chan The Type Game is currently deactivated on $+($chan,!)
    halt
  }
  if (%type) {
    msg $chan A type game is in progress on $+(%typechan,!) $+(Type,$getS($numtok(%type,124)),:) $displayType(%type)
    halt
  }
  set %typechan $chan
  set %type $getType
  set %typeregexanswer $getRegex(%type)
  set %typeamount $rand(1,%typeamount)
  if (%typeamount > 5) {
    set %typeamount $rand(1,5)
  }
  set %typeanswers $null
  msg %typechan Name $+(07,%typeamount,) Pokémon with the following $+(type,$getS($numtok(%type,124)),:) $displayType(%type)
}

/*
 * on %typeregexanswer event
 * Responds to correct answers
 */
on $*:TEXT:%typeregexanswer:%typechan:{
  DKcheck $nick
  if (!%type) {
    unset %type*
    halt
  }
  if (%playtype. [ $+ [ $chan ] ] == 0) {
    halt
  }
  if ($istok(%typeanswers,$regml(1),124)) {
    notice $nick You already have $+($proper($regml(1)),!) Only $+(07,%typeamount,) more to go!
    halt
  }
  %typeanswers = $addtok(%typeanswers,$regml(1),124)
  %typeamount = %typeamount - 1
  inc %type. [ $+ [ $nick ] ] 1
  set %typeusers $addtok(%typeusers,$nick,44)
  var %message = $proper($regml(1)) is correct! $nick now has $+(07,%type. [ $+ [ $nick ] ],) $+(point,$getS(%type. [ $+ [ $nick ] ]),!)
  if (%typeamount > 0) {
    msg %typechan %message Only $+(07,%typeamount,) more to go!
  }
  else {
    var %i = 1, %nick, %max = $gettok(%typeusers,1,44)
    while (%i <= $numtok(%typeusers,44)) {
      %nick = $gettok(%typeusers,%i,44)
      if (%type. [ $+ [ %nick ] ] > %type. [ $+ [ %max ] ]) {
        %max = %nick
      }
      inc %i 1
    }
    msg %typechan %message Congratulations! $+(,%max,) wins with $+(07,%type. [ $+ [ %max ] ],) $+(point,$getS(%type. [ $+ [ %max ] ]),!)
    unset %type*
  }
}

/*
 * displayType
 * $1: Pokémon type
 * $2: (optional) Second Pokémon type
 * Returns: Colorized text for the given type(s)
 */
alias -l displayType {
  tokenize 124 $1
  var %return = $+(,$readini(TypeData.ini,Number,$1),$1,)
  if ($2) {
    %return = %return $+(,$readini(TypeData.ini,Number,$2),$2,)
  }
  return %return
}

/*
 * getRegex
 * $1: Pokémon type
 * $2: (optional) Second Pokémon type
 * Returns: Regular expression string that matches all possible correct answers
 * Note: Also sets %typeamount
 */
alias -l getRegex {
  tokenize 124 $1
  set %typeamount 0
  var %typeregex
  if ($2) {
    %typeregex = /^([^\\]+)\\( $+ $1 $+ \\ $+ $2 $+ $chr(124) $+ $2 $+ \\ $+ $1 $+ )$/i
  }
  else {
    %typeregex = /^([^\\]+)\\( $+ $1 $+ \\.+ $+ $chr(124) $+ .+\\ $+ $1 $+ $chr(124) $+ $1 $+ )$/i
  }
  var %i = 1, %pokemon, %return = /(
  while (%i > -1) {
    %pokemon = $read(TypePokemon.txt,r,%typeregex,%i)
    if (!%pokemon) {
      %i = -1
    }
    else {
      %i = $readn + 1
      inc %typeamount 1
      %return = $+(%return,$regml(1),$chr(124))
    }
  }
  %return = $+($left(%return,-1),$chr(41),/Si)
  return %return
}

/*
 * getType
 * Returns: One or two Pokémon types (separated by a pipe)
 */
alias -l getType {
  var %return, %i
  while ($noTypeCombo(%return)) {
    %i = 0
    %return = $null
    while (%i < 2) {
      %return = $addtok(%return,$readini(TypeData.ini,Type,$rand(1,18)),124)
      inc %i 1
    }
  }
  return %return
}

/*
 * noTypeCombo
 * $1: Pokémon type
 * $2: (optional) Second Pokémon type
 * Returns: Boolean value determining if there exists any Pokémon with the given type combination
 */
alias -l noTypeCombo {
  if (!$1) {
    return $true
  }
  tokenize 124 $1
  var %typeregex
  if (!$2) {
    %typeregex = $+(/^[^\\]+\\,$1,$/i)
  }
  else {
    %typeregex = /^[^\\]+\\( $+ $1 $+ \\ $+ $2 $+ $chr(124) $+ $2 $+ \\ $+ $1 $+ )$/i
  }
  if ($read(TypePokemon.txt,r,%typeregex)) {
    return $false
  }
  return $true
}

/*
 * proper
 * $1: String to convert
 * Returns: $1 in Proper Case
 */
alias -l proper {
  var %return, %token, %i = 1
  while (%i <= $numtok($1,32)) {
    %token = $gettok($1,%i,32)
    %return = %return $+($upper($left(%token,1)),$lower($right(%token,-1)))
    inc %i 1
  }
  return %return
}