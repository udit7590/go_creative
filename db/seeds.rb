# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)


#FIXME_AB: Since we will launch this app in opensource so lets ask user to input email and password instead of hardcoding. 

AdminUser.create!(email: 'udit@booleans.in', password: 'admin123', password_confirmation: 'admin123')
AdminUser.create!(email: 'admin@booleans.in', password: 'admin123', password_confirmation: 'admin123')
u = User.create!(first_name: 'Udit', email: 'udit@booleans.in', password: 'user1234', password_confirmation: 'user1234')
u.confirm
