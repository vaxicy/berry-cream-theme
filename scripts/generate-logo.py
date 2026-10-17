"""A single flat berry with a cream-colored leaf. Only 128px RGBA output."""
from pathlib import Path
from PIL import Image, ImageDraw

ROOT = Path(__file__).resolve().parents[1]
S = 4
im = Image.new('RGBA', (128*S, 128*S))
d = ImageDraw.Draw(im)
def box(v):
    return tuple(round(x*S) for x in v)
# One berry silhouette, two broad flat color areas; no scattered decoration.
d.ellipse(box((20,36,108,119)), fill='#AC8296')
d.ellipse(box((27,36,101,96)), fill='#C2A6B4')
# A cream cap with an organic, pointed leaf silhouette.
leaf = [(60,40),(46,34),(38,20),(50,18),(61,23),(67,32),
        (73,18),(88,10),(96,12),(92,25),(80,35),(68,40)]
d.polygon([(x*S,y*S) for x,y in leaf], fill='#F3E5EA')
im = im.resize((128,128), Image.Resampling.LANCZOS)
target = ROOT/'logo/logo128.png'
target.parent.mkdir(parents=True, exist_ok=True)
im.save(target)
assert im.size == (128,128) and im.mode == 'RGBA'
print('Generated logo/logo128.png: 128x128 RGBA')
