#!/usr/bin/env bash

read -rp "Introduzca la ubicación del fichero .gcode: " input_file

cd "$(pwd)"/external/rounder/ || exit
uv run rounder.py "$input_file" ./examples/out/salida.gcode
cd ../..
echo "Fichero guardado en rounder/examples/out/"

cd "$(pwd)"/external/encoding || exit
uv run binary_encoder.py ../rounder/examples/out/salida.gcode
cd ../..


