#!/bin/bash

# Ruta al archivo PDF
FILE="$1"

# Convertimos la ruta al estilo de Windows
WIN_PATH=$(flatpak run com.usebottles.bottles run -b sumatra32 --command winepath -w "$FILE")

# Ejecutamos SumatraPDF con la ruta convertida
flatpak run com.usebottles.bottles run -b sumatra32 --command SumatraPDF.exe "$WIN_PATH"
