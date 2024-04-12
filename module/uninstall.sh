#!/system/bin/sh

# Variables importantes
MODDIR=${0%/*}
PACKAGE_NAME="xyz.getpapillon.app"
INSTALLED_VERSION_FILE="$MODDIR/installed_version.txt"

# Afficher les informations sur le module
ui_print "Désinstallation du module de mise à jour automatique pour Papillon"

# Désinstaller l'application Papillon
ui_print "Désinstallation de l'application Papillon..."
pm uninstall $PACKAGE_NAME

# Supprimer le fichier de version installée
rm $INSTALLED_VERSION_FILE

ui_print "Désinstallation terminée. Le module de mise à jour automatique pour Papillon a été supprimé."

# Fin du script uninstall.sh