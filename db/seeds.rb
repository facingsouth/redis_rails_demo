# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)


User.destroy_all
Post.destroy_all

5.times do |i|
  user = User.create(name: "User #{i+1}")
  5.times do |j|
    user.posts.create(title: "Post #{5*i+j+1}", content: "Lorem ipsum dolor sit amet, consectetur adipiscing elit.")
  end
end