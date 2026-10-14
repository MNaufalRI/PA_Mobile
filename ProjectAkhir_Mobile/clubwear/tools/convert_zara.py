"""Konversi dataset Zara (folder Men/*.csv) -> lib/data/seed_products.dart

Pakai:  python tools/convert_zara.py <folder_Men> [kurs_INR_ke_IDR]
Contoh: python tools/convert_zara.py ../Men 190
"""
import ast, csv, os, random, re, sys

SRC = sys.argv[1] if len(sys.argv) > 1 else 'Men'
KURS = float(sys.argv[2]) if len(sys.argv) > 2 else 190.0  # 1 INR -> IDR
PER_CATEGORY_CAP = 14
random.seed(42)

# file CSV -> kategori aplikasi
MAP = {
    'T-SHIRTS': 'Kaos', 'POLO SHIRTS': 'Kaos',
    'SHIRTS': 'Kemeja', 'OVERSHIRTS': 'Kemeja', 'LINEN': 'Kemeja',
    'JEANS': 'Celana', 'TROUSERS': 'Celana', 'SHORTS': 'Celana',
    'JACKETS': 'Jaket', 'BLAZERS': 'Jaket',
    'HOODIES_SWEATSHIRTS': 'Sweater', 'SWEATERS_CARDIGANS': 'Sweater',
    'SHOES': 'Sepatu',
    'ACCESSORIES': 'Aksesoris', 'BAGS_BACKPACKS': 'Aksesoris',
}
COLORS = {'Kaos': 0xFF2B2B2B, 'Kemeja': 0xFF7E9BB8, 'Celana': 0xFF4B6179,
          'Jaket': 0xFF3C4A3E, 'Sweater': 0xFF8C8C88, 'Sepatu': 0xFF3A2E27,
          'Aksesoris': 0xFF6B6652}
SIZES = {'Celana': ['28', '30', '32', '34'], 'Sepatu': ['40', '41', '42', '43', '44'],
         'Aksesoris': ['All Size']}
DEFAULT_SIZES = ['S', 'M', 'L', 'XL', 'XXL']


def ds(s):  # string literal Dart
    s = ' '.join(str(s).split())
    return "'" + s.replace('\\', '\\\\').replace("'", "\\'").replace('$', '\\$') + "'"


def parse_price(p):
    d = re.sub(r'[^\d.]', '', p.split('.')[0].replace(',', '')) if p else ''
    return int(d) if d else None


def first_image(raw):
    try:
        data = ast.literal_eval(raw)
        return next(iter(data[0].keys())) if data else ''
    except Exception:
        m = re.search(r"https?://[^'\"]+", raw or '')
        return m.group(0) if m else ''


items, seen = [], set()
for fname, cat in MAP.items():
    path = os.path.join(SRC, fname + '.csv')
    if not os.path.exists(path):
        continue
    n = 0
    with open(path, encoding='utf-8-sig', newline='') as f:
        for row in csv.reader(f):
            if len(row) < 6 or row[1] == 'product_name':
                continue
            _, name, link, imgs, price, details = row[:6]
            pid = re.search(r'-p(\d+)\.html', link)
            pid = pid.group(1) if pid else None
            img, inr = first_image(imgs), parse_price(price)
            if not pid or pid in seen or not img or not inr:
                continue
            seen.add(pid)
            idr = round(inr * KURS / 1000) * 1000
            orig = round(idr * 1.25 / 1000) * 1000 if random.random() < 0.25 else None
            items.append(dict(
                id=f'zara-{pid}', name=name.title(), cat=cat, price=idr, orig=orig,
                img=img, desc=(details or '').strip()[:320] or 'Produk pilihan Clubwear.',
                stock=0 if random.random() < 0.04 else random.randint(5, 40),
                rating=round(random.uniform(4.2, 5.0), 1), sold=random.randint(20, 900),
                new=random.random() < 0.15, sizes=SIZES.get(cat, DEFAULT_SIZES)))
            n += 1
            if n >= PER_CATEGORY_CAP:
                break

out = ["// DIHASILKAN OTOMATIS oleh tools/convert_zara.py dari dataset Zara (Men).",
       "// Harga dikonversi dari INR ke Rupiah (kurs %s). Jangan edit manual." % KURS,
       "import '../models/product.dart';", "",
       "/// Data awal: fallback offline & bahan upload ke Firestore.",
       "final List<Product> seedProducts = [",]
for p in items:
    out.append("  Product(id: %s, name: %s, category: %s, price: %d, originalPrice: %s, "
               "imageUrl: %s, colorValue: 0x%X, stock: %d, sizes: %s, rating: %s, sold: %d, "
               "isNew: %s, description: %s)," % (
        ds(p['id']), ds(p['name']), ds(p['cat']), p['price'],
        p['orig'] if p['orig'] else 'null', ds(p['img']), COLORS[p['cat']], p['stock'],
        '[' + ', '.join(ds(s) for s in p['sizes']) + ']', p['rating'], p['sold'],
        'true' if p['new'] else 'false', ds(p['desc'])))
out.append("];")
dest = os.path.join(os.path.dirname(os.path.abspath(__file__)), '..', 'lib', 'data', 'seed_products.dart')
open(dest, 'w', encoding='utf-8').write('\n'.join(out) + '\n')
from collections import Counter
print(len(items), 'produk', dict(Counter(p['cat'] for p in items)))
