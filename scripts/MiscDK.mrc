; IDEK why people like these.

/*
 * on .Source event
 * Links the user to my source code
 */
on $*:TEXT:$($+(/^,$DKtrigger,(src|source|code)/Si)):#:if ($me == DKbot) msg $chan https://github.com/DragonKnight40/DKbot $chr(124) http://pastebin.com/u/DKbot

/*
 * on Smogon event
 * Links the user to the Smogon analysis of the specified Pokemon
 */
on $*:TEXT:$($+(/^,$DKtrigger,Smogon\b/Si)):*:if ($me == DKbot) msg $iif($chan,$chan,$nick) http://www.smogon.com/bw/pokemon/ $+ $2

/*
 * off BAN event
 * Links the channel to a banhammer gif whenever a ban is placed
 */
off *:BAN:#:{
  DKcheck $nick
  if ($chan != #smogonwifi) {
    msg $chan DOWN GOES THE BANHAMMER http://goo.gl/qhTYTY
  }
}
/*
 * off KICK event
 * Links the channel to a kick gif whenever a kick occurs
 */
off *:KICK:#:{
  DKcheck $knick
  if ($knick != $me && $chan != #smogonwifi) {
    msg $chan OUTTA HERE $iif($rand(0,1),http://goo.gl/zWgqam,http://i.imgur.com/DbaoNuN.gif)
  }
}

on *:PART:#:if ($me == DKbot && $chan != #Battle && $nick($chan,0) <= 2) part $chan

on *:QUIT:{
  var %i = 1, %chans = $chan(0), %current
  while (%i <= %chans) {
    %current = $chan(%i)
    if ($nick(%current,0) <= 1 && %current != #Battle) part %current
    inc %i 1
  }
}

/*
 * off /r/ event
 * Provides the full link to any subreddit written as /r/something
 */
off $*:TEXT:/(?<!\.com)\/(r|u)\/([^\s]+)\b/Si:#:{
  DKcheck
  var %sub = $regml(2)
  if (%sub != pokemontrades && %sub != svexchange) {
    msg $chan $+(http://reddit.com/,$iif($regml(1) == u,user,r),/,%sub)
  }
}

on $*:TEXT:$($+(/^,$DKtrigger,rules\b/Si)):#:{
  DKcheck $nick
  msg $chan http://reddit.com/r/ $+ $right($chan,-1) $+ /wiki/rules
}

/*
 * on DISCONNECT event
 * Trys to reconnect when disconnected
 */
on *:DISCONNECT:{
  DKcheck $null
  set %DKcid $cid
  server irc.synirc.net:6666
}

/*
 * on CONNECT event
 * Start searching for giveaways as soon as a connection is established
 */
on *:CONNECT:{
  if ($cid == %DKcid || $me == DKbot) {
    unset %DKcid
    tnick DKbot
    timerreddit 0 60 reddit
    msg NickServ PASSWORD $+($chr(76),$chr(111),$chr(108),$chr(110),$chr(111),$chr(46))
  }
}

on $*:TEXT:/^!(FC|Recap\d?|Msg|Type)\b/Si:*:{
  DKcheck $nick
  $iif($chan,notice,msg) $nick If you were trying to use me, I no longer respond to ! other than to tell you this. Use . instead.
}

on $*:TEXT:$($+(/^,$DKtrigger,$chr(40),random|roulette|wut|pic,$chr(41),\b/Si)):*:{
  DKcheck $chan
  msg $iif($chan,$chan,$nick) $read($pics)
}

/*
 * These do not even deserve documentation lol
 */
