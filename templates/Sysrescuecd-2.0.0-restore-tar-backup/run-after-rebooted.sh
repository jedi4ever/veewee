#!/bin/sh
# This script was generated using Makeself 2.1.6

umask 077

CRCsum="2516467927"
MD5="2639b3eb563f61ab87ccb38b77d300c1"
TMPROOT=${TMPDIR:=/tmp}

label="Files to be run after rebooted, in the restored system"
script="./run-after-rebooted-runner.sh"
scriptargs=""
licensetxt=""
targetdir="run-after-rebooted"
filesizes="8573"
keep="n"
quiet="n"

print_cmd_arg=""
if type printf > /dev/null; then
    print_cmd="printf"
elif test -x /usr/ucb/echo; then
    print_cmd="/usr/ucb/echo"
else
    print_cmd="echo"
fi

unset CDPATH

MS_Printf()
{
    $print_cmd $print_cmd_arg "$1"
}

MS_PrintLicense()
{
  if test x"$licensetxt" != x; then
    echo $licensetxt
    while true
    do
      MS_Printf "Please type y to accept, n otherwise: "
      read yn
      if test x"$yn" = xn; then
        keep=n
 	eval $finish; exit 1        
        break;    
      elif test x"$yn" = xy; then
        break;
      fi
    done
  fi
}

MS_diskspace()
{
	(
	if test -d /usr/xpg4/bin; then
		PATH=/usr/xpg4/bin:$PATH
	fi
	df -kP "$1" | tail -1 | awk '{ if ($4 ~ /%/) {print $3} else {print $4} }'
	)
}

MS_dd()
{
    blocks=`expr $3 / 1024`
    bytes=`expr $3 % 1024`
    dd if="$1" ibs=$2 skip=1 obs=1024 conv=sync 2> /dev/null | \
    { test $blocks -gt 0 && dd ibs=1024 obs=1024 count=$blocks ; \
      test $bytes  -gt 0 && dd ibs=1 obs=1024 count=$bytes ; } 2> /dev/null
}

MS_dd_Progress()
{
    if test "$noprogress" = "y"; then
        MS_dd $@
        return $?
    fi
    file="$1"
    offset=$2
    length=$3
    pos=0
    bsize=4194304
    while test $bsize -gt $length; do
        bsize=`expr $bsize / 4`
    done
    blocks=`expr $length / $bsize`
    bytes=`expr $length % $bsize`
    (
        dd bs=$offset count=0 skip=1 2>/dev/null
        pos=`expr $pos \+ $bsize`
        MS_Printf "     0%% " 1>&2
        if test $blocks -gt 0; then
            while test $pos -le $length; do
                dd bs=$bsize count=1 2>/dev/null
                pcent=`expr $length / 100`
                pcent=`expr $pos / $pcent`
                if test $pcent -lt 100; then
                    MS_Printf "\b\b\b\b\b\b\b" 1>&2
                    if test $pcent -lt 10; then
                        MS_Printf "    $pcent%% " 1>&2
                    else
                        MS_Printf "   $pcent%% " 1>&2
                    fi
                fi
                pos=`expr $pos \+ $bsize`
            done
        fi
        if test $bytes -gt 0; then
            dd bs=$bytes count=1 2>/dev/null
        fi
        MS_Printf "\b\b\b\b\b\b\b" 1>&2
        MS_Printf " 100%%  " 1>&2
    ) < "$file"
}

MS_Help()
{
    cat << EOH >&2
Makeself version 2.1.6
 1) Getting help or info about $0 :
  $0 --help   Print this message
  $0 --info   Print embedded info : title, default target directory, embedded script ...
  $0 --lsm    Print embedded lsm entry (or no LSM)
  $0 --list   Print the list of files in the archive
  $0 --check  Checks integrity of the archive
 
 2) Running $0 :
  $0 [options] [--] [additional arguments to embedded script]
  with following options (in that order)
  --confirm             Ask before running embedded script
  --quiet		Do not print anything except error messages
  --noexec              Do not run embedded script
  --keep                Do not erase target directory after running
			the embedded script
  --noprogress          Do not show the progress during the decompression
  --nox11               Do not spawn an xterm
  --nochown             Do not give the extracted files to the current user
  --target dir          Extract directly to a target directory
                        directory path can be either absolute or relative
  --tar arg1 [arg2 ...] Access the contents of the archive through the tar command
  --                    Following arguments will be passed to the embedded script
EOH
}

