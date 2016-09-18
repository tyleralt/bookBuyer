require 'rubygems'
require 'CSV'
require 'selenium-webdriver'
require_relative 'goodBuysHelpers.rb'

#Verify to continue
$driver = Selenium::WebDriver.for :firefox

isbn_to_buying_price = Hash.new
isbn_to_penn_price = Hash.new
back_off_handler = ExponentialBackOffHandler.new

#uncomment if something went wrong with the write and you need to redo
#isbn_to_penn_price = Marshal.load(File.read('./bookData/isbn_to_penn_price.bin'))
isbn_to_buying_price = Marshal.load(File.read('./bookData/isbn_to_buying_price.bin'))

CSV.foreach('./bookdata/offers.csv') do |row|
  row[0].slice!("-")
  isbn = row[0]
  price = row[1]

  if (isbn_to_penn_price[isbn]) then
    isbn_to_penn_price[isbn].push(price)
  else
    isbn_to_penn_price[isbn] = [price]
  end

  begin
    if (not isbn_to_buying_price.has_key?(isbn))
      allprices = getDictionaryOfPrices(isbn)
      if (allprices)
        isbn_to_buying_price[isbn] = allprices
      end
    end
  rescue Selenium::WebDriver::Error::TimeOutError
    #we need to back off because this means it is asking for a captcha.
    #it will eventually go away but not sure how long
    back_off_handler.backOff()
    puts 'we did a back off'
    redo
  rescue StandardError
    puts 'there was a StandardError with '+ isbn.to_s
  end
  back_off_handler.reset()
  File.write('./bookData/isbn_to_buying_price.bin', Marshal.dump(isbn_to_buying_price))
end

isbn_to_buying_price.each_value do |hash_of_prices|
  hash_of_prices.each_value do |price|
    price = price.to_f
  end
end

File.write('./bookData/isbn_to_buying_price.bin', Marshal.dump(isbn_to_buying_price))
File.write('./bookdata/isbn_to_penn_price.bin', Marshal.dump(isbn_to_penn_price))

#comment above and uncomment below if one of the writes failed will retrieved saved data
#isbn_to_penn_price = Marshal.load(File.read('./bookData/isbn_to_penn_price.bin'))
#isbn_to_buying_price = Marshal.load(File.read('./bookData/isbn_to_buying_price.bin'))




CSV.open("./bookData/amazonPrices.csv", "wb") do |csv|
  isbn_to_penn_price.each_pair do |key, value|
    if (isbn_to_buying_price[key])
      csv << [value, key, isbn_to_buying_price[key]["Amazon"]]
    end
  end
end

CSV.open("./bookData/cheggPrices.csv", "wb") do |csv|
  isbn_to_buying_price.each_pair do |key, value|
    csv << [isbn_to_penn_price[key], key, value["Chegg"]]
  end
end

CSV.open("./bookData/cheggAndAmazonPrices.csv", "wb") do |csv|
  isbn_to_buying_price.each_pair do |key, value|
    amazon_value = value["Amazon"]
    chegg_value = value["Chegg"]
    if (chegg_value)
      if (not amazon_value )
        csv << [isbn_to_penn_price[key], key, chegg_value]
      elsif (amazon_value)
        if (amazon_value < chegg_value)
          csv << [isbn_to_penn_price[key], key, chegg_value]
        end
      end
    elsif (amazon_value)
      csv << [isbn_to_penn_price[key], key, amazon_value]
    end
  end
end

CSV.open("./bookData/totalBestPrice.csv", "wb") do |csv|
  isbn_to_penn_price.each_pair do |key, value|
    if (hash_of_buy_prices = isbn_to_buying_price[key])
      prices = hash_of_buy_prices.values.map!{ |x| x.to_f}
      csv << [value, prices.max, key]
    end
  end
end
