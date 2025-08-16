#!/usr/bin/env python3
from PIL import Image, ImageDraw, ImageFont
import os

# Créer une image 1024x1024 avec fond blanc
size = 1024
img = Image.new('RGB', (size, size), color='white')
draw = ImageDraw.Draw(img)

# Ajouter un texte simple au centre
try:
    # Essayer d'utiliser une police système
    font = ImageFont.truetype("/System/Library/Fonts/Arial.ttf", 120)
except:
    # Fallback vers la police par défaut
    font = ImageFont.load_default()

# Dessiner un rectangle coloré
draw.rectangle([size//4, size//4, 3*size//4, 3*size//4], fill='#007AFF', outline='#0056CC', width=10)

# Ajouter du texte
text = "LIYA"
bbox = draw.textbbox((0, 0), text, font=font)
text_width = bbox[2] - bbox[0]
text_height = bbox[3] - bbox[1]
x = (size - text_width) // 2
y = (size - text_height) // 2
draw.text((x, y), text, fill='white', font=font)

# Sauvegarder l'image
output_path = "Icon-App-1024x1024@1x.png"
img.save(output_path, 'PNG')
print(f"✅ Icône créée : {output_path}")
print(f"✅ Format : {img.mode} (sans canal alpha)")
print(f"✅ Taille : {img.size}")
