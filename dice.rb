require 'pry'

# add a constructor shortcut to hash containing initial data
class DataHash < Hash
  def initialize(probability = '0.0', credits = '0', total_probab = 0)
    end_of_range = total_probab + (probability.to_f * 10).to_i - 1
    self[:probability] = probability.to_f / 100
    self[:credits] = credits.to_f
    self[:random_range] = total_probab..end_of_range
  end
end

# add statistic methods to stats array
class DataStats < Array
  def sum
    inject(0) { |accum, i| accum + i }
  end

  def mean
    sum / length.to_f
  end

  def sample_variance
    m = mean
    sum = inject(0) { |accum, i| accum + (i - m)**2 }
    sum / (length - 1).to_f
  end

  def standard_deviation
    Math.sqrt(sample_variance)
  end
end

# convert data from string form
def stats_and_paylines_from_str(str)
  data = {}
  total_probab = 0
  str.split(/\n\r?/).each do |text|
    slices = text.split(/(% \-| - | )+/)
    data[slices[0].to_i] = DataHash.new(slices[2], slices[4], total_probab)
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
  payout * 100 / payin
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

ROUNDS_IN_GAME_CONST = 2_000.0
SIMULATIONS_NUMBER_CONST = 1_000
# border t-student value of 1_000 samples and 90% confidence level: 1,6449
TSTUDENT_VALUE_CONST = 1.644_9

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

payout = 0.0
debug = {}

paylines.each do |face, data|
  debug[face] = data[:probability] * ROUNDS_IN_GAME_CONST.to_i
  payout += data[:probability] * data[:credits] * ROUNDS_IN_GAME_CONST
end

print_scores(payout, ROUNDS_IN_GAME_CONST, debug)

simulation_payloads = DataStats.new(SIMULATIONS_NUMBER_CONST)
simulation_payloads.each_with_index do |_, index|
  simulation_payloads[index] = simulate(ROUNDS_IN_GAME_CONST, paylines)
end

puts "\nSimulations scores (less format)"
IO.popen('less', 'w') { |f| f.puts simulation_payloads }
puts 'was shown'

puts "Mean: #{simulation_payloads.mean}"
puts "Standard deviation: #{simulation_payloads.standard_deviation}"

result_max = simulation_payloads.mean +
             (simulation_payloads.standard_deviation * TSTUDENT_VALUE_CONST) /
             Math.sqrt(SIMULATIONS_NUMBER_CONST.to_f)
result_min = simulation_payloads.mean -
             (simulation_payloads.standard_deviation * TSTUDENT_VALUE_CONST) /
             Math.sqrt(SIMULATIONS_NUMBER_CONST.to_f)

puts "\nPayload range: #{result_min} .. #{result_max}"
