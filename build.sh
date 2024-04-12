cd module/
zip -r9 papillonMagisk.zip * -x .git
cd ..
rm -f papillonMagisk.zip
mv module/papillonMagisk.zip .
cd ..
exit 0