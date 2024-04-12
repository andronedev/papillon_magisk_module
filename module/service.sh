#!/system/bin/sh

MODDIR=${0%/*}  # Chemin du répertoire du module
INSTALLED_VERSION_FILE="$MODDIR/installed_version.txt"
GITHUB_API_URL="https://api.github.com/repos/papillonapp/papillon/releases/latest"
PACKAGE_NAME="xyz.getpapillon.app"
APK_PATH="$MODDIR/papillon.apk"
LOG_FILE="$MODDIR/log.txt"

check_and_update() {
    # add date to log 
    echo "$(date) - Checking for updates..." >> $LOG_FILE

    # Obtenir les données de la dernière release
    RESPONSE=$(curl -s $GITHUB_API_URL)
    CURRENT_VERSION=$(echo $RESPONSE | grep -o '"tag_name": "[^"]*' | cut -d '"' -f 4)
    [ -f $INSTALLED_VERSION_FILE ] && INSTALLED_VERSION=$(cat $INSTALLED_VERSION_FILE) || INSTALLED_VERSION=""

    # Log the version
    echo "$(date) - Latest version: $CURRENT_VERSION" >> $LOG_FILE
    echo "$(date) - Installed version: $INSTALLED_VERSION" >> $LOG_FILE

    # Vérifier si la version installée est différente de la dernière version disponible
    if [ "$CURRENT_VERSION" != "$INSTALLED_VERSION" ]; then
        # Trouver l'URL de l'APK
        APK_URL=$(echo $RESPONSE | grep -o '"browser_download_url": "[^"]*\.apk"' | cut -d '"' -f 4)
        # Télécharger l'APK dans MODDIR
        curl -L $APK_URL -o $APK_PATH
        # Log the download
        echo "$(date) - Downloaded APK from $APK_URL" >> $LOG_FILE
        # Tenter d'installer l'APK depuis MODDIR
        INSTALL_OUTPUT=$(pm install -r $APK_PATH 2>&1)
        # Log the installation output
        echo "$(date) - Installation output: $INSTALL_OUTPUT" >> $LOG_FILE

        # Vérifier si l'installation a échoué à cause d'une incompatibilité de signature
        if echo "$INSTALL_OUTPUT" | grep -q "INSTALL_FAILED_UPDATE_INCOMPATIBLE"; then
            # Log the uninstallation
            echo "$(date) - Uninstalling the old version..." >> $LOG_FILE
            # Désinstaller l'ancienne version
            pm uninstall $PACKAGE_NAME
            # Réessayer l'installation depuis MODDIR
            pm install -r $APK_PATH
        fi

        # Mettre à jour le fichier de version installée
        echo $CURRENT_VERSION > $INSTALLED_VERSION_FILE

        # Notification de mise à jour (facultatif)
        echo "Papillon mis à jour vers la version $CURRENT_VERSION" >> $LOG_FILE

        # RM the APK file
        rm $APK_PATH

    fi
    
    # Mise a jour du module.prop et ajout du message de version avec la date et l'heure de dernière verification
    DATE=$(date)
    MESSAGE="En marche | Dernière vérification: $DATE => Version $CURRENT_VERSION installée."
    # Log the message
    echo "$(date) - Update description to $MESSAGE" >> $LOG_FILE
    # Modify description
    sed -Ei "s/^description=(\[.*][[:space:]]*)?/description=[$MESSAGE] /g" "$MODPATH/module.prop"
}

# Mise a jour du module.prop et ajout du message de version avec la date et l'heure de dernière verification
DATE="unknown"
MESSAGE="En marche | Dernière vérification: $DATE => Version $(cat $INSTALLED_VERSION_FILE) installée."

# Modify description
sed -Ei "s/^description=(\[.*][[:space:]]*)?/description=[$MESSAGE] /g" "$MODPATH/module.prop"

#Log the start
echo "$(date) - Starting the service..." >> $LOG_FILE

while true; do
    check_and_update
    sleep 300  # Attendre 5 minutes (300 secondes)
done
