# Python script to convert hex colors to RGB

def hex_to_rgb(hex_color):
    hex_color = hex_color.lstrip("0x")
    return tuple(int(hex_color[i:i+2], 16) for i in (0, 2, 4))

# Hex color codes
hex_colors = [
    0xffffff, 0x000000, 0x241f31, 0x00ac48, 0x06d268,
    0x38e7a0, 0xc92825, 0xfc2626, 0xff5562, 0xeeb402,
    0xffcd01, 0xffe200, 0x1c71d8, 0x0081d6, 0x00c1ff,
    0x49ddfe, 0x6272a4, 0x7c49b2, 0xba5eea, 0xda96f2
]

# Convert and print RGB values
for hex_color in hex_colors:
    rgb_color = hex_to_rgb(hex(hex_color))
    print(f"{rgb_color[0]} {rgb_color[1]} {rgb_color[2]}")