MS_Check()
{
    OLD_PATH="$PATH"
    PATH=${GUESS_MD5_PATH:-"$OLD_PATH:/bin:/usr/bin:/sbin:/usr/local/ssl/bin:/usr/local/bin:/opt/openssl/bin"}
	MD5_ARG=""
    MD5_PATH=`exec <&- 2>&-; which md5sum || type md5sum`
    test -x "$MD5_PATH" || MD5_PATH=`exec <&- 2>&-; which md5 || type md5`
	test -x "$MD5_PATH" || MD5_PATH=`exec <&- 2>&-; which digest || type digest`
    PATH="$OLD_PATH"

    if test "$quiet" = "n";then
    	MS_Printf "Verifying archive integrity..."
    fi
    offset=`head -n 498 "$1" | wc -c | tr -d " "`
    verb=$2
    i=1
    for s in $filesizes
    do
		crc=`echo $CRCsum | cut -d" " -f$i`
		if test -x "$MD5_PATH"; then
			if test `basename $MD5_PATH` = digest; then
				MD5_ARG="-a md5"
			fi
			md5=`echo $MD5 | cut -d" " -f$i`
			if test $md5 = "00000000000000000000000000000000"; then
				test x$verb = xy && echo " $1 does not contain an embedded MD5 checksum." >&2
			else
				md5sum=`MS_dd "$1" $offset $s | eval "$MD5_PATH $MD5_ARG" | cut -b-32`;
				if test "$md5sum" != "$md5"; then
					echo "Error in MD5 checksums: $md5sum is different from $md5" >&2
					exit 2
				else
					test x$verb = xy && MS_Printf " MD5 checksums are OK." >&2
				fi
				crc="0000000000"; verb=n
			fi
		fi
		if test $crc = "0000000000"; then
			test x$verb = xy && echo " $1 does not contain a CRC checksum." >&2
		else
			sum1=`MS_dd "$1" $offset $s | CMD_ENV=xpg4 cksum | awk '{print $1}'`
			if test "$sum1" = "$crc"; then
				test x$verb = xy && MS_Printf " CRC checksums are OK." >&2
			else
				echo "Error in checksums: $sum1 is different from $crc" >&2
				exit 2;
			fi
		fi
		i=`expr $i + 1`
		offset=`expr $offset + $s`
    done
    if test "$quiet" = "n";then
    	echo " All good."
    fi
}

UnTAR()
{
    if test "$quiet" = "n"; then
    	tar $1vf - 2>&1 || { echo Extraction failed. > /dev/tty; kill -15 $$; }
    else

    	tar $1f - 2>&1 || { echo Extraction failed. > /dev/tty; kill -15 $$; }
    fi
}

finish=true
xterm_loop=
noprogress=n
nox11=n
copy=none
ownership=y
verbose=n

initargs="$@"

while true
do
    case "$1" in
    -h | --help)
	MS_Help
	exit 0
	;;
    -q | --quiet)
	quiet=y
	noprogress=y
	shift
	;;
    --info)
	echo Identification: "$label"
	echo Target directory: "$targetdir"
	echo Uncompressed size: 104 KB
	echo Compression: gzip
	echo Date of packaging: Sun Jan 13 19:08:14 EST 2013
	echo Built with Makeself version 2.1.6 on darwin12
	echo Build command was: "/Volumes/Storage/martincleaver/SoftwareDevelopment/makeself/makeself.sh \\
    \"run-after-rebooted\" \\
    \"run-after-rebooted.sh\" \\
    \"Files to be run after rebooted, in the restored system\" \\
    \"./run-after-rebooted-runner.sh\""
	if test x$script != x; then
	    echo Script run after extraction:
	    echo "    " $script $scriptargs
	fi
	if test x"" = xcopy; then
		echo "Archive will copy itself to a temporary location"
	fi
	if test x"n" = xy; then
	    echo "directory $targetdir is permanent"
	else
	    echo "$targetdir will be removed after extraction"
	fi
	exit 0
	;;
    --dumpconf)
	echo LABEL=\"$label\"
	echo SCRIPT=\"$script\"
	echo SCRIPTARGS=\"$scriptargs\"
	echo archdirname=\"run-after-rebooted\"
	echo KEEP=n
	echo COMPRESS=gzip
	echo filesizes=\"$filesizes\"
	echo CRCsum=\"$CRCsum\"
	echo MD5sum=\"$MD5\"
	echo OLDUSIZE=104
	echo OLDSKIP=499
	exit 0
	;;
    --lsm)
cat << EOLSM
No LSM.
EOLSM
	exit 0
	;;
    --list)
	echo Target directory: $targetdir
	offset=`head -n 498 "$0" | wc -c | tr -d " "`
	for s in $filesizes
	do
	    MS_dd "$0" $offset $s | eval "gzip -cd" | UnTAR t
	    offset=`expr $offset + $s`
	done
	exit 0
	;;
	--tar)
	offset=`head -n 498 "$0" | wc -c | tr -d " "`
	arg1="$2"
    if ! shift 2; then MS_Help; exit 1; fi
	for s in $filesizes
	do
	    MS_dd "$0" $offset $s | eval "gzip -cd" | tar "$arg1" - $*
	    offset=`expr $offset + $s`
	done
	exit 0
	;;
    --check)
	MS_Check "$0" y
	exit 0
	;;
    --confirm)
	verbose=y
	shift
	;;
	--noexec)
	script=""
	shift
	;;
    --keep)
	keep=y
	shift
	;;
    --target)
	keep=y
	targetdir=${2:-.}
    if ! shift 2; then MS_Help; exit 1; fi
	;;
    --noprogress)
	noprogress=y
	shift
	;;
    --nox11)
	nox11=y
	shift
	;;
    --nochown)
	ownership=n
	shift
	;;
    --xwin)
	finish="echo Press Return to close this window...; read junk"
	xterm_loop=1
	shift
	;;
    --phase2)
	copy=phase2
	shift
	;;
    --)
	shift
	break ;;
    -*)
	echo Unrecognized flag : "$1" >&2
	MS_Help
	exit 1
	;;
    *)
	break ;;
    esac
