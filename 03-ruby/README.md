# Allegro Crawler

A Ruby scraper for Allegro.pl – it fetches products by keywords and saves the data to an SQLite database.

## Requirements
```bash
gem install selenium-webdriver nokogiri sequel sqlite3
```
You also need ChromeDriver in a version compatible with your installed Chrome:
https://googlechromelabs.github.io/chrome-for-testing/

## Usage
```bash
ruby crawler.rb <keyword> <limit>
```
Default limit is `10`.

### Docker
```bash
docker build -t allegro-crawler .

docker run --rm -v "${PWD}/db:/app/db" allegro-crawler "macbook pro" 15
```

## Dataabse preview
```bash
sqlite3 db/Allegro.db "SELECT title, price FROM laptop LIMIT 5;"
```
