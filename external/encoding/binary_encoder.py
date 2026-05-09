import serial
import sys
import time
import re
import math

GCODE_FILE = sys.argv[1]
PUERTO_SERIE = '' # sustituir por puerto donde esté conectada la FPGA
BAUD_RATE = 115200
internal_clk = 100_000_000
min_draw_v = 10
max_draw_v = 200 # en mm/s
ac = 1000
servo_delay = 150 # ms
SEGMENT_MM = 1
STEPS_PER_MM = 80 # sustituir dependiendo de los uSteps del driver

SIM = True

normalize = True
# Medidas en mm
max_width = 297
max_height = 210
top_margin = 25.4 # 1"
bottom_margin = 25.4
left_margin = 25.4
right_margin = 25.4


def get_boundaries(file):
    min_x, min_y = float('inf'), float('inf')
    max_x, max_y = float('-inf'), float('-inf')

    with open(file, 'r') as file:
        for line in file:
            line = line.strip()
            if line.startswith('G0') or line.startswith('G1'):
                match_x = re.search(r'X([\d.\-]+)', line)
                match_y = re.search(r'Y([\d.\-]+)', line)
                if match_x:
                    val_x = float(match_x.group(1))
                    min_x = min(min_x, val_x)
                    max_x = max(max_x, val_x)
                if match_y:
                    val_y = float(match_y.group(1))
                    min_y = min(min_y, val_y)
                    max_y = max(max_y, val_y)

    original_width = max_x - min_x
    original_height = max_y - min_y

    area_x = max_width - left_margin - right_margin
    area_y = max_height - top_margin - bottom_margin

    scale_x = area_x / original_width if original_width > 0 else 1
    scale_y = area_y / original_height if original_height > 0 else 1
    final_scale = min(scale_x, scale_y)

    print(f"--- ANÁLISIS DEL DIBUJO ---")
    print(f"Tamaño original: {original_width:.2f} x {original_height:.2f} mm")
    print(f"Factor de escala a aplicar: {final_scale:.4f}")

    return min_x, min_y, final_scale


def pack_gcode_line(dx_steps, dy_steps, pen_down, plot_end):
    packet = []

    dir_x = 1 if dx_steps >= 0 else 0
    dir_y = 1 if dy_steps >= 0 else 0

    control_byte = (plot_end << 3) | (pen_down << 2) | (dir_y << 1) | dir_x

    abs_steps_x = abs(dx_steps)
    abs_steps_y = abs(dy_steps)
    dx_mm = abs_steps_x / STEPS_PER_MM
    dy_mm = abs_steps_y / STEPS_PER_MM
    dist_total_mm = math.hypot(dx_mm, dy_mm)

    if dist_total_mm == 0:
        delay_servo_ticks = int((internal_clk * (servo_delay / 1000.0)) / 8)
        delay_servo_ticks = max(1, min(65535, delay_servo_ticks))

        packet = bytearray([
            0xAA, control_byte,
            0x00, 0x00, 0x00, 0x00,
            (delay_servo_ticks >> 8) & 0xFF, delay_servo_ticks & 0xFF
        ])
        return packet

    d_acel = (max_draw_v ** 2 - min_draw_v ** 2) / (2 * ac)
    if dist_total_mm < 2 * d_acel:
        d_acel = dist_total_mm / 2  # Perfil triangular si la línea es corta

    x_recorrida = 0.0
    pasos_dados_x = 0
    pasos_dados_y = 0

    while x_recorrida < dist_total_mm:

        if x_recorrida < d_acel:
            # Rampa de subida
            v_actual = math.sqrt(min_draw_v ** 2 + 2 * ac * x_recorrida)
        elif x_recorrida > (dist_total_mm - d_acel):
            # Rampa de frenada
            dist_restante = dist_total_mm - x_recorrida
            v_actual = math.sqrt(min_draw_v ** 2 + 2 * ac * max(0, dist_restante))
        else:
            v_actual = max_draw_v

        v_actual = max(min_draw_v, min(v_actual, max_draw_v))

        ticks = internal_clk / (STEPS_PER_MM * v_actual)
        delay_16bit = int(ticks / 8)
        delay_16bit = max(1, min(65535, delay_16bit))  # Clamp de seguridad a 2 bytes

        x_siguiente = min(x_recorrida + SEGMENT_MM, dist_total_mm)
        ratio = x_siguiente / dist_total_mm

        target_x = int(abs_steps_x * ratio)
        target_y = int(abs_steps_y * ratio)

        pasos_paquete_x = target_x - pasos_dados_x
        pasos_paquete_y = target_y - pasos_dados_y

        pasos_dados_x += pasos_paquete_x
        pasos_dados_y += pasos_paquete_y
        x_recorrida = x_siguiente

        steps_x_clamp = min(pasos_paquete_x, 65535)
        steps_y_clamp = min(pasos_paquete_y, 65535)

        x_high_bits = (steps_x_clamp >> 8) & 0xFF
        x_low_bits = steps_x_clamp & 0xFF
        y_high_bits = (steps_y_clamp >> 8) & 0xFF
        y_low_bits = steps_y_clamp & 0xFF
        delay_high_bits = (delay_16bit >> 8) & 0xFF
        delay_low_bits = delay_16bit & 0xFF
        packet = bytearray([0xAA, control_byte, x_high_bits, x_low_bits, y_high_bits, y_low_bits, delay_high_bits, delay_low_bits])

    return packet


