import json
import urllib.request
import os

BOOKS = [
    # Perjanjian Lama (39)
    {"id": 1, "code": "kej", "name": "Kejadian", "testament": "PL", "chapters": 50},
    {"id": 2, "code": "kel", "name": "Keluaran", "testament": "PL", "chapters": 40},
    {"id": 3, "code": "im", "name": "Imamat", "testament": "PL", "chapters": 27},
    {"id": 4, "code": "bil", "name": "Bilangan", "testament": "PL", "chapters": 36},
    {"id": 5, "code": "ul", "name": "Ulangan", "testament": "PL", "chapters": 34},
    {"id": 6, "code": "yos", "name": "Yosua", "testament": "PL", "chapters": 24},
    {"id": 7, "code": "hak", "name": "Hakim-hakim", "testament": "PL", "chapters": 21},
    {"id": 8, "code": "rut", "name": "Rut", "testament": "PL", "chapters": 4},
    {"id": 9, "code": "1sam", "name": "1 Samuel", "testament": "PL", "chapters": 31},
    {"id": 10, "code": "2sam", "name": "2 Samuel", "testament": "PL", "chapters": 24},
    {"id": 11, "code": "1raj", "name": "1 Raja-raja", "testament": "PL", "chapters": 22},
    {"id": 12, "code": "2raj", "name": "2 Raja-raja", "testament": "PL", "chapters": 25},
    {"id": 13, "code": "1taw", "name": "1 Tawarikh", "testament": "PL", "chapters": 29},
    {"id": 14, "code": "2taw", "name": "2 Tawarikh", "testament": "PL", "chapters": 36},
    {"id": 15, "code": "ezr", "name": "Ezra", "testament": "PL", "chapters": 10},
    {"id": 16, "code": "neh", "name": "Nehemia", "testament": "PL", "chapters": 13},
    {"id": 17, "code": "est", "name": "Ester", "testament": "PL", "chapters": 10},
    {"id": 18, "code": "ayb", "name": "Ayub", "testament": "PL", "chapters": 42},
    {"id": 19, "code": "maz", "name": "Mazmur", "testament": "PL", "chapters": 150},
    {"id": 20, "code": "ams", "name": "Amsal", "testament": "PL", "chapters": 31},
    {"id": 21, "code": "pkh", "name": "Pengkhotbah", "testament": "PL", "chapters": 12},
    {"id": 22, "code": "kid", "name": "Kidung Agung", "testament": "PL", "chapters": 8},
    {"id": 23, "code": "yes", "name": "Yesaya", "testament": "PL", "chapters": 66},
    {"id": 24, "code": "yer", "name": "Yeremia", "testament": "PL", "chapters": 52},
    {"id": 25, "code": "rat", "name": "Ratapan", "testament": "PL", "chapters": 5},
    {"id": 26, "code": "yeh", "name": "Yehezkiel", "testament": "PL", "chapters": 48},
    {"id": 27, "code": "dan", "name": "Daniel", "testament": "PL", "chapters": 12},
    {"id": 28, "code": "hos", "name": "Hosea", "testament": "PL", "chapters": 14},
    {"id": 29, "code": "yoe", "name": "Yoel", "testament": "PL", "chapters": 3},
    {"id": 30, "code": "amo", "name": "Amos", "testament": "PL", "chapters": 9},
    {"id": 31, "code": "oba", "name": "Obaja", "testament": "PL", "chapters": 1},
    {"id": 32, "code": "yun", "name": "Yunus", "testament": "PL", "chapters": 4},
    {"id": 33, "code": "mik", "name": "Mikha", "testament": "PL", "chapters": 7},
    {"id": 34, "code": "nah", "name": "Nahum", "testament": "PL", "chapters": 3},
    {"id": 35, "code": "hab", "name": "Habakuk", "testament": "PL", "chapters": 3},
    {"id": 36, "code": "zef", "name": "Zefanya", "testament": "PL", "chapters": 3},
    {"id": 37, "code": "hag", "name": "Hagai", "testament": "PL", "chapters": 2},
    {"id": 38, "code": "zak", "name": "Zakharia", "testament": "PL", "chapters": 14},
    {"id": 39, "code": "mal", "name": "Maleakhi", "testament": "PL", "chapters": 4},

    # Perjanjian Baru (27)
    {"id": 40, "code": "mat", "name": "Matius", "testament": "PB", "chapters": 28},
    {"id": 41, "code": "mrk", "name": "Markus", "testament": "PB", "chapters": 16},
    {"id": 42, "code": "luk", "name": "Lukas", "testament": "PB", "chapters": 24},
    {"id": 43, "code": "yoh", "name": "Yohanes", "testament": "PB", "chapters": 21},
    {"id": 44, "code": "kis", "name": "Kisah Para Rasul", "testament": "PB", "chapters": 28},
    {"id": 45, "code": "rom", "name": "Roma", "testament": "PB", "chapters": 16},
    {"id": 46, "code": "1kor", "name": "1 Korintus", "testament": "PB", "chapters": 16},
    {"id": 47, "code": "2kor", "name": "2 Korintus", "testament": "PB", "chapters": 13},
    {"id": 48, "code": "gal", "name": "Galatia", "testament": "PB", "chapters": 6},
    {"id": 49, "code": "efe", "name": "Efesus", "testament": "PB", "chapters": 6},
    {"id": 50, "code": "flp", "name": "Filipi", "testament": "PB", "chapters": 4},
    {"id": 51, "code": "kol", "name": "Kolose", "testament": "PB", "chapters": 4},
    {"id": 52, "code": "1tes", "name": "1 Tesalonika", "testament": "PB", "chapters": 5},
    {"id": 53, "code": "2tes", "name": "2 Tesalonika", "testament": "PB", "chapters": 3},
    {"id": 54, "code": "1tim", "name": "1 Timotius", "testament": "PB", "chapters": 6},
    {"id": 55, "code": "2tim", "name": "2 Timotius", "testament": "PB", "chapters": 4},
    {"id": 56, "code": "tit", "name": "Titus", "testament": "PB", "chapters": 3},
    {"id": 57, "code": "flm", "name": "Filemon", "testament": "PB", "chapters": 1},
    {"id": 58, "code": "ibr", "name": "Ibrani", "testament": "PB", "chapters": 13},
    {"id": 59, "code": "yak", "name": "Yakobus", "testament": "PB", "chapters": 5},
    {"id": 60, "code": "1pet", "name": "1 Petrus", "testament": "PB", "chapters": 5},
    {"id": 61, "code": "2pet", "name": "2 Petrus", "testament": "PB", "chapters": 3},
    {"id": 62, "code": "1yoh", "name": "1 Yohanes", "testament": "PB", "chapters": 5},
    {"id": 63, "code": "2yoh", "name": "2 Yohanes", "testament": "PB", "chapters": 1},
    {"id": 64, "code": "3yoh", "name": "3 Yohanes", "testament": "PB", "chapters": 1},
    {"id": 65, "code": "yud", "name": "Yudas", "testament": "PB", "chapters": 1},
    {"id": 66, "code": "wah", "name": "Wahyu", "testament": "PB", "chapters": 22},
]

