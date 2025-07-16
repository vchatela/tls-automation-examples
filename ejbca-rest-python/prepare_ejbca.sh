#!/bin/bash
# set -euo pipefail

CONTAINER="ejbca"

# 1. Export ManagementCA certificate
echo "📥 Exporting ManagementCA certificate..."
docker exec $CONTAINER ejbca.sh ca getcacert ManagementCA /tmp/ManagementCA.pem
docker cp $CONTAINER:/tmp/ManagementCA.pem ./ManagementCA.pem

# 2. Import certificate and end entity profiles
echo "📤 Preparing profile import..."
docker cp ./profiles $CONTAINER:/tmp/tmp-ejbca-profiles

echo "📦 Importing profiles into EJBCA..."
docker exec $CONTAINER ejbca.sh ca importprofiles -d /tmp/tmp-ejbca-profiles/profiles/

# 3. Create API Role
echo "🔐 Creating API role TLS_API_ROLE..."
docker exec $CONTAINER ejbca.sh roles addrole TLS_API_ROLE

# 4. Assign valentin-admin to API role
echo "👤 Adding CN=valentin-admin to TLS_API_ROLE..."
docker exec $CONTAINER ejbca.sh roles addrolemember \
  --role=TLS_API_ROLE \
  --with=CertificateAuthenticationToken:WITH_FULLDN \
  --value='CN=valentin-admin' \
  --caname='ManagementCA'

# 5. Assign RA Admin permissions to this role
echo "🛡️ Assigning RA permissions to TLS_API_ROLE..."
docker exec $CONTAINER ejbca.sh roles changerule --name=TLS_API_ROLE \
  --rule=/ra_functionality/  \
  --state=ACCEPT

echo "✅ Setup complete. ManagementCA.pem has been exported locally."

# 6 Create end entity with EJBCA-managed key pair (SOFT token)
echo "📄 Creating end entity valentin-admin (SOFT token)..."
docker exec $CONTAINER ejbca.sh ra addendentity \
  --dn "CN=valentin-admin" \
  --caname ManagementCA \
  --type 1 \
  --username valentin-admin \
  --password FooBar123 \
  --certprofile ENDUSER \
  --eeprofile EMPTY \
  --token P12s

echo "✅ Certificate ready to be downloaded at https://localhost/ejbca/ra/enrollwithusername.xhtml"
