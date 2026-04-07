
import re
import json
import psycopg2

#Configuration
RAW_FILE = "task1_d.json"   # put the file in the same folder as this script

DB_CONFIG = {
    "host":     "DB_HOST",
    "port":     "DB_PORT",
    "dbname":   "DB_NAME",
    "user":     "DB_USER",
    "password": "DB_PASSWORD"
}

# Parse the Ruby-hash file
print("Reading raw file …")
with open(RAW_FILE, encoding="utf-8") as f:
    raw = f.read()

# Convert Ruby symbol keys  :key=>  →  "key":
text = re.sub(r':(\w+)=>', r'"\1":', raw)

records = json.loads(text)
print(f"Parsed {len(records):,} records")

# Connect to PostgreSQL
conn = psycopg2.connect(**DB_CONFIG)
conn.autocommit = False
cur = conn.cursor()

#Insert records
rows = []
for r in records:
    rows.append((
        r["id"],
        r.get("title"),
        r.get("author"),
        r.get("genre"),
        r.get("publisher"),
        r.get("year"),
        r.get("price"),
    ))

cur.executemany(
    """
    INSERT INTO books (book_id, title, author, genre, publisher, pub_year, price)
    VALUES (%s, %s, %s, %s, %s, %s, %s)
    ON CONFLICT (book_id) DO NOTHING
    """,
    rows
)
conn.commit()

cur.execute("SELECT COUNT(*) FROM books")
print(f"Inserted rows into 'books' -> total: {cur.fetchone()[0]:,}")

cur.close()
conn.close()
print("\nDone!")
