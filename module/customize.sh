#!/system/bin/sh

# Variables importantes
MODDIR=${0%/*}
GITHUB_API_URL="https://api.github.com/repos/papillonapp/papillon/releases/latest"
PACKAGE_NAME="xyz.getpapillon.app"
APK_PATH="$TMPDIR/papillon.apk"
INSTALLED_VERSION_FILE="$MODDIR/installed_version.txt"

# Afficher les informations sur le module
ui_print "Installation du module de mise à jour automatique pour Papillon"
ui_print "Ce module vérifie et installe automatiquement la dernière version de Papillon toutes les 5 minutes."

# Télécharger et installer la dernière version de Papillon
ui_print "Téléchargement et installation de la dernière version de Papillon..."
download_and_install() {
    local RESPONSE=$(curl -s $GITHUB_API_URL)
    local CURRENT_VERSION=$(echo $RESPONSE | grep -o '"tag_name": "[^"]*' | cut -d '"' -f 4)
    local APK_URL=$(echo $RESPONSE | grep -o '"browser_download_url": "[^"]*\.apk"' | cut -d '"' -f 4)
    curl -L $APK_URL -o $APK_PATH
    local INSTALL_OUTPUT=$(pm install -r $APK_PATH 2>&1)

    if echo "$INSTALL_OUTPUT" | grep -q "INSTALL_FAILED_UPDATE_INCOMPATIBLE"; then
        pm uninstall $PACKAGE_NAME
        pm install -r $APK_PATH
    fi

    echo $CURRENT_VERSION > $INSTALLED_VERSION_FILE

    # Mise a jour du module.prop et ajout du message de version avec la date et l'heure de dernière verification
    DATE=$(date)
    MESSAGE="En attente de redémarrage 🔄 | Dernière vérification: $DATE => Version $CURRENT_VERSION installée."

    # Modify description
    sed -Ei "s/^description=(\[.*][[:space:]]*)?/description=[$MESSAGE] /g" "$MODPATH/module.prop"

    ui_print "Installation terminée. Papillon est à jour. (Version $CURRENT_VERSION)"
}

download_and_install

# Fin du script customize.sh
