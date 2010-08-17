require 'factory_girl'

Factory.sequence :name do |n|
  "#{n}" 
end

Factory.define :comment do |c|
  c.body                "Monkey AMZ1monkey Monkey #cute #awesome Monkey!"
  c.tags                ["cute", "awesome"]
end

Factory.define :discussion do |d|
  d.subject             "Monkey is an OIII emission"
  d.slug                "monkey-is-an-oiii-emission"
end

Factory.define :asset do |a|
  a.zooniverse_id       { "AHZ#{Factory.next(:name)}" }
  a.location            "http://imageserver.org/assets/1"
  a.thumbnail_location  "http://imageserver.org/assets/thumbs/1"
end

Factory.define :user do |u|
  u.zooniverse_user_id  { "#{Factory.next(:name)}" }
  u.name                { "User #{Factory.next(:name)}"}
end

Factory.define :collection do |c|
  c.name {"#{Factory.next(:name)}"}
  c.description {"This is collection"}
end