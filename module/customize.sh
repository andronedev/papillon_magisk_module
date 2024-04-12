#!/system/bin/sh
MODDIR=${0%/*}

# Check for the Volume key event
key_event_volume_up() {
    /system/bin/getevent -lqc 1 | grep -q "KEY_VOLUMEUP"
}

# Check for the Volume key event
key_event_volume_down() {
    /system/bin/getevent -lqc 1 | grep -q "KEY_VOLUMEDOWN"
}


# Afficher les informations sur le module
ui_print "Installation du module de mise à jour automatique pour Papillon"
ui_print "Ce module vérifie et installe automatiquement la dernière version de Papillon toutes les 5 minutes."

# On demande le temps entre chaque vérification
# 15min, 1h, 4h, 6h, 12h, 24h

ui_print "Veuillez choisir le temps entre chaque vérification:"
ui_print "1. 15 minutes"
ui_print "2. 1 heure"
ui_print "3. 4 heures"
ui_print "4. 6 heures"
ui_print "5. 12 heures"
ui_print "6. 24 heures"
ui_print "Volume + pour augmenter, Volume - pour Valider"

CURRENT_SELECTION=1
ui_print "Sélection actuelle: 15 minutes"
# tant que l'utilisateur n'a pas validé on continue
while true; do
    if key_event_volume_up; then
        CURRENT_SELECTION=$((CURRENT_SELECTION + 1))
        if [ $CURRENT_SELECTION -gt 6 ]; then
            CURRENT_SELECTION=1
        fi
    fi

    # Afficher la sélection actuelle
    case $CURRENT_SELECTION in
        1) ui_print "15 minutes" ;;
        2) ui_print "1 heure" ;;
        3) ui_print "4 heures" ;;
        4) ui_print "6 heures" ;;
        5) ui_print "12 heures" ;;
        6) ui_print "24 heures" ;;
    esac

    # Attendre que l'utilisateur valide
    if key_event_volume_down; then
        ui_print "Validation..."
        break
    fi
done

# Enregistrer la sélection
case $CURRENT_SELECTION in
    1) INTERVAL=300 ;;  # 15 minutes
    2) INTERVAL=3600 ;;  # 1 heure
    3) INTERVAL=14400 ;;  # 4 heures
    4) INTERVAL=21600 ;;  # 6 heures
    5) INTERVAL=43200 ;;  # 12 heures
    6) INTERVAL=86400 ;;  # 24 heures
esac

# Créer le fichier de configuration
echo $INTERVAL > "$MODDIR/interval.txt"

ui_print "Installation terminée. Le module de mise à jour automatique pour Papillon a été installé."
ui_print "Veuillez redémarrer votre appareil pour terminer l'installation."


# Télécharger et installer la dernière version de Papillon
# Mise a jour du module.prop et ajout du message de version avec la date et l'heure de dernière verification
DATE=$(date)
MESSAGE="En attente de redémarrage 🔄"

# Modify description
W=$(sed -E "s/^description=(\[.*][[:space:]]*)?/description=[ $MESSAGE ] /g" "$MODDIR/module.prop")
echo -n "$W" > "$MODDIR/module.prop"


# Fin du script customize.sh
