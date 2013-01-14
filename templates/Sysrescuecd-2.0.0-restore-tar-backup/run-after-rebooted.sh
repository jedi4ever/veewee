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
� nL�P�\{s�6������3�;�Hɒ�z�θ����$�����ݽZ�%�I�%H�J�~�{�HQ�m�8݌8�X�� 88� ��/>������g�w����=��>���������>�;{ݮ��� O��CW�2b�oD����w�Q��y�^�ME1U��[fm=�8���c����~
��}���������ϣ�b�H���0��q�IK�L��#�@���{�ƹ���q��<�ų���~B��z�~����l��Ϡ������u��L�nƃk>�C�����3�U���O�?���6�����8�X*D(B���08<+ܱ(�L�q�~-���*u�\����iU�X�둛�����_R��A���N����u���s��Fw>7�t��Gܣ�{� j�+ ��}����O��|�ˊ���p�
�F��˖"gS>�e��`�,T�v��S5e*b*ΣIQd�7Q�B�G�g�v�O�^(�5u�i��2-o==ӅH<��b�s�iQ���B�<�
W��>ɨ,T.�v���N�^_��_���8lm=����8chqs��r������΋Zδ�(����e�����Dx`�<�et;���f�p<o�"����,��o\�o�0WIk^X��(b��B�-ւ�H�8ԇ���D��#vL�qT=�Yہ�2����Q�6\i�|l챕�T��:�쏐hvA���e1kRX��Y��Ջ���j��k�,7R�:��x�y�Fż���~O>���������;��z���AgE\j��䥢�G���$�~�/�O)3��+�~��TE+����!b��q����~}X�� p��P�w����w�ۘ�?��{�̋��#u�i��{u��7��C��t���?��#<��;�N��@T+x��kO�$vt*�
�����q)t��0��T)�%�"S�`�J@#K���O���`�w0��?] ��{�����迌�)
�F��
8��k�M�)��]NKE1R��j������-�e���`OT�0��č@��D�/Y ������5%��4Ӆʰx�$*d�5��$00�(C����|,�Z:����4S���|j���0��[0�^}w��:��$� �s��_w��g����H�7�j�kK��|��fH�X��mUՙ��dτ~��<���UM���)*��(�N��=W�#@b�t��?8���w����.���F�?�o{#������������#����a���(��d ;S@���9��k��P�k$�q���������{�Z���������ys�P������.O���[9�f1k!�*���V�הXN�ېfje��is3��|g�;�����.�
�����!�T��s������w��&�����'�`��J��S�H�Y��"'4�� �|>cA�˞ȔM'2�� �Ze��k��E!�/h�0e9W�w�Z��H����)"HQ�Jא/S<�T5��8�G�?�\>?�zqyH�4䜟�]�x����W*xr|�ը�mU����37d[K�?튈1��v,
`�	@~� 0n$d:��� ��QG�U��%����uV�-ۚ�k����@e��J�$n���#b`m]��C��-!��5��-����gd����������;}��������_?��=l��������0�{���7����+:
@v s�wg�!�FJ}�#L�Dp���zR�<��wب�q�
�EZH���:������iW?s��E���<��Zfu.-!�\Щ��N�� #�@^�*�cG�Ot%s���c��8z���	����i/�^]\�t|����b���T�k����,�"�3�/.��k�����	h:�1gǜ�پ�K�j�}��%�'�/��w�Ĺ	��5�*�2�,���,����7ߜ�}�,�PD����ӈ�Tɂ	O� �H�b�@߶�r�n�6�yH��V^DD�E�v�ێ����w���]��������U�z|zqy~���������Lhօ��{i	S��A#fM�/C����g�/N����_��Z?�R�5E[v��
��E:��h9��i�����2�����������W�Oa�1._*k	�uS����U��������}t��,��3�n��������j�1��ͥ=�߷��'�Mˍ������ �����`�������?���o.��y��Z��P�~�t�Xh,���� �fxs&Cs�\/�e,���@R�u�*�X̙*-�#��=X+z��}�M<�����$,�4�K�*�f�̙����%V��q\/a�Gi�����6M�C����@��#��iSj�X��T����K-%;
4�0κL���"�*�.SX�E<0�]L����S�a³lֲ�`����9"c�V��|�jzzc�?o���G������o��� �%�T�{{v�(�U��q@��LYg��78��?:_�_tz���rc#�s�?���G����������v7���y%�T�����̇"�y.���0vd�0����߲���.&& ���P��S��}��'k(��;={�&G*O������'JC{&���"CF�a1��P��nL�p�graA9Ĉ5�U��%3�,\x��
x���A(>��.� �G�<��I���$�S3������E_����{��?
���x��k>��i+��>V��"hp�S.��֮M�p��ϥH����&��7':���/U �z����2�-#��||������c�fc<���>~^g#֯_ o�X,���.�L�E�%�����u.0Z�`�0Di�����G�O�+�������ej ��*�#��]����4<LUJH������BZ�¥['Q�`���ص�%<�./<�9�oN��o���4�2�FS�l<N���2�'�_.P|c�L�'C�S��(���ny7�ɸ� ����0Bʘ��45�ҭƂyt4~�Yg��By�D���8�~Cl��x��m�IY�J��'<�Uefr3�F�#z.�-�u�23њ��S�1�*�*�^듇U���_��G�2)�ӆ�Z$��X�2�����C�,���������7��a�?�d!��x1L���5�|.sN��d~��'�4��Z�8X�Z|���8�U��=�b��Kp��! A�p%[v)^l�9F4�}`X��l�x��c0ǈL�GH��ąR��xL�-�x�4K���\����[b/�KW��2�D����a$-���Xl�"\����
�b�Ca���l�[cSIm���<rCg
�$d,�k&#fC�Q,ڌ�l���B���t_�
�LL?��u�-n,�r"��-�y+fB��5�λP�|<�sP,�3T�����0Χ��a�=4t��a�&ƙ�����]a�e������S0��p�0{@H��,C"Ǔo��ˋʸ���]�\+o�~�# ���������Es6��2�����P�xl����d����i$`�K����i���($[�h�m����	}����C�@������g�GΛL^
���y�8�r�`���N�,U�X�T�U����2��`�;x��0bD��f`������vg��v��Y).3����k
����E� @��v��v��_)<�:��zA�ɓ������3VAc����x�㴊�Ь�E!�0�tnx�m3C��f?����$R$��T�f�e2=FlG���	g=��˰ [�I̻�:I��,o,Xs��١.2�Ysl�ƘJ�����O'/т�A� �,�T�#��S�Y����:��������8�Ӌ���B�9F�g38KXW�����4|b���T�;~�-t㫋M��
�8��<Ĳ���O�(���b<у��iS �d"+���d8�mv��Q�S�,z��5I0�k,g�8��fq�њ����.�=���ƕ=L�L	��<��CxToW �-��O>���'���ݦ�f��K��tq�u�*�g�gj��Ej=-���(�'�R�Em�W��rd�W�.Q!n�T��u+)�D����G��ErOi��Q;�����<G�f<w"��FEF�xw�=Ъ^��n�J��e�k�*PqU	h:��%��e���ۥnfV����~߬�c�3+���U!r$�,H��\.GS�%�7�u�+�<����c����¨���x��H��.�o���)mU��p�^#H3�0�<�˦A��>�l�@eX@����٫˧��Q�m�Ū{��D�NJX ��\r֮ǽu������|��BK���G|��2��Gu�Lp|�����Y7J���/阫06�˼rXvVƚK8�����o���c�y<N��7�3BHG��b�E�U):ȭ0
�`^_"PF�0�t5o	!�'7�3D�֬W��"٬�"a�QF��:�Y�V.t���%#�8�U�֏�x���cxG1��c4!m���@F3Z�A�XQ�Xv#�Ǥ�II�d 1�����1�:(���8`�ؑ���ɼP�R��G�I/�����C �=���n%.�_d$/�^�zG�G�$T��Y�uanFn<r������e�Pe
+����f%NKP%-���@09QS$,���r1��Sk��⛤E��
�YV��jm#��P���uN8mqX��"�0�j��|"Eh�C.�>SqȞ�z������!-TS�C���c��,0@)!	r�(@#�B4���n/��!��"CHY�W�&ԛe�ڞ�wŭ$�ɪ/����cx�g�S��K�$�|m�9���^�,07WW���$��5'���l�Ŷ�(4LBC|�s�*�X�iܵd�,5�ĸ�0fC�v÷��o��(4I�g�
�|��B�̄��.� Y28`��`�����*T?�r�t��	}e�P&X,�%ײK�~vIM�"��_��'��yX{��Ok�M�X�* u[�!��r��7�B����">x��L!�yv�t TA��i��C�I1�M{�d���[2��ѐ�9Ѓ����� Vs��#����k.��f5;����e�[@��e��a�L�$t+(�d��y,�@B���W^������ �w,�$�P���k�Y���)g���o2�tX��B����)όd�x��@w��f�Z+����ǒ�w=��O��s����OM�zz>�����$��A�z��\&<���޲-��_~+�t~������B�N0��z�7��w� �$��X	x��x�f��Y!��i��M<����;�q���c�N����c{�U�=D�b"U���� V��c`�)DK�e܂�γEخ��)�(�����u�� �����AE�Z��z�l���j�D-G0%t�L47����a����ۻ��6�#�]�����HQ�TC��v�/u"؎��(�#�$^D�<2���w�y��{�d�����l��۷۝�y���a9/G�x|ztrtr*�ysq@�J�]�v|�e`�����q��4�|C�V¦b
�b�S��:%�d��CTma�e��n&��f���ν�Ч(B��^ࠠX��>�ɻ�؃9�K�7o�(�����ꌂ�Ϣk2���Ay�%{*�q$ak]53ס=�I�N�T-��"&�D4��a�7츩&5�Ϣ'd(eOL{���p�,+�j?ugc�Z3x�W1�6>yz&���p{lxWￌ�]B��M4߁X bؗl��`0M�)���͝��I9�E�T�~m�Z�0��-�۩5\�J�?7�]�~��Q�3�@-�×�����va9���ن�,� m��x8��덚���)l�y��"�!W��쩿�WN��]�����b�#n淚�g���}=�wW�~����Ҡ6r>̠6��kP��^ʀ�`�Z���*�
UD?�ݩ~Og��]�S�6wF��h|���RҞ�l5�o+g����?o����n�,�4U��wK�3����K�Z۲"���x���@����)�t,O[/�m����5(���*_�+�<e-u~�@_�\s�a��rb��N�����n"	�LVJm����U��D8ϫ LI�dh���l�SG��>%���9#��L�z�Y$v�Λ�Ǧ +����y�+�>�(�������*��� �[��K5��y�}Zr�w�^r�]�笼�s���&�[��6�Z��[�4����+�5�):�1My&���qU^�'�v����f�9�P>������Os��4��Xۃ��y�����o��:ٮmt~ �1�P���]�6IuM�"�$¨��t���r�Uכ��g�!�� U����:�%��r����'̢����n�f��M�*\>��4'���i�*�i�z+^D��JA~u��2[U��pw �ɬ�P�p�1/�9|��@(i�H��	:�r-*5A_H��ד���2�Z^%�8�"l���o�ՠ}ƣ�i�p�Y٪�A�È&&�zC�ی)7�lV@�P }#��	������`�P��1 F��T��SͳEY)bS��>���^B5�bc�eQ2��w�󱐗�H���$�"�����W#��e��:��}�kp��B����C��jLЩ��ij��̙E�(�Ѭ�z�ʣ���xk���6@7{���fm{Qttl�J��8+
���Y���8�C�����#p�=69P��ߴ�{��FV�rh���Tw��RrW��L�n]�Q�$�h&"���n^�d-�\�а|#L"���pCξ�>
��w0I�#�0,��*�)�{�t����}��7����z�vJ�3�
�IV��."�@������9�WȑL��W���o|U����Ώ�qX����hpt(ݺ&�
�� k��t�9�����
�:K�%�B�E��v�}��M�ؑy��>�b��p.s���=q�Լ���ۖ#��-Rz8�M;�I<�����hW���$��"��g�H��#$���w�����C��_Ou �[�0��d:l��`��(�V�R�C К��:�Jc��,�_�\�h.�8���;<�0W�8(���	&Y���$@�$_MhK�bn�M�xܶ���#�a4~��W>�@���u�Gh�/1�riu
k 揑���.8a}��;�]7̎E���C%��N��2�i���t*�w)�� :�C��+R�����7 _Udg�๹��*.eu)c�����K��6L��TͥWY�X��_f@3��
�ۂI]�i�,dU�B�j(���1��<��Kz�3`�̥5����f%͜yLϦ���e�J+��Vzn��Z����>��U�$*��ݕ��Ŧ�W���6��d6��ڨ��ې�fO�]���,��h	��&��Ri������3� ������t�z`]��L�'�]l�!H$s�m�z�ͮ��
Z�G[Hϥ�nA�gP�4���Vf�E�����
�o�ו�ȯ5z^�`� ��-2�ޚF�U�?`V�kp)���^o��i6K��x����A�"ò_Վb�mP�H2�L�^N�J*��10���X��v8tI�M+���
���`p[�52�ƕ�����Vօ
\]ө�Ge�v%�XB*�0S~��c�L����Ȏ�s���x��i�r��8���o�
�����u3��.��2�1:�;�o�����=��Ɖ(��x�"��ˢI�5^�g�n�5��f�uB/��ב�!r�ǡ�1>O��2�/\���PU��m 2�,�Rt��J�ế�����hz}s�uj!�߄���{����������g��'�p��#������ e:���7�_�C?p����q'���Y8������{���R��3��qA�����i�����D'�2���H>φ�{�;.������/�L�?�%�`���t+ǀg�C{��4�aG1O�f���+	�~G���'~�޳Wk���<BR�} Äiv�.�[�����y��Qq���ON;�OB��GZ�8_y d��_ZC ꄘ �+�|��ӌ٥��LM`=��׸ȷT��>�M����Xt�Ȃ������їe��kp���ԡL��x���|��4�EG߻�=�e���n-�c\.#\H׺γ��*��R��6���X��T*�E!�*�c��fxE�D��b9Z���+b����m��c�������謷A�J)7������������hpR@���8���
~�|��D�Dꬉ176h6'�>�v��8Z����}I4ʾ}fuY�00�U�m����&�{�>�c;�[�����}�??��ϟw�s���p��{�s}�s���V=��7>���?������;����H�X>��l��3��|/I�9���ȅЇo^_��9�V�ǯ�"3��
{xH!�RH!�RH!�RH!�RH!�RH!�RH!�RH!�RH!=|�w��} �  