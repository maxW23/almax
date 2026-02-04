#!/bin/bash

# قم بتغيير هذه القيم حسب احتياجك
KEYSTORE_PATH="android/keystores/upload-keystore.jks"
KEY_ALIAS="upload"
KEYSTORE_PASSWORD="lklkliveblackwolf"
KEY_PASSWORD="lklkliveblackwolf"
VALIDITY_DAYS=10000

# إنشاء المجلد إذا لم يكن موجوداً
mkdir -p android/keystores

# إنشاء الـ keystore
keytool -genkey -v \
  -keystore "$KEYSTORE_PATH" \
  -keyalg RSA -keysize 2048 \
  -validity $VALIDITY_DAYS \
  -alias "$KEY_ALIAS" \
  -storepass "$KEYSTORE_PASSWORD" \
  -keypass "$KEY_PASSWORD" \
  -dname "CN=Mohamad Adib Tawil, OU=lklk, O=lklk, L=null, ST=null, C=null"

# عرض معلومات الـ keystore
keytool -list -v \
  -keystore "$KEYSTORE_PATH" \
  -alias "$KEY_ALIAS" \
  -storepass "$KEYSTORE_PASSWORD" \
  -keypass "$KEY_PASSWORD"

# إنشاء ملف key.properties
cat > android/key.properties <<EOL
storePassword=$KEYSTORE_PASSWORD
keyPassword=$KEY_PASSWORD
keyAlias=$KEY_ALIAS
storeFile=keystores/upload-keystore.jks
EOL

echo ""
echo "تم إنشاء الـ keystore بنجاح في: $KEYSTORE_PATH"
