require 'curb'
require 'nokogiri'
require 'csv'

puts "Enter name of url which begin with https://www.petsonic.com/"
name_of_url = gets.chomp


puts "Enter full path and name of file!"
path_of_file = gets.chomp

u = 0

path_of_file = (path_of_file =~ /[\w\W\d]+.csv$/) ? path_of_file : "default.csv"
url_for_count = (name_of_url =~ /^(http|https):[\w\W\d]+/) ? name_of_url : "https://www.petsonic.com/snacks-huesos-para-perros/"
doc_for_count = Nokogiri::HTML(Curl::Easy.perform(url_for_count).body_str)
col_pages = doc_for_count.xpath("//*[@id='center_column']/div[1]/div/div[2]/h1/small/text()").to_s
col_pages = (col_pages.gsub(/[a-zA-Z\W\s]+/, "").to_i)/20 + 1

CSV.open("#{path_of_file}", "wb") do |csv|

	csv << ["title", "price", "picture"]
	(1..col_pages).each do |i|

		url ="#{url_for_count}" + "?p=#{i}"
		main_page = Curl::Easy.perform(url).body_str
		doc = Nokogiri::HTML(main_page)
		count_notes = doc.xpath("//*[@id='center_column']/div[3]/div/div").count
		
		(1..count_notes).each do |j|

			custom_url = doc.xpath("//*[@id='center_column']/div[3]/div/div[#{j}]/div/div[1]/div/a/@href").to_s
			puts custom_url
			custom_doc = Nokogiri::HTML(Curl::Easy.perform(custom_url).body_str)
			picture = custom_doc.xpath("//*[@id='bigpic']/@src").to_s.gsub(/\s{2,}/, "")
			title = custom_doc.xpath("//*[@id='right']/div/div[1]/div/h1/text()").to_s.gsub(/\s{2,}/, "")
			c = custom_doc.xpath("//*[@id='attributes']/fieldset/div/ul").count || 2
		
			(2..c).each do |fi|
				
				title_add = custom_doc.xpath("//*[@id='attributes']/fieldset/div/ul[#{fi}]/li/span[1]/text()").to_s.gsub(/\s{2,}/, "")
				title += " - #{title_add}"
				price =	custom_doc.xpath("//*[@id='attributes']/fieldset/div/ul[#{fi}]/li/span[2]/text()").to_s.gsub(/\s{2,}/, "")
				main_text = [title, price, picture]
				u += 1
				puts u
				csv << main_text
			end
		end
	end
end