def parse_gcode():
    if len(sys.argv) < 2:
        print("Uso: binary_encoder.py <GCODE_FILE>")
        sys.exit(1)

    ser = None
    if not SIM:
        try:
            ser = serial.Serial(PUERTO_SERIE, BAUD_RATE)
            time.sleep(2)
            print(f"Conectado a {PUERTO_SERIE} a {BAUD_RATE} baudios.")
        except Exception as e:
            print(f"Error abriendo puerto serie: {e}")
            return

    offset_x, offset_y, scale = (0, 0, 1)
    if normalize:
        offset_x, offset_y, scale = get_boundaries(GCODE_FILE)

    pos_x_actual = 0.0
    pos_y_actual = 0.0
    sent_lines = 0

    pen_state = 0  # 0 = Up, 1 = Down
    plot_end = 0
    try:
        with open(GCODE_FILE, 'r') as file:
            for line in file:
                line = line.strip()

                if not line or line.startswith(';'):
                    continue

                if line.startswith('G0') or line.startswith('G1'):
                    pen_change = False

                    match_x = re.search(r'X([\d.\-]+)', line)
                    match_y = re.search(r'Y([\d.\-]+)', line)
                    match_z = re.search(r'Z([\d.\-]+)', line)

                    meta_x = float(match_x.group(1)) if match_x else None
                    meta_y = float(match_y.group(1)) if match_y else None

                    if match_z:
                        meta_z = float(match_z.group(1))
                        new_state = 0 if meta_z > 0 else 1
                        if new_state != pen_state:
                            pen_state = new_state
                            pen_change = True

                    meta_x_norm = pos_x_actual
                    if meta_x is not None:
                        if normalize:
                            meta_x_norm = ((meta_x - offset_x) * scale) + left_margin
                        else:
                            meta_x_norm = meta_x

                    meta_y_norm = pos_y_actual
                    if meta_y is not None:
                        if normalize:
                            meta_y_norm = ((meta_y - offset_y) * scale) + bottom_margin
                        else:
                            meta_y_norm = meta_y

                    target_step_x = int(round(meta_x_norm * STEPS_PER_MM))
                    target_step_y = int(round(meta_y_norm * STEPS_PER_MM))

                    current_step_x = int(round(pos_x_actual * STEPS_PER_MM))
                    current_step_y = int(round(pos_y_actual * STEPS_PER_MM))


                    dx_steps = target_step_x - current_step_x
                    dy_steps = target_step_y - current_step_y

                    if dx_steps != 0 or dy_steps != 0 or pen_change:
                        packet = pack_gcode_line(dx_steps, dy_steps, pen_state, plot_end)

                        if SIM:
                            hex_str = ' '.join([f"{b:02X}" for b in packet])
                            print(#hex_str)
                                f"Comando: {line} | Bytes: [{hex_str}] | Pasos a dar: X={dx_steps}, Y={dy_steps} | Lápiz: {pen_state} | Fin: {plot_end}")
                        else:
                            ser.write(packet)
                            time.sleep(0.01)

                        sent_lines += 1

                    pos_x_actual = meta_x_norm
                    pos_y_actual = meta_y_norm

            plot_end = 1
            end_packet = pack_gcode_line(0, 0, pen_state, plot_end)
            hex_str = ' '.join([f"{b:02X}" for b in end_packet])
            print(f"Comando: FIN DE ARCHIVO (M2)  | Bytes: [{hex_str}] | Lápiz: {pen_state} | Fin: {plot_end}")
            if not SIM:
                ser.write(end_packet)

    except FileNotFoundError:
        print(f"Error: No se encontró el file {GCODE_FILE}. Asegúrate de que está en la misma carpeta.")

    if not SIM and ser:
        ser.close()
        print("Puerto serial cerrado.")

    print(f"\nSe enviaron {sent_lines} paquetes binarios.")


if __name__ == '__main__':
    parse_gcode()
