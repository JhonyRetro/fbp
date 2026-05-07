import re
import sys

MOVEMENT_REGEX = re.compile(r'(\w)(-?\d+\.\d+)')


def main():
    if len(sys.argv) < 4:
        print("Uso: rounder.py <in_file> <out_file> <precision>")
        sys.exit(1)

    in_file = sys.argv[1]
    out_file = sys.argv[2]

    try:
        precision = int(sys.argv[3])
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
        f.write(f"Decimal precision updated by gcode rounder - FBP | JhonyRetro\n")
        f.write('\n'.join(output) + '\n')

    print("done!\n")
    print(f"{counts['converted']} commands rounded to {precision} decimal precision.")
    print(f"{counts['removed_f']} 'F' commands removed.")
    print(f"{counts['maintained']} commands ignored.\n")

    sys.exit(0)


if __name__ == '__main__':
    main()