done

if test "$quiet" = "y" -a "$verbose" = "y";then
	echo Cannot be verbose and quiet at the same time. >&2
	exit 1
fi

MS_PrintLicense

case "$copy" in
copy)
    tmpdir=$TMPROOT/makeself.$RANDOM.`date +"%y%m%d%H%M%S"`.$$
    mkdir "$tmpdir" || {
	echo "Could not create temporary directory $tmpdir" >&2
	exit 1
    }
    SCRIPT_COPY="$tmpdir/makeself"
    echo "Copying to a temporary location..." >&2
    cp "$0" "$SCRIPT_COPY"
    chmod +x "$SCRIPT_COPY"
    cd "$TMPROOT"
    exec "$SCRIPT_COPY" --phase2 -- $initargs
    ;;
phase2)
    finish="$finish ; rm -rf `dirname $0`"
    ;;
esac

if test "$nox11" = "n"; then
    if tty -s; then                 # Do we have a terminal?
	:
    else
        if test x"$DISPLAY" != x -a x"$xterm_loop" = x; then  # No, but do we have X?
            if xset q > /dev/null 2>&1; then # Check for valid DISPLAY variable
                GUESS_XTERMS="xterm rxvt dtterm eterm Eterm kvt konsole aterm"
                for a in $GUESS_XTERMS; do
                    if type $a >/dev/null 2>&1; then
                        XTERM=$a
                        break
                    fi
                done
                chmod a+x $0 || echo Please add execution rights on $0
                if test `echo "$0" | cut -c1` = "/"; then # Spawn a terminal!
                    exec $XTERM -title "$label" -e "$0" --xwin "$initargs"
                else
                    exec $XTERM -title "$label" -e "./$0" --xwin "$initargs"
                fi
            fi
        fi
    fi
fi

if test "$targetdir" = "."; then
    tmpdir="."
else
    if test "$keep" = y; then
	if test "$quiet" = "n";then
	    echo "Creating directory $targetdir" >&2
	fi
	tmpdir="$targetdir"
	dashp="-p"
    else
	tmpdir="$TMPROOT/selfgz$$$RANDOM"
	dashp=""
    fi
    mkdir $dashp $tmpdir || {
	echo 'Cannot create target directory' $tmpdir >&2
	echo 'You should try option --target dir' >&2
	eval $finish
	exit 1
    }
fi

location="`pwd`"
if test x$SETUP_NOCHECK != x1; then
    MS_Check "$0"
fi
offset=`head -n 498 "$0" | wc -c | tr -d " "`

if test x"$verbose" = xy; then
	MS_Printf "About to extract 104 KB in $tmpdir ... Proceed ? [Y/n] "
	read yn
	if test x"$yn" = xn; then
		eval $finish; exit 1
	fi
fi

if test "$quiet" = "n";then
	MS_Printf "Uncompressing $label"
fi
res=3
if test "$keep" = n; then
    trap 'echo Signal caught, cleaning up >&2; cd $TMPROOT; /bin/rm -rf $tmpdir; eval $finish; exit 15' 1 2 3 15
fi

leftspace=`MS_diskspace $tmpdir`
if test -n "$leftspace"; then
    if test "$leftspace" -lt 104; then
        echo
        echo "Not enough space left in "`dirname $tmpdir`" ($leftspace KB) to decompress $0 (104 KB)" >&2
        if test "$keep" = n; then
            echo "Consider setting TMPDIR to a directory with more free space."
        fi
        eval $finish; exit 1
    fi
fi

for s in $filesizes
do
    if MS_dd_Progress "$0" $offset $s | eval "gzip -cd" | ( cd "$tmpdir"; UnTAR x ) 1>/dev/null; then
		if test x"$ownership" = xy; then
			(PATH=/usr/xpg4/bin:$PATH; cd "$tmpdir"; chown -R `id -u` .;  chgrp -R `id -g` .)
		fi
    else
		echo >&2
		echo "Unable to decompress $0" >&2
		eval $finish; exit 1
    fi
    offset=`expr $offset + $s`
done
if test "$quiet" = "n";then
	echo
fi

cd "$tmpdir"
res=0
if test x"$script" != x; then
    if test x"$verbose" = xy; then
		MS_Printf "OK to execute: $script $scriptargs $* ? [Y/n] "
		read yn
		if test x"$yn" = x -o x"$yn" = xy -o x"$yn" = xY; then
			eval $script $scriptargs $*; res=$?;
		fi
    else
		eval $script $scriptargs $*; res=$?
    fi
    if test $res -ne 0; then
		test x"$verbose" = xy && echo "The program '$script' returned an error code ($res)" >&2
    fi
