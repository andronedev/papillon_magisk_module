#!/system/bin/sh

MODDIR=${0%/*}  # Chemin du répertoire du module
INSTALLED_VERSION_FILE="$MODDIR/installed_version.txt"
GITHUB_API_URL="https://api.github.com/repos/papillonapp/papillon/releases/latest"
PACKAGE_NAME="xyz.getpapillon.app"
APK_PATH="$TMPDIR/papillon.apk"

check_and_update() {
    # Obtenir les données de la dernière release
    RESPONSE=$(curl -s $GITHUB_API_URL)
    CURRENT_VERSION=$(echo $RESPONSE | grep -o '"tag_name": "[^"]*' | cut -d '"' -f 4)
    [ -f $INSTALLED_VERSION_FILE ] && INSTALLED_VERSION=$(cat $INSTALLED_VERSION_FILE) || INSTALLED_VERSION=""

    # Vérifier si la version installée est différente de la dernière version disponible
    if [ "$CURRENT_VERSION" != "$INSTALLED_VERSION" ]; then
        # Trouver l'URL de l'APK
        APK_URL=$(echo $RESPONSE | grep -o '"browser_download_url": "[^"]*\.apk"' | cut -d '"' -f 4)
        # Télécharger l'APK dans TMPDIR
        curl -L $APK_URL -o $APK_PATH
        # Tenter d'installer l'APK depuis TMPDIR
        INSTALL_OUTPUT=$(pm install -r $APK_PATH 2>&1)

        # Vérifier si l'installation a échoué à cause d'une incompatibilité de signature
        if echo "$INSTALL_OUTPUT" | grep -q "INSTALL_FAILED_UPDATE_INCOMPATIBLE"; then
            # Désinstaller l'ancienne version
            pm uninstall $PACKAGE_NAME
            # Réessayer l'installation depuis TMPDIR
            pm install -r $APK_PATH
        fi

        # Mettre à jour le fichier de version installée
        echo $CURRENT_VERSION > $INSTALLED_VERSION_FILE

        # Notification de mise à jour (facultatif)
        echo "Papillon mis à jour vers la version $CURRENT_VERSION"

    fi
    
    # Mise a jour du module.prop et ajout du message de version avec la date et l'heure de dernière verification
    MESSAGE="En marche 👌 | Dernière vérification: $(date +'%d/%m/%Y %H:%M') => $CURRENT_VERSION installée."

    # Modify description
    cp "$MODPATH/module.prop" "$MODPATH/temp.prop"
    sed -Ei "s/^description=(\[.*][[:space:]]*)?/description=[$MESSAGE] /g" "$MODPATH/temp.prop"
    mv "$MODPATH/temp.prop" "$MODPATH/module.prop"
}

while true; do
    check_and_update
    sleep 300  # Attendre 5 minutes (300 secondes)
done
