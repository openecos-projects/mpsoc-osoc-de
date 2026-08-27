# usage: bash change-cpuid.sh new-cpuid out-bin

HELLO_BIN=hello-minirv-ysyxsoc.bin

OFFSET1=370432
OFFSET2=$((OFFSET1 + 8))

magic1=`dd if=$HELLO_BIN bs=1 skip=$OFFSET1 count=4 | hexdump --format '"%08x"'`
magic2=`dd if=$HELLO_BIN bs=1 skip=$OFFSET2 count=4 | hexdump --format '"%08x"'`

echo $magic1
echo $magic2
if test $magic1 != "00c0ffee" -o $magic2 != "deadbeef" ; then
  echo bad magic number
  exit -1
fi

NEW_CPUID=$1
if test $NEW_CPUID -gt 255 ; then
  echo new cpuid too big
  exit -1
fi

OUT_BIN=$2
CPUID_OFFSET=$((OFFSET1 + 4))
cp $HELLO_BIN $OUT_BIN
printf "0x%02x" $NEW_CPUID | xxd -r | dd of=$OUT_BIN bs=1 seek=$CPUID_OFFSET count=1 conv=notrunc