fi
if test "$keep" = n; then
    cd $TMPROOT
    /bin/rm -rf $tmpdir
fi
eval $finish; exit $res
‹ nLóPì\{sÛ6¶ïßü¸Š3;¦HÉ’ÕzëÎ¸±ÛúŞ$Îø‘îŞİ½Zˆ%¬I‚%HËJ“~ö{ÎHQÇmš8İŒ8“XÄã 88 ¶½/>úãûş ßgôwßüõ»=ó×>¬Óõ½ı½½îŞ>ó;{İ®ÿëñ O©CW2bÁoD¾¦‹¢wÇQÿıyÚ^ÇME1Uùµ[fm=ù8ó¿ßë½cşÕüû~
ú}¿Óı‚ù›ùÿèÏ£ÿbŞH¦0÷ÖqÂIK‘L“#£@¥‘Ó{ÃÆ¹ÈÃÜq¾Ø<ŸÅ³¢ÿ¿~Bıïz~õ¿ÛílôÿÏ ÿó·şúßu©µLÇnÆƒk>úC£€ûô¿3èUş¿¿Oú?èôö6úÿàúã8X*D(B©œ08<+Ü±(˜LqÌ~-–Š¦*u£\ˆ¡ÈåˆiUæX©ë‘›à²òçÕÿ_RÿıA·ÒÿNÇ şïuûıÿsëÿFw>7ıt§ôGÜ£ÿ{€ jÿ+ Äÿ}¿·ÑÿO¢ÿ|²ËŠ‰È›pÍ
ÅF‚ñ”Ë–"gS>Ûe£²`§,TévÁ®S5e*b*Î£IQd7QÓBµG’g³v O¤^(à5uÇiéÆ2-o==Ó…H<­¢bÊsáiQ”™»B¸<İ
W¸¶>É¨,T.…vœã“ïN^_œ_œ½8lm=Ö¨‡8chqs½ÓrŸŸŸÎ‹ZÎ´ş(·¿Üúe‘ÖÛÛöDx`û<ƒet;–ºØfÿp<oØ"÷†µÊ,ä…Ğo\o‚0WIk^XæÂ(b™ÈBä‡-Ö‚÷HŠ8Ô‡İÇÁD±Ö#vL­qT=àYÛ2Ëá¨ÈÚQŞ6\i«|lì±•‘T¤°:öìhvA‹ Ìe1kRX­êY¦ÜÕ‹÷¤j¥kí²,7R•:‘x¦yûFÅ¼±Ø~O>º÷ŒäªÄäÛ;„®z¶¤‘AgE\jüıä¥¢õG¦¦ñ$æ®~¼/™O)3€§+´~ƒÔTE+±©œ!b´qü·Œÿ~}Xü‡ pÿéPüw°¿ÁüwşÛ˜¯?®ÿ{îÌ‹’Ç#uûiö»{uü§7ØÛCıïtüş?¬ş#<²ê;NÛ¡@T+xó‚‰ßkOŠ$vt*¶
¯í¬„‹æ¤Üq)táò0”…T)”%à"S‰`åJ@#K°ÑìO£ÿŸ`ÿw0¨ã?] ¨ÿ{şæüÇÃè¿Œ¬)
æF¬
8„ákĞMö)öˆ]NKE1RªÖjÙì•ïÔ-Óe–©¼`OTî0­ØÄ@‘‹DÁ/Y ¹•Ÿ›¥…5%¬¸4Ó…Ê°x$*dØ5ÊÅ$00²(CÁÜËÊ|,ØZ:·Îú4Sìî¦Ç|j­×Ò0©›[0Æ^}wö×:µõ$à ”ï†sŞ_wª§g‡¯€âHğ¨¢7Üj’kK­ |¢ÊfH±X©ŒmUÕ™—¤dÏ„~øß<¤øñUM±—)*ªò(’N­ÿ=W—#@b¬t……?8¸×ÿw÷êó.ÆşŞFÿ?şo{#®îù´½¼ÍàƒŸÂÁ#ÚöÍîaÉ¬€(èåd ;S@õõ›9Õëk‘«Pêk$¸qÊêÿ×éÿ¯ªÿ{ƒZÿ»ıÿ ÛÛàÿysï™P²»ßöÛû.OÂı[9ıf1k!Ò*°¶Vù×”XNÛfješis3´˜|g‹;³¢ÿ ñ.
‘»¹À¹!TäÜsş¿ãïÏÿwış&ş÷‰âì'Á`şöJ€øSˆHì´Y™†"'4œ‹ Ğ|>cA¸ËÈ”M'2˜° ÷ZeÁêkø¡E!ø/hñ0e9W¤w€Z·ÍHâšÔ¬û)"HQÇJ×/S<§T5°ã8—Gç?œ\>?»zqyHØ4äœŸ]şxöüäêW*xr|¸Õ¨çmU¹¢¿37d[KØ?íŠˆ1³÷v,
`‹	@~Š 0n$d:­… ş†QG¼UĞÿ%âü•›uV•-Ûš¦kçÂî±@e»¸Jû$n¡¾#b`m]ùìC¼Õ-!™Æ5· -Ö›°ëgdÿ›îñã´ñÛïõö;}¼ÿÕï÷»›û_?ÿÚ=lü¯ÓëØùïù0ÿ{´ş÷7ç¿Æÿ³+:
@v s¼wgÕ!FJ}Š#LîDp€ÚİzR¦<ÌÍwØ¨”qè
­EZH¯«ü:–£ÎØÅĞiW?s ”EÖÕÊ<ÿÿZfu.-!¶\Ğ©†ÛN™ #¾@^Ú*—cGƒOt%sÛÖŞcÚË8zöìğ	ü·ƒ¿i/Î^]\üt|€ÉãíbØğåTğk¦õ„¼,"Á3Ç/.Àık—èáÙ	h:«1gÇœßÙ¾ÒK¦j›}û­%­'ø/š»wØÄ¹	Ÿö5Ã*ˆ2ª,°¹š,‚€†ì7ßœœ}Ï,½PD¼Œ«­ÓˆÍTÉ‚	OÇÂ ¼HÆb—@ß¶™rËnŒ6åyH»ÀV^DD‚Eè¿vÛóÃùÕwÃã“ï®]úæõòôùÉÙUız|zqy~úİÕåÙùá¿èÁLhÖ…ÃÄ{i	SıæA#fMú/Càéóãg§/N†ğßÕ_ëÆZ?—R­5E[v×Ø
ÈE:¼ºh9ÀÇiÖÙøÿÆ2ş÷üıîªıßÄÈşWûOaî1._*k	ÌuSåæÒşU°şŸ³ş¯Ù}tıï,ë·3ènôÿôÿ©™ój1àšÍ¥=Ìß·ƒ™'óMËıøóëÿ† ÷­ÿüş`Ùÿ÷»ƒş? şºo.¸ìy÷Zæñ²P¦~½tÁXh,¢ƒ¡Œ ¿fxs&Cs¢\/åe,´½Ô@RˆuÀ*…XÌ™*-´#ŞÏ=X+z˜á}‰M<ç×¢Ì»Â…$,Ì4KÅ*¸fªÌ™ı¾Åê%V ¦q\/ašGiíĞøî¼“¸Ö6M®C™ÿò@ÜÍ#³¾iSj²X¿¿T¸šŠœK-%;
4·0ÎºL‹€…"æ³*Ø.SX·E<0Ä]LÄûš”SŞaÂ³lÖ²´`ÍêâÒ9"cİV½µ|ójzzc¼?oû÷ğGÅõùÿüço¾ÿò Ï%€TŒ{{v¯(ÊUÂŞq@¥ì¢LYgı78®?:_ø_tzìäârc#şsõ?ÌßÎG…ÿºûİŞÒúÏïv7çÿäy%ÄTˆƒƒãùÌ‡"ˆy.üâ0vdå0 “£‡ß²íÎö.&& êòÙPË×S»ı}“'k(Õö;={×&G*O¸¡òêø“'JC{&¦¼Š"CFéa1ËÄP†”nLÑp¿graA9Äˆ5æUñİ%3…,\x¶ê
xãËÛA(>«×.İ ôˆ˜GÄ<¨‹I¿µ™$ìS3¾ßÿªîïE_ñş¾Ï{ı?
¯ºxÄõk>¯ªi+« >Vï€™"hp‡S.«ôÖ®M’p¨ÅÏ¥HâÄßé&èö7':ø–ø/U ¯zœ§…½2-#Ÿ¾||ğøåÙùåcÏfc<¿®²>~^g#Ö¯_ oóX,•¸….€L¥Eî%¢˜¨ğ°Ôu.0Zó`å0DiÀåÅáãGÏO¯+ª„ËôĞú‚ej ª*#ç]ÇÜà×4<LUJH–…¼™—ƒBZÅÂ¥['Qé`Ç¹ªØµ˜%<Ó./<ó³9oN°o·áíŸ4×2¸FSél<Nâ Óí¶–2—'ß_.P|c’L­'CÚSº‹(ı”ny7ÏÉ¸Ö òÃõ¹0BÊ˜§à45ÆÒ­Æ‚yt4~Yg•¡By¥D³íõ8Û~ClîÓx¶mÙIY JÔå'<†Uefr3´F‰#z.ù-»uİ23ÑšŸ¬Sš1Í*Ñ*¬^ë“‡U‚İ©_×ÅG—2)Ó†­Z$šƒX2çíóéüCº,ş³×íì­ìÿì÷7şÿaâ?ğ°§d!×x1LáÁ5Ü|.sNÛ×d~à'¡4¸ñZì8XïZ|ùšÊ8öUàõ=ÍbKp±ç! A¤p%[v)^l«9F4È}`XçÄl¤x×c0ÇˆLœGH ²Ä…R±öxL´-Ãxá4K¬Øêª\©¡“[b/èKWœ…2ŠD±‘ëªa$-Ñ”¹Xlº"\êÑå„˜
ÿbÑCaü¤¯l¡[cSImèñõ<rCg
ñ$d,Ók&#fCËQ,ÚŒ–lÒÑæB•¾–t_ƒ
ÏLL?ö€uÌ-n,­r"™â-íy+fB¬‡5½Î»Pñ|<sP,ä3T• Øè0Î§àáaÔ=4tœùaº&Æ™ÕÔüÀ]a¨eÇ´¬¬ĞÑS0™Šp´0{@H»æ,C"Ç“o¬ƒË‹Ê¸½Ğ¤]Û\+oû~£# ø¶¢êùöøª™Es6í²2ÅÏÿ ¸P³xl»¤èÀdóÔÕ•i$`œK“šÃÜiğ€ï($[ä¥hômÊÓâÚ	}¦¶àİCÕ@¨˜€„Á¦gøGÎ›L^
˜‹®y¿8 rÿ`Ë‡N…,U…XÍTíUÒğ´æõ2Ÿé`Ï;x¹Ø0bD„f`ºšáÎ×İvgÿ«v§İY).3üœ­Ğk
÷º«ÄE‘ @¬ÊvûıvõÏ_)<‡:å³ûzAãÉ“¡åóòä¥3VAcš‚“x“ã´ŠÙĞ¬ëE!­0ætnxèm3C£Ğf?ª© é‡$R$œìªTfÉe2=FlG™ÆÌ	g=°¶Ë° [äIÌ»´:Iõ€,o,Xs–ŠÙ¡.2°Ysl”Æ˜J¦Š¬ßO'/Ñ‚ƒAä ‹,ÜTâ#­‡S‘Yª¹Û:åÁõÌğ¯î‘Õ8’Ó‹—šÎBƒ9Fëg38KXW¯‘şåæ4|b•¹şTÎ;~ú-tã«‹Mƒ¯
­8˜È<Ä²»æôOš(–¤b<Ñƒ™ËiS ˜d"+ÁÜd8ëmv†ÒQSÌ,zà‡5I0æk,gÆ8™ºfqäÑšµÀ’Ô.ú=ô˜ĞÆ•=L©L	‘<’CxToW ¿-©¾O>§'“…Ãİ¦¢f€±K´Õtqñ£u—*gÖgj‘âEj=-éèø(•'öRŠEmˆWæÉrdW®.Q!nÓT¿Òu+)ÍD¯–¨úGîûErOi—Q;–ë÷ŸË<G°f<w"ÖâFEFßxw‰=Ğª^ãšn’Jû e‡kë€*PqU	h:ì%’†eÍğ–Û¥nfVª„ Å~ß¬ªc£3+¡ƒ·U!r$¥,H´í\.GS®%‰7âu¨+¡<¢°¡àc‘¹ºÕÂ¨ÙãÙx¼³H¼„.®o¦ë)mU’ÇpÂ^#H3Á0Ø< Ë¦A–€>¶l@eX@¤±ïĞÙ«Ë§ÆòQ†m”Åª{ùÈD‚NJX ƒ¶\rÖ®Ç½uù¿£ÃÁ|Á€BKü›àG|°ë2”GuãLp|ŸáôÔY7JËñ—/é˜«06ãË¼rXvVÆšK8ê‘²¸Òo“é·Çc‘y<NŞí7¶3BHG¾ÒbÿEò®¥U):È­0
ëŸ`^_"PF0²t5o	!¸'7 3DÆÖ¬W‹è"Ù¬¬"aıQF°:„Y V.túÂ%#Ğ8çU­ÖäxŒšêcxG1Àò”c4!mÕ‰@F3ZØAËXQªXv#¡Ç¤·IIŸd 1–ßÜâ1ù:(áÆÛ8`¬Ø‘¡õÉ¼P£R„ˆGÑI/³Š¸‚C ó=˜åøn%.ä_d$/^œzG—G¤$TéÀYáuanFn<rœ¨´şÀ±eĞPe
+îõ¤€f%NKP%- ·ü@09QS$,‡‘·r1ÆÅSk—µâ›¤EŠß
òYV¨Öjm#¶—PÁÂä…uN8mqXƒ±"õ0îjŠÄ|"EhğC.±>SqÈ½z¾¯ à!-TSœC¤ƒğc¨È,0@)!	r´(@#ËB4”©İn/Œá!š“"CHYÖWä¥&Ô›e±Ú®wÅ­$ÓÉª/‡±ó£ÓcxÎg‹Sœ„K­$á|m—9ØÒı^Á,07WW¹´×$°³5'õêĞlÍÅ¶î(4LBC|±sÍ*¼XÑiÜµd¹,5ÔÄ¸”0fC¦vÃ·•Ùo›†(4IÀgÚ
á| öB£Ì„Æ¡.ã Y28`¸Å`¢±ÒÄê*T?…rÀtÒñ¦	}e©P&X,Ú%×²K‡~vIM¼"É¼_ÕË'ÓÑyX{ºÀOköMÙX™* u[ì!Îr„É7ÀB°„–">xš¢L!µyvƒt TA‰ëiàšC²I1™M{³dª¶‹[2Œ‹Ñ©9Ğƒ§ªêö‰ VsÎÇ#Ò™«›k.şf5;€ƒè¿Îeˆ[@¼…e•Ùa¨Lá$t+(ÏdÖ—y,Ã@BÊğüW^ó îÚú…‘ öw,À$íP°ÁškÌYúÌ)g­¹o2ŸtX±B³Š±¯)ÏŒd”x¨Ì@wº•fãZ+ÎèÜÇ’Šw=ÿÀOáƒıs‰øÁûOM zz>ëû¬ãû$„ïA z¶²\&<ŸıÂŞ²-ì²_~+ãt~©„ú­ı±BâN0İÂzÍ7ŞÛw÷ ×$Á¿X	xûÛxĞf¿ïY!Ğ÷iªÿM<ÿòŸÂÄ;øq˜¸ßcıN—íùşc{ŒUõ=D¹b"U¿“…ë† V«Æc`Š)DK©eÜ‚¶Î³EØ®úÒ)Ø(Î°¸¸†uµÀ ·±ú–’AEÖZ¹ùzÍlâ´šj×D-G0%t¾L47 ½…áaáöÿÛ»ÚŞ6#ü]¿âê‘ğHQ•TC†Ôv’/u"Øƒ´(ˆ#ï$^Dò®<2²œæ¿wyÙÛ{¡d£ªŠ¢»l‘ÜÛ·ÛyæÙÙa9/G›x|ztrtr*ñysq@¿J©]êœv|¥e`û— ÒÔqÈî4½|C†VÂ¦b
åbÎSœº:%İdØÔCTma…e²Ên&¤áf‹ºÎ½ÊĞ§(B°¥^à  XğÀ>úÉ»¼Øƒ9™K²7o«(•”¿ÉêŒ‚·Ï¢k2„²…Ayğ%{*ùq$ak]53×¡=·I¾N÷T-§"&šD4¤Éa¤7ì¸©&5¤Ï¢'d(eOL{æçØp©,+§j?ugc¥Z3xòW1õ6>yz&ƒúç™p{lxWï¿Œ¡]Bó€èM4ßX bØ—lÀÔ`0M†)÷ş¡ÍªºI9EÌT÷~mìZ¢0³º-é©Û©5\–JÌ?7Ë]¶~ÊQ–3È@-Ã—´’¥¦va9§îËÙ†ä,ÿ m²›x8®Ëëš÷úÕ)lÛy³Í"í!Wèßì©¿«WNô¥]äŒâËíbá#nï¥€g×íÌ}=ìwWÍ~õƒÊÕÒ 6r>Ì 6‹¼kP¿ˆ^Ê€Ö`‚ZÀ›¹*•
UD?’İ©~OgŠ‹]ÑSù6wFüøh|ÄıåRÒÄl5ço+g‚ı¥î?o›µïÌnï,Ò4U£àwKª3ğæşÑK½ZÛ²"…Ëòxû›Ç@–¼êÎ)ít,O[/“mšÓìÄ5(¶¡‚*_æ+•<e-u~î@_Æ\s®aØÍrb÷úNƒ¦¨œån"	ÍLVJmø±éÏU„D8Ï« LIí£dh·ÓèlòSGÊé>%áŒäğ9#’ùLĞzôY$v·Î›ÜÇ¦ +ñ½úèày÷+ƒ>ì(‘•©¯£ê´Í*‹¬ «[ÿ¶K5‘İyÑ}Zr°wË^rÏ]íç¬¼Æsö¥ÿ&î‹[‡È6Zëì[²4æòÃÀ+Ì5‡):£1My&„ÜäqU^Á'¨v¦¡Úşfë9¼P>•à•ÈÀçOsã¼4úœXÛƒ‹y“ºı¸Ãoáõ:Ù®mt~ ç1»PİÀÑ]ö6IuMŸ"ı$Â¨ñÒtıÖàršU×›¢ägÄ!°à U·¦ë:•%õáræ©ØÖ'Ì¢«„…æ£n¶f•úM£*\>ƒ«4'°¥ÉiÀ*ıi÷z+^DËõJA~u¤Š2[UÕÜpw üÉ¬„P‘pú1/9|™ç@(i§H³º	:–r-*5A_H÷ ×“™›â2‡Z^%—8Å"lšöÉo¢Õ }Æ£ìiÂpéYÙªåA„Ãˆ&&ğzCÊÛŒ)7âlV@ÓP }#¬í	ÊÑÍ×çÈ`ÿPá×1 FÒÍTòğSÍ³EY)bSü‚>À¿»^B5ëbcıeQ2÷í±w”ó±—¯HæèÏ$ø"‡Œ¨öW#áåe²É:Ú´}èkpµ±BÑĞö¿C”¼jLĞ©—ijÌ™E¾(êÑ¬çz›Ê£°‚‚xk˜ÕÑ6@7{¥ªªfm{QttlãJÛÂ8+
­ÏŞY­™…8µCÖ˜©ê#pø=69PŒÕß´¢{ıâFV†rh…­ƒTwìRrW’¹LÈn]©QØ$¸h&"şú³n^ıd-›\ÓĞ°|#L"£¬°pCÎ¾è>
òów0IÅ#À0,‚Ú*‘)Â{‡tö‡·½}€–7á“¢êzšvJî3³
¿IV£Ø."@¾ãœ®±ë9ÀWÈ‘LôÙWı“°o|U·øäìÎÂqX“·óôhpt(İº&ñ‡
‘ô kÙõtş9âÿ±şŒ
ğ:K·%¨BEŒòv˜}õİM£Ø‘y‹â>ãbÀ®p.s™Š=qğÔ¼ş»êºÛ–#±÷-Rz8¹M;åI<ßş·•­hW„ş®$‘"áìg´H÷ö#$ÎÁûwãøı»³CÖ_Ou ö[¸0ı›d:lèÇ`äà(¤V½RÌC ĞšÂè:ËJc°ô,«_‹\Ãh.¨8´ ™;<å0Wõ8(ëŒ‹	&YÁ­ª$@æ$_MhK»bn³MİxÜ¶ÖÆÌ#™a4~ÁËW>Û@ŠÆòu²Gh¦/1¨riu
k æ‘¦¸è.8a}ØĞ;­]7ÌE€±ÒC%À–N£2¤iµÆít*Ëw)§ˆ :âC÷«+RÀƒºô7 _UdgÊà¹¹¹³*.eu)c‚¤²®ÇKŞô6Lü¬TÍ¥WYêX¬_f@3Áì
îÛ‚I]òˆˆiš,dUØBj(ÛÚß1Œá<şKz¿3`ŞÌ¥5¤Ğğ¾f%ÍœyLÏ¦À¿¼e…J+³¤Vzn‘ºZ¬áÌ×>âU­$*ê«Ìİ•†ñÅ¦¢W•²ã6Šôd6ÄÎÚ¨¢ØÛ¿fOÃ]¹¿Ö,üîh	§¿&«ô„Ri¢ôå›íŠİÆ3š ´²¬»ŞŞtëz`]¬æLË'é„]l¯!H$s…måzÍ®™¥
ZÿG[HÏ¥áœnAğgPã’4şªæVfÊE‘×Ç”Å
Ğo§×•¹È¯5z^æ`§ èÍ-2ŠŞšF¾Uª?`V¤kp)„ñÏ^o¼Ái6K¶ñxßÀì…ÔAò"Ã²_Õb¼mP·H2àL^NöJ*­¥10Ç®Xºµv8tI¬M+‡¾à
ªˆö`p[ê52ÀÆ•Œ—÷úÓVÖ…
\]Ó©™Geïv%¹XB*ï0S~‡cä–L¬…àÈ¸sŸ¶¯x“¬iærÚÚ8óÁáo£
¯í‹Úõ½u3ı.·ü2±1:À;“o˜´=ñüÆ‰(µÖxı"ô¦Ë¢IÒ5^‰g©n‡5àÕfşuB/›µ×‘ô!rÌÇ¡™1>O¯ß2©/\†ÈPUÅÂm 2ã,¶RtêJåáº¿…½‰÷ê¬hz}s¹uj!¶ß„³õÿ{çÿİùÇ­ãşøgíó'ãpÿû#Å²øüî e:„ÿ7ë_C?p÷­ÿ³q'şÛÑY8ÿûÈëÿ½{±€RÓ‚3„ÿqA»éïñği´Îè¯»ÂD'ø2Š½õH>Ï†Ç{Ë;.˜ÑÉóÙã/“L¿?æ%ë`²ƒì³t+Ç€g—C{€¹4öaG1OöfÊıê+	í¨~G³´'~äŞ³Wk¸Š<BRœ} Ã„iv‡.Ø[ÏîêñŞyı×QqıON;ñOBü¯GZÿ8_y dÿ±_ZC ê„˜ ø+Ç|äãÓŒÙ¥©²LM`=‘Æ×¸È·T•Â>ó¯M‚“´¡XtˆÈ‚§ãïÄÕ—Ñ—eñ‘í—kpœ­ã—Ô¡L÷£x‰ğò|ÍÑ4ÁEGß»²=‘e¸În-¾c\.#\H×ºÎ³ªæ*¾şRôü6‚£·Xç³T*±E!Æ*’cëäfxEıDàüb9Zæ›ö¹+b™ı×måÖc¹îïÍæ¸õè¬·AíJ)7ğÂøõëÜú×Ó¼†hpR@€Àš8¹Õû
~Ê|¸—D¦Dê¬‰176h6'Ñ>¦v’¹8Z›Ôïï¿}I4Ê¾}fuYÅ00‹U¸mèåÿä&ø{ï>ûc;ş[¸ÿù‘Ò}×??ìíÏŸwùs÷îçpõó¿{õs}ósßú÷V=¢ı7>·õ¿?üç‘ô¿¿Ò;ÌÏêH¥X>¹ƒlğÒ3“ü|/Iı9Ÿ›ıÈ…Ğ‡o^_¼û9šVÏÇ¯Ù"3ˆ¿
{xH!…RH!…RH!…RH!…RH!…RH!…RH!…RH!…RH!=|úw¸Ò} È  