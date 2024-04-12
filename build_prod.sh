cd module/
# replace "LOG_FILE="$MODDIR/log.txt" with LOG_FILE="/dev/null"
sed -i 's/LOG_FILE="$MODDIR\/log.txt"/LOG_FILE="\/dev\/null"/g' service.sh
zip -r9 papillonMagiskProd.zip * -x .git
cd ..
rm -f papillonMagiskProd.zip
mv module/papillonMagiskProd.zip .
cd ..
exit 0