def main():
    os.makedirs("assets/data", exist_ok=True)
    
    # Save books list
    books_file = "assets/data/books.json"
    with open(books_file, "w", encoding="utf-8") as f:
        json.dump(BOOKS, f, ensure_ascii=False, indent=2)
    print(f"Saved {len(BOOKS)} books to {books_file}")

    # Fetch bundled chapters for instant offline enjoyment
    sample_targets = [
        ("kej1.json", "Kejadian 1"),
        ("maz23.json", "Mazmur 23"),
        ("ams3.json", "Amsal 3"),
        ("mat5.json", "Matius 5"),
        ("yoh1.json", "Yohanes 1"),
        ("yoh3.json", "Yohanes 3"),
        ("1kor13.json", "1 Korintus 13"),
        ("flp4.json", "Filipi 4"),
        ("wah22.json", "Wahyu 22")
    ]
    
    bundled_chapters = {}
    base_url = "https://raw.githubusercontent.com/KenCodeDev/alkitab-json/main/alkitab-umum/"
    
    for filename, label in sample_targets:
        url = base_url + filename
        try:
            req = urllib.request.Request(url, headers={'User-Agent': 'Mozilla/5.0'})
            with urllib.request.urlopen(req, timeout=10) as resp:
                data = json.loads(resp.read().decode('utf-8'))
                key = filename.replace(".json", "")
                bundled_chapters[key] = data
                print(f"Bundled {label} ({filename})")
        except Exception as e:
            print(f"Warning: Could not fetch {filename}: {e}")

    bundled_file = "assets/data/bundled_chapters.json"
    with open(bundled_file, "w", encoding="utf-8") as f:
        json.dump(bundled_chapters, f, ensure_ascii=False, indent=2)
    print(f"Saved {len(bundled_chapters)} bundled chapters to {bundled_file}")

if __name__ == "__main__":
    main()