on $*:TEXT:$($+(/^,$DKtrigger,jude/Si)):#:if ($me == DKbot) msg $chan http://i.imgur.com/srJNJFd.jpg
on $*:TEXT:$($+(/^,$DKtrigger,lenian/Si)):#:if ($me == DKbot) msg $chan http://i.imgur.com/Moj9nR4.gif
on $*:TEXT:$($+(/^,$DKtrigger,flare/Si)):#:if ($me == DKbot) msg $chan http://i.imgur.com/U9kHqot.gif
on $*:TEXT:$($+(/^,$DKtrigger,grumpus/Si)):#:if ($me == DKbot) msg $chan http://dutnall.co.uk/
on $*:TEXT:$($+(/^,$DKtrigger,trold/Si)):#:if ($me == DKbot) msg $chan http://i.imgur.com/CEPdd.jpg
on $*:TEXT:$($+(/^,$DKtrigger,potato/Si)):#:if ($me == DKbot) msg $chan http://i.imgur.com/bUN4XDS.jpg
on $*:TEXT:$($+(/^,$DKtrigger,kurttr/Si)):#:if ($me == DKbot) msg $chan http://i.imgur.com/jurE0vC.jpg
on $*:TEXT:$($+(/^,$DKtrigger,xiao/Si)):#:if ($me == DKbot) msg $chan http://i.imgur.com/wwncqOJ.jpg
on $*:TEXT:$($+(/^,$DKtrigger,ek/Si)):#:if ($me == DKbot) msg $chan http://i.imgur.com/0j58mzp.jpg
on $*:TEXT:$($+(/^,$DKtrigger,rod/Si)):#:if ($me == DKbot) msg $chan http://i.imgur.com/23N4bCX.gif
on $*:TEXT:$($+(/^,$DKtrigger,rustle/Si)):#:if ($me == DKbot) msg $chan http://i.imgur.com/R3lNH3w.gif
on $*:TEXT:$($+(/^,$DKtrigger,lenny/Si)):#:if ($me == DKbot) msg $chan http://goo.gl/L3Owh8
on $*:TEXT:$($+(/^,$DKtrigger,i8m/Si)):#:if ($me == DKbot) msg $chan http://i.imgur.com/fwyWTfw.gif
on $*:TEXT:$($+(/^,$DKtrigger,amab/Si)):#:if ($me == DKbot) msg $chan http://i.imgur.com/WjkLrjo.png
on $*:TEXT:$($+(/^,$DKtrigger,cent/Si)):#:if ($me == DKbot) msg $chan http://i.imgur.com/aY2V27F.gif
on $*:TEXT:$($+(/^,$DKtrigger,banana/Si)):#:if ($me == DKbot) msg $chan http://i.imgur.com/my9GNka.jpg
on $*:TEXT:$($+(/^,$DKtrigger,froakie/Si)):#:if ($me == DKbot) msg $chan http://i.imgur.com/LDA62GL.png
on $*:TEXT:$($+(/^,$DKtrigger,raia/Si)):#:if ($me == DKbot) msg $chan http://i.imgur.com/J6IB6RN.png
on $*:TEXT:$($+(/^,$DKtrigger,rash/Si)):#:if ($me == DKbot) msg $chan http://i.imgur.com/lB7dDzG.png
on $*:TEXT:$($+(/^,$DKtrigger,joel/Si)):#:if ($me == DKbot) msg $chan http://i.imgur.com/7Vjfz9T.jpg
on $*:TEXT:$($+(/^,$DKtrigger,sir/Si)):#:if ($me == DKbot) msg $chan http://i.imgur.com/DrXpLu5.gif
on $*:TEXT:$($+(/^,$DKtrigger,nameless/Si)):#:if ($me == DKbot) msg $chan http://i.imgur.com/gBOIYh9.gif
on $*:TEXT:$($+(/^,$DKtrigger,sparky/Si)):#:if ($me == DKbot) msg $chan http://i.imgur.com/r7haFqK.png
on $*:TEXT:$($+(/^,$DKtrigger,a11/Si)):#:if ($me == DKbot) msg $chan http://i.imgur.com/BUNca1P.gif
on $*:TEXT:$($+(/^,$DKtrigger,eps/Si)):#:if ($me == DKbot) msg $chan http://goo.gl/d5mLWH