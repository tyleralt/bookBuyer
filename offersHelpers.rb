require 'rubygems'
require 'mechanize'
require 'Date'

def login (driver)
  bazaarLogin = driver.get('http://pennbookbazaar.com/')
  bazaarLoginForm = bazaarLogin.form
  bazaarLoginForm.email = "USERNAME HERE"
  bazaarLoginForm.password = "PASSWORD HERE"
  driver.submit(bazaarLoginForm, bazaarLoginForm.buttons[0])
end

def getArrayOfOfferingLinks (driver, pageNumber)
  element = driver.get("http://pennbookbazaar.com/offer/all&page=" + pageNumber.to_s)
  offerings = Array.new
  #pp element.search("a")[0].attributes["href"].value
  element.search("[class='post']").each do |post|
    link = post.css("a")[0].attributes["href"].value
    offerings.push(link)
  end
  return offerings
end

def getDate (driver, link)
  bookInfoElement = driver.get(link).search("[class='book']")
  text = bookInfoElement.text
  dateMatchData = /Posted on: (\d{2})-(\d{2})-(\d{4})/.match(text)
  return Date.new(dateMatchData[3].to_i, dateMatchData[1].to_i, dateMatchData[2].to_i)
end

def getOfferInformation (driver, link)
  #returns an array of the the information or nil if it is missing the isbn
  #goes [book name, 
  information = Array.new
  bookInfoElement = driver.get(link).search("[class='book']")
  text = bookInfoElement.text
  dateMatchData = /Posted on: (\d{2})-(\d{2})-(\d{4})/.match(text)
  date = Date.new(dateMatchData[3].to_i, dateMatchData[1].to_i, dateMatchData[2].to_i)
  information [0] = date

  bookName = /Book:\s*(.*)/.match(text)[1]
  authors = /Author\(s\):\s*(.*)/.match(text)[1]
  isbnMatch = (/ISBN: ((?:\d|\-)+)/.match(text))

  bookPriceElement = driver.current_page().search("[class='single_area']").search("p")
  bookPriceMatch = /Price:\s*\$(\d*)/.match(bookPriceElement.text)

  if (isbnMatch && bookPriceMatch) then
    return [isbnMatch[1], bookPriceMatch[1].to_i, bookName, authors]
  else
   return nil
  end
end

def help (driver)
  puts"###################################"
  pp driver
  puts "###################################"
end
  #bazaarMeam = driver.get('http://pennbookbazaar.com/sas/biol/')
  #allPosts = bazaarMeam.at("#listings")
  #link = allPosts.css("[class=post]")[3].css("h2")[0].css("a")[0]['href']
  #puts link
  #onePage = driver.get(link)
  #bookDets = onePage.at("div [class=\"book\"]")
  #puts "this is the date"
  #puts bookDets.text
  #puts bookDets.xpath("//comment()")[5]
  #pp bookDets.css("b")[0].text
#
