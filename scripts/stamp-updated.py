#!/usr/bin/env python3
"""Set the "updated <month year>" footer, JSON-LD dateModified and sitemap lastmod.

Run before committing:  python3 scripts/stamp-updated.py
Optional date override: python3 scripts/stamp-updated.py 2026-12
"""
import datetime
import pathlib
import re
import sys

RU = ["январе", "феврале", "марте", "апреле", "мае", "июне", "июле",
      "августе", "сентябре", "октябре", "ноябре", "декабре"]
EN = ["January", "February", "March", "April", "May", "June", "July",
      "August", "September", "October", "November", "December"]

ROOT = pathlib.Path(__file__).resolve().parent.parent
PAGES = ["index.html", "cv/index.html", "en/index.html", "en/cv/index.html"]
PATTERN = re.compile(r'<time class="updated" datetime="[^"]*">[^<]*</time>')
DATE_MODIFIED = re.compile(r'"dateModified":\s*"[^"]*"')
LASTMOD = re.compile(r"<lastmod>[^<]*</lastmod>")


def main() -> None:
    if len(sys.argv) > 1:
        year, month = map(int, sys.argv[1].split("-"))
        date = datetime.date(year, month, 1)
    else:
        date = datetime.date.today()
        year, month = date.year, date.month
    iso = date.isoformat()

    for rel in PAGES:
        path = ROOT / rel
        html = path.read_text(encoding="utf-8")
        names = EN if '<html lang="en"' in html else RU
        stamp = f'<time class="updated" datetime="{year}-{month:02d}">{names[month - 1]} {year}</time>'
        new_html, count = PATTERN.subn(stamp, html)
        if count != 1:
            sys.exit(f"{rel}: expected exactly one <time class=\"updated\">, found {count}")
        new_html, count = DATE_MODIFIED.subn(f'"dateModified": "{iso}"', new_html)
        if count != 1:
            sys.exit(f"{rel}: expected exactly one dateModified in JSON-LD, found {count}")
        path.write_text(new_html, encoding="utf-8")
        print(f"{rel}: {names[month - 1]} {year}, dateModified {iso}")

    sitemap = ROOT / "sitemap.xml"
    xml, count = LASTMOD.subn(f"<lastmod>{iso}</lastmod>", sitemap.read_text(encoding="utf-8"))
    if count == 0:
        sys.exit("sitemap.xml: no <lastmod> entries found")
    sitemap.write_text(xml, encoding="utf-8")
    print(f"sitemap.xml: {count} lastmod entries set to {iso}")


if __name__ == "__main__":
    main()
