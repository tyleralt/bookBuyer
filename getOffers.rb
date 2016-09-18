require 'rubygems'
require 'mechanize'
require_relative 'offersHelpers.rb'
require 'Date'
require 'CSV'

DATE_LIMIT = Date.new(2016,8,20)

driver = Mechanize.new()
driver.user_agent_alias = 'Mac Safari'

login(driver)




#I think that this was just left over for testing the getArrayOfOfferingLinks
#lastDateChecked = Date.today
#while (lastDateChecked > DATE_LIMIT)
  #links = getArrayOfOfferingLinks(driver)
  #handle
#end


shouldEnd = false
CSV.open("bookData/offers.csv", "wb") do |csv|
  (1..1000).each do |counter|
    links = getArrayOfOfferingLinks(driver, counter)
    links.each do |link|
      puts 'we are here'
      date = getDate(driver, link)
      if (date < DATE_LIMIT) then
        shouldEnd = true
        break
      end
      data = getOfferInformation(driver,link)
      if (data)
        csv << data.push(link)
      end
    end
    if shouldEnd; break; end
  end
end



