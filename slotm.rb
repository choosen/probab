# require 'pry'

# Convert string to hash probability in string form, need to eval hash table
def stats_from_string(str, number)
  # puts "\nStart array: #{str}\n\n"
  a = str.split.sort
  results = {}
  a.each { |c| results[c] = (results[c] || 0) + 1 }
  results['total'] = a.count
  puts "Occurance in strip #{number}: #{results}"
  results.each { |key, val| results[key] = "#{val} / #{results['total']}.0" }
  # puts "Probability: #{results}"
  results
end

# add a random_element method to array
class Array
  def random_element
    self[rand(length)]
  end
end

#
def paylines_from_string(str)
  payline_strings = str.split(/\n\r?/)
  # puts payline_strings
  paylines = {}
  payline_strings.each do |p|
    div = p.split
    paylines[div[0]] = div[2].to_i
  end
  paylines
end

# print scores of calculation and Simulations, returns payback_percent
def print_scores(payout, payin, debug)
  debug = debug.sort.to_h
  payback_percent = payout * 100 / payin
  puts "\nPayed out: #{payout}"
  puts "Payed in:  #{payin}"
  puts "\nPayback % = #{format('%.6f', payback_percent)} % \n"
  puts "Occurance payloads: #{debug}"
  payback_percent
end

payline_data = "AAA ——> 100
BBB ——> 80
CCC ——> 60
DDD ——> 40
EEE ——> 20
ABC ——> 10
EDC ——> 5"

paylines = paylines_from_string(payline_data)
# puts "Paylines: #{paylines}\n"

s1 = 'A B C B D E A A B D E C B D A B D E'
s2 = 'E D E B C A B E D A B C D E A A B B B D D D C E D A D'
s3 = 'B B D E A E D A C B E A B D E A C D'

a1 = s1.split
a2 = s2.split
a3 = s3.split

strip1 = stats_from_string(s1, '1')
strip2 = stats_from_string(s2, '2')
strip3 = stats_from_string(s3, '3')

total_possibilities = "#{strip1['total'].split('/')[1]} *"\
          "#{strip2['total'].split('/')[1]} * #{strip3['total'].split('/')[1]}"
puts "\nTotal possibilities are #{total_possibilities}"

payline_probab = {}
paylines.each do |p|
  payline_probab[p[0]] = "#{strip1[p[0][0]]} * "\
                         "#{strip2[p[0][1]]} * #{strip3[p[0][2]]}"
end

# puts "payline_probab: #{payline_probab}"

payline_probab.each { |key, val| payline_probab[key] = eval(val) }

puts "payline_probab: #{payline_probab}"

payin = 1_000_000_0.0
payout = 0
debug = {}
# puts "\nThearetical payout for each combination for #{payin} credits"
paylines.each do |setup, bonus|
  debug[setup] = (payline_probab[setup] * payin).to_i
  payout += payline_probab[setup] * bonus * payin
end

print_scores(payout, payin, debug)

puts "\nSimulations scores:"
payout = 0
debug = {}

require 'benchmark'

c = Benchmark.measure do
  payin.to_i.times do
    turn = a1.random_element + a2.random_element + a3.random_element
    payout += paylines[turn].to_i
    debug[turn] = debug[turn].to_i + 1 unless paylines[turn].nil?
  end
end

r = Benchmark.measure do
  for i in 1..(payin.to_i) do
    turn = a1.random_element + a2.random_element + a3.random_element
    payout += paylines[turn].to_i
    debug[turn] = debug[turn].to_i + 1 unless paylines[turn].nil?
  end
end

u = Benchmark.measure do
  1.upto(payin.to_i) do
    turn = a1.random_element + a2.random_element + a3.random_element
    payout += paylines[turn].to_i
    debug[turn] = debug[turn].to_i + 1 unless paylines[turn].nil?
  end
end

e = Benchmark.measure do
  (1..(payin.to_i)).each do
    turn = a1.random_element + a2.random_element + a3.random_element
    payout += paylines[turn].to_i
    debug[turn] = debug[turn].to_i + 1 unless paylines[turn].nil?
  end
end


puts "C= #{c} | R = #{r} | U = #{u} | E = #{e}"

print_scores(payout, payin, debug)
