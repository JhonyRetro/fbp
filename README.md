# FBP: FPGA Based Plotter
### Proyecto Final de Asignatura | PHR

Este repositorio recogerá todo el código y recursos utilizados para el desarrollo del proyecto final de la asignatura de Programación de Hardware Reconfigurable.

FBP se trata de una máquina CNC tipo plotter, capaz de dibujar sobre un plano utilizando un lápiz o bolígrafo, siendo útil su aplicación en varios campos de ingeniería. Este proyecto es un acercamiento a una máquina final, en la que se dibujarán imágenes procesadas a G-code interpretadas por una FPGA.

En el proyecto se encuentran tanto los ficheros en relación con el procesado de G-Code, como el código VHDL correspondiente al proyecto. La conversión de imagen a G-code se ha realizado utilizando la herramienta [image2gcode](https://github.com/LittleSurvival/image2gcode).

### Preprocesado de G-Code

Antes de realizar cualquier operación, deberemos procesar nuestro G-Code generado por la herramienta anteriormente mencionada. Para ello, aproximaremos a 4 decimales, utilizando el script `rounder.py`, el cual también eliminará instrucciones innecesarias.

```
uv sync
uv run ./external/rounder.py <gcode entrada> <fich. salida>
```

Este código filtrado, lo codificaremos en paquetes binarios de 6 Bytes, que serán comunicados mediante UART a la FPGA para ser leídos y poder generar los pulsos correspondientes. La estructura de los paquetes binarios es la siguiente:

![Paquete Binario](docs/binary-packet.png)
