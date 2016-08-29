require 'pry'

# add a constructor shortcut to hash containing initial data
class DataHash < Hash
  def self.constr(probability, credits, total_probab)
    end_of_range = total_probab + (probability.to_f * 10).to_i - 1
    Hash[probability: probability.to_f / 100,
         credits: credits.to_f,
         random_range: total_probab..end_of_range]
  end
end

# Convert data from string form
def stats_and_paylines_from_str(str)
  data = {}
  total_probab = 0
  str.split(/\n\r?/).each do |text|
    slices = text.split(/(% \-| - | )+/)
    data[slices[0].to_i] = DataHash.constr(slices[2], slices[4], total_probab)
    total_probab += (slices[2].to_f * 10).to_i
  end
  data
end

def simulate(payin, paylines)
  payout = 0.0
  payin.to_i.times do
    random_n = rand(1000)
    faces = paylines.select { |_, pl| pl[:random_range].include?(random_n) }
    face = faces.keys.first
    payout += paylines[face][:credits] # || 0 # if !paylines[face].nil?
  end
  payback_percent = payout * 100 / payin
end

# print scores of calculation and Simulations, returns payback_percent
def print_scores(payout, payin, debug)
  debug = debug.sort.to_h
  payback_percent = payout * 100 / payin
  puts "\nPayed out: #{payout}"
  puts "Payed in:  #{payin}"
  puts "\nPayback % = #{format('%.6f', payback_percent)} % \n"
  puts "Occurance payloads: #{debug}"
end

payline_data = "0 - 15% - 3 credits payout
1 - 65% - 0 credits
2 - 7% - 2 credits
3 - 3% - 15 credits
4 - 1% - 1 credit
5 - 2% - 1.5 credits
6 - 1.5% - 4 credits
7 - 1.5% - 5 credits
8 - 3% - 7 credits
9 - 1% - 55 credits"

paylines = stats_and_paylines_from_str(payline_data)
puts "Paylines: #{paylines}\n"

payin = 2_000.0
payout = 0.0
debug = {}

paylines.each do |face, bonus|
  debug[face] = bonus[:probability] * payin.to_i
  payout += bonus[:probability] * bonus[:credits] * payin
end

print_scores(payout, payin, debug)

simulation_payloads = []
1_000.times do
  simulation_payloads << simulate(payin, paylines)
end

puts "\nSimulations scores:"
puts simulation_payloads
# TODO: calculate left and right borders of payload %
