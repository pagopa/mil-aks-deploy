#!/bin/bash

set -e  # Termina lo script se un comando fallisce

# Funzione per gestire gli errori
handle_error() {
    echo "❌ Errore: $1" >&2
    exit 1
}

# Verifica dei parametri
VALUES_FILE_NAME=$1
NAMESPACE=$2
APP_NAME=$3

if [ -z "$VALUES_FILE_NAME" ] || [ -z "$NAMESPACE" ] || [ -z "$APP_NAME" ]; then
    handle_error "Tutti i parametri sono richiesti: VALUES_FILE_NAME NAMESPACE APP_NAME"
fi

# Verifica che helm sia installato
if ! command -v helm &> /dev/null; then
    handle_error "Helm non è installato. Per favore, installalo e riprova."
fi

echo "✂️ Eliminazione della cartella charts"
rm -rf charts || handle_error "Impossibile eliminare la cartella charts"

echo "🚀 Inizio dell'installazione Release"

# Esegui il comando helm upgrade/install e cattura l'output e il codice di uscita
output=$(helm upgrade --namespace "$NAMESPACE" \
    --install --values "$VALUES_FILE_NAME" \
    --wait --timeout 3m0s "$APP_NAME" . 2>&1)
exit_code=$?

# Controlla il risultato del comando
if [ $exit_code -ne 0 ]; then
    handle_error "Fallimento nell'aggiornamento/installazione del chart Helm: $output"
else
    echo "✅ Installazione Release completata con successo"
    echo "$output"
fi
