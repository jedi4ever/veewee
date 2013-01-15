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
� ���P�=�w�6����W`e���3E}����sl��]l��r���=-D��$��ee���o ��$�6qڮ��X`0_�z��'�4��n���=�������C�-�i�:�f�4��V���~��Bi*�+)��ga��=�k� ,��?HG��w�M?cz"�_�u5�4���t�3�v�;�F�	��f��l}A���䟭?�`ȳ@����y�8L8�4az��x�,�#�Dޒ�d9�Q$=����-?�J�l���
�	T��R_����D��6:�t������=f��1UD2d�f�Qř$:�'�B�s�lG��LL���Ș�5�:?���hQr�O�H����e���x�Ti�J�zB%�E�C�>(-�ЧY�g"�cɘ���ZHΔ睞=??��>��9��<�m�Bk)�#�$��T���ګy���W�G3f�Y�s���,��g��L��5���!S��+�C��#�yK����V��L���߆�im$�a	O�f�Fj�s�Dꨵ�y,R�"�f���T��=�)q�u^�e�R�.��8 +#)Qau�ٯA1���Br=�ǰZ5pDyW/~!ok�w@�$�잋B%SÞF޹	�<a;����F�+P�l��LW�iy�[a�RN>���~�T8~Ǽ����䙏@�\?�kJВm �1M,*`��#�����+�/�����~h��=�������A��Y�}��d�E(��uyBA�T�ß�-���"sb!��-�(�w~C��e�������l�_������ҿ"'W�/^�������������ȷ׷��M���@��)�9G���8&	�aq��zjKcP�ꙁ6�\�(A��$���܇���"����f$Xsi$��8�5�)�cKЕ�-�6������w��oA��C�z\���_��l�P�۝�F�7��	�#�K�����M�����[�Ne�[-��^����G��i�(�L&�9��UIJ3x
�q�S�4�P�I��%wGw��f&�,���GSڧQ�5���8.W���,M>����9�U�;�6��q���߫��+⿑��-�]_C.�K�,���|P��K����f��9���o��փҩ7�*Oѓ�O��set$i�gΗvU�"ϙ�=#ų"_4B��L��)yä���C���d����������f�?Z��F�����N��Z����:���n��P��s��S�&BFg+����,���< �V�}����c����on���>=r�6�o�ʌȵ��BΈ0+d��P�#yK�DK�����1)�0��BF�>mD�#�?X|�ƚI_�!L1��	Ș�h���6{�n��w��o��F�?�����������rE��
�uRd-J�d� "MI�]��ɘ�cb��$��
�(��(�X%c"��b��Zub8n��d�����נ/2ܧ*������g������Q�f:�y�WW��.ΎLA�h �N����m�/=���ď��<������#Ħޜ2�B�SmF��t2�x��jP)��1ӕ��s��-FB��@ȗu��J�K�V%��5�l��K!��9�zv	�VA� 
�ƢH"����FS��A�\�ɀ>�4<��TT5��0%� ك�4����'��Oϯ���M�g~� �|n|�����В����'e�
%�1�D��_"��$&G�$�}�
�Lo?#~�H����(��I�3��@�	�c�Ճ�(��~�g����:�@F5�˷���b_"̏�o.q���KrzuyVs�������ͥ��L��Y��>�����O�����2���Z��A�F�o��F�o�����GS��o�����Ot�g��kv:f����l��=���P�ǟ������;��i��ݶ��il⿏c�ɭI7
T�|ΒK_�ń'x���({��hʈ/�Ȱ�I�3�X�9M�U~��as�G���Jʯht 3�b���a!��ox^�5abt[nLV�MJsb���:��P��<
���gdGO�^6x�G���~�+��2���C,�, Æ�F�Rcc`���<��éDR�}'�*g�$t0#Ξu�wnC�L쐧Oj5Ɵh`�^b�}*�U6�M�BcsZ��`~,�o�9�zA��ŴHt`�ܶ�yL�`��1�F�zy�C�o��;�>��XmBedN�9n��1���xT�<L����8�}�?j�������m�xz~ӿ>~ۿ�>���-�	EZ�a�� +`�߾�v�o��Eprq����l ����j��c����9��Sc���<b�����}<on���a�E��jW���֪�߬�I��;�zs�p�Rj[( O;���w$�M ��,��c?��7���<hm�������9y]͹����_�C�ۻ!դ����F�;�g!�o��VC������dJ����ۗ���|h���,��nk���������K��/Z��B[�Z�`@�`4��_�9!Gu�4��d�0��Bb�J�s�J�HpOe k� __b�c���[\H��L��D�wD�����`/��i�"������I�(�n;��E\���ܗ�]��M�d�~w�>P5c�I�r��-���Q,$K����m1q�ȒyS]�3�y>-��`����9a,'�Z�ut*|j�����߮��^�Q��4�z�A\�R���^�������F�?Ƨo@"��=�MK��ws���f��'�V��&��a�{���FG�~�?b�݅n|]��k�Z���_��ڜ�x��k�&���f>baB%���G�a��P�2=%;͝},L���Ӂ�o���=[�	ڦ�7���ξ+��L�������BA{!�^ıE#�@Os6��)��h��ط��`�ߕ��%5�,\x֪
x�»na�S:b����ad�A@],��ͤQ�4�ht��F�v�������4��A�V��n���jDb�%�F�2���1�ł��L(/�k��,L��b?,%�j6�w�9S�SC'x(y�3�y��((dr����Փ�'����O���U�����5�����4aKw��'S(&��鱈�
U�"Bk����8zry|q�dH$Rʳ2;��!�.��溎;(�3�_��(��d1C�~@J$�7�
��̎%t%���4W>Ձ�:?�oΰ��;��73w<�C���v��Vm����7�*���$��x`��ޅL�5�;��ޔ�����͋Y	N��XZ�X�9�9{Y�*"��j
�ד|��`�o0/c�I��`ǅF����4�Uen��1,+������u��Dmv
�*��i���8K�XN)܆H��.>��r�d��J�b��A�N���=����9�z���������n�����CN�����`� ��5�|.$5��F��+09����K�������#��ۊ$4`bM��8�BB��e�$����0��:�ŦCA%O@�g�m!�Rk!P���!T{�+���+4p�@���r�x3�����aD���-6]".�p	sJC,�ϐ���P�=��1h�Ȅ��6��x��,rc�
12������P|��:1K6�`$�Rw<��+ᩍ	�eX����B���:k�N�����YJ���7y��`� }���$�u�����8�hz�d�1��U��؀�+"�؀���� l
*�"-� �z��2�|4֘�&/.��Bww�s��sƏ�Q�s�v�-�t�^���b�Ŵ�.�2���9��-
Ӑ�8�:������gB�Zl�o���H'�ٴ�6U"=�i��g�GN牼8P�f,����P ˇ�T�)t*"��l����NQ�'���l{�C�ņ�GD�L�3��s���}Uo֛+�<��̙Z�i�"g:��mu���<�:���G�G���?Φ�t�͜X'��qp��(+c6fV5�z�EXd�s<�4��\��J�N�f�_͝�+�4�%�ʤ̛ѷ3Wvl��l�����O����f]Z��j@�6�پ%07�E ��#iN��XUI�L����+��)��n�1�H����+�5݄�wSK��o��߼R�O�FXJ*���_W����J
>v�\���W_����Ml^���@-*RF�o��h6'�lYI
B`=�9i6p�iTd�r��g�N��;�l0A��8�c�C8;��ķ����Y�,q��C�	m�*��X$�2�X�S�9F����
��sGʿO1Å'�����B��n��`���j���ΙK�%Sg3�� �i-�Y��=�QB��P�E]����Qx���.nӔ��u�)�A�Q��h���>�t,�1Կ�R���<3"N��:7w���D��9he�qU��Jw<�r�uu���ERV����%��d� ��녚̬T�@�C�ߺ��3+�������k��n.���[�R��3ڡ����̆�� 3q��Q�]k�h�����.�o�L׉٪4���4{	���%8�d2fF���'P*��w��m��j>�6
�j^��G�F�9Gu�P�<�L�{���_C���p�`���B��x�?v�g�L���_`�g� =�֍�Q���ʤ�2;`;Ψ���r��2�L/�Q[��+-�Q�.=�^�;��3F���J��/���RЁo�]P8���
ed�K���1!t�P9z�N�����Yy��٣ܸ�C�
��G�\�5�o)�����N�|4�My�qnyF1�.m�����S�&g5c��$�=��Ma��@A��q��Ԧ���: �q�	�u�Pև��b��F��F9��E#�L*CdP4/����Kv1��K@ysrs������J��
�Lfj�>Pŉ�HyE�!�xC�*,�c��	h���|	C�4��ރl���0�d#\<��I-�OkF�k���Z�V��q��
΍@Z8��P�m0F<��g��D���L��D$y��bѽ�6��B5�9D<�^b�
(3��1��@CG��P�z��0.D`�h`3EP�,�HKe��<O8S.��gܨNR��r}|~
�t�8�i��J���2[��+]0�[���+��1	�lEI�:4Ws��w 2���E�ع�*�{�"��x�
ט&F��2�~(�����c%=F�t6[�,�ԝh�9S��]
���C�[6�m|��b���B��;�x�$��%�T0?\�7�e�$��1	t���~UZ�lGga!��=�ڷad�e� ԃn#��dy�ڜ�4����O2�iˤ����DX�z�����ĨM��d����Q��ѐ�M�����}�<V���a�=�"�����j5=�����`��jG*��P��q�VP�}Y-\fm�	��/YѠ�����@��;���L�����I(��3��ۻ�޸�+�]��U�H���%ِ� �����+H�B�.)-��%�ܵ$;���>����r�M��`k��<��ܹ�3w��FΛ��N+	R`��}]D�̌5@e"�S�u6��j+zY)��S$1jlJ�~Nh_ȅ��\����0�<	C����t-�>��=4�� ��G����G����pxk����{�7� ����:�oG�~�y�Q�����{��G!��>D<:G������
#�R�Sوȟo$a[�k9y�!ϳ��-�B���6�vv��(��rMzu#�p}-I�"�V��tf�o�6�w���4kj�z^0܀}����|�V��px0<8�����8C�r�M�3��BK��/�JS���W���)Z��1�W�9Op��d�~UQ����ErqBn2�(�|R�� ]�	
Z���G?y�}0%�cN����bŲ���(����QpN�P23S|ɞ�J^��:WC��u֞�(]�[*�WM�]"i��n�I�`��dۤgnq��ʲr��W76V�5�� ?
�����#!�_&��1c�+��x�e�)$��H�� *�=d� �c�d�bp����A7�a2T��/[��(ԬfKZ�vbW����j�����/��^��ld����K���FS�f9�Nݖ�n���_�h�,X��q]^oԼ����N�ݨi�B�a_�S�r"/m"�W0^����̷�YH�7�����F��U�S|Q��[�����Z�MD�*x*-�	���*T��"xCz��=�*.zEK���)��h���bRҞ��U�o-g����?����Moo,�8V;F�cK�3�#���pJ��ȱ������y�����9���k�e��S���3�6�Q��t��'/���ӗ!ל�DPv����f}'��U�rW-	�LVJ�����U���p*�W�0E���M��F@f�W.����3���l�L'bݠO�w{�y����%�U<o�~e�;Jde�p��Ye���u��v�b/�;�_K�n� ���X��ʫ|g��0q�\9�lթ�L��&MS�\�5�j�B�Mcށ	!79��g�	��iVm��^(�J�Jd��Ob�:�yi�9鱴=�&v�q����d�����������s���aF�A��[��8_e9#�G��5�\�,��Ӊ��`gX3�`���Yo�U�7�Q�P>qJ,`M������7�xa-�g(h�u�6�,OE15�;,��$S�p�!��9|��@�i����	:s )*5B_H���I�Mq�C-/�S��z6M��7�j�>�S�4�\zV��y�0���	�\��6a�ƅ8�ՠiV ���������`�P��у����b�ë"@@�B-6�/����9XP�.F��?�r���=6F)y��x��&��9'l��?�(ͣUҐ� �C^��������^��Oб��aj������,�e%5˹^��YAA�5��h�@��Ucx�YEڞe=��mc�Bi`�B(gY�����5��vH� %3U}d=��
�\���W�F5�=�T���Za�ց��Hv�E��Ē9�Ho]�RX#\4'����l^�eɛ\�аt%���QX��0ξ��>
��w@��`
0���Jd���!���Uk �p���hz�zJ�#�2�Q T��. �c��X���+ĉ'���I�F_�-nݓ��A �5~�;����Lt��<�h���Xˮ���)����}T���ݖ�91�۠V��w3�bC�(�O)=v�s���P�݇���T�ͺ��o� ����@����?-hE�"�w����~F��^���}=
߾>�c����Tb����i��������ʠWj�	ĴfD�'In��e�>K5��,��C���csU�AQg|Q1&Y���$N�I�8�-팱}�B4&t�a�j3S2�6h����|�����x��LA/Q�R���5 ��@S\t�8a}
��wZ�l�� <b�BR�xK��QҴ��v:�囄S���!����ъ�#�N���ل2xn�n��CYM�������K��6L�$WɥUXjh�=�_F@3���یAM���i�,��Ba�P���c8$3�y ���~���-x5�֐@�!|�B�9��M/���b�J+��։c�Z���>��E)$��W���Mk���6�d6�N�@x�r�}Þ��r�Yx�h	���rB�0Qz�r�`��&�,kŦ1��@�.���bʰ|�N��E��D2VX����Q����p���\"�x�?5NI�/Jler�ϲ�<��(V1:���Yz���280:����£!�-�|��ş0+�%���g�7Fp�L�5G<�1c�L� ~������q�)Z3z%���Ę㑫'�n)�Cm�ʡ\A���^���=a �\	���CLGhY/��ꚎM=�5�Г�2�PB��%���13�w�9Fnɉ��$8�㻭 ء���i�R��8����A�����W�#rY.���z�``bt w"*_?��=��±(�Z�^���4��t�����ax��`��:�>���Lfl���L���!�DU�p`�q�k)J�r�RyIT�3z��h�}s�uj!��tg��x�����/Zǧ�?������w���?�౯D����ŀ��Y�z�����;���_���w��_�؋섚�ܘ!���M���e*����3�A��C��<C �ǣ�Q�cy�#:y�!{x�d��Hs��,d�g�Z�ON��ci�ǆb��v'���k	l��޿��(��{�^��r,�P IarI�	���\����������/�&����6�?���7�_�+��?�Kk@�'��1��4���X�&&����H�1.r�U�����
�`���"��Y�u�����<���'`�N��Y�e��2����^�^��9G�=�W�ǲ��ɕ�w�y�����F�A�(�ʾ��Z���͖�$F �BtQ�����2��Q?8?���j�}ꊘG�?�uU�����;[��<���Qk��Rn�×֯c�_Kg0$l��I ����ѕ�W�S2�ý� 2$RgM���r�fs�`!`'���y��}z���@�Q��3����γ�ݕ9���ߗ��}[�����z����N���9Ln�i5�w�n;0���)�w�pW��`7��{$��daGNq��*�co��Y��>*\�� dYN��s�<��_�b�
���zI<����Ѩ�E|NB�抷���2^9����%Pz��Væ����~�ɳ,��(�.���WI�+�h|�J�H_W"������[7�/`����Q]�{����H��;��3?�w �,`����K�H�� ��|n������_��x�s0.���Dj?���.u�K]�R��ԥ.u�K]�R��ԥ.u�K]�R��ԥ.u�K]�R��ԥ�'�7a[ �  