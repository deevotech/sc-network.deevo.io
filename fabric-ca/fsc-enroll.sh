
source $(dirname "$0")/env.sh

if [ -d $ROOT_DIR ]; then
    rm -rf $ROOT_DIR
fi

ORG=org
AUDITOR_ORG=auditors

TLS_CERT=tls.rca.${ORG}.deevo.io.pem

BOOTSTRAP_USER=rca-${ORG}-admin
BOOTSTRAP_PASS=rca-${ORG}-adminpw
BOOTSTRAP_USER_PASS=$BOOTSTRAP_USER:$BOOTSTRAP_PASS

BOOTSTRAP_AUDITOR_ADMIN_NAME=auditor-admin
BOOTSTRAP_AUDITOR_ADMIN_PASS=auditor-admin-pw
BOOTSTRAP_AUDITOR_ADMIN=$BOOTSTRAP_AUDITOR_ADMIN_NAME:$BOOTSTRAP_AUDITOR_ADMIN_PASS

# ======================================================================
log "Start root CA"
./start-root-ca.sh -g $ORG -u $BOOTSTRAP_USER -p $BOOTSTRAP_PASS

# ======================================================================
log "Enroll Bootstrap admin"
./enroll.sh -g $ORG -k $TLS_CERT -h bootstrap -u $BOOTSTRAP_USER_PASS

# ======================================================================
log "Create affiliation for aimthai"
./affiliation-add.sh -g $ORG -b bootstrap -a $ORG.aimthai

log "Register aimthai admin"
AIMTHAI_ADMIN=aimthai-admin
AIMTHAI_ADMIN_PW=aimthai-admin-pw
ATTR='hf.Registrar.Attributes=*,hf.Revoker=true,hf.GenCRL=true,hf.AffiliationMgr=true'

./register.sh -g $ORG -k $TLS_CERT -b bootstrap -u $AIMTHAI_ADMIN -p $AIMTHAI_ADMIN_PW -t admin -a ${ORG}.aimthai -r mod,user,auditor -s $ATTR

log "Enroll aimthai admin #1"
./enroll.sh -g $ORG -k $TLS_CERT -h 'admin1' -u $AIMTHAI_ADMIN:$AIMTHAI_ADMIN_PW

log "Enroll aimthai admin #2"
./enroll.sh -g $ORG -k $TLS_CERT -h 'admin2' -u $AIMTHAI_ADMIN:$AIMTHAI_ADMIN_PW

# # ======================================================================
# log "Create affiliation for farm"
# ./affiliation-add.sh -g $ORG -b $AIMTHAI_ADMIN -a $ORG.aimthai.farm

# log "Register farm mod"
# FARM_ADMIN=aimthai-farm-mod
# FARM_ADMIN_PW=aimthai-farm-mod-pw
# ATTR='hf.Registrar.Attributes=*,hf.Revoker=true,hf.GenCRL=true,hf.AffiliationMgr=false'

# ./register.sh -g $ORG -k $TLS_CERT -b $AIMTHAI_ADMIN -u $FARM_ADMIN -p $FARM_ADMIN_PW -t mod -a ${ORG}.aimthai.farm -r user -s $ATTR

# log "Enroll farm mod"
# ./enroll.sh -g $ORG -k $TLS_CERT -h $FARM_ADMIN -u $FARM_ADMIN:$FARM_ADMIN_PW

# # ======================================================================
# log "Create affiliation for factory"
# ./affiliation-add.sh -g $ORG -b $AIMTHAI_ADMIN -a $ORG.aimthai.factory

# log "Register factory mod"
# FACTORY_ADMIN=aimthai-factory-mod
# FACTORY_ADMIN_PW=aimthai-factory-mod-pw
# ATTR='hf.Registrar.Attributes=*,hf.Revoker=true,hf.GenCRL=true,hf.AffiliationMgr=false'

