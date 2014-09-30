#!/bin/sh
# This script was generated using Makeself 2.1.6

umask 077

CRCsum="3599234632"
MD5="c65e40724b1dd485c49c8ad3e72d8533"
TMPROOT=${TMPDIR:=/tmp}

label="Files to be run after rebooted, in the restored system"
script="./run-after-rebooted-runner.sh"
scriptargs=""
licensetxt=""
targetdir="run-after-rebooted"
filesizes="8943"
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
	echo Date of packaging: Mon Jan 14 22:15:34 EST 2013
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
‹ ÖÉôPì=ıwÛ6’ıõøW`eçÙî3E}»ëÖÉsl§õ]lçÙrº½½=-D‚Î$Á ee³ıÛo ©Ï$İ6qÚ®ôâX`0_àzğÅ'ÿ4ƒn—˜ß=û»ÑêØßîCš-€iô:½fƒ4šíV³ıé~ñŸBi*¡+)•šgaÂè=“kà ,ß?HGõûwò©M?cz"ä_äu5ş4óßëtŞ3ÿvş;½F£	€f¯Ñl}A›ùÿäŸ­?‘`È³@‰ÿàyÑ8L8Ë4azÜñxŠ,æ#óDŞ’‘d9¡Q$=ï‹Íçñ©-?åJñläÃì
õ	TÀä¿R_Ê÷ ÓDùï6:ùtù¿÷¼­ï=f’‘1UD2d„f„QÅ™$:İ'ÃB“s‰lG“»LLˆˆ‰È˜·5Ö:?‚±˜hQršOë¡H–ƒÇÌe…Ÿğ¬xÔTi–JÄzB%ÓEîCÃ>(-ùĞ§Yäg"ócÉ˜ïêåZHÎ”ç=??¾¼>»¾9¿º<ªmïBk)Ô#‰$ƒÙTŒø¡Ú«yç××W×G3fÔYísıËí,âúgìL‡Í5ô±!Sõ„+½CşÇ#ğyKñø÷¤VäÕL½õ•ß†‘im$óa	O¹fò¨Fjğs–Dê¨µçy,RÛ"§f ÄTÖ=è)qu^eİR¥.äÈ8 +#)QauìÙ¯A1ßÅÂBr=Ç°Z5pDyW/~!okÈw@û$—ì‹B%SÃFŞ¹	Õ<a;¿şFò+P•lòôLWiyĞ[a—RN>¿”¸~ÃT8~Ç¼«¿Íçä™@Ó\?ƒkJĞ’m Ä1M,*`£#÷ïîÿµ+ÿ/§á±î~hı×=è•ëÿú‚æA³½Yÿ}ÿdŒE(¡ºuyBAŸTŠÃŸ-’„¨"sb!ÉÜ-à(ìw~Cğßeÿìúø¤şúlŸ_’›³³‹Ò¿"'W—/^ŸôÉ÷çıïÈÙñõËÈ·×·ÏÉMÿöÅ@áƒË)ô9G²¥‹8&	‹aqšæzjKcPÎê™6Ï\š(AÀ›$ º™Ü‡ş–ı"‡·µf$Xsi$á˜Å8’5Ğ)½cKĞ•õ-½6«†×ÕÇÔwéoAù¾Cşz\ùïºõ_·İlöPşÛîFş7òÿ	ä#şKòßñï¹ÔM†âáóÄ[íNeÿ[-”ÿ^³±‘ÿG–äi·(™L&õ9¦ÀUIJ3x
Âq£Së4ñPúIÉà%wGw©òf&¶,áòGSÚ§QÄ5›¥Ï8.WîŞÚ,M>‡üÿô9ä¿UÆ;í6Ê»q°‘ÿß«üÿ+â¿‘şÏ-ÿ]_C.ºK¾,²î|PşÚKûÿÎfıÿ9üÿ¤oÆ”ÖƒÒ©7à*OÑ“¶O–Ãset$i¦gÎ—vUò"Ï™=#Å³"_4B‹ïLÁ–)yÃ¤ˆ¸ºCìáıdòÿÓãÊ¯ôÿ»Ífó?ZíöFşÿèò¿õNéßZ’ıà:ùïùnÆüPÀ´sü–S¥&BFg+àÃòß,í»×< V³}ĞØÈÿcûÿ¯on¾¿º>=rá6™o˜ÊŒÈµš¼BÎˆ0+d»·PÕ#yKûDKÕõ˜‘×1)“0ÙÏBFÊ>mDö#Ë?X|ŸÆšI_²!L1‹Ğ	È˜ühë€äÿ6{½nåÿw°şoá–ÀFş?ƒı÷¶È÷ŒÀüƒ¸rEô„‡ì
›uRd-J±d¡ "MIí“]‘É˜‡cb®×$…—
¾(–Ä(ÛX%c"¹bµØZub8nÏÃd„™¬³’× /2Ü§*Øó¼şñõ·gı‹«ÛËşQf:°y×WWıï®.ÎLAõh ÏN¶çêm—/=Çä¯ÄÈö<ùÛ×ØİÌ#Ä¦Şœ2ÍBì¢SmFâút2ÔxÕÈjP)½Ç1Ó•àõsñğ-FBË@È—u®ÄJ›KÕV%½£5•l¯™K!¡È9³zv	¸VAÿ 
¢Æ¢H"Ì÷“ŒFS³·Aİ\üÉ€>À4<–ÀTT5¯î0%³ Ùƒ–4¬´ıœ'‰•OÏ¯ªöM°g~å à|n|›­³ïƒĞ’‡û˜ø'eì¬
%Ï1ğDù_"à×$&G†$•}ï
ÌLo?#~ÆH£šŞÿ(‡å€IÌ3®Æ@¾	×c³Õƒ¾(Ùİ~¶géŠˆí:¨@F5ƒË·Ÿ¹†b_"Ì„o.qëøåKrzuyVsÏÏûß’õƒÍ¥¸çL£ïY’×>ê¾ÑûõÿO¢ÿ»½2şÛí´ZèÿAñFÿoôÿFÿoôÿãèÿGSÿŞoÍÿŸ›ƒOtğgŸÿkv:fÿ¿ÛílÎÿ=şü»PßÇŸÿ÷Åš¦;ÿ×iôšİ¶Ùÿilâ¿cÿÉ­I7
Tò|Î’K_—Å„'xÀ¥à({·ÈhÊˆ/÷È°àIä3¥X¦9MÖU~“ğasäGìğ•JÊ¯ht 3ëbÁºša!°ÿox^½5abt[nLV»MJsbö•ñ:¸ğP’<
İçÄgdGOÌ^6xäG»ğß~›+»¼2Á¨ÓC,í, Ã†ûFïˆRcc`ñŸ<½¼Ã©DR }'»*gĞ$t0#ÎuûwnCÈLì§Oj5ÆŸh`Ï^b×}*ÒU6ÇMó”‰BcsZ´`~,Úo¾9»zA¾ˆÅ´Ht`²Ü¶ÈyL¦`êÃ1ÍFÌzy˜C·oœ¾;å>ÂîXmBedN9nØ1ÿÕÃxT÷<Lİœ½8¾}Ù?jØÇşùÅÙÕmõxz~Ó¿>~Û¿º>úûÂ-˜	EZĞa˜ø +`ªß¾µvØoù»Eprqúòüòl ÿİş¥j¬öcÁ™®­9ª¹Sc˜<bÙàö¦æ}<on°ÿ¶aÅEıï¶jWÿÃÛÖªşß¬ÿIÿŸ;åzsïpıRj[( O;¾äîw$ÂM ş,ÿë¶c?¹ü7—å¿Õ<hmäÿ‘äÿÄÎ9y]Í¹÷úùÕ_ªCÕÛ»!Õ¤ëõF;³g!Îo®VCƒíùê×ğdJ¶ËıñÛ—ÿì|hı×è,Ûÿnk“ÿû˜òŞıü‚KÚÇ/ZæÑB[¿Zº`@î`4”—_¼9!Gu¢4®—d‘0åöBbĞJÑs¶JõHpOe kÅ __bôc’‘[\HÂÂLá½ÃD„wD’¸ûÖ`/°‚iÚ"Çõ–¦¬ÖI¼(©n;šŞE\şğ€Ü—±]ßÔMÓd±~w©>P5c’I¦rÿÔ-Œ’Q,$Kè´¶óÖm1qñÈ’yS]ï3¦y>-÷`ÍêãÒ9a,'­Zµut*|j£¼ÿØúß®¶ı^½Qïù4zäA\ïRÿ¯Õ^Œÿ¶š½ƒŞFÿ?Æ§o@"Á½=·MK‘’ws¹€Ÿf‡ü'V£Ù&­Öa³{Øî³›şFGü~å?b¸İ…n|]ËÿkõZ¥õ_£ÕÚœÿx”ÏkÆ&ŒÎf>baB%Ûı‡GÈa˜ƒPà2=%;Í},LÁ©“Óâo–¶º=[	Ú¦Ô7šÆÎ¾+…L©Åòúô‹ÇBA{!Ç^Ä±E#Ô@Os6à‘)·ªhĞëØ·° `Äß•ñİ%5…,\xÖª
xãÂ»naÄS:b«×îøadA@],ú¹Í¤Q×4Óht¿êF½vüíöô İí4†ÑAó«V¯İnş™ÎjDb’%‚Fƒ2¨Õ1ıÅ‚ ÂL(/Ëkû®,L£b?,%şj6›w¾9SáSC'x(yå3øyŠ±((dräñäüÕ“Ã'¯®®ûO÷ãùU•õñóê5úúÕøÛ4aKwÃÈ'S(&ƒ”é±ˆ
U½"Bk¬È¸¼8zry|qödH$RÊ³2;–©!ª.Åóæº;(˜3ğ_³è(™ñd1Cá~@J$Ì7§
¬™Ì%t%Ø›¦4W>Õı:?oÎ°§;ğô73w<¼C£¹vš­Vméåòä7–*†Ÿ›$£Ôx`ö”Ş…L¾5–;ÚÍŞ”™şëßÂÍ‹Y	NÓÜXZåXğ9Ü9{Y½*"üj
í¶×“|ç­Ù`óo0/cçI¼ã`Ç…F‘¨àÇ4Uenßæ¨1,+Š¨ç×ÜÖuÍÎDmv
¥*™i–…î8KùXN)Ü†Hõ¸.>ºôr®dîĞJ­b‰ùA¬N™÷Ï=ïóÙÿ9îz´øŞõ¼²ÿÓënìÿãÄàCNŒ†´÷½`˜ ÇÌ5Ü|.$5Û×Fıìš+09ìÛó°ŞKÔøüñÜ#ÃãÛŠ$4`bMœÇ8æBBŸ“e“$®š–Ñ0æÃ:ÿÅ¦CA%O@£gâm!‚Rk!P•ƒ!T{ó+ºº„+4pö@í™Ër‹x3‰±‘»²aDÍÑ’-6]".Ôp	sJC,…ÏèÒÆPÈ=Íí1hÖÈ„›6´xÇê,rc’
12áÙ¦ªÚP|˜°:1K6é`$ Rw<‡î+á©	áeXÇŞâŠĞB”ŞÒ:kÅNˆ³°¶ƒYJš‚7y‚ä` }¢à$Îuç“ÑèĞê8Áhz³d„1ÈàU‰˜Ø€˜+"ïØ€–ã“ú l
*"-Ì âzßæ2¤|4Ö˜Á&/.’úBww¥s¿õsÆ±QÍsé«ví-ÉtŸ^ÿŠìbšÅ´ì. 2™æ9¬ª-
ÓÁ8—:Æ…¹˜ÁƒgB²Zl®ošé÷H'ôÙ´Ï6U"=¶i‹¶gøGNç‰¼8Pÿf,ª¢ıâP Ë‡ƒT)t*"™Ğlõ¥ÈÍNQÉ'­—él{ŞCËÅ†ÑGDÒL•3Üüs«Şì}UoÖ›+à<ÇëÌ™ZÜi­"g:±„mu»õò§±<ƒ:¡ÓõÂŒG¦GçåÉ?Î¦¤tÍœX'˜˜qpŞø(+c6fV5Æz‘EXdÖs<÷4ïÌ\‹…J¡N¾f¦_ÍÏ+¡4ª%—Ê¤Ì›Ñ·3WvlÙÆlŠ³ƒ³¶O«üÄf]Z¤j@6åÙ¾%07ÔE ëö#iN­ĞXUI³Lí÷ıÙ+Ôà )¸ÅnÂ1áH©Á„å+ê5İ„†wSK¿ªo­Â‘œß¼R¨OğFXJ*Œ¥_W­áşåJ
>vÂ\İ†óW_£†»Ml^áÀ£@-*RF»o³·h6'‰lYI
B`=˜9i6piTd©r˜›g½N®;Êl0Aì¢¾8•c¾C8;ÆñÄ·‹£À¬Y«,qí¢İC‹	mÜ*ÛÏX$ 2óXÎSÈ9FÃªí
¤·sGÊ¿O1Ã…'•Á’ÊB‚án“®`õ’Ùjº¹ùÎ™K‘%Sg3Ëğ i-‡YšÔ=°QB¦îP²E]—êÉQx–¦.nÓ”¿ÒuÇ)ó…AÅQÕÙhèôĞ>¡t,×1Ô¿àR¢³æ<3"NãÆ:7w¼ƒ¹DÀÀ9he¯qU·áJw<àrÃuu€‡´ERVœŞÜë%”–dó –ë…šÌ¬T‰@ŠC¼ßº¬ã¢3+€ĞÁ‡È’‚kÃÚn.‡£Ì[‡R£²3Ú¡ª„üˆÌ†Œ 3q«˜Q‘]kÙh²·ˆ¼€.®oÁL×‰Ùª4œò4{	’õÍ%8ºd2fF˜û­'P*ÜêwèìmÿÄj>óÂ…6
½j^ğÔGŠFŠ9Gu˜Pä<ªL{»ÿß_C•áp¶`À„ĞBıÆx‰?vg±L‹ÅÛ_`Çgé =õÖÒQü²ÿÊ¤¹2;`;Î¨¥Ár³°2ÖL/ùQ[•ó+-òºQı.=Ö^™;–º3F—ÎØJçû/¢÷®RĞo™]P8ûóú
edËKçñü1!tîP9zÆN­—‹è¢ÑYy‰ÂÙ£Ü¸í¦Cø
ÄÊGİ\¡5Ào)º¨œ³ªNê‡|4ÂMyúqnyF1†.mÙ•³ÇS³&g5c‰©$Ù=‡¹Maı¨@AŒ¸qŞÔ¦ÑÄØ: q	ã¿uœPÖ‡äØbÇúF½˜F9‹ĞE#½L*CdP4/€ÁÅ÷Kv1ö…K@ysrsÜ÷˜J‡Ş
ÕLfjä>PÅ‰ÊHyE™!ËxC¥*,©c´§	h–ìä|	CÉ4ô–ŞƒlŒ¨“0òšd#\<ÕöI-¹OkFğk¡œæZÔVûèq½„
Î@Z8ã„ÃPÎm0F<ìî˜g‰ÙD²ÈúLúúD$yùúbÑ½¶6ÂÍB5Ã9D<è^b‰
(3„1´È@CGãÑP¦z½¾0.D`™h`3EP²,¯HKe¼Ş<O8S.»ŞgÜ¨NRşår}|~
—tº8Åi´ÔJ­ñ¯İ2[¡İ+]0ç˜[‹«+Éİ1	ìlEIµ:4Ws±­w 2®ŠE¾Ø¹ù*¥{±"ÓöxÚ
×˜&F‡°2•~(Õşœ²™c%=F•t6[,šÔhä9S‡æ¾]
œÅÃC‚[6Ëm|¡ªbÀÆàBâù;åxÒ$À’% T0?\Ú7¦eß$ıì1	tšÏÑ~UZlGga!ìé=Ú·ad«eÊ Ôƒn#®dyòÚœ4ø„ñ¢ÀO2äiË¤îÛàˆDXàz¨‡êĞè¤Ä¨M–³d«ÖõƒQŒ‹Ñ‰MèÁ¬ªª}ƒ<V›çƒãaÙ=—"Ãææ—ÿ‡j5=€ƒ×É`àñjG*»ÃPªÂqä§VP}Y-\fm	Áü/YÑ êÚú…å@¶‹; ’öL°Á©§ÌI(™ù3ôÿÛ»ÖŞ¸+ú]¿‚UÜH–û%Ùá µİâÄğ+HëBà.)-£İ%»Üµ$;úï½ç>†ÃÇÊrà¨MËù`kÉá<îÌÜ¹3w‚ÜFÎ›”ƒN+	R`«°}]D¹ÌŒ5@e"ºS×u6ËÖj+zY)çøS$1jlJï¨~Nh_È…Ÿ‘\–†Áá0‡<	C–îåËt-¯>×Á=4äÂÛ ›ÎG›Ô×úG£ˆĞpxkßù¿¸{×7· úÏà:®oGƒ~ğy©QÀáÇÀş{şòG!âş>D<:GûÁıáğÏ
#ÅRıSÙˆÈŸo$a[ˆk9yí!Ï³Œ´-ÛB¡›ç6ËvvÓñ¨(˜€rMzu#·p}-I¤"åV¡ïtf±o°6Õw¢­Ç4kjüz^0Ü€}ï“Œ—ı|šVáèpx0<8”øº¼¹8C¿r©Mâœ3ìøBKÏö/±JSÇÁ»WôÒ)Z«Š1„W°9Opâê˜d“~UQ±…–“ErqBn2Û(ë|Rº ]ê	
Z„ÏÃG?y—}0%õcNú†ÃÍbÅ²“ò“¤Ì(ö¶ışQpNŠP23S|ÉƒJ^äÚ:WC‰ÌuÖ«(]Æ[*ÈWM‚]"i´ènªIñ£`›¥dÛ¤gnqŠ—Ê²rŠúW76Vª5¥ ?
©·áÁÃ#!ê_&‚í1cÃ+¸’xÿeÚ)$°ŞHóíŠ *=dÕ ªcÑd¨bpïïÙÜA7a2TÁ/[›š(Ô¬fKZêvbW€¥òëjù€¡ËÖ/¦²^¤ld –ÀáKÒñÒFS›f9ßNİ–³n’³ü_Áh“,XÅÃq]^oÔ¼çÏ¡ÛN«İ¨i¹Bÿa_ıS½r"/m"W0^„§ëÙÌ·¸YH¾7ô²¹ÍFıİU³S|Q¹ú[µ’óËµZäMDı*x*-	ª¯¦*Tª©"xCz§ú=*.zEKåëÔ)ñ£áhÈıåbRÒ„¬Uço-g„ı¥ì?¯«µ¯Moo,Ò8V;FÆcK¢3ì#Œı‹pJ¶ÎÈ±ŒÁ—Ğ°yôÔÀ’Í9¥åkëe´Sš¸3À6”Qåót¡œ'/¹ÎÏÓ—!×œ«DPv¹Šèıf}'¢©UÎrW-	ÕLVJÍÚğ¦êÏU„Üp*W±0E¥’M»F@f“W.§û”„3’Ãçl‘L'bİ O¢w{ÆyãûØ %¾U<oâ~e£;Jdeêp¶Ye¡ uëßv©b/°;›_KönÙ ·ÜÅXÿÎÊ«|gıï0qŸ\9‹lÕ©µLşµ&MSÍ\ş5°jæšBMcŞ	!79ågğ	ªiVm³õ^(ŸJğJdÃçObæ:Æyiô9é±´=ó&vûqßÂëõd½¨´ÑùœÇì…Êî²µŠŠsúèÿaF•AÓõ[—ã¤8_e9#G©ê¹5…\ç±,©ËÓ‰û¤`gX3Î`šºYo˜Uê7íQ‘P>qJ,`M“Ó«ô§İ7æ­xa-çg(h¬uì6 ,OE15»;,üÑ$Spü!Í÷9|™ç@Èi§ˆ“²	:s )*5B_Hö áIÌMqC-/¢SŠâz6Mûå7ÑjĞ>ãSö4\zV¶¨yá0¢‰‡	¼\‘ğ6aÈÆ…8›Õ iV –öÄÊÑÌ×æÈ`ÿPæ×Ñƒ š©bÈÃ«"@@ÁB-6Ù/èü»Ë9XPµ.F±­?ÏrÆş =6F)yúŒx¾&À9'lˆª?†(Í£UÒÖ íC^ƒ«ŠŠ´ÿ^óåOĞ±—aj—öúäÌ,e%5Ë¹^‡ò¨YAA¼5Ìâhİ@éUcx§YEÚe=¥mcÜBi`½B(gY¦ÕâÛ«5µ§vHÛ %3U}d=¿Ç
£\†¦õWµF5Ñ=òT€–¡Za°Ö«»Hv±E¹ËÄ’9Ho]¨RX#\4'ÂşÚ³l^ùeÉ›\ÓĞ°t%¦‘”QX¸¡0Î¾êé>
ğãw@†¨`
0‹ ÔJdŠğŞ!ıñUk åp“¬hzªzJê#³2¿Q T£è.Â ¾c—XŒåà+Ä‰'úè«öIØF_•-nİ“ÍùA ‡5~»;‡½áLtÿª<†h€ÓÃXË®§ãÏ)ÿôÿ}T€áÌİ– 91ÊÛ V´Õw3ŒbCæ(ŠO)=v…s™óøPô‰İ‡æõßT×Íº±½oÙ ¥‡“ë°@Äóí?-hE»"äw‰ôÔÎ~F»É^‚ãì¾}=
ß¾>ÚcÙÑùõTb¿…»™iûùˆŒšÔÊ Wjó	Ä´fDœ'In––eõ>K5æ,‚ˆCš±ÃcsUÒAQg|Q1&YÁµª$NäIº8¡-íŒ±}ŒB4&táaÛj3S2Á6hø‚§Ï|´åëxÀLA/Q¨R¢´º5 õÇ@S\tÓ8a}
³¡wZ»l˜‹ <báBRöxK§ÎQÒ´Òãv:åå›„S„ªğ!‹†ûÕÑŠÄ#à NıÀÙÙ„2xn®n¬ŠCYMÈØ±¤²¬ÇKŞä6Lü$WÉ¥UXjh=¬_F@3ÀìîÛŒAMğˆ°iš,¤ØBaÕP´µ¿c8$3‚y ù—ä~§Àš-x5•Ö@ä!|ÉBš9óM/€¿¼bJ+³¤Ö‰cåZ¬áŒ×>â¶E)$ªÕW‘»ã‹Mk—³ã6ôd6„NÛ@xérÂ}Ã†›r£Yxìh	Çï£ÅrB®0Qzør½`·ñ„&­,kÅ¦1Àè@¶.çÖÅbÊ°|âNØÑE÷êD2VX®§ÉäœQª€õ¯p´…ä\"çx€?5NIâ/Jler™Ï²´<ş (V1:­®ÌYz®Ñó280:öÖÜÂ£!è-‰|¹®ÅŸ0+â%°‚øg¯7FpœL¢5G<Ş1cöLê ~²ì¥££èqœ)Z3z%–ÖÄ˜ã‘«'šn)öCmÓÊ¡\AÁ—ò^á›¶=a ¬\	½¼áCLGhY/”áêšM=•5òĞ“ì2àPB‹%¤üŞ13Åwè9FnÉ‰µĞ$8²ã»­ Ø¡í‚iæRÚÚ8óîŞÇAˆ×öàWÚ#rY.›ñèz‡``bt w"*_?ìµ=áôÂ±(£Z^¿¼é4«‚t…ÂÂ™«ÛaxµÑ`³ô:>ùØ÷LflŸ§á·Lê—£!òDUñƒp`™qšk)J¤rRyIT¤3zãê´hú}s¹uj!¶ßtgëÿxçÿİùÇ/ZÇ§ã?ÕÏÿŒºówÿÉâ?¾à±¯D€”éĞÅ€ü¿Yÿzú×ñ©õ;ßêñ_ºó¿w¼ş_ÒØ‹ì„š–Ü˜!üÚMúƒe*†ş²°3œAãßC±µ<C ÉÇ£şQ‹cy‡#:yŞ!{xï£dºîHs–Á,dégñZONûöciìÇ†b¶·v'Šıúk	l¨Ş¿“‹(šğ’{Ï^­şr,üP IarIŠ	Ãìö\°·öİÔã­ÿğú/£&Üáúí6â?Œºõ7ë_ç+„ô?öKk@'şÊ1ùø4ÛìâXÑ&&°ƒHã1.rÏU¤°ßü¶
°`‚Ö"‹ĞYğuø¸úÂ<¸·›'`ÉN¾ÆYì¯eü’2”ÉŞÎ^Î^¯9G¸=æW¶Ç²¬çÉ•Åwóyğ€“ÁèF‹A¿(¦Ê¾¾ÏZŞàèÍ–é‡$F •BtQ°±‚øØ2ºèŸQ?8?›æéj…}êŠ˜G¤?ÇuU¸õ˜¯Ç;[“é<‹ƒáQkƒê•RnØÃ—Ö¯cë_Kg0$l¢ÁI ŠÖüÀÑ•ŞWğS2ãÃ½¤ 2$RgMˆ¹±r†fsí`!`'©‹ƒy¶Š}zÿğí«@¢Q¶í3‹Ó÷ÑÎ³Åİ•9ÿÃòß—û}[ùïÁÑızü·ûÃNş»“9Lnái5Äwàn;0™Ôõ)îwÏpW«Ø`7›Å{$ğ‰daGNqñ–ó*õco¶…Y‘„>*\¯Ò dYN¹—s°<´‹_Òbé
ˆâùzI<ªµ”ËÑ¨ıE|NBéæŠ·¸Ãó 2^9Ÿ°”µ%Pz½VÃ¦ë·œ®~ÈÉ³,ËË(ê.º£×WIñ+íh|íJüH_W"‰ÉÁµÂŸœ¦[7¬/`Õê£ÃQ]ş{°ßÙîHşû;®³3?«w ,`ùå²ÁKÏHòã­ õÇ|n–ïÄËèÇ_Ÿ¿xıs0.³Dj?êöğ.u©K]êR—ºÔ¥.u©K]êR—ºÔ¥.u©K]êR—ºÔ¥.u©K]êR—ºÔ¥ß'ı7a[ È  