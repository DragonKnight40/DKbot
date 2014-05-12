;#########################################################################################
;## Pokémon Gen IV Battle Simulator, IRC Style                                          ##
;## Made entirely by DragonKnight                                                       ##
;## !Battle <nick (case sensitive)> will challenge nick to a battle.                    ##
;## !Run is the equivilent of pressing the "Run" button in a wifi battle; you forfeit.  ##
;## For your team saving to work, edit the proceding alias.                             ##
;## Change the directory so that you can save teams on your computer.                   ##
;## All file storing in this script uses this alias.                                    ##
;#########################################################################################

;http://www.mediafire.com/?qm6600l64jlrn3r

alias -l teams return C:\Users\stmor_000\AppData\Roaming\mIRC\Teams.ini

alias -l mesg {
  if ( %timeramount == $null ) set %timeramount 0
  .timerkilltimer off
  .timerkilltimer 1 2 unset %timeramount
  .timer 1 %timeramount $iif($left($1,1) == $chr(35),msg,notice) $1 $2-
  inc %timeramount 2
}
alias -l mesgq {
  if ( %timeramount == $null ) set %timeramount 0
  .timerkilltimer off
  .timerkilltimer 1 2 unset %timeramount
  .timer 1 %timeramount msg $1 $2-
  inc %timeramount 2
}

alias links {
  say Pokémon editor: 5http://pastebin.com/n0TvnBf8
  say Manual tutorial: 4http://www.smogon.com/forums/showthread.php?t=82709
  say Battle client: 12http://pastebin.com/ykQpwH0x
}

alias EndBattle {
  var %count = 1
  while ( %count <= $scon(0) ) {
    scon %count
    if ( ( $me == DKbot ) && ( *.purplesurge.com iswm $server ) ) msg %chan The battle has been manually ended.
    inc %count 1
  }
  UnsetVars
  halt
}

on *:MODE:%chan:if ( ($me == DKBot) && ( %battle ) && ( c isincs $1- ) || ( S isincs $1- ) ) mode %chan -cS

on *:TEXT:*:#:{
  if ($me != DKBot) halt
  var %text = $strip($1-)
  var %nick2 = $gettok(%text,2,32)
  if ( ( $regex($gettok(%text,1,32),/^[!.](Quit|Flee|Run)$/i) ) && ( %battle ) && ( $nick == %plr1 || $nick == %plr2 ) ) {
    mesg %chan $nick has dropped out of the battle.
    if ( $nick == %plr1 ) mesg %chan %plr2 wins! Score: $Score(%plr2)
    if ( $nick == %plr2 ) mesg %chan %plr1 wins! Score: $Score(%plr1)
    UnsetVars
    halt
  }
  if ( $regex($gettok(%text,1,32),/^[!.](Battle|Challenge)$/i) ) {
    if ( %nick2 == $null ) {
      mesg $nick You must specify a person to battle.
      halt
    }
    if ( %battle ) {
      mesg $nick Sorry, but another battle is currently taking place. Try again later.
      halt
    }
    if ( %nick2 == $me ) {
      mesg $nick You cannot battle me.
      halt
    }
    if ( $nick == %nick2 ) {
      mesg $nick You cannot battle yourself.
      halt
    }
    var %count = 1
    var %legalnick = $false
    while ( %count <= $nick($chan,0) ) {
      if ( $nick($chan,%count) === %nick2 ) var %legalnick = $true
      inc %count 1
    }
    if ( !%legalnick ) {
      mesg $nick You cannot battle %nick2 $+ ; He/She is not on the channel.
      halt
    }
    if ( !$team($nick) ) {
      mesg $nick You cannot challenge anyone; You do not have any teams.
      halt
    }
    if ( !$team(%nick2) ) {
      mesg $nick You cannot battle %nick2 $+ ; He/She does not have any teams.
      halt
    }
    set %plr1 $nick
    set %plr2 %nick2
    set %battle 1
    set %chan $iif($gettok(%text,3,32),$gettok(%text,3,32),$chan)
    mesg %plr1 You have challenged %plr2 to a battle. Waiting for a reply.....
    .timerchallenge 1 60 ChallengeTimeout
    mesg %plr2 %plr1 has challenged you to a battle on %chan $+ . Type /msg $me accept/decline to accept or decline this challenge.
    set %challenge. [ $+ [ %plr2 ] ] 1
  }
}
on *:PART:%chan:{
  if ($me != DKBot) halt
  if ( ( $nick == %plr1 ) || ( $nick == %plr2 ) ) {
    mesg %chan $nick has dropped out of the battle.
    if ( $nick == %plr1 ) mesg %chan %plr2 wins! Score: $Score(%plr2)
    if ( $nick == %plr2 ) mesg %chan %plr1 wins! Score: $Score(%plr1)
    UnsetVars
    halt
  }
}
on *:QUIT:{
  if ($me != DKBot) halt
  if ( ( $nick == %plr1 ) || ( $nick == %plr2 ) ) {
    mesg %chan $nick has dropped out of the battle.
    if ( $nick == %plr1 ) mesg %chan %plr2 wins! Score: $Score(%plr2)
    if ( $nick == %plr2 ) mesg %chan %plr1 wins! Score: $Score(%plr1)
    UnsetVars
    halt
  }
}
on *:NICK:{
  if ($me != DKBot) halt
  if ( ( $newnick == %plr1 ) || ( $newnick == %plr2 ) ) {
    .timerdisqualify off
    mesg $newnick Thank you for changing your nick back.
    mesg $newnick You battle will now resume.
  }
  if ( ( $nick == %plr1 ) || ( $nick == %plr2 ) ) {
    if ( $nick == %plr1 ) {
      mesg $newnick  $+ $newnick $+  $+ , please change your nick back to %plr1 if you wish to continue your battle.
      .timerdisqualify 1 30 Disqualify %plr1
    }
    if ( $nick == %plr2 ) {
      mesg $newnick  $+ $newnick $+  $+ , please change your nick back to %plr2 if you wish to continue your battle.
      .timerdisqualify 1 30 Disqualify %plr2
    }
    mesg $newnick Failure to do so will result in automatic disqualification.
  }
}
alias -l Disqualify {
  var %nick = $1
  mesg %chan %nick has been disqualified from his/her battle.
  if ( %nick == %plr1 ) var %plr = %plr2
  if ( %nick == %plr2 ) var %plr = %plr1
  mesg %chan %plr wins! Score: $Score(%plr)
  UnsetVars
  halt
}
on *:KICK:%chan:{
  if ($me != DKBot) halt
  if ( ( $knick == %plr1 ) || ( $knick == %plr2 ) ) {
    invite $knick %chan
    mesg %chan 4Please do not kick the active trainers.
  }
}
alias -l ChallengeTimeout {
  unset %challenge. [ $+ [ %plr2 ] ]
  mesg %plr1 Your challenge to %plr2 has timed out.
  mesg %plr2 The challenge from %plr1 has timed out.
  unset %plr1
  unset %plr2
  unset %chan
  unset %battle
}
on *:TEXT:accept:?:{
  if ($me != DKBot) halt
  if ( %challenge. [ $+ [ $nick ] ] ) {
    .timerchallenge off
    unset %challenge. [ $+ [ $nick ] ]
    mesg %plr2 You have accepted %plr1 $+ 's challenge.
    if ($me !ison %chan) join %chan
    if ($nick !ison %chan) invite $nick %chan
    mesg %plr1 %plr2 has accepted your challenge.
    ;mode %chan -cS
    mesg %chan Current battle:  $+ %plr1 $+  vs.  $+ %plr2 $+ 
    mesg %chan Waiting for both trainers to choose their Pokémon.....
    mesg %plr1 %plr1 $+ , choose one of your Pokémon teams to use by typing /msg $me choose (Team Name).
    mesg %plr1 Your teams: $team(%plr1)
    mesg %plr1 Example: /msg $me choose Universal
    set %choose. [ $+ [ %plr1 ] ] 1
    mesg %plr2 %plr2 $+ , choose one of your Pokémon teams to use by typing /msg $me choose (Team Name).
    mesg %plr2 Your teams: $team(%plr2)
    mesg %plr2 Example: /msg $me choose Universal
    set %choose. [ $+ [ %plr2 ] ] 1
  }
}
alias -l team {
  var %plr = $1
  var %teams = $read($teams,w,[ $+ %plr $+ _*])
  while ( $read($teams,w,[ $+ %plr $+ _*],$calc( $readn + 1 )) != $null ) var %teams = $addtok(%teams,$v1,32)
  var %teams = $remove(%teams,$+($chr(91),%plr,$chr(95)),$chr(93))
  return $addtok(%teams,Universal,32)
}
on *:TEXT:decline:?:{
  if ($me != DKBot) halt
  if ( %challenge. [ $+ [ $nick ] ] ) {
    .timerchallenge off
    unset %challenge. [ $+ [ $nick ] ]
    mesg %plr2 You have declined %plr1 $+ 's challenge.
    mesg %plr1 %plr2 has declined your challenge.
    unset %plr1
    unset %plr2
    unset %chan
    unset %battle
  }
}
on *:TEXT:choose *:?:{
  if ($me != DKBot) halt
  if ( %choose. [ $+ [ $nick ] ] ) {
    set %team. [ $+ [ $nick ] ] $2
    if ( $readini($teams,$iif($2 == Universal,$2,$+($nick,$chr(95),$2)),Pokemon6) != $null ) {
      unset %choose. [ $+ [ $nick ] ]
      mesg $nick You have chosen  $+ $2 $+  as the team to use.
      mesg $nick Waiting for the opponent to decide.....
      set %ready. [ $+ [ $nick ] ] 1
      if ( ( %ready. [ $+ [ %plr1 ] ] ) && ( %ready. [ $+ [ %plr2 ] ] ) ) {
        unset %ready.*
        var %teamplr1 = $GetTeamName(%plr1)
        var %teamplr2 = $GetTeamName(%plr2)
        var %pokesplr1 = $readini($teams,%teamplr1,Pokemon1) $readini($teams,%teamplr1,Pokemon2) $readini($teams,%teamplr1,Pokemon3) $readini($teams,%teamplr1,Pokemon4) $readini($teams,%teamplr1,Pokemon5) $readini($teams,%teamplr1,Pokemon6)
        var %pokesplr2 = $readini($teams,%teamplr2,Pokemon1) $readini($teams,%teamplr2,Pokemon2) $readini($teams,%teamplr2,Pokemon3) $readini($teams,%teamplr2,Pokemon4) $readini($teams,%teamplr2,Pokemon5) $readini($teams,%teamplr2,Pokemon6)
        
        mesg %plr1 Choose the order of your team. Do so by typing /msg $me order (Pokémon 1) (Pokémon 2) (Pokémon 3) (Pokémon 4) (Pokémon 5) (Pokémon 6)
        mesg %plr1 Your team: %pokesplr1 $+ . Your opponent's team: %pokesplr2
        mesg %plr2 Choose the order of your team. Do so by typing /msg $me order (Pokémon 1) (Pokémon 2) (Pokémon 3) (Pokémon 4) (Pokémon 5) (Pokémon 6)
        mesg %plr2 Your team: %pokesplr2 $+ . Your opponent's team: %pokesplr1
        set %order. [ $+ [ %plr1 ] ] 1
        set %order. [ $+ [ %plr2 ] ] 1
      }
    }
    else {
      mesg $nick Unknown team  $+ $2 $+ .
      unset %team. [ $+ [ $nick ] ]
    }
  }
}
on *:TEXT:order *:?:{
  if ($me != DKBot) halt
  if ( %order. [ $+ [ $nick ] ] ) {
    var %pokeorder. [ $+ [ $nick ] ] $2-
    var %realpokes = $readini($teams,$GetTeamName($nick),Pokemon1) $readini($teams,$GetTeamName($nick),Pokemon2) $readini($teams,$GetTeamName($nick),Pokemon3) $readini($teams,$GetTeamName($nick),Pokemon4) $readini($teams,$GetTeamName($nick),Pokemon5) $readini($teams,$GetTeamName($nick),Pokemon6)
    if ( ( $numtok(%pokeorder. [ $+ [ $nick ] ],32) != 6 ) || ( $sorttok(%pokeorder. [ $+ [ $nick ] ],32) != $sorttok(%realpokes,32) ) ) mesg $nick One or more of the Pokémon you specified is not on your team  $+ %team. [ $+ [ $nick ] ] $+ . Your team: %realpokes
    else {
      unset %order. [ $+ [ $nick ] ]
      var %count = 1
      while ( %count < 7 ) {
        var %count2 = 1
        while ( %count2 < 7 ) {
          if ( $gettok(%pokeorder. [ $+ [ $nick ] ],%count,32) == $gettok(%realpokes,%count2,32) ) set %slotorder. [ $+ [ $nick ] ] %slotorder. [ $+ [ $nick ] ] %count2
          inc %count2 1
        }
        inc %count 1
      }
      set %slot. [ $+ [ $nick ] ] $gettok(%slotorder. [ $+ [ $nick ] ],1,32)
      set %curHP. [ $+ [ $nick ] ] -1 -1 -1 -1 -1 -1
      SetPoke $nick
      mesg $nick You have chosen the order of your team to use in battle.
      mesg $nick Waiting for the opponent to decide.....
      set %ready. [ $+ [ $nick ] ] 1
      if ( ( %ready. [ $+ [ %plr1 ] ] ) && ( %ready. [ $+ [ %plr2 ] ] ) ) {
        unset %ready.*
        mesg %chan Both trainers have chosen their Pokémon team. Let the battle commence!
        set %turns 1
        if ( %ability. [ $+ [ %plr1 ] ] == Illusion ) set %Illusion. [ $+ [ %plr1 ] ] 1
        if ( %ability. [ $+ [ %plr2 ] ] == Illusion ) set %Illusion. [ $+ [ %plr2 ] ] 1
        mesg %chan %plr1 sent out $TypeColor(%plr1).real $+ !
        mesg %chan %plr2 sent out $TypeColor(%plr2).real $+ !
        if ( %ability. [ $+ [ %plr1 ] ] == Intimidate && %ability. [ $+ [ %plr2 ] ] != Clear Body ) {
          BoostStat %plr2 Atk -1
        }
        if ( %ability. [ $+ [ %plr2 ] ] == Intimidate && %ability. [ $+ [ %plr1 ] ] != Clear Body ) {
          BoostStat %plr1 Atk -1
        }
        ;Insert auto-weather here
        if ( %item. [ $+ [ %plr1 ] ] == Air Balloon ) mesg %chan %plr1 $+ 's $TypeColor(%plr1) is floating on its Air Balloon!
        if ( %item. [ $+ [ %plr2 ] ] == Air Balloon ) mesg %chan %plr2 $+ 's $TypeColor(%plr2) is floating on its Air Balloon!
        StartBattle
      }
    }
  }
}
alias -l GetTeamName {
  if (%team. [ $+ [ $1 ] ] == Universal) return $v2
  else return $+($1,$chr(95),%team. [ $+ [ $1 ] ])
}
alias -l SetPoke {
  var %plr = $1
  set %poke. [ $+ [ %plr ] ] $readini($teams,$GetTeamName(%plr),$+(Pokemon,%slot. [ $+ [ %plr ] ]))
  set %item. [ $+ [ %plr ] ] $iif(%newitem. [ $+ [ %plr ] $+ [ %slot. [ $+ [ %plr ] ] ] ] != $null,%newitem. [ $+ [ %plr ] $+ [ %slot. [ $+ [ %plr ] ] ] ],$readini($teams,$GetTeamName(%plr),$+(Item,%slot. [ $+ [ %plr ] ])))
  if ( %itemused. [ $+ [ %plr ] $+ [ %slot. [ $+ [ %plr ] ] ] ] ) unset %item. [ $+ [ %plr ] ]
  set %ability. [ $+ [ %plr ] ] $readini($teams,$GetTeamName(%plr),$+(Ability,%slot. [ $+ [ %plr ] ]))
  set %types. [ $+ [ %plr ] ] $readini($teams,$GetTeamName(%plr),$+(Type,%slot. [ $+ [ %plr ] ]))
  set %tier. [ $+ [ %plr ] ] $readini($teams,$GetTeamName(%plr),$+(Tier,%slot. [ $+ [ %plr ] ]))
  set %moves. [ $+ [ %plr ] ] $readini($teams,$GetTeamName(%plr),$+(Moves,%slot. [ $+ [ %plr ] ]))
  set %nature. [ $+ [ %plr ] ] $readini($teams,$GetTeamName(%plr),$+(Nature,%slot. [ $+ [ %plr ] ]))
  set %IVs. [ $+ [ %plr ] ] $readini($teams,$GetTeamName(%plr),$+(IVs,%slot. [ $+ [ %plr ] ]))
  set %EVs. [ $+ [ %plr ] ] $readini($teams,$GetTeamName(%plr),$+(EVs,%slot. [ $+ [ %plr ] ]))
  set %BaseStats. [ $+ [ %plr ] ] $readini($teams,$GetTeamName(%plr),$+(BaseStats,%slot. [ $+ [ %plr ] ]))
  set %nick. [ $+ [ %plr ] ] $readini($teams,$GetTeamName(%plr),$+(Nickname,%slot. [ $+ [ %plr ] ]))
  var %a = $calc( 2 * $gettok(%BaseStats. [ $+ [ %plr ] ],1,32) )
  var %b = $calc( $gettok(%EVs. [ $+ [ %plr ] ],1,32) / 4 )
  var %c = $calc( $gettok(%IVs. [ $+ [ %plr ] ],1,32) + %a + %b + 100 )
  var %d = $calc( %c + 10 )
  set %stat. [ $+ [ %plr ] ] $floor(%d)
  if ( $gettok(%curHP. [ $+ [ %plr ] ],%slot. [ $+ [ %plr ] ],32) == -1 ) set %curHP. [ $+ [ %plr ] ] $puttok(%curHP. [ $+ [ %plr ] ],$floor(%d),%slot. [ $+ [ %plr ] ],32)
  var %count = 2
  while ( %count < 7 ) {
    var %a = $calc( 2 * $gettok(%BaseStats. [ $+ [ %plr ] ],%count,32) )
    var %b = $calc( $gettok(%EVs. [ $+ [ %plr ] ],%count,32) / 4 )
    var %c = $calc( $gettok(%IVs. [ $+ [ %plr ] ],%count,32) + %a + %b )
    var %d = $calc( %c + 5 )
    var %e = $floor(%d)
    var %f = $gettok($Nature(%nature. [ $+ [ %plr ] ]),%count,32)
    var %g = $calc( %e * %f )
    set %stat. [ $+ [ %plr ] ] %stat. [ $+ [ %plr ] ] $floor(%g)
    inc %count 1
  }
}
alias -l Score {
  var %plr = $1
  if ( %plr == %plr1 ) var %opponent = %plr2
  if ( %plr == %plr2 ) var %opponent = %plr1
  var %score1 = $calc( 6 - $numtok(%fainted. [ $+ [ %plr ] ],32) )
  var %score2 = $calc( 6 - $numtok(%fainted. [ $+ [ %opponent ] ],32) )
  return $+(%score1,$chr(45),%score2)
}
alias -l StartBattle {
  if ( ( %dead. [ $+ [ %plr1 ] ] ) && ( %dead. [ $+ [ %plr2 ] ] ) ) {
    unset %dead.*
    if ( ( $numtok(%fainted. [ $+ [ %plr1 ] ],32) == 6 ) && ( $numtok(%fainted. [ $+ [ %plr2 ] ],32) == 6 ) ) {
      mesg %chan 'Tis a draw! Score: $Score(%plr1)
      UnsetVars
      halt
    }
    elseif ( $numtok(%fainted. [ $+ [ %plr1 ] ],32) == 6 ) {
      mesg %chan %plr2 wins! Score: $Score(%plr2)
      UnsetVars
      halt
    }
    elseif ( $numtok(%fainted. [ $+ [ %plr2 ] ],32) == 6 ) {
      mesg %chan %plr1 wins! Score: $Score(%plr1)
      UnsetVars
      halt
    }
    else {
      set %bothdead 1
      mesg %plr1 Choose a Pokémon to switch in. Do so by typing /msg $me switch (Pokémon).
      var %count = 1
      while ( %count <= 6 ) {
        if ( !$istok(%fainted. [ $+ [ %plr1 ] ],$gettok(%slotorder. [ $+ [ %plr1 ] ],%count,32),32) ) var %alive1 = %alive1 $readini($teams,$GetTeamName(%plr1),$+(Pokemon,$gettok(%slotorder. [ $+ [ %plr1 ] ],%count,32)))
        inc %count 1
      }
      mesg %plr1 Your non-fainted Pokémon: %alive1
      set %gox. [ $+ [ %plr1 ] ] 1
      mesg %plr2 Choose a Pokémon to switch in. Do so by typing /msg $me switch (Pokémon).
      var %count = 1
      while ( %count <= 6 ) {
        if ( !$istok(%fainted. [ $+ [ %plr2 ] ],$gettok(%slotorder. [ $+ [ %plr2 ] ],%count,32),32) ) var %alive2 = %alive2 $readini($teams,$GetTeamName(%plr2),$+(Pokemon,$gettok(%slotorder. [ $+ [ %plr2 ] ],%count,32)))
        inc %count 1
      }
      mesg %plr2 Your non-fainted Pokémon: %alive2
      set %gox. [ $+ [ %plr2 ] ] 1
      halt
    }
  }
  else {
    if ( %dead. [ $+ [ %plr1 ] ] ) {
      unset %dead. [ $+ [ %plr1 ] ]
      if ( $numtok(%fainted. [ $+ [ %plr1 ] ],32) == 6 ) {
        mesg %chan %plr2 wins! Score: $Score(%plr2)
        UnsetVars
        halt
      }
      mesg %plr1 Choose a Pokémon to switch in. Do so by typing /msg $me switch (Pokémon).
      var %count = 1
      while ( %count <= 6 ) {
        if ( !$istok(%fainted. [ $+ [ %plr1 ] ],$gettok(%slotorder. [ $+ [ %plr1 ] ],%count,32),32) ) var %alive1 = %alive1 $readini($teams,$GetTeamName(%plr1),$+(Pokemon,$gettok(%slotorder. [ $+ [ %plr1 ] ],%count,32)))
        inc %count 1
      }
      mesg %plr1 Your non-fainted Pokémon: %alive1
      set %gox. [ $+ [ %plr1 ] ] 1
      if ( !%dead. [ $+ [ %plr2 ] ] ) halt
    }
    if ( %dead. [ $+ [ %plr2 ] ] ) {
      unset %dead. [ $+ [ %plr2 ] ]
      if ( $numtok(%fainted. [ $+ [ %plr2 ] ],32) == 6 ) {
        mesg %chan %plr1 wins! Score: $Score(%plr1)
        UnsetVars
        halt
      }
      mesg %plr2 Choose a Pokémon to switch in. Do so by typing /msg $me switch (Pokémon).
      var %count = 1
      while ( %count <= 6 ) {
        if ( !$istok(%fainted. [ $+ [ %plr2 ] ],$gettok(%slotorder. [ $+ [ %plr2 ] ],%count,32),32) ) var %alive2 = %alive2 $readini($teams,$GetTeamName(%plr2),$+(Pokemon,$gettok(%slotorder. [ $+ [ %plr2 ] ],%count,32)))
        inc %count 1
      }
      mesg %plr2 Your non-fainted Pokémon: %alive2
      set %gox. [ $+ [ %plr2 ] ] 1
      halt
    }
  }
  mesg %plr1 Choose a move to use or a Pokémon to switch in. Do so by typing /msg $me use (Move) or /msg $me switch (Pokémon), respectively.
  var %count = 1
  while ( %count <= 6 ) {
    if ( ( !$istok(%fainted. [ $+ [ %plr1 ] ],$gettok(%slotorder. [ $+ [ %plr1 ] ],%count,32),32) ) && ( $readini($teams,$GetTeamName(%plr1),$+(Pokemon,$gettok(%slotorder. [ $+ [ %plr1 ] ],%count,32))) != %poke. [ $+ [ %plr1 ] ] ) ) var %alive1 = %alive1 $readini($teams,$GetTeamName(%plr1),$+(Pokemon,$gettok(%slotorder. [ $+ [ %plr1 ] ],%count,32)))
    inc %count 1
  }
  mesg %plr1 Your moves: $replace(%moves. [ $+ [ %plr1 ] ],$chr(46),$+($chr(44),$chr(32))) $+ . Your non-fainted Pokémon: %alive1
  set %go. [ $+ [ %plr1 ] ] 1
  mesg %plr2 Choose a move to use or a Pokémon to switch in. Do so by typing /msg $me use (Move) or /msg $me switch (Pokémon), respectively.
  var %count = 1
  while ( %count <= 6 ) {
    if ( ( !$istok(%fainted. [ $+ [ %plr2 ] ],$gettok(%slotorder. [ $+ [ %plr2 ] ],%count,32),32) ) && ( $readini($teams,$GetTeamName(%plr2),$+(Pokemon,$gettok(%slotorder. [ $+ [ %plr2 ] ],%count,32))) != %poke. [ $+ [ %plr2 ] ] ) ) var %alive2 = %alive2 $readini($teams,$GetTeamName(%plr2),$+(Pokemon,$gettok(%slotorder. [ $+ [ %plr2 ] ],%count,32)))
    inc %count 1
  }
  mesg %plr2 Your moves: $replace(%moves. [ $+ [ %plr2 ] ],$chr(46),$+($chr(44),$chr(32))) $+ . Your non-fainted Pokémon: %alive2
  set %go. [ $+ [ %plr2 ] ] 1
}
on *:TEXT:use *:?:{
  if ($me != DKBot) halt
  if ( %go. [ $+ [ $nick ] ] ) {
    set %move. [ $+ [ $nick ] ] $proper($2-)
    if ( !$istok(%moves. [ $+ [ $nick ] ],%move. [ $+ [ $nick ] ],46) ) {
      mesg $nick Your %poke. [ $+ [ $nick ] ] does not know  $+ %move. [ $+ [ $nick ] ] $+ .
      unset %move. [ $+ [ $nick ] ]
      halt
    }
    if ( ( $gettok($Move(%move. [ $+ [ $nick ] ]),2,32) == Status ) && ( $istok(%status. [ $+ [ $nick ] $+ [ %slot. [ $+ [ $nick ] ] ] ],Taunt,32) ) ) {
      mesg $nick You cannot use %move. [ $+ [ $nick ] ] $+ ; You are Taunted.
      unset %move. [ $+ [ $nick ] ]
      halt
    }
    if ( ( %lockmove. [ $+ [ $nick ] ] != $null ) && ( %move. [ $+ [ $nick ] ] != %lockmove. [ $+ [ $nick ] ] ) ) {
      mesg $nick You cannot use  $+ %move. [ $+ [ $nick ] ] $+ ; Your %item. [ $+ [ $nick ] ] only allows the use of %lockmove. [ $+ [ $nick ] ] $+ .
      unset %move. [ $+ [ $nick ] ]
      halt
    }
    if (%Rampage. [ $+ [ $nick ] ] > 0 && %move. [ $+ [ $nick ] ] != %RampageMove. [ $+ [ $nick ] ]) {
      mesg $nick You cannot use  $+ %move. [ $+ [ $nick ] ] $+ ; You are locked into %RampageMove. [ $+ [ $nick ] ] $+ .
      unset %move. [ $+ [ $nick ] ]
      halt
    }
    mesg $nick You have chosen  $+ %move. [ $+ [ $nick ] ] $+  as the move to use.
    mesg $nick Waiting for the opponent to decide.....
    unset %go. [ $+ [ $nick ] ]
    set %ready. [ $+ [ $nick ] ] 1
    .timer $+ $nick off
    if ( ( %ready. [ $+ [ %plr1 ] ] ) && ( %ready. [ $+ [ %plr2 ] ] ) ) {
      unset %ready.*
      UseMoves
    }
  }
}
on *:TEXT:switch *:?:{
  if ($me != DKBot) halt
  if ( %goz. [ $+ [ $nick ] ] ) {
    set %switchpoke. [ $+ [ $nick ] ] $proper($2)
    var %legalswitch = $false
    var %count = 1
    while ( %count <= 6 ) {
      if ( ( $readini($teams,$GetTeamName($nick),$+(Pokemon,%count)) == %switchpoke. [ $+ [ $nick ] ] ) && $&
        ( $readini($teams,$GetTeamName($nick),$+(Pokemon,%count)) != %poke. [ $+ [ $nick ] ] ) ) {
        var %legalswitch = $true
        set %newslot. [ $+ [ $nick ] ] %count
      }
      inc %count 1
    }
    if ( !%legalswitch ) {
      mesg $nick Illegal switch  $+ %switchpoke. [ $+ [ $nick ] ] $+ .
      unset %switchpoke. [ $+ [ $nick ] ]
      halt
    }
    if ( $istok(%fainted. [ $+ [ $nick ] ],%newslot. [ $+ [ $nick ] ],32) ) {
      mesg $nick %switchpoke. [ $+ [ $nick ] ] has fainted; You may not switch it in.
      unset %switchpoke. [ $+ [ $nick ] ]
      unset %newslot. [ $+ [ $nick ] ]
    }
    set %slot. [ $+ [ $nick ] ] %newslot. [ $+ [ $nick ] ]
    unset %newslot. [ $+ [ $nick ] ]
    SetPoke $nick
    unset %switchpoke. [ $+ [ $nick ] ]
    unset %goz. [ $+ [ $nick ] ]
    if ( $nick == %plr1 ) var %opponent = %plr2
    if ( $nick == %plr2 ) var %opponent = %plr1
    mesg %chan $nick sent out $TypeColor($nick).real $+ !
    if ( %ability. [ $+ [ $nick ] ] == Intimidate && %ability. [ $+ [ %opponent ] ] != Clear Body ) {
      BoostStat %opponent Atk -1
    }
    SwitchEffects $nick
    if ( $gettok(%curHP. [ $+ [ %opponent ] ],%slot. [ $+ [ %opponent ] ],32) < 1 ) {
      set %dead. [ $+ [ %opponent ] ] 1
      set %fainted. [ $+ [ %opponent ] ] $addtok(%fainted. [ $+ [ %opponent ] ],%slot. [ $+ [ %opponent ] ],32)
      mesg %chan %opponent $+ 's $TypeColor(%opponent) fainted! Score: $Score($nick)
    }
    if ( %faster == %opponent ) {
      WeatherMsg
      if ( !%dead. [ $+ [ %opponent ] ] ) EndOfTurn %opponent $nick
      if ( !%dead. [ $+ [ $nick ] ] ) EndOfTurn $nick %opponent
    }
    else {
      if ( !%dead. [ $+ [ %opponent ] ] ) Attack %opponent $nick
      WeatherMsg
      if ( !%dead. [ $+ [ $nick ] ] ) EndOfTurn $nick %opponent
      if ( !%dead. [ $+ [ %opponent ] ] ) EndOfTurn %opponent $nick
    }
    StartBattle
  }
  elseif ( %gox. [ $+ [ $nick ] ] ) {
    set %switchpoke. [ $+ [ $nick ] ] $proper($2)
    var %legalswitch = $false
    var %count = 1
    while ( %count <= 6 ) {
      if ( ( $readini($teams,$GetTeamName($nick),$+(Pokemon,%count)) == %switchpoke. [ $+ [ $nick ] ] ) && $&
        ( $readini($teams,$GetTeamName($nick),$+(Pokemon,%count)) != %poke. [ $+ [ $nick ] ] ) ) {
        var %legalswitch = $true
        set %newslot. [ $+ [ $nick ] ] %count
      }
      inc %count 1
    }
    if ( !%legalswitch ) {
      mesg $nick Illegal switch  $+ %switchpoke. [ $+ [ $nick ] ] $+ .
      unset %switchpoke. [ $+ [ $nick ] ]
      halt
    }
    if ( $istok(%fainted. [ $+ [ $nick ] ],%newslot. [ $+ [ $nick ] ],32) ) {
      mesg $nick %switchpoke. [ $+ [ $nick ] ] has fainted; You may not switch it in.
      unset %switchpoke. [ $+ [ $nick ] ]
      unset %newslot. [ $+ [ $nick ] ]
    }
    GetStatus -l Confuse $nick
    unset %durationConfuse. [ $+ [ $nick ] ]
    GetStatus -l Taunt $nick
    unset %durationTaunt. [ $+ [ $nick ] ]
    if ( %ability. [ $+ [ $nick ] ] == Natural Cure ) {
      unset %status. [ $+ [ $nick ] $+ [ %slot. [ $+ [ $nick ] ] ] ]
      unset %durationToxic. [ $+ [ $nick ] $+ [ %slot. [ $+ [ $nick ] ] ] ]
    }
    unset %FlashFireBoost. [ $+ [ $nick ] ]
    unset %Seed. [ $+ [ $nick ] ]
    if ( %durationToxic. [ $+ [ $nick ] $+ [ %slot. [ $+ [ $nick ] ] ] ] != $null ) set %durationToxic. [ $+ [ $nick ] $+ [ %slot. [ $+ [ $nick ] ] ] ] 1
    unset %Atk. [ $+ [ $nick ] ]
    unset %Def. [ $+ [ $nick ] ]
    unset %SpA. [ $+ [ $nick ] ]
    unset %SpD. [ $+ [ $nick ] ]
    unset %Spe. [ $+ [ $nick ] ]
    set %slot. [ $+ [ $nick ] ] %newslot. [ $+ [ $nick ] ]
    unset %newslot. [ $+ [ $nick ] ]
    SetPoke $nick
    unset %switchpoke. [ $+ [ $nick ] ]
    unset %gox. [ $+ [ $nick ] ]
    if ( %bothdead ) {
      mesg $nick You have chosen  $+ %poke. [ $+ [ $nick ] ] $+  as the Pokémon to switch to.
      mesg $nick Waiting for the opponent to decide.....
      set %ready. [ $+ [ $nick ] ] 1
      if ( ( %ready. [ $+ [ %plr1 ] ] ) && ( %ready. [ $+ [ %plr2 ] ] ) ) {
        unset %bothdead
        unset %ready.*
        mesg %chan %plr1 sent out $TypeColor(%plr1).real $+ !
        SwitchEffects %plr1
        mesg %chan %plr2 sent out $TypeColor(%plr2).real $+ !
        SwitchEffects %plr2
        if ( %ability. [ $+ [ %plr1 ] ] == Intimidate && %ability. [ $+ [ %plr2 ] ] != Clear Body ) {
          BoostStat %plr2 Atk -1
        }
        if ( %ability. [ $+ [ %plr2 ] ] == Intimidate && %ability. [ $+ [ %plr1 ] ] != Clear Body ) {
          BoostStat %plr1 Atk -1
        }
        StartBattle
      }
    }
    else {
      mesg %chan $nick sent out $TypeColor($nick).real $+ !
      SwitchEffects $nick
      var %opponent = $iif($nick == %plr1,%plr2,%plr1)
      if ( %ability. [ $+ [ $nick ] ] == Intimidate && %ability. [ $+ [ %opponent ] ] != Clear Body ) {
        BoostStat %opponent Atk -1
      }
      StartBattle
    }
  }
  elseif ( %go. [ $+ [ $nick ] ] ) {
    if (%Rampage. [ $+ [ $nick ] ] > 0) {
      mesg $nick You cannot switch; You are locked into %RampageMove. [ $+ [ $nick ] ] $+ .
      halt
    }
    set %switchpoke. [ $+ [ $nick ] ] $proper($2)
    var %legalswitch = $false
    var %count = 1
    while ( %count <= 6 ) {
      if ( ( $readini($teams,$GetTeamName($nick),$+(Pokemon,%count)) == %switchpoke. [ $+ [ $nick ] ] ) && $&
        ( $readini($teams,$GetTeamName($nick),$+(Pokemon,%count)) != %poke. [ $+ [ $nick ] ] ) ) {
        var %legalswitch = $true
        set %newslot. [ $+ [ $nick ] ] %count
      }
      inc %count 1
    }
    if ( !%legalswitch ) {
      mesg $nick Illegal switch  $+ %switchpoke. [ $+ [ $nick ] ] $+ .
      unset %switchpoke. [ $+ [ $nick ] ]
      halt
    }
    if ( $istok(%fainted. [ $+ [ $nick ] ],%newslot. [ $+ [ $nick ] ],32) ) {
      mesg $nick %switchpoke. [ $+ [ $nick ] ] has fainted; You may not switch it in.
      unset %switchpoke. [ $+ [ $nick ] ]
      unset %newslot. [ $+ [ $nick ] ]
    }
    mesg $nick You have chosen  $+ %switchpoke. [ $+ [ $nick ] ] $+  as the Pokémon to switch to.
    mesg $nick Waiting for the opponent to decide.....
    unset %go. [ $+ [ $nick ] ]
    set %ready. [ $+ [ $nick ] ] 1
    unset %switchpoke. [ $+ [ $nick ] ]
    if ( ( %ready. [ $+ [ %plr1 ] ] ) && ( %ready. [ $+ [ %plr2 ] ] ) ) {
      unset %ready.*
      UseMoves
    }
  }
}
alias -l Switch {
  var %plr = $1
  var %opponent = $iif(%plr == %plr2,%plr1,%plr2)
  mesg %chan %plr withdrew $TypeColor(%plr) $+ !
  if ( $istok($gettok($Move(%move. [ $+ [ %opponent ] ]),6-,32),KillSwitch,32) ) {
    Attack %opponent %plr
    set %Pursuit. [ $+ [ %opponent ] ] 1
  }
  GetStatus -l Confuse %plr
  unset %durationConfuse. [ $+ [ %plr ] ]
  GetStatus -l Taunt %plr
  unset %durationTaunt. [ $+ [ %plr ] ]
  if ( %ability. [ $+ [ %plr ] ] == Natural Cure ) {
    unset %status. [ $+ [ %plr ] $+ [ %slot. [ $+ [ %plr ] ] ] ]
    unset %durationToxic. [ $+ [ %plr ] $+ [ %slot. [ $+ [ %plr ] ] ] ]
  }
  unset %FlashFireBoost. [ $+ [ %plr ] ]
  unset %Seed. [ $+ [ %plr ] ]
  if ( %durationToxic. [ $+ [ %plr ] $+ [ %slot. [ $+ [ %plr ] ] ] ] != $null ) set %durationToxic. [ $+ [ %plr ] $+ [ %slot. [ $+ [ %plr ] ] ] ] 1
  set %slot. [ $+ [ %plr ] ] %newslot. [ $+ [ %plr ] ]
  unset %newslot. [ $+ [ %plr ] ]
  SetPoke %plr
  unset %Atk. [ $+ [ %plr ] ]
  unset %Def. [ $+ [ %plr ] ]
  unset %SpA. [ $+ [ %plr ] ]
  unset %SpD. [ $+ [ %plr ] ]
  unset %Spe. [ $+ [ %plr ] ]
  mesg %chan %plr sent out $TypeColor(%plr).real $+ !
  SwitchEffects %plr
  if ( %ability. [ $+ [ %plr ] ] == Intimidate && %ability. [ $+ [ %opponent ] ] != Clear Body ) {
    BoostStat %opponent Atk -1
  }
}
alias -l SwitchEffects {
  var %plr = $1
  unset %lockmove. [ $+ [ %plr ] ]
  if ( %ability. [ $+ [ %plr ] ] == Illusion ) set %Illusion 1
  if ( $istok(%field. [ $+ [ %plr ] ],StealthRock,32) ) {
    var %effective = $calc( $Effective(Rock,$gettok(%types. [ $+ [ %plr ] ],1,32)) * $Effective(Rock,$gettok(%types. [ $+ [ %plr ] ],2,32)) )
    var %damage = $int($calc( 0.125 * %effective * $GetStat(%plr).hp ))
    TakeDamage %plr %damage
    mesg %chan %plr $+ 's $TypeColor(%plr) was hurt by Stealth Rock!
  }
  if ( ( %ability. [ $+ [ %plr ] ] != Levitate ) && ( %ability. [ $+ [ %plr ] ] != Magic Guard ) && ( !$istok(%types. [ $+ [ %plr ] ],Flying,32) ) && ( ( %item. [ $+ [ %plr ] ] != Air Balloon ) || ( %popped. [ $+ [ %plr ] ] ) ) ) {
    if ( $istok(%field. [ $+ [ %plr ] ],Spikes,32) ) {
      var %damage = $int($calc( ( ( 0.0625 * %SpikesAmount. [ $+ [ %plr ] ] ) + 0.0625 ) * $GetStat(%plr).hp ))
      TakeDamage %plr %damage
      mesg %chan %plr $+ 's $TypeColor(%plr) was hurt by the Spikes!
    }
    if ( ( %ability. [ $+ [ %plr ] ] != Immunity ) && ( !$istok(%types. [ $+ [ %plr ] ],Steel,32) ) ) {
      if ( $istok(%field. [ $+ [ %plr ] ],ToxicSpikes,32) ) {
        if ( $istok( %types. [ $+ [ %plr ] ],Poison,32) ) {
          set %field. [ $+ [ %plr ] ] $remtok(%field. [ $+ [ %plr ] ],ToxicSpikes,1,32)
          unset %ToxicSpikesAmount. [ $+ [ %plr ] ]
          mesg %chan %plr $+ 's $TypeColor(%plr) absorbed the Toxic Spikes!
        }
        elseif ( ( !$istok(%status. [ $+ [ %plr ] ],Poison,32) ) && ( !$istok(%status. [ $+ [ %plr ] ],Toxic,32) ) ) {
          if ( !$istok(%types. [ $+ [ %plr ] ],Steel,32) ) {
            if ( %ToxicSpikesAmount. [ $+ [ %plr ] ] == 1 ) {
              GetStatus Poison %plr
              mesg %chan %plr $+ 's $TypeColor(%plr) was 6poisoned by the Toxic Spikes!
            }
            if ( %ToxicSpikesAmount. [ $+ [ %plr ] ] == 2 ) {
              GetStatus Toxic %plr
              mesg %chan %plr $+ 's $TypeColor(%plr) was 6badly poisoned by the Toxic Spikes!
              set %durationToxic. [ $+ [ %plr ] $+ [ %slot. [ $+ [ %plr ] ] ] ] 1
            }
          }
        }
      }
    }
  }
  if ( %ability. [ $+ [ %plr ] ] == Drought ) {
    set %weather Sun
    set %durationWeather 9001
    mesg %chan %plr $+ 's $TypeColor(%plr) $+ 's Drought intensified the sun's rays!
  }
  if ( %ability. [ $+ [ %plr ] ] == Drizzle ) {
    set %weather Rain
    set %durationWeather 9001
    mesg %chan %plr $+ 's $TypeColor(%plr) $+ 's Drizzle made it rain!
  }
  if ( %ability. [ $+ [ %plr ] ] == Sand Stream ) {
    set %weather Sandstorm
    set %durationWeather 9001
    mesg %chan %plr $+ 's $TypeColor(%plr) $+ 's Sand Stream brewed up a sandstorm!
  }
  if ( %ability. [ $+ [ %plr ] ] == Snow Warning ) {
    set %weather Hail
    set %durationWeather 9001
    mesg %chan %plr $+ 's $TypeColor(%plr) $+ 's Snow Warning made it hail!
  }
  if ( ( %item. [ $+ [ %plr ] ] == Air Balloon ) && ( !%popped. [ $+ [ %plr ] ] ) ) mesg %chan %plr $+ 's $TypeColor(%plr) is floating on its Air Balloon!
  if ( $gettok(%curHP. [ $+ [ %plr ] ],%slot. [ $+ [ %plr ] ],32) < 1 ) {
    set %dead. [ $+ [ %plr ] ] 1
    set %fainted. [ $+ [ %plr ] ] $addtok(%fainted. [ $+ [ %plr ] ],%slot. [ $+ [ %plr ] ],32)
    mesg %chan %plr $+ 's $TypeColor(%plr) fainted! Score: $Score($iif(%plr == %plr1,%plr2,%plr1))
  }
}
alias -l WeatherMsg {
  if ( %durationWeather <= 0 ) return
  if ( %weather == Sun ) var %msg = 4The sunlight is strong.
  if ( %weather == Rain ) var %msg = 12Rain continues to fall.
  if ( %weather == Sandstorm ) var %msg = 5The sandstorm rages.
  if ( %weather == Hail ) var %msg = 11Hail continues to fall.
  if ( %msg != $null ) mesg %chan %msg
}
alias -l UseMoves {
  mesg %chan 4Start of turn %turns $+ .
  inc %turns 1
  .timer $+ %plr1 1 300 Disqualify %plr1
  .timer $+ %plr2 1 300 Disqualify %plr2
  var %switch1 = 0
  var %switch2 = 0
  if ( %newslot. [ $+ [ %plr1 ] ] != $null ) {
    set %switch. [ $+ [ %plr1 ] ] 1
    Switch %plr1
    var %switch1 = 1
  }
  if ( %newslot. [ $+ [ %plr2 ] ] != $null ) {
    set %switch. [ $+ [ %plr2 ] ] 1
    Switch %plr2
    var %switch2 = 1
  }
  if ( ( %switch1 ) && ( %switch2 ) ) {
    set %faster %plr1
    WeatherMsg
    if ( !%dead. [ $+ [ %plr1 ] ] ) EndOfTurn %plr1 %plr2
    if ( !%dead. [ $+ [ %plr2 ] ] ) EndOfTurn %plr2 %plr2
  }
  if ( ( %switch1 ) && ( !%switch2 ) ) {
    set %faster %plr1
    if ( !%dead. [ $+ [ %plr1 ] ] ) Attack %plr2 %plr1
    WeatherMsg
    if ( !%dead. [ $+ [ %plr1 ] ] ) EndOfTurn %plr1 %plr2
    if ( !%dead. [ $+ [ %plr2 ] ] ) EndOfTurn %plr2 %plr2
  }
  elseif ( ( !%switch1 ) && ( %switch2 ) ) {
    set %faster %plr2
    if ( !%dead. [ $+ [ %plr1 ] ] ) Attack %plr1 %plr2
    WeatherMsg
    if ( !%dead. [ $+ [ %plr1 ] ] ) EndOfTurn %plr2 %plr1
    if ( !%dead. [ $+ [ %plr2 ] ] ) EndOfTurn %plr1 %plr2
  }
  elseif ( ( !%switch1 ) && ( !%switch2 ) ) {
    var %speedtie = $rand(1,2)
    var %speed1 = $GetStat(%plr1).spe
    if ( %item. [ $+ [ %plr1 ] ] == Choice Scarf ) var %speed1 = $int($calc( 1.5 * %speed1 ))
    if ( ( %ability. [ $+ [ %plr1 ] ] == Swift Swim ) && ( %weather == Rain ) ) var %speed1 = $int($calc( 2 * %speed1 ))
    if ( ( %ability. [ $+ [ %plr1 ] ] == Chlorophyll ) && ( %weather == Sun ) ) var %speed1 = $int($calc( 2 * %speed1 ))
    if ( $istok(%status. [ $+ [ %plr1 ] $+ [ %slot. [ $+ [ %plr1 ] ] ] ],Paralyze,32) ) var %speed1 = $int($calc( 0.25 * %speed1 ))
    var %speed2 = $GetStat(%plr2).spe
    if ( %item. [ $+ [ %plr2 ] ] == Choice Scarf ) var %speed2 = $int($calc( 1.5 * %speed2 ))
    if ( ( %ability. [ $+ [ %plr2 ] ] == Swift Swim ) && ( %weather == Rain ) ) var %speed2 = $int($calc( 2 * %speed2 ))
    if ( ( %ability. [ $+ [ %plr2 ] ] == Chlorophyll ) && ( %weather == Sun ) ) var %speed2 = $int($calc( 2 * %speed2 ))
    if ( $istok(%status. [ $+ [ %plr2 ] $+ [ %slot. [ $+ [ %plr2 ] ] ] ],Paralyze,32) ) var %speed2 = $int($calc( 0.25 * %speed2 ))
    var %q = $Move(%move. [ $+ [ %plr1 ] ])
    var %w = $Move(%move. [ $+ [ %plr2 ] ])
    if ( ( priority isin %q ) || ( priority isin %w ) ) {
      if ( priority isin %q ) var %prior1 = $gettok($Move(%move. [ $+ [ %plr1 ] ]),$calc( $findtok($Move(%move. [ $+ [ %plr1 ] ]),priority,1,32) + 1 ),32)
      else var %prior1 = 0
      if ( priority isin %w ) var %prior2 = $gettok($Move(%move. [ $+ [ %plr2 ] ]),$calc( $findtok($Move(%move. [ $+ [ %plr2 ] ]),priority,1,32) + 1 ),32)
      else var %prior2 = 0
      if ( %prior1 > %prior2 ) {
        set %faster %plr1
        if ( !%dead. [ $+ [ %plr1 ] ] ) Attack %plr1 %plr2
        var %flinch = $true
        if ( $istok($Move(%move. [ $+ [ %plr1 ] ]),flinch,32) ) {
          var %flinch = $false
          var %chance = $gettok($Move(%move. [ $+ [ %plr1 ] ]),$calc( $findtok($Move(%move. [ $+ [ %plr1 ] ]),flinch,1,32) + 1 ),32)
          if ( %ability. [ $+ [ %plr ] ] == Serene Grace ) var %chance = $int($calc( 2 * %chance ))
          if ( $rand(1,100) <= %chance ) mesg %chan %plr2 $+ 's $TypeColor(%plr2) flinched!
          else if ( !%dead. [ $+ [ %plr2 ] ] ) Attack %plr2 %plr1
        }
        if ( %flinch ) if ( !%dead. [ $+ [ %plr1 ] ] ) Attack %plr2 %plr1
        WeatherMsg
        if ( !%dead. [ $+ [ %plr1 ] ] ) EndOfTurn %plr1 %plr2
        if ( !%dead. [ $+ [ %plr2 ] ] ) EndOfTurn %plr2 %plr1
      }
      if ( %prior2 > %prior1 ) {
        set %faster %plr2
        if ( !%dead. [ $+ [ %plr1 ] ] ) Attack %plr2 %plr1
        var %flinch = $true
        if ( $istok($Move(%move. [ $+ [ %plr2 ] ]),flinch,32) ) {
          var %flinch = $false
          var %chance = $gettok($Move(%move. [ $+ [ %plr2 ] ]),$calc( $findtok($Move(%move. [ $+ [ %plr2 ] ]),flinch,1,32) + 1 ),32)
          if ( %ability. [ $+ [ %plr ] ] == Serene Grace ) var %chance = $int($calc( 2 * %chance ))
          if ( $rand(1,100) <= %chance ) mesg %chan %plr1 $+ 's $TypeColor(%plr1) flinched!
          else if ( !%dead. [ $+ [ %plr1 ] ] ) Attack %plr1 %plr2
        }
        if ( %flinch ) if ( !%dead. [ $+ [ %plr1 ] ] ) Attack %plr1 %plr2
        WeatherMsg
        if ( !%dead. [ $+ [ %plr2 ] ] ) EndOfTurn %plr2 %plr1
        if ( !%dead. [ $+ [ %plr1 ] ] ) EndOfTurn %plr1 %plr2
      }
    }
    if ( %prior1 == %prior2 ) {
      if ( ( %speed1 > %speed2 ) || ( ( %speed1 == %speed2 ) && ( %speedtie == 1 ) ) ) {
        set %faster %plr1
        if ( !%dead. [ $+ [ %plr1 ] ] ) Attack %plr1 %plr2
        var %flinch = $true
        if ( $istok($Move(%move. [ $+ [ %plr1 ] ]),flinch,32) ) {
          var %flinch = $false
          var %chance = $gettok($Move(%move. [ $+ [ %plr1 ] ]),$calc( $findtok($Move(%move. [ $+ [ %plr1 ] ]),flinch,1,32) + 1 ),32)
          if ( %ability. [ $+ [ %plr ] ] == Serene Grace ) var %chance = $int($calc( 2 * %chance ))
          if ( $rand(1,100) <= %chance ) mesg %chan %plr2 $+ 's $TypeColor(%plr2) flinched!
          else if ( !%dead. [ $+ [ %plr2 ] ] ) Attack %plr2 %plr1
        }
        if ( %flinch ) if ( !%dead. [ $+ [ %plr1 ] ] ) Attack %plr2 %plr1
        WeatherMsg
        if ( !%dead. [ $+ [ %plr1 ] ] ) EndOfTurn %plr1 %plr2
        if ( !%dead. [ $+ [ %plr2 ] ] ) EndOfTurn %plr2 %plr1
      }
      elseif ( ( %speed1 < %speed2 ) || ( ( %speed1 == %speed2 ) && ( %speedtie == 2 ) ) ) {
        set %faster %plr2
        if ( !%dead. [ $+ [ %plr1 ] ] ) Attack %plr2 %plr1
        var %flinch = $true
        if ( $istok($Move(%move. [ $+ [ %plr2 ] ]),flinch,32) ) {
          var %flinch = $false
          var %chance = $gettok($Move(%move. [ $+ [ %plr2 ] ]),$calc( $findtok($Move(%move. [ $+ [ %plr2 ] ]),flinch,1,32) + 1 ),32)
          if ( %ability. [ $+ [ %plr ] ] == Serene Grace ) var %chance = $int($calc( 2 * %chance ))
          if ( $rand(1,100) <= %chance ) mesg %chan %plr1 $+ 's $TypeColor(%plr1) flinched!
          else if ( !%dead. [ $+ [ %plr1 ] ] ) Attack %plr1 %plr2
        }
        if ( %flinch ) if ( !%dead. [ $+ [ %plr1 ] ] ) Attack %plr1 %plr2
        WeatherMsg
        if ( !%dead. [ $+ [ %plr2 ] ] ) EndOfTurn %plr2 %plr1
        if ( !%dead. [ $+ [ %plr1 ] ] ) EndOfTurn %plr1 %plr2
      }
    }
  }
  if ( %durationWeather != $null ) dec %durationWeather 1
  unset %protect.*
  unset %switch.*
  unset %faster
  StartBattle
}
alias -l TypeColor {
  var %type = $gettok(%Types. [ $+ [ $1 ] ],1,32)
  if ( ( %ability. [ $+ [ $1 ] ] == Illusion ) && ( %Illusion. [ $+ [ $1 ] ] ) ) {
    var %pokedis = $readini($teams,$GetTeamName($1),$+(Pokemon,$gettok(%slotorder. [ $+ [ $nick ] ],6,32))) $+ $iif($readini($teams,$GetTeamName($1),$+(Shiny,$gettok(%slotorder. [ $+ [ $nick ] ],6,32))),*,)
    var %dis = $readini($teams,$GetTeamName($1),$+(Nickname,$gettok(%slotorder. [ $+ [ $nick ] ],6,32)))
    var %type = $gettok($readini($teams,$GetTeamName($1),$+(Type,$gettok(%slotorder. [ $+ [ $nick ] ],6,32))),1,32)
  }
  if ( $prop == atk ) var %type = $gettok($Move(%move. [ $+ [ $1 ] ]),1,32)
  if ( %type == Normal ) var %textcolor = 14
  if ( %type == Fighting ) var %textcolor = 05
  if ( %type == Flying ) var %textcolor = 15
  if ( %type == Poison ) var %textcolor = 06
  if ( %type == Ground ) var %textcolor = 07
  if ( %type == Rock ) var %textcolor = 05
  if ( %type == Bug ) var %textcolor = 03
  if ( %type == Ghost ) var %textcolor = 0,01
  if ( %type == Steel ) var %textcolor = 14
  if ( %type == Fire ) var %textcolor = 04
  if ( %type == Water ) var %textcolor = 12
  if ( %type == Grass ) var %textcolor = 09
  if ( %type == Electric ) var %textcolor = 08
  if ( %type == Psychic ) var %textcolor = 13
  if ( %type == Ice ) var %textcolor = 11
  if ( %type == Dragon ) var %textcolor = 06
  if ( %type == Dark ) var %textcolor = 01
  if ( %textcolor == $null ) var %textcolor = 01
  if ( $prop == atk ) return  $+ %textcolor $+ %move. [ $+ [ $1 ] ] $+ 
  if ( $prop == real ) return  $+ %textcolor $+ $iif(%dis,%dis,%nick. [ $+ [ $1 ] ]) $+  $+($chr(40),$iif(%pokedis,%pokedis,$+(%poke. [ $+ [ $1 ] ],$iif($readini($teams,$GetTeamName($1),$+(Shiny,%slot. [ $+ [ $1 ] ])),*,))),$chr(41))
  return  $+ %textcolor $+ $iif(%dis,%dis,%nick. [ $+ [ $1 ] ]) $+ 
}
; $1: Base Power  $2: [Sp]Atk  $3: [Sp]Def  $4: Mod1  $5: CH $6: Mod2  $7: R  $8: STAB  $9: Type1&2  $10: Mod3
alias -l Damage return $int($calc( ( ( ( ( ( ( ( 100 * 2 / 5 ) + 2 ) * $1 * $2 / 50 ) / $3 ) * $4 ) + 2 ) * $5 * $6 * $7 / 100 ) * $8 * $9 * $10 ))
alias -l TakeDamage {
  if ( $2 == Substitute ) set %subHP. [ $+ [ $1 ] ] $calc( %subHP. [ $+ [ $1 ] ] - $3 )
  else {
    var %a = $gettok(%curHP. [ $+ [ $1 ] ],%slot. [ $+ [ $1 ] ],32)
    var %b = $GetStat($1).hp
    if ( %a == %b ) var %max = 1
    var %plr = $1
    var %damage = $2
    if ( $calc( $gettok(%curHP. [ $+ [ %plr ] ],%slot. [ $+ [ %plr ] ],32) - %damage ) > $GetStat(%plr).hp ) $&
      var %damage = $calc( -1 * ( $GetStat(%plr).hp - $gettok(%curHP. [ $+ [ %plr ] ],%slot. [ $+ [ %plr ] ],32) ) )
    set %curHP. [ $+ [ %plr ] ] $puttok(%curHP. [ $+ [ %plr ] ],$calc( $gettok(%curHP. [ $+ [ %plr ] ],%slot. [ $+ [ %plr ] ],32) - %damage ),%slot. [ $+ [ %plr ] ],32)
    if ( ( $gettok(%curHP. [ $+ [ %plr ] ],%slot. [ $+ [ %plr ] ],32) < 1 ) && ( %max ) && ( ( %item. [ $+ [ %plr ] ] == Focus Sash ) || ( %ability. [ $+ [ %plr ] ] == Sturdy ) ) ) {
      set %curHP. [ $+ [ %plr ] ] $puttok(%curHP. [ $+ [ %plr ] ],1,%slot. [ $+ [ %plr ] ],32)
      DisplayHP %a 1 %b
      mesg %chan %plr $+ 's $TypeColor(%plr) held on using its $iif(%ability. [ $+ [ %plr ] ] == Sturdy,Sturdy,Focus Sash) $+ !
    }
    else {
      var %c = $gettok(%curHP. [ $+ [ %plr ] ],%slot. [ $+ [ %plr ] ],32)
      DisplayHP %a %c %b
    }
  }
}
alias -l DisplayHP {
  var %HPold = $1
  var %HPnew = $2
  var %HPmax = $3
  var %percentHPold = $ceil($calc( 50 * ( %HPold / %HPmax ) ))
  var %percentHPnew = $ceil($calc( 50 * ( %HPnew / %HPmax ) ))
  if ( %percentHPnew > 25 ) var %textcolor = 9,9
  elseif ( %percentHPnew > 12.5 ) var %textcolor = 8,8
  else var %textcolor = 4,4
  var %HP = %textcolor
  var %count = 1
  while ( %count <= 50 ) {
    if ( %count == %percentHPold ) {
      if ( %count >= %percentHPnew ) var %HP = %HP $+ 7,7 $+ $chr(160) $+ 1,1
      else var %HP = %HP $+ 7,7 $+ $chr(160) $+ %textcolor
    }
    else {
      if ( %count > %percentHPnew ) var %HP = %HP $+ 1,1
      var %HP = %HP $+ $chr(160)
    }
    inc %count 1
  }
  mesg %chan $+(%HP,,$chr(32),$round($calc( 100 * %HPnew / %HPmax ),1),$chr(37))
}
alias -l Trip {
  var %poke = $1
  var %p20 = Azelf.Bellossom.Castform.Celebi.Chatot.Cherrim.Chimecho.Corsola.Ditto.Glameow.Jirachi.Jumpluff.Luvdisc.Manaphy.Masquerain.Mesprit.Mew.Minun.Mismagius.Pachirisu.Phione.Pikachu.Plusle.Qwilfish.Rotom.Shaymin.Shedinja.Spinda.Sunflora.Unown.Uxie.Weezing.Wormadam
  var %p40 = Altaria.Ambipom.Banette.Delibird.Drifblim.Dunsparce.Farfetch'd.Flareon.Gorebyss.Illumise.Jolteon.Kecleon.Lanturn.Lumineon.Mawile.Mothim.Ninetales.Ninjask.Raticate.Relicanth.Roserade.Sableye.Shuckle.Staraptor.Swellow.Trapinch.Venomoth.Victreebel.Vileplume.Volbeat.Whiscash.Wigglytuff.Wynaut.Xatu
  var %p60 = Absol.Alakazam.Ariados.Azumarill.Beautifly.Beedrill.Bibarel.Blissey.Breloom.Butterfree.Carnivine.Chansey.Clefable.Crawdaunt.Delcatty.Dugtrio.Dustox.Espeon.Fearow.Floatzel.Froslass.Furrett.Gengar.Gastrodon.Gallade.Girafarig.Glaceon.Gliscor.Granbull.Hitmonlee.Hitmontop.Honchkrow.Houndoom.Huntail.Jynx.Kabutops.Kricketune.Latias.Leafeon.Ledian.Linoone.Lopunny.Luxray.Manectric.Marowak.Medicham.Mightyena.Muk.Noctowl.Octillery.Omastar.Parasect.Pelipper.Persian.Pidgeot.Politoed.Porygon-Z.Porygon2.Primeape.Purugly.Raichu.Sandslash.Seaking.Skuntank.Sudowoodo.Togekiss.Toxicroak.Umbreon.Vaporeon.Vespiquen.Vigoroth.Weavile.Wobbuffet.Zangoose
  var %p80 = Aerodactyl.Ampharos.Arbok.Armaldo.Articuno.Blastoise.Blaziken.Cacturne.Charizard.Clamperl.Cradily.Cresselia.Crobat.Darkrai.Deoxys.Dodrio.Drapion.Electrode.Empoleon.Exploud.Feraligatr.Flygon.Gardevoir.Garchomp.Golduck.Grumpig.Heracross.Hitmonchan.Hypno.Infernape.Kangaskhan.Kingler.Latios.Lucario.Ludicolo.Magcargo.Magmortar.Magneton.Miltank.Moltres.Mr. Mime.Nidoking.Nidoqueen.Pinsir.Poliwrath.Quagsire.Rapidash.Sceptile.Scyther.Seviper.Sharpedo.Shiftry.Skarmory.Slowbro.Slowking.Smeargle.Stantler.Starmie.Swampert.Swalot.Tauros.Tentacruel.Torkoal.Typhlosion.Yanmega.Zapdos
  var %p100 = Abomasnow.Arcanine.Bastiodon.Bronzong.Claydol.Cloyster.Dewgong.Donphan.Dusknoir.Electivire.Entei.Exeggutor.Forretress.Ho-oh.Kingdra.Lickilicky.Lunatone.Machamp.Magnezone.Meganium.Mewtwo.Milotic.Raikou.Rampardos.Regice.Rhydon.Salamence.Scizor.Slaking.Solrock.Spiritomb.Suicune.Tangrowth.Tropius.Ursaring.Venusaur.Walrein
  var %p120 = Aggron.Arceus.Camerupt.Dialga.Dragonite.Giratina.Giratina-o.Glalie.Golem.Groudon.Gyarados.Hariyama.Heatran.Hippowdon.Kyogre.Lapras.Lugia.Mamoswine.Mantine.Metagross.Palkia.Probopass.Rayquaza.Regigigas.Regirock.Registeel.Rhyperior.Snorlax.Steelix.Torterra.Tyranitar.Wailord
  if ( $istok(%p20,%poke,46) ) return 20
  if ( $istok(%p40,%poke,46) ) return 40
  if ( $istok(%p60,%poke,46) ) return 60
  if ( $istok(%p80,%poke,46) ) return 80
  if ( $istok(%p100,%poke,46) ) return 100
  if ( $istok(%p120,%poke,46) ) return 120
  return 1
}
alias -l HiddenPower {
  var %IVs = $1
  var %count = 1
  while ( %count <= 6 ) {
    var %IV. [ $+ [ %count ] ] $gettok(%IVs,%count,32)
    inc %count 1
  }
  if ( $prop == type ) {
    if ( $calc( %IV.1 % 2 ) == 1 ) var %a = 1
    else var %a = 0
    if ( $calc( %IV.2 % 2 ) == 1 ) var %b = 1
    else var %b = 0
    if ( $calc( %IV.3 % 2 ) == 1 ) var %c = 1
    else var %c = 0
    if ( $calc( %IV.4 % 2 ) == 1 ) var %e = 1
    else var %e = 0
    if ( $calc( %IV.5 % 2 ) == 1 ) var %f = 1
    else var %f = 0
    if ( $calc( %IV.6 % 2 ) == 1 ) var %d = 1
    else var %d = 0
    var %type = $int($calc( ( ( %a + ( 2 * %b ) + ( 4 * %c ) + ( 8 * %d ) + ( 16 * %e ) + ( 32 * %f ) ) * 15 ) / 63.0 ))
    if ( %type == 0 ) var %text = Fighting
    elseif ( %type == 1 ) var %text = Flying
    elseif ( %type == 2 ) var %text = Poison
    elseif ( %type == 3 ) var %text = Ground
    elseif ( %type == 4 ) var %text = Rock
    elseif ( %type == 5 ) var %text = Bug
    elseif ( %type == 6 ) var %text = Ghost
    elseif ( %type == 7 ) var %text = Steel
    elseif ( %type == 8 ) var %text = Fire
    elseif ( %type == 9 ) var %text = Water
    elseif ( %type == 10 ) var %text = Grass
    elseif ( %type == 11 ) var %text = Electric
    elseif ( %type == 12 ) var %text = Psychic
    elseif ( %type == 13 ) var %text = Ice
    elseif ( %type == 14 ) var %text = Dragon
    elseif ( %type == 15 ) var %text = Dark
    return %text
  }
  elseif ( $prop == power ) {
    if ( ( $calc( %IV.1 % 4 ) == 2 ) || ( $calc( %IV.1 % 4 ) == 3 ) ) var %u = 1
    else var %u = 0
    if ( ( $calc( %IV.2 % 4 ) == 2 ) || ( $calc( %IV.2 % 4 ) == 3 ) ) var %v = 1
    else var %v = 0
    if ( ( $calc( %IV.3 % 4 ) == 2 ) || ( $calc( %IV.3 % 4 ) == 3 ) ) var %w = 1
    else var %w = 0
    if ( ( $calc( %IV.4 % 4 ) == 2 ) || ( $calc( %IV.4 % 4 ) == 3 ) ) var %y = 1
    else var %y = 0
    if ( ( $calc( %IV.5 % 4 ) == 2 ) || ( $calc( %IV.5 % 4 ) == 3 ) ) var %z = 1
    else var %z = 0
    if ( ( $calc( %IV.6 % 4 ) == 2 ) || ( $calc( %IV.6 % 4 ) == 3 ) ) var %x = 1
    else var %x = 0
    var %power = $int($calc( ( ( ( %u + ( 2 * %v ) + ( 4 * %w ) + ( 8 * %x ) + ( 16 * %y ) + ( 32 * %z ) ) * 40 ) / 63.0 ) + 30 ))
    return %power
  }
}
alias -l GetStat {
  if ($prop == hp) var %index = 1
  elseif ($prop == atk) var %index = 2
  elseif ($prop == def) var %index = 3
  elseif ($prop == spa) var %index = 4
  elseif ($prop == spd) var %index = 5
  elseif ($prop == spe) var %index = 6
  else return
  var %statBoost = % [ $+ [ $prop ] $+ ] . [ $+ [ $$1 ] ]
  if (%statBoost == $null) %statBoost = 0
  if (%statBoost >= 0) var %statBoost = $calc(%statBoost + 2) / 2
  elseif (%statBoost < 0) var %statBoost = 2 / $calc(-1 * %statBoost + 2)
  else return
  var %return = $calc(%statBoost * $gettok(%stat. [ $+ [ $1 ] ],%index,32))
  var %fe = 3.6.9.12.15.18.20.22.24.26.28.31.34.36.38.40.45.47.49.51.53.55.57.59.62.65.68.71.73.76.78.80.83.85.87.89.91.94.97.99.101.103.105.106.107.110.115.119.121.122.124.127.128.130.131.132.134.135.136.139.141.142.143.144.145.146.149.150.151.154.157.160.162.164.166.168.169.171.178.181.182.184.185.186.189.192.195.196.197.199.201.202.203.205.206.208.210.211.212.213.214.217.219.222.224.225.226.227.229.230.232.234.235.237.241.242.243.244.245.248.249.250.251.254.257.260.262.264.267.269.272.275.277.279.282.284.286.289.291.292.295.297.301.302.303.306.308.310.311.312.313.314.317.319.321.323.324.326.327.330.332.334.335.336.337.338.340.342.344.346.348.350.351.352.354.357.358.359.362.365.367.368.369.370.373.376.377.378.379.380.381.382.383.384.385.386.389.392.395.398.400.402.405.407.409.411.413.414.416.417.419.421.423.424.426.428.429.430.432.435.437.441.442.445.448.450.452.454.455.457.460.461.462.463.464.465.466.467.468.469.470.471.472.473.474.475.476.477.478.479.480.481.482.483.484.485.486.487.488.489.490.491.492.493.494.497.500.503.505.508.510.512.514.516.518.521.523.526.528.530.531.534.537.538.539.542.545.547.549.550.553.555.556.558.560.561.563.565.567.569.571.573.576.579.581.584.586.587.589.591.593.594.596.598.601.604.606.609.612.614.615.617.618.620.621.623.625.626.628.630.631.632.635.637.638.639.640.641.642.643.644.645.646.647.648.649.652.655.658.660.663.666.668.671.673.675.676.678.681.683.685.687.689.691.693.695.697.699.700.701.702.703.706.707.709.711.713.715.716.717.718
  if (%item. [ $+ [ $1 ] ] == Eviolite && ($prop == def || $prop == spd) && !$istok(%fe,$gettok($Pokemon(%poke. [ $+ [ $1 ] ]),2,46),46)) {
    var %oldreturn = %return
    %return = $int($calc(1.5 * %return))
    mesg %chan DEBUG: Eviolite: $upper($prop) raised from %oldreturn to %return $+ .
  }
  return %return
}
alias -l Attack {
  var %plr = $1
  if ( %Pursuit. [ $+ [ %plr ] ] ) return
  if ( ( ( %item. [ $+ [ %plr ] ] == Choice Band ) || ( %item. [ $+ [ %plr ] ] == Choice Specs ) || $&
    ( %item. [ $+ [ %plr ] ] == Choice Scarf ) ) && ( %lockmove. [ $+ [ %plr ] ] == $null ) ) set %lockmove. [ $+ [ %plr ] ] %move. [ $+ [ %plr ] ]
  if ( %dead. [ $+ [ %plr ] ] ) return
  if ( %recharge. [ $+ [ %plr ] ] ) {
    mesg %chan %plr $+ 's $TypeColor(%plr) must recharge!
    unset %recharge. [ $+ [ %plr ] ]
    return
  }
  var %opponent = $2
  var %effect = $gettok($Move(%move. [ $+ [ %plr ] ]),6-,32)
  var %critical = $rand(1,10000)
  if ( $istok($Move(%move. [ $+ [ %plr ] ]),crit,32) ) {
    if ( %critical <= 1250 ) var %crit = 2
    else var %crit = 1
  }
  else {
    if ( %critical <= 625 ) var %crit = 2
    else var %crit = 1
  }
  if ( $istok(%status. [ $+ [ %plr ] $+ [ %slot. [ $+ [ %plr ] ] ] ],Sleep,32) ) {
    if ( %durationSleep. [ $+ [ %plr ] $+ [ %slot. [ $+ [ %plr ] ] ] ] <= 0 ) {
      mesg %chan %plr $+ 's $TypeColor(%plr) 15woke up!
      GetStatus -l Sleep %plr
      unset %durationSleep. [ $+ [ %plr ] $+ [ %slot. [ $+ [ %plr ] ] ] ]
    }
    else {
      mesg %chan %plr $+ 's $TypeColor(%plr) is 15fast asleep...
      DisruptRampage %plr
      if ( $istok(%effect,SleepTalk,32) ) {
        mesg %chan %plr $+ 's $TypeColor(%plr) used $TypeColor(%plr).atk $+ !
        var %illegalchoices = Assist.Bide.Bounce.Chatter.Copycat.Dig.Dive.Fly.Focus Punch.Me First.Metronome.Mirror Move.Shadow Force.Skull Bash.Sky Attack.Sleep Talk.SolarBeam.Razor Wind.Uproar
        var %moveloc = $rand(1,4)
        while ( $istok(%illegalchoices,$gettok(%moves. [ $+ [ %plr ] ],%moveloc,46),46) ) var %moveloc = $rand(1,4)
        var %newmove = $gettok(%moves. [ $+ [ %plr ] ],%moveloc,46)
        set %move. [ $+ [ %plr ] ] %newmove
        set %STalk. [ $+ [ %plr ] ] 1
        var %effect = $gettok($Move(%move. [ $+ [ %plr ] ]),6-,32)
      }
      else return
    }
  }
  if ( $istok(%status. [ $+ [ %plr ] $+ [ %slot. [ $+ [ %plr ] ] ] ],Freeze,32) ) {
    if ( $rand(1,5) == 5 ) {
      mesg %chan %plr $+ 's $TypeColor(%plr) 11thawed out!
      GetStatus -l Freeze %plr
    }
    else {
      mesg %chan %plr $+ 's $TypeColor(%plr) is 11frozen solid!
      DisruptRampage %plr
      return
    }
  }
  if ( $istok(%status. [ $+ [ %plr ] $+ [ %slot. [ $+ [ %plr ] ] ] ],Confuse,32) ) {
    if ( %durationConfuse. [ $+ [ %plr ] ] <= 0 ) {
      mesg %chan %plr $+ 's $TypeColor(%plr) snapped out of its confusion!
      GetStatus -l Confuse %plr
      unset %durationConfuse. [ $+ [ %plr ] ]
    }
    else {
      mesg %chan %plr $+ 's $TypeColor(%plr) is confused!
      if ( $rand(0,1) ) {
        var %BasePower = 40
        var %Attack = $GetStat(%plr).atk
        var %Defense = $GetStat(%plr).def
        var %R = $int($calc( ( $rand(217,255) * 100 ) / 255 ))
        var %damage = $Damage(%BasePower,%Attack,%Defense,1,1,1,%R,1,1,1)
        TakeDamage %plr %damage
        mesg %chan It hurt itself in its confusion!
        if ( $gettok(%curHP. [ $+ [ %plr ] ],%slot. [ $+ [ %plr ] ],32) < 1 ) {
          set %dead. [ $+ [ %plr ] ] 1
          set %fainted. [ $+ [ %plr ] ] $addtok(%fainted. [ $+ [ %plr ] ],%slot. [ $+ [ %plr ] ],32)
          mesg %chan %plr $+ 's $TypeColor(%plr) fainted! Score: $Score(%opponent)
        }
        else DisruptRampage %plr
        return
      }
    }
  }
  if ( $istok(%status. [ $+ [ %plr ] $+ [ %slot. [ $+ [ %plr ] ] ] ],Taunt,32) ) {
    if ( %durationTaunt. [ $+ [ %plr ] ] == 0 ) {
      mesg %chan %plr $+ 's $TypeColor(%plr) $+ 's Taunt wore off!
      GetStatus -l Taunt %plr
      unset %durationTaunt. [ $+ [ %plr ] ]
    }
  }
  if ( $istok(%status. [ $+ [ %plr ] $+ [ %slot. [ $+ [ %plr ] ] ] ],Paralyze,32) ) {
    if ( $rand(1,4) == 4 ) {
      mesg %chan %plr $+ 's $TypeColor(%plr) is 8paralyzed! It can't move!
      DisruptRampage %plr
      return
    }
  }
  var %atk = $gettok($Move(%move. [ $+ [ %plr ] ]),1,32)
  var %def1 = $gettok(%Types. [ $+ [ %opponent ] ],1,32)
  var %def2 = $gettok(%Types. [ $+ [ %opponent ] ],2,32)
  if ( $istok($Move(%move. [ $+ [ %plr ] ]),HiddenPower,32) ) var %atk = $HiddenPower(%IVs. [ $+ [ %plr ] ]).type
  if ( $istok($Move(%move. [ $+ [ %plr ] ]),faint,32) ) TakeDamage %plr 9001
  if ( ( $istok(%status. [ $+ [ %plr ] $+ [ %slot. [ $+ [ %plr ] ] ] ],Taunt,32) ) && ( $gettok($Move(%move. [ $+ [ %plr ] ]),2,32) == Status ) ) {
    mesg %chan %plr $+ 's $TypeColor(%plr) cannot use $TypeColor(%plr).atk after the taunt!
    return
  }

  mesg %chan %plr $+ 's $TypeColor(%plr) used $TypeColor(%plr).atk $+ !

  if ($istok(%effect,rampage,32) && %Rampage. [ $+ [ %plr ] ] == $null) {
    set %Rampage. [ $+ [ %plr ] ] $rand(2,3)
    set %RampageMove. [ $+ [ %plr ] ] %move. [ $+ [ %plr ] ]
  }
  if ($istok(%effect,haze,32)) {
    unset %Atk.*
    unset %Def.*
    unset %SpA.*
    unset %SpD.*
    unset %Spe.*
    mesg %chan Both Pokémon's stats have been reset!
  }
  if ( $istok(%effect,RandomMove,32) ) {
    set %move. [ $+ [ %plr ] ] $Proper($Metronome($rand(1,534)))
    if ( $istok($Move(%move. [ $+ [ %plr ] ]),faint,32) ) TakeDamage %plr 9001
    if ( ( $istok(%status. [ $+ [ %plr ] $+ [ %slot. [ $+ [ %plr ] ] ] ],Taunt,32) ) && ( $gettok($Move(%move. [ $+ [ %plr ] ]),2,32) == Status ) ) {
      mesg %chan %plr $+ 's $TypeColor(%plr) cannot use $TypeColor(%plr).atk after the taunt!
      return
    }
    mesg %chan %plr $+ 's $TypeColor(%plr) used $TypeColor(%plr).atk $+ !
    var %effect = $gettok($Move(%move. [ $+ [ %plr ] ]),6-,32)
    var %atk = $gettok($Move(%move. [ $+ [ %plr ] ]),1,32)
    var %def1 = $gettok(%Types. [ $+ [ %opponent ] ],1,32)
    var %def2 = $gettok(%Types. [ $+ [ %opponent ] ],2,32)
    if ( $istok($Move(%move. [ $+ [ %plr ] ]),HiddenPower,32) ) var %atk = $HiddenPower(%IVs. [ $+ [ %plr ] ]).type
  }
  if ( ( %dead. [ $+ [ %opponent ] ] ) && ( !$NoProtect(%move. [ $+ [ %plr ] ]) ) ) {
    mesg %chan But there was no target...
    DisruptRampage %plr
    return
  }
  var %acc = $gettok($Move(%move. [ $+ [ %plr ] ]),4,32)
  if ( ( %weather == Rain ) && ( $istok(%effect,rainnomiss,32) ) ) var %acc = 100
  if ( ( %weather == Sun ) && ( $istok(%effect,rainnomiss,32) ) ) var %acc = 50

  ; ^^^ Accuracy mods here

  if ( ( $rand(1,100) > %acc ) && ( %ability. [ $+ [ %plr ] ] != No Guard ) && ( %ability. [ $+ [ %opponent ] ] != No Guard ) ) {
    mesg %chan %opponent $+ 's $TypeColor(%opponent) avoided the attack!
    DisruptRampage %plr
    return
  }
  if ( $istok(%effect,none,32) ) {
    mesg %chan BUT NOTHING HAPPENED!
    return
  }
  if ( ( ( $istok(%effect,SleepTalk,32) ) && ( !%STalk. [ $+ [ %plr ] ] ) ) || ( ( $istok(%effect,SuckerPunch,32) ) && $&
    ( ( $gettok($Move(%move. [ $+ [ %opponent ] ]),2,32) == Status ) || ( %switch. [ $+ [ %opponent ] ] ) ) ) || $&
    ( ( $istok(%status. [ $+ [ %plr ] ],Substitute,32) ) && ( $istok(%effect,Substitute,32) ) ) ) {
    mesg %chan But it failed!
    return
  }
  if ( ( %protect. [ $+ [ %opponent ] ] ) && ( !$NoProtect(%move. [ $+ [ %plr ] ]) ) ) {
    mesg %chan %opponent $+ 's $TypeColor(%opponent) protected itself!
    unset %protect. [ $+ [ %opponent ] ]
    DisruptRampage %plr
    return
  }
  if ( ( %ability. [ $+ [ %opponent ] ] == Motor Drive ) && ( %atk == Electric ) ) {
    BoostStat %opponent Spe 1
    return
  }
  if ( ( %ability. [ $+ [ %opponent ] ] == Volt Absorb ) && ( %atk == Electric ) ) {
    TakeDamage %opponent $calc( -0.5 * $GetStat(%opponent).hp )
    mesg %chan %opponent $+ 's $TypeColor(%opponent) absorbed the attack with Volt Absorb!
    return
  }
  if ( ( %ability. [ $+ [ %opponent ] ] == Water Absorb ) && ( %atk == Water ) ) {
    TakeDamage %opponent $calc( -0.5 * $GetStat(%opponent).hp )
    mesg %chan %opponent $+ 's $TypeColor(%opponent) absorbed the attack with Water Absorb!
    return
  }
  if ( ( %ability. [ $+ [ %opponent ] ] == Flash Fire ) && ( %atk == Fire ) ) {
    set %FlashFireBoost. [ $+ [ %opponent ] ] 1
    mesg %chan %opponent $+ 's $TypeColor(%opponent) boosted its Fire moves with Flash Fire!
    return
  }
  if ( $gettok($Move(%move. [ $+ [ %plr ] ]),2,32) == Status ) Side %plr %effect
  else {
    var %weakness = $calc( $Effective(%atk,%def1) * $Effective(%atk,%def2) )
    if ( ( %atk == Ground ) && ( ( %ability. [ $+ [ %opponent ] ] == Levitate ) || ( ( %item. [ $+ [ %opponent ] ] == Air Balloon ) && ( !%popped. [ $+ [ %opponent ] ] ) ) ) ) var %weakness = 0
    if ( ( $gettok($Move(%move. [ $+ [ %plr ] ]),3,32) == OHKO ) && ( %weakness != 0 ) ) var %damage = 9001
    else {
      var %BasePower = $gettok($Move(%move. [ $+ [ %plr ] ]),3,32)
      if ( $istok(%effect,HiddenPower,32) ) var %BasePower = $HiddenPower(%IVs. [ $+ [ %plr ] ]).power
      if ( %Pursuit. [ $+ [ %plr ] ] ) var %BasePower = 80
      if ( ( $istok(%effect,payback,32) ) && ( $GetStat(%plr).spe < $GetStat(%opponent).spe ) && ( !%switch. [ $+ [ %opponent ] ] ) ) {
        var %BasePower = $int($calc(2 * %BasePower))
        mesg %chan DEBUG: Payback upto %BasePower power.
      }
      if ( $istok(%effect,trip,32) ) var %BasePower = $trip(%poke. [ $+ [ %opponent ] ])
      if ( ( %ability. [ $+ [ %plr ] ] == Technician ) && ( %BasePower <= 60 ) ) var %BasePower = $int($calc( 1.5 * %BasePower ))
      if ( ( %ability. [ $+ [ %plr ] ] == Torrent ) && ( %atk == Water ) && ( $gettok(%curHP. [ $+ [ %plr ] ],%slot. [ $+ [ %plr ] ],32) <= $int($calc( $GetStat(%plr).hp / 3 )) ) ) var %BasePower = $int($calc( 1.5 * %BasePower ))
      if ( ( %ability. [ $+ [ %plr ] ] == Blaze ) && ( %atk == Fire ) && ( $gettok(%curHP. [ $+ [ %plr ] ],%slot. [ $+ [ %plr ] ],32) <= $int($calc( $GetStat(%plr).hp / 3 )) ) ) var %BasePower = $int($calc( 1.5 * %BasePower ))
      if ( ( %ability. [ $+ [ %plr ] ] == Overgrow ) && ( %atk == Grass ) && ( $gettok(%curHP. [ $+ [ %plr ] ],%slot. [ $+ [ %plr ] ],32) <= $int($calc( $GetStat(%plr).hp / 3 )) ) ) var %BasePower = $int($calc( 1.5 * %BasePower ))
      if ( ( %ability. [ $+ [ %plr ] ] == Swarm ) && ( %atk == Bug ) && ( $gettok(%curHP. [ $+ [ %plr ] ],%slot. [ $+ [ %plr ] ],32) <= $int($calc( $GetStat(%plr).hp / 3 )) ) ) var %BasePower = $int($calc( 1.5 * %BasePower ))
      if ( $istok(%effect,speeddif,32) ) {
        var %BasePower = $int($calc( 25 * ( $GetStat(%opponent).spe / $GetStat(%plr).spe ) ))
        if ( %BasePower < 1 ) var %BasePower = 1
        if ( %BasePower > 150 ) var %BasePower = 150
      }
      if ( ( %item. [ $+ [ %plr ] ] == Lustrous Orb ) && ( %poke. [ $+ [ %plr ] ] == Palkia ) && ( ( %atk == Water ) || ( %atk == Dragon ) ) ) var %BasePower = $int($calc( 1.2 * %BasePower ))

      ;^^^Base Power mods here

      if ( $gettok($Move(%move. [ $+ [ %plr ] ]),2,32) == Physical ) {
        var %Attack = $GetStat(%plr).atk
        if ( $regex(%ability. [ $+ [ %plr ] ],/(Huge|Pure) Power/i) ) var %Attack = $int($calc( 2 * %Attack ))
        if ( %item. [ $+ [ %plr ] ] == Choice Band ) var %Attack = $int($calc( 1.5 * %Attack ))
        var %Defense = $GetStat(%opponent).def
      }
      elseif ( $gettok($Move(%move. [ $+ [ %plr ] ]),2,32) == Special ) {
        var %Attack = $GetStat(%plr).spa
        if ( %item. [ $+ [ %plr ] ] == Choice Specs ) var %Attack = $int($calc( 1.5 * %Attack ))
        var %Defense = $GetStat(%opponent).spd
        if ( ( %weather == Sandstorm ) && ( $istok(%types. [ $+ [ %opponent ] ],Rock,32) ) ) var %Defense = $int($calc( 1.5 * %Defense ))
      }
      if ( ( $gettok($Move(%move. [ $+ [ %plr ] ]),2,32) == Physical ) && ( $istok(%status. [ $+ [ %plr ] $+ [ %slot. [ $+ [ %plr ] ] ] ],Burn,32) ) ) var %BRN = 0.5
      else var %BRN = 1
      if ( ( ( $gettok($Move(%move. [ $+ [ %plr ] ]),2,32) == Physical ) && ( $istok(%field. [ $+ [ %opponent ] ],Reflect,32) ) ) || $&
        ( ( $gettok($Move(%move. [ $+ [ %plr ] ]),2,32) == Special ) && ( $istok(%field. [ $+ [ %opponent ] ],LightScreen,32) ) ) ) var %RL = 0.5
      else var %RL = 1
      if ( %atk == Fire ) {
        if ( %weather == Sun ) var %SR = 1.5
        elseif ( %weather == Rain ) var %SR = 0.5
        else var %SR = 1
      }
      elseif ( %atk == Water ) {
        if ( %weather == Sun ) var %SR = 0.5
        elseif ( %weather == Rain ) var %SR = 1.5
        else var %SR = 1
      }
      else var %SR = 1
      if ( ( %atk == Fire ) && ( %FlashFireBoost. [ $+ [ %plr ] ] ) ) var %FF = 1.5
      else var %FF = 1
      var %Mod1 = $calc( %BRN * %RL * %SR * %FF )
      if ( ( %item. [ $+ [ %plr ] ] == Life Orb ) && ( %move. [ $+ [ %plr ] ] == Me First ) ) {
        var %Mod2 = 1.95
        set %LOdamage. [ $+ [ %plr ] ] 1
      }
      elseif ( %item. [ $+ [ %plr ] ] == Life Orb ) {
        var %Mod2 = 1.3
        set %LOdamage. [ $+ [ %plr ] ] 1
      }
      elseif ( %move. [ $+ [ %plr ] ] == Me First ) var %Mod2 = 1.5
      else var %Mod2 = 1
      var %R = $int($calc( ( $rand(217,255) * 100 ) / 255 ))
      if ( $istok(%types. [ $+ [ %plr ] ],%atk,32) ) var %STAB = $iif(%ability. [ $+ [ %plr ] ] == Adaptability,2,1.5)
      else var %STAB = 1
      ; Mod3 involves abilities and held items, so adjust if added.
      if ( ( %item. [ $+ [ %plr ] ] == Expert Belt ) && ( %weakness >= 2 ) ) var %EB = 1.2
      else var %EB = 1
      if ( ( %atk == $SuperBerry(%item. [ $+ [ %opponent ] ]) ) && ( %weakness > 1 ) ) var %TRB = 0.5
      elseif ( %atk == $SuperBerry(%item. [ $+ [ %opponent ] ] ) && ( %atk == Normal ) ) var %TRB = 0.5
      else var %TRB = 1
      var %Mod3 = $calc( %EB * %TRB )
      if ( $istok(%effect,setdamage,32) ) {
        var %damage = %BasePower
        if ( %weakness != 0 ) var %weakness = 1
      }
      elseif ( $istok(%effect,counter,32) ) {
        var %area = $findtok(%effect,counter,1,32)
        var %cat = $gettok(%effect,$calc( %area + 1 ),32)
        if ( ( !%switch. [ $+ [ %opponent ] ] ) && ( ( %cat == All ) || ( %cat == $gettok($Move(%move. [ $+ [ %opponent ] ]),2,32) ) ) ) var %damage = $int($calc( 2 * %damage. [ $+ [ %plr ] ] ))
        else {
          mesg %chan But it failed!
          return
        }
      }
      else var %damage = $Damage(%BasePower,%Attack,%Defense,%Mod1,%crit,%Mod2,%R,%STAB,%weakness,%Mod3)
      if (%ability. [ $+ [ %plr ] ] == Multiscale && $GetStat(%opponent).hp == $gettok(%curHP. [ $+ [ %opponent ] ],%slot. [ $+ [ %opponent ] ],32)) {
        mesg %chan DEBUG: Damage before Multiscale: %damage $+ .
        var %damage = $int($calc(%damage / 2))
        mesg %chan DEBUG: Damage after Multiscale: %damage $+ .
      }
      set %damage. [ $+ [ %opponent ] ] %damage
      ; $1: Base Power  $2: [Sp]Atk  $3: [Sp]Def  $4: Mod1  $5: CH  $6: Mod2  $7: R  $8: STAB  $9: Type1&2  $10: Mod3
      if ( ( %item. [ $+ [ %plr ] ] == Sharp Beak ) && ( %atk == Flying ) ) var %damage = $int($calc( 1.2 * %damage ))
      if ( ( $istok(%effect,endeavor,32) ) && ( $gettok(%curHP. [ $+ [ %opponent ] ],%slot. [ $+ [ %opponent ] ],32) > $gettok(%curHP. [ $+ [ %plr ] ],%slot. [ $+ [ %plr ] ],32) ) ) var %damage = $&
        $calc( $gettok(%curHP. [ $+ [ %opponent ] ],%slot. [ $+ [ %opponent ] ],32) - $gettok(%curHP. [ $+ [ %plr ] ],%slot. [ $+ [ %plr ] ],32) )
      elseif ( $istok(%effect,endeavor,32) ) var %endeavorfail = 1
      if ( %damage == 0 ) var %damage = 1
      if ( $calc( $gettok(%curHP. [ $+ [ %opponent ] ],%slot. [ $+ [ %opponent ] ],32) - %damage ) < 1 ) var %realdamage = $gettok(%curHP. [ $+ [ %opponent ] ],%slot. [ $+ [ %opponent ] ],32)
    }
    if ( ( %weakness != 0 ) && ( !%endeavorfail ) ) {
      if ( $istok(%status. [ $+ [ %opponent ] $+ [ %slot. [ $+ [ %opponent ] ] ] ],Substitute,32) ) {
        TakeDamage %opponent Substitute %damage
        unset %LOdamage. [ $+ [ %plr ] ]
        mesg %chan The Substitute took damage for %opponent $+ 's $TypeColor(%opponent) $+ !
        if ( %subHP. [ $+ [ %opponent ] ] < 1 ) {
          mesg %chan %opponent $+ 's $TypeColor(%opponent) $+ 's Substitute faded!
          unset %subHP. [ $+ [ %opponent ] ]
          GetStatus -l Substitute %opponent
        }
      }
      else {
        TakeDamage %opponent %damage
        if ( %TRB < 1 ) {
          mesg %chan %opponent $+ 's $TypeColor(%opponent) $+ 's %item. [ $+ [ %opponent ] ] reduced %move. [ $+ [ %plr ] ] $+ 's power!
          set %itemused. [ $+ [ %opponent ] $+ [ %slot. [ $+ [ %opponent ] ] ] ] 1
          unset %item. [ $+ [ %opponent ] ]
        }
        mesg %chan %opponent $+ 's $TypeColor(%opponent) took %damage damage! $+($chr(40),$round($calc( 100 * %damage / $GetStat(%opponent).hp ),1),$chr(37),$chr(41))
        if ( ( %item. [ $+ [ %opponent ] ] == Air Balloon ) && ( !%popped. [ $+ [ %opponent ] ] ) ) {
          set %popped. [ $+ [ %opponent ] ] 1
          mesg %chan %opponent $+ 's $TypeColor(%opponent) $+ 's Air Balloon popped!
        }
        if ( %item. [ $+ [ %plr ] ] == Shell Bell ) {
          var %heal = $calc( -1 * ( %damage / 8 ) )
          TakeDamage %plr %heal
          mesg %chan %plr $+ 's $TypeColor(%plr) restored some HP with its Shell Bell!
        }
        if ( $istok(%effect,leech,32) ) {
          var %heal = $calc( -1 * ( %damage / 2 ) )
          if ( %item. [ $+ [ %plr ] ] == Big Root ) var %heal = $calc( 1.3 * %heal )
          if ( %ability. [ $+ [ %opponent ] ] == Liquid Ooze ) {
            var %heal = $calc( -1 * %heal )
            TakeDamage %plr %heal
            mesg %chan %plr $+ 's $TypeColor(%plr) was hurt by $TypeColor(%opponent) $+ 's Liquid Ooze!
          }
          else {
            TakeDamage %plr %heal
            mesg %chan %plr $+ 's $TypeColor(%plr) absorbed the foe's HP!
          }
        }
      }
    }
    if ( %realdamage != $null ) var %damage = %realdamage
    if ( %weakness == 0 ) mesg %chan It doesn't affect $TypeColor(%opponent) $+ ...
    elseif ( %endeavorfail ) mesg %chan But it failed!
    elseif ( $gettok($Move(%move. [ $+ [ %plr ] ]),3,32) == OHKO ) mesg %chan 'Tis over 9000!!!
    else {
      if ( %crit >= 2 ) mesg %chan A critical hit!
      if ( %weakness >= 2 ) mesg %chan 'Tis super effective!
      if ( %weakness <= 0.5 ) mesg %chan 'Tis not very effective...
      if ( ( %ability. [ $+ [ %opponent ] ] == Illusion ) && ( %Illusion. [ $+ [ %opponent ] ] ) ) {
        unset %Illusion. [ $+ [ %opponent ] ]
        mesg %chan %opponent $+ 's $TypeColor(%opponent).real $+ 's Illusion wore off!
      }
    }
    if ( $istok(%effect,recoil,32) ) {
      var %area = $findtok(%effect,recoil,1,32)
      var %percent = $gettok(%effect,$calc( %area + 1 ),32)
      var %damage = $int($calc( %percent * %damage ))
      TakeDamage %plr %damage
      mesg %chan %plr $+ 's $TypeColor(%plr) was hit with recoil!
    }
    if ( %weakness == 0 ) unset %LOdamage. [ $+ [ %plr ] ]
    if ( ( $gettok($Move(%move. [ $+ [ %plr ] ]),6,32) != $null ) && ( %weakness != 0 ) ) Side %plr %effect
  }
  if ( %LOdamage. [ $+ [ %plr ] ] ) {
    unset %LOdamage. [ $+ [ %plr ] ]
    var %damage = $int($calc( 0.1 * $GetStat(%plr).hp ))
    TakeDamage %plr %damage
    mesg %chan %plr $+ 's $TypeColor(%plr) was hurt by its Life Orb!
  }
  if ( $gettok(%curHP. [ $+ [ %opponent ] ],%slot. [ $+ [ %opponent ] ],32) < 1 ) {
    set %dead. [ $+ [ %opponent ] ] 1
    set %fainted. [ $+ [ %opponent ] ] $addtok(%fainted. [ $+ [ %opponent ] ],%slot. [ $+ [ %opponent ] ],32)
    mesg %chan %opponent $+ 's $TypeColor(%opponent) fainted! Score: $Score(%plr)
  }
  if ( $gettok(%curHP. [ $+ [ %plr ] ],%slot. [ $+ [ %plr ] ],32) < 1 ) {
    set %dead. [ $+ [ %plr ] ] 1
    set %fainted. [ $+ [ %plr ] ] $addtok(%fainted. [ $+ [ %plr ] ],%slot. [ $+ [ %plr ] ],32)
    mesg %chan %plr $+ 's $TypeColor(%plr) fainted! Score: $Score(%opponent)
  }
}
alias -l EndOfTurn {
  var %plr = $1
  var %opponent = $2

  ; All the stuff like leftovers recovery and burn damage here

  if ( %wish. [ $+ [ %plr ] ] ) {
    var %damage = $int($calc( -0.5 * $GetStat(%plr).hp ))
    TakeDamage %plr %damage
    mesg %chan %plr $+ 's %wishmsg. [ $+ [ %plr ] ] $+ 's wish came true!
    unset %wish. [ $+ [ %plr ] ]
    unset %wishmsg. [ $+ [ %plr ] ]
  }
  if ( %weather != $null ) {
    if ( %durationWeather <= 0 ) {
      if ( %weather == Sun ) var %msg = The sunlight faded.
      if ( %weather == Rain ) var %msg = The rain stopped.
      if ( %weather == Sandstorm ) var %msg = The sandstorm subsided.
      if ( %weather == Hail ) var %msg = The hail stopped.
      unset %weather
      unset %durationWeather
      mesg %chan %msg
      if ( %dead. [ $+ [ %plr ] ] ) return
    }
    else {
      if ( ( %weather == Sandstorm ) && ( !$istok(%types. [ $+ [ %plr ] ],Ground,32) ) && $&
        ( !$istok(%types. [ $+ [ %plr ] ],Rock,32) ) && ( !$istok(%types. [ $+ [ %plr ] ],Steel,32) ) ) {
        ; Also add abilities to list of SS damage immunities.
        var %damage = $int($calc( 0.0625 * $GetStat(%plr).hp ))
        TakeDamage %plr %damage
        mesg %chan %plr $+ 's $TypeColor(%plr) was buffeted by the sandstorm!
      }
      elseif ( ( %weather == Hail ) && ( !$istok(%types. [ $+ [ %plr ] ],Ice,32) ) ) {
        ; Also add abilities to list of Hail damage immunities.
        var %damage = $int($calc( 0.0625 * $GetStat(%plr).hp ))
        TakeDamage %plr %damage
        mesg %chan %plr $+ 's $TypeColor(%plr) was buffeted by the hail!
      }
    }
  }
  if ( %dead. [ $+ [ %plr ] ] ) return
  if ( ( %item. [ $+ [ %plr ] ] == Leftovers ) && ( $gettok(%curHP. [ $+ [ %plr ] ],%slot. [ $+ [ %plr ] ],32) < $GetStat(%plr).hp ) ) {
    var %damage = $int($calc( $GetStat(%plr).hp * -1 / 16 ))
    TakeDamage %plr %damage
    mesg %chan %plr $+ 's $TypeColor(%plr) restored a little HP using its Leftovers!
  }
  if ( $istok(%status. [ $+ [ %plr ] $+ [ %slot. [ $+ [ %plr ] ] ] ],Burn,32) ) {
    var %damage = $int($calc( 0.125 * $GetStat(%plr).hp ))
    if ( %poke. [ $+ [ %plr ] ] == Shedinja ) set %curHP. [ $+ [ %plr ] ] $puttok(%curHP. [ $+ [ %plr ] ],0,%slot. [ $+ [ %plr ] ],32)
    else TakeDamage %plr %damage
    mesg %chan %plr $+ 's $TypeColor(%plr) was hurt by its 4burn!
  }
  if ( $istok(%status. [ $+ [ %plr ] $+ [ %slot. [ $+ [ %plr ] ] ] ],Poison,32) ) {
    var %damage = $int($calc( 0.125 * $GetStat(%plr).hp ))
    if ( %poke. [ $+ [ %plr ] ] == Shedinja ) set %curHP. [ $+ [ %plr ] ] $puttok(%curHP. [ $+ [ %plr ] ],0,%slot. [ $+ [ %plr ] ],32)
    else TakeDamage %plr %damage
    mesg %chan %plr $+ 's $TypeColor(%plr) was hurt by its 6poison!
  }
  if ( $istok(%status. [ $+ [ %plr ] $+ [ %slot. [ $+ [ %plr ] ] ] ],Toxic,32) ) {
    var %damage = $int($calc( 0.0625 * $GetStat(%plr).hp * %durationToxic. [ $+ [ %plr ] $+ [ %slot. [ $+ [ %plr ] ] ] ] ))
    if ( %poke. [ $+ [ %plr ] ] == Shedinja ) set %curHP. [ $+ [ %plr ] ] $puttok(%curHP. [ $+ [ %plr ] ],0,%slot. [ $+ [ %plr ] ],32)
    elseif ( %durationToxic. [ $+ [ %plr ] $+ [ %slot. [ $+ [ %plr ] ] ] ] >= 16 ) var %damage = $int($calc( 0.9375 * $GetStat(%plr).hp ))
    TakeDamage %plr %damage
    mesg %chan %plr $+ 's $TypeColor(%plr) was hurt by its 6poison!
  }
  if ( %Seed. [ $+ [ %plr ] ] ) {
    var %damage = $int($calc( 0.125 * $GetStat(%plr).hp ))
    if ( %damage == 0 ) var %damage = 1
    TakeDamage %plr %damage
    if ( !%dead. [ $+ [ %opponent ] ] ) TakeDamage %opponent $calc( -1 * %damage )
    mesg %chan %plr $+ 's $TypeColor(%plr) $+ 's health was sapped by Leech Seed!
  }
  if ( %ability. [ $+ [ %plr ] ] == Speed Boost ) BoostStat %plr Spe 1

  ;Rest of end of turn stuff

  if ( ( $istok(%field. [ $+ [ %plr ] ],Reflect,32) ) && ( %durationReflect. [ $+ [ %plr ] ] <= 0 ) ) {
    unset %durationReflect. [ $+ [ %plr ] ]
    set %field. [ $+ [ %plr ] ] $remtok(%field. [ $+ [ %plr ] ],Reflect,1,32)
    mesg %chan %plr $+ 's Reflect wore off!
  }
  if ( ( $istok(%field. [ $+ [ %plr ] ],LightScreen,32) ) && ( %durationLS. [ $+ [ %plr ] ] <= 0 ) ) {
    unset %durationLS. [ $+ [ %plr ] ]
    set %field. [ $+ [ %plr ] ] $remtok(%field. [ $+ [ %plr ] ],LightScreen,1,32)
    mesg %chan %plr $+ 's Light Screen wore off!
  }
  if ( $gettok(%curHP. [ $+ [ %plr ] ],%slot. [ $+ [ %plr ] ],32) < 1 ) {
    set %dead. [ $+ [ %plr ] ] 1
    set %fainted. [ $+ [ %plr ] ] $addtok(%fainted. [ $+ [ %plr ] ],%slot. [ $+ [ %plr ] ],32)
    mesg %chan %plr $+ 's $TypeColor(%plr) fainted! Score: $Score(%opponent)
  }
  if ( ( %item. [ $+ [ %plr ] ] != Choice Band ) && ( %item. [ $+ [ %plr ] ] != Choice Specs ) && $&
    ( %item. [ $+ [ %plr ] ] != Choice Scarf ) && ( %lockmove. [ $+ [ %plr ] ] != $null ) ) unset %lockmove. [ $+ [ %plr ] ]
  if ( %wish. [ $+ [ %plr ] ] == 0 ) set %wish. [ $+ [ %plr ] ] 1
  unset %STalk. [ $+ [ %plr ] ]
  unset %Pursuit. [ $+ [ %plr ] ]
  if ( %Rampage. [ $+ [ %plr ] ] != $null ) {
    dec %Rampage. [ $+ [ %plr ] ] 1
    mesg %chan DEBUG: Decrease rampage duration to %Rampage. [ $+ [ %plr ] ] $+ .
    if ( %Rampage. [ $+ [ %plr ] ] <= 0 ) {
      GetStatus Confuse %plr
      mesg %chan %plr $+ 's $TypeColor(%plr) became confused due to fatigue!
      set %durationConfuse. [ $+ [ %plr ] ] $rand(1,4)
      unset %Rampage. [ $+ [ %plr ] ]
      unset %RampageMove. [ $+ [ %plr ] ]
    }
  }
  if ( %durationConfuse. [ $+ [ %plr ] ] != $null ) dec %durationConfuse. [ $+ [ %plr ] ] 1
  if ( %durationTaunt. [ $+ [ %plr ] ] != $null ) dec %durationTaunt. [ $+ [ %plr ] ] 1
  if ( %durationToxic. [ $+ [ %plr ] $+ [ %slot. [ $+ [ %plr ] ] ] ] != $null ) inc %durationToxic. [ $+ [ %plr ] $+ [ %slot. [ $+ [ %plr ] ] ] ] 1
  if ( %durationSleep. [ $+ [ %plr ] $+ [ %slot. [ $+ [ %plr ] ] ] ] != $null ) dec %durationSleep. [ $+ [ %plr ] $+ [ %slot. [ $+ [ %plr ] ] ] ] 1
  if ( %durationReflect. [ $+ [ %plr ] ] != $null ) dec %durationReflect. [ $+ [ %plr ] ] 1
  if ( %durationLS. [ $+ [ %plr ] ] != $null ) dec %durationLS. [ $+ [ %plr ] ] 1
}
alias -l DisruptRampage {
  if (%Rampage. [ $+ [ $1 ] ] == 1) {
    GetStatus Confuse $1
    mesg %chan $1 $+ 's $TypeColor($1) became confused due to fatigue!
    set %durationConfuse. [ $+ [ %plr ] ] $rand(1,4)
  }
  unset %Rampage. [ $+ [ $1 ] ]
  unset %RampageMove. [ $+ [ $1 ] ]
}
alias -l Effective {
  var %atk = $1
  var %def = $2
  if ( %def == $null ) return 1
  if ( %atk == Normal ) {
    if ( %def == Normal ) return 1
    if ( %def == Fighting ) return 1
    if ( %def == Flying ) return 1
    if ( %def == Poison ) return 1
    if ( %def == Ground ) return 1
    if ( %def == Rock ) return 0.5
    if ( %def == Bug ) return 1
    if ( %def == Ghost ) return 0
    if ( %def == Steel ) return 0.5
    if ( %def == Fire ) return 1
    if ( %def == Water ) return 1
    if ( %def == Grass ) return 1
    if ( %def == Electric ) return 1
    if ( %def == Psychic ) return 1
    if ( %def == Ice ) return 1
    if ( %def == Dragon ) return 1
    if ( %def == Dark ) return 1
  }
  if ( %atk == Fighting ) {
    if ( %def == Normal ) return 2
    if ( %def == Fighting ) return 1
    if ( %def == Flying ) return 0.5
    if ( %def == Poison ) return 0.5
    if ( %def == Ground ) return 1
    if ( %def == Rock ) return 2
    if ( %def == Bug ) return 0.5
    if ( %def == Ghost ) return 0
    if ( %def == Steel ) return 2
    if ( %def == Fire ) return 1
    if ( %def == Water ) return 1
    if ( %def == Grass ) return 1
    if ( %def == Electric ) return 1
    if ( %def == Psychic ) return 0.5
    if ( %def == Ice ) return 2
    if ( %def == Dragon ) return 1
    if ( %def == Dark ) return 2
  }
  if ( %atk == Flying ) {
    if ( %def == Normal ) return 1
    if ( %def == Fighting ) return 2
    if ( %def == Flying ) return 1
    if ( %def == Poison ) return 1
    if ( %def == Ground ) return 1
    if ( %def == Rock ) return 0.5
    if ( %def == Bug ) return 2
    if ( %def == Ghost ) return 1
    if ( %def == Steel ) return 0.5
    if ( %def == Fire ) return 1
    if ( %def == Water ) return 1
    if ( %def == Grass ) return 2
    if ( %def == Electric ) return 0.5
    if ( %def == Psychic ) return 1
    if ( %def == Ice ) return 1
    if ( %def == Dragon ) return 1
    if ( %def == Dark ) return 1
  }
  if ( %atk == Poison ) {
    if ( %def == Normal ) return 1
    if ( %def == Fighting ) return 1
    if ( %def == Flying ) return 1
    if ( %def == Poison ) return 0.5
    if ( %def == Ground ) return 0.5
    if ( %def == Rock ) return 0.5
    if ( %def == Bug ) return 1
    if ( %def == Ghost ) return 0.5
    if ( %def == Steel ) return 0
    if ( %def == Fire ) return 1
    if ( %def == Water ) return 1
    if ( %def == Grass ) return 2
    if ( %def == Electric ) return 1
    if ( %def == Psychic ) return 1
    if ( %def == Ice ) return 1
    if ( %def == Dragon ) return 1
    if ( %def == Dark ) return 1
  }
  if ( %atk == Ground ) {
    if ( %def == Normal ) return 1
    if ( %def == Fighting ) return 1
    if ( %def == Flying ) return 0
    if ( %def == Poison ) return 2
    if ( %def == Ground ) return 1
    if ( %def == Rock ) return 2
    if ( %def == Bug ) return 0.5
    if ( %def == Ghost ) return 1
    if ( %def == Steel ) return 2
    if ( %def == Fire ) return 2
    if ( %def == Water ) return 1
    if ( %def == Grass ) return 0.5
    if ( %def == Electric ) return 2
    if ( %def == Psychic ) return 1
    if ( %def == Ice ) return 1
    if ( %def == Dragon ) return 1
    if ( %def == Dark ) return 1
  }
  if ( %atk == Rock ) {
    if ( %def == Normal ) return 1
    if ( %def == Fighting ) return 0.5
    if ( %def == Flying ) return 2
    if ( %def == Poison ) return 1
    if ( %def == Ground ) return 0.5
    if ( %def == Rock ) return 1
    if ( %def == Bug ) return 2
    if ( %def == Ghost ) return 1
    if ( %def == Steel ) return 0.5
    if ( %def == Fire ) return 2
    if ( %def == Water ) return 1
    if ( %def == Grass ) return 1
    if ( %def == Electric ) return 1
    if ( %def == Psychic ) return 1
    if ( %def == Ice ) return 2
    if ( %def == Dragon ) return 1
    if ( %def == Dark ) return 1
  }
  if ( %atk == Bug ) {
    if ( %def == Normal ) return 1
    if ( %def == Fighting ) return 0.5
    if ( %def == Flying ) return 0.5
    if ( %def == Poison ) return 0.5
    if ( %def == Ground ) return 1
    if ( %def == Rock ) return 1
    if ( %def == Bug ) return 1
    if ( %def == Ghost ) return 0.5
    if ( %def == Steel ) return 0.5
    if ( %def == Fire ) return 0.5
    if ( %def == Water ) return 1
    if ( %def == Grass ) return 2
    if ( %def == Electric ) return 1
    if ( %def == Psychic ) return 2
    if ( %def == Ice ) return 1
    if ( %def == Dragon ) return 1
    if ( %def == Dark ) return 2
  }
  if ( %atk == Ghost ) {
    if ( %def == Normal ) return 0
    if ( %def == Fighting ) return 1
    if ( %def == Flying ) return 1
    if ( %def == Poison ) return 1
    if ( %def == Ground ) return 1
    if ( %def == Rock ) return 1
    if ( %def == Bug ) return 1
    if ( %def == Ghost ) return 2
    if ( %def == Steel ) return 0.5
    if ( %def == Fire ) return 1
    if ( %def == Water ) return 1
    if ( %def == Grass ) return 1
    if ( %def == Electric ) return 1
    if ( %def == Psychic ) return 2
    if ( %def == Ice ) return 1
    if ( %def == Dragon ) return 1
    if ( %def == Dark ) return 0.5
  }
  if ( %atk == Steel ) {
    if ( %def == Normal ) return 1
    if ( %def == Fighting ) return 1
    if ( %def == Flying ) return 1
    if ( %def == Poison ) return 1
    if ( %def == Ground ) return 1
    if ( %def == Rock ) return 2
    if ( %def == Bug ) return 1
    if ( %def == Ghost ) return 1
    if ( %def == Steel ) return 0.5
    if ( %def == Fire ) return 0.5
    if ( %def == Water ) return 0.5
    if ( %def == Grass ) return 1
    if ( %def == Electric ) return 0.5
    if ( %def == Psychic ) return 1
    if ( %def == Ice ) return 2
    if ( %def == Dragon ) return 1
    if ( %def == Dark ) return 1
  }
  if ( %atk == Fire ) {
    if ( %def == Normal ) return 1
    if ( %def == Fighting ) return 1
    if ( %def == Flying ) return 1
    if ( %def == Poison ) return 1
    if ( %def == Ground ) return 1
    if ( %def == Rock ) return 0.5
    if ( %def == Bug ) return 2
    if ( %def == Ghost ) return 1
    if ( %def == Steel ) return 2
    if ( %def == Fire ) return 0.5
    if ( %def == Water ) return 0.5
    if ( %def == Grass ) return 2
    if ( %def == Electric ) return 1
    if ( %def == Psychic ) return 1
    if ( %def == Ice ) return 2
    if ( %def == Dragon ) return 0.5
    if ( %def == Dark ) return 1
  }
  if ( %atk == Water ) {
    if ( %def == Normal ) return 1
    if ( %def == Fighting ) return 1
    if ( %def == Flying ) return 1
    if ( %def == Poison ) return 1
    if ( %def == Ground ) return 2
    if ( %def == Rock ) return 2
    if ( %def == Bug ) return 1
    if ( %def == Ghost ) return 1
    if ( %def == Steel ) return 1
    if ( %def == Fire ) return 2
    if ( %def == Water ) return 0.5
    if ( %def == Grass ) return 0.5
    if ( %def == Electric ) return 1
    if ( %def == Psychic ) return 1
    if ( %def == Ice ) return 1
    if ( %def == Dragon ) return 0.5
    if ( %def == Dark ) return 1
  }
  if ( %atk == Grass ) {
    if ( %def == Normal ) return 1
    if ( %def == Fighting ) return 1
    if ( %def == Flying ) return 0.5
    if ( %def == Poison ) return 0.5
    if ( %def == Ground ) return 2
    if ( %def == Rock ) return 2
    if ( %def == Bug ) return 0.5
    if ( %def == Ghost ) return 1
    if ( %def == Steel ) return 0.5
    if ( %def == Fire ) return 0.5
    if ( %def == Water ) return 2
    if ( %def == Grass ) return 0.5
    if ( %def == Electric ) return 1
    if ( %def == Psychic ) return 1
    if ( %def == Ice ) return 1
    if ( %def == Dragon ) return 0.5
    if ( %def == Dark ) return 1
  }
  if ( %atk == Electric ) {
    if ( %def == Normal ) return 1
    if ( %def == Fighting ) return 1
    if ( %def == Flying ) return 2
    if ( %def == Poison ) return 1
    if ( %def == Ground ) return 0
    if ( %def == Rock ) return 1
    if ( %def == Bug ) return 1
    if ( %def == Ghost ) return 1
    if ( %def == Steel ) return 1
    if ( %def == Fire ) return 1
    if ( %def == Water ) return 2
    if ( %def == Grass ) return 0.5
    if ( %def == Electric ) return 0.5
    if ( %def == Psychic ) return 1
    if ( %def == Ice ) return 1
    if ( %def == Dragon ) return 0.5
    if ( %def == Dark ) return 1
  }
  if ( %atk == Psychic ) {
    if ( %def == Normal ) return 1
    if ( %def == Fighting ) return 2
    if ( %def == Flying ) return 1
    if ( %def == Poison ) return 2
    if ( %def == Ground ) return 1
    if ( %def == Rock ) return 1
    if ( %def == Bug ) return 1
    if ( %def == Ghost ) return 1
    if ( %def == Steel ) return 0.5
    if ( %def == Fire ) return 1
    if ( %def == Water ) return 1
    if ( %def == Grass ) return 1
    if ( %def == Electric ) return 1
    if ( %def == Psychic ) return 0.5
    if ( %def == Ice ) return 1
    if ( %def == Dragon ) return 1
    if ( %def == Dark ) return 0
  }
  if ( %atk == Ice ) {
    if ( %def == Normal ) return 1
    if ( %def == Fighting ) return 1
    if ( %def == Flying ) return 2
    if ( %def == Poison ) return 1
    if ( %def == Ground ) return 2
    if ( %def == Rock ) return 1
    if ( %def == Bug ) return 1
    if ( %def == Ghost ) return 1
    if ( %def == Steel ) return 0.5
    if ( %def == Fire ) return 0.5
    if ( %def == Water ) return 0.5
    if ( %def == Grass ) return 2
    if ( %def == Electric ) return 1
    if ( %def == Psychic ) return 1
    if ( %def == Ice ) return 0.5
    if ( %def == Dragon ) return 2
    if ( %def == Dark ) return 1
  }
  if ( %atk == Dragon ) {
    if ( %def == Normal ) return 1
    if ( %def == Fighting ) return 1
    if ( %def == Flying ) return 1
    if ( %def == Poison ) return 1
    if ( %def == Ground ) return 1
    if ( %def == Rock ) return 1
    if ( %def == Bug ) return 1
    if ( %def == Ghost ) return 1
    if ( %def == Steel ) return 0.5
    if ( %def == Fire ) return 1
    if ( %def == Water ) return 1
    if ( %def == Grass ) return 1
    if ( %def == Electric ) return 1
    if ( %def == Psychic ) return 1
    if ( %def == Ice ) return 1
    if ( %def == Dragon ) return 2
    if ( %def == Dark ) return 1
  }
  if ( %atk == Dark ) {
    if ( %def == Normal ) return 1
    if ( %def == Fighting ) return 0.5
    if ( %def == Flying ) return 1
    if ( %def == Poison ) return 1
    if ( %def == Ground ) return 1
    if ( %def == Rock ) return 1
    if ( %def == Bug ) return 1
    if ( %def == Ghost ) return 2
    if ( %def == Steel ) return 0.5
    if ( %def == Fire ) return 1
    if ( %def == Water ) return 1
    if ( %def == Grass ) return 1
    if ( %def == Electric ) return 1
    if ( %def == Psychic ) return 2
    if ( %def == Ice ) return 1
    if ( %def == Dragon ) return 1
    if ( %def == Dark ) return 0.5
  }
  return -1
}
alias -l Side {
  var %plr = $1
  if ( %plr == %plr1 ) var %opponent = %plr2
  if ( %plr == %plr2 ) var %opponent = %plr1
  var %effect = $2-
  if ( $istok(%effect,Atk,32) ) {
    var %area = $findtok(%effect,Atk,1,32)
    var %amount = $gettok(%effect,$calc( %area + 1 ),32)
    var %chance = $gettok(%effect,$calc( %area + 2 ),32)
    if ( %ability. [ $+ [ %plr ] ] == Serene Grace ) var %chance = $int($calc( 2 * %chance ))
    if ( $gettok(%effect,$calc( %area + 3 ),32) == me ) var %player = %plr
    if ( $gettok(%effect,$calc( %area + 3 ),32) == foe ) var %player = %opponent
    if ( $rand(1,100) <= %chance ) BoostStat %player Atk %amount
  }
  if ( $istok(%effect,Def,32) ) {
    var %area = $findtok(%effect,Def,1,32)
    var %amount = $gettok(%effect,$calc( %area + 1 ),32)
    var %chance = $gettok(%effect,$calc( %area + 2 ),32)
    if ( %ability. [ $+ [ %plr ] ] == Serene Grace ) var %chance = $int($calc( 2 * %chance ))
    if ( $gettok(%effect,$calc( %area + 3 ),32) == me ) var %player = %plr
    if ( $gettok(%effect,$calc( %area + 3 ),32) == foe ) var %player = %opponent
    if ( $rand(1,100) <= %chance ) BoostStat %player Def %amount
  }
  if ( $istok(%effect,SpA,32) ) {
    var %area = $findtok(%effect,SpA,1,32)
    var %amount = $gettok(%effect,$calc( %area + 1 ),32)
    var %chance = $gettok(%effect,$calc( %area + 2 ),32)
    if ( %ability. [ $+ [ %plr ] ] == Serene Grace ) var %chance = $int($calc( 2 * %chance ))
    if ( $gettok(%effect,$calc( %area + 3 ),32) == me ) var %player = %plr
    if ( $gettok(%effect,$calc( %area + 3 ),32) == foe ) var %player = %opponent
    if ( $rand(1,100) <= %chance ) BoostStat %player SpA %amount
  }
  if ( $istok(%effect,SpD,32) ) {
    var %area = $findtok(%effect,SpD,1,32)
    var %amount = $gettok(%effect,$calc( %area + 1 ),32)
    var %chance = $gettok(%effect,$calc( %area + 2 ),32)
    if ( %ability. [ $+ [ %plr ] ] == Serene Grace ) var %chance = $int($calc( 2 * %chance ))
    if ( $gettok(%effect,$calc( %area + 3 ),32) == me ) var %player = %plr
    if ( $gettok(%effect,$calc( %area + 3 ),32) == foe ) var %player = %opponent
    if ( $rand(1,100) <= %chance ) BoostStat %player SpD %amount
  }
  if ( $istok(%effect,Spe,32) ) {
    var %area = $findtok(%effect,Spe,1,32)
    var %amount = $gettok(%effect,$calc( %area + 1 ),32)
    var %chance = $gettok(%effect,$calc( %area + 2 ),32)
    if ( %ability. [ $+ [ %plr ] ] == Serene Grace ) var %chance = $int($calc( 2 * %chance ))
    if ( $gettok(%effect,$calc( %area + 3 ),32) == me ) var %player = %plr
    if ( $gettok(%effect,$calc( %area + 3 ),32) == foe ) var %player = %opponent
    if ( $rand(1,100) <= %chance ) BoostStat %player Spe %amount
  }
  if ( $istok(%effect,confuse,32) ) {
    if ( $istok(%status. [ $+ [ %opponent ] $+ [ %slot. [ $+ [ %opponent ] ] ] ],Confuse,32) ) return
    var %area = $findtok(%effect,confuse,1,32)
    var %chance = $gettok(%effect,$calc( %area + 1 ),32)
    if ( %ability. [ $+ [ %plr ] ] == Serene Grace ) var %chance = $int($calc( 2 * %chance ))
    if ( $rand(1,100) <= %chance ) {
      GetStatus Confuse %opponent
      mesg %chan %opponent $+ 's $TypeColor(%opponent) became confused!
      set %durationConfuse. [ $+ [ %opponent ] ] $rand(1,4)
    }
  }
  if ( $istok(%effect,burn,32) ) {
    if ( $istok(%types. [ $+ [ %opponent ] ],Fire,32) ) return
    if ( $istok(%status. [ $+ [ %opponent ] $+ [ %slot. [ $+ [ %opponent ] ] ] ],Burn,32) ) return
    if ( $istok(%status. [ $+ [ %opponent ] $+ [ %slot. [ $+ [ %opponent ] ] ] ],Freeze,32) ) return
    if ( $istok(%status. [ $+ [ %opponent ] $+ [ %slot. [ $+ [ %opponent ] ] ] ],Paralyze,32) ) return
    if ( $istok(%status. [ $+ [ %opponent ] $+ [ %slot. [ $+ [ %opponent ] ] ] ],Poison,32) ) return
    if ( $istok(%status. [ $+ [ %opponent ] $+ [ %slot. [ $+ [ %opponent ] ] ] ],Toxic,32) ) return
    if ( $istok(%status. [ $+ [ %opponent ] $+ [ %slot. [ $+ [ %opponent ] ] ] ],Sleep,32) ) return
    if ( $istok(%status. [ $+ [ %opponent ] $+ [ %slot. [ $+ [ %opponent ] ] ] ],Substitute,32) ) return
    var %area = $findtok(%effect,burn,1,32)
    var %chance = $gettok(%effect,$calc( %area + 1 ),32)
    if ( %ability. [ $+ [ %plr ] ] == Serene Grace ) var %chance = $int($calc( 2 * %chance ))
    if ( $rand(1,100) <= %chance ) {
      GetStatus Burn %opponent
      mesg %chan %opponent $+ 's $TypeColor(%opponent) was 4burned!
    }
  }
  if ( $istok(%effect,freeze,32) ) {
    if ( %weather == Sun ) return
    if ( $istok(%status. [ $+ [ %opponent ] $+ [ %slot. [ $+ [ %opponent ] ] ] ],Burn,32) ) return
    if ( $istok(%status. [ $+ [ %opponent ] $+ [ %slot. [ $+ [ %opponent ] ] ] ],Freeze,32) ) return
    if ( $istok(%status. [ $+ [ %opponent ] $+ [ %slot. [ $+ [ %opponent ] ] ] ],Paralyze,32) ) return
    if ( $istok(%status. [ $+ [ %opponent ] $+ [ %slot. [ $+ [ %opponent ] ] ] ],Poison,32) ) return
    if ( $istok(%status. [ $+ [ %opponent ] $+ [ %slot. [ $+ [ %opponent ] ] ] ],Toxic,32) ) return
    if ( $istok(%status. [ $+ [ %opponent ] $+ [ %slot. [ $+ [ %opponent ] ] ] ],Sleep,32) ) return
    if ( $istok(%status. [ $+ [ %opponent ] $+ [ %slot. [ $+ [ %opponent ] ] ] ],Substitute,32) ) return
    var %area = $findtok(%effect,freeze,1,32)
    var %chance = $gettok(%effect,$calc( %area + 1 ),32)
    if ( %ability. [ $+ [ %plr ] ] == Serene Grace ) var %chance = $int($calc( 2 * %chance ))
    if ( $rand(1,100) <= %chance ) {
      GetStatus Freeze %opponent
      mesg %chan %opponent $+ 's $TypeColor(%opponent) was 11frozen solid!
    }
  }
  if ( $istok(%effect,paralyze,32) ) {
    if ( ( $istok(%types. [ $+ [ %opponent ] ],Ground,32) ) && ( $gettok($Move(%move. [ $+ [ %plr ] ]),1,32) == Electric ) ) return
    if ( $istok(%status. [ $+ [ %opponent ] $+ [ %slot. [ $+ [ %opponent ] ] ] ],Burn,32) ) return
    if ( $istok(%status. [ $+ [ %opponent ] $+ [ %slot. [ $+ [ %opponent ] ] ] ],Freeze,32) ) return
    if ( $istok(%status. [ $+ [ %opponent ] $+ [ %slot. [ $+ [ %opponent ] ] ] ],Paralyze,32) ) return
    if ( $istok(%status. [ $+ [ %opponent ] $+ [ %slot. [ $+ [ %opponent ] ] ] ],Poison,32) ) return
    if ( $istok(%status. [ $+ [ %opponent ] $+ [ %slot. [ $+ [ %opponent ] ] ] ],Toxic,32) ) return
    if ( $istok(%status. [ $+ [ %opponent ] $+ [ %slot. [ $+ [ %opponent ] ] ] ],Sleep,32) ) return
    if ( $istok(%status. [ $+ [ %opponent ] $+ [ %slot. [ $+ [ %opponent ] ] ] ],Substitute,32) ) return
    var %area = $findtok(%effect,paralyze,1,32)
    var %chance = $gettok(%effect,$calc( %area + 1 ),32)
    if ( %ability. [ $+ [ %plr ] ] == Serene Grace ) var %chance = $int($calc( 2 * %chance ))
    if ( $rand(1,100) <= %chance ) {
      GetStatus Paralyze %opponent
      mesg %chan %opponent $+ 's $TypeColor(%opponent) was 8paralyzed!
    }
  }
  if ( $istok(%effect,poison,32) ) {
    if ( ( $istok(%types. [ $+ [ %opponent ] ],Poison,32) ) || ( $istok(%types. [ $+ [ %opponent ] ],Steel,32) ) ) return
    if ( $istok(%status. [ $+ [ %opponent ] $+ [ %slot. [ $+ [ %opponent ] ] ] ],Burn,32) ) return
    if ( $istok(%status. [ $+ [ %opponent ] $+ [ %slot. [ $+ [ %opponent ] ] ] ],Freeze,32) ) return
    if ( $istok(%status. [ $+ [ %opponent ] $+ [ %slot. [ $+ [ %opponent ] ] ] ],Paralyze,32) ) return
    if ( $istok(%status. [ $+ [ %opponent ] $+ [ %slot. [ $+ [ %opponent ] ] ] ],Poison,32) ) return
    if ( $istok(%status. [ $+ [ %opponent ] $+ [ %slot. [ $+ [ %opponent ] ] ] ],Toxic,32) ) return
    if ( $istok(%status. [ $+ [ %opponent ] $+ [ %slot. [ $+ [ %opponent ] ] ] ],Sleep,32) ) return
    if ( $istok(%status. [ $+ [ %opponent ] $+ [ %slot. [ $+ [ %opponent ] ] ] ],Substitute,32) ) return
    var %area = $findtok(%effect,poison,1,32)
    var %chance = $gettok(%effect,$calc( %area + 1 ),32)
    if ( %ability. [ $+ [ %plr ] ] == Serene Grace ) var %chance = $int($calc( 2 * %chance ))
    if ( $rand(1,100) <= %chance ) {
      GetStatus Poison %opponent
      mesg %chan %opponent $+ 's $TypeColor(%opponent) was 6poisoned!
    }
  }
  if ( $istok(%effect,toxic,32) ) {
    if ( ( $istok(%types. [ $+ [ %opponent ] ],Poison,32) ) || ( $istok(%types. [ $+ [ %opponent ] ],Steel,32) ) ) return
    if ( $istok(%status. [ $+ [ %opponent ] $+ [ %slot. [ $+ [ %opponent ] ] ] ],Burn,32) ) return
    if ( $istok(%status. [ $+ [ %opponent ] $+ [ %slot. [ $+ [ %opponent ] ] ] ],Freeze,32) ) return
    if ( $istok(%status. [ $+ [ %opponent ] $+ [ %slot. [ $+ [ %opponent ] ] ] ],Paralyze,32) ) return
    if ( $istok(%status. [ $+ [ %opponent ] $+ [ %slot. [ $+ [ %opponent ] ] ] ],Poison,32) ) return
    if ( $istok(%status. [ $+ [ %opponent ] $+ [ %slot. [ $+ [ %opponent ] ] ] ],Toxic,32) ) return
    if ( $istok(%status. [ $+ [ %opponent ] $+ [ %slot. [ $+ [ %opponent ] ] ] ],Sleep,32) ) return
    if ( $istok(%status. [ $+ [ %opponent ] $+ [ %slot. [ $+ [ %opponent ] ] ] ],Substitute,32) ) return
    var %area = $findtok(%effect,toxic,1,32)
    var %chance = $gettok(%effect,$calc( %area + 1 ),32)
    if ( %ability. [ $+ [ %plr ] ] == Serene Grace ) var %chance = $int($calc( 2 * %chance ))
    if ( $rand(1,100) <= %chance ) {
      GetStatus Toxic %opponent
      mesg %chan %opponent $+ 's $TypeColor(%opponent) was 6badly poisoned!
      set %durationToxic. [ $+ [ %opponent ] $+ [ %slot. [ $+ [ %opponent ] ] ] ] 1
    }
  }
  if ( $istok(%effect,sleep,32) ) {
    if ( $istok(%status. [ $+ [ %opponent ] $+ [ %slot. [ $+ [ %opponent ] ] ] ],Burn,32) ) return
    if ( $istok(%status. [ $+ [ %opponent ] $+ [ %slot. [ $+ [ %opponent ] ] ] ],Freeze,32) ) return
    if ( $istok(%status. [ $+ [ %opponent ] $+ [ %slot. [ $+ [ %opponent ] ] ] ],Paralyze,32) ) return
    if ( $istok(%status. [ $+ [ %opponent ] $+ [ %slot. [ $+ [ %opponent ] ] ] ],Poison,32) ) return
    if ( $istok(%status. [ $+ [ %opponent ] $+ [ %slot. [ $+ [ %opponent ] ] ] ],Toxic,32) ) return
    if ( $istok(%status. [ $+ [ %opponent ] $+ [ %slot. [ $+ [ %opponent ] ] ] ],Sleep,32) ) return
    if ( $istok(%status. [ $+ [ %opponent ] $+ [ %slot. [ $+ [ %opponent ] ] ] ],Substitute,32) ) return
    var %area = $findtok(%effect,sleep,1,32)
    var %chance = $gettok(%effect,$calc( %area + 1 ),32)
    if ( %ability. [ $+ [ %plr ] ] == Serene Grace ) var %chance = $int($calc( 2 * %chance ))
    if ( $rand(1,100) <= %chance ) {
      GetStatus Sleep %opponent
      mesg %chan %opponent $+ 's $TypeColor(%opponent) fell 15asleep!
      set %durationSleep. [ $+ [ %opponent ] $+ [ %slot. [ $+ [ %opponent ] ] ] ] $rand(1,5)
    }
  }
  if ( $istok(%effect,StealthRock,32) ) {
    if ( $istok(StealthRock,%field. [ $+ [ %opponent ] ],32) ) {
      mesg %chan But it failed!
      return
    }
    set %field. [ $+ [ %opponent ] ] $addtok(%field. [ $+ [ %opponent ] ],StealthRock,32)
    mesg %chan Jagged rocks were placed around the opponent's feet!
  }
  if ( $istok(%effect,Spikes,32) ) {
    if ( %SpikesAmount. [ $+ [ %opponent ] ] == 3 ) {
      mesg %chan But it failed!
      return
    }
    set %field. [ $+ [ %opponent ] ] $addtok(%field. [ $+ [ %opponent ] ],Spikes,32)
    if ( %SpikesAmount. [ $+ [ %opponent ] ] == $null ) set %SpikesAmount. [ $+ [ %opponent ] ] 0
    inc %SpikesAmount. [ $+ [ %opponent ] ] 1
    mesg %chan Pointed spikes were placed around the opponent's feet!
  }
  if ( $istok(%effect,ToxicSpikes,32) ) {
    if ( %ToxicSpikesAmount. [ $+ [ %opponent ] ] == 2 ) {
      mesg %chan But it failed!
      return
    }
    set %field. [ $+ [ %opponent ] ] $addtok(%field. [ $+ [ %opponent ] ],ToxicSpikes,32)
    if ( %ToxicSpikesAmount. [ $+ [ %opponent ] ] == $null ) set %ToxicSpikesAmount. [ $+ [ %opponent ] ] 0
    inc %ToxicSpikesAmount. [ $+ [ %opponent ] ] 1
    mesg %chan Poisonous spikes were placed around the opponent's feet!
  }
  if ( $istok(%effect,heal,32) ) {
    if ( $gettok(%curHP. [ $+ [ %plr ] ],%slot. [ $+ [ %plr ] ],32) == $GetStat(%plr).hp ) {
      mesg %chan %plr $+ 's $TypeColor(%plr) $+ 's HP won't go higher!
      return
    }
    var %damage = $int($calc( $GetStat(%plr).hp * -1 / 2 ))
    TakeDamage %plr %damage
    mesg %chan %plr $+ 's $TypeColor(%plr) restored its health!
  }
  if ( $istok(%effect,rest,32) ) {
    if ( ( $gettok(%curHP. [ $+ [ %plr ] ],%slot. [ $+ [ %plr ] ],32) == $GetStat(%plr).hp ) || ( %STalk. [ $+ [ %plr ] ] ) ) {
      mesg %chan But it failed!
      unset %STalk. [ $+ [ %plr ] ]
      return
    }
    var %damage = $calc( -1 * ( $GetStat(%plr).hp - $gettok(%curHP. [ $+ [ %plr ] ],%slot. [ $+ [ %plr ] ],32) ) )
    TakeDamage %plr %damage
    unset %status. [ $+ [ %plr ] $+ [ %slot. [ $+ [ %plr ] ] ] ]
    GetStatus Sleep %plr
    mesg %chan %plr $+ 's $TypeColor(%plr) rested to restore its HP and cure its status problems!
    set %durationSleep. [ $+ [ %plr ] $+ [ %slot. [ $+ [ %plr ] ] ] ] 3
  }
  if ( $istok(%effect,summon,32) ) {
    var %area = $findtok(%effect,summon,1,32)
    var %weath = $gettok(%effect,$calc( %area + 1 ),32)
    var %length = $gettok(%effect,$calc( %area + 2 ),32)
    if ( %weath == Sun ) {
      var %msg = The sunlight intensified!
      if ( %item. [ $+ [ %plr ] ] == Heat Rock ) var %boostweath = 1
    }
    if ( %weath == Rain ) {
      var %msg = It began to rain!
      if ( %item. [ $+ [ %plr ] ] == Damp Rock ) var %boostweath = 1
    }
    if ( %weath == Sandstorm ) {
      var %msg = A sandstorm brewed!
      if ( %item. [ $+ [ %plr ] ] == Smooth Rock ) var %boostweath = 1
    }
    if ( %weath == Hail ) {
      var %msg = It began to hail!
      if ( %item. [ $+ [ %plr ] ] == Icy Rock ) var %boostweath = 1
    }
    mesg %chan %msg
    set %weather %weath
    set %durationWeather $iif(%boostweath,9,$calc( %length + 1 ))
  }
  if ( $istok(%effect,Wish,32) ) {
    if ( %wish. [ $+ [ %plr ] ] != $null ) {
      mesg %chan But it failed!
      return
    }
    mesg %chan %plr $+ 's $TypeColor(%plr) made a wish!
    set %wish. [ $+ [ %plr ] ] 0
    set %wishmsg. [ $+ [ %plr ] ] $TypeColor(%plr)
  }
  if ( $istok(%effect,Taunt,32) ) {
    mesg %chan %opponent $+ 's $TypeColor(%opponent) fell for the taunt!
    GetStatus Taunt %opponent
    set %durationTaunt. [ $+ [ %opponent ] ] $rand(3,5)
  }
  if ( $istok(%effect,Substitute,32) ) {
    if ( $gettok(%curHP. [ $+ [ %plr ] ],%slot. [ $+ [ %plr ] ],32) <= $calc( 0.25 * $GetStat(%plr).hp ) ) {
      mesg %chan It was too weak to make a Substitute!
      return
    }
    var %damage = $int($calc( 0.25 * $GetStat(%plr).hp ))
    TakeDamage %plr %damage
    GetStatus Substitute %plr
    set %subHP. [ $+ [ %plr ] ] %damage
    mesg %chan %plr $+ 's $TypeColor(%plr) made a Substitute!
  }
  if ( $istok(%effect,SwapItem,32) ) {
    var %tempitem = %item. [ $+ [ %plr ] ]
    set %item. [ $+ [ %plr ] ] %item. [ $+ [ %opponent ] ]
    set %item. [ $+ [ %opponent ] ] %tempitem
    set %newitem. [ $+ [ %plr ] $+ [ %slot. [ $+ [ %plr ] ] ] ] %item. [ $+ [ %plr ] ]
    set %newitem. [ $+ [ %opponent ] $+ [ %slot. [ $+ [ %opponent ] ] ] ] %item. [ $+ [ %opponent ] ]
    mesg %chan %plr $+ 's $TypeColor(%plr) swapped items with its opponent!
    mesg %chan %plr $+ 's $TypeColor(%plr) got one %item. [ $+ [ %plr ] ] $+ !
    mesg %chan %opponent $+ 's $TypeColor(%opponent) got one %item. [ $+ [ %opponent ] ] $+ !
  }
  if ($istok(%effect,BatonPass,32)) {
    mesg %chan %plr $+ 's $TypeColor(%plr) went back to %plr $+ !
    if ( %ability. [ $+ [ %plr ] ] == Natural Cure ) {
      unset %status. [ $+ [ %plr ] $+ [ %slot. [ $+ [ %plr ] ] ] ]
      unset %durationToxic. [ $+ [ %plr ] $+ [ %slot. [ $+ [ %plr ] ] ] ]
    }
    unset %FlashFireBoost. [ $+ [ %plr ] ]
    if ( %durationToxic. [ $+ [ %plr ] $+ [ %slot. [ $+ [ %plr ] ] ] ] != $null ) set %durationToxic. [ $+ [ %plr ] $+ [ %slot. [ $+ [ %plr ] ] ] ] 1
    set %goz. [ $+ [ %plr ] ] 1
    mesg %plr Choose a Pokémon to switch in. Do so by typing /msg $me switch (Pokémon).
    var %count = 1
    while ( %count <= 6 ) {
      if ( !$istok(%fainted. [ $+ [ %plr ] ],$gettok(%slotorder. [ $+ [ %plr ] ],%count,32),32) ) var %alive = %alive $readini($teams,$GetTeamName(%plr),$+(Pokemon,$gettok(%slotorder. [ $+ [ %plr ] ],%count,32)))
      inc %count 1
    }
    mesg %plr Your non-fainted Pokémon: $remtok(%alive,%poke. [ $+ [ %plr ] ],1,32)
    halt
  }
  if ( $istok(%effect,U-turn,32) ) {
    if ( %LOdamage. [ $+ [ %plr ] ] ) {
      unset %LOdamage. [ $+ [ %plr ] ]
      var %damage = $int($calc( 0.1 * $GetStat(%plr).hp ))
      TakeDamage %plr %damage
      mesg %chan %plr $+ 's $TypeColor(%plr) was hurt by its Life Orb!
    }
    if ( ( $gettok(%curHP. [ $+ [ %plr ] ],%slot. [ $+ [ %plr ] ],32) > 0 ) && ( $left($Score(%plr),1) > 1 ) ) {
      mesg %chan %plr $+ 's $TypeColor(%plr) went back to %plr $+ !
      GetStatus -l Confuse %plr
      unset %durationConfuse. [ $+ [ %plr ] ]
      GetStatus -l Taunt %plr
      unset %durationTaunt. [ $+ [ %plr ] ]
      if ( %ability. [ $+ [ %plr ] ] == Natural Cure ) {
        unset %status. [ $+ [ %plr ] $+ [ %slot. [ $+ [ %plr ] ] ] ]
        unset %durationToxic. [ $+ [ %plr ] $+ [ %slot. [ $+ [ %plr ] ] ] ]
      }
      unset %FlashFireBoost. [ $+ [ %plr ] ]
      unset %Seed. [ $+ [ %plr ] ]
      if ( %durationToxic. [ $+ [ %plr ] $+ [ %slot. [ $+ [ %plr ] ] ] ] != $null ) set %durationToxic. [ $+ [ %plr ] $+ [ %slot. [ $+ [ %plr ] ] ] ] 1
      unset %Atk. [ $+ [ %plr ] ]
      unset %Def. [ $+ [ %plr ] ]
      unset %SpA. [ $+ [ %plr ] ]
      unset %SpD. [ $+ [ %plr ] ]
      unset %Spe. [ $+ [ %plr ] ]
      set %goz. [ $+ [ %plr ] ] 1
      mesg %plr Choose a Pokémon to switch in. Do so by typing /msg $me switch (Pokémon).
      var %count = 1
      while ( %count <= 6 ) {
        if ( !$istok(%fainted. [ $+ [ %plr ] ],$gettok(%slotorder. [ $+ [ %plr ] ],%count,32),32) ) var %alive = %alive $readini($teams,$GetTeamName(%plr),$+(Pokemon,$gettok(%slotorder. [ $+ [ %plr ] ],%count,32)))
        inc %count 1
      }
      mesg %plr Your non-fainted Pokémon: $remtok(%alive,%poke. [ $+ [ %plr ] ],1,32)
      halt
    }
  }
  if ( $istok(%effect,forceswitch,32) ) {
    if ( $numtok(%fainted. [ $+ [ %opponent ] ],32) >= 5 ) {
      mesg %chan But it failed!
      return
    }
    mesg %chan %opponent $+ 's $TypeColor(%opponent) was forced away!
    var %count = $rand(1,6)
    while ( ( $readini($teams,$GetTeamName(%opponent),$+(Pokemon,%count)) == %poke. [ $+ [ %opponent ] ] ) || ( $istok(%fainted. [ $+ [ %opponent ] ],%count,32) ) ) var %count = $rand(1,6)
    GetStatus -l Confuse %opponent
    unset %durationConfuse. [ $+ [ %opponent ] ]
    GetStatus -l Taunt %opponent
    unset %durationTaunt. [ $+ [ %opponent ] ]
    if ( %ability. [ $+ [ %opponent ] ] == Natural Cure ) {
      unset %status. [ $+ [ %opponent ] $+ [ %slot. [ $+ [ %opponent ] ] ] ]
      unset %durationToxic. [ $+ [ %opponent ] $+ [ %slot. [ $+ [ %opponent ] ] ] ]
    }
    unset %FlashFireBoost. [ $+ [ %opponent ] ]
    unset %Seed. [ $+ [ %opponent ] ]
    if ( %durationToxic. [ $+ [ %opponent ] $+ [ %slot. [ $+ [ %opponent ] ] ] ] != $null ) set %durationToxic. [ $+ [ %opponent ] $+ [ %slot. [ $+ [ %opponent ] ] ] ] 1
    set %slot. [ $+ [ %opponent ] ] %count
    SetPoke %opponent
    unset %Atk. [ $+ [ %opponent ] ]
    unset %Def. [ $+ [ %opponent ] ]
    unset %SpA. [ $+ [ %opponent ] ]
    unset %SpD. [ $+ [ %opponent ] ]
    unset %Spe. [ $+ [ %opponent ] ]
    mesg %chan %opponent $+ 's $TypeColor(%opponent).real was dragged out!
    SwitchEffects %opponent
    if ( %faster == %plr ) {
      WeatherMsg
      if ( !%dead. [ $+ [ %plr ] ] ) EndOfTurn %plr %opponent
      if ( !%dead. [ $+ [ %opponent ] ] ) EndOfTurn %opponent %plr
      StartBattle
      halt
    }
  }
  if ( $istok(%effect,protect,32) ) {
    set %protect. [ $+ [ %plr ] ] 1
    mesg %chan %plr $+ 's $TypeColor(%plr) protected itself!
  }
  if ( $istok(%effect,seed,32) ) {
    if ( $istok(%types. [ $+ [ %opponent ] ],Grass,32) ) {
      mesg %chan But it failed!
      return
    }
    mesg %chan %opponent $+ 's $TypeColor(%opponent) was seeded!
    set %Seed. [ $+ [ %opponent ] ] 1
  }
  if ( $istok(%effect,RapidSpin,32) ) {
    if ( $istok(%field. [ $+ [ %plr ] ],StealthRock,32) ) mesg %chan %plr $+ 's $TypeColor(%plr) blew away the Stealth Rock!
    if ( $istok(%field. [ $+ [ %plr ] ],Spikes,32) ) mesg %chan %plr $+ 's $TypeColor(%plr) blew away the Spikes!
    if ( $istok(%field. [ $+ [ %plr ] ],ToxicSpikes,32) ) mesg %chan %plr $+ 's $TypeColor(%plr) blew away the Toxic Spikes!
    if ( %Seed. [ $+ [ %plr ] ] ) mesg %chan %plr $+ 's $TypeColor(%plr) blew away the Leech Seed!

    ; Also add Bind, Clamp, Fire Spin, Magma Storm, Sand Tomb, Whirlpool, and Wrap

    set %field. [ $+ [ %plr ] ] $remtok(%field. [ $+ [ %plr ] ],StealthRock,1,32)
    set %field. [ $+ [ %plr ] ] $remtok(%field. [ $+ [ %plr ] ],Spikes,1,32)
    set %field. [ $+ [ %plr ] ] $remtok(%field. [ $+ [ %plr ] ],ToxicSpikes,1,32)
    unset %SpikesAmount. [ $+ [ %plr ] ]
    unset %ToxicSpikesAmount. [ $+ [ %plr ] ]
    unset %Seed. [ $+ [ %plr ] ]
  }
  if ( $istok(%effect,recharge,32) ) set %recharge. [ $+ [ %plr ] ] 1
  if ( $istok(%effect,Reflect,32) ) {
    set %field. [ $+ [ %plr ] ] $addtok(%field. [ $+ [ %plr ] ],Reflect,32)
    set %durationReflect. [ $+ [ %plr ] ] $iif(%item. [ $+ [ %plr ] ] == Light Clay,8,5)
    mesg %chan %plr $+ 's $TypeColor(%plr) set up a barrier!
  }
  if ( $istok(%effect,LightScreen,32) ) {
    set %field. [ $+ [ %plr ] ] $addtok(%field. [ $+ [ %plr ] ],LightScreen,32)
    set %durationLS. [ $+ [ %plr ] ] $iif(%item. [ $+ [ %plr ] ] == Light Clay,8,5)
    mesg %chan %plr $+ 's $TypeColor(%plr) set up a barrier!
  }
  if ( $istok(%effect,cure,32) ) {
    unset %status. [ $+ [ %plr ] $+ * ]
    mesg %chan %plr $+ 's $TypeColor(%plr) cured its team's status problems!
  }
  if ( $istok(%effect,Transform,32) ) {
    set %ability. [ $+ [ %plr ] ] %ability. [ $+ [ %opponent ] ]
    set %types. [ $+ [ %plr ] ] %types. [ $+ [ %opponent ] ]
    set %moves. [ $+ [ %plr ] ] %moves. [ $+ [ %opponent ] ]
    set %stat. [ $+ [ %plr ] ] $GetStat(%plr).hp $gettok(%stat. [ $+ [ %opponent ] ],2-6,32)
    mesg %chan %plr $+ 's $TypeColor(%plr) transformed into %opponent $+ 's $TypeColor(%opponent) $+ !
  }
  ;^^^Rest of effects

}
alias -l GetStatus {
  if ( $1 == -l ) {
    var %status = $2
    var %plr = $3
    set %status. [ $+ [ %plr ] $+ [ %slot. [ $+ [ %plr ] ] ] ] $remtok(%status. [ $+ [ %plr ] $+ [ %slot. [ $+ [ %plr ] ] ] ],%status,1,32)
    if ( %status. [ $+ [ %plr ] $+ [ %slot. [ $+ [ %plr ] ] ] ] == $null ) unset %status. [ $+ [ %plr ] $+ [ %slot. [ $+ [ %plr ] ] ] ]
  }
  else {
    var %status = $1
    var %plr = $2
    set %status. [ $+ [ %plr ] $+ [ %slot. [ $+ [ %plr ] ] ] ] $addtok(%status. [ $+ [ %plr ] $+ [ %slot. [ $+ [ %plr ] ] ] ],%status,32)
  }
}
alias -l BoostStat {
  var %player = $1
  var %stat = $2
  var %amount = $3
  if ( % [ $+ [ %stat ] $+ ] . [ $+ [ %player ] ] == $null ) set % [ $+ [ %stat ] $+ ] . [ $+ [ %player ] ] 0
  if ( %amount > 0 ) {
    inc % [ $+ [ %stat ] $+ ] . [ $+ [ %player ] ] %amount
    if ( % [ $+ [ %stat ] $+ ] . [ $+ [ %player ] ] > 6 ) {
      dec % [ $+ [ %stat ] $+ ] . [ $+ [ %player ] ] %amount
      mesg %chan %player $+ 's $TypeColor(%player) $+ 's $FullStat(%stat) won't go higher!
      return
    }
    ;var %newStat = $int($calc( $gettok(%stat. [ $+ [ %player ] ],$NumStat(%stat),32) * ( ( %amount + 2 ) / 2 ) ))
  }
  if ( %amount < 0 ) {
    inc % [ $+ [ %stat ] $+ ] . [ $+ [ %player ] ] %amount
    if ( % [ $+ [ %stat ] $+ ] . [ $+ [ %player ] ] < -6 ) {
      dec % [ $+ [ %stat ] ] . [ $+ [ %player ] ] %amount
      mesg %chan %player $+ 's $TypeColor(%player) $+ 's $FullStat(%stat) won't go lower!
      return
    }
    ;var %newStat = $int($calc( $gettok(%stat. [ $+ [ %player ] ],$NumStat(%stat),32) * ( 2 / ( ( -1 * %amount ) + 2 ) ) ))
  }
  ;set %stat. [ $+ [ %player ] ] $puttok(%stat. [ $+ [ %player ] ],%newStat,$NumStat(%stat),32)
  if ( %amount <= -2 ) mesg %chan %player $+ 's $TypeColor(%player) $+ 's $FullStat(%stat) harshly fell!
  if ( %amount == -1 ) mesg %chan %player $+ 's $TypeColor(%player) $+ 's $FullStat(%stat) fell!
  if ( %amount == 1 ) mesg %chan %player $+ 's $TypeColor(%player) $+ 's $FullStat(%stat) rose!
  if ( %amount >= 2 ) mesg %chan %player $+ 's $TypeColor(%player) $+ 's $FullStat(%stat) sharply rose!
}
alias -l FullStat {
  if ( $1 == Atk ) return Attack
  if ( $1 == Def ) return Defense
  if ( $1 == SpA ) return Sp. Attack
  if ( $1 == SpD ) return Sp. Defense
  if ( $1 == Spe ) return Speed
}
alias -l NumStat {
  if ( $1 == Atk ) return 2
  if ( $1 == Def ) return 3
  if ( $1 == SpA ) return 4
  if ( $1 == SpD ) return 5
  if ( $1 == Spe ) return 6
}

;#####
;###############
;#############################################   Separation between simulator (above) and team editor (below)
;###############
;#####

alias -l nohtml {
  var %x, %i = $regsub($1-,/(^[^<]*>|<[^>]*>|<[^>]*$)/g,$null,%x), %x = $remove(%x,&nbsp;)
  return %x
}
alias -l GetData {
  set %thing $1
  set %nick $2
  set %prop $3
  if ( %prop == Realitem ) {
    set %item $replace(%item,$chr(95),$chr(32))
    set %thing %item
  }
  if ( %prop == Legalability ) {
    set %ability $replace(%ability,$chr(95),$chr(32))
    set %thing %ability
  }
  if ( %prop == Legalmoves ) {
    set %moves $replace(%moves,$chr(95),$chr(32))
    set %thing %moves
    set %movecount 0
  }
  sockopen Data www.smogon.com 80
}
on *:SOCKOPEN:Data:{
  if ( %prop == Realpoke ) sockwrite -n Data GET /dp/pokemon/ $+ %thing $+ /moves HTTP/1.0
  elseif ( %prop == Realitem ) sockwrite -n Data GET /dp/items/ HTTP/1.0
  elseif ( %prop == Legalability ) {
    if ( $readini($teams,$+(%nick,$chr(95),%teamname),$+(Pokemon,%slot)) == $null ) {
      mesg %nick You cannot set an ability for a Pokémon that you have not set yet.
      unset %thing
      unset %nick
      unset %return
      unset %prop
      unset %nickname
      unset %slot
      unset %teamname
      unset %ability
      sockclose Data
      halt
    }
    else sockwrite -n Data GET /dp/pokemon/ $+ $readini($teams,$+(%nick,$chr(95),%teamname),$+(Pokemon,%slot)) $+ /moves HTTP/1.0
  }
  elseif ( %prop == LegalMoves ) {
    if ( $readini($teams,$+(%nick,$chr(95),%teamname),$+(Pokemon,%slot)) == $null ) {
      mesg %nick You cannot set a moveset for a Pokémon that you have not set yet.
      unset %thing
      unset %nick
      unset %return
      unset %prop
      unset %nickname
      unset %slot
      unset %teamname
      unset %ability
      sockclose Data
      halt
    }
    else sockwrite -n Data GET /dp/pokemon/ $+ $readini($teams,$+(%nick,$chr(95),%teamname),$+(Pokemon,%slot)) $+ /moves HTTP/1.0
  }
  sockwrite -n Data Host: www.smogon.com $crlf $+ $crlf $+
}
on *:SOCKREAD:Data:{
  var %text
  sockread %text
  if ( %prop == Realpoke ) {
    if ( <!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Strict//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd"> isin %text ) {
      set %return $true
    }
    elseif ( ( <a href="/dp/tiers/ isin %text ) && ( $nohtml(%text) != Tiers ) ) writeini -n $teams $+(%nickname,$chr(95),%teamname) $+(Tier,%slot) $nohtml(%text)
    elseif ( ( <a href="/dp/types/ isin %text ) && ( $nohtml(%text) != Types ) ) writeini -n $teams $+(%nickname,$chr(95),%teamname) $+(Type,%slot) $remove($nohtml(%text),$+($chr(47),$chr(32)))
    elseif ( <div style="width:*px; background:#*">*</div> iswm %text ) set %BS %BS $nohtml(%text)
  }
  elseif ( %prop == Realitem ) {
    if ( ( <a href="/dp/items/ isin %text ) && ( $nohtml(%text) == %thing ) ) {
      set %return $true
    }
  }
  elseif ( %prop == Legalability ) {
    if ( ( <a href="/dp/abilities/ isin %text ) && ( $nohtml(%text) == %thing ) && ( $nohtml(%text) != Abilities ) ) {
      set %return $true
    }
  }
  elseif ( %prop == Legalmoves ) {
    if ( ( <a href="/dp/moves/ isin %text ) && ( $istok(%thing,$nohtml(%text),46) ) && ( $nohtml(%text) != Moves ) ) {
      inc %movecount 1
    }
  }
}
on *:SOCKCLOSE:Data:{
  if ( ( %prop == Realpoke ) && ( %return ) ) {
    writeini -n $teams $+(%nickname,$chr(95),%teamname) $+(BaseStats,%slot) %BS
    unset %BS
  }
  if ( ( %prop == Legalmoves ) && ( %movecount == 4 ) ) set %return $true
  unset %movecount
  if ( %return == $null ) set %return $false
  unset %thing
  unset %nick
  InterpretResults
}
alias -l proper {
  var %end = $numtok($1,32)
  var %count = 1
  while ( %count <= %end ) {
    var %text = %text $+($upper($left($gettok($1,%count,32),1)),$lower($right($gettok($1,%count,32),-1)))
    inc %count 1
  }
  return %text
}
on *:TEXT:MyTeam *:?:{
  if ( $3 == $null ) {
    mesg $nick Available MyTeam commands: Pokémon IVs EVs Nature Item Ability Moves Delete View Nickname Shiny
    halt
  }
  if ( $3 == Delete ) {
    remini $teams $+($nick,$chr(95),$2)
    mesg $nick Your team  $+ $2 $+  has been deleted.
    halt
  }
  if ( $3 == View ) {
    if ( ( $4 !isnum 1-6 ) && ( $4 != all ) ) {
      mesg $nick Syntax Error. Correct syntax:
      mesg $nick MyTeam Team Name View Slot
      halt
    }
    var %count = $4
    if ( %count != all ) {
      var %pokemon = $readini($teams,$+($nick,$chr(95),$2),$+(Pokemon,%count))
      var %item = $readini($teams,$+($nick,$chr(95),$2),$+(Item,%count))
      var %ability = $readini($teams,$+($nick,$chr(95),$2),$+(Ability,%count))
      var %nature = $readini($teams,$+($nick,$chr(95),$2),$+(Nature,%count))
      var %IVs = $readini($teams,$+($nick,$chr(95),$2),$+(IVs,%count))
      var %EVs = $readini($teams,$+($nick,$chr(95),$2),$+(EVs,%count))
      var %moves = $readini($teams,$+($nick,$chr(95),$2),$+(Moves,%count))
      mesg $nick Slot %count $+ : $iif(%pokemon != $null,%pokemon,(No Pokémon)) $chr(64) $iif(%item != $null,%item,(No Item))
      mesg $nick $iif(%ability != $null,%ability,(No Ability)) $+ $chr(44) $iif(%nature != $null,%nature,(No Nature))
      mesg $nick $iif(%IVs != $null,%IVs,(No IVs)) $chr(47) $iif(%EVs != $null,%EVs,(No EVs))
      mesg $nick $chr(126) $iif($gettok(%moves,1,46) != $null,$gettok(%moves,1,46),(No Move in Slot 1))
      mesg $nick $chr(126) $iif($gettok(%moves,2,46) != $null,$gettok(%moves,2,46),(No Move in Slot 2))
      mesg $nick $chr(126) $iif($gettok(%moves,3,46) != $null,$gettok(%moves,3,46),(No Move in Slot 3))
      mesg $nick $chr(126) $iif($gettok(%moves,4,46) != $null,$gettok(%moves,4,46),(No Move in Slot 4))
    }
    else {
      var %count = 1
      while ( %count <= 6 ) {
        var %pokemon = $readini($teams,$+($nick,$chr(95),$2),$+(Pokemon,%count))
        var %item = $readini($teams,$+($nick,$chr(95),$2),$+(Item,%count))
        var %ability = $readini($teams,$+($nick,$chr(95),$2),$+(Ability,%count))
        var %nature = $readini($teams,$+($nick,$chr(95),$2),$+(Nature,%count))
        var %IVs = $readini($teams,$+($nick,$chr(95),$2),$+(IVs,%count))
        var %EVs = $readini($teams,$+($nick,$chr(95),$2),$+(EVs,%count))
        var %moves = $readini($teams,$+($nick,$chr(95),$2),$+(Moves,%count))
        mesgq $nick Slot %count $+ : $iif(%pokemon != $null,%pokemon,(No Pokémon)) $chr(64) $iif(%item != $null,%item,(No Item))
        mesgq $nick $iif(%ability != $null,%ability,(No Ability)) $+ $chr(44) $iif(%nature != $null,%nature,(No Nature))
        mesgq $nick $iif(%IVs != $null,%IVs,(No IVs)) $chr(47) $iif(%EVs != $null,%EVs,(No EVs))
        mesgq $nick $chr(126) $iif($gettok(%moves,1,46) != $null,$gettok(%moves,1,46),(No Move in Slot 1))
        mesgq $nick $chr(126) $iif($gettok(%moves,2,46) != $null,$gettok(%moves,2,46),(No Move in Slot 2))
        mesgq $nick $chr(126) $iif($gettok(%moves,3,46) != $null,$gettok(%moves,3,46),(No Move in Slot 3))
        mesgq $nick $chr(126) $iif($gettok(%moves,4,46) != $null,$gettok(%moves,4,46),(No Move in Slot 4))
        inc %count 1
      }
    }
    halt
  }
  set %nickname $nick
  set %teamname $2
  if ( ( $chr(91) isin %teamname ) || ( $chr(93) isin %teamname ) ) {
    mesg $nick $chr(91) and $chr(93) are illegal Team Name characters.
    unset %nickname
    unset %teamname
    halt
  }
  set %slot $4
  tokenize 32 $3-
  if ( $1 == Moves ) {
    var %count = 1
    var %commacount = 0
    while ( %count <= $len($3-) ) {
      if ( ( $mid($3-,%count,1) == $chr(44) ) && ( $mid($3-,$calc( %count + 1 ),1) == $chr(32) ) ) inc %commacount 1
      inc %count 1
    }
  }
  if ( ( $3 == $null ) || ( $2 !isnum 1-6 ) || ( ( $1 == Moves ) && ( %commacount != 3 ) ) || ( ( ( $1 == IVs ) || ( $1 == EVs ) ) && ( $8 == $null ) ) ) {
    mesg $nick Syntax error. Correct syntax:
    if ( ( $1 == Pokémon ) || ( $1 == Pokemon ) ) mesg $nick MyTeam Team Name Pokémon Slot  <Pokémon>
    elseif ( $1 == IVs ) mesg $nick MyTeam Team Name IVs Slot <HPIV AtkIV DefIV SpAIV SpDIV SpeIV>
    elseif ( $1 == EVs ) mesg $nick MyTeam Team Name EVs Slot <HPEV AtkEV DefEV SpAEV SpDEV SpeEV>
    elseif ( $1 == Nature ) mesg $nick MyTeam  Team Name Nature Slot <Nature>
    elseif ( $1 == Item ) mesg $nick MyTeam Team Name Item Slot <Item>
    elseif ( $1 == Ability ) mesg $nick MyTeam Team Name Ability Slot <Ability>
    elseif ( $1 == Moves ) mesg $nick MyTeam Team Name Moves Slot <Move1, Move2, Move3, Move4>
    elseif ( $1 == Shiny ) mesg $nick MyTeam Team Name Shiny Slot <True/False>
    else mesg $nick MyTeam MyTeam Team Name Command Name Slot Parameters
    unset %nickname
    unset %teamname
    unset %slot
    halt
  }
  if ( ( $1 == Pokémon ) || ( $1 == Pokemon ) ) {
    set %pok $proper($3)
    if ( ( %pok == $readini($teams,$+(%nickname,$chr(95),%teamname),Pokemon1) ) || $&
      ( %pok == $readini($teams,$+(%nickname,$chr(95),%teamname),Pokemon2) ) || $&
      ( %pok == $readini($teams,$+(%nickname,$chr(95),%teamname),Pokemon3) ) || $&
      ( %pok == $readini($teams,$+(%nickname,$chr(95),%teamname),Pokemon4) ) || $&
      ( %pok == $readini($teams,$+(%nickname,$chr(95),%teamname),Pokemon5) ) || $&
      ( %pok == $readini($teams,$+(%nickname,$chr(95),%teamname),Pokemon6) ) ) {
      if ( %pok == $readini($teams,$+(%nickname,$chr(95),%teamname),$+(Pokemon,%slot)) ) mesg %nickname Pokémon of slot %slot of %teamname set to  $+ %pok $+ .
      else mesg %nickname You may not violate the Species Clause.
      unset %nickname
      unset %teamname
      unset %slot
      halt
    }
    ;GetData %pok %nickname Realpoke
    if ( $Pokemon(%pok) != $null ) {
      writeini -n $teams $+(%nickname,$chr(95),%teamname) $+(Pokemon,%slot) %pok
      writeini -n $teams $+(%nickname,$chr(95),%teamname) $+(Nickname,%slot) %pok
      writeini -n $teams $+(%nickname,$chr(95),%teamname) $+(BaseStats,%slot) $replace($gettok($Pokemon(%pok),5-10,46),$chr(46),$chr(32))
      writeini -n $teams $+(%nickname,$chr(95),%teamname) $+(Type,%slot) $remove($replace($gettok($Pokemon(%pok),3-4,46),$chr(46),$chr(32)),x)
      writeini -n $teams $+(%nickname,$chr(95),%teamname) $+(IVs,%slot) 31 31 31 31 31 31
      writeini -n $teams $+(%nickname,$chr(95),%teamname) $+(EVs,%slot) 0 0 0 0 0 0
      remini $teams $+(%nickname,$chr(95),%teamname) $+(Ability,%slot)
      remini $teams $+(%nickname,$chr(95),%teamname) $+(Moves,%slot)
      remini $teams $+(%nickname,$chr(95),%teamname) $+(PP,%slot)
      mesg %nickname Pokémon of slot %slot of %teamname set to  $+ %pok $+ .
    }
    else mesg %nickname Illegal and/or unknown Pokémon  $+ %pok $+ .
    unset %pok
  }
  elseif ( $1 == Nickname ) {
    var %nick = $3
    if ( $len(%nick) > 10 ) mesg %nickname Illegal nickname  $+ %nick $+ ; too long.
    else {
      writeini -n $teams $+(%nickname,$chr(95),%teamname) $+(Nickname,%slot) %nick
      mesg %nickname Nickname of slot %slot of %teamname set to  $+ %nick $+ .
    }
  }
  elseif ( $1 == IVs ) {
    var %HP = $3
    var %Atk = $4
    var %Def = $5
    var %SpA = $6
    var %SpD = $7
    var %Spe = $8
    if ( ( %HP < 32 ) && ( %HP >= 0 ) && $&
      ( %Atk < 32 ) && ( %Atk >= 0 ) && $&
      ( %Def < 32 ) && ( %Def >= 0 ) && $&
      ( %SpA < 32 ) && ( %SpA >= 0 ) && $&
      ( %SpD < 32 ) && ( %SpD >= 0 ) && $&
      ( %Spe < 32 ) && ( %Spe >= 0 ) ) {
      writeini -n $teams $+(%nickname,$chr(95),%teamname) $+(IVs,%slot) %HP %Atk %Def %SpA %SpD %Spe
      mesg %nickname IVs of slot %slot of %teamname set to  $+ %HP %Atk %Def %SpA %SpD %Spe $+ .
    }
    else mesg %nickname Illegal IVs  $+ %HP %Atk %Def %SpA %SpD %Spe $+ .
    unset %nickname
    unset %teamname
    unset %slot
    halt
  }
  elseif ( $1 == EVs ) {
    var %HP = $3
    var %Atk = $4
    var %Def = $5
    var %SpA = $6
    var %SpD = $7
    var %Spe = $8
    if ( ( %HP < 256 ) && ( %HP >= 0 ) && $&
      ( %Atk < 256 ) && ( %Atk >= 0 ) && $&
      ( %Def < 256 ) && ( %Def >= 0 ) && $&
      ( %SpA < 256 ) && ( %SpA >= 0 ) && $&
      ( %SpD < 256 ) && ( %SpD >= 0 ) && $&
      ( %Spe < 256 ) && ( %Spe >= 0 ) && $&
      ( $calc( %HP + %Atk + %Def + %SpA + %SpD + %Spe ) <= 510 ) ) {
      writeini -n $teams $+(%nickname,$chr(95),%teamname) $+(EVs,%slot) %HP %Atk %Def %SpA %SpD %Spe
      mesg %nickname EVs of slot %slot of %teamname set to  $+ %HP %Atk %Def %SpA %SpD %Spe $+ .
    }
    else mesg %nickname Illegal EVs  $+ %HP %Atk %Def %SpA %SpD %Spe $+ .
    unset %nickname
    unset %teamname
    unset %slot
    halt
  }
  elseif ( $1 == Shiny ) {
    if ( ( $3 == False ) || ( $3 == No ) || ( $3 == Off ) || ( $3 == 0 ) ) {
      remini $teams $+(%nickname,$chr(95),%teamname) $+(Shiny,%slot)
      mesg %nickname Shinyness of slot %slot of %teamname set to false.
    }
    else {
      writeini -n $teams $+(%nickname,$chr(95),%teamname) $+(Shiny,%slot) 1
      mesg %nickname Shinyness of slot %slot of %teamname set to true.
    }
  }
  elseif ( $1 == Nature ) {
    var %nature = $proper($3)
    if ( $Nature(%nature) != $null ) {
      writeini -n $teams $+(%nickname,$chr(95),%teamname) $+(Nature,%slot) %nature
      mesg %nickname Nature of slot %slot of %teamname set to  $+ %nature $+ .
    } 
    else mesg %nickname Unknown nature  $+ %nature $+ .
    unset %nickname
    unset %teamname
    unset %slot
    halt
  }
  elseif ( $1 == Item ) {
    ;set %item $replace($proper($3-),$chr(32),$chr(95))
    set %item $proper($3-)
    ;GetData %item %nickname Realitem
    if ( $Item(%item) != $null ) {
      writeini -n $teams $+(%nickname,$chr(95),%teamname) $+(Item,%slot) %item
      mesg %nickname Item of slot %slot of %teamname set to  $+ %item $+ .
    }
    else mesg %nickname Unknown item  $+ %item $+ .
    unset %item
  }
  elseif ( $1 == Ability ) {
    ;set %ability $replace($proper($3-),$chr(32),$chr(95))
    set %ability $proper($3-)
    ;GetData %ability %nickname Legalability
    if ( $istok($gettok($Pokemon($readini($teams,$+(%nickname,$chr(95),%teamname),$+(Pokemon,%slot))),11-13,46),%ability,46) ) {
      writeini -n $teams $+(%nickname,$chr(95),%teamname) $+(Ability,%slot) %ability
      mesg %nickname Ability of slot %slot of %teamname set to  $+ %ability $+ .
    }
    else mesg %nickname Illegal and/or unknown ability  $+ %ability $+ .
    unset %ability
  }
  elseif ( $1 == Moves ) {
    set %moves $proper($3-)
    var %count = 1
    while ( %count <= $len(%moves) ) {
      if ( $mid(%moves,%count,1) == $chr(44) ) set %moves $+($left(%moves,$calc( %count - 1 )),$chr(46),$mid(%moves,$calc( %count + 2 ),$len(%moves)))
      inc %count 1
    }
    set %moves $replace(%moves,$chr(32),$chr(95))
    var %count = 1
    while ( %count <= 4 ) {
      var %move. [ $+ [ %count ] ] $replace($gettok(%moves,%count,46),$chr(95),$chr(32))
      inc %count 1
    }
    if ( ( %move.1 == %move.2 ) || ( %move.1 == %move.3 ) || ( %move.1 == %move.4 ) || $&
      ( %move.2 == %move.3 ) || ( %move.2 == %move.4 ) || ( %move.3 == %move.4 ) ) {
      mesg %nickname You cannot use the same move twice in a moveset.
      unset %nickname
      unset %teamname
      unset %slot
      unset %moves
      halt
    }
    ;GetData %moves %nickname Legalmoves
    set %moves $replace(%moves,$chr(95),$chr(32))
    if ( ( $Move(%move.1) != $null ) && ( $Move(%move.2) != $null ) && ( $Move(%move.3) != $null ) && ( $Move(%move.4) != $null ) ) {
      writeini -n $teams $+(%nickname,$chr(95),%teamname) $+(Moves,%slot) %moves
      writeini -n $teams $+(%nickname,$chr(95),%teamname) $+(PP,%slot) $+($gettok($Move($gettok(%moves,1,46)),5,32),$chr(32),$&
        $gettok($Move($gettok(%moves,2,46)),5,32),$chr(32),$gettok($Move($gettok(%moves,3,46)),5,32),$chr(32),$gettok($Move($gettok(%moves,4,46)),5,32))
      mesg %nickname Moveset of slot %slot of %teamname set to  $+ $replace(%moves,$chr(46),$+($chr(44),$chr(32))) $+ .
    }
    else mesg %nickname Illegal and/or unknown moveset  $+ $replace(%moves,$chr(46),$+($chr(44),$chr(32))) $+ .
    unset %moves
  }
  else {
    mesg $nick Unknown MyTeam command  $+ $1 $+ .
    mesg $nick Available MyTeam commands: Pokémon IVs EVs Nature Item Ability Moves Delete View Nickname Shiny
  }
}
alias -l InterpretResults {
  if ( %prop == Realpoke ) {
    if ( %return ) {
      writeini -n $teams $+(%nickname,$chr(95),%teamname) $+(Pokemon,%slot) %pok
      writeini -n $teams $+(%nickname,$chr(95),%teamname) $+(IVs,%slot) 31 31 31 31 31 31
      writeini -n $teams $+(%nickname,$chr(95),%teamname) $+(EVs,%slot) 0 0 0 0 0 0
      remini $teams $+(%nickname,$chr(95),%teamname) $+(Ability,%slot)
      remini $teams $+(%nickname,$chr(95),%teamname) $+(Moves,%slot)
      remini $teams $+(%nickname,$chr(95),%teamname) $+(PP,%slot)
      mesg %nickname Pokémon of slot %slot of %teamname set to  $+ %pok $+ .
    }
    else mesg %nickname Unknown Pokémon  $+ %pok $+ .
    unset %pok
  }
  if ( %prop == Realitem ) {
    if ( %return ) {
      writeini -n $teams $+(%nickname,$chr(95),%teamname) $+(Item,%slot) %item
      mesg %nickname Item of slot %slot of %teamname set to  $+ %item $+ .
    }
    else mesg %nickname Unknown item  $+ %item $+ .
    unset %item
  }
  if ( %prop == Legalability ) {
    if ( %return ) {
      writeini -n $teams $+(%nickname,$chr(95),%teamname) $+(Ability,%slot) %ability
      mesg %nickname Ability of slot %slot of %teamname set to  $+ %ability $+ .
    }
    else mesg %nickname Illegal and/or unknown ability  $+ %ability $+ .
    unset %ability
  }
  if ( %prop == Legalmoves ) {
    if ( %return ) {
      writeini -n $teams $+(%nickname,$chr(95),%teamname) $+(Moves,%slot) %moves
      writeini -n $teams $+(%nickname,$chr(95),%teamname) $+(PP,%slot) $+($gettok($Move($gettok(%moves,1,46)),5,32),$chr(32),$&
        $gettok($Move($gettok(%moves,2,46)),5,32),$chr(32),$gettok($Move($gettok(%moves,3,46)),5,32),$chr(32),$gettok($Move($gettok(%moves,4,46)),5,32))
      mesg %nickname Moveset of slot %slot of %teamname set to  $+ $replace(%moves,$chr(46),$+($chr(44),$chr(32))) $+ .
    }
    else mesg %nickname Illegal and/or unknown moveset  $+ $replace(%moves,$chr(46),$+($chr(44),$chr(32))) $+ .
    unset %moves
  }
  unset %nickname
  unset %slot
  unset %teamname
  unset %return
  unset %prop
}

;#####
;###############
;#############################################   Separation between simulator (below) and team editor (above)
;###############
;#####

alias -l UnsetVars {
  .timerkillall 1 $calc( %timeramount + 1 ) .timers off
  unset %plr1
  unset %plr2
  unset %battle
  unset %chan
  unset %fainted.*
  unset %dead.*
  unset %team.*
  unset %slot.*
  unset %newslot.*
  unset %challenge.*
  unset %choose.*
  unset %go.*
  unset %gox.*
  unset %ready.*
  unset %poke.*
  unset %item.*
  unset %damage.*
  unset %newitem.*
  unset %order.*
  unset %itemused.*
  unset %nature.*
  unset %IVs.*
  unset %EVs.*
  unset %moves.*
  unset %stat.*
  unset %move.*
  unset %curHP.*
  unset %status.*
  unset %Atk.*
  unset %Def.*
  unset %SpA.*
  unset %SpD.*
  unset %Spe.*
  unset %slotorder.*
  unset %nick.*
  unset %popped.*
  unset %bothdead
  unset %turns
  unset %Seed.*
  unset %start.*
  unset %end.*
  unset %ability.*
  unset %Types.*
  unset %Tier.*
  unset %BaseStats.*
  unset %weather
  unset %field.*
  unset %subHP.*
  unset %lockmove.*
  unset %LOdamage.*
  unset %wish*
  unset %faster
  unset %duration*
  unset %SpikesAmount.*
  unset %ToxicSpikesAmount.*
  unset %Rampage.*
  unset %RampageMove.*
}
alias -l Nature {
  var %nat = $1
  if ( %nat == Adamant ) var %nature = 1 1.1 1 0.9 1 1
  if ( %nat == Bashful ) var %nature = 1 1 1 1 1 1
  if ( %nat == Bold ) var %nature = 1 0.9 1.1 1 1 1
  if ( %nat == Brave ) var %nature = 1 1.1 1 1 1 0.9
  if ( %nat == Calm ) var %nature = 1 0.9 1 1 1.1 1
  if ( %nat == Careful ) var %nature = 1 1 1 0.9 1.1 1
  if ( %nat == Docile ) var %nature = 1 1 1 1 1 1
  if ( %nat == Gentle ) var %nature = 1 1 0.9 1 1.1 1
  if ( %nat == Hardy ) var %nature = 1 1 1 1 1 1
  if ( %nat == Hasty ) var %nature = 1 1 0.9 1 1 1.1
  if ( %nat == Impish ) var %nature = 1 1 1.1 0.9 1 1
  if ( %nat == Jolly ) var %nature = 1 1 1 0.9 1 1.1
  if ( %nat == Lax ) var %nature = 1 1 1.1 1 0.9 1
  if ( %nat == Lonely ) var %nature = 1 1.1 0.9 1 1 1
  if ( %nat == Mild ) var %nature = 1 1 0.9 1.1 1 1
  if ( %nat == Modest ) var %nature = 1 0.9 1 1.1 1 1
  if ( %nat == Naive ) var %nature = 1 1 1 1 0.9 1.1
  if ( %nat == Naughty ) var %nature = 1 1.1 1 1 0.9 1
  if ( %nat == Quiet ) var %nature = 1 1 1 1.1 1 0.9
  if ( %nat == Quirky ) var %nature = 1 1 1 1 1 1
  if ( %nat == Rash ) var %nature = 1 1 1 1.1 0.9 1
  if ( %nat == Relaxed ) var %nature = 1 1 1.1 1 1 0.9
  if ( %nat == Sassy ) var %nature = 1 1 1 1 1.1 0.9
  if ( %nat == Serious ) var %nature = 1 1 1 1 1 1
  if ( %nat == Timid ) var %nature = 1 0.9 1 1 1 1.1
  return %nature
}
alias -l Move {
  var %move = $1-
  if ( %move == Absorb ) var %abc = Grass Special 20 100 25 leech
  if ( %move == Acid ) var %abc = Poison Special 40 100 30 SpD -1 10 foe
  if ( %move == Acid Armor ) var %abc = Poison Status 0 101 40 Def 2 100 me
  if ( %move == Acupressure ) var %abc = Normal Status 0 101 30 randboost
  if ( %move == Aerial Ace ) var %abc = Flying Physical 60 101 20
  if ( %move == Aeroblast ) var %abc = Flying Special 100 95 5 crit
  if ( %move == Agility ) var %abc = Psychic Status 0 101 30 Spe 2 100 me 
  if ( %move == Air Cutter ) var %abc = Flying Special 55 95 25 crit
  if ( %move == Air Slash ) var %abc = Flying Special 75 95 20 flinch 30
  if ( %move == Amnesia ) var %abc = Psychic Status 0 101 20 SpD 2 100 me
  if ( %move == AncientPower ) var %abc = Rock Special 60 100 5 allboost 10 
  if ( %move == Aqua Jet ) var %abc = Water Physical 40 100 20 priority 1 
  if ( %move == Aqua Ring ) var %abc = Water Status 0 101 20 restore 
  if ( %move == Aqua Tail ) var %abc = Water Physical 90 90 10
  if ( %move == Arm Thrust ) var %abc = Fighting Physical 15 100 20 multi
  if ( %move == Aromatherapy ) var %abc = Grass Status 0 101 5 cure
  if ( %move == Assist ) var %abc = Normal Status 0 101 20 TeamMove
  if ( %move == Assurance ) var %abc = Dark Physical 50 100 10 assurance
  if ( %move == Astonish ) var %abc = Ghost Physical 30 100 15 flinch 30
  if ( %move == Attack Order ) var %abc = Bug Physical 90 100 15 crit
  if ( %move == Aura Sphere ) var %abc = Fighting Special 90 101 20
  if ( %move == Aurora Beam ) var %abc = Ice Special 65 100 20 Atk -1 10 foe
  if ( %move == Avalanche ) var %abc = Ice Physical 60 100 10 priority -4 payback
  if ( %move == Barrage ) var %abc = Normal Physical 15 85 20 multi
  if ( %move == Barrier ) var %abc = Psychic Status 0 101 30 Def 2 100 me
  if ( %move == Baton Pass ) var %abc = Normal Status 0 101 40 BatonPass
  if ( %move == Beat Up ) var %abc = Dark Physical 0 100 10 beatup
  if ( %move == Belly Drum ) var %abc = Normal Status 0 101 10 BellyDrum
  if ( %move == Bide ) var %abc = Normal Physical 0 101 10 bide priority 1
  if ( %move == Bind ) var %abc = Normal Physical 15 85 20 squeeze
  if ( %move == Bite ) var %abc = Dark Physical 60 100 25 flinch 30
  if ( %move == Blast Burn ) var %abc = Fire Special 150 90 5 recharge
  if ( %move == Blaze Kick ) var %abc = Fire Physical 85 90 10 crit burn 10
  if ( %move == Blizzard ) var %abc = Ice Special 120 70 5 freeze 10 nomisshail
  if ( %move == Block ) var %abc = Normal Status 0 100 5 block
  if ( %move == Body Slam ) var %abc = Normal Physical 85 100 15 paralyze 30
  if ( %move == Bone Club ) var %abc = Ground Physical 65 85 20 flinch 10
  if ( %move == Bone Rush ) var %abc = Ground Physical 25 90 10 multi
  if ( %move == Bonemerang ) var %abc = Ground Physical 50 90 10 twice
  if ( %move == Bounce ) var %abc = Flying Physical 85 85 5 semi paralyze 30
  if ( %move == Brave Bird ) var %abc = Flying Physical 120 100 15 recoil 0.33333
  if ( %move == Brick Break ) var %abc = Fighting Physical 75 100 15 BrickBreak
  if ( %move == Brine ) var %abc = Water Special 65 100 10 Brine
  if ( %move == Bubble ) var %abc = Water Special 20 100 30 Spe -1 10 foe
  if ( %move == BubbleBeam ) var %abc = Water Special 65 100 20 Spe -1 10 foe
  if ( %move == Bug Bite ) var %abc = Bug Physical 60 100 20 StealBerry
  if ( %move == Bug Buzz ) var %abc = Bug Special 90 100 10 SpD -1 10 foe
  if ( %move == Bulk Up ) var %abc = Fighting Status 0 101 20 Atk 1 100 me Def 1 100 me
  if ( %move == Bullet Punch ) var %abc = Steel Physical 40 100 30 priority 1
  if ( %move == Bullet Seed ) var %abc = Grass Physical 25 100 30 multi
  if ( %move == Calm Mind ) var %abc = Psychic Status 0 101 20 SpA 1 100 me SpD 1 100 me
  if ( %move == Camouflage ) var %abc = Normal Status 0 101 20 Camouflage
  if ( %move == Captivate ) var %abc = Normal Status 0 100 20 SpA -2 100 foe
  if ( %move == Charge ) var %abc = Electric Status 0 101 20 Charge SpD 1 100 me 
  if ( %move == Charge Beam ) var %abc = Electric Special 50 90 10 SpA 1 70 me
  if ( %move == Charm ) var %abc = Normal Status 0 100 20 Atk -2 100 foe
  if ( %move == Chatter ) var %abc = Flying Special 60 100 20 confuse 100
  if ( %move == Clamp ) var %abc = Water Physical 35 85 10 squeeze
  if ( %move == Close Combat ) var %abc = Fighting Physical 120 100 5 Def -1 100 me SpD -1 100 me
  if ( %move == Comet Punch ) var %abc = Normal Physical 18 85 15 multi
  if ( %move == Confuse Ray ) var %abc = Ghost Status 0 100 10 confuse 100
  if ( %move == Confusion ) var %abc = Psychic Special 50 100 25 confuse 10
  if ( %move == Constrict ) var %abc = Normal Physical 10 100 35 Spe -1 10 foe
  if ( %move == Conversion ) var %abc = Normal Status 0 101 30 StealType
  if ( %move == Conversion 2 ) var %abc = Normal Status 0 101 30 RandomType
  if ( %move == Copycat ) var %abc = Normal Status 0 101 20 Copycat
  if ( %move == Cosmic Power ) var %abc = Psychic Status 0 101 20 Def 1 100 me SpD 1 100 me
  if ( %move == Cotton Spore ) var %abc = Grass Status 0 100 40 Spe -2 100 foe
  if ( %move == Counter ) var %abc = Fighting Physical 0 100 20 priority -5 counter Physical
  if ( %move == Covet ) var %abc = Normal Physical 60 100 40 StealItem
  if ( %move == Crabhammer ) var %abc = Water Physical 90 90 10 crit
  if ( %move == Cross Chop ) var %abc = Fighting Physical 100 80 5 crit
  if ( %move == Cross Poison ) var %abc = Poison Physical 70 100 20 crit poison 10
  if ( %move == Crunch ) var %abc = Dark Physical 80 100 15 Def -1 20 foe
  if ( %move == Crush Claw ) var %abc = Normal Physical 75 95 10 Def -1 50 foe
  if ( %move == Crush Grip ) var %abc = Normal Physical 0 100 5 CrushGrip
  if ( %move == Curse ) var %abc = Ghost Status 0 101 10 Atk 1 100 me Def 1 100 me Spe -1 100 me Curse
  if ( %move == Cut ) var %abc = Normal Physical 50 95 30
  if ( %move == Dark Pulse ) var %abc = Dark Special 80 100 15 flinch 20
  if ( %move == Dark Void ) var %abc = Dark Status 0 80 10 sleep 100
  if ( %move == Defend Order ) var %abc = Bug Status 0 101 10 Def 1 100 me SpD 1 100 me
  if ( %move == Defense Curl ) var %abc = Normal Status 0 101 40 Def 1 100 me
  if ( %move == Defog ) var %abc = Flying Status 0 101 15 evasion -1 100 foe
  if ( %move == Destiny Bond ) var %abc = Ghost Status 0 101 5 bond
  if ( %move == Detect ) var %abc = Fighting Status 0 101 5 protect priority 3
  if ( %move == Dig ) var %abc = Ground Physical 80 100 10 semi
  if ( %move == Disable ) var %abc = Normal Status 0 100 20 disable
  if ( %move == Discharge ) var %abc = Electric Special 80 100 15 paralyze 30
  if ( %move == Dive ) var %abc = Water Physical 80 100 10 semi
  if ( %move == Dizzy Punch ) var %abc = Normal Physical 70 100 10 confuse 20
  if ( %move == Doom Desire ) var %abc = Steel Special 140 100 5 triturn
  if ( %move == Double Hit ) var %abc = Normal Physical 35 90 10 twice
  if ( %move == Double Kick ) var %abc = Fighting Physical 30 100 30 twice
  if ( %move == Double Team ) var %abc = Normal Status 0 101 15 evasion 1 100 me
  if ( %move == Double-Edge ) var %abc = Normal Physical 120 100 15 recoil 0.33333
  if ( %move == DoubleSlap ) var %abc = Normal Physical 15 85 10 multi
  if ( %move == Draco Meteor ) var %abc = Dragon Special 140 90 5 SpA -2 100 me
  if ( %move == Dragon Claw ) var %abc = Dragon Physical 80 100 15
  if ( %move == Dragon Dance ) var %abc = Dragon Status 0 101 20 Atk 1 100 me Spe 1 100 me
  if ( %move == Dragon Pulse ) var %abc = Dragon Special 90 100 10
  if ( %move == Dragon Rage ) var %abc = Dragon Special 0 100 10 setdamage
  if ( %move == Dragon Rush ) var %abc = Dragon Physical 100 75 10 flinch 20
  if ( %move == DragonBreath ) var %abc = Dragon Special 60 100 20 paralyze 30
  if ( %move == Drain Punch ) var %abc = Fighting Physical 75 100 5 leech
  if ( %move == Dream Eater ) var %abc = Psychic Special 100 100 15 leech sleeponly
  if ( %move == Drill Peck ) var %abc = Flying Physical 80 100 20
  if ( %move == DynamicPunch ) var %abc = Fighting Physical 100 50 5 confuse 100
  if ( %move == Earth Power ) var %abc = Ground Special 90 100 10 SpD -1 10 foe
  if ( %move == Earthquake ) var %abc = Ground Physical 100 100 10 hitbig Dig
  if ( %move == Egg Bomb ) var %abc = Normal Physical 100 75 10
  if ( %move == Embargo ) var %abc = Dark Status 0 100 15 StopItem
  if ( %move == Ember ) var %abc = Fire Special 40 100 25 burn 10
  if ( %move == Encore ) var %abc = Normal Status 0 100 5 encore
  if ( %move == Endeavor ) var %abc = Normal Physical 0 100 5 endeavor
  if ( %move == Endure ) var %abc = Normal Status 0 101 10 endure priority 3
  if ( %move == Energy Ball ) var %abc = Grass Special 80 100 10 SpD -1 10 foe
  if ( %move == Eruption ) var %abc = Fire Special 150 100 5 HPchange
  if ( %move == Explosion ) var %abc = Normal Physical 250 100 5 faint
  if ( %move == Extrasensory ) var %abc = Psychic Special 80 100 30 flinch 10
  if ( %move == ExtremeSpeed ) var %abc = Normal Physical 80 100 5 priority 2
  if ( %move == Facade ) var %abc = Normal Physical 70 100 20 facade
  if ( %move == Faint Attack ) var %abc = Dark Physical 60 101 20
  if ( %move == Fake Out ) var %abc = Normal Physical 40 100 10 priority 1 flinch 100 FakeOut
  if ( %move == Fake Tears ) var %abc = Dark Status 0 100 20 SpD -2 100 foe
  if ( %move == False Swipe ) var %abc = Normal Physical 40 100 40 FalseSwipe
  if ( %move == FeatherDance ) var %abc = Flying Status 0 100 15 Atk -2 100 foe
  if ( %move == Feint ) var %abc = Normal Physical 30 100 10 Feint priority 2
  if ( %move == Fire Blast ) var %abc = Fire Special 120 85 5 burn 10
  if ( %move == Fire Fang ) var %abc = Fire Physical 65 95 15 flinch 10 burn 10
  if ( %move == Fire Punch ) var %abc = Fire Physical 75 100 15 burn 10
  if ( %move == Fire Spin ) var %abc = Fire Special 35 85 15 squeeze
  if ( %move == Fissure ) var %abc = Ground Physical OHKO 30 5
  if ( %move == Flail ) var %abc = Normal Physical 0 100 15 flail
  if ( %move == Flame Wheel ) var %abc = Fire Physical 60 100 25 burn 10 thaw
  if ( %move == Flamethrower ) var %abc = Fire Special 95 100 15 burn 10
  if ( %move == Flare Blitz ) var %abc = Fire Physical 120 100 15 recoil 0.33333 burn 10 thaw
  if ( %move == Flash ) var %abc = Normal Status 0 100 20 accuracy -1 100 foe
  if ( %move == Flash Cannon ) var %abc = Steel Special 80 100 10 SpD -1 10 foe
  if ( %move == Flatter ) var %abc = Dark Status 0 100 15 SpA 1 100 foe confuse 100
  if ( %move == Fling ) var %abc = Dark Physical 0 100 10 FlingItem
  if ( %move == Fly ) var %abc = Flying Physical 90 95 15 semi
  if ( %move == Focus Blast ) var %abc = Fighting Special 120 70 5 SpD -1 10 foe
  if ( %move == Focus Energy ) var %abc = Normal Status 0 101 30 boostcrit
  if ( %move == Focus Punch ) var %abc = Fighting Physical 150 100 20 priority -3 focushit
  if ( %move == Force Palm ) var %abc = Fighting Physical 60 100 10 paralyze 30
  if ( %move == Foresight ) var %abc = Normal Status 0 101 5 foresight
  if ( %move == Frenzy Plant ) var %abc = Grass Special 150 90 5 recharge
  if ( %move == Frustration ) var %abc = Normal Physical 102 100 20
  if ( %move == Fury Attack ) var %abc = Normal Physical 15 85 20 multi
  if ( %move == Fury Cutter ) var %abc = Bug Physical 20 95 20 double
  if ( %move == Fury Swipes ) var %abc = Normal Physical 18 80 15 multi
  if ( %move == Future Sight ) var %abc = Phychic Special 100 100 15 triturn
  if ( %move == Gastro Acid ) var %abc = Poison Status 0 100 10 KillAbility
  if ( %move == Giga Drain ) var %abc = Grass Special 75 100 10 leech
  if ( %move == Giga Impact ) var %abc = Normal Physical 150 90 5 recharge
  if ( %move == Glare ) var %abc = Normal Status 0 90 30 paralyze 100
  if ( %move == Grass Knot ) var %abc = Grass Special 0 100 20 trip
  if ( %move == GrassWhistle ) var %abc = Grass Status 0 55 15 sleep 100
  if ( %move == Gravity ) var %abc = Psychic Status 0 101 5 gravity
  if ( %move == Growl ) var %abc = Normal Status 0 100 40 Atk -1 100 foe
  if ( %move == Growth ) var %abc = Normal Status 0 101 40 SpA 1 100 me
  if ( %move == Grudge ) var %abc = Ghost Status 0 101 5 Grudge
  if ( %move == Guard Swap ) var %abc = Psychic Status 0 101 10 swap Def SpD
  if ( %move == Guillotine ) var %abc = Normal Physical OHKO 30 5
  if ( %move == Gunk Shot ) var %abc = Poison Physical 120 70 5 poison 30
  if ( %move == Gust ) var %abc = Flying Special 40 100 35 hitbig Bounce Fly
  if ( %move == Gyro Ball ) var %abc = Steel Physical 0 100 5 speeddif
  if ( %move == Hail ) var %abc = Ice Status 0 101 10 summon Hail 5
  if ( %move == Hammer Arm ) var %abc = Fighting Physical 100 90 10 Spe -1 100 me
  if ( %move == Harden ) var %abc = Normal Status 0 101 30 Def 1 100 me
  if ( %move == Haze ) var %abc = Ice Status 0 101 30 haze
  if ( %move == Head Smash ) var %abc = Rock Physical 150 80 5 recoil 0.5
  if ( %move == Headbutt ) var %abc = Normal Physical 70 100 15 flinch 30
  if ( %move == Heal Bell ) var %abc = Normal Status 0 101 5 cure
  if ( %move == Heal Block ) var %abc = Psychic Status 0 100 15 HealBlock
  if ( %move == Heal Order ) var %abc = Bug Status 0 101 10 heal
  if ( %move == Healing Wish ) var %abc = Psychic Status 0 101 10 faint HealingWish
  if ( %move == Heart Swap ) var %abc = Psychic Status 0 101 10 swap Atk Def SpA SpD Spe
  if ( %move == Heat Wave ) var %abc = Fire Special 100 90 10 burn 10
  if ( %move == Hi Jump Kick ) var %abc = Fighting Physical 130 90 20 missrecoil
  if ( %move == Hidden Power ) var %abc = Normal Special 70 100 15 HiddenPower
  if ( %move == Horn Attack ) var %abc = Normal Physical 65 100 25
  if ( %move == Horn Drill ) var %abc = Normal Physical OHKO 30 5
  if ( %move == Howl ) var %abc = Normal Status 0 101 40 Atk 1 100 me
  if ( %move == Hydro Cannon ) var %abc = Water Special 150 90 5 recharge
  if ( %move == Hydro Pump ) var %abc = Water Special 120 80 5
  if ( %move == Hyper Beam ) var %abc = Normal Special 150 90 5 recharge
  if ( %move == Hyper Fang ) var %abc = Normal Physical 80 90 15 flinch 10
  if ( %move == Hyper Voice ) var %abc = Normal Special 90 100 10
  if ( %move == Hypnosis ) var %abc = Psychic Status 0 60 20 sleep 100
  if ( %move == Ice Ball ) var %abc = Ice Physical 30 90 20 BuildUp
  if ( %move == Ice Beam ) var %abc = Ice Special 95 100 10 freeze 10
  if ( %move == Ice Fang ) var %abc = Ice Physical 65 95 15 flinch 10 freeze 10
  if ( %move == Ice Punch ) var %abc = Ice Physical 75 100 15 freeze 10
  if ( %move == Ice Shard ) var %abc = Ice Physical 40 100 30 priority 1
  if ( %move == Icicle Spear ) var %abc = Ice Physical 25 100 30 multi
  if ( %move == Icy Wind ) var %abc = Ice Special 55 95 15 Spe -1 100 foe
  if ( %move == Imprison ) var %abc = Psychic Status 0 101 10 Imprison
  if ( %move == Ingrain ) var %abc = Grass Status 0 101 20 restore
  if ( %move == Iron Defense ) var %abc = Steel Status 0 101 15 Def 2 100 me
  if ( %move == Iron Head ) var %abc = Steel Physical 80 100 15 flinch 30
  if ( %move == Iron Tail ) var %abc = Steel Physical 100 75 15 Def -1 30 foe
  if ( %move == Judgment ) var %abc = Normal Special 100 100 10 Plates
  if ( %move == Jump Kick ) var %abc = Fighting Physical 100 95 25 missrecoil
  if ( %move == Karate Chop ) var %abc = Fighting Physical 50 100 25 crit
  if ( %move == Kinesis ) var %abc = Psychic Status 0 80 15 accuracy -1 100 foe
  if ( %move == Knock Off ) var %abc = Dark Physical 20 100 20 KnockOff
  if ( %move == Last Resort ) var %abc = Normal Physical 140 100 5 lastmove
  if ( %move == Lava Plume ) var %abc = Fire Special 80 100 15 burn 30
  if ( %move == Leaf Blade ) var %abc = Grass Physical 90 100 15 crit
  if ( %move == Leaf Storm ) var %abc = Grass Special 140 90 5 SpA -2 100 me
  if ( %move == Leech Life ) var %abc = Bug Physical 20 100 15 leech
  if ( %move == Leech Seed ) var %abc = Grass Status 0 90 10 seed
  if ( %move == Leer ) var %abc = Normal Status 0 100 30 Def -1 100 foe
  if ( %move == Lick ) var %abc = Ghost Physical 20 100 30 paralyze 30
  if ( %move == Light Screen ) var %abc = Psychic Status 0 101 30 LightScreen
  if ( %move == Lock-On ) var %abc = Normal Status 0 101 5 surefire
  if ( %move == Lovely Kiss ) var %abc = Normal Status 0 75 10 sleep 100
  if ( %move == Low Kick ) var %abc = Fighting Physical 0 100 20 trip
  if ( %move == Lucky Chant ) var %abc = Normal Status 0 101 30 blockcrits
  if ( %move == Lunar Dance ) var %abc = Psychis Status 0 101 10 faint HealingWish
  if ( %move == Luster Purge ) var %abc = Psychic Special 70 100 5 SpD -1 50 foe
  if ( %move == Mach Punch ) var %abc = Fighting Physical 40 100 30 priority 1
  if ( %move == Magic Coat ) var %abc = Psychic Status 0 101 15 BounceBackStatus priority 4
  if ( %move == Magical Leaf ) var %abc = Grass Special 60 101 20
  if ( %move == Magma Storm ) var %abc = Fire Special 120 75 5 squeeze
  if ( %move == Magnet Bomb ) var %abc = Steel Physical 60 101 20
  if ( %move == Magnet Rise ) var %abc = Electric Status 0 101 10 levitate
  if ( %move == Magnitude ) var %abc = Ground Physical 0 100 30 magnitude hitbig Dig
  if ( %move == Me First ) var %abc = Normal Status 0 101 20 MeFirst
  if ( %move == Mean Look ) var %abc = Normal Status 0 101 5 block
  if ( %move == Meditate ) var %abc = Psychic Status 0 101 40 Atk 1 100 me
  if ( %move == Mega Drain ) var %abc = Grass Special 40 100 15 leech
  if ( %move == Mega Kick ) var %abc = Normal Physical 120 75 5
  if ( %move == Mega Punch ) var %abc = Normal Physical 80 85 20
  if ( %move == Megahorn ) var %abc = Bug Physical 120 85 10
  if ( %move == Memento ) var %abc = Dark Status 0 101 10 faint Memento
  if ( %move == Metal Burst ) var %abc = Steel Physical 0 100 10 counter All
  if ( %move == Metal Claw ) var %abc = Steel Physical 50 95 35 Atk 1 10 me
  if ( %move == Metal Sound ) var %abc = Steel Status 0 85 40 SpD -2 100 foe
  if ( %move == Meteor Mash ) var %abc = Steel Physical 100 85 10 Atk 1 20 me
  if ( %move == Metronome ) var %abc = Normal Status 0 101 10 RandomMove
  if ( %move == Milk Drink ) var %abc = Normal Status 0 101 10 heal
  if ( %move == Mimic ) var %abc = Normal Status 0 101 10 Mimic
  if ( %move == Mind Reader ) var %abc = Normal Status 0 101 40 surefire
  if ( %move == Minimize ) var %abc = Normal Status 0 101 20 evasion 1 100 me
  if ( %move == Miracle Eye ) var %abc = Psychic Status 0 101 40 MiracleEye
  if ( %move == Mirror Coat ) var %abc = Psychic Special 0 101 20 priority -5 counter Special
  if ( %move == Mirror Move ) var %abc = Flying Status 0 101 20 LastMove
  if ( %move == Mirror Shot ) var %abc = Steel Special 65 85 10 accuracy -1 30 foe
  if ( %move == Mist ) var %abc = Ice Status 0 101 30 NoLower
  if ( %move == Mist Ball ) var %abc = Psychic Special 70 100 5 SpA -1 50 foe
  if ( %move == Moonlight ) var %abc = Normal Status 0 101 5 WeatherHeal
  if ( %move == Morning Sun ) var %abc = Normal Status 0 101 5 WeatherHeal
  if ( %move == Mud Bomb ) var %abc = Ground Special 65 85 10 accuracy -1 30 foe
  if ( %move == Mud Shot ) var %abc = Ground Special 55 95 15 Spe -1 100 foe
  if ( %move == Mud Sport ) var %abc = Ground Status 0 101 15 MudSport
  if ( %move == Mud-Slap ) var %abc = Ground Special 20 100 10 accuracy -1 100 foe
  if ( %move == Muddy Water ) var %abc = Water Special 95 85 10 accuracy -1 30 foe
  if ( %move == Nasty Plot ) var %abc = Dark Status 0 101 20 SpA 2 100 me
  if ( %move == Natural Gift ) var %abc = Normal Physical 0 100 15 BerryPower
  if ( %move == Nature Power ) var %abc = Normal Special 60 101 20
  if ( %move == Needle Arm ) var %abc = Grass Physical 60 100 15 flinch 30
  if ( %move == Night Shade ) var %abc = Ghost Special 100 100 15 setdamage
  if ( %move == Night Slash ) var %abc = Dark Physical 70 100 15 crit
  if ( %move == Nightmare ) var %abc = Ghost Status 0 100 15 nightmare
  if ( %move == Octazooka ) var %abc = Water Special 65 85 10 accuracy -1 50 foe
  if ( %move == Odor Sleuth ) var %abc = Normal Status 0 101 40 foresight
  if ( %move == Ominous Wind ) var %abc = Ghost Special 60 100 5 allboost 10
  if ( %move == Outrage ) var %abc = Dragon Physical 120 100 15 rampage
  if ( %move == Overheat ) var %abc = Fire Special 140 90 5 SpA -2 100 me
  if ( %move == Pain Split ) var %abc = Normal Status 0 101 20 HPaverage
  if ( %move == Pay Day ) var %abc = Normal Physical 40 100 20
  if ( %move == Payback ) var %abc = Dark Physical 50 100 10 payback
  if ( %move == Peck ) var %abc = Flying Physical 35 100 35
  if ( %move == Perish Song ) var %abc = Normal Status 0 101 5 PerishSong
  if ( %move == Petal Dance ) var %abc = Grass Special 120 100 20 rampage
  if ( %move == Pin Missile ) var %abc = Bug Physical 14 85 20 multi
  if ( %move == Pluck ) var %abc = Flying Physical 60 100 20 StealBerry
  if ( %move == Poison Fang ) var %abc = Poison Physical 50 100 15 toxic 30
  if ( %move == Poison Gas ) var %abc = Poison Status 0 80 40 poison 100
  if ( %move == Poison Jab ) var %abc = Poison Physical 80 100 20 poison 30
  if ( %move == Poison Sting ) var %abc = Poison Physical 15 100 35 poison 30
  if ( %move == Poison Tail ) var %abc = Poison Physical 50 100 25 crit poison 10
  if ( %move == PoisonPowder ) var %abc = Poison Status 0 75 35 poison 100
  if ( %move == Pound ) var %abc = Normal Physical 40 100 35
  if ( %move == Powder Snow ) var %abc = Ice Special 40 100 25 freeze 10
  if ( %move == Power Gem ) var %abc = Rock Special 70 100 20
  if ( %move == Power Swap ) var %abc = Psychic Status 0 101 10 swap Atk SpA
  if ( %move == Power Trick ) var %abc = Psychic Status 0 101 10 PowerTrick
  if ( %move == Power Whip ) var %abc = Grass Physical 120 85 10
  if ( %move == Present ) var %abc = Normal Physical 0 90 15 present
  if ( %move == Protect ) var %abc = Normal Status 0 101 10 protect priority 3
  if ( %move == Psybeam ) var %abc = Psychic Special 65 100 20 confuse 10
  if ( %move == Psych Up ) var %abc = Normal Status 0 101 10 CopyBoosts
  if ( %move == Psychic ) var %abc = Psychic Special 90 100 10 SpD -1 10 foe
  if ( %move == Psycho Boost ) var %abc = Psychic Special 140 90 5 SpA -2 100 me
  if ( %move == Psycho Cut ) var %abc = Psychic Physical 70 100 20 crit
  if ( %move == Psycho Shift ) var %abc = Psychic Status 0 90 10 SwapStatus
  if ( %move == Psywave ) var %abc = Psychic Special 0 80 15 psywave
  if ( %move == Punishment ) var %abc = Dark Physical 0 100 5 punish
  if ( %move == Pursuit ) var %abc = Dark Physical 40 100 20 KillSwitch
  if ( %move == Quick Attack ) var %abc = Normal Physical 40 100 30 priority 1
  if ( %move == Rage ) var %abc = Normal Physical 20 100 20 rage
  if ( %move == Rain Dance ) var %abc = Water Status 0 101 5 summon Rain 5
  if ( %move == Rapid Spin ) var %abc = Normal Physical 20 100 40 RapidSpin
  if ( %move == Razor Leaf ) var %abc = Grass Physical 55 95 25 crit
  if ( %move == Razor Wind ) var %abc = Normal Special 80 100 10 crit RazorWind
  if ( %move == Recover ) var %abc = Normal Status 0 101 10 heal
  if ( %move == Recycle ) var %abc = Normal Status 0 101 10 Recycle
  if ( %move == Reflect ) var %abc = Psychic Status 0 101 20 Reflect
  if ( %move == Refresh ) var %abc = Normal Status 0 101 20 CureStatus
  if ( %move == Rest ) var %abc = Psychic Status 0 101 10 rest
  if ( %move == Return ) var %abc = Normal Physical 102 100 20
  if ( %move == Revenge ) var %abc = Fighting Physical 60 100 10 DoubleHit priority -4
  if ( %move == Reversal ) var %abc = Fighting Physical 0 100 15 flail
  if ( %move == Roar ) var %abc = Normal Status 0 100 20 priority -6 forceswitch
  if ( %move == Roar Of Time ) var %abc = Dragon Special 150 90 5 recharge
  if ( %move == Rock Blast ) var %abc = Rock Physical 25 90 10 multi
  if ( %move == Rock Climb ) var %abc = Normal Physical 90 85 20 confuse 20
  if ( %move == Rock Polish ) var %abc = Rock Status 0 101 20 Spe 2 100 me
  if ( %move == Rock Slide ) var %abc = Rock Physical 75 90 10 flinch 30
  if ( %move == Rock Smash ) var %abc = Fighting Physical 40 100 15 Def -1 50 foe
  if ( %move == Rock Throw ) var %abc = Rock Physical 50 90 15
  if ( %move == Rock Tomb ) var %abc = Rock Physical 50 80 10 Spe -1 100 foe
  if ( %move == Rock Wrecker ) var %abc = Rock Physical 150 90 5 recharge
  if ( %move == Role Play ) var %abc = Psychic Status 0 101 10 StealAbility
  if ( %move == Rolling Kick ) var %abc = Fighting Physical 60 85 15 flinch 30
  if ( %move == Rollout ) var %abc = Rock Physical 30 90 20 BuildUp
  if ( %move == Roost ) var %abc = Flying Status 0 101 10 heal roost
  if ( %move == Sacred Fire ) var %abc = Fire Physical 100 95 5 burn 50 thaw
  if ( %move == Safeguard ) var %abc = Normal Status 0 101 25 Safeguard
  if ( %move == Sand Tomb ) var %abc = Ground Physical 35 85 15 squeeze
  if ( %move == Sand-Attack ) var %abc = Ground Status 0 100 15 accuracy -1 100 foe
  if ( %move == Sandstorm ) var %abc = Rock Status 0 101 10 summon Sandstorm 5
  if ( %move == Scary Face ) var %abc = Normal Status 0 100 10 Spe -2 100 foe
  if ( %move == Scratch ) var %abc = Normal Physical 40 100 35
  if ( %move == Screech ) var %abc = Normal Status 0 85 40 Def -2 100 foe
  if ( %move == Secret Power ) var %abc = Normal Physical 70 100 20 paralyze 30
  if ( %move == Seed Bomb ) var %abc = Grass Physical 80 100 15
  if ( %move == Seed Flare ) var %abc = Grass Special 120 85 5 SpD -2 40 foe
  if ( %move == Seismic Toss ) var %abc = Fighting Physical 100 100 20 setdamage
  if ( %move == Selfdestruct ) var %abc = Normal Physical 200 100 5 faint
  if ( %move == Shadow Ball ) var %abc = Ghost Special 80 100 15 SpD -1 20 foe
  if ( %move == Shadow Claw ) var %abc = Ghost Physical 70 100 15 crit
  if ( %move == Shadow Force ) var %abc = Ghost Physical 120 100 5 semi protectkill
  if ( %move == Shadow Punch ) var %abc = Ghost Physical 60 101 20
  if ( %move == Shadow Sneak ) var %abc = Ghost Physical 40 100 30 priority 1
  if ( %move == Sharpen ) var %abc = Normal Status 0 101 30 Atk 1 100 me
  if ( %move == Sheer Cold ) var %abc = Ice Special OHKO 30 5
  if ( %move == Shock Wave ) var %abc = Electric Special 60 101 20
  if ( %move == Signal Beam ) var %abc = Bug Special 75 100 15 confuse 10
  if ( %move == Silver Wind ) var %abc = Bug Special 60 100 5 allboost 10
  if ( %move == Sing ) var %abc = Normal Status 0 55 15 sleep 100
  if ( %move == Skill Swap ) var %abc = Psychic Status 0 101 10 SwapAbilities
  if ( %move == Skull Bash ) var %abc = Normal Physical 100 100 15 SkullBash
  if ( %move == Sky Attack ) var %abc = Flying Physical 140 90 5 SkyAttack
  if ( %move == Sky Uppercut ) var %abc = Fighting Physical 85 90 15 hitbig bounce fly
  if ( %move == Slack Off ) var %abc = Normal Status 0 101 10 heal
  if ( %move == Slam ) var %abc = Normal Physical 80 75 20
  if ( %move == Slash ) var %abc = Normal Physical 70 100 20 crit
  if ( %move == Sleep Powder ) var %abc = Grass Status 0 75 15 sleep 100
  if ( %move == Sleep Talk ) var %abc = Normal Status 0 101 10 SleepTalk
  if ( %move == Sludge ) var %abc = Poison Special 65 100 20 poison 30
  if ( %move == Sludge Bomb ) var %abc = Poison Special 90 100 10 poison 30
  if ( %move == SmellingSalt ) var %abc = Normal Physical 60 100 10 SmellingSalt
  if ( %move == Smog ) var %abc = Poison Special 20 70 20 poison 40
  if ( %move == SmokeScreen ) var %abc = Normal Status 0 100 20 accuracy -1 100 foe
  if ( %move == Snatch ) var %abc = Dark Status 0 101 10 Snatch priority 4
  if ( %move == Snore ) var %abc = Normal Special 40 100 15 Snore
  if ( %move == Softboiled ) var %abc = Normal Status 0 101 10 heal
  if ( %move == SolarBeam ) var %abc = Grass Special 120 100 10 SolarBeam
  if ( %move == SonicBoom ) var %abc = Normal Special 20 90 20 setdamage
  if ( %move == Spacial Rend ) var %abc = Dragon Special 100 95 5 crit
  if ( %move == Spark ) var %abc = Electric Physical 65 100 20 paralyze 30
  if ( %move == Spider Web ) var %abc = Bug Status 0 101 10 block
  if ( %move == Spike Cannon ) var %abc = Normal Physical 20 100 15 multi
  if ( %move == Spikes ) var %abc = Ground Status 0 101 20 Spikes
  if ( %move == Spit Up ) var %abc = Normal Special 0 100 10 SpitUp
  if ( %move == Spite ) var %abc = Ghost Status 0 100 10 Spite
  if ( %move == Splash ) var %abc = Normal Status 0 101 40 none
  if ( %move == Spore ) var %abc = Grass Status 0 100 15 sleep 100
  if ( %move == Stealth Rock ) var %abc = Rock Status 0 101 20 StealthRock
  if ( %move == Steel Wing ) var %abc = Steel Physical 70 90 25 Def 1 10 me
  if ( %move == Stockpile ) var %abc = Normal Status 0 101 20 Def 1 100 me SpD 1 100 me Stockpile
  if ( %move == Stomp ) var %abc = Normal Physical 65 100 20 flinch 30
  if ( %move == Stone Edge ) var %abc = Rock Physical 100 80 5 crit
  if ( %move == Strength ) var %abc = Normal Physical 80 100 15
  if ( %move == String Shot ) var %abc = Bug Status 0 95 40 Spe -1 100 foe
  if ( %move == Stun Spore ) var %abc = Grass Status 0 75 30 paralyze 100
  if ( %move == Submission ) var %abc = Fighting Physical 80 80 25 recoil 0.25
  if ( %move == Substitute ) var %abc = Normal Status 0 101 10 Substitute
  if ( %move == Sucker Punch ) var %abc = Dark Physical 80 100 5 priority 1 SuckerPunch
  if ( %move == Sunny Day ) var %abc = Fire Status 0 101 5 summon Sun 5
  if ( %move == Super Fang ) var %abc = Normal Physical 0 90 10 HalfHP
  if ( %move == Superpower ) var %abc = Fighting Physical 120 100 5 Atk -1 100 me Def -1 100 me
  if ( %move == Supersonic ) var %abc = Normal Status 0 55 20 confuse 100
  if ( %move == Surf ) var %abc = Water Special 95 100 15 hitbig Dive
  if ( %move == Swagger ) var %abc = Normal Status 0 90 15 Atk 2 100 foe confuse 100
  if ( %move == Swallow ) var %abc = Normal Status 0 101 10 Swallow
  if ( %move == Sweet Kiss ) var %abc = Normal Status 0 75 10 confuse 100
  if ( %move == Sweet Scent ) var %abc = Normal Status 0 100 20 evasion -1 100 foe
  if ( %move == Swift ) var %abc = Normal Special 60 101 20
  if ( %move == Switcheroo ) var %abc = Dark Status 0 100 10 SwapItem
  if ( %move == Swords Dance ) var %abc = Normal Status 0 101 30 Atk 2 100 me
  if ( %move == Synthesis ) var %abc = Grass Status 0 101 5 WeatherHeal
  if ( %move == Tackle ) var %abc = Normal Physical 50 100 35
  if ( %move == Tail Glow ) var %abc = Bug Status 0 101 20 SpA 2 100 me
  if ( %move == Tail Whip ) var %abc = Normal Status 0 100 30 Def -1 100 foe
  if ( %move == Tailwind ) var %abc = Flying Status 0 101 30 Tailwind
  if ( %move == Take Down ) var %abc = Normal Physical 90 85 20 recoil 0.25
  if ( %move == Taunt ) var %abc = Dark Status 0 100 20 Taunt
  if ( %move == Teeter Dance ) var %abc = Normal Status 0 100 20 confuse 100
  if ( %move == Thief ) var %abc = Dark Physical 40 100 10 StealItem
  if ( %move == Thrash ) var %abc = Normal Physical 120 100 20 rampage
  if ( %move == Thunder ) var %abc = Electric Special 120 70 10 paralyze 30 rainnomiss
  if ( %move == Thunder Fang ) var %abc = Electric Physical 65 95 15 flinch 10 paralyze 10
  if ( %move == Thunder Wave ) var %abc = Electric Status 0 100 20 paralyze 100
  if ( %move == Thunderbolt ) var %abc = Electric Special 95 100 15 paralyze 10
  if ( %move == ThunderPunch ) var %abc = Electric Physical 75 100 15 paralyze 10
  if ( %move == ThunderShock ) var %abc = Electric Special 40 100 30 paralyze 10
  if ( %move == Tickle ) var %abc = Normal Status 0 100 20 Atk -1 100 foe Def -1 100 foe
  if ( %move == Torment ) var %abc = Dark Status 0 100 15 Torment
  if ( %move == Toxic ) var %abc = Poison Status 0 90 10 toxic 100
  if ( %move == Toxic Spikes ) var %abc = Poison Status 0 101 20 ToxicSpikes
  if ( %move == Transform ) var %abc = Normal Status 0 101 10 Transform
  if ( %move == Tri Attack ) var %abc = Normal Special 80 100 10 triplestatus
  if ( %move == Trick ) var %abc = Psychic Status 0 100 10 SwapItem
  if ( %move == Trick Room ) var %abc = Psychic Status 0 101 5 TrickRoom
  if ( %move == Triple Kick ) var %abc = Fighting Physical 10 90 10 TripleKick
  if ( %move == Trump Card ) var %abc = Normal Special 0 101 5 TrumpCard
  if ( %move == Twineedle ) var %abc = Bug Physical 25 100 20 Twineedle
  if ( %move == Twister ) var %abc = Dragon Special 40 100 20 flinch 20
  if ( %move == U-turn ) var %abc = Bug Physical 70 100 20 U-turn
  if ( %move == Uproar ) var %abc = Normal Special 90 100 10 Uproar
  if ( %move == Vacuum Wave ) var %abc = Fighting Special 40 100 30 priority 1
  if ( %move == ViceGrip ) var %abc = Normal Physical 55 100 30
  if ( %move == Vine Whip ) var %abc = Grass Physical 35 100 15
  if ( %move == Vital Throw ) var %abc = Fighting Physical 70 101 10 priority -1
  if ( %move == Volt Tackle ) var %abc = Electric Physical 120 100 15 recoil .33333 paralyze 10
  if ( %move == Wake-Up Slap ) var %abc = Fighting Physical 60 100 10 WakeUpPain
  if ( %move == Water Gun ) var %abc = Water Special 40 100 25
  if ( %move == Water Pulse ) var %abc = Water Special 60 100 20 confuse 20
  if ( %move == Water Sport ) var %abc = Water Status 0 101 15 WaterSport
  if ( %move == Water Spout ) var %abc = Water Special 150 100 5 HPchange
  if ( %move == Waterfall ) var %abc = Water Physical 80 100 15 flinch 20
  if ( %move == Weather Ball ) var %abc = Normal Special 50 100 10 WeatherBall
  if ( %move == Whirlpool ) var %abc = Water Special 35 85 15 squeeze
  if ( %move == Whirlwind ) var %abc = Normal Status 0 100 20 priority -6 forceswitch
  if ( %move == Will-O-Wisp ) var %abc = Fire Status 0 75 15 burn 100
  if ( %move == Wing Attack ) var %abc = Flying Physical 60 100 35
  if ( %move == Wish ) var %abc = Normal Status 0 101 10 Wish
  if ( %move == Withdraw ) var %abc = Water Status 0 101 40 Def 1 100 me
  if ( %move == Wood Hammer ) var %abc = Grass Physical 120 100 15 recoil .33333
  if ( %move == Worry Seed ) var %abc = Grass Status 0 100 10 WorrySeed
  if ( %move == Wrap ) var %abc = Normal Physical 15 90 20 squeeze
  if ( %move == Wring Out ) var %abc = Normal Special 0 100 5 CrushGrip
  if ( %move == X-Scissor ) var %abc = Bug Physical 80 100 15
  if ( %move == Yawn ) var %abc = Normal Status 0 101 10 Yawn
  if ( %move == Zap Cannon ) var %abc = Electric Special 120 50 5 paralyze 100
  if ( %move == Zen Headbutt ) var %abc = Psychic Physical 80 90 15 flinch 20
  ;Gen I-IV^  Gen Vv
  if ( %move == Acid Spray ) var %abc = Poison Special 40 100 32 SpD -2 100 foe
  if ( %move == Acrobatics ) var %abc = Flying Physical 55 100 24 noitem
  if ( %move == After You ) var %abc = Normal Status 0 101 24 none
  if ( %move == Ally Switch ) var %abc = Psychic Status 0 101 24 none
  if ( %move == Autotomize ) var %abc = Steel Status 0 101 24 halfweight Spe 2 100 me
  if ( %move == Bestow ) var %abc = Normal Status 0 101 24 giveitem
  if ( %move == Blue Flare ) var %abc = Fire Special 130 85 8 burn 20
  if ( %move == Bolt Strike ) var %abc = Electric Physical 130 85 8 paralyze 20
  if ( %move == Bulldoze ) var %abc = Ground Physical 60 100 32 Spe -1 100 foe
  if ( %move == Chip Away ) var %abc = Normal Physical 70 100 32 ignoredefev
  if ( %move == Circle Throw ) var %abc = Fighting Physical 60 90 16 priority -6 forceswitch
  if ( %move == Clear Smog ) var %abc = Poison Special 50 101 24 haze
  if ( %move == Coil ) var %abc = Poison Status 0 101 32 Atk 1 100 me Def 1 100 me accuracy 1 100 me
  if ( %move == Cotton Guard ) var %abc = Grass Status 0 101 16 Def 3 100 me
  if ( %move == Dragon Tail ) var %abc = Dragon Physical 60 90 16 priority -6 forceswitch
  if ( %move == Drill Run ) var %abc = Ground Physical 80 95 16 crit
  if ( %move == Dual Chop ) var %abc = Dragon Physical 40 90 24 twice
  if ( %move == Echoed Voice ) var %abc = Normal Special 40 100 24 incpower
  if ( %move == Electro Ball ) var %abc = Electric Special 0 100 16 speedpower
  if ( %move == Electroweb ) var %abc = Electric Special 55 95 24 Spe -1 100 foe
  if ( %move == Entrainment ) var %abc = Normal Status 0 100 24 giveability
  if ( %move == Fiery Dance ) var %abc = Fire Special 80 100 16 SpA 1 50 me
  if ( %move == Final Gambit ) var %abc = Fighting Special Varies 100 8 faint myhpdamage
  if ( %move == Fire Pledge ) var %abc = Fire Special 50 100 16
  if ( %move == Flame Burst ) var %abc = Fire Special 70 100 24
  if ( %move == Flame Charge ) var %abc = Fire Physical 50 100 32 Spe 1 100 me
  if ( %move == Foul Play ) var %abc = Dark Physical 95 100 24 usefoeatk
  if ( %move == Freeze Shock ) var %abc = Ice Physical 140 90 8 paralyze 30 SkyAttack
  if ( %move == Frost Breath ) var %abc = Ice Special 40 90 16 alwayscrit
  if ( %move == Fusion Bolt ) var %abc = Electric Physical 100 100 8 fusionboost Fusion Flare
  if ( %move == Fusion Flare ) var %abc = Fire Special 100 100 8 fusionboost Fusion Bolt
  if ( %move == Gear Grind ) var %abc = Steel Physical 50 85 24 twice
  if ( %move == Glaciate ) var %abc = Ice Special 65 95 16 Spe -1 100 foe
  if ( %move == Grass Pledge ) var %abc = Grass Special 50 100 16
  if ( %move == Guard Split ) var %abc = Psychic Status 0 101 16 split Def SpD
  if ( %move == Head Charge ) var %abc = Normal Physical 120 100 24 recoil .25
  if ( %move == Heal Pulse ) var %abc = Psychic Status 0 101 16 restorefoehp
  if ( %move == Heart Stamp ) var %abc = Psychic Physical 60 100 40 flinch 30
  if ( %move == Heat Crash ) var %abc = Fire Physical Varies 100 16 crush
  if ( %move == Heavy Slam ) var %abc = Steel Physical Varies 100 16 crush
  if ( %move == Hex ) var %abc = Ghost Special 50 100 16 doublestatus
  if ( %move == Hone Claws ) var %abc = Dark Status 0 101 24 Atk 1 100 me accuracy 1 100 me
  if ( %move == Horn Leech ) var %abc = Grass Physical 75 100 16 leech
  if ( %move == Hurricane ) var %abc = Flying Special 120 70 16 confuse 30 rainnomiss
  if ( %move == Ice Burn ) var %abc = Ice Special 140 90 8 burn 30 SkyAttack
  if ( %move == Icicle Crash ) var %abc = Ice Physical 85 90 16 flinch 30
  if ( %move == Incinerate ) var %abc = Fire Special 30 100 24 berryburn
  if ( %move == Inferno ) var %abc = Fire Special 100 50 8 burn 100
  if ( %move == Leaf Tornado ) var %abc = Grass Special 65 90 16 accuracy -1 30 foe
  if ( %move == Low Sweep ) var %abc = Fighting Physical 60 100 32 Spe -1 100 foe
  if ( %move == Magic Room ) var %abc = Psychic Status 0 101 16 priority -7 MagicRoom
  if ( %move == Night Daze ) var %abc = Dark Special 85 95 16 accuracy -1 40 foe
  if ( %move == Power Split ) var %abc = Psychic Status 0 101 16 split Atk SpA
  if ( %move == Psyshock ) var %abc = Psychic Special 80 100 16 SpADef
  if ( %move == Psystrike ) var %abc = Psychic Special 100 100 16 SpADef
  if ( %move == Quash ) var %abc = Dark Status 0 100 24 none
  if ( %move == Quick Guard ) var %abc = Fighting Status 0 101 24 priority 3 QuickGuard
  if ( %move == Quiver Dance ) var %abc = Bug Status 0 101 32 SpA 1 100 me SpD 1 100 me Spe 1 100 me
  if ( %move == Rage Powder ) var %abc = Bug Status 0 101 32 none
  if ( %move == Razor Shell ) var %abc = Water Physical 75 95 16 Def -1 50 foe
  if ( %move == Reflect Type ) var %abc = Normal Status 0 101 24 copytype
  if ( %move == Relic Song ) var %abc = Normal Special 75 100 16 sleep 10 Meloetta
  if ( %move == Retaliate ) var %abc = Normal Physical 70 100 8 revenge
  if ( %move == Round ) var %abc = Normal Special 60 100 24
  if ( %move == Sacred Sword ) var %abc = Fighting Physical 90 100 32 ignoredefev
  if ( %move == Scald ) var %abc = Water Special 80 100 24 burn 30 thaw
  if ( %move == Searing Shot ) var %abc = Fire Special 100 100 8 burn 30
  if ( %move == Secret Sword ) var %abc = Fighting Special 85 100 16 SpADef
  if ( %move == Shell Smash ) var %abc = Normal Status 0 101 24 Atk 2 100 me Def -1 100 me SpA 2 100 me SpD -1 100 me Spe 2 100 me
  if ( %move == Shift Gear ) var %abc = Steel Status 0 101 16 Atk 1 100 me Spe 2 100 me
  if ( %move == Simple Beam ) var %abc = Normal Status 0 100 24 givesimple
  if ( %move == Sky Drop ) var %abc = Flying Physical 60 100 16 skydrop
  if ( %move == Sludge Wave ) var %abc = Poison Special 95 100 16 poison 10
  if ( %move == Smack Down ) var %abc = Rock Physical 50 100 24 smackdown
  if ( %move == Snarl ) var %abc = Dark Special 55 95 24 SpA -1 100 foe
  if ( %move == Soak ) var %abc = Water Status 0 101 32 givewater
  if ( %move == Steamroller ) var %abc = Bug Physical 65 100 32 flinch 30 hitbig Minimize
  if ( %move == Stored Power ) var %abc = Psychic Special 20 100 16 StoredPower
  if ( %move == Storm Throw ) var %abc = Fighting Physical 40 100 16 alwayscrit
  if ( %move == Struggle Bug ) var %abc = Bug Special 30 100 32 SpA -1 100 foe
  if ( %move == Synchronoise ) var %abc = Psychic Special 70 100 24 hitsametype
  if ( %move == Tail Slap ) var %abc = Normal Physical 25 85 16 multi
  if ( %move == Techno Blast ) var %abc = Normal Special 85 100 8 Drives
  if ( %move == Telekinesis ) var %abc = Psychic Status 0 101 24 Telekinesis
  if ( %move == V-create ) var %abc = Fire Physical 180 95 8 Def -1 100 me SpD -1 100 me Spe -1 100 me
  if ( %move == Venoshock ) var %abc = Poison Special 65 100 16 poisonpower
  if ( %move == Volt Switch ) var %abc = Electric Special 70 100 32 U-turn
  if ( %move == Water Pledge ) var %abc = Water Special 50 100 16
  if ( %move == Wide Guard ) var %abc = Rock Status 0 101 16 WideGuard
  if ( %move == Wild Charge ) var %abc = Electric Physical 90 100 24 recoil .25
  if ( %move == Wonder Room ) var %abc = Psychic Status 0 101 16 WonderRoom
  if ( %move == Work Up ) var %abc = Normal Status 0 101 48 Atk 1 100 me SpA 1 100 me

  return %abc
}
alias -l NoProtect {
  if ( $1 == Water Sport ) return 1
  if ( $1 == Sunny Day ) return 1
  if ( $1 == Sandstorm ) return 1
  if ( $1 == Gravity ) return 1
  if ( $1 == Hail ) return 1
  if ( $1 == Haze ) return 1
  if ( $1 == Trick Room ) return 1
  if ( $1 == Rain Dance ) return 1
  if ( $1 == Perish Song ) return 1
  if ( $1 == Mud Sport ) return 1
  if ( $1 == Toxic Spikes ) return 1
  if ( $1 == Spikes ) return 1
  if ( $1 == Stealth Rock ) return 1
  if ( $1 == Milk Drink ) return 1
  if ( $1 == Stockpile ) return 1
  if ( $1 == Splash ) return 1
  if ( $1 == Softboiled ) return 1
  if ( $1 == Slack Off ) return 1
  if ( $1 == Sharpen ) return 1
  if ( $1 == Acid Armor ) return 1
  if ( $1 == Swallow ) return 1
  if ( $1 == Roost ) return 1
  if ( $1 == Rock Polish ) return 1
  if ( $1 == Rest ) return 1
  if ( $1 == Refresh ) return 1
  if ( $1 == Swords Dance ) return 1
  if ( $1 == Synthesis ) return 1
  if ( $1 == Agility ) return 1
  if ( $1 == Tail Glow ) return 1
  if ( $1 == Recycle ) return 1
  if ( $1 == Amnesia ) return 1
  if ( $1 == Recover ) return 1
  if ( $1 == Protect ) return 1
  if ( $1 == Power Trick ) return 1
  if ( $1 == Teleport ) return 1
  if ( $1 == Nasty Plot ) return 1
  if ( $1 == Morning Sun ) return 1
  if ( $1 == Moonlight ) return 1
  if ( $1 == Aqua Ring ) return 1
  if ( $1 == Minimize ) return 1
  if ( $1 == Substitute ) return 1
  if ( $1 == Meditate ) return 1
  if ( $1 == Magnet Rise ) return 1
  if ( $1 == Lunar Dance ) return 1
  if ( $1 == Barrier ) return 1
  if ( $1 == Baton Pass ) return 1
  if ( $1 == Iron Defense ) return 1
  if ( $1 == Ingrain ) return 1
  if ( $1 == Imprison ) return 1
  if ( $1 == Howl ) return 1
  if ( $1 == Healing Wish ) return 1
  if ( $1 == Heal Order ) return 1
  if ( $1 == Belly Drum ) return 1
  if ( $1 == Harden ) return 1
  if ( $1 == Grudge ) return 1
  if ( $1 == Growth ) return 1
  if ( $1 == Follow Me ) return 1
  if ( $1 == Focus Energy ) return 1
  if ( $1 == Endure ) return 1
  if ( $1 == Dragon Dance ) return 1
  if ( $1 == Double Team ) return 1
  if ( $1 == Detect ) return 1
  if ( $1 == Destiny Bond ) return 1
  if ( $1 == Defense Curl ) return 1
  if ( $1 == Defend Order ) return 1
  if ( $1 == Cosmic Power ) return 1
  if ( $1 == Conversion2 ) return 1
  if ( $1 == Conversion ) return 1
  if ( $1 == Charge ) return 1
  if ( $1 == Camouflage ) return 1
  if ( $1 == Calm Mind ) return 1
  if ( $1 == Bulk Up ) return 1
  if ( $1 == Bide ) return 1
  if ( $1 == Wish ) return 1
  if ( $1 == Withdraw ) return 1
  if ( $1 == Acupressure ) return 1
  if ( $1 == Heal Bell ) return 1
  if ( $1 == Light Screen ) return 1
  if ( $1 == Aromatherapy ) return 1
  if ( $1 == Lucky Chant ) return 1
  if ( $1 == Mist ) return 1
  if ( $1 == Tailwind ) return 1
  if ( $1 == Reflect ) return 1
  if ( $1 == Safeguard ) return 1
  return 0
}
alias -l SuperBerry {
  if ( $1 == Occa Berry ) return Fire
  if ( $1 == Passho Berry ) return Water
  if ( $1 == Wacan Berry ) return Electric
  if ( $1 == Rindo Berry ) return Grass
  if ( $1 == Yache Berry ) return Ice
  if ( $1 == Chople Berry ) return Fighting
  if ( $1 == Kebia Berry ) return Poison
  if ( $1 == Shuca Berry ) return Ground
  if ( $1 == Coba Berry ) return Flying
  if ( $1 == Payapa Berry ) return Psychic
  if ( $1 == Tanga Berry ) return Bug
  if ( $1 == Charti Berry ) return Rock
  if ( $1 == Kasib Berry ) return Ghost
  if ( $1 == Haban Berry ) return Dragon
  if ( $1 == Colbur Berry ) return Dark
  if ( $1 == Babiri Berry ) return Steel
  if ( $1 == Chilan Berry ) return Normal
}


;########## All-purpose Pokemon Data Alias ##########

alias -l Pokemon {
  ; Species # Type1 Type2 HP Atk Def SpA SpD Spe Ability0 Ability1 AbilityDW
  if ( ( $1 == Bulbasaur ) || ( $1 == 1 ) ) return Bulbasaur.1.Grass.Poison.45.49.49.65.65.45.Overgrow.x.Chlorophyll
  if ( ( $1 == Ivysaur ) || ( $1 == 2 ) ) return Ivysaur.2.Grass.Poison.60.62.63.80.80.60.Overgrow.x.Chlorophyll
  if ( ( $1 == Venusaur ) || ( $1 == 3 ) ) return Venusaur.3.Grass.Poison.80.82.83.100.100.80.Overgrow.x.Chlorophyll
  if ( ( $1 == Charmander ) || ( $1 == 4 ) ) return Charmander.4.Fire.x.39.52.43.60.50.65.Blaze.x.Solar Power
  if ( ( $1 == Charmeleon ) || ( $1 == 5 ) ) return Charmeleon.5.Fire.x.58.64.58.80.65.80.Blaze.x.Solar Power
  if ( ( $1 == Charizard ) || ( $1 == 6 ) ) return Charizard.6.Fire.Flying.78.84.78.109.85.100.Blaze.x.Solar Power
  if ( ( $1 == Squirtle ) || ( $1 == 7 ) ) return Squirtle.7.Water.x.44.48.65.50.64.43.Torrent.x.Rain Dish
  if ( ( $1 == Wartortle ) || ( $1 == 8 ) ) return Wartortle.8.Water.x.59.63.80.65.80.58.Torrent.x.Rain Dish
  if ( ( $1 == Blastoise ) || ( $1 == 9 ) ) return Blastoise.9.Water.x.79.83.100.85.105.78.Torrent.x.Rain Dish
  if ( ( $1 == Caterpie ) || ( $1 == 10 ) ) return Caterpie.10.Bug.x.45.30.35.20.20.45.Shield Dust.x.Run Away
  if ( ( $1 == Metapod ) || ( $1 == 11 ) ) return Metapod.11.Bug.x.50.20.55.25.25.30.Shed Skin.x.x
  if ( ( $1 == Butterfree ) || ( $1 == 12 ) ) return Butterfree.12.Bug.Flying.60.45.50.80.80.70.Compoundeyes.x.Tinted Lens
  if ( ( $1 == Weedle ) || ( $1 == 13 ) ) return Weedle.13.Bug.Poison.40.35.30.20.20.50.Shield Dust.x.Run Away
  if ( ( $1 == Kakuna ) || ( $1 == 14 ) ) return Kakuna.14.Bug.Poison.45.25.50.25.25.35.Shed Skin.x.x
  if ( ( $1 == Beedrill ) || ( $1 == 15 ) ) return Beedrill.15.Bug.Poison.65.80.40.45.80.75.Swarm.x.Sniper
  if ( ( $1 == Pidgey ) || ( $1 == 16 ) ) return Pidgey.16.Normal.Flying.40.45.40.35.35.56.Keen Eye.Tangled Feet.Big Pecks
  if ( ( $1 == Pidgeotto ) || ( $1 == 17 ) ) return Pidgeotto.17.Normal.Flying.63.60.55.50.50.71.Keen Eye.Tangled Feet.Big Pecks
  if ( ( $1 == Pidgeot ) || ( $1 == 18 ) ) return Pidgeot.18.Normal.Flying.83.80.75.70.70.91.Keen Eye.Tangled Feet.Big Pecks
  if ( ( $1 == Rattata ) || ( $1 == 19 ) ) return Rattata.19.Normal.x.30.56.35.25.35.72.Guts.Run Away.Hustle
  if ( ( $1 == Raticate ) || ( $1 == 20 ) ) return Raticate.20.Normal.x.55.81.60.50.70.97.Guts.Run Away.Hustle
  if ( ( $1 == Spearow ) || ( $1 == 21 ) ) return Spearow.21.Normal.Flying.40.60.30.31.31.70.Keen Eye.x.Sniper
  if ( ( $1 == Fearow ) || ( $1 == 22 ) ) return Fearow.22.Normal.Flying.65.90.65.61.61.100.Keen Eye.x.Sniper
  if ( ( $1 == Ekans ) || ( $1 == 23 ) ) return Ekans.23.Poison.x.35.60.44.40.54.55.Intimidate.Shed Skin.Unnerve
  if ( ( $1 == Arbok ) || ( $1 == 24 ) ) return Arbok.24.Poison.x.60.85.69.65.79.80.Intimidate.Shed Skin.Unnerve
  if ( ( $1 == Pikachu ) || ( $1 == 25 ) ) return Pikachu.25.Electric.x.35.55.30.50.40.90.Static.x.Lightningrod
  if ( ( $1 == Raichu ) || ( $1 == 26 ) ) return Raichu.26.Electric.x.60.90.55.90.80.100.Static.x.Lightningrod
  if ( ( $1 == Sandshrew ) || ( $1 == 27 ) ) return Sandshrew.27.Ground.x.50.75.85.20.30.40.Sand Veil.x.Sand Rush
  if ( ( $1 == Sandslash ) || ( $1 == 28 ) ) return Sandslash.28.Ground.x.75.100.110.45.55.65.Sand Veil.x.Sand Rush
  if ( ( $1 == Nidoran♀ ) || ( $1 == 29 ) ) return Nidoran♀.29.Poison.x.55.47.52.40.40.41.Poison Point.Rivalry.Hustle
  if ( ( $1 == Nidorina ) || ( $1 == 30 ) ) return Nidorina.30.Poison.x.70.62.67.55.55.56.Poison Point.Rivalry.Hustle
  if ( ( $1 == Nidoqueen ) || ( $1 == 31 ) ) return Nidoqueen.31.Poison.Ground.90.82.87.75.85.76.Poison Point.Rivalry.Sheer Force
  if ( ( $1 == Nidoran♂ ) || ( $1 == 32 ) ) return Nidoran♂.32.Poison.x.46.57.40.40.40.50.Poison Point.Rivalry.Hustle
  if ( ( $1 == Nidorino ) || ( $1 == 33 ) ) return Nidorino.33.Poison.x.61.72.57.55.55.65.Poison Point.Rivalry.Hustle
  if ( ( $1 == Nidoking ) || ( $1 == 34 ) ) return Nidoking.34.Poison.Ground.81.92.77.85.75.85.Poison Point.Rivalry.Sheer Force
  if ( ( $1 == Clefairy ) || ( $1 == 35 ) ) return Clefairy.35.Normal.x.70.45.48.60.65.35.Cute Charm.Magic Guard.Friend Guard
  if ( ( $1 == Clefable ) || ( $1 == 36 ) ) return Clefable.36.Normal.x.95.70.73.85.90.60.Cute Charm.Magic Guard.Unaware
  if ( ( $1 == Vulpix ) || ( $1 == 37 ) ) return Vulpix.37.Fire.x.38.41.40.50.65.65.Flash Fire.x.Drought
  if ( ( $1 == Ninetales ) || ( $1 == 38 ) ) return Ninetales.38.Fire.x.73.76.75.81.100.100.Flash Fire.x.Drought
  if ( ( $1 == Jigglypuff ) || ( $1 == 39 ) ) return Jigglypuff.39.Normal.x.115.45.20.45.25.20.Cute Charm.x.Friend Guard
  if ( ( $1 == Wigglytuff ) || ( $1 == 40 ) ) return Wigglytuff.40.Normal.x.140.70.45.75.50.45.Cute Charm.x.Frisk
  if ( ( $1 == Zubat ) || ( $1 == 41 ) ) return Zubat.41.Poison.Flying.40.45.35.30.40.55.Inner Focus.x.Infiltrator
  if ( ( $1 == Golbat ) || ( $1 == 42 ) ) return Golbat.42.Poison.Flying.75.80.70.65.75.90.Inner Focus.x.Infiltrator
  if ( ( $1 == Oddish ) || ( $1 == 43 ) ) return Oddish.43.Grass.Poison.45.50.55.75.65.30.Chlorophyll.x.Run Away
  if ( ( $1 == Gloom ) || ( $1 == 44 ) ) return Gloom.44.Grass.Poison.60.65.70.85.75.40.Chlorophyll.x.Stench
  if ( ( $1 == Vileplume ) || ( $1 == 45 ) ) return Vileplume.45.Grass.Poison.75.80.85.100.90.50.Chlorophyll.x.Effect Spore
  if ( ( $1 == Paras ) || ( $1 == 46 ) ) return Paras.46.Bug.Grass.35.70.55.45.55.25.Dry Skin.Effect Spore.Damp
  if ( ( $1 == Parasect ) || ( $1 == 47 ) ) return Parasect.47.Bug.Grass.60.95.80.60.80.30.Dry Skin.Effect Spore.Damp
  if ( ( $1 == Venonat ) || ( $1 == 48 ) ) return Venonat.48.Bug.Poison.60.55.50.40.55.45.Compoundeyes.Tinted Lens.Run Away
  if ( ( $1 == Venomoth ) || ( $1 == 49 ) ) return Venomoth.49.Bug.Poison.70.65.60.90.75.90.Shield Dust.Tinted Lens.Wonder Skin
  if ( ( $1 == Diglett ) || ( $1 == 50 ) ) return Diglett.50.Ground.x.10.55.25.35.45.95.Arena Trap.Sand Veil.Sand Force
  if ( ( $1 == Dugtrio ) || ( $1 == 51 ) ) return Dugtrio.51.Ground.x.35.80.50.50.70.120.Arena Trap.Sand Veil.Sand Force
  if ( ( $1 == Meowth ) || ( $1 == 52 ) ) return Meowth.52.Normal.x.40.45.35.40.40.90.Pickup.Technician.Unnerve
  if ( ( $1 == Persian ) || ( $1 == 53 ) ) return Persian.53.Normal.x.65.70.60.65.65.115.Limber.Technician.Unnerve
  if ( ( $1 == Psyduck ) || ( $1 == 54 ) ) return Psyduck.54.Water.x.50.52.48.65.50.55.Cloud Nine.Damp.Swift Swim
  if ( ( $1 == Golduck ) || ( $1 == 55 ) ) return Golduck.55.Water.x.80.82.78.95.80.85.Cloud Nine.Damp.Swift Swim
  if ( ( $1 == Mankey ) || ( $1 == 56 ) ) return Mankey.56.Fighting.x.40.80.35.35.45.70.Anger Point.Vital Spirit.Defiant
  if ( ( $1 == Primeape ) || ( $1 == 57 ) ) return Primeape.57.Fighting.x.65.105.60.60.70.95.Anger Point.Vital Spirit.Defiant
  if ( ( $1 == Growlithe ) || ( $1 == 58 ) ) return Growlithe.58.Fire.x.55.70.45.70.50.60.Flash Fire.Intimidate.Justified
  if ( ( $1 == Arcanine ) || ( $1 == 59 ) ) return Arcanine.59.Fire.x.90.110.80.100.80.95.Flash Fire.Intimidate.Justified
  if ( ( $1 == Poliwag ) || ( $1 == 60 ) ) return Poliwag.60.Water.x.40.50.40.40.40.90.Damp.Water Absorb.Swift Swim
  if ( ( $1 == Poliwhirl ) || ( $1 == 61 ) ) return Poliwhirl.61.Water.x.65.65.65.50.50.90.Damp.Water Absorb.Swift Swim
  if ( ( $1 == Poliwrath ) || ( $1 == 62 ) ) return Poliwrath.62.Water.Fighting.90.85.95.70.90.70.Damp.Water Absorb.Swift Swim
  if ( ( $1 == Abra ) || ( $1 == 63 ) ) return Abra.63.Psychic.x.25.20.15.105.55.90.Inner Focus.Synchronize.Magic Guard
  if ( ( $1 == Kadabra ) || ( $1 == 64 ) ) return Kadabra.64.Psychic.x.40.35.30.120.70.105.Inner Focus.Synchronize.Magic Guard
  if ( ( $1 == Alakazam ) || ( $1 == 65 ) ) return Alakazam.65.Psychic.x.55.50.45.135.85.120.Inner Focus.Synchronize.Magic Guard
  if ( ( $1 == Machop ) || ( $1 == 66 ) ) return Machop.66.Fighting.x.70.80.50.35.35.35.Guts.No Guard.Steadfast
  if ( ( $1 == Machoke ) || ( $1 == 67 ) ) return Machoke.67.Fighting.x.80.100.70.50.60.45.Guts.No Guard.Steadfast
  if ( ( $1 == Machamp ) || ( $1 == 68 ) ) return Machamp.68.Fighting.x.90.130.80.65.85.55.Guts.No Guard.Steadfast
  if ( ( $1 == Bellsprout ) || ( $1 == 69 ) ) return Bellsprout.69.Grass.Poison.50.75.35.70.30.40.Chlorophyll.x.Gluttony
  if ( ( $1 == Weepinbell ) || ( $1 == 70 ) ) return Weepinbell.70.Grass.Poison.65.90.50.85.45.55.Chlorophyll.x.Gluttony
  if ( ( $1 == Victreebel ) || ( $1 == 71 ) ) return Victreebel.71.Grass.Poison.80.105.65.100.60.70.Chlorophyll.x.Gluttony
  if ( ( $1 == Tentacool ) || ( $1 == 72 ) ) return Tentacool.72.Water.Poison.40.40.35.50.100.70.Clear Body.Liquid Ooze.Rain Dish
  if ( ( $1 == Tentacruel ) || ( $1 == 73 ) ) return Tentacruel.73.Water.Poison.80.70.65.80.120.100.Clear Body.Liquid Ooze.Rain Dish
  if ( ( $1 == Geodude ) || ( $1 == 74 ) ) return Geodude.74.Rock.Ground.40.80.100.30.30.20.Rock Head.Sturdy.Sand Veil
  if ( ( $1 == Graveler ) || ( $1 == 75 ) ) return Graveler.75.Rock.Ground.55.95.115.45.45.35.Rock Head.Sturdy.Sand Veil
  if ( ( $1 == Golem ) || ( $1 == 76 ) ) return Golem.76.Rock.Ground.80.110.130.55.65.45.Rock Head.Sturdy.Sand Veil
  if ( ( $1 == Ponyta ) || ( $1 == 77 ) ) return Ponyta.77.Fire.x.50.85.55.65.65.90.Flash Fire.Run Away.Flame Body
  if ( ( $1 == Rapidash ) || ( $1 == 78 ) ) return Rapidash.78.Fire.x.65.100.70.80.80.105.Flash Fire.Run Away.Flame Body
  if ( ( $1 == Slowpoke ) || ( $1 == 79 ) ) return Slowpoke.79.Water.Psychic.90.65.65.40.40.15.Oblivious.Own Tempo.Regenerator
  if ( ( $1 == Slowbro ) || ( $1 == 80 ) ) return Slowbro.80.Water.Psychic.95.75.110.100.80.30.Oblivious.Own Tempo.Regenerator
  if ( ( $1 == Magnemite ) || ( $1 == 81 ) ) return Magnemite.81.Electric.Steel.25.35.70.95.55.45.Magnet Pull.Sturdy.Analytic
  if ( ( $1 == Magneton ) || ( $1 == 82 ) ) return Magneton.82.Electric.Steel.50.60.95.120.70.70.Magnet Pull.Sturdy.Analytic
  if ( ( $1 == Farfetch'd ) || ( $1 == 83 ) ) return Farfetch'd.83.Normal.Flying.52.65.55.58.62.60.Keen Eye.Inner Focus.Defiant
  if ( ( $1 == Doduo ) || ( $1 == 84 ) ) return Doduo.84.Normal.Flying.35.85.45.35.35.75.Early Bird.Run Away.Tangled Feet
  if ( ( $1 == Dodrio ) || ( $1 == 85 ) ) return Dodrio.85.Normal.Flying.60.110.70.60.60.100.Early Bird.Run Away.Tangled Feet
  if ( ( $1 == Seel ) || ( $1 == 86 ) ) return Seel.86.Water.x.65.45.55.45.70.45.Hydration.Thick Fat.Ice Body
  if ( ( $1 == Dewgong ) || ( $1 == 87 ) ) return Dewgong.87.Water.Ice.90.70.80.70.95.70.Hydration.Thick Fat.Ice Body
  if ( ( $1 == Grimer ) || ( $1 == 88 ) ) return Grimer.88.Poison.x.80.80.50.40.50.25.Stench.Sticky Hold.Poison Touch
  if ( ( $1 == Muk ) || ( $1 == 89 ) ) return Muk.89.Poison.x.105.105.75.65.100.50.Stench.Sticky Hold.Poison Touch
  if ( ( $1 == Shellder ) || ( $1 == 90 ) ) return Shellder.90.Water.x.30.65.100.45.25.40.Shell Armor.Skill Link.Overcoat
  if ( ( $1 == Cloyster ) || ( $1 == 91 ) ) return Cloyster.91.Water.Ice.50.95.180.85.45.70.Shell Armor.Skill Link.Overcoat
  if ( ( $1 == Gastly ) || ( $1 == 92 ) ) return Gastly.92.Ghost.Poison.30.35.30.100.35.80.Levitate.x.x
  if ( ( $1 == Haunter ) || ( $1 == 93 ) ) return Haunter.93.Ghost.Poison.45.50.45.115.55.95.Levitate.x.x
  if ( ( $1 == Gengar ) || ( $1 == 94 ) ) return Gengar.94.Ghost.Poison.60.65.60.130.75.110.Levitate.x.x
  if ( ( $1 == Onix ) || ( $1 == 95 ) ) return Onix.95.Rock.Ground.35.45.160.30.45.70.Rock Head.Sturdy.Weak Armor
  if ( ( $1 == Drowzee ) || ( $1 == 96 ) ) return Drowzee.96.Psychic.x.60.48.45.43.90.42.Forewarn.Insomnia.Inner Focus
  if ( ( $1 == Hypno ) || ( $1 == 97 ) ) return Hypno.97.Psychic.x.85.73.70.73.115.67.Forewarn.Insomnia.Inner Focus
  if ( ( $1 == Krabby ) || ( $1 == 98 ) ) return Krabby.98.Water.x.30.105.90.25.25.50.Hyper Cutter.Shell Armor.Sheer Force
  if ( ( $1 == Kingler ) || ( $1 == 99 ) ) return Kingler.99.Water.x.55.130.115.50.50.75.Hyper Cutter.Shell Armor.Sheer Force
  if ( ( $1 == Voltorb ) || ( $1 == 100 ) ) return Voltorb.100.Electric.x.40.30.50.55.55.100.Soundproof.Static.Aftermath
  if ( ( $1 == Electrode ) || ( $1 == 101 ) ) return Electrode.101.Electric.x.60.50.70.80.80.140.Soundproof.Static.Aftermath
  if ( ( $1 == Exeggcute ) || ( $1 == 102 ) ) return Exeggcute.102.Grass.Psychic.60.40.80.60.45.40.Chlorophyll.x.Harvest
  if ( ( $1 == Exeggutor ) || ( $1 == 103 ) ) return Exeggutor.103.Grass.Psychic.95.95.85.125.65.55.Chlorophyll.x.Harvest
  if ( ( $1 == Cubone ) || ( $1 == 104 ) ) return Cubone.104.Ground.x.50.50.95.40.50.35.Lightningrod.Rock Head.Battle Armor
  if ( ( $1 == Marowak ) || ( $1 == 105 ) ) return Marowak.105.Ground.x.60.80.110.50.80.45.Lightningrod.Rock Head.Battle Armor
  if ( ( $1 == Hitmonlee ) || ( $1 == 106 ) ) return Hitmonlee.106.Fighting.x.50.120.53.35.110.87.Limber.Reckless.Unburden
  if ( ( $1 == Hitmonchan ) || ( $1 == 107 ) ) return Hitmonchan.107.Fighting.x.50.105.79.35.110.76.Iron Fist.Keen Eye.Inner Focus
  if ( ( $1 == Lickitung ) || ( $1 == 108 ) ) return Lickitung.108.Normal.x.90.55.75.60.75.30.Oblivious.Own Tempo.Cloud Nine
  if ( ( $1 == Koffing ) || ( $1 == 109 ) ) return Koffing.109.Poison.x.40.65.95.60.45.35.Levitate.x.x
  if ( ( $1 == Weezing ) || ( $1 == 110 ) ) return Weezing.110.Poison.x.65.90.120.85.70.60.Levitate.x.x
  if ( ( $1 == Rhyhorn ) || ( $1 == 111 ) ) return Rhyhorn.111.Ground.Rock.80.85.95.30.30.25.Lightningrod.Rock Head.Reckless
  if ( ( $1 == Rhydon ) || ( $1 == 112 ) ) return Rhydon.112.Ground.Rock.105.130.120.45.45.40.Lightningrod.Rock Head.Reckless
  if ( ( $1 == Chansey ) || ( $1 == 113 ) ) return Chansey.113.Normal.x.250.5.5.35.105.50.Natural Cure.Serene Grace.Healer
  if ( ( $1 == Tangela ) || ( $1 == 114 ) ) return Tangela.114.Grass.x.65.55.115.100.40.60.Chlorophyll.Leaf Guard.Regenerator
  if ( ( $1 == Kangaskhan ) || ( $1 == 115 ) ) return Kangaskhan.115.Normal.x.105.95.80.40.80.90.Early Bird.Scrappy.Inner Focus
  if ( ( $1 == Horsea ) || ( $1 == 116 ) ) return Horsea.116.Water.x.30.40.70.70.25.60.Sniper.Swift Swim.Damp
  if ( ( $1 == Seadra ) || ( $1 == 117 ) ) return Seadra.117.Water.x.55.65.95.95.45.85.Poison Point.Sniper.Damp
  if ( ( $1 == Goldeen ) || ( $1 == 118 ) ) return Goldeen.118.Water.x.45.67.60.35.50.63.Swift Swim.Water Veil.Lightningrod
  if ( ( $1 == Seaking ) || ( $1 == 119 ) ) return Seaking.119.Water.x.80.92.65.65.80.68.Swift Swim.Water Veil.Lightningrod
  if ( ( $1 == Staryu ) || ( $1 == 120 ) ) return Staryu.120.Water.x.30.45.55.70.55.85.Illuminate.Natural Cure.Analytic
  if ( ( $1 == Starmie ) || ( $1 == 121 ) ) return Starmie.121.Water.Psychic.60.75.85.100.85.115.Illuminate.Natural Cure.Analytic
  if ( ( $1 == Mr. Mime ) || ( $1 == 122 ) ) return Mr. Mime.122.Psychic.x.40.45.65.100.120.90.Soundproof.Filter.Technician
  if ( ( $1 == Scyther ) || ( $1 == 123 ) ) return Scyther.123.Bug.Flying.70.110.80.55.80.105.Swarm.Technician.Steadfast
  if ( ( $1 == Jynx ) || ( $1 == 124 ) ) return Jynx.124.Ice.Psychic.65.50.35.115.95.95.Forewarn.Oblivious.Dry Skin
  if ( ( $1 == Electabuzz ) || ( $1 == 125 ) ) return Electabuzz.125.Electric.x.65.83.57.95.85.105.Static.x.Vital Spirit
  if ( ( $1 == Magmar ) || ( $1 == 126 ) ) return Magmar.126.Fire.x.65.95.57.100.85.93.Flame Body.x.Vital Spirit
  if ( ( $1 == Pinsir ) || ( $1 == 127 ) ) return Pinsir.127.Bug.x.65.125.100.55.70.85.Hyper Cutter.Mold Breaker.Moxie
  if ( ( $1 == Tauros ) || ( $1 == 128 ) ) return Tauros.128.Normal.x.75.100.95.40.70.110.Anger Point.Intimidate.Sheer Force
  if ( ( $1 == Magikarp ) || ( $1 == 129 ) ) return Magikarp.129.Water.x.20.10.55.15.20.80.Swift Swim.x.Rattled
  if ( ( $1 == Gyarados ) || ( $1 == 130 ) ) return Gyarados.130.Water.Flying.95.125.79.60.100.81.Intimidate.x.Moxie
  if ( ( $1 == Lapras ) || ( $1 == 131 ) ) return Lapras.131.Water.Ice.130.85.80.85.95.60.Shell Armor.Water Absorb.Hydration
  if ( ( $1 == Ditto ) || ( $1 == 132 ) ) return Ditto.132.Normal.x.48.48.48.48.48.48.Limber.x.Imposter
  if ( ( $1 == Eevee ) || ( $1 == 133 ) ) return Eevee.133.Normal.x.55.55.50.45.65.55.Adaptability.Run Away.Anticipation
  if ( ( $1 == Vaporeon ) || ( $1 == 134 ) ) return Vaporeon.134.Water.x.130.65.60.110.95.65.Water Absorb.x.Hydration
  if ( ( $1 == Jolteon ) || ( $1 == 135 ) ) return Jolteon.135.Electric.x.65.65.60.110.95.130.Volt Absorb.x.Quick Feet
  if ( ( $1 == Flareon ) || ( $1 == 136 ) ) return Flareon.136.Fire.x.65.130.60.95.110.65.Flash Fire.x.Guts
  if ( ( $1 == Porygon ) || ( $1 == 137 ) ) return Porygon.137.Normal.x.65.60.70.85.75.40.Download.Trace.Analytic
  if ( ( $1 == Omanyte ) || ( $1 == 138 ) ) return Omanyte.138.Rock.Water.35.40.100.90.55.35.Shell Armor.Swift Swim.Weak Armor
  if ( ( $1 == Omastar ) || ( $1 == 139 ) ) return Omastar.139.Rock.Water.70.60.125.115.70.55.Shell Armor.Swift Swim.Weak Armor
  if ( ( $1 == Kabuto ) || ( $1 == 140 ) ) return Kabuto.140.Rock.Water.30.80.90.55.45.55.Battle Armor.Swift Swim.Weak Armor
  if ( ( $1 == Kabutops ) || ( $1 == 141 ) ) return Kabutops.141.Rock.Water.60.115.105.65.70.80.Battle Armor.Swift Swim.Weak Armor
  if ( ( $1 == Aerodactyl ) || ( $1 == 142 ) ) return Aerodactyl.142.Rock.Flying.80.105.65.60.75.130.Pressure.Rock Head.Unnerve
  if ( ( $1 == Snorlax ) || ( $1 == 143 ) ) return Snorlax.143.Normal.x.160.110.65.65.110.30.Immunity.Thick Fat.Gluttony
  if ( ( $1 == Articuno ) || ( $1 == 144 ) ) return Articuno.144.Ice.Flying.90.85.100.95.125.85.Pressure.x.Snow Cloak
  if ( ( $1 == Zapdos ) || ( $1 == 145 ) ) return Zapdos.145.Electric.Flying.90.90.85.125.90.100.Pressure.x.Lightningrod
  if ( ( $1 == Moltres ) || ( $1 == 146 ) ) return Moltres.146.Fire.Flying.90.100.90.125.85.90.Pressure.x.Flame Body
  if ( ( $1 == Dratini ) || ( $1 == 147 ) ) return Dratini.147.Dragon.x.41.64.45.50.50.50.Shed Skin.x.Marvel Scale
  if ( ( $1 == Dragonair ) || ( $1 == 148 ) ) return Dragonair.148.Dragon.x.61.84.65.70.70.70.Shed Skin.x.Marvel Scale
  if ( ( $1 == Dragonite ) || ( $1 == 149 ) ) return Dragonite.149.Dragon.Flying.91.134.95.100.100.80.Inner Focus.x.Multiscale
  if ( ( $1 == Mewtwo ) || ( $1 == 150 ) ) return Mewtwo.150.Psychic.x.106.110.90.154.90.130.Pressure.x.Unnerve
  if ( ( $1 == Mew ) || ( $1 == 151 ) ) return Mew.151.Psychic.x.100.100.100.100.100.100.Synchronize.x.x
  if ( ( $1 == Chikorita ) || ( $1 == 152 ) ) return Chikorita.152.Grass.x.45.49.65.49.65.45.Overgrow.x.Leaf Guard
  if ( ( $1 == Bayleef ) || ( $1 == 153 ) ) return Bayleef.153.Grass.x.60.62.80.63.80.60.Overgrow.x.Leaf Guard
  if ( ( $1 == Meganium ) || ( $1 == 154 ) ) return Meganium.154.Grass.x.80.82.100.83.100.80.Overgrow.x.Leaf Guard
  if ( ( $1 == Cyndaquil ) || ( $1 == 155 ) ) return Cyndaquil.155.Fire.x.39.52.43.60.50.65.Blaze.x.Flash Fire
  if ( ( $1 == Quilava ) || ( $1 == 156 ) ) return Quilava.156.Fire.x.58.64.58.80.65.80.Blaze.x.Flash Fire
  if ( ( $1 == Typhlosion ) || ( $1 == 157 ) ) return Typhlosion.157.Fire.x.78.84.78.109.85.100.Blaze.x.Flash Fire
  if ( ( $1 == Totodile ) || ( $1 == 158 ) ) return Totodile.158.Water.x.50.65.64.44.48.43.Torrent.x.Sheer Force
  if ( ( $1 == Croconaw ) || ( $1 == 159 ) ) return Croconaw.159.Water.x.65.80.80.59.63.58.Torrent.x.Sheer Force
  if ( ( $1 == Feraligatr ) || ( $1 == 160 ) ) return Feraligatr.160.Water.x.85.105.100.79.83.78.Torrent.x.Sheer Force
  if ( ( $1 == Sentret ) || ( $1 == 161 ) ) return Sentret.161.Normal.x.35.46.34.35.45.20.Keen Eye.Run Away.Frisk
  if ( ( $1 == Furret ) || ( $1 == 162 ) ) return Furret.162.Normal.x.85.76.64.45.55.90.Keen Eye.Run Away.Frisk
  if ( ( $1 == Hoothoot ) || ( $1 == 163 ) ) return Hoothoot.163.Normal.Flying.60.30.30.36.56.50.Insomnia.Keen Eye.Tinted Lens
  if ( ( $1 == Noctowl ) || ( $1 == 164 ) ) return Noctowl.164.Normal.Flying.100.50.50.76.96.70.Insomnia.Keen Eye.Tinted Lens
  if ( ( $1 == Ledyba ) || ( $1 == 165 ) ) return Ledyba.165.Bug.Flying.40.20.30.40.80.55.Swarm.Early Bird.Rattled
  if ( ( $1 == Ledian ) || ( $1 == 166 ) ) return Ledian.166.Bug.Flying.55.35.50.55.110.85.Early Bird.Swarm.Iron Fist
  if ( ( $1 == Spinarak ) || ( $1 == 167 ) ) return Spinarak.167.Bug.Poison.40.60.40.40.40.30.Insomnia.Swarm.Sniper
  if ( ( $1 == Ariados ) || ( $1 == 168 ) ) return Ariados.168.Bug.Poison.70.90.70.60.60.40.Insomnia.Swarm.Sniper
  if ( ( $1 == Crobat ) || ( $1 == 169 ) ) return Crobat.169.Poison.Flying.85.90.80.70.80.130.Inner Focus.x.Infiltrator
  if ( ( $1 == Chinchou ) || ( $1 == 170 ) ) return Chinchou.170.Water.Electric.75.38.38.56.56.67.Illuminate.Volt Absorb.Water Absorb
  if ( ( $1 == Lanturn ) || ( $1 == 171 ) ) return Lanturn.171.Water.Electric.125.58.58.76.76.67.Illuminate.Volt Absorb.Water Absorb
  if ( ( $1 == Pichu ) || ( $1 == 172 ) ) return Pichu.172.Electric.x.20.40.15.35.35.60.Static.x.Lightningrod
  if ( ( $1 == Cleffa ) || ( $1 == 173 ) ) return Cleffa.173.Normal.x.50.25.28.45.55.15.Cute Charm.Magic Guard.Friend Guard
  if ( ( $1 == Igglybuff ) || ( $1 == 174 ) ) return Igglybuff.174.Normal.x.90.30.15.40.20.15.Cute Charm.x.Friend Guard
  if ( ( $1 == Togepi ) || ( $1 == 175 ) ) return Togepi.175.Normal.x.35.20.65.40.65.20.Hustle.Serene Grace.Super Luck
  if ( ( $1 == Togetic ) || ( $1 == 176 ) ) return Togetic.176.Normal.Flying.55.40.85.80.105.40.Hustle.Serene Grace.Super Luck
  if ( ( $1 == Natu ) || ( $1 == 177 ) ) return Natu.177.Psychic.Flying.40.50.45.70.45.70.Early Bird.Synchronize.Magic Bounce
  if ( ( $1 == Xatu ) || ( $1 == 178 ) ) return Xatu.178.Psychic.Flying.65.75.70.95.70.95.Early Bird.Synchronize.Magic Bounce
  if ( ( $1 == Mareep ) || ( $1 == 179 ) ) return Mareep.179.Electric.x.55.40.40.65.45.35.Static.x.Plus
  if ( ( $1 == Flaaffy ) || ( $1 == 180 ) ) return Flaaffy.180.Electric.x.70.55.55.80.60.45.Static.x.Plus
  if ( ( $1 == Ampharos ) || ( $1 == 181 ) ) return Ampharos.181.Electric.x.90.75.75.115.90.55.Static.x.Plus
  if ( ( $1 == Bellossom ) || ( $1 == 182 ) ) return Bellossom.182.Grass.x.75.80.85.90.100.50.Chlorophyll.x.Healer
  if ( ( $1 == Marill ) || ( $1 == 183 ) ) return Marill.183.Water.x.70.20.50.20.50.40.Huge Power.Thick Fat.Sap Sipper
  if ( ( $1 == Azumarill ) || ( $1 == 184 ) ) return Azumarill.184.Water.x.100.50.80.50.80.50.Huge Power.Thick Fat.Sap Sipper
  if ( ( $1 == Sudowoodo ) || ( $1 == 185 ) ) return Sudowoodo.185.Rock.x.70.100.115.30.65.30.Rock Head.Sturdy.Rattled
  if ( ( $1 == Politoed ) || ( $1 == 186 ) ) return Politoed.186.Water.x.90.75.75.90.100.70.Damp.Water Absorb.Drizzle
  if ( ( $1 == Hoppip ) || ( $1 == 187 ) ) return Hoppip.187.Grass.Flying.35.35.40.35.55.50.Chlorophyll.Leaf Guard.Infiltrator
  if ( ( $1 == Skiploom ) || ( $1 == 188 ) ) return Skiploom.188.Grass.Flying.55.45.50.45.65.80.Chlorophyll.Leaf Guard.Infiltrator
  if ( ( $1 == Jumpluff ) || ( $1 == 189 ) ) return Jumpluff.189.Grass.Flying.75.55.70.55.85.110.Chlorophyll.Leaf Guard.Infiltrator
  if ( ( $1 == Aipom ) || ( $1 == 190 ) ) return Aipom.190.Normal.x.55.70.55.40.55.85.Pickup.Run Away.Skill Link
  if ( ( $1 == Sunkern ) || ( $1 == 191 ) ) return Sunkern.191.Grass.x.30.30.30.30.30.30.Chlorophyll.Solar Power.Early Bird
  if ( ( $1 == Sunflora ) || ( $1 == 192 ) ) return Sunflora.192.Grass.x.75.75.55.105.85.30.Chlorophyll.Solar Power.Early Bird
  if ( ( $1 == Yanma ) || ( $1 == 193 ) ) return Yanma.193.Bug.Flying.65.65.45.75.45.95.Compoundeyes.Speed Boost.Frisk
  if ( ( $1 == Wooper ) || ( $1 == 194 ) ) return Wooper.194.Water.Ground.55.45.45.25.25.15.Damp.Water Absorb.Unaware
  if ( ( $1 == Quagsire ) || ( $1 == 195 ) ) return Quagsire.195.Water.Ground.95.85.85.65.65.35.Damp.Water Absorb.Unaware
  if ( ( $1 == Espeon ) || ( $1 == 196 ) ) return Espeon.196.Psychic.x.65.65.60.130.95.110.Synchronize.x.Magic Bounce
  if ( ( $1 == Umbreon ) || ( $1 == 197 ) ) return Umbreon.197.Dark.x.95.65.110.60.130.65.Synchronize.x.Inner Focus
  if ( ( $1 == Murkrow ) || ( $1 == 198 ) ) return Murkrow.198.Dark.Flying.60.85.42.85.42.91.Insomnia.Super Luck.Prankster
  if ( ( $1 == Slowking ) || ( $1 == 199 ) ) return Slowking.199.Water.Psychic.95.75.80.100.110.30.Oblivious.Own Tempo.Regenerator
  if ( ( $1 == Misdreavus ) || ( $1 == 200 ) ) return Misdreavus.200.Ghost.x.60.60.60.85.85.85.Levitate.x.x
  if ( ( $1 == Unown ) || ( $1 == 201 ) ) return Unown.201.Psychic.x.48.72.48.72.48.48.Levitate.x.x
  if ( ( $1 == Wobbuffet ) || ( $1 == 202 ) ) return Wobbuffet.202.Psychic.x.190.33.58.33.58.33.Shadow Tag.x.Telepathy
  if ( ( $1 == Girafarig ) || ( $1 == 203 ) ) return Girafarig.203.Normal.Psychic.70.80.65.90.65.85.Early Bird.Inner Focus.Sap Sipper
  if ( ( $1 == Pineco ) || ( $1 == 204 ) ) return Pineco.204.Bug.x.50.65.90.35.35.15.Sturdy.x.Overcoat
  if ( ( $1 == Forretress ) || ( $1 == 205 ) ) return Forretress.205.Bug.Steel.75.90.140.60.60.40.Sturdy.x.Overcoat
  if ( ( $1 == Dunsparce ) || ( $1 == 206 ) ) return Dunsparce.206.Normal.x.100.70.70.65.65.45.Run Away.Serene Grace.Rattled
  if ( ( $1 == Gligar ) || ( $1 == 207 ) ) return Gligar.207.Ground.Flying.65.75.105.35.65.85.Hyper Cutter.Sand Veil.Immunity
  if ( ( $1 == Steelix ) || ( $1 == 208 ) ) return Steelix.208.Steel.Ground.75.85.200.55.65.30.Rock Head.Sturdy.Sheer Force
  if ( ( $1 == Snubbull ) || ( $1 == 209 ) ) return Snubbull.209.Normal.x.60.80.50.40.40.30.Intimidate.Run Away.Rattled
  if ( ( $1 == Granbull ) || ( $1 == 210 ) ) return Granbull.210.Normal.x.90.120.75.60.60.45.Intimidate.Quick Feet.Rattled
  if ( ( $1 == Qwilfish ) || ( $1 == 211 ) ) return Qwilfish.211.Water.Poison.65.95.75.55.55.85.Poison Point.Swift Swim.Intimidate
  if ( ( $1 == Scizor ) || ( $1 == 212 ) ) return Scizor.212.Bug.Steel.70.130.100.55.80.65.Swarm.Technician.Light Metal
  if ( ( $1 == Shuckle ) || ( $1 == 213 ) ) return Shuckle.213.Bug.Rock.20.10.230.10.230.5.Gluttony.Sturdy.Contrary
  if ( ( $1 == Heracross ) || ( $1 == 214 ) ) return Heracross.214.Bug.Fighting.80.125.75.40.95.85.Guts.Swarm.Moxie
  if ( ( $1 == Sneasel ) || ( $1 == 215 ) ) return Sneasel.215.Dark.Ice.55.95.55.35.75.115.Inner Focus.Keen Eye.Pickpocket
  if ( ( $1 == Teddiursa ) || ( $1 == 216 ) ) return Teddiursa.216.Normal.x.60.80.50.50.50.40.Pickup.Quick Feet.Honey Gather
  if ( ( $1 == Ursaring ) || ( $1 == 217 ) ) return Ursaring.217.Normal.x.90.130.75.75.75.55.Guts.Quick Feet.Unnerve
  if ( ( $1 == Slugma ) || ( $1 == 218 ) ) return Slugma.218.Fire.x.40.40.40.70.40.20.Flame Body.Magma Armor.Weak Armor
  if ( ( $1 == Magcargo ) || ( $1 == 219 ) ) return Magcargo.219.Fire.Rock.50.50.120.80.80.30.Flame Body.Magma Armor.Weak Armor
  if ( ( $1 == Swinub ) || ( $1 == 220 ) ) return Swinub.220.Ice.Ground.50.50.40.30.30.50.Oblivious.Snow Cloak.Thick Fat
  if ( ( $1 == Piloswine ) || ( $1 == 221 ) ) return Piloswine.221.Ice.Ground.100.100.80.60.60.50.Oblivious.Snow Cloak.Thick Fat
  if ( ( $1 == Corsola ) || ( $1 == 222 ) ) return Corsola.222.Water.Rock.55.55.85.65.85.35.Hustle.Natural Cure.Regenerator
  if ( ( $1 == Remoraid ) || ( $1 == 223 ) ) return Remoraid.223.Water.x.35.65.35.65.35.65.Hustle.Sniper.Moody
  if ( ( $1 == Octillery ) || ( $1 == 224 ) ) return Octillery.224.Water.x.75.105.75.105.75.45.Sniper.Suction Cups.Moody
  if ( ( $1 == Delibird ) || ( $1 == 225 ) ) return Delibird.225.Ice.Flying.45.55.45.65.45.75.Hustle.Vital Spirit.Insomnia
  if ( ( $1 == Mantine ) || ( $1 == 226 ) ) return Mantine.226.Water.Flying.65.40.70.80.140.70.Swift Swim.Water Absorb.Water Veil
  if ( ( $1 == Skarmory ) || ( $1 == 227 ) ) return Skarmory.227.Steel.Flying.65.80.140.40.70.70.Keen Eye.Sturdy.Weak Armor
  if ( ( $1 == Houndour ) || ( $1 == 228 ) ) return Houndour.228.Dark.Fire.45.60.30.80.50.65.Early Bird.Flash Fire.Unnerve
  if ( ( $1 == Houndoom ) || ( $1 == 229 ) ) return Houndoom.229.Dark.Fire.75.90.50.110.80.95.Early Bird.Flash Fire.Unnerve
  if ( ( $1 == Kingdra ) || ( $1 == 230 ) ) return Kingdra.230.Water.Dragon.75.95.95.95.95.85.Sniper.Swift Swim.Damp
  if ( ( $1 == Phanpy ) || ( $1 == 231 ) ) return Phanpy.231.Ground.x.90.60.60.40.40.40.Pickup.x.Sand Veil
  if ( ( $1 == Donphan ) || ( $1 == 232 ) ) return Donphan.232.Ground.x.90.120.120.60.60.50.Sturdy.x.Sand Veil
  if ( ( $1 == Porygon2 ) || ( $1 == 233 ) ) return Porygon2.233.Normal.x.85.80.90.105.95.60.Download.Trace.Analytic
  if ( ( $1 == Stantler ) || ( $1 == 234 ) ) return Stantler.234.Normal.x.73.95.62.85.65.85.Frisk.Intimidate.Sap Sipper
  if ( ( $1 == Smeargle ) || ( $1 == 235 ) ) return Smeargle.235.Normal.x.55.20.35.20.45.75.Own Tempo.Technician.Moody
  if ( ( $1 == Tyrogue ) || ( $1 == 236 ) ) return Tyrogue.236.Fighting.x.35.35.35.35.35.35.Guts.Steadfast.Vital Spirit
  if ( ( $1 == Hitmontop ) || ( $1 == 237 ) ) return Hitmontop.237.Fighting.x.50.95.95.35.110.70.Intimidate.Technician.Steadfast
  if ( ( $1 == Smoochum ) || ( $1 == 238 ) ) return Smoochum.238.Ice.Psychic.45.30.15.85.65.65.Forewarn.Oblivious.Hydration
  if ( ( $1 == Elekid ) || ( $1 == 239 ) ) return Elekid.239.Electric.x.45.63.37.65.55.95.Static.x.Vital Spirit
  if ( ( $1 == Magby ) || ( $1 == 240 ) ) return Magby.240.Fire.x.45.75.37.70.55.83.Flame Body.x.Vital Spirit
  if ( ( $1 == Miltank ) || ( $1 == 241 ) ) return Miltank.241.Normal.x.95.80.105.40.70.100.Scrappy.Thick Fat.Sap Sipper
  if ( ( $1 == Blissey ) || ( $1 == 242 ) ) return Blissey.242.Normal.x.255.10.10.75.135.55.Natural Cure.Serene Grace.Healer
  if ( ( $1 == Raikou ) || ( $1 == 243 ) ) return Raikou.243.Electric.x.90.85.75.115.100.115.Pressure.x.Volt Absorb
  if ( ( $1 == Entei ) || ( $1 == 244 ) ) return Entei.244.Fire.x.115.115.85.90.75.100.Pressure.x.Flash Fire
  if ( ( $1 == Suicune ) || ( $1 == 245 ) ) return Suicune.245.Water.x.100.75.115.90.115.85.Pressure.x.Water Absorb
  if ( ( $1 == Larvitar ) || ( $1 == 246 ) ) return Larvitar.246.Rock.Ground.50.64.50.45.50.41.Guts.x.Sand Veil
  if ( ( $1 == Pupitar ) || ( $1 == 247 ) ) return Pupitar.247.Rock.Ground.70.84.70.65.70.51.Shed Skin.x.x
  if ( ( $1 == Tyranitar ) || ( $1 == 248 ) ) return Tyranitar.248.Rock.Dark.100.134.110.95.100.61.Sand Stream.x.Unnerve
  if ( ( $1 == Lugia ) || ( $1 == 249 ) ) return Lugia.249.Psychic.Flying.106.90.130.90.154.110.Pressure.x.Multiscale
  if ( ( $1 == Ho-Oh ) || ( $1 == 250 ) ) return Ho-Oh.250.Fire.Flying.106.130.90.110.154.90.Pressure.x.Regenerator
  if ( ( $1 == Celebi ) || ( $1 == 251 ) ) return Celebi.251.Psychic.Grass.100.100.100.100.100.100.Natural Cure.x.x
  if ( ( $1 == Treecko ) || ( $1 == 252 ) ) return Treecko.252.Grass.x.40.45.35.65.55.70.Overgrow.x.Unburden
  if ( ( $1 == Grovyle ) || ( $1 == 253 ) ) return Grovyle.253.Grass.x.50.65.45.85.65.95.Overgrow.x.Unburden
  if ( ( $1 == Sceptile ) || ( $1 == 254 ) ) return Sceptile.254.Grass.x.70.85.65.105.85.120.Overgrow.x.Unburden
  if ( ( $1 == Torchic ) || ( $1 == 255 ) ) return Torchic.255.Fire.x.45.60.40.70.50.45.Blaze.x.Speed Boost
  if ( ( $1 == Combusken ) || ( $1 == 256 ) ) return Combusken.256.Fire.Fighting.60.85.60.85.60.55.Blaze.x.Speed Boost
  if ( ( $1 == Blaziken ) || ( $1 == 257 ) ) return Blaziken.257.Fire.Fighting.80.120.70.110.70.80.Blaze.x.Speed Boost
  if ( ( $1 == Mudkip ) || ( $1 == 258 ) ) return Mudkip.258.Water.x.50.70.50.50.50.40.Torrent.x.Damp
  if ( ( $1 == Marshtomp ) || ( $1 == 259 ) ) return Marshtomp.259.Water.Ground.70.85.70.60.70.50.Torrent.x.Damp
  if ( ( $1 == Swampert ) || ( $1 == 260 ) ) return Swampert.260.Water.Ground.100.110.90.85.90.60.Torrent.x.Damp
  if ( ( $1 == Poochyena ) || ( $1 == 261 ) ) return Poochyena.261.Dark.x.35.55.35.30.30.35.Quick Feet.Run Away.Rattled
  if ( ( $1 == Mightyena ) || ( $1 == 262 ) ) return Mightyena.262.Dark.x.70.90.70.60.60.70.Intimidate.Quick Feet.Moxie
  if ( ( $1 == Zigzagoon ) || ( $1 == 263 ) ) return Zigzagoon.263.Normal.x.38.30.41.30.41.60.Gluttony.Pickup.Quick Feet
  if ( ( $1 == Linoone ) || ( $1 == 264 ) ) return Linoone.264.Normal.x.78.70.61.50.61.100.Gluttony.Pickup.Quick Feet
  if ( ( $1 == Wurmple ) || ( $1 == 265 ) ) return Wurmple.265.Bug.x.45.45.35.20.30.20.Shield Dust.x.Run Away
  if ( ( $1 == Silcoon ) || ( $1 == 266 ) ) return Silcoon.266.Bug.x.50.35.55.25.25.15.Shed Skin.x.x
  if ( ( $1 == Beautifly ) || ( $1 == 267 ) ) return Beautifly.267.Bug.Flying.60.70.50.90.50.65.Swarm.x.Rivalry
  if ( ( $1 == Cascoon ) || ( $1 == 268 ) ) return Cascoon.268.Bug.x.50.35.55.25.25.15.Shed Skin.x.x
  if ( ( $1 == Dustox ) || ( $1 == 269 ) ) return Dustox.269.Bug.Poison.60.50.70.50.90.65.Shield Dust.x.Compoundeyes
  if ( ( $1 == Lotad ) || ( $1 == 270 ) ) return Lotad.270.Water.Grass.40.30.30.40.50.30.Rain Dish.Swift Swim.Own Tempo
  if ( ( $1 == Lombre ) || ( $1 == 271 ) ) return Lombre.271.Water.Grass.60.50.50.60.70.50.Rain Dish.Swift Swim.Own Tempo
  if ( ( $1 == Ludicolo ) || ( $1 == 272 ) ) return Ludicolo.272.Water.Grass.80.70.70.90.100.70.Rain Dish.Swift Swim.Own Tempo
  if ( ( $1 == Seedot ) || ( $1 == 273 ) ) return Seedot.273.Grass.x.40.40.50.30.30.30.Chlorophyll.Early Bird.Pickpocket
  if ( ( $1 == Nuzleaf ) || ( $1 == 274 ) ) return Nuzleaf.274.Grass.Dark.70.70.40.60.40.60.Chlorophyll.Early Bird.Pickpocket
  if ( ( $1 == Shiftry ) || ( $1 == 275 ) ) return Shiftry.275.Grass.Dark.90.100.60.90.60.80.Chlorophyll.Early Bird.Pickpocket
  if ( ( $1 == Taillow ) || ( $1 == 276 ) ) return Taillow.276.Normal.Flying.40.55.30.30.30.85.Guts.x.Scrappy
  if ( ( $1 == Swellow ) || ( $1 == 277 ) ) return Swellow.277.Normal.Flying.60.85.60.50.50.125.Guts.x.Scrappy
  if ( ( $1 == Wingull ) || ( $1 == 278 ) ) return Wingull.278.Water.Flying.40.30.30.55.30.85.Keen Eye.x.Rain Dish
  if ( ( $1 == Pelipper ) || ( $1 == 279 ) ) return Pelipper.279.Water.Flying.60.50.100.85.70.65.Keen Eye.x.Rain Dish
  if ( ( $1 == Ralts ) || ( $1 == 280 ) ) return Ralts.280.Psychic.x.28.25.25.45.35.40.Synchronize.Trace.Telepathy
  if ( ( $1 == Kirlia ) || ( $1 == 281 ) ) return Kirlia.281.Psychic.x.38.35.35.65.55.50.Synchronize.Trace.Telepathy
  if ( ( $1 == Gardevoir ) || ( $1 == 282 ) ) return Gardevoir.282.Psychic.x.68.65.65.125.115.80.Synchronize.Trace.Telepathy
  if ( ( $1 == Surskit ) || ( $1 == 283 ) ) return Surskit.283.Bug.Water.40.30.32.50.52.65.Swift Swim.x.Rain Dish
  if ( ( $1 == Masquerain ) || ( $1 == 284 ) ) return Masquerain.284.Bug.Flying.70.60.62.80.82.60.Intimidate.x.Unnerve
  if ( ( $1 == Shroomish ) || ( $1 == 285 ) ) return Shroomish.285.Grass.x.60.40.60.40.60.35.Effect Spore.Poison Heal.Quick Feet
  if ( ( $1 == Breloom ) || ( $1 == 286 ) ) return Breloom.286.Grass.Fighting.60.130.80.60.60.70.Effect Spore.Poison Heal.Technician
  if ( ( $1 == Slakoth ) || ( $1 == 287 ) ) return Slakoth.287.Normal.x.60.60.60.35.35.30.Truant.x.x
  if ( ( $1 == Vigoroth ) || ( $1 == 288 ) ) return Vigoroth.288.Normal.x.80.80.80.55.55.90.Vital Spirit.x.x
  if ( ( $1 == Slaking ) || ( $1 == 289 ) ) return Slaking.289.Normal.x.150.160.100.95.65.100.Truant.x.x
  if ( ( $1 == Nincada ) || ( $1 == 290 ) ) return Nincada.290.Bug.Ground.31.45.90.30.30.40.Compoundeyes.x.Run Away
  if ( ( $1 == Ninjask ) || ( $1 == 291 ) ) return Ninjask.291.Bug.Flying.61.90.45.50.50.160.Speed Boost.x.Infiltrator
  if ( ( $1 == Shedinja ) || ( $1 == 292 ) ) return Shedinja.292.Bug.Ghost.1.90.45.30.30.40.Wonder Guard.x.x
  if ( ( $1 == Whismur ) || ( $1 == 293 ) ) return Whismur.293.Normal.x.64.51.23.51.23.28.Soundproof.x.Rattled
  if ( ( $1 == Loudred ) || ( $1 == 294 ) ) return Loudred.294.Normal.x.84.71.43.71.43.48.Soundproof.x.Scrappy
  if ( ( $1 == Exploud ) || ( $1 == 295 ) ) return Exploud.295.Normal.x.104.91.63.91.63.68.Soundproof.x.Scrappy
  if ( ( $1 == Makuhita ) || ( $1 == 296 ) ) return Makuhita.296.Fighting.x.72.60.30.20.30.25.Guts.Thick Fat.Sheer Force
  if ( ( $1 == Hariyama ) || ( $1 == 297 ) ) return Hariyama.297.Fighting.x.144.120.60.40.60.50.Guts.Thick Fat.Sheer Force
  if ( ( $1 == Azurill ) || ( $1 == 298 ) ) return Azurill.298.Normal.x.50.20.40.20.40.20.Huge Power.Thick Fat.Sap Sipper
  if ( ( $1 == Nosepass ) || ( $1 == 299 ) ) return Nosepass.299.Rock.x.30.45.135.45.90.30.Magnet Pull.Sturdy.Sand Force
  if ( ( $1 == Skitty ) || ( $1 == 300 ) ) return Skitty.300.Normal.x.50.45.45.35.35.50.Cute Charm.Normalize.Wonder Skin
  if ( ( $1 == Delcatty ) || ( $1 == 301 ) ) return Delcatty.301.Normal.x.70.65.65.55.55.70.Cute Charm.Normalize.Wonder Skin
  if ( ( $1 == Sableye ) || ( $1 == 302 ) ) return Sableye.302.Dark.Ghost.50.75.75.65.65.50.Keen Eye.Stall.Prankster
  if ( ( $1 == Mawile ) || ( $1 == 303 ) ) return Mawile.303.Steel.x.50.85.85.55.55.50.Hyper Cutter.Intimidate.Sheer Force
  if ( ( $1 == Aron ) || ( $1 == 304 ) ) return Aron.304.Steel.Rock.50.70.100.40.40.30.Rock Head.Sturdy.Heavy Metal
  if ( ( $1 == Lairon ) || ( $1 == 305 ) ) return Lairon.305.Steel.Rock.60.90.140.50.50.40.Rock Head.Sturdy.Heavy Metal
  if ( ( $1 == Aggron ) || ( $1 == 306 ) ) return Aggron.306.Steel.Rock.70.110.180.60.60.50.Rock Head.Sturdy.Heavy Metal
  if ( ( $1 == Meditite ) || ( $1 == 307 ) ) return Meditite.307.Fighting.Psychic.30.40.55.40.55.60.Pure Power.x.Telepathy
  if ( ( $1 == Medicham ) || ( $1 == 308 ) ) return Medicham.308.Fighting.Psychic.60.60.75.60.75.80.Pure Power.x.Telepathy
  if ( ( $1 == Electrike ) || ( $1 == 309 ) ) return Electrike.309.Electric.x.40.45.40.65.40.65.Lightningrod.Static.Minus
  if ( ( $1 == Manectric ) || ( $1 == 310 ) ) return Manectric.310.Electric.x.70.75.60.105.60.105.Lightningrod.Static.Minus
  if ( ( $1 == Plusle ) || ( $1 == 311 ) ) return Plusle.311.Electric.x.60.50.40.85.75.95.Plus.x.x
  if ( ( $1 == Minun ) || ( $1 == 312 ) ) return Minun.312.Electric.x.60.40.50.75.85.95.Minus.x.x
  if ( ( $1 == Volbeat ) || ( $1 == 313 ) ) return Volbeat.313.Bug.x.65.73.55.47.75.85.Illuminate.Swarm.Prankster
  if ( ( $1 == Illumise ) || ( $1 == 314 ) ) return Illumise.314.Bug.x.65.47.55.73.75.85.Oblivious.Tinted Lens.Prankster
  if ( ( $1 == Roselia ) || ( $1 == 315 ) ) return Roselia.315.Grass.Poison.50.60.45.100.80.65.Natural Cure.Poison Point.Leaf Guard
  if ( ( $1 == Gulpin ) || ( $1 == 316 ) ) return Gulpin.316.Poison.x.70.43.53.43.53.40.Liquid Ooze.Sticky Hold.Gluttony
  if ( ( $1 == Swalot ) || ( $1 == 317 ) ) return Swalot.317.Poison.x.100.73.83.73.83.55.Liquid Ooze.Sticky Hold.Gluttony
  if ( ( $1 == Carvanha ) || ( $1 == 318 ) ) return Carvanha.318.Water.Dark.45.90.20.65.20.65.Rough Skin.x.Speed Boost
  if ( ( $1 == Sharpedo ) || ( $1 == 319 ) ) return Sharpedo.319.Water.Dark.70.120.40.95.40.95.Rough Skin.x.Speed Boost
  if ( ( $1 == Wailmer ) || ( $1 == 320 ) ) return Wailmer.320.Water.x.130.70.35.70.35.60.Oblivious.Water Veil.Pressure
  if ( ( $1 == Wailord ) || ( $1 == 321 ) ) return Wailord.321.Water.x.170.90.45.90.45.60.Oblivious.Water Veil.Pressure
  if ( ( $1 == Numel ) || ( $1 == 322 ) ) return Numel.322.Fire.Ground.60.60.40.65.45.35.Oblivious.Simple.Own Tempo
  if ( ( $1 == Camerupt ) || ( $1 == 323 ) ) return Camerupt.323.Fire.Ground.70.100.70.105.75.40.Magma Armor.Solid Rock.Anger Point
  if ( ( $1 == Torkoal ) || ( $1 == 324 ) ) return Torkoal.324.Fire.x.70.85.140.85.70.20.White Smoke.x.Shell Armor
  if ( ( $1 == Spoink ) || ( $1 == 325 ) ) return Spoink.325.Psychic.x.60.25.35.70.80.60.Own Tempo.Thick Fat.Gluttony
  if ( ( $1 == Grumpig ) || ( $1 == 326 ) ) return Grumpig.326.Psychic.x.80.45.65.90.110.80.Own Tempo.Thick Fat.Gluttony
  if ( ( $1 == Spinda ) || ( $1 == 327 ) ) return Spinda.327.Normal.x.60.60.60.60.60.60.Own Tempo.Tangled Feet.Contrary
  if ( ( $1 == Trapinch ) || ( $1 == 328 ) ) return Trapinch.328.Ground.x.45.100.45.45.45.10.Arena Trap.Hyper Cutter.Sheer Force
  if ( ( $1 == Vibrava ) || ( $1 == 329 ) ) return Vibrava.329.Ground.Dragon.50.70.50.50.50.70.Levitate.x.x
  if ( ( $1 == Flygon ) || ( $1 == 330 ) ) return Flygon.330.Ground.Dragon.80.100.80.80.80.100.Levitate.x.x
  if ( ( $1 == Cacnea ) || ( $1 == 331 ) ) return Cacnea.331.Grass.x.50.85.40.85.40.35.Sand Veil.x.Water Absorb
  if ( ( $1 == Cacturne ) || ( $1 == 332 ) ) return Cacturne.332.Grass.Dark.70.115.60.115.60.55.Sand Veil.x.Water Absorb
  if ( ( $1 == Swablu ) || ( $1 == 333 ) ) return Swablu.333.Normal.Flying.45.40.60.40.75.50.Natural Cure.x.Cloud Nine
  if ( ( $1 == Altaria ) || ( $1 == 334 ) ) return Altaria.334.Dragon.Flying.75.70.90.70.105.80.Natural Cure.x.Cloud Nine
  if ( ( $1 == Zangoose ) || ( $1 == 335 ) ) return Zangoose.335.Normal.x.73.115.60.60.60.90.Immunity.x.Toxic Boost
  if ( ( $1 == Seviper ) || ( $1 == 336 ) ) return Seviper.336.Poison.x.73.100.60.100.60.65.Shed Skin.x.Infiltrator
  if ( ( $1 == Lunatone ) || ( $1 == 337 ) ) return Lunatone.337.Rock.Psychic.70.55.65.95.85.70.Levitate.x.x
  if ( ( $1 == Solrock ) || ( $1 == 338 ) ) return Solrock.338.Rock.Psychic.70.95.85.55.65.70.Levitate.x.x
  if ( ( $1 == Barboach ) || ( $1 == 339 ) ) return Barboach.339.Water.Ground.50.48.43.46.41.60.Anticipation.Oblivious.Hydration
  if ( ( $1 == Whiscash ) || ( $1 == 340 ) ) return Whiscash.340.Water.Ground.110.78.73.76.71.60.Anticipation.Oblivious.Hydration
  if ( ( $1 == Corphish ) || ( $1 == 341 ) ) return Corphish.341.Water.x.43.80.65.50.35.35.Hyper Cutter.Shell Armor.Adaptability
  if ( ( $1 == Crawdaunt ) || ( $1 == 342 ) ) return Crawdaunt.342.Water.Dark.63.120.85.90.55.55.Hyper Cutter.Shell Armor.Adaptability
  if ( ( $1 == Baltoy ) || ( $1 == 343 ) ) return Baltoy.343.Ground.Psychic.40.40.55.40.70.55.Levitate.x.x
  if ( ( $1 == Claydol ) || ( $1 == 344 ) ) return Claydol.344.Ground.Psychic.60.70.105.70.120.75.Levitate.x.x
  if ( ( $1 == Lileep ) || ( $1 == 345 ) ) return Lileep.345.Rock.Grass.66.41.77.61.87.23.Suction Cups.x.Storm Drain
  if ( ( $1 == Cradily ) || ( $1 == 346 ) ) return Cradily.346.Rock.Grass.86.81.97.81.107.43.Suction Cups.x.Storm Drain
  if ( ( $1 == Anorith ) || ( $1 == 347 ) ) return Anorith.347.Rock.Bug.45.95.50.40.50.75.Battle Armor.x.Swift Swim
  if ( ( $1 == Armaldo ) || ( $1 == 348 ) ) return Armaldo.348.Rock.Bug.75.125.100.70.80.45.Battle Armor.x.Swift Swim
  if ( ( $1 == Feebas ) || ( $1 == 349 ) ) return Feebas.349.Water.x.20.15.20.10.55.80.Swift Swim.x.Adaptability
  if ( ( $1 == Milotic ) || ( $1 == 350 ) ) return Milotic.350.Water.x.95.60.79.100.125.81.Marvel Scale.x.Cute Charm
  if ( ( $1 == Castform ) || ( $1 == 351 ) ) return Castform.351.Normal.x.70.70.70.70.70.70.Forecast.x.x
  if ( ( $1 == Kecleon ) || ( $1 == 352 ) ) return Kecleon.352.Normal.x.60.90.70.60.120.40.Color Change.x.x
  if ( ( $1 == Shuppet ) || ( $1 == 353 ) ) return Shuppet.353.Ghost.x.44.75.35.63.33.45.Frisk.Insomnia.Cursed Body
  if ( ( $1 == Banette ) || ( $1 == 354 ) ) return Banette.354.Ghost.x.64.115.65.83.63.65.Frisk.Insomnia.Cursed Body
  if ( ( $1 == Duskull ) || ( $1 == 355 ) ) return Duskull.355.Ghost.x.20.40.90.30.90.25.Levitate.x.x
  if ( ( $1 == Dusclops ) || ( $1 == 356 ) ) return Dusclops.356.Ghost.x.40.70.130.60.130.25.Pressure.x.x
  if ( ( $1 == Tropius ) || ( $1 == 357 ) ) return Tropius.357.Grass.Flying.99.68.83.72.87.51.Chlorophyll.Solar Power.Harvest
  if ( ( $1 == Chimecho ) || ( $1 == 358 ) ) return Chimecho.358.Psychic.x.65.50.70.95.80.65.Levitate.x.x
  if ( ( $1 == Absol ) || ( $1 == 359 ) ) return Absol.359.Dark.x.65.130.60.75.60.75.Pressure.Super Luck.Justified
  if ( ( $1 == Wynaut ) || ( $1 == 360 ) ) return Wynaut.360.Psychic.x.95.23.48.23.48.23.Shadow Tag.x.Telepathy
  if ( ( $1 == Snorunt ) || ( $1 == 361 ) ) return Snorunt.361.Ice.x.50.50.50.50.50.50.Ice Body.Inner Focus.Moody
  if ( ( $1 == Glalie ) || ( $1 == 362 ) ) return Glalie.362.Ice.x.80.80.80.80.80.80.Ice Body.Inner Focus.Moody
  if ( ( $1 == Spheal ) || ( $1 == 363 ) ) return Spheal.363.Ice.Water.70.40.50.55.50.25.Ice Body.Thick Fat.Oblivious
  if ( ( $1 == Sealeo ) || ( $1 == 364 ) ) return Sealeo.364.Ice.Water.90.60.70.75.70.45.Ice Body.Thick Fat.Oblivious
  if ( ( $1 == Walrein ) || ( $1 == 365 ) ) return Walrein.365.Ice.Water.110.80.90.95.90.65.Ice Body.Thick Fat.Oblivious
  if ( ( $1 == Clamperl ) || ( $1 == 366 ) ) return Clamperl.366.Water.x.35.64.85.74.55.32.Shell Armor.x.Rattled
  if ( ( $1 == Huntail ) || ( $1 == 367 ) ) return Huntail.367.Water.x.55.104.105.94.75.52.Swift Swim.x.Water Veil
  if ( ( $1 == Gorebyss ) || ( $1 == 368 ) ) return Gorebyss.368.Water.x.55.84.105.114.75.52.Swift Swim.x.Hydration
  if ( ( $1 == Relicanth ) || ( $1 == 369 ) ) return Relicanth.369.Water.Rock.100.90.130.45.65.55.Rock Head.Swift Swim.Sturdy
  if ( ( $1 == Luvdisc ) || ( $1 == 370 ) ) return Luvdisc.370.Water.x.43.30.55.40.65.97.Swift Swim.x.Hydration
  if ( ( $1 == Bagon ) || ( $1 == 371 ) ) return Bagon.371.Dragon.x.45.75.60.40.30.50.Rock Head.x.Sheer Force
  if ( ( $1 == Shelgon ) || ( $1 == 372 ) ) return Shelgon.372.Dragon.x.65.95.100.60.50.50.Rock Head.x.Overcoat
  if ( ( $1 == Salamence ) || ( $1 == 373 ) ) return Salamence.373.Dragon.Flying.95.135.80.110.80.100.Intimidate.x.Moxie
  if ( ( $1 == Beldum ) || ( $1 == 374 ) ) return Beldum.374.Steel.Psychic.40.55.80.35.60.30.Clear Body.x.Light Metal
  if ( ( $1 == Metang ) || ( $1 == 375 ) ) return Metang.375.Steel.Psychic.60.75.100.55.80.50.Clear Body.x.Light Metal
  if ( ( $1 == Metagross ) || ( $1 == 376 ) ) return Metagross.376.Steel.Psychic.80.135.130.95.90.70.Clear Body.x.Light Metal
  if ( ( $1 == Regirock ) || ( $1 == 377 ) ) return Regirock.377.Rock.x.80.100.200.50.100.50.Clear Body.x.Sturdy
  if ( ( $1 == Regice ) || ( $1 == 378 ) ) return Regice.378.Ice.x.80.50.100.100.200.50.Clear Body.x.Ice Body
  if ( ( $1 == Registeel ) || ( $1 == 379 ) ) return Registeel.379.Steel.x.80.75.150.75.150.50.Clear Body.x.Light Metal
  if ( ( $1 == Latias ) || ( $1 == 380 ) ) return Latias.380.Dragon.Psychic.80.80.90.110.130.110.Levitate.x.x
  if ( ( $1 == Latios ) || ( $1 == 381 ) ) return Latios.381.Dragon.Psychic.80.90.80.130.110.110.Levitate.x.x
  if ( ( $1 == Kyogre ) || ( $1 == 382 ) ) return Kyogre.382.Water.x.100.100.90.150.140.90.Drizzle.x.x
  if ( ( $1 == Groudon ) || ( $1 == 383 ) ) return Groudon.383.Ground.x.100.150.140.100.90.90.Drought.x.x
  if ( ( $1 == Rayquaza ) || ( $1 == 384 ) ) return Rayquaza.384.Dragon.Flying.105.150.90.150.90.95.Air Lock.x.x
  if ( ( $1 == Jirachi ) || ( $1 == 385 ) ) return Jirachi.385.Steel.Psychic.100.100.100.100.100.100.Serene Grace.x.x
  if ( ( $1 == Deoxys ) || ( $1 == 386 ) ) return Deoxys.386.Psychic.x.50.150.50.150.50.150.Pressure.x.x
  if ( $1 == Deoxys-a ) return Deoxys-a.386.Psychic.x.50.180.20.180.20.150.Pressure.x.x
  if ( $1 == Deoxys-d ) return Deoxys-d.386.Psychic.x.50.70.160.70.160.90.Pressure.x.x
  if ( $1 == Deoxys-s ) return Deoxys-s.386.Psychic.x.50.95.90.95.90.180.Pressure.x.x
  if ( ( $1 == Turtwig ) || ( $1 == 387 ) ) return Turtwig.387.Grass.x.55.68.64.45.55.31.Overgrow.x.Shell Armor
  if ( ( $1 == Grotle ) || ( $1 == 388 ) ) return Grotle.388.Grass.x.75.89.85.55.65.36.Overgrow.x.Shell Armor
  if ( ( $1 == Torterra ) || ( $1 == 389 ) ) return Torterra.389.Grass.Ground.95.109.105.75.85.56.Overgrow.x.Shell Armor
  if ( ( $1 == Chimchar ) || ( $1 == 390 ) ) return Chimchar.390.Fire.x.44.58.44.58.44.61.Blaze.x.Iron Fist
  if ( ( $1 == Monferno ) || ( $1 == 391 ) ) return Monferno.391.Fire.Fighting.64.78.52.78.52.81.Blaze.x.Iron Fist
  if ( ( $1 == Infernape ) || ( $1 == 392 ) ) return Infernape.392.Fire.Fighting.76.104.71.104.71.108.Blaze.x.Iron Fist
  if ( ( $1 == Piplup ) || ( $1 == 393 ) ) return Piplup.393.Water.x.53.51.53.61.56.40.Torrent.x.Defiant
  if ( ( $1 == Prinplup ) || ( $1 == 394 ) ) return Prinplup.394.Water.x.64.66.68.81.76.50.Torrent.x.Defiant
  if ( ( $1 == Empoleon ) || ( $1 == 395 ) ) return Empoleon.395.Water.Steel.84.86.88.111.101.60.Torrent.x.Defiant
  if ( ( $1 == Starly ) || ( $1 == 396 ) ) return Starly.396.Normal.Flying.40.55.30.30.30.60.Keen Eye.x.x
  if ( ( $1 == Staravia ) || ( $1 == 397 ) ) return Staravia.397.Normal.Flying.55.75.50.40.40.80.Intimidate.x.Reckless
  if ( ( $1 == Staraptor ) || ( $1 == 398 ) ) return Staraptor.398.Normal.Flying.85.120.70.50.50.100.Intimidate.x.Reckless
  if ( ( $1 == Bidoof ) || ( $1 == 399 ) ) return Bidoof.399.Normal.x.59.45.40.35.40.31.Simple.Unaware.Moody
  if ( ( $1 == Bibarel ) || ( $1 == 400 ) ) return Bibarel.400.Normal.Water.79.85.60.55.60.71.Simple.Unaware.Moody
  if ( ( $1 == Kricketot ) || ( $1 == 401 ) ) return Kricketot.401.Bug.x.37.25.41.25.41.25.Shed Skin.x.Run Away
  if ( ( $1 == Kricketune ) || ( $1 == 402 ) ) return Kricketune.402.Bug.x.77.85.51.55.51.65.Swarm.x.Technician
  if ( ( $1 == Shinx ) || ( $1 == 403 ) ) return Shinx.403.Electric.x.45.65.34.40.34.45.Intimidate.Rivalry.Guts
  if ( ( $1 == Luxio ) || ( $1 == 404 ) ) return Luxio.404.Electric.x.60.85.49.60.49.60.Intimidate.Rivalry.Guts
  if ( ( $1 == Luxray ) || ( $1 == 405 ) ) return Luxray.405.Electric.x.80.120.79.95.79.70.Intimidate.Rivalry.Guts
  if ( ( $1 == Budew ) || ( $1 == 406 ) ) return Budew.406.Grass.Poison.40.30.35.50.70.55.Natural Cure.Poison Point.Leaf Guard
  if ( ( $1 == Roserade ) || ( $1 == 407 ) ) return Roserade.407.Grass.Poison.60.70.55.125.105.90.Natural Cure.Poison Point.Technician
  if ( ( $1 == Cranidos ) || ( $1 == 408 ) ) return Cranidos.408.Rock.x.67.125.40.30.30.58.Mold Breaker.x.Sheer Force
  if ( ( $1 == Rampardos ) || ( $1 == 409 ) ) return Rampardos.409.Rock.x.97.165.60.65.50.58.Mold Breaker.x.Sheer Force
  if ( ( $1 == Shieldon ) || ( $1 == 410 ) ) return Shieldon.410.Rock.Steel.30.42.118.42.88.30.Sturdy.x.Soundproof
  if ( ( $1 == Bastiodon ) || ( $1 == 411 ) ) return Bastiodon.411.Rock.Steel.60.52.168.47.138.30.Sturdy.x.Soundproof
  if ( ( $1 == Burmy ) || ( $1 == 412 ) ) return Burmy.412.Bug.x.40.29.45.29.45.36.Shed Skin.x.Overcoat
  if ( $1 == Burmy-g ) return Burmy-g.412.Bug.x.40.29.45.29.45.36.Shed Skin.x.Overcoat
  if ( $1 == Burmy-s ) return Burmy-s.412.Bug.x.40.29.45.29.45.36.Shed Skin.x.Overcoat
  if ( ( $1 == Wormadam ) || ( $1 == 413 ) ) return Wormadam.413.Bug.Grass.60.59.85.79.105.36.Anticipation.x.Overcoat
  if ( $1 == Wormadam-g ) return Wormadam-g.413.Bug.Ground.60.79.105.59.85.36.Anticipation.x.Overcoat
  if ( $1 == Wormadam-s ) return Wormadam-s.413.Bug.Steel.60.69.95.69.95.36.Anticipation.x.Overcoat
  if ( ( $1 == Mothim ) || ( $1 == 414 ) ) return Mothim.414.Bug.Flying.70.94.50.94.50.66.Swarm.x.Tinted Lens
  if ( ( $1 == Combee ) || ( $1 == 415 ) ) return Combee.415.Bug.Flying.30.30.42.30.42.70.Honey Gather.x.Hustle
  if ( ( $1 == Vespiquen ) || ( $1 == 416 ) ) return Vespiquen.416.Bug.Flying.70.80.102.80.102.40.Pressure.x.Unnerve
  if ( ( $1 == Pachirisu ) || ( $1 == 417 ) ) return Pachirisu.417.Electric.x.60.45.70.45.90.95.Pickup.Run Away.Volt Absorb
  if ( ( $1 == Buizel ) || ( $1 == 418 ) ) return Buizel.418.Water.x.55.65.35.60.30.85.Swift Swim.x.Water Veil
  if ( ( $1 == Floatzel ) || ( $1 == 419 ) ) return Floatzel.419.Water.x.85.105.55.85.50.115.Swift Swim.x.Water Veil
  if ( ( $1 == Cherubi ) || ( $1 == 420 ) ) return Cherubi.420.Grass.x.45.35.45.62.53.35.Chlorophyll.x.x
  if ( ( $1 == Cherrim ) || ( $1 == 421 ) ) return Cherrim.421.Grass.x.70.60.70.87.78.85.Flower Gift.x.x
  if ( ( $1 == Shellos ) || ( $1 == 422 ) ) return Shellos.422.Water.x.76.48.48.57.62.34.Sticky Hold.Storm Drain.Sand Force
  if ( ( $1 == Gastrodon ) || ( $1 == 423 ) ) return Gastrodon.423.Water.Ground.111.83.68.92.82.39.Sticky Hold.Storm Drain.Sand Force
  if ( ( $1 == Ambipom ) || ( $1 == 424 ) ) return Ambipom.424.Normal.x.75.100.66.60.66.115.Pickup.Technician.Skill Link
  if ( ( $1 == Drifloon ) || ( $1 == 425 ) ) return Drifloon.425.Ghost.Flying.90.50.34.60.44.70.Aftermath.Unburden.Flare Boost
  if ( ( $1 == Drifblim ) || ( $1 == 426 ) ) return Drifblim.426.Ghost.Flying.150.80.44.90.54.80.Aftermath.Unburden.Flare Boost
  if ( ( $1 == Buneary ) || ( $1 == 427 ) ) return Buneary.427.Normal.x.55.66.44.44.56.85.Klutz.Run Away.Limber
  if ( ( $1 == Lopunny ) || ( $1 == 428 ) ) return Lopunny.428.Normal.x.65.76.84.54.96.105.Cute Charm.Klutz.Limber
  if ( ( $1 == Mismagius ) || ( $1 == 429 ) ) return Mismagius.429.Ghost.x.60.60.60.105.105.105.Levitate.x.x
  if ( ( $1 == Honchkrow ) || ( $1 == 430 ) ) return Honchkrow.430.Dark.Flying.100.125.52.105.52.71.Insomnia.Super Luck.Moxie
  if ( ( $1 == Glameow ) || ( $1 == 431 ) ) return Glameow.431.Normal.x.49.55.42.42.37.85.Limber.Own Tempo.Keen Eye
  if ( ( $1 == Purugly ) || ( $1 == 432 ) ) return Purugly.432.Normal.x.71.82.64.64.59.112.Own Tempo.Thick Fat.Defiant
  if ( ( $1 == Chingling ) || ( $1 == 433 ) ) return Chingling.433.Psychic.x.45.30.50.65.50.45.Levitate.x.x
  if ( ( $1 == Stunky ) || ( $1 == 434 ) ) return Stunky.434.Poison.Dark.63.63.47.41.41.74.Aftermath.Stench.Keen Eye
  if ( ( $1 == Skuntank ) || ( $1 == 435 ) ) return Skuntank.435.Poison.Dark.103.93.67.71.61.84.Aftermath.Stench.Keen Eye
  if ( ( $1 == Bronzor ) || ( $1 == 436 ) ) return Bronzor.436.Steel.Psychic.57.24.86.24.86.23.Heatproof.Levitate.Heavy Metal
  if ( ( $1 == Bronzong ) || ( $1 == 437 ) ) return Bronzong.437.Steel.Psychic.67.89.116.79.116.33.Heatproof.Levitate.Heavy Metal
  if ( ( $1 == Bonsly ) || ( $1 == 438 ) ) return Bonsly.438.Rock.x.50.80.95.10.45.10.Rock Head.Sturdy.Rattled
  if ( ( $1 == Mime Jr. ) || ( $1 == 439 ) ) return Mime Jr..439.Psychic.x.20.25.45.70.90.60.Soundproof.Filter.Technician
  if ( ( $1 == Happiny ) || ( $1 == 440 ) ) return Happiny.440.Normal.x.100.5.5.15.65.30.Natural Cure.Serene Grace.Friend Guard
  if ( ( $1 == Chatot ) || ( $1 == 441 ) ) return Chatot.441.Normal.Flying.76.65.45.92.42.91.Keen Eye.Tangled Feet.Big Pecks
  if ( ( $1 == Spiritomb ) || ( $1 == 442 ) ) return Spiritomb.442.Ghost.Dark.50.92.108.92.108.35.Pressure.x.Infiltrator
  if ( ( $1 == Gible ) || ( $1 == 443 ) ) return Gible.443.Dragon.Ground.58.70.45.40.45.42.Sand Veil.x.Rough Skin
  if ( ( $1 == Gabite ) || ( $1 == 444 ) ) return Gabite.444.Dragon.Ground.68.90.65.50.55.82.Sand Veil.x.Rough Skin
  if ( ( $1 == Garchomp ) || ( $1 == 445 ) ) return Garchomp.445.Dragon.Ground.108.130.95.80.85.102.Sand Veil.x.Rough Skin
  if ( ( $1 == Munchlax ) || ( $1 == 446 ) ) return Munchlax.446.Normal.x.135.85.40.40.85.5.Pickup.Thick Fat.Gluttony
  if ( ( $1 == Riolu ) || ( $1 == 447 ) ) return Riolu.447.Fighting.x.40.70.40.35.40.60.Inner Focus.Steadfast.Prankster
  if ( ( $1 == Lucario ) || ( $1 == 448 ) ) return Lucario.448.Fighting.Steel.70.110.70.115.70.90.Inner Focus.Steadfast.Justified
  if ( ( $1 == Hippopotas ) || ( $1 == 449 ) ) return Hippopotas.449.Ground.x.68.72.78.38.42.32.Sand Stream.x.Sand Force
  if ( ( $1 == Hippowdon ) || ( $1 == 450 ) ) return Hippowdon.450.Ground.x.108.112.118.68.72.47.Sand Stream.x.Sand Force
  if ( ( $1 == Skorupi ) || ( $1 == 451 ) ) return Skorupi.451.Poison.Bug.40.50.90.30.55.65.Battle Armor.Sniper.Keen Eye
  if ( ( $1 == Drapion ) || ( $1 == 452 ) ) return Drapion.452.Poison.Dark.70.90.110.60.75.95.Battle Armor.Sniper.Keen Eye
  if ( ( $1 == Croagunk ) || ( $1 == 453 ) ) return Croagunk.453.Poison.Fighting.48.61.40.61.40.50.Anticipation.Dry Skin.Poison Touch
  if ( ( $1 == Toxicroak ) || ( $1 == 454 ) ) return Toxicroak.454.Poison.Fighting.83.106.65.86.65.85.Anticipation.Dry Skin.Poison Touch
  if ( ( $1 == Carnivine ) || ( $1 == 455 ) ) return Carnivine.455.Grass.x.74.100.72.90.72.46.Levitate.x.x
  if ( ( $1 == Finneon ) || ( $1 == 456 ) ) return Finneon.456.Water.x.49.49.56.49.61.66.Storm Drain.Swift Swim.Water Veil
  if ( ( $1 == Lumineon ) || ( $1 == 457 ) ) return Lumineon.457.Water.x.69.69.76.69.86.91.Storm Drain.Swift Swim.Water Veil
  if ( ( $1 == Mantyke ) || ( $1 == 458 ) ) return Mantyke.458.Water.Flying.45.20.50.60.120.50.Swift Swim.Water Absorb.Water Veil
  if ( ( $1 == Snover ) || ( $1 == 459 ) ) return Snover.459.Grass.Ice.60.62.50.62.60.40.Snow Warning.x.Soundproof
  if ( ( $1 == Abomasnow ) || ( $1 == 460 ) ) return Abomasnow.460.Grass.Ice.90.92.75.92.85.60.Snow Warning.x.Soundproof
  if ( ( $1 == Weavile ) || ( $1 == 461 ) ) return Weavile.461.Dark.Ice.70.120.65.45.85.125.Pressure.x.Pickpocket
  if ( ( $1 == Magnezone ) || ( $1 == 462 ) ) return Magnezone.462.Electric.Steel.70.70.115.130.90.60.Magnet Pull.Sturdy.Analytic
  if ( ( $1 == Lickilicky ) || ( $1 == 463 ) ) return Lickilicky.463.Normal.x.110.85.95.80.95.50.Oblivious.Own Tempo.Cloud Nine
  if ( ( $1 == Rhyperior ) || ( $1 == 464 ) ) return Rhyperior.464.Ground.Rock.115.140.130.55.55.40.Lightningrod.Solid Rock.Reckless
  if ( ( $1 == Tangrowth ) || ( $1 == 465 ) ) return Tangrowth.465.Grass.x.100.100.125.110.50.50.Chlorophyll.Leaf Guard.Regenerator
  if ( ( $1 == Electivire ) || ( $1 == 466 ) ) return Electivire.466.Electric.x.75.123.67.95.85.95.Motor Drive.x.Vital Spirit
  if ( ( $1 == Magmortar ) || ( $1 == 467 ) ) return Magmortar.467.Fire.x.75.95.67.125.95.83.Flame Body.x.Vital Spirit
  if ( ( $1 == Togekiss ) || ( $1 == 468 ) ) return Togekiss.468.Normal.Flying.85.50.95.120.115.80.Hustle.Serene Grace.Super Luck
  if ( ( $1 == Yanmega ) || ( $1 == 469 ) ) return Yanmega.469.Bug.Flying.86.76.86.116.56.95.Speed Boost.Tinted Lens.Frisk
  if ( ( $1 == Leafeon ) || ( $1 == 470 ) ) return Leafeon.470.Grass.x.65.110.130.60.65.95.Leaf Guard.x.Chlorophyll
  if ( ( $1 == Glaceon ) || ( $1 == 471 ) ) return Glaceon.471.Ice.x.65.60.110.130.95.65.Snow Cloak.x.Ice Body
  if ( ( $1 == Gliscor ) || ( $1 == 472 ) ) return Gliscor.472.Ground.Flying.75.95.125.45.75.95.Hyper Cutter.Sand Veil.Poison Heal
  if ( ( $1 == Mamoswine ) || ( $1 == 473 ) ) return Mamoswine.473.Ice.Ground.110.130.80.70.60.80.Oblivious.Snow Cloak.Thick Fat
  if ( ( $1 == Porygon-Z ) || ( $1 == 474 ) ) return Porygon-Z.474.Normal.x.85.80.70.135.75.90.Adaptability.Download.Analytic
  if ( ( $1 == Gallade ) || ( $1 == 475 ) ) return Gallade.475.Psychic.Fighting.68.125.65.65.115.80.Steadfast.x.Justified
  if ( ( $1 == Probopass ) || ( $1 == 476 ) ) return Probopass.476.Rock.Steel.60.55.145.75.150.40.Magnet Pull.Sturdy.Sand Force
  if ( ( $1 == Dusknoir ) || ( $1 == 477 ) ) return Dusknoir.477.Ghost.x.45.100.135.65.135.45.Pressure.x.x
  if ( ( $1 == Froslass ) || ( $1 == 478 ) ) return Froslass.478.Ice.Ghost.70.80.70.80.70.110.Snow Cloak.x.Cursed Body
  if ( ( $1 == Rotom ) || ( $1 == 479 ) ) return Rotom.479.Electric.Ghost.50.50.77.95.77.91.Levitate.x.x
  if ( $1 == Rotom-c ) return Rotom-c.479.Electric.Grass.50.65.107.105.107.86.Levitate.x.x
  if ( $1 == Rotom-f ) return Rotom-f.479.Electric.Ice.50.65.107.105.107.86.Levitate.x.x
  if ( $1 == Rotom-h ) return Rotom-h.479.Electric.Fire.50.65.107.105.107.86.Levitate.x.x
  if ( $1 == Rotom-s ) return Rotom-s.479.Electric.Flying.50.65.107.105.107.86.Levitate.x.x
  if ( $1 == Rotom-w ) return Rotom-w.479.Electric.Water.50.65.107.105.107.86.Levitate.x.x
  if ( ( $1 == Uxie ) || ( $1 == 480 ) ) return Uxie.480.Psychic.x.75.75.130.75.130.95.Levitate.x.x
  if ( ( $1 == Mesprit ) || ( $1 == 481 ) ) return Mesprit.481.Psychic.x.80.105.105.105.105.80.Levitate.x.x
  if ( ( $1 == Azelf ) || ( $1 == 482 ) ) return Azelf.482.Psychic.x.75.125.70.125.70.115.Levitate.x.x
  if ( ( $1 == Dialga ) || ( $1 == 483 ) ) return Dialga.483.Steel.Dragon.100.120.120.150.100.90.Pressure.x.Telepathy
  if ( ( $1 == Palkia ) || ( $1 == 484 ) ) return Palkia.484.Water.Dragon.90.120.100.150.120.100.Pressure.x.Telepathy
  if ( ( $1 == Heatran ) || ( $1 == 485 ) ) return Heatran.485.Fire.Steel.91.90.106.130.106.77.Flash Fire.x.Flame Body
  if ( ( $1 == Regigigas ) || ( $1 == 486 ) ) return Regigigas.486.Normal.x.110.160.110.80.110.100.Slow Start.x.x
  if ( ( $1 == Giratina ) || ( $1 == 487 ) ) return Giratina.487.Ghost.Dragon.150.100.120.100.120.90.Pressure.x.Telepathy
  if ( $1 == Giratina-o ) return Giratina-o.487.Ghost.Dragon.150.120.100.120.100.90.Levitate.x.Telepathy
  if ( ( $1 == Cresselia ) || ( $1 == 488 ) ) return Cresselia.488.Psychic.x.120.70.120.75.130.85.Levitate.x.x
  if ( ( $1 == Phione ) || ( $1 == 489 ) ) return Phione.489.Water.x.80.80.80.80.80.80.Hydration.x.x
  if ( ( $1 == Manaphy ) || ( $1 == 490 ) ) return Manaphy.490.Water.x.100.100.100.100.100.100.Hydration.x.x
  if ( ( $1 == Darkrai ) || ( $1 == 491 ) ) return Darkrai.491.Dark.x.70.90.90.135.90.125.Bad Dreams.x.x
  if ( ( $1 == Shaymin ) || ( $1 == 492 ) ) return Shaymin.492.Grass.x.100.100.100.100.100.100.Natural Cure.x.x
  if ( $1 == Shaymin-s ) return Shaymin-s.492.Grass.Flying.100.103.75.120.75.100.Serene Grace.x.x
  if ( ( $1 == Arceus ) || ( $1 == 493 ) ) return Arceus.493.Normal.x.120.120.120.120.120.120.Multitype.x.x
  if ( ( $1 == Victini ) || ( $1 == 494 ) ) return Victini.494.Psychic.Fire.100.100.100.100.100.100.Victory Star.x.x
  if ( ( $1 == Snivy ) || ( $1 == 495 ) ) return Snivy.495.Grass.x.45.45.55.45.55.63.Overgrow.x.Contrary
  if ( ( $1 == Servine ) || ( $1 == 496 ) ) return Servine.496.Grass.x.60.60.75.60.75.83.Overgrow.x.Contrary
  if ( ( $1 == Serperior ) || ( $1 == 497 ) ) return Serperior.497.Grass.x.75.75.95.75.95.113.Overgrow.x.Contrary
  if ( ( $1 == Tepig ) || ( $1 == 498 ) ) return Tepig.498.Fire.x.65.63.45.45.45.45.Blaze.x.Thick Fat
  if ( ( $1 == Pignite ) || ( $1 == 499 ) ) return Pignite.499.Fire.Fighting.90.93.55.70.55.55.Blaze.x.Thick Fat
  if ( ( $1 == Emboar ) || ( $1 == 500 ) ) return Emboar.500.Fire.Fighting.110.123.65.100.65.65.Blaze.x.Reckless
  if ( ( $1 == Oshawott ) || ( $1 == 501 ) ) return Oshawott.501.Water.x.55.55.45.63.45.45.Torrent.x.Shell Armor
  if ( ( $1 == Dewott ) || ( $1 == 502 ) ) return Dewott.502.Water.x.75.75.60.83.60.60.Torrent.x.Shell Armor
  if ( ( $1 == Samurott ) || ( $1 == 503 ) ) return Samurott.503.Water.x.95.100.85.108.70.70.Torrent.x.Shell Armor
  if ( ( $1 == Patrat ) || ( $1 == 504 ) ) return Patrat.504.Normal.x.45.55.39.35.39.42.Keen Eye.Run Away.Analytic
  if ( ( $1 == Watchog ) || ( $1 == 505 ) ) return Watchog.505.Normal.x.60.85.69.60.69.77.Illuminate.Keen Eye.Analytic
  if ( ( $1 == Lillipup ) || ( $1 == 506 ) ) return Lillipup.506.Normal.x.45.60.45.25.45.55.Pickup.Vital Spirit.Run Away
  if ( ( $1 == Herdier ) || ( $1 == 507 ) ) return Herdier.507.Normal.x.65.80.65.35.65.60.Intimidate.Sand Rush.Scrappy
  if ( ( $1 == Stoutland ) || ( $1 == 508 ) ) return Stoutland.508.Normal.x.85.100.90.45.90.80.Intimidate.Sand Rush.Scrappy
  if ( ( $1 == Purrloin ) || ( $1 == 509 ) ) return Purrloin.509.Dark.x.41.50.37.50.37.66.Limber.Unburden.Prankster
  if ( ( $1 == Liepard ) || ( $1 == 510 ) ) return Liepard.510.Dark.x.64.88.50.88.50.106.Limber.Unburden.Prankster
  if ( ( $1 == Pansage ) || ( $1 == 511 ) ) return Pansage.511.Grass.x.50.53.48.53.48.64.Gluttony.x.Overgrow
  if ( ( $1 == Simisage ) || ( $1 == 512 ) ) return Simisage.512.Grass.x.75.98.63.98.63.101.Gluttony.x.Overgrow
  if ( ( $1 == Pansear ) || ( $1 == 513 ) ) return Pansear.513.Fire.x.50.53.48.53.48.64.Gluttony.x.Blaze
  if ( ( $1 == Simisear ) || ( $1 == 514 ) ) return Simisear.514.Fire.x.75.98.63.98.63.101.Gluttony.x.Blaze
  if ( ( $1 == Panpour ) || ( $1 == 515 ) ) return Panpour.515.Water.x.50.53.48.53.48.64.Gluttony.x.Torrent
  if ( ( $1 == Simipour ) || ( $1 == 516 ) ) return Simipour.516.Water.x.75.98.63.98.63.101.Gluttony.x.Torrent
  if ( ( $1 == Munna ) || ( $1 == 517 ) ) return Munna.517.Psychic.x.76.25.45.67.55.24.Forewarn.Synchronize.Telepathy
  if ( ( $1 == Musharna ) || ( $1 == 518 ) ) return Musharna.518.Psychic.x.116.55.85.107.95.29.Forewarn.Synchronize.Telepathy
  if ( ( $1 == Pidove ) || ( $1 == 519 ) ) return Pidove.519.Normal.Flying.50.55.50.36.30.43.Big Pecks.Super Luck.Rivalry
  if ( ( $1 == Tranquill ) || ( $1 == 520 ) ) return Tranquill.520.Normal.Flying.62.77.62.50.42.65.Big Pecks.Super Luck.Rivalry
  if ( ( $1 == Unfezant ) || ( $1 == 521 ) ) return Unfezant.521.Normal.Flying.80.105.80.65.55.93.Big Pecks.Super Luck.Rivalry
  if ( ( $1 == Blitzle ) || ( $1 == 522 ) ) return Blitzle.522.Electric.x.45.60.32.50.32.76.Lightningrod.Motor Drive.Sap Sipper
  if ( ( $1 == Zebstrika ) || ( $1 == 523 ) ) return Zebstrika.523.Electric.x.75.100.63.80.63.116.Lightningrod.Motor Drive.Sap Sipper
  if ( ( $1 == Roggenrola ) || ( $1 == 524 ) ) return Roggenrola.524.Rock.x.55.75.85.25.25.15.Sturdy.x.Sand Force
  if ( ( $1 == Boldore ) || ( $1 == 525 ) ) return Boldore.525.Rock.x.70.105.105.50.40.20.Sturdy.x.Sand Force
  if ( ( $1 == Gigalith ) || ( $1 == 526 ) ) return Gigalith.526.Rock.x.85.135.130.60.70.25.Sturdy.x.Sand Force
  if ( ( $1 == Woobat ) || ( $1 == 527 ) ) return Woobat.527.Psychic.Flying.55.45.43.55.43.72.Klutz.Unaware.Simple
  if ( ( $1 == Swoobat ) || ( $1 == 528 ) ) return Swoobat.528.Psychic.Flying.67.57.55.77.55.114.Klutz.Unaware.Simple
  if ( ( $1 == Drilbur ) || ( $1 == 529 ) ) return Drilbur.529.Ground.x.60.85.40.30.45.68.Sand Force.Sand Rush.Mold Breaker
  if ( ( $1 == Excadrill ) || ( $1 == 530 ) ) return Excadrill.530.Ground.Steel.110.135.60.50.65.88.Sand Force.Sand Rush.Mold Breaker
  if ( ( $1 == Audino ) || ( $1 == 531 ) ) return Audino.531.Normal.x.103.60.86.60.86.50.Healer.Regenerator.Klutz
  if ( ( $1 == Timburr ) || ( $1 == 532 ) ) return Timburr.532.Fighting.x.75.80.55.25.35.35.Guts.Sheer Force.Iron Fist
  if ( ( $1 == Gurdurr ) || ( $1 == 533 ) ) return Gurdurr.533.Fighting.x.85.105.85.40.50.40.Guts.Sheer Force.Iron Fist
  if ( ( $1 == Conkeldurr ) || ( $1 == 534 ) ) return Conkeldurr.534.Fighting.x.105.140.95.55.65.45.Guts.Sheer Force.Iron Fist
  if ( ( $1 == Tympole ) || ( $1 == 535 ) ) return Tympole.535.Water.x.50.50.40.50.40.64.Hydration.Swift Swim.Water Absorb
  if ( ( $1 == Palpitoad ) || ( $1 == 536 ) ) return Palpitoad.536.Water.Ground.75.65.55.65.55.69.Hydration.Swift Swim.Water Absorb
  if ( ( $1 == Seismitoad ) || ( $1 == 537 ) ) return Seismitoad.537.Water.Ground.105.85.75.85.75.74.Poison Touch.Swift Swim.Water Absorb
  if ( ( $1 == Throh ) || ( $1 == 538 ) ) return Throh.538.Fighting.x.120.100.85.30.85.45.Guts.Inner Focus.Mold Breaker
  if ( ( $1 == Sawk ) || ( $1 == 539 ) ) return Sawk.539.Fighting.x.75.125.75.30.75.85.Inner Focus.Sturdy.Mold Breaker
  if ( ( $1 == Sewaddle ) || ( $1 == 540 ) ) return Sewaddle.540.Bug.Grass.45.53.70.40.60.42.Chlorophyll.Swarm.Overcoat
  if ( ( $1 == Swadloon ) || ( $1 == 541 ) ) return Swadloon.541.Bug.Grass.55.63.90.50.80.42.Chlorophyll.Leaf Guard.Overcoat
  if ( ( $1 == Leavanny ) || ( $1 == 542 ) ) return Leavanny.542.Bug.Grass.75.103.80.70.70.92.Chlorophyll.Swarm.Overcoat
  if ( ( $1 == Venipede ) || ( $1 == 543 ) ) return Venipede.543.Bug.Poison.30.45.59.30.39.57.Poison Point.Swarm.Speed Boost
  if ( ( $1 == Whirlipede ) || ( $1 == 544 ) ) return Whirlipede.544.Bug.Poison.40.55.99.40.79.47.Poison Point.Swarm.Speed Boost
  if ( ( $1 == Scolipede ) || ( $1 == 545 ) ) return Scolipede.545.Bug.Poison.60.90.89.55.69.112.Poison Point.Swarm.Speed Boost
  if ( ( $1 == Cottonee ) || ( $1 == 546 ) ) return Cottonee.546.Grass.x.40.27.60.37.50.66.Infiltrator.Prankster.Chlorophyll
  if ( ( $1 == Whimsicott ) || ( $1 == 547 ) ) return Whimsicott.547.Grass.x.60.67.85.77.75.116.Infiltrator.Prankster.Chlorophyll
  if ( ( $1 == Petilil ) || ( $1 == 548 ) ) return Petilil.548.Grass.x.45.35.50.70.50.30.Chlorophyll.Own Tempo.Leaf Guard
  if ( ( $1 == Lilligant ) || ( $1 == 549 ) ) return Lilligant.549.Grass.x.70.60.75.110.75.90.Chlorophyll.Own Tempo.Leaf Guard
  if ( ( $1 == Basculin ) || ( $1 == 550 ) ) return Basculin.550.Water.x.70.92.65.80.55.98.Adaptability.Reckless.Mold Breaker
  if ( ( $1 == Sandile ) || ( $1 == 551 ) ) return Sandile.551.Ground.Dark.50.72.35.35.35.65.Intimidate.Moxie.Anger Point
  if ( ( $1 == Krokorok ) || ( $1 == 552 ) ) return Krokorok.552.Ground.Dark.60.82.45.45.45.74.Intimidate.Moxie.Anger Point
  if ( ( $1 == Krookodile ) || ( $1 == 553 ) ) return Krookodile.553.Ground.Dark.95.117.70.65.70.92.Intimidate.Moxie.Anger Point
  if ( ( $1 == Darumaka ) || ( $1 == 554 ) ) return Darumaka.554.Fire.x.70.90.45.15.45.50.Hustle.x.Inner Focus
  if ( ( $1 == Darmanitan ) || ( $1 == 555 ) ) return Darmanitan.555.Fire.x.105.140.55.30.55.95.Sheer Force.x.Zen Mode
  if ( $1 == Darmanitan-z ) return Darmanitan-z.555.Fire.Psychic.105.30.105.140.105.55.Sheer Force.x.Zen Mode
  if ( ( $1 == Maractus ) || ( $1 == 556 ) ) return Maractus.556.Grass.x.75.86.67.106.67.60.Chlorophyll.Water Absorb.Storm Drain
  if ( ( $1 == Dwebble ) || ( $1 == 557 ) ) return Dwebble.557.Bug.Rock.50.65.85.35.35.55.Shell Armor.Sturdy.Weak Armor
  if ( ( $1 == Crustle ) || ( $1 == 558 ) ) return Crustle.558.Bug.Rock.70.95.125.65.75.45.Shell Armor.Sturdy.Weak Armor
  if ( ( $1 == Scraggy ) || ( $1 == 559 ) ) return Scraggy.559.Dark.Fighting.50.75.70.35.70.48.Moxie.Shed Skin.Intimidate
  if ( ( $1 == Scrafty ) || ( $1 == 560 ) ) return Scrafty.560.Dark.Fighting.65.90.115.45.115.58.Moxie.Shed Skin.Intimidate
  if ( ( $1 == Sigilyph ) || ( $1 == 561 ) ) return Sigilyph.561.Psychic.Flying.72.58.80.103.80.97.Magic Guard.Wonder Skin.Tinted Lens
  if ( ( $1 == Yamask ) || ( $1 == 562 ) ) return Yamask.562.Ghost.x.38.30.85.55.65.30.Mummy.x.x
  if ( ( $1 == Cofagrigus ) || ( $1 == 563 ) ) return Cofagrigus.563.Ghost.x.58.50.145.95.105.30.Mummy.x.x
  if ( ( $1 == Tirtouga ) || ( $1 == 564 ) ) return Tirtouga.564.Water.Rock.54.78.103.53.45.22.Solid Rock.Sturdy.Swift Swim
  if ( ( $1 == Carracosta ) || ( $1 == 565 ) ) return Carracosta.565.Water.Rock.74.108.133.83.65.32.Solid Rock.Sturdy.Swift Swim
  if ( ( $1 == Archen ) || ( $1 == 566 ) ) return Archen.566.Rock.Flying.55.112.45.74.45.70.Defeatist.x.x
  if ( ( $1 == Archeops ) || ( $1 == 567 ) ) return Archeops.567.Rock.Flying.75.140.65.112.65.110.Defeatist.x.x
  if ( ( $1 == Trubbish ) || ( $1 == 568 ) ) return Trubbish.568.Poison.x.50.50.62.40.62.65.Stench.Sticky Hold.Aftermath
  if ( ( $1 == Garbodor ) || ( $1 == 569 ) ) return Garbodor.569.Poison.x.80.95.82.60.82.75.Stench.Weak Armor.Aftermath
  if ( ( $1 == Zorua ) || ( $1 == 570 ) ) return Zorua.570.Dark.x.40.65.40.80.40.65.Illusion.x.x
  if ( ( $1 == Zoroark ) || ( $1 == 571 ) ) return Zoroark.571.Dark.x.60.105.60.120.60.105.Illusion.x.x
  if ( ( $1 == Minccino ) || ( $1 == 572 ) ) return Minccino.572.Normal.x.55.50.40.40.40.75.Cute Charm.Technician.Skill Link
  if ( ( $1 == Cinccino ) || ( $1 == 573 ) ) return Cinccino.573.Normal.x.75.95.60.65.60.115.Cute Charm.Technician.Skill Link
  if ( ( $1 == Gothita ) || ( $1 == 574 ) ) return Gothita.574.Psychic.x.45.30.50.55.65.45.Frisk.x.Shadow Tag
  if ( ( $1 == Gothorita ) || ( $1 == 575 ) ) return Gothorita.575.Psychic.x.60.45.70.75.85.55.Frisk.x.Shadow Tag
  if ( ( $1 == Gothitelle ) || ( $1 == 576 ) ) return Gothitelle.576.Psychic.x.70.55.95.95.110.65.Frisk.x.Shadow Tag
  if ( ( $1 == Solosis ) || ( $1 == 577 ) ) return Solosis.577.Psychic.x.45.30.40.105.50.20.Magic Guard.Overcoat.Regenerator
  if ( ( $1 == Duosion ) || ( $1 == 578 ) ) return Duosion.578.Psychic.x.65.40.50.125.60.30.Magic Guard.Overcoat.Regenerator
  if ( ( $1 == Reuniclus ) || ( $1 == 579 ) ) return Reuniclus.579.Psychic.x.110.65.75.125.85.30.Magic Guard.Overcoat.Regenerator
  if ( ( $1 == Ducklett ) || ( $1 == 580 ) ) return Ducklett.580.Water.Flying.62.44.50.44.50.55.Big Pecks.Keen Eye.Hydration
  if ( ( $1 == Swanna ) || ( $1 == 581 ) ) return Swanna.581.Water.Flying.75.87.63.87.63.98.Big Pecks.Keen Eye.Hydration
  if ( ( $1 == Vanillite ) || ( $1 == 582 ) ) return Vanillite.582.Ice.x.36.50.50.65.60.44.Ice Body.x.Weak Armor
  if ( ( $1 == Vanillish ) || ( $1 == 583 ) ) return Vanillish.583.Ice.x.51.65.65.80.75.59.Ice Body.x.Weak Armor
  if ( ( $1 == Vanilluxe ) || ( $1 == 584 ) ) return Vanilluxe.584.Ice.x.71.95.85.110.95.79.Ice Body.x.Weak Armor
  if ( ( $1 == Deerling ) || ( $1 == 585 ) ) return Deerling.585.Normal.Grass.60.60.50.40.50.75.Chlorophyll.Sap Sipper.Serene Grace
  if ( ( $1 == Sawsbuck ) || ( $1 == 586 ) ) return Sawsbuck.586.Normal.Grass.80.100.70.60.70.95.Chlorophyll.Sap Sipper.Serene Grace
  if ( ( $1 == Emolga ) || ( $1 == 587 ) ) return Emolga.587.Electric.Flying.55.75.60.75.60.103.Static.x.Motor Drive
  if ( ( $1 == Karrablast ) || ( $1 == 588 ) ) return Karrablast.588.Bug.x.50.75.45.40.45.60.Shed Skin.Swarm.No Guard
  if ( ( $1 == Escavalier ) || ( $1 == 589 ) ) return Escavalier.589.Bug.Steel.70.135.105.60.105.20.Shell Armor.Swarm.Overcoat
  if ( ( $1 == Foongus ) || ( $1 == 590 ) ) return Foongus.590.Grass.Poison.69.55.45.55.55.15.Effect Spore.x.Regenerator
  if ( ( $1 == Amoonguss ) || ( $1 == 591 ) ) return Amoonguss.591.Grass.Poison.114.85.70.85.80.30.Effect Spore.x.Regenerator
  if ( ( $1 == Frillish ) || ( $1 == 592 ) ) return Frillish.592.Water.Ghost.55.40.50.65.85.40.Cursed Body.Water Absorb.Damp
  if ( ( $1 == Jellicent ) || ( $1 == 593 ) ) return Jellicent.593.Water.Ghost.100.60.70.85.105.60.Cursed Body.Water Absorb.Damp
  if ( ( $1 == Alomomola ) || ( $1 == 594 ) ) return Alomomola.594.Water.x.165.75.80.40.45.65.Healer.Hydration.Regenerator
  if ( ( $1 == Joltik ) || ( $1 == 595 ) ) return Joltik.595.Bug.Electric.50.47.50.57.50.65.Compoundeyes.Unnerve.Swarm
  if ( ( $1 == Galvantula ) || ( $1 == 596 ) ) return Galvantula.596.Bug.Electric.70.77.60.97.60.108.Compoundeyes.Unnerve.Swarm
  if ( ( $1 == Ferroseed ) || ( $1 == 597 ) ) return Ferroseed.597.Grass.Steel.44.50.91.24.86.10.Iron Barbs.x.x
  if ( ( $1 == Ferrothorn ) || ( $1 == 598 ) ) return Ferrothorn.598.Grass.Steel.74.94.131.54.116.20.Iron Barbs.x.x
  if ( ( $1 == Klink ) || ( $1 == 599 ) ) return Klink.599.Steel.x.40.55.70.45.60.30.Minus.Plus.Clear Body
  if ( ( $1 == Klang ) || ( $1 == 600 ) ) return Klang.600.Steel.x.60.80.95.70.85.50.Minus.Plus.Clear Body
  if ( ( $1 == Klinklang ) || ( $1 == 601 ) ) return Klinklang.601.Steel.x.60.100.115.70.85.90.Minus.Plus.Clear Body
  if ( ( $1 == Tynamo ) || ( $1 == 602 ) ) return Tynamo.602.Electric.x.35.55.40.45.40.60.Levitate.x.x
  if ( ( $1 == Eelektrik ) || ( $1 == 603 ) ) return Eelektrik.603.Electric.x.65.85.70.75.70.40.Levitate.x.x
  if ( ( $1 == Eelektross ) || ( $1 == 604 ) ) return Eelektross.604.Electric.x.85.115.80.105.80.50.Levitate.x.x
  if ( ( $1 == Elgyem ) || ( $1 == 605 ) ) return Elgyem.605.Psychic.x.55.55.55.85.55.30.Synchronize.Telepathy.Analytic
  if ( ( $1 == Beheeyem ) || ( $1 == 606 ) ) return Beheeyem.606.Psychic.x.75.75.75.125.95.40.Synchronize.Telepathy.Analytic
  if ( ( $1 == Litwick ) || ( $1 == 607 ) ) return Litwick.607.Ghost.Fire.50.30.55.65.55.20.Flame Body.Flash Fire.Shadow Tag
  if ( ( $1 == Lampent ) || ( $1 == 608 ) ) return Lampent.608.Ghost.Fire.60.40.60.95.60.55.Flame Body.Flash Fire.Shadow Tag
  if ( ( $1 == Chandelure ) || ( $1 == 609 ) ) return Chandelure.609.Ghost.Fire.60.55.90.145.90.80.Flame Body.Flash Fire.Shadow Tag
  if ( ( $1 == Axew ) || ( $1 == 610 ) ) return Axew.610.Dragon.x.46.87.60.30.40.57.Mold Breaker.Rivalry.Unnerve
  if ( ( $1 == Fraxure ) || ( $1 == 611 ) ) return Fraxure.611.Dragon.x.66.117.70.40.50.67.Mold Breaker.Rivalry.Unnerve
  if ( ( $1 == Haxorus ) || ( $1 == 612 ) ) return Haxorus.612.Dragon.x.76.147.90.60.70.97.Mold Breaker.Rivalry.Unnerve
  if ( ( $1 == Cubchoo ) || ( $1 == 613 ) ) return Cubchoo.613.Ice.x.55.70.40.60.40.40.Snow Cloak.x.Rattled
  if ( ( $1 == Beartic ) || ( $1 == 614 ) ) return Beartic.614.Ice.x.95.110.80.70.80.50.Snow Cloak.x.Swift Swim
  if ( ( $1 == Cryogonal ) || ( $1 == 615 ) ) return Cryogonal.615.Ice.x.70.50.30.95.135.105.Levitate.x.x
  if ( ( $1 == Shelmet ) || ( $1 == 616 ) ) return Shelmet.616.Bug.x.50.40.85.40.65.25.Hydration.Shell Armor.Overcoat
  if ( ( $1 == Accelgor ) || ( $1 == 617 ) ) return Accelgor.617.Bug.x.80.70.40.100.60.145.Hydration.Sticky Hold.Unburden
  if ( ( $1 == Stunfisk ) || ( $1 == 618 ) ) return Stunfisk.618.Ground.Electric.109.66.84.81.99.32.Limber.Static.Sand Veil
  if ( ( $1 == Mienfoo ) || ( $1 == 619 ) ) return Mienfoo.619.Fighting.x.45.85.50.55.50.65.Inner Focus.Regenerator.Reckless
  if ( ( $1 == Mienshao ) || ( $1 == 620 ) ) return Mienshao.620.Fighting.x.65.125.60.95.60.105.Inner Focus.Regenerator.Reckless
  if ( ( $1 == Druddigon ) || ( $1 == 621 ) ) return Druddigon.621.Dragon.x.77.120.90.60.90.48.Rough Skin.Sheer Force.Mold Breaker
  if ( ( $1 == Golett ) || ( $1 == 622 ) ) return Golett.622.Ground.Ghost.59.74.50.35.50.35.Iron Fist.Klutz.No Guard
  if ( ( $1 == Golurk ) || ( $1 == 623 ) ) return Golurk.623.Ground.Ghost.89.124.80.55.80.55.Iron Fist.Klutz.No Guard
  if ( ( $1 == Pawniard ) || ( $1 == 624 ) ) return Pawniard.624.Dark.Steel.45.85.70.40.40.60.Defiant.Inner Focus.Pressure
  if ( ( $1 == Bisharp ) || ( $1 == 625 ) ) return Bisharp.625.Dark.Steel.65.125.100.60.70.70.Defiant.Inner Focus.Pressure
  if ( ( $1 == Bouffalant ) || ( $1 == 626 ) ) return Bouffalant.626.Normal.x.95.110.95.40.95.55.Reckless.Sap Sipper.Soundproof
  if ( ( $1 == Rufflet ) || ( $1 == 627 ) ) return Rufflet.627.Normal.Flying.70.83.50.37.50.60.Keen Eye.Sheer Force.Hustle
  if ( ( $1 == Braviary ) || ( $1 == 628 ) ) return Braviary.628.Normal.Flying.100.123.75.57.75.80.Keen Eye.Sheer Force.Defiant
  if ( ( $1 == Vullaby ) || ( $1 == 629 ) ) return Vullaby.629.Dark.Flying.70.55.75.45.65.60.Big Pecks.Overcoat.Weak Armor
  if ( ( $1 == Mandibuzz ) || ( $1 == 630 ) ) return Mandibuzz.630.Dark.Flying.110.65.105.55.95.80.Big Pecks.Overcoat.Weak Armor
  if ( ( $1 == Heatmor ) || ( $1 == 631 ) ) return Heatmor.631.Fire.x.85.97.66.105.66.65.Flash Fire.Gluttony.White Smoke
  if ( ( $1 == Durant ) || ( $1 == 632 ) ) return Durant.632.Bug.Steel.58.109.112.48.48.109.Hustle.Swarm.Truant
  if ( ( $1 == Deino ) || ( $1 == 633 ) ) return Deino.633.Dark.Dragon.52.65.50.45.50.38.Hustle.x.x
  if ( ( $1 == Zweilous ) || ( $1 == 634 ) ) return Zweilous.634.Dark.Dragon.72.85.70.65.70.58.Hustle.x.x
  if ( ( $1 == Hydreigon ) || ( $1 == 635 ) ) return Hydreigon.635.Dark.Dragon.92.105.90.125.90.98.Levitate.x.x
  if ( ( $1 == Larvesta ) || ( $1 == 636 ) ) return Larvesta.636.Bug.Fire.55.85.55.50.55.60.Flame Body.x.Swarm
  if ( ( $1 == Volcarona ) || ( $1 == 637 ) ) return Volcarona.637.Bug.Fire.85.60.65.135.105.100.Flame Body.x.Swarm
  if ( ( $1 == Cobalion ) || ( $1 == 638 ) ) return Cobalion.638.Steel.Fighting.91.90.129.90.72.108.Justified.x.x
  if ( ( $1 == Terrakion ) || ( $1 == 639 ) ) return Terrakion.639.Rock.Fighting.91.129.90.72.90.108.Justified.x.x
  if ( ( $1 == Virizion ) || ( $1 == 640 ) ) return Virizion.640.Grass.Fighting.91.90.72.90.129.108.Justified.x.x
  if ( ( $1 == Tornadus ) || ( $1 == 641 ) ) return Tornadus.641.Flying.x.79.115.70.125.80.111.Prankster.x.Defiant
  if ( ( $1 == Thundurus ) || ( $1 == 642 ) ) return Thundurus.642.Electric.Flying.79.115.70.125.80.111.Prankster.x.Defiant
  if ( ( $1 == Reshiram ) || ( $1 == 643 ) ) return Reshiram.643.Dragon.Fire.100.120.100.150.120.90.Turboblaze.x.x
  if ( ( $1 == Zekrom ) || ( $1 == 644 ) ) return Zekrom.644.Dragon.Electric.100.150.120.120.100.90.Teravolt.x.x
  if ( ( $1 == Landorus ) || ( $1 == 645 ) ) return Landorus.645.Ground.Flying.89.125.90.115.80.101.Sand Force.x.Sheer Force
  if ( ( $1 == Kyurem ) || ( $1 == 646 ) ) return Kyurem.646.Dragon.Ice.125.130.90.130.90.95.Pressure.x.x
  if ( ( $1 == Keldeo ) || ( $1 == 647 ) ) return Keldeo.647.Water.Fighting.91.72.90.129.90.108.Justified.x.x
  if ( ( $1 == Meloetta ) || ( $1 == 648 ) ) return Meloetta.648.Normal.Psychic.100.77.77.128.128.90.Serene Grace.x.x
  if ( $1 == Meloetta-p ) return Meloetta-p.648.Normal.Fighting.100.128.90.77.77.128.Serene Grace.x.x
  if ( ( $1 == Genesect ) || ( $1 == 649 ) ) return Genesect.649.Bug.Steel.71.120.95.120.95.99.Download.x.x
}
alias -l Item {
  if ( ( $1 == Absorb Bulb ) || ( $1 == 1 ) ) return Absorb Bulb
  if ( ( $1 == Adamant Orb ) || ( $1 == 2 ) ) return Adamant Orb
  if ( ( $1 == Aguav Berry ) || ( $1 == 3 ) ) return Aguav Berry
  if ( ( $1 == Air Balloon ) || ( $1 == 4 ) ) return Air Balloon
  if ( ( $1 == Amulet Coin ) || ( $1 == 5 ) ) return Amulet Coin
  if ( ( $1 == Apicot Berry ) || ( $1 == 6 ) ) return Apicot Berry
  if ( ( $1 == Aspear Berry ) || ( $1 == 7 ) ) return Aspear Berry
  if ( ( $1 == Babiri Berry ) || ( $1 == 8 ) ) return Babiri Berry
  if ( ( $1 == Belue Berry ) || ( $1 == 9 ) ) return Belue Berry
  if ( ( $1 == Big Root ) || ( $1 == 10 ) ) return Big Root
  if ( ( $1 == Binding Band ) || ( $1 == 11 ) ) return Binding Band
  if ( ( $1 == Black Belt ) || ( $1 == 12 ) ) return Black Belt
  if ( ( $1 == Black Sludge ) || ( $1 == 13 ) ) return Black Sludge
  if ( ( $1 == BlackGlasses ) || ( $1 == 14 ) ) return BlackGlasses
  if ( ( $1 == Blue Scarf ) || ( $1 == 15 ) ) return Blue Scarf
  if ( ( $1 == Bluk Berry ) || ( $1 == 16 ) ) return Bluk Berry
  if ( ( $1 == Bright Powder ) || ( $1 == 17 ) ) return Bright Powder
  if ( ( $1 == Bug Gem ) || ( $1 == 18 ) ) return Bug Gem
  if ( ( $1 == Burn Drive ) || ( $1 == 19 ) ) return Burn Drive
  if ( ( $1 == Cell Battery ) || ( $1 == 20 ) ) return Cell Battery
  if ( ( $1 == Charcoal ) || ( $1 == 21 ) ) return Charcoal
  if ( ( $1 == Charti Berry ) || ( $1 == 22 ) ) return Charti Berry
  if ( ( $1 == Cheri Berry ) || ( $1 == 23 ) ) return Cheri Berry
  if ( ( $1 == Chesto Berry ) || ( $1 == 24 ) ) return Chesto Berry
  if ( ( $1 == Chilan Berry ) || ( $1 == 25 ) ) return Chilan Berry
  if ( ( $1 == Chill Drive ) || ( $1 == 26 ) ) return Chill Drive
  if ( ( $1 == Choice Band ) || ( $1 == 27 ) ) return Choice Band
  if ( ( $1 == Choice Scarf ) || ( $1 == 28 ) ) return Choice Scarf
  if ( ( $1 == Choice Specs ) || ( $1 == 29 ) ) return Choice Specs
  if ( ( $1 == Chople Berry ) || ( $1 == 30 ) ) return Chople Berry
  if ( ( $1 == Cleanse Tag ) || ( $1 == 31 ) ) return Cleanse Tag
  if ( ( $1 == Coba Berry ) || ( $1 == 32 ) ) return Coba Berry
  if ( ( $1 == Colbur Berry ) || ( $1 == 33 ) ) return Colbur Berry
  if ( ( $1 == Cornn Berry ) || ( $1 == 34 ) ) return Cornn Berry
  if ( ( $1 == Custap Berry ) || ( $1 == 35 ) ) return Custap Berry
  if ( ( $1 == Damp Rock ) || ( $1 == 36 ) ) return Damp Rock
  if ( ( $1 == Dark Gem ) || ( $1 == 37 ) ) return Dark Gem
  if ( ( $1 == Deepseascale ) || ( $1 == 38 ) ) return Deepseascale
  if ( ( $1 == Deepseatooth ) || ( $1 == 39 ) ) return Deepseatooth
  if ( ( $1 == Destiny Knot ) || ( $1 == 40 ) ) return Destiny Knot
  if ( ( $1 == Douse Drive ) || ( $1 == 41 ) ) return Douse Drive
  if ( ( $1 == Draco Plate ) || ( $1 == 42 ) ) return Draco Plate
  if ( ( $1 == Dragon Fang ) || ( $1 == 43 ) ) return Dragon Fang
  if ( ( $1 == Dragon Gem ) || ( $1 == 44 ) ) return Dragon Gem
  if ( ( $1 == Dread Plate ) || ( $1 == 45 ) ) return Dread Plate
  if ( ( $1 == Durin Berry ) || ( $1 == 46 ) ) return Durin Berry
  if ( ( $1 == Earth Plate ) || ( $1 == 47 ) ) return Earth Plate
  if ( ( $1 == Eject Button ) || ( $1 == 48 ) ) return Eject Button
  if ( ( $1 == Electric Gem ) || ( $1 == 49 ) ) return Electric Gem
  if ( ( $1 == Enigma Berry ) || ( $1 == 50 ) ) return Enigma Berry
  if ( ( $1 == Everstone ) || ( $1 == 51 ) ) return Everstone
  if ( ( $1 == Eviolite ) || ( $1 == 52 ) ) return Eviolite
  if ( ( $1 == Exp. Share ) || ( $1 == 53 ) ) return Exp. Share
  if ( ( $1 == Expert Belt ) || ( $1 == 54 ) ) return Expert Belt
  if ( ( $1 == Fighting Gem ) || ( $1 == 55 ) ) return Fighting Gem
  if ( ( $1 == Figy Berry ) || ( $1 == 56 ) ) return Figy Berry
  if ( ( $1 == Fire Gem ) || ( $1 == 57 ) ) return Fire Gem
  if ( ( $1 == Fist Plate ) || ( $1 == 58 ) ) return Fist Plate
  if ( ( $1 == Flame Orb ) || ( $1 == 59 ) ) return Flame Orb
  if ( ( $1 == Flame Plate ) || ( $1 == 60 ) ) return Flame Plate
  if ( ( $1 == Float Stone ) || ( $1 == 61 ) ) return Float Stone
  if ( ( $1 == Flying Gem ) || ( $1 == 62 ) ) return Flying Gem
  if ( ( $1 == Focus Band ) || ( $1 == 63 ) ) return Focus Band
  if ( ( $1 == Focus Sash ) || ( $1 == 64 ) ) return Focus Sash
  if ( ( $1 == Full Incense ) || ( $1 == 65 ) ) return Full Incense
  if ( ( $1 == Ganlon Berry ) || ( $1 == 66 ) ) return Ganlon Berry
  if ( ( $1 == Ghost Gem ) || ( $1 == 67 ) ) return Ghost Gem
  if ( ( $1 == Grass Gem ) || ( $1 == 68 ) ) return Grass Gem
  if ( ( $1 == Green Scarf ) || ( $1 == 69 ) ) return Green Scarf
  if ( ( $1 == Grepa Berry ) || ( $1 == 70 ) ) return Grepa Berry
  if ( ( $1 == Grip Claw ) || ( $1 == 71 ) ) return Grip Claw
  if ( ( $1 == Griseous Orb ) || ( $1 == 72 ) ) return Griseous Orb
  if ( ( $1 == Ground Gem ) || ( $1 == 73 ) ) return Ground Gem
  if ( ( $1 == Haban Berry ) || ( $1 == 74 ) ) return Haban Berry
  if ( ( $1 == Hard Stone ) || ( $1 == 75 ) ) return Hard Stone
  if ( ( $1 == Heat Rock ) || ( $1 == 76 ) ) return Heat Rock
  if ( ( $1 == Hondew Berry ) || ( $1 == 77 ) ) return Hondew Berry
  if ( ( $1 == Iapapa Berry ) || ( $1 == 78 ) ) return Iapapa Berry
  if ( ( $1 == Ice Gem ) || ( $1 == 79 ) ) return Ice Gem
  if ( ( $1 == Ice Heal ) || ( $1 == 80 ) ) return Ice Heal
  if ( ( $1 == Icicle Plate ) || ( $1 == 81 ) ) return Icicle Plate
  if ( ( $1 == Icy Rock ) || ( $1 == 82 ) ) return Icy Rock
  if ( ( $1 == Insect Plate ) || ( $1 == 83 ) ) return Insect Plate
  if ( ( $1 == Iron Ball ) || ( $1 == 84 ) ) return Iron Ball
  if ( ( $1 == Iron Plate ) || ( $1 == 85 ) ) return Iron Plate
  if ( ( $1 == Jaboca Berry ) || ( $1 == 86 ) ) return Jaboca Berry
  if ( ( $1 == Kasib Berry ) || ( $1 == 87 ) ) return Kasib Berry
  if ( ( $1 == Kebia Berry ) || ( $1 == 88 ) ) return Kebia Berry
  if ( ( $1 == Kelpsy Berry ) || ( $1 == 89 ) ) return Kelpsy Berry
  if ( ( $1 == King's Rock ) || ( $1 == 90 ) ) return King's Rock
  if ( ( $1 == Lagging Tail ) || ( $1 == 91 ) ) return Lagging Tail
  if ( ( $1 == Lansat Berry ) || ( $1 == 92 ) ) return Lansat Berry
  if ( ( $1 == Lax Incense ) || ( $1 == 93 ) ) return Lax Incense
  if ( ( $1 == Leftovers ) || ( $1 == 94 ) ) return Leftovers
  if ( ( $1 == Leppa Berry ) || ( $1 == 95 ) ) return Leppa Berry
  if ( ( $1 == Liechi Berry ) || ( $1 == 96 ) ) return Liechi Berry
  if ( ( $1 == Life Orb ) || ( $1 == 97 ) ) return Life Orb
  if ( ( $1 == Light Ball ) || ( $1 == 98 ) ) return Light Ball
  if ( ( $1 == Light Clay ) || ( $1 == 99 ) ) return Light Clay
  if ( ( $1 == Luck Incense ) || ( $1 == 100 ) ) return Luck Incense
  if ( ( $1 == Lucky Egg ) || ( $1 == 101 ) ) return Lucky Egg
  if ( ( $1 == Lucky Punch ) || ( $1 == 102 ) ) return Lucky Punch
  if ( ( $1 == Lum Berry ) || ( $1 == 103 ) ) return Lum Berry
  if ( ( $1 == Lustrous Orb ) || ( $1 == 104 ) ) return Lustrous Orb
  if ( ( $1 == Macho Brace ) || ( $1 == 105 ) ) return Macho Brace
  if ( ( $1 == Magmarizer ) || ( $1 == 106 ) ) return Magmarizer
  if ( ( $1 == Magnet ) || ( $1 == 107 ) ) return Magnet
  if ( ( $1 == Mago Berry ) || ( $1 == 108 ) ) return Mago Berry
  if ( ( $1 == Magost Berry ) || ( $1 == 109 ) ) return Magost Berry
  if ( ( $1 == Meadow Plate ) || ( $1 == 110 ) ) return Meadow Plate
  if ( ( $1 == Mental Herb ) || ( $1 == 111 ) ) return Mental Herb
  if ( ( $1 == Metal Coat ) || ( $1 == 112 ) ) return Metal Coat
  if ( ( $1 == Metal Powder ) || ( $1 == 113 ) ) return Metal Powder
  if ( ( $1 == Metronome ) || ( $1 == 114 ) ) return Metronome
  if ( ( $1 == Micle Berry ) || ( $1 == 115 ) ) return Micle Berry
  if ( ( $1 == Mind Plate ) || ( $1 == 116 ) ) return Mind Plate
  if ( ( $1 == Miracle Seed ) || ( $1 == 117 ) ) return Miracle Seed
  if ( ( $1 == Muscle Band ) || ( $1 == 118 ) ) return Muscle Band
  if ( ( $1 == Mystic Water ) || ( $1 == 119 ) ) return Mystic Water
  if ( ( $1 == Nanab Berry ) || ( $1 == 120 ) ) return Nanab Berry
  if ( ( $1 == NeverMeltIce ) || ( $1 == 121 ) ) return NeverMeltIce
  if ( ( $1 == Nomel Berry ) || ( $1 == 122 ) ) return Nomel Berry
  if ( ( $1 == Normal Gem ) || ( $1 == 123 ) ) return Normal Gem
  if ( ( $1 == Occa Berry ) || ( $1 == 124 ) ) return Occa Berry
  if ( ( $1 == Odd Incense ) || ( $1 == 125 ) ) return Odd Incense
  if ( ( $1 == Oran Berry ) || ( $1 == 126 ) ) return Oran Berry
  if ( ( $1 == Pamtre Berry ) || ( $1 == 127 ) ) return Pamtre Berry
  if ( ( $1 == Passho Berry ) || ( $1 == 128 ) ) return Passho Berry
  if ( ( $1 == Payapa Berry ) || ( $1 == 129 ) ) return Payapa Berry
  if ( ( $1 == Pecha Berry ) || ( $1 == 130 ) ) return Pecha Berry
  if ( ( $1 == Persim Berry ) || ( $1 == 131 ) ) return Persim Berry
  if ( ( $1 == Petaya Berry ) || ( $1 == 132 ) ) return Petaya Berry
  if ( ( $1 == Pinap Berry ) || ( $1 == 133 ) ) return Pinap Berry
  if ( ( $1 == Pink Scarf ) || ( $1 == 134 ) ) return Pink Scarf
  if ( ( $1 == Poison Barb ) || ( $1 == 135 ) ) return Poison Barb
  if ( ( $1 == Poison Gem ) || ( $1 == 136 ) ) return Poison Gem
  if ( ( $1 == Pomeg Berry ) || ( $1 == 137 ) ) return Pomeg Berry
  if ( ( $1 == Power Anklet ) || ( $1 == 138 ) ) return Power Anklet
  if ( ( $1 == Power Band ) || ( $1 == 139 ) ) return Power Band
  if ( ( $1 == Power Belt ) || ( $1 == 140 ) ) return Power Belt
  if ( ( $1 == Power Bracer ) || ( $1 == 141 ) ) return Power Bracer
  if ( ( $1 == Power Herb ) || ( $1 == 142 ) ) return Power Herb
  if ( ( $1 == Power Lens ) || ( $1 == 143 ) ) return Power Lens
  if ( ( $1 == Power Weight ) || ( $1 == 144 ) ) return Power Weight
  if ( ( $1 == Prism Scale ) || ( $1 == 145 ) ) return Prism Scale
  if ( ( $1 == Psychic Gem ) || ( $1 == 146 ) ) return Psychic Gem
  if ( ( $1 == Pure Incense ) || ( $1 == 147 ) ) return Pure Incense
  if ( ( $1 == Qualot Berry ) || ( $1 == 148 ) ) return Qualot Berry
  if ( ( $1 == Quick Claw ) || ( $1 == 149 ) ) return Quick Claw
  if ( ( $1 == Quick Powder ) || ( $1 == 150 ) ) return Quick Powder
  if ( ( $1 == Rabuta Berry ) || ( $1 == 151 ) ) return Rabuta Berry
  if ( ( $1 == Rare Candy ) || ( $1 == 152 ) ) return Rare Candy
  if ( ( $1 == Rawst Berry ) || ( $1 == 153 ) ) return Rawst Berry
  if ( ( $1 == Razor Claw ) || ( $1 == 154 ) ) return Razor Claw
  if ( ( $1 == Razor Fang ) || ( $1 == 155 ) ) return Razor Fang
  if ( ( $1 == Razz Berry ) || ( $1 == 156 ) ) return Razz Berry
  if ( ( $1 == Red Card ) || ( $1 == 157 ) ) return Red Card
  if ( ( $1 == Red Scarf ) || ( $1 == 158 ) ) return Red Scarf
  if ( ( $1 == Rindo Berry ) || ( $1 == 159 ) ) return Rindo Berry
  if ( ( $1 == Ring Target ) || ( $1 == 160 ) ) return Ring Target
  if ( ( $1 == Rock Gem ) || ( $1 == 161 ) ) return Rock Gem
  if ( ( $1 == Rock Incense ) || ( $1 == 162 ) ) return Rock Incense
  if ( ( $1 == Rocky Helmet ) || ( $1 == 163 ) ) return Rocky Helmet
  if ( ( $1 == Rose Incense ) || ( $1 == 164 ) ) return Rose Incense
  if ( ( $1 == Rowap Berry ) || ( $1 == 165 ) ) return Rowap Berry
  if ( ( $1 == Salac Berry ) || ( $1 == 166 ) ) return Salac Berry
  if ( ( $1 == Scope Lens ) || ( $1 == 167 ) ) return Scope Lens
  if ( ( $1 == Sea Incense ) || ( $1 == 168 ) ) return Sea Incense
  if ( ( $1 == Sharp Beak ) || ( $1 == 169 ) ) return Sharp Beak
  if ( ( $1 == Shed Shell ) || ( $1 == 170 ) ) return Shed Shell
  if ( ( $1 == Shell Bell ) || ( $1 == 171 ) ) return Shell Bell
  if ( ( $1 == Shock Drive ) || ( $1 == 172 ) ) return Shock Drive
  if ( ( $1 == Shuca Berry ) || ( $1 == 173 ) ) return Shuca Berry
  if ( ( $1 == Silk Scarf ) || ( $1 == 174 ) ) return Silk Scarf
  if ( ( $1 == SilverPowder ) || ( $1 == 175 ) ) return SilverPowder
  if ( ( $1 == Sitrus Berry ) || ( $1 == 176 ) ) return Sitrus Berry
  if ( ( $1 == Sky Plate ) || ( $1 == 177 ) ) return Sky Plate
  if ( ( $1 == Smoke Ball ) || ( $1 == 178 ) ) return Smoke Ball
  if ( ( $1 == Smooth Rock ) || ( $1 == 179 ) ) return Smooth Rock
  if ( ( $1 == Soft Sand ) || ( $1 == 180 ) ) return Soft Sand
  if ( ( $1 == Soothe Bell ) || ( $1 == 181 ) ) return Soothe Bell
  if ( ( $1 == Soul Dew ) || ( $1 == 182 ) ) return Soul Dew
  if ( ( $1 == Spell Tag ) || ( $1 == 183 ) ) return Spell Tag
  if ( ( $1 == Spelon Berry ) || ( $1 == 184 ) ) return Spelon Berry
  if ( ( $1 == Splash Plate ) || ( $1 == 185 ) ) return Splash Plate
  if ( ( $1 == Spooky Plate ) || ( $1 == 186 ) ) return Spooky Plate
  if ( ( $1 == Starf Berry ) || ( $1 == 187 ) ) return Starf Berry
  if ( ( $1 == Steel Gem ) || ( $1 == 188 ) ) return Steel Gem
  if ( ( $1 == Stick ) || ( $1 == 189 ) ) return Stick
  if ( ( $1 == Sticky Barb ) || ( $1 == 190 ) ) return Sticky Barb
  if ( ( $1 == Stone Plate ) || ( $1 == 191 ) ) return Stone Plate
  if ( ( $1 == Tamato Berry ) || ( $1 == 192 ) ) return Tamato Berry
  if ( ( $1 == Tanga Berry ) || ( $1 == 193 ) ) return Tanga Berry
  if ( ( $1 == Thick Club ) || ( $1 == 194 ) ) return Thick Club
  if ( ( $1 == Toxic Orb ) || ( $1 == 195 ) ) return Toxic Orb
  if ( ( $1 == Toxic Plate ) || ( $1 == 196 ) ) return Toxic Plate
  if ( ( $1 == TwistedSpoon ) || ( $1 == 197 ) ) return TwistedSpoon
  if ( ( $1 == Wacan Berry ) || ( $1 == 198 ) ) return Wacan Berry
  if ( ( $1 == Water Gem ) || ( $1 == 199 ) ) return Water Gem
  if ( ( $1 == Watmel Berry ) || ( $1 == 200 ) ) return Watmel Berry
  if ( ( $1 == Wave Incense ) || ( $1 == 201 ) ) return Wave Incense
  if ( ( $1 == Wepear Berry ) || ( $1 == 202 ) ) return Wepear Berry
  if ( ( $1 == White Herb ) || ( $1 == 203 ) ) return White Herb
  if ( ( $1 == Wide Lens ) || ( $1 == 204 ) ) return Wide Lens
  if ( ( $1 == Wiki Berry ) || ( $1 == 205 ) ) return Wiki Berry
  if ( ( $1 == Wise Glasses ) || ( $1 == 206 ) ) return Wise Glasses
  if ( ( $1 == Yache Berry ) || ( $1 == 207 ) ) return Yache Berry
  if ( ( $1 == Yellow Scarf ) || ( $1 == 208 ) ) return Yellow Scarf
  if ( ( $1 == Zap Plate ) || ( $1 == 209 ) ) return Zap Plate
  if ( ( $1 == Zoom Lens ) || ( $1 == 210 ) ) return Zoom Lens
}
alias -l Metronome {
  if ( $1 == 1 ) return Pound
  if ( $1 == 2 ) return Karate Chop
  if ( $1 == 3 ) return DoubleSlap
  if ( $1 == 4 ) return Comet Punch
  if ( $1 == 5 ) return Mega Punch
  if ( $1 == 6 ) return Pay Day
  if ( $1 == 7 ) return Fire Punch
  if ( $1 == 8 ) return Ice Punch
  if ( $1 == 9 ) return ThunderPunch
  if ( $1 == 10 ) return Scratch
  if ( $1 == 11 ) return ViceGrip
  if ( $1 == 12 ) return Guillotine
  if ( $1 == 13 ) return Razor Wind
  if ( $1 == 14 ) return Swords Dance
  if ( $1 == 15 ) return Cut
  if ( $1 == 16 ) return Gust
  if ( $1 == 17 ) return Wing Attack
  if ( $1 == 18 ) return Whirlwind
  if ( $1 == 19 ) return Fly
  if ( $1 == 20 ) return Bind
  if ( $1 == 21 ) return Slam
  if ( $1 == 22 ) return Vine Whip
  if ( $1 == 23 ) return Stomp
  if ( $1 == 24 ) return Double Kick
  if ( $1 == 25 ) return Mega Kick
  if ( $1 == 26 ) return Jump Kick
  if ( $1 == 27 ) return Rolling Kick
  if ( $1 == 28 ) return Sand-Attack
  if ( $1 == 29 ) return Headbutt
  if ( $1 == 30 ) return Horn Attack
  if ( $1 == 31 ) return Fury Attack
  if ( $1 == 32 ) return Horn Drill
  if ( $1 == 33 ) return Tackle
  if ( $1 == 34 ) return Body Slam
  if ( $1 == 35 ) return Wrap
  if ( $1 == 36 ) return Take Down
  if ( $1 == 37 ) return Thrash
  if ( $1 == 38 ) return Double-Edge
  if ( $1 == 39 ) return Tail Whip
  if ( $1 == 40 ) return Poison Sting
  if ( $1 == 41 ) return Twineedle
  if ( $1 == 42 ) return Pin Missile
  if ( $1 == 43 ) return Leer
  if ( $1 == 44 ) return Bite
  if ( $1 == 45 ) return Growl
  if ( $1 == 46 ) return Roar
  if ( $1 == 47 ) return Sing
  if ( $1 == 48 ) return Supersonic
  if ( $1 == 49 ) return SonicBoom
  if ( $1 == 50 ) return Disable
  if ( $1 == 51 ) return Acid
  if ( $1 == 52 ) return Ember
  if ( $1 == 53 ) return Flamethrower
  if ( $1 == 54 ) return Mist
  if ( $1 == 55 ) return Water Gun
  if ( $1 == 56 ) return Hydro Pump
  if ( $1 == 57 ) return Surf
  if ( $1 == 58 ) return Ice Beam
  if ( $1 == 59 ) return Blizzard
  if ( $1 == 60 ) return Psybeam
  if ( $1 == 61 ) return BubbleBeam
  if ( $1 == 62 ) return Aurora Beam
  if ( $1 == 63 ) return Hyper Beam
  if ( $1 == 64 ) return Peck
  if ( $1 == 65 ) return Drill Peck
  if ( $1 == 66 ) return Submission
  if ( $1 == 67 ) return Low Kick
  if ( $1 == 68 ) return Seismic Toss
  if ( $1 == 69 ) return Strength
  if ( $1 == 70 ) return Absorb
  if ( $1 == 71 ) return Mega Drain
  if ( $1 == 72 ) return Leech Seed
  if ( $1 == 73 ) return Growth
  if ( $1 == 74 ) return Razor Leaf
  if ( $1 == 75 ) return SolarBeam
  if ( $1 == 76 ) return PoisonPowder
  if ( $1 == 77 ) return Stun Spore
  if ( $1 == 78 ) return Sleep Powder
  if ( $1 == 79 ) return Petal Dance
  if ( $1 == 80 ) return String Shot
  if ( $1 == 81 ) return Dragon Rage
  if ( $1 == 82 ) return Fire Spin
  if ( $1 == 83 ) return ThunderShock
  if ( $1 == 84 ) return Thunderbolt
  if ( $1 == 85 ) return Thunder Wave
  if ( $1 == 86 ) return Thunder
  if ( $1 == 87 ) return Rock Throw
  if ( $1 == 88 ) return Earthquake
  if ( $1 == 89 ) return Fissure
  if ( $1 == 90 ) return Dig
  if ( $1 == 91 ) return Toxic
  if ( $1 == 92 ) return Confusion
  if ( $1 == 93 ) return Psychic
  if ( $1 == 94 ) return Hypnosis
  if ( $1 == 95 ) return Meditate
  if ( $1 == 96 ) return Agility
  if ( $1 == 97 ) return Quick Attack
  if ( $1 == 98 ) return Rage
  if ( $1 == 99 ) return Teleport
  if ( $1 == 100 ) return Night Shade
  if ( $1 == 101 ) return Screech
  if ( $1 == 102 ) return Double Team
  if ( $1 == 103 ) return Recover
  if ( $1 == 104 ) return Harden
  if ( $1 == 105 ) return Minimize
  if ( $1 == 106 ) return SmokeScreen
  if ( $1 == 107 ) return Confuse Ray
  if ( $1 == 108 ) return Withdraw
  if ( $1 == 109 ) return Defense Curl
  if ( $1 == 110 ) return Barrier
  if ( $1 == 111 ) return Light Screen
  if ( $1 == 112 ) return Haze
  if ( $1 == 113 ) return Reflect
  if ( $1 == 114 ) return Focus Energy
  if ( $1 == 115 ) return Bide
  if ( $1 == 116 ) return Selfdestruct
  if ( $1 == 117 ) return Egg Bomb
  if ( $1 == 118 ) return Lick
  if ( $1 == 119 ) return Smog
  if ( $1 == 120 ) return Sludge
  if ( $1 == 121 ) return Bone Club
  if ( $1 == 122 ) return Fire Blast
  if ( $1 == 123 ) return Waterfall
  if ( $1 == 124 ) return Clamp
  if ( $1 == 125 ) return Swift
  if ( $1 == 126 ) return Skull Bash
  if ( $1 == 127 ) return Spike Cannon
  if ( $1 == 128 ) return Constrict
  if ( $1 == 129 ) return Amnesia
  if ( $1 == 130 ) return Kinesis
  if ( $1 == 131 ) return Softboiled
  if ( $1 == 132 ) return Hi Jump Kick
  if ( $1 == 133 ) return Glare
  if ( $1 == 134 ) return Dream Eater
  if ( $1 == 135 ) return Poison Gas
  if ( $1 == 136 ) return Barrage
  if ( $1 == 137 ) return Leech Life
  if ( $1 == 138 ) return Lovely Kiss
  if ( $1 == 139 ) return Sky Attack
  if ( $1 == 140 ) return Transform
  if ( $1 == 141 ) return Bubble
  if ( $1 == 142 ) return Dizzy Punch
  if ( $1 == 143 ) return Spore
  if ( $1 == 144 ) return Flash
  if ( $1 == 145 ) return Psywave
  if ( $1 == 146 ) return Splash
  if ( $1 == 147 ) return Acid Armor
  if ( $1 == 148 ) return Crabhammer
  if ( $1 == 149 ) return Explosion
  if ( $1 == 150 ) return Fury Swipes
  if ( $1 == 151 ) return Bonemerang
  if ( $1 == 152 ) return Rest
  if ( $1 == 153 ) return Rock Slide
  if ( $1 == 154 ) return Hyper Fang
  if ( $1 == 155 ) return Sharpen
  if ( $1 == 156 ) return Conversion
  if ( $1 == 157 ) return Tri Attack
  if ( $1 == 158 ) return Super Fang
  if ( $1 == 159 ) return Slash
  if ( $1 == 160 ) return Substitute
  if ( $1 == 161 ) return Triple Kick
  if ( $1 == 162 ) return Spider Web
  if ( $1 == 163 ) return Mind Reader
  if ( $1 == 164 ) return Nightmare
  if ( $1 == 165 ) return Flame Wheel
  if ( $1 == 166 ) return Snore
  if ( $1 == 167 ) return Curse
  if ( $1 == 168 ) return Flail
  if ( $1 == 169 ) return Conversion 2
  if ( $1 == 170 ) return Aeroblast
  if ( $1 == 171 ) return Cotton Spore
  if ( $1 == 172 ) return Reversal
  if ( $1 == 173 ) return Spite
  if ( $1 == 174 ) return Powder Snow
  if ( $1 == 175 ) return Mach Punch
  if ( $1 == 176 ) return Scary Face
  if ( $1 == 177 ) return Faint Attack
  if ( $1 == 178 ) return Sweet Kiss
  if ( $1 == 179 ) return Belly Drum
  if ( $1 == 180 ) return Sludge Bomb
  if ( $1 == 181 ) return Mud-Slap
  if ( $1 == 182 ) return Octazooka
  if ( $1 == 183 ) return Spikes
  if ( $1 == 184 ) return Zap Cannon
  if ( $1 == 185 ) return Foresight
  if ( $1 == 186 ) return Perish Song
  if ( $1 == 187 ) return Icy Wind
  if ( $1 == 188 ) return Bone Rush
  if ( $1 == 189 ) return Lock-On
  if ( $1 == 190 ) return Outrage
  if ( $1 == 191 ) return Sandstorm
  if ( $1 == 192 ) return Giga Drain
  if ( $1 == 193 ) return Charm
  if ( $1 == 194 ) return Rollout
  if ( $1 == 195 ) return False Swipe
  if ( $1 == 196 ) return Swagger
  if ( $1 == 197 ) return Milk Drink
  if ( $1 == 198 ) return Spark
  if ( $1 == 199 ) return Fury Cutter
  if ( $1 == 200 ) return Steel Wing
  if ( $1 == 201 ) return Mean Look
  if ( $1 == 202 ) return Attract
  if ( $1 == 203 ) return Heal Bell
  if ( $1 == 204 ) return Return
  if ( $1 == 205 ) return Present
  if ( $1 == 206 ) return Frustration
  if ( $1 == 207 ) return Safeguard
  if ( $1 == 208 ) return Pain Split
  if ( $1 == 209 ) return Sacred Fire
  if ( $1 == 210 ) return Magnitude
  if ( $1 == 211 ) return DynamicPunch
  if ( $1 == 212 ) return Megahorn
  if ( $1 == 213 ) return DragonBreath
  if ( $1 == 214 ) return Baton Pass
  if ( $1 == 215 ) return Encore
  if ( $1 == 216 ) return Pursuit
  if ( $1 == 217 ) return Rapid Spin
  if ( $1 == 218 ) return Sweet Scent
  if ( $1 == 219 ) return Iron Tail
  if ( $1 == 220 ) return Metal Claw
  if ( $1 == 221 ) return Vital Throw
  if ( $1 == 222 ) return Morning Sun
  if ( $1 == 223 ) return Synthesis
  if ( $1 == 224 ) return Moonlight
  if ( $1 == 225 ) return Hidden Power
  if ( $1 == 226 ) return Cross Chop
  if ( $1 == 227 ) return Twister
  if ( $1 == 228 ) return Rain Dance
  if ( $1 == 229 ) return Sunny Day
  if ( $1 == 230 ) return Crunch
  if ( $1 == 231 ) return Psych Up
  if ( $1 == 232 ) return ExtremeSpeed
  if ( $1 == 233 ) return AncientPower
  if ( $1 == 234 ) return Shadow Ball
  if ( $1 == 235 ) return Future Sight
  if ( $1 == 236 ) return Rock Smash
  if ( $1 == 237 ) return Whirlpool
  if ( $1 == 238 ) return Beat Up
  if ( $1 == 239 ) return Fake Out
  if ( $1 == 240 ) return Uproar
  if ( $1 == 241 ) return Stockpile
  if ( $1 == 242 ) return Spit Up
  if ( $1 == 243 ) return Swallow
  if ( $1 == 244 ) return Heat Wave
  if ( $1 == 245 ) return Hail
  if ( $1 == 246 ) return Torment
  if ( $1 == 247 ) return Flatter
  if ( $1 == 248 ) return Will-O-Wisp
  if ( $1 == 249 ) return Memento
  if ( $1 == 250 ) return Facade
  if ( $1 == 251 ) return SmellingSalt
  if ( $1 == 252 ) return Nature Power
  if ( $1 == 253 ) return Charge
  if ( $1 == 254 ) return Taunt
  if ( $1 == 255 ) return Role Play
  if ( $1 == 256 ) return Wish
  if ( $1 == 257 ) return Ingrain
  if ( $1 == 258 ) return Superpower
  if ( $1 == 259 ) return Magic Coat
  if ( $1 == 260 ) return Recycle
  if ( $1 == 261 ) return Revenge
  if ( $1 == 262 ) return Brick Break
  if ( $1 == 263 ) return Yawn
  if ( $1 == 264 ) return Knock Off
  if ( $1 == 265 ) return Endeavor
  if ( $1 == 266 ) return Eruption
  if ( $1 == 267 ) return Skill Swap
  if ( $1 == 268 ) return Imprison
  if ( $1 == 269 ) return Refresh
  if ( $1 == 270 ) return Grudge
  if ( $1 == 271 ) return Secret Power
  if ( $1 == 272 ) return Dive
  if ( $1 == 273 ) return Arm Thrust
  if ( $1 == 274 ) return Camouflage
  if ( $1 == 275 ) return Tail Glow
  if ( $1 == 276 ) return Luster Purge
  if ( $1 == 277 ) return Mist Ball
  if ( $1 == 278 ) return FeatherDance
  if ( $1 == 279 ) return Teeter Dance
  if ( $1 == 280 ) return Blaze Kick
  if ( $1 == 281 ) return Mud Sport
  if ( $1 == 282 ) return Ice Ball
  if ( $1 == 283 ) return Needle Arm
  if ( $1 == 284 ) return Slack Off
  if ( $1 == 285 ) return Hyper Voice
  if ( $1 == 286 ) return Poison Fang
  if ( $1 == 287 ) return Crush Claw
  if ( $1 == 288 ) return Blast Burn
  if ( $1 == 289 ) return Hydro Cannon
  if ( $1 == 290 ) return Meteor Mash
  if ( $1 == 291 ) return Astonish
  if ( $1 == 292 ) return Weather Ball
  if ( $1 == 293 ) return Aromatherapy
  if ( $1 == 294 ) return Fake Tears
  if ( $1 == 295 ) return Air Cutter
  if ( $1 == 296 ) return Overheat
  if ( $1 == 297 ) return Odor Sleuth
  if ( $1 == 298 ) return Rock Tomb
  if ( $1 == 299 ) return Silver Wind
  if ( $1 == 300 ) return Metal Sound
  if ( $1 == 301 ) return GrassWhistle
  if ( $1 == 302 ) return Tickle
  if ( $1 == 303 ) return Cosmic Power
  if ( $1 == 304 ) return Water Spout
  if ( $1 == 305 ) return Signal Beam
  if ( $1 == 306 ) return Shadow Punch
  if ( $1 == 307 ) return Extrasensory
  if ( $1 == 308 ) return Sky Uppercut
  if ( $1 == 309 ) return Sand Tomb
  if ( $1 == 310 ) return Sheer Cold
  if ( $1 == 311 ) return Muddy Water
  if ( $1 == 312 ) return Bullet Seed
  if ( $1 == 313 ) return Aerial Ace
  if ( $1 == 314 ) return Icicle Spear
  if ( $1 == 315 ) return Iron Defense
  if ( $1 == 316 ) return Block
  if ( $1 == 317 ) return Howl
  if ( $1 == 318 ) return Dragon Claw
  if ( $1 == 319 ) return Frenzy Plant
  if ( $1 == 320 ) return Bulk Up
  if ( $1 == 321 ) return Bounce
  if ( $1 == 322 ) return Mud Shot
  if ( $1 == 323 ) return Poison Tail
  if ( $1 == 324 ) return Volt Tackle
  if ( $1 == 325 ) return Magical Leaf
  if ( $1 == 326 ) return Water Sport
  if ( $1 == 327 ) return Calm Mind
  if ( $1 == 328 ) return Leaf Blade
  if ( $1 == 329 ) return Dragon Dance
  if ( $1 == 330 ) return Rock Blast
  if ( $1 == 331 ) return Shock Wave
  if ( $1 == 332 ) return Water Pulse
  if ( $1 == 333 ) return Doom Desire
  if ( $1 == 334 ) return Psycho Boost
  if ( $1 == 335 ) return Roost
  if ( $1 == 336 ) return Gravity
  if ( $1 == 337 ) return Miracle Eye
  if ( $1 == 338 ) return Wake-Up Slap
  if ( $1 == 339 ) return Hammer Arm
  if ( $1 == 340 ) return Gyro Ball
  if ( $1 == 341 ) return Healing Wish
  if ( $1 == 342 ) return Brine
  if ( $1 == 343 ) return Natural Gift
  if ( $1 == 344 ) return Pluck
  if ( $1 == 345 ) return Tailwind
  if ( $1 == 346 ) return Acupressure
  if ( $1 == 347 ) return Metal Burst
  if ( $1 == 348 ) return U-turn
  if ( $1 == 349 ) return Close Combat
  if ( $1 == 350 ) return Payback
  if ( $1 == 351 ) return Assurance
  if ( $1 == 352 ) return Embargo
  if ( $1 == 353 ) return Fling
  if ( $1 == 354 ) return Psycho Shift
  if ( $1 == 355 ) return Trump Card
  if ( $1 == 356 ) return Heal Block
  if ( $1 == 357 ) return Wring Out
  if ( $1 == 358 ) return Power Trick
  if ( $1 == 359 ) return Gastro Acid
  if ( $1 == 360 ) return Lucky Chant
  if ( $1 == 361 ) return Power Swap
  if ( $1 == 362 ) return Guard Swap
  if ( $1 == 363 ) return Punishment
  if ( $1 == 364 ) return Last Resort
  if ( $1 == 365 ) return Worry Seed
  if ( $1 == 366 ) return Sucker Punch
  if ( $1 == 367 ) return Toxic Spikes
  if ( $1 == 368 ) return Heart Swap
  if ( $1 == 369 ) return Aqua Ring
  if ( $1 == 370 ) return Magnet Rise
  if ( $1 == 371 ) return Flare Blitz
  if ( $1 == 372 ) return Force Palm
  if ( $1 == 373 ) return Aura Sphere
  if ( $1 == 374 ) return Rock Polish
  if ( $1 == 375 ) return Poison Jab
  if ( $1 == 376 ) return Dark Pulse
  if ( $1 == 377 ) return Night Slash
  if ( $1 == 378 ) return Aqua Tail
  if ( $1 == 379 ) return Seed Bomb
  if ( $1 == 380 ) return Air Slash
  if ( $1 == 381 ) return X-Scissor
  if ( $1 == 382 ) return Bug Buzz
  if ( $1 == 383 ) return Dragon Pulse
  if ( $1 == 384 ) return Dragon Rush
  if ( $1 == 385 ) return Power Gem
  if ( $1 == 386 ) return Drain Punch
  if ( $1 == 387 ) return Vacuum Wave
  if ( $1 == 388 ) return Focus Blast
  if ( $1 == 389 ) return Energy Ball
  if ( $1 == 390 ) return Brave Bird
  if ( $1 == 391 ) return Earth Power
  if ( $1 == 392 ) return Giga Impact
  if ( $1 == 393 ) return Nasty Plot
  if ( $1 == 394 ) return Bullet Punch
  if ( $1 == 395 ) return Avalanche
  if ( $1 == 396 ) return Ice Shard
  if ( $1 == 397 ) return Shadow Claw
  if ( $1 == 398 ) return Thunder Fang
  if ( $1 == 399 ) return Ice Fang
  if ( $1 == 400 ) return Fire Fang
  if ( $1 == 401 ) return Shadow Sneak
  if ( $1 == 402 ) return Mud Bomb
  if ( $1 == 403 ) return Psycho Cut
  if ( $1 == 404 ) return Zen Headbutt
  if ( $1 == 405 ) return Mirror Shot
  if ( $1 == 406 ) return Flash Cannon
  if ( $1 == 407 ) return Rock Climb
  if ( $1 == 408 ) return Defog
  if ( $1 == 409 ) return Trick Room
  if ( $1 == 410 ) return Draco Meteor
  if ( $1 == 411 ) return Discharge
  if ( $1 == 412 ) return Lava Plume
  if ( $1 == 413 ) return Leaf Storm
  if ( $1 == 414 ) return Power Whip
  if ( $1 == 415 ) return Rock Wrecker
  if ( $1 == 416 ) return Cross Poison
  if ( $1 == 417 ) return Gunk Shot
  if ( $1 == 418 ) return Iron Head
  if ( $1 == 419 ) return Magnet Bomb
  if ( $1 == 420 ) return Stone Edge
  if ( $1 == 421 ) return Captivate
  if ( $1 == 422 ) return Stealth Rock
  if ( $1 == 423 ) return Grass Knot
  if ( $1 == 424 ) return Judgment
  if ( $1 == 425 ) return Bug Bite
  if ( $1 == 426 ) return Charge Beam
  if ( $1 == 427 ) return Wood Hammer
  if ( $1 == 428 ) return Aqua Jet
  if ( $1 == 429 ) return Attack Order
  if ( $1 == 430 ) return Defend Order
  if ( $1 == 431 ) return Heal Order
  if ( $1 == 432 ) return Head Smash
  if ( $1 == 433 ) return Double Hit
  if ( $1 == 434 ) return Roar of Time
  if ( $1 == 435 ) return Spacial Rend
  if ( $1 == 436 ) return Lunar Dance
  if ( $1 == 437 ) return Crush Grip
  if ( $1 == 438 ) return Magma Storm
  if ( $1 == 439 ) return Dark Void
  if ( $1 == 440 ) return Seed Flare
  if ( $1 == 441 ) return Ominous Wind
  if ( $1 == 442 ) return Shadow Force
  if ( $1 == 443 ) return Hone Claws
  if ( $1 == 444 ) return Wide Guard
  if ( $1 == 445 ) return Guard Split
  if ( $1 == 446 ) return Power Split
  if ( $1 == 447 ) return Wonder Room
  if ( $1 == 448 ) return Psyshock
  if ( $1 == 449 ) return Venoshock
  if ( $1 == 450 ) return Autotomize
  if ( $1 == 451 ) return Rage Powder
  if ( $1 == 452 ) return Telekinesis
  if ( $1 == 453 ) return Magic Room
  if ( $1 == 454 ) return Smack Down
  if ( $1 == 455 ) return Storm Throw
  if ( $1 == 456 ) return Flame Burst
  if ( $1 == 457 ) return Sludge Wave
  if ( $1 == 458 ) return Quiver Dance
  if ( $1 == 459 ) return Heavy Slam
  if ( $1 == 460 ) return Synchronoise
  if ( $1 == 461 ) return Electro Ball
  if ( $1 == 462 ) return Soak
  if ( $1 == 463 ) return Flame Charge
  if ( $1 == 464 ) return Coil
  if ( $1 == 465 ) return Low Sweep
  if ( $1 == 466 ) return Acid Spray
  if ( $1 == 467 ) return Foul Play
  if ( $1 == 468 ) return Simple Beam
  if ( $1 == 469 ) return Entrainment
  if ( $1 == 470 ) return After You
  if ( $1 == 471 ) return Round
  if ( $1 == 472 ) return Echoed Voice
  if ( $1 == 473 ) return Chip Away
  if ( $1 == 474 ) return Clear Smog
  if ( $1 == 475 ) return Stored Power
  if ( $1 == 476 ) return Quick Guard
  if ( $1 == 477 ) return Ally Switch
  if ( $1 == 478 ) return Scald
  if ( $1 == 479 ) return Shell Smash
  if ( $1 == 480 ) return Heal Pulse
  if ( $1 == 481 ) return Hex
  if ( $1 == 482 ) return Sky Drop
  if ( $1 == 483 ) return Shift Gear
  if ( $1 == 484 ) return Circle Throw
  if ( $1 == 485 ) return Incinerate
  if ( $1 == 486 ) return Quash
  if ( $1 == 487 ) return Acrobatics
  if ( $1 == 488 ) return Reflect Type
  if ( $1 == 489 ) return Retaliate
  if ( $1 == 490 ) return Final Gambit
  if ( $1 == 491 ) return Bestow
  if ( $1 == 492 ) return Inferno
  if ( $1 == 493 ) return Water Pledge
  if ( $1 == 494 ) return Fire Pledge
  if ( $1 == 495 ) return Grass Pledge
  if ( $1 == 496 ) return Volt Switch
  if ( $1 == 497 ) return Struggle Bug
  if ( $1 == 498 ) return Bulldoze
  if ( $1 == 499 ) return Frost Breath
  if ( $1 == 500 ) return Dragon Tail
  if ( $1 == 501 ) return Work Up
  if ( $1 == 502 ) return Electroweb
  if ( $1 == 503 ) return Wild Charge
  if ( $1 == 504 ) return Drill Run
  if ( $1 == 505 ) return Dual Chop
  if ( $1 == 506 ) return Heart Stamp
  if ( $1 == 507 ) return Horn Leech
  if ( $1 == 508 ) return Sacred Sword
  if ( $1 == 509 ) return Razor Shell
  if ( $1 == 510 ) return Heat Crash
  if ( $1 == 511 ) return Leaf Tornado
  if ( $1 == 512 ) return Steamroller
  if ( $1 == 513 ) return Cotton Guard
  if ( $1 == 514 ) return Night Daze
  if ( $1 == 515 ) return Psystrike
  if ( $1 == 516 ) return Tail Slap
  if ( $1 == 517 ) return Hurricane
  if ( $1 == 518 ) return Head Charge
  if ( $1 == 519 ) return Gear Grind
  if ( $1 == 520 ) return Searing Shot
  if ( $1 == 521 ) return Techno Blast
  if ( $1 == 522 ) return Relic Song
  if ( $1 == 523 ) return Secret Sword
  if ( $1 == 524 ) return Glaciate
  if ( $1 == 525 ) return Bolt Strike
  if ( $1 == 526 ) return Blue Flare
  if ( $1 == 527 ) return Fiery Dance
  if ( $1 == 528 ) return Freeze Shock
  if ( $1 == 529 ) return Ice Burn
  if ( $1 == 530 ) return Snarl
  if ( $1 == 531 ) return Icicle Crash
  if ( $1 == 532 ) return V-create
  if ( $1 == 533 ) return Fusion Flare
  if ( $1 == 534 ) return Fusion Bolt
}
