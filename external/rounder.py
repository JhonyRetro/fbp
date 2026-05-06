# Usage:
#
#   IN=/path/to/file OUT=/path/to/file PRECISION=(0...n) python ./round.py
#
# IN        : (required) Path to input file
# OUT       : (optional) Path to output file (leave off to overwrite original)
# PRECISION : (optional) Number of digits after the decimal to keep (default 6)

import os
import re
import sys

MOVEMENT_REGEX = re.compile(r'(\w)(-?\d+\.\d+)')


def main():
    in_file = os.environ.get('IN')
    if not in_file:
        print("Error: La variable de entorno 'IN' es obligatoria.")
        sys.exit(1)

    out_file = os.environ.get('OUT') or in_file

    try:
        precision = int(os.environ.get('PRECISION', 6))
    except ValueError:
        precision = 6

    counts = {'converted': 0, 'maintained': 0, 'removed_f': 0}
    output = []

    try:
        with open(in_file, 'r', encoding='utf-8') as f:
            lines = f.read().splitlines()
    except FileNotFoundError:
        print(f"Error: No se pudo encontrar el archivo '{in_file}'")
        sys.exit(1)

    print(f"\nConverting {len(lines)} lines...", end='', flush=True)

    for line in lines:
        commands = line.split(' ')
        new_commands = []

        for command in commands:
            if not command:
                new_commands.append(command)
                continue

            if re.match(r'^[Ff][0-9]', command):
                counts['removed_f'] += 1
                continue

            match = MOVEMENT_REGEX.search(command)
            if match:
                counts['converted'] += 1
                new_location = round(float(match.group(2)), precision)
                new_commands.append(f"{match.group(1)}{new_location}")
            else:
                counts['maintained'] += 1
                new_commands.append(command)

        output.append(' '.join(new_commands).rstrip())

    with open(out_file, 'w', encoding='utf-8') as f:
        f.write(f"(Decimal precision updated by gcode rounder - FBP | JhonyRetro\n")
        f.write('\n'.join(output) + '\n')

    print("done!\n")
    print(f"{counts['converted']} commands rounded to {precision} decimal precision.")
    print(f"{counts['removed_f']} 'F' commands removed.")
    print(f"{counts['maintained']} commands ignored.\n")

    sys.exit(0)


if __name__ == '__main__':
    main()
