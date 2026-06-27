import os
from PIL import Image

artifact_dir = "C:/Users/oskar/.gemini/antigravity-ide/brain/b42e5962-88b3-46e3-bc32-7eb2f7a761be/"
out_dir = "C:/gra2D/Gra2DProjektZespolowy_repo/assets/textures/items/"

if not os.path.exists(out_dir):
    os.makedirs(out_dir)

files = {
    "health_potion_1782576055934.png": "health_potion.png",
    "iron_armor_1782576066079.png": "iron_armor.png",
    "leather_armor_1782576074812.png": "leather_armor.png",
    "chest_1782576085495.png": "chest.png"
}

for in_name, out_name in files.items():
    in_path = os.path.join(artifact_dir, in_name)
    try:
        # Pillow radzi sobie ze wszystkimi typami obrazów (np. webp ukrytymi pod rozszerzeniem png)
        img = Image.open(in_path).convert("RGBA")
        
        # Wycinanie białego tła
        data = img.getdata()
        newData = []
        for item in data:
            if item[0] > 240 and item[1] > 240 and item[2] > 240:
                newData.append((255, 255, 255, 0)) # Przezroczysty
            else:
                newData.append(item)
        img.putdata(newData)
        
        # Zmniejszenie grafiki z 1024x1024 do formatu pixel art (np. 64x64 lub 128x128 dla detali)
        img.thumbnail((64, 64), Image.Resampling.LANCZOS)
        
        out_path = os.path.join(out_dir, out_name)
        img.save(out_path, format="PNG")
        print("Processed and saved:", out_path)
    except Exception as e:
        print("Failed to process", in_name, ":", str(e))