# ./register.sh -g $ORG -k $TLS_CERT -b $AIMTHAI_ADMIN -u $FACTORY_ADMIN -p $FACTORY_ADMIN_PW -t mod -a ${ORG}.aimthai.factory -r user -s $ATTR

# log "Enroll factory mod"
# ./enroll.sh -g $ORG -k $TLS_CERT -h $FACTORY_ADMIN -u $FACTORY_ADMIN:$FACTORY_ADMIN_PW

# # ======================================================================
# log "Enroll auditors admin"
# ./enroll.sh -g $AUDITOR_ORG -k $TLS_CERT -h $BOOTSTRAP_AUDITOR_ADMIN_NAME -u $BOOTSTRAP_AUDITOR_ADMIN

# # ======================================================================
# log "Register auditor-1"
# AUDITOR_1=auditor-1
# AUDITOR_1_PW=auditor-1-pw
# ATTR='hf.Registrar.Attributes=*,hf.Revoker=false,hf.GenCRL=false'

# ./register.sh -g $AUDITOR_ORG -k $TLS_CERT -b $BOOTSTRAP_AUDITOR_ADMIN_NAME -u $AUDITOR_1 -p $AUDITOR_1_PW -t auditor -a auditors -s $ATTR

# log "Enroll auditor-1"
# ./enroll.sh -g $AUDITOR_ORG -k $TLS_CERT -h $AUDITOR_1 -u $AUDITOR_1:$AUDITOR_1_PW

# # ======================================================================
# log "Create affiliation for auditors of aimthai"
# ./affiliation-add.sh -g $ORG -b $AIMTHAI_ADMIN -a $ORG.aimthai.auditors

# log "Register auditors mod"
# AIMTHAI_AUDITOR_ADMIN=aimthai-auditors-mod
# AIMTHAI_AUDITOR_ADMIN_PW=aimthai-auditors-mod-pw
# ATTR='hf.Registrar.Attributes=*,hf.Revoker=true,hf.GenCRL=true,hf.AffiliationMgr=false,auditor_id=auditor-1:ecert'

# ./register.sh -g $ORG -k $TLS_CERT -b $AIMTHAI_ADMIN -u $AIMTHAI_AUDITOR_ADMIN -p $AIMTHAI_AUDITOR_ADMIN_PW -t mod -a ${ORG}.aimthai.auditors -r auditor -s $ATTR

# log "Enroll auditors mod"
# ./enroll.sh -g $ORG -k $TLS_CERT -h $AIMTHAI_AUDITOR_ADMIN -u $AIMTHAI_AUDITOR_ADMIN:$AIMTHAI_AUDITOR_ADMIN_PW

# # ======================================================================
# log "Register auditor in aimthai for auditor-1"
# AIMTHAI_AUDITOR_1=aimthai-auditors-1
# AIMTHAI_AUDITOR_1_PW=aimthai-auditors-1-pw
# # AUDITOR_CERT=$(cat $ROOT_DIR/clients/$AUDITOR_1/msp/signcerts/cert.pem | base64 --wrap=0)
# # log "Base64 cert of $AUDITOR_1: $AUDITOR_CERT"
# # ATTR='hf.Registrar.Attributes=*,hf.Revoker=false,hf.GenCRL=false,auditor.id=auditor-1:ecert,auditor.cert='"$AUDITOR_CERT"':ecert'
# ATTR='hf.Registrar.Attributes=*,hf.Revoker=false,hf.GenCRL=false,auditor.id=auditor-1:ecert'

# ./register.sh -g $ORG -k $TLS_CERT -b $AIMTHAI_AUDITOR_ADMIN -u $AIMTHAI_AUDITOR_1 -p $AIMTHAI_AUDITOR_1_PW -t auditor -a ${ORG}.aimthai.auditors -s $ATTR

# log "Enroll auditor in aimthai for auditor-1"
# ./enroll.sh -g $ORG -k $TLS_CERT -h $AIMTHAI_AUDITOR_1 -u $AIMTHAI_AUDITOR_1:$AIMTHAI_AUDITOR_1_PW