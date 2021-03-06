BASE_DIR=$1
RUBY_TESTVERS=$2

TESTDIR_SKEL=/tmp/test_omsadmin_
TESTDIR=$TESTDIR_SKEL$$
mkdir -p $TESTDIR
echo "$TESTDIR"

OMSADMIN=$TESTDIR/omsadmin.sh
cp $BASE_DIR/installer/scripts/omsadmin.sh $OMSADMIN
chmod u+wx $OMSADMIN

sed -i s,TMP_DIR=.*,TMP_DIR=$TESTDIR,1 $OMSADMIN
sed -i s,CONF_DIR=.*,CONF_DIR=$TESTDIR,1 $OMSADMIN
sed -i s,CERT_DIR=.*,CERT_DIR=$TESTDIR,1 $OMSADMIN
sed -i s,OS_INFO=.*,OS_INFO=$TESTDIR/scx-release,1 $OMSADMIN
sed -i s,RUBY=.*,RUBY=${RUBY_TESTVERS}/bin/ruby,1 $OMSADMIN
sed -i s,AUTH_KEY_SCRIPT=.*,AUTH_KEY_SCRIPT=$BASE_DIR/installer/scripts/auth_key.rb,1 $OMSADMIN
sed -i s,INSTALL_INFO=.*,INSTALL_INFO=$BASE_DIR/installer/conf/installinfo.txt,1 $OMSADMIN
sed -i s,AGENT_USER=.*,AGENT_USER=`id -un`,1 $OMSADMIN
sed -i s,AGENT_GROUP=.*,AGENT_GROUP=`id -gn`,1 $OMSADMIN
sed -i s,METACONFIG_PY=.*,METACONFIG_PY=$TESTDIR/not_a_file,1 $OMSADMIN
sed -i s,PROCESS_STATS=.*,PROCESS_STATS=$TESTDIR/process_stats,1 $OMSADMIN

cat <<EOF > $TESTDIR/process_stats
    PercentUserTime=2
    PercentPrivilegedTime=1
    UsedMemory=27712
    PercentUsedMemory=3
EOF


cat <<EOF > $TESTDIR/scx-release
OSName=Ubuntu
OSVersion=14.04
OSFullName=Ubuntu 14.04 (x86_64)
OSAlias=UniversalD
OSManufacturer=Canonical Group Limited
OSShortName=Ubuntu_14.04
EOF
