require 'selenium-webdriver'
require 'nokogiri'
require 'uri'

# OPENING THE SITE
# Using selenium to open page via chrome - simulating an actual user
options = Selenium::WebDriver::Chrome::Options.new

options.add_argument('--disable-blink-features=AutomationControlled')
options.add_argument('--no-sandbox')
options.add_argument('--disable-dev-shm-usage')

driver = Selenium::WebDriver.for :chrome, options: options

driver.execute_cdp('Page.addScriptToEvaluateOnNewDocument',
  source: "Object.defineProperty(navigator, 'webdriver', {get: () => undefined})"
)

puts "Opening Allegro..."
driver.get("https://allegro.pl")
sleep(rand(4..8)) # Simulating real user

puts "Title: #{driver.title}"

driver.get("https://allegro.pl/kategoria/zabawki-11818")
sleep(rand(5..9)) # Simulating real user

html = driver.page_source
File.write("debug.html", html)
puts "Site Saved to a debug HTML file - #{html.size} bytes"

# SCRAPING INFORMATION
doc = Nokogiri::HTML(html)
articles = doc.css("article")
puts "Products: #{articles.size}"

puts "PRODUCT NAME | PRICE | LINK"
articles.each do |item|
  # Title - text of the link inside header2
  title = item.css("h2 a").text.strip

  # Price - paragraph with aria-label containing "aktualna cena"
  price_node = item.css("p[aria-label*='aktualna cena']").first
  price = price_node ? price_node["aria-label"].gsub("aktualna cena", "").strip : "no price"

  # Link - - first link inside header2
  href = item.css("h2 a").first&.[]("href") || "no link"

  next if title.empty?
  puts "#{title[0..60]} | #{price} | #{href}"
end

driver.quit