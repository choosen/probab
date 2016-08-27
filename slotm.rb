#require 'pry'

def statsFromString(str)
  #puts "\nStart array: #{str}\n\n"
  a = str.split.sort
  results = {}
  a.each { |c| results[c] = (results[c] || 0) + 1 }
  results['total'] = a.count
  puts "Occurance: #{results}"
  results.each { |key,value| results[key] = "#{value}/#{results['total']}.0" }
  #puts "Probability: #{results}"
  results
end

class Array
  def random_element
    self[rand(length)]
  end
end

def getPaylines(str)
  payline_strings = str.split(/\n\r?/)
  #puts payline_strings
  paylines = {}
  payline_strings.each do |p|
    div = p.split
    paylines[div[0]] = div[2].to_i
  end
  paylines
end

payline_data = "AAA ——> 100
BBB ——> 80
CCC ——> 60
DDD ——> 40
EEE ——> 20
ABC ——> 10
EDC ——> 5"

paylines = getPaylines(payline_data)
#puts "Paylines: #{paylines}\n"

s1 = 'A B C B D E A A B D E C B D A B D E'
s2 = 'E D E B C A B E D A B C D E A A B B B D D D C E D A D'
s3 = 'B B D E A E D A C B E A B D E A C D'

a1 = s1.split
a2 = s2.split
a3 = s3.split

strip1 = statsFromString(s1)
strip2 = statsFromString(s2)
strip3 = statsFromString(s3)

total_possibilities = "#{strip1['total'].split('/')[1]} * #{strip2['total'].split('/')[1]} * #{strip3['total'].split('/')[1]}"
#puts "\nTotal possibilities are #{total_possibilities}"

payline_probabilities = {}
paylines.each { |p| payline_probabilities[p[0]] = "#{strip1[p[0][0]]} * #{strip2[p[0][1]]} * #{strip3[p[0][2]]}" }

#puts "Payline_probabilities: #{payline_probabilities}"

payline_probabilities.each { |key,value| payline_probabilities[key] = eval("#{value}") }

puts "Payline_probabilities: #{payline_probabilities}"

debug = {}
paylines.each { |key,value| debug[key] = 0 }

payin = 1000000.0
payout = 0
#puts "\nThearetical payout for each combination for #{payin} credits"
paylines.each do |setup,bonus|
  debug[setup] = (payline_probabilities[setup] * payin).to_i
  #puts "#{setup}: #{payline_probabilities[setup] * bonus * payin}"
  payout += payline_probabilities[setup] * bonus * payin
end

payback_percent = payout*100/payin
puts "\nPayed out: #{payout}"
puts "Payed in:  #{payin}"
puts "Payback % = #{'%.6f' %  payback_percent} % \n"
puts "Occurance payloads: #{debug}"

puts "\nSimulations scores:"
payout = 0
debug = {}
paylines.each { |key,value| debug[key] = 0 }

payin.to_i.times do
  turn = a1.random_element + a2.random_element + a3.random_element
  val = paylines[turn]
  payout += val || 0
  debug[turn] = (debug[turn] || 0) + 1  if !val.nil? && val > 0
end

payback_percent_real = payout*100/payin
puts "\nPayed out: #{payout}"
puts "Payed in:  #{payin}"
puts "\nPayback % = #{'%.6f' %  payback_percent_real} % \n"
puts "Occurance payloads: #{debug}"
