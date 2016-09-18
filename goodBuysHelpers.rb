require 'rubygems'
require 'CSV'
require 'selenium-webdriver'

BOOKSCOUTER_URL = "http://bookscouter.com/prices.php?isbn="
URL_TAIL = "&all" 
#trhis one doesn't do chegg for some reason
#URL_TAIL = "&searchbutton=Sell"

def getDictionaryOfPrices (isbn)
  #returns a hash from a company to a price they offer
  #returns nil if the isbn was bad
  link = BOOKSCOUTER_URL + isbn.to_s + URL_TAIL
  puts link
  $driver.navigate.to(BOOKSCOUTER_URL + isbn.to_s + URL_TAIL)
  #if ($driver.current_url.include?("badisbn")) then
  if (not $driver.current_url.include?(isbn.to_s)) then
      puts 'this was bad' + isbn.to_s
      return nil
  else
    wait = Selenium::WebDriver::Wait.new(:timeout => 30)
    wait.until { $driver.find_element(:id => "faux-featBox" || $driver.find_element(:class => "sellbox-bg").displayed?) }
    allOffers = $driver.find_element(:id => "price_results")
    companyToPriceHash = Hash.new
    sleep(1)
    allOffers.find_elements(:class => 'offer').each do |offer|
      nameOfCompany = offer.find_element(:class => 'column-1').text
      priceColumn = offer.find_element(:class => 'column-6').text
      priceMatcher = /\$((?:\d|.)*)/.match(priceColumn)
      if (priceMatcher)
        companyToPriceHash[nameOfCompany] = priceMatcher[1]
      end
    end
    return companyToPriceHash
  end
end

class ExponentialBackOffHandler

  def initialize()
    @sleepTime = 5
  end

  def backOff
    sleep(@sleepTime * 60)
    @sleepTime *= 2
  end

  def reset
    @sleepTime = 0
  end
end
