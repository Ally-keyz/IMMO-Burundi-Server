"""Prints an icon as ASCII so the geometry can be checked without a viewer."""

import sys
from PIL import Image

path = sys.argv[1]
image = Image.open(path).convert("RGB")
print(f"{path}  {image.size[0]}x{image.size[1]}  mode={image.mode}")

W, H = 48, 24
small = image.resize((W, H), Image.LANCZOS)
ramp = " .:-=+*#%@"
for y in range(H):
    row = []
    for x in range(W):
        r, g, b = small.getpixel((x, y))
        # Blue channel dominates the brand blue; the mark is white on blue.
        lum = (r * 0.299 + g * 0.587 + b * 0.114) / 255
        row.append(ramp[min(9, int(lum * 9.99))])
    print("".join(row))
