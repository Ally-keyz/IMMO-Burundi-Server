"""Generate the native launcher icons from the website's brand mark.

The mark itself is the site's own `apps/web/public/favicon.svg`: a blue
rounded square with a white house. Only the geometry is reused, and the blue is
`#0057FF` rather than the `#0B5FFF` baked into that file, because the design
system in docs/youtube_design_notes.md defines `--immo-brand` as `#0057FF` and
the app's whole palette is generated from that token. The favicon is the only
place in the repository that disagrees.

Run from mobile/:  python tool/make_launcher_icons.py
"""

from __future__ import annotations

import os
from PIL import Image, ImageDraw

# --immo-brand from docs/youtube_design_notes.md.
BRAND = (0x00, 0x57, 0xFF, 255)
WHITE = (255, 255, 255, 255)

# The house path from favicon.svg, in its 64x64 viewBox.
HOUSE = [
    (32, 15),
    (52, 32),
    (46, 32),
    (46, 49),
    (36, 49),
    (36, 38.5),
    (28, 38.5),
    (28, 49),
    (18, 49),
    (18, 32),
    (12, 32),
]

# The favicon's corner radius, also in the 64-unit viewBox.
RADIUS = 14

# Drawn large then downsampled, because a 20x20 icon drawn at 20x20 has no
# antialiasing at all and the roof diagonal turns to stairs.
SUPERSAMPLE = 8

ROOT = os.path.dirname(os.path.abspath(__file__))
MOBILE = os.path.dirname(ROOT)


def render(size: int, rounded: bool, circle: bool = False) -> Image.Image:
    """Renders the mark at `size` px square.

    `rounded` keeps the favicon's rounded square, which is right for Android's
    legacy launcher icon. `circle` is the round-icon variant. iOS applies its own
    mask, so its icons are full-bleed squares: baking corners in there would show
    blue notches inside the system's rounded rect.
    """
    big = size * SUPERSAMPLE
    scale = big / 64.0

    if circle:
        # A round icon is shown unmasked on launchers that ask for one, so the
        # area outside the disc has to be transparent rather than brand blue -
        # blue-on-blue would render as a plain square. Android allows an alpha
        # channel; only iOS rejects it.
        image = Image.new("RGBA", (big, big), (0, 0, 0, 0))
        draw = ImageDraw.Draw(image)
        draw.ellipse((0, 0, big - 1, big - 1), fill=BRAND)
    else:
        # RGB, not RGBA: iOS rejects an app icon that contains an alpha channel.
        image = Image.new("RGB", (big, big), BRAND[:3])
        draw = ImageDraw.Draw(image)
        if rounded:
            draw.rounded_rectangle(
                (0, 0, big - 1, big - 1),
                radius=RADIUS * scale,
                fill=BRAND[:3],
            )

    fill = WHITE if circle else WHITE[:3]
    draw.polygon([(x * scale, y * scale) for x, y in HOUSE], fill=fill)

    return image.resize((size, size), Image.LANCZOS)


# (path, size, rounded) for every icon the two platforms require.
ANDROID = [
    ("android/app/src/main/res/mipmap-mdpi/ic_launcher.png", 48, True),
    ("android/app/src/main/res/mipmap-hdpi/ic_launcher.png", 72, True),
    ("android/app/src/main/res/mipmap-xhdpi/ic_launcher.png", 96, True),
    ("android/app/src/main/res/mipmap-xxhdpi/ic_launcher.png", 144, True),
    ("android/app/src/main/res/mipmap-xxxhdpi/ic_launcher.png", 192, True),
]

ANDROID_ROUND = [
    ("android/app/src/main/res/mipmap-mdpi/ic_launcher_round.png", 48),
    ("android/app/src/main/res/mipmap-hdpi/ic_launcher_round.png", 72),
    ("android/app/src/main/res/mipmap-xhdpi/ic_launcher_round.png", 96),
    ("android/app/src/main/res/mipmap-xxhdpi/ic_launcher_round.png", 144),
    ("android/app/src/main/res/mipmap-xxxhdpi/ic_launcher_round.png", 192),
]

IOS = [
    ("Icon-App-20x20@1x.png", 20, False),
    ("Icon-App-20x20@2x.png", 40, False),
    ("Icon-App-20x20@3x.png", 60, False),
    ("Icon-App-29x29@1x.png", 29, False),
    ("Icon-App-29x29@2x.png", 58, False),
    ("Icon-App-29x29@3x.png", 87, False),
    ("Icon-App-40x40@1x.png", 40, False),
    ("Icon-App-40x40@2x.png", 80, False),
    ("Icon-App-40x40@3x.png", 120, False),
    ("Icon-App-60x60@2x.png", 120, False),
    ("Icon-App-60x60@3x.png", 180, False),
    ("Icon-App-76x76@1x.png", 76, False),
    ("Icon-App-76x76@2x.png", 152, False),
    ("Icon-App-83.5x83.5@2x.png", 167, False),
    ("Icon-App-1024x1024@1x.png", 1024, False),
]

IOS_DIR = os.path.join(MOBILE, "ios", "Runner", "Assets.xcassets", "AppIcon.appiconset")


def main() -> None:
    written = 0
    for relative, size, rounded in ANDROID:
        path = os.path.join(MOBILE, relative)
        os.makedirs(os.path.dirname(path), exist_ok=True)
        render(size, rounded).save(path, "PNG", optimize=True)
        written += 1
        print(f"android  {size:>4}px  {relative}")

    for relative, size in ANDROID_ROUND:
        path = os.path.join(MOBILE, relative)
        os.makedirs(os.path.dirname(path), exist_ok=True)
        render(size, rounded=True, circle=True).save(path, "PNG", optimize=True)
        written += 1
        print(f"android  {size:>4}px  {relative}")

    for name, size, rounded in IOS:
        path = os.path.join(IOS_DIR, name)
        render(size, rounded).save(path, "PNG", optimize=True)
        written += 1
        print(f"ios      {size:>4}px  {name}")

    print(f"\n{written} icons written")


if __name__ == "__main__":
    main()
