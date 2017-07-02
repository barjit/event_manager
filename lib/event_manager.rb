require "csv"
require "sunlight/congress"
require "erb"

Sunlight::Congress.api_key = "e179a6973728c4dd3fb1204283aaccb5"

def clean_zipcode(zipcode)
  zipcode.to_s.rjust(5, "0")[0..4]
end

def clean_phone_number(phone)
  phone = phone.scan(/\d/).join

  if phone.length < 10
    "0000000000"
  elsif phone.length == 11
    if phone[0] == "1"
      phone[1..10]
    else
      "0000000000"
    end
  elsif phone.length > 11
    "0000000000"
  else
    phone
  end
end


def legislators_by_zipcode(zipcode)
  Sunlight::Congress::Legislator.by_zipcode(zipcode)
end

def save_thank_you_letters(id, form_letter)
  Dir.mkdir("output") unless Dir.exists? "output"

  filename = "output/thanks_#{id}.html"

  File.open(filename, 'w') do |file|
    file.puts form_letter
  end    
end


contents = CSV.open "event_attendees.csv", headers: true, header_converters: :symbol

template_letter = File.read "form_letter.erb"
erb_template = ERB.new template_letter

contents.each do |row|
  id = row[0]
  name = row[:first_name].capitalize
  phone_number = row[:homephone]

  zipcode = clean_zipcode(row[:zipcode])

  legislators = legislators_by_zipcode(zipcode)

  form_letter = erb_template.result(binding)

  phone_number = clean_phone_number(phone_number)

  puts "saving #{name}'s thank you letter to html"
  save_thank_you_letters(id, form_letter)
end
