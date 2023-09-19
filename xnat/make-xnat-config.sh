#!/bin/sh

# generate xnat config
if [ ! -f $XNAT_HOME/config/xnat-conf.properties ]; then
  cat > $XNAT_HOME/config/xnat-conf.properties << EOF
datasource.driver=$XNAT_DATASOURCE_DRIVER
datasource.url=$XNAT_DATASOURCE_URL
datasource.username=$XNAT_DATASOURCE_USERNAME
datasource.password=$XNAT_DATASOURCE_PASSWORD

hibernate.dialect=org.hibernate.dialect.PostgreSQL9Dialect
hibernate.hbm2ddl.auto=update
hibernate.show_sql=false
hibernate.cache.use_second_level_cache=true
hibernate.cache.use_query_cache=true

spring.http.multipart.max-file-size=1073741824
spring.http.multipart.max-request-size=1073741824
EOF
fi

# generate pipeline-engine config
if [ ! -f $XNAT_ROOT/pipeline/xnat-pipeline-engine/gradle.properties ]; then
  cat > $XNAT_ROOT/pipeline/xnat-pipeline-engine/gradle.properties << EOF
xnatUrl=http://localhost
siteName=XNAT
adminEmail=admin@oldschool.edu
smtpServer=mail.oldschool.edu
destination=/data/xnat/pipeline
EOF
fi

if [ ! -z "$XNAT_EMAIL" ]; then
  cat > $XNAT_HOME/config/prefs-init.ini << EOF
[siteConfig]
adminEmail=$XNAT_EMAIL
EOF
fi

# generate ldap config
if [ ! -f $XNAT_HOME/config/auth/ldap-provider.properties ]; then
  cat > $XNAT_HOME/config/auth/ldap-provider.properties << EOF
name=LDAP
provider.id=ldap
auth.method=ldap
address=ldap://sample.sample.de/dc=uni-augsburg,dc=de
userdn=cn=UNI-AUGSBURG\\mustermann,dc=uni-augsburg,dc=de
password=
search.base=
search.filter=(sAMAccountName=mustermann)
EOF
fi

# generate administer config
if [ ! -f $XNAT_HOME/config/auth/local-provider.properties ]; then
  cat > $XNAT_HOME/config/auth/local-provider.properties << EOF
provider.db.name=LOCAL
provider.db.id=localdb
provider.db.type=db
EOF
fi

if [ "$XNAT_SMTP_ENABLED" = true ]; then
  cat >> $XNAT_HOME/config/prefs-init.ini << EOF
[notifications]
smtpEnabled=true
smtpHostname=$XNAT_SMTP_HOSTNAME
smtpPort=$XNAT_SMTP_PORT
smtpUsername=$XNAT_SMTP_USERNAME
smtpPassword=$XNAT_SMTP_PASSWORD
smtpAuth=$XNAT_SMTP_AUTH
EOF
fi

# generate local db config
if [ ! -f $XNAT_HOME/config/prefs-init.ini ]; then
  cat > $XNAT_HOME/config/prefs-init.ini << EOF
[siteConfig]

siteId=XNAT
siteUrl=http://localhost
adminEmail=fake@fake.fake

archivePath=/data/xnat/archive
prearchivePath=/data/xnat/prearchive
cachePath=/data/xnat/cache
buildPath=/data/xnat/build
ftpPath=/data/xnat/ftp
pipelinePath=/data/xnat/pipeline

requireLogin=true
userRegistration=false
enableCsrfToken=true
sessionTimeout=1 hour
initialized=false

[notifications]

smtpEnabled=${SMTP_ENABLED}
smtpHostname=${SMTP_HOSTNAME}
smtpPort=${SMTP_PORT}
smtpProtocol=${SMTP_PROTOCOL}
smtpAuth=${SMTP_AUTH}
smtpUsername=${SMTP_USERNAME}
smtpPassword=${SMTP_PASSWORD}
smtpStartTls=false
smtpSslTrust=
emailPrefix=XNAT

EOF
fi

mkdir -p /usr/local/share/xnat
find $XNAT_HOME/config -mindepth 1 -maxdepth 1 -type f -exec cp {} /usr/local/share/xnat \;


