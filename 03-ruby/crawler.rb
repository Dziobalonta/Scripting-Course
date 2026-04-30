require 'selenium-webdriver'
require 'nokogiri'
require 'uri'
require 'sequel'
require 'sqlite3'
require 'fileutils'

search_query = ARGV[0] || ""
limit = (ARGV[1] || 10).to_i # Default number is 10

## DATABASE SETUP
FileUtils.mkdir_p('db') # if no folder - create it

DB = Sequel.connect('sqlite://db/Allegro.db')
# to_sym changes string to symbol,-  Sequel requires it
table_name = search_query
                        .downcase
                        .tr('ąćęłńóśźż', 'acelnosyz')
                        .gsub(/[^a-z0-9]/, '_')
                        .squeeze('_')
                        .to_sym

DB.create_table?(table_name) do
  primary_key :id
  String :title
  String :price
  String :url, unique: true
  DateTime :scraped_at
end

products_db = DB[table_name]

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
sleep(2) # Simulating real user

products = []
page_num  = 1

while products.size < limit
  puts "Strona #{page_num} | Zebrano #{products.size}/#{limit}..."

  # encode query to web format, change spaces to %20 etc
  encoded = URI.encode_www_form_component(search_query)
  driver.get("https://allegro.pl/listing?string=#{encoded}&p=#{page_num}")
  sleep(3) # Simulating real user

  # SCRAPING BASIC INFORMATION
  doc      = Nokogiri::HTML(driver.page_source)
  articles = doc.css("article")
  puts "Products on page: #{articles.size}"

  break if articles.empty?

  puts "PRODUCT NAME | PRICE | LINK"
  articles.each do |item|
    break if products.size >= limit

    # Title - text of the link inside header2
    title = item.css("h2 a").text.strip
    next if title.empty?

    # Price - paragraph with aria-label containing "aktualna cena"
    price_node = item.css("p[aria-label*='aktualna cena']").first
    price = price_node ? price_node["aria-label"].gsub("aktualna cena", "").strip : "no price"

    # Link - first link inside header2
    raw_href = item.css("h2 a").first&.[]("href") || "no link"
    href = if raw_href.include?("redirect=")
      URI.decode_www_form_component(raw_href.match(/redirect=([^&]+)/)[1])
    else
      raw_href
    end

    products << { title: title, price: price, url: href }
    puts "#{title} | #{price} | #{href}"
  end

  page_num += 1
end

# SCRAPING DETALIS
products.each_with_index do |page, i|
  puts "─" * 60
  puts "[#{i+1}/#{products.size}] #{page[:title]}"
  puts "Cena: #{page[:price]}"
  puts "URL:  #{page[:url]}"

  driver.get(page[:url])
  sleep(1)

  doc = Nokogiri::HTML(driver.page_source)
  params = {}

  # Params
  # dl - keys
  # dd - values
  doc.css("div[data-box-name='Parameters'] table tr").each do |row|
    cells = row.css("td")
    next if cells.size < 2

    key = cells[0].text.strip

    value_cell = cells[1].dup  # dup to not modify orignal data
    value_cell.css("div[aria-describedby], div[role='tooltip'], div[aria-hidden]").each { |element| element.remove }
    value = value_cell.text.strip

    params[key] = value unless key.nil? || key.empty?
  end

  if params.empty?
    puts "NO PARAMS"
  else
    puts "Params:"
    params.each do |k, v|
      puts "  #{k}: #{v}"
    end
  end

  puts ""

  ## SAVING TO DATABASE

  params.each_key do |k|
    col = k
          .downcase
          .tr('ąćęłńóśźż', 'acelnosyz')
          .gsub(/[^a-z0-9]/, '_')
          .squeeze('_')
          .to_sym

    unless DB[table_name].columns.include?(col)
      DB.add_column(table_name, col, String)
      puts "  New column added: #{col}"

    end
  end

  row = {
    title:      page[:title],
    price:      page[:price],
    url:        page[:url],
    scraped_at: Time.now
  }

  params.each do |k, v|

    col = k
          .downcase
          .tr('ąćęłńóśźż', 'acelnosyz')
          .gsub(/[^a-z0-9]/, '_')
          .squeeze('_')
          .to_sym

    row[col] = v
  end

  products_db.insert_conflict(:ignore).insert(row)
  
  puts "Saved to Database!"
  puts ""

end

puts "Done! #{products_db.count} products in database."

driver.quit