import json
import re

def clean_text(text):
    if not text:
        return ""
    # Remove HTML/XML tags like <t />, <f>...</f>, <q>, etc.
    text = re.sub(r'<[^>]+>', '', text)
    # Normalize whitespaces
    text = re.sub(r'\s+', ' ', text).strip()
    return text

def main():
    print("Reading assets/data/ayt.json...")
    with open("assets/data/ayt.json", "r", encoding="utf-8") as f:
        raw_verses = json.load(f)

    # Book metadata mapping
    BOOK_NAMES = {
        1: ("Kejadian", "Kej", "PL"),
        2: ("Keluaran", "Kel", "PL"),
        3: ("Imamat", "Im", "PL"),
        4: ("Bilangan", "Bil", "PL"),
        5: ("Ulangan", "Ul", "PL"),
        6: ("Yosua", "Yos", "PL"),
        7: ("Hakim-hakim", "Hak", "PL"),
        8: ("Rut", "Rut", "PL"),
        9: ("1 Samuel", "1Sam", "PL"),
        10: ("2 Samuel", "2Sam", "PL"),
        11: ("1 Raja-raja", "1Raj", "PL"),
        12: ("2 Raja-raja", "2Raj", "PL"),
        13: ("1 Tawarikh", "1Taw", "PL"),
        14: ("2 Tawarikh", "2Taw", "PL"),
        15: ("Ezra", "Ezr", "PL"),
        16: ("Nehemia", "Neh", "PL"),
        17: ("Ester", "Est", "PL"),
        18: ("Ayub", "Ayb", "PL"),
        19: ("Mazmur", "Maz", "PL"),
        20: ("Amsal", "Ams", "PL"),
        21: ("Pengkhotbah", "Pkh", "PL"),
        22: ("Kidung Agung", "Kid", "PL"),
        23: ("Yesaya", "Yes", "PL"),
        24: ("Yeremia", "Yer", "PL"),
        25: ("Ratapan", "Rat", "PL"),
        26: ("Yehezkiel", "Yeh", "PL"),
        27: ("Daniel", "Dan", "PL"),
        28: ("Hosea", "Hos", "PL"),
        29: ("Yoel", "Yoe", "PL"),
        30: ("Amos", "Amo", "PL"),
        31: ("Obaja", "Oba", "PL"),
        32: ("Yunus", "Yun", "PL"),
        33: ("Mikha", "Mik", "PL"),
        34: ("Nahum", "Nah", "PL"),
        35: ("Habakuk", "Hab", "PL"),
        36: ("Zefanya", "Zef", "PL"),
        37: ("Hagai", "Hag", "PL"),
        38: ("Zakharia", "Zak", "PL"),
        39: ("Maleakhi", "Mal", "PL"),
        40: ("Matius", "Mat", "PB"),
        41: ("Markus", "Mrk", "PB"),
        42: ("Lukas", "Luk", "PB"),
        43: ("Yohanes", "Yoh", "PB"),
        44: ("Kisah Para Rasul", "Kis", "PB"),
        45: ("Roma", "Rom", "PB"),
        46: ("1 Korintus", "1Kor", "PB"),
        47: ("2 Korintus", "2Kor", "PB"),
        48: ("Galatia", "Gal", "PB"),
        49: ("Efesus", "Efe", "PB"),
        50: ("Filipi", "Flp", "PB"),
        51: ("Kolose", "Kol", "PB"),
        52: ("1 Tesalonika", "1Tes", "PB"),
        53: ("2 Tesalonika", "2Tes", "PB"),
        54: ("1 Timotius", "1Tim", "PB"),
        55: ("2 Timotius", "2Tim", "PB"),
        56: ("Titus", "Tit", "PB"),
        57: ("Filemon", "Flm", "PB"),
        58: ("Ibrani", "Ibr", "PB"),
        59: ("Yakobus", "Yak", "PB"),
        60: ("1 Petrus", "1Pet", "PB"),
        61: ("2 Petrus", "2Pet", "PB"),
        62: ("1 Yohanes", "1Yoh", "PB"),
        63: ("2 Yohanes", "2Yoh", "PB"),
        64: ("3 Yohanes", "3Yoh", "PB"),
        65: ("Yudas", "Yud", "PB"),
        66: ("Wahyu", "Why", "PB"),
    }

    books_info = {}
    cleaned_verses = []

    for v in raw_verses:
        book_id = int(v["book"])
        chap = int(v["chapter"])
        verse_num = int(v["verse"])
        text = clean_text(v.get("text", ""))
        title = clean_text(v.get("title", ""))

        if book_id not in books_info:
            name, abbr, test = BOOK_NAMES.get(book_id, (f"Kitab {book_id}", "Ktb", "PB"))
            books_info[book_id] = {
                "id": book_id,
                "name": name,
                "abbr": abbr,
                "testament": test,
                "maxChapter": 0,
                "totalVerses": 0
            }

        if chap > books_info[book_id]["maxChapter"]:
            books_info[book_id]["maxChapter"] = chap
        books_info[book_id]["totalVerses"] += 1

        cleaned_verses.append({
            "id": int(v["id"]),
            "b": book_id,
            "c": chap,
            "v": verse_num,
            "t": text,
            "title": title if title else None
        })

    # Save books list
    books_list = [books_info[b_id] for b_id in sorted(books_info.keys())]
    with open("assets/data/books.json", "w", encoding="utf-8") as f:
        json.dump(books_list, f, ensure_ascii=False, indent=2)
    print(f"Updated assets/data/books.json with {len(books_list)} books.")

    # Save starter bundle (Kejadian: 1, Mazmur: 19, Amsal: 20, Matius: 40, Yohanes: 43, Roma: 45, 1 Korintus: 46, Filipi: 50)
    starter_book_ids = {1, 19, 20, 40, 43, 45, 46, 50}
    starter_verses = [v for v in cleaned_verses if v["b"] in starter_book_ids]
    with open("assets/data/starter_bundle.json", "w", encoding="utf-8") as f:
        json.dump(starter_verses, f, ensure_ascii=False)
    print(f"Saved assets/data/starter_bundle.json ({len(starter_verses)} verses).")

    # Save compact full verses for local fast offline loading
    with open("assets/data/full_bible_clean.json", "w", encoding="utf-8") as f:
        json.dump(cleaned_verses, f, ensure_ascii=False)
    print(f"Saved assets/data/full_bible_clean.json ({len(cleaned_verses)} verses).")

if __name__ == "__main__":
    main()
