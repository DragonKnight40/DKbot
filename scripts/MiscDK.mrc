; IDEK why people like these.

/*
 * on .Source event
 * Links the user to my source code
 */
on $*:TEXT:$($+(/^,$DKtrigger,(src|source|code)/Si)):#:if ($me == DKbot) msg $chan http://pastebin.com/u/DKbot

/*
 * on Smogon event
 * Links the user to the Smogon analysis of the specified Pokemon
 */
on $*:TEXT:$($+(/^,$DKtrigger,Smogon\b/Si)):*:if ($me == DKbot) msg $iif($chan,$chan,$nick) http://www.smogon.com/bw/pokemon/ $+ $2

/*
 * on BAN event
 * Links the channel to a banhammer gif whenever a ban is placed
 */
on *:BAN:#:{
  DKcheck $nick
  msg $chan DOWN GOES THE BANHAMMER http://goo.gl/qhTYTY
}
/*
 * on KICK event
 * Links the channel to a kick gif whenever a kick occurs
 */
on *:KICK:#:{
  DKcheck $knick
  if ($knick != $me) {
    msg $chan OUTTA HERE $iif($rand(0,1),http://goo.gl/zWgqam,http://i.imgur.com/DbaoNuN.gif)
  }
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
on $*:TEXT:$($+(/^,$DKtrigger,cent/Si)):#:if ($me == DKbot) msg $chan http://i.imgur.com/51YBBuq.jpg
on $*:TEXT:$($+(/^,$DKtrigger,banana/Si)):#:if ($me == DKbot) msg $chan http://i.imgur.com/my9GNka.jpg