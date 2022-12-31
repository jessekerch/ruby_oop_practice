require 'io/console'

module Cleanable
  def clean
    # clean the brewery, so you can make more beer
    work_a_shift
  end
end

PEOPLE_NAMES = %w(Davin Avery Natasha Maya Kendall Joslyn Evelyn Darren 
                  Pranav Krista Brent Dexter)
                  
BEER_ADJECTIVES = %w(Crispy Hoppy Fresh Rich Dark Barrel-Aged Classic Modern Malty)

class Staff
  attr_reader :name, :job_title, :jobs
  include Cleanable

  def initialize(name, job_title)
    @name = name
    @job_title = job_title
  end
  
end

class Brewer < Staff
  def initialize(name, job_title)
    super(name, job_title)
    @jobs = "brew, ferment, clean, or relax (b/f/c/r)"
  end
end

class CellarPerson < Staff
  def initialize(name, job_title)
    super(name, job_title)
    @jobs = "ferment, package, clean, or relax (f/p/c/r)"
  end
end

class Bartender < Staff
  def initialize(name, job_title)
    super(name, job_title)
    @jobs = "serve beer, clean, or relax (s/c/r)"
  end
end

class Manager
  attr_reader :name
  def initialize(name)
    @name = name
  end
  
  # def pay_staff(name) # Advanced Function
  #   # pay one of the staff, enter their name
  #   work_a_shift
  # end
  
  # def hire(name) # Advanced Function
  #   # add someone to the team
  #   work_a_shift
  # end
end

class Brewery
  BEER_STYLES = %w(Lager IPA Stout)
  STAFF_JOBS = ['Brewer', 'Cellar Person', 'Bartender']
  attr_accessor :our_beers, :open_orders, :cold_box, :brewery_team, :fv_tank, :cash_drawer
  
  def initialize(name)
    @cash_drawer = 100
    @brewery_team = []
    @our_beers = []
    @open_orders = { 'Lager' => 1, 'IPA' => 1, 'Stout' => 1 }
    @fv_tank = nil
    @cold_box = { 'Lager' => 0, 'IPA' => 0, 'Stout' => 0 }
  end
  
  def build_our_beers
    # add all beers to the beer_lineup like @ipa = IPA.new or something using collaborators
    BEER_STYLES.each do |style|
      create_a_beer(style)
    end
  end
  
  def display_our_beers
    puts "Matz Brew Co Beers: "
    our_beers.each do |beer|
      puts "* " + [beer.name, beer.abv, "$#{beer.price}"].join(", ")
    end
  end
  
  def create_a_beer(style)
    case style
    when 'Lager'
      @lager = Lager.new("#{BEER_ADJECTIVES.sample} Lager", "4.5%", 5, 2)
      @our_beers << @lager
    when 'IPA'
      @ipa = IPA.new("#{BEER_ADJECTIVES.sample} IPA", "6.8%", 7, 5)
      @our_beers << @ipa
    when 'Stout'
      @stout = Stout.new("#{BEER_ADJECTIVES.sample} Imperial Stout", "9%", 9, 4)
      @our_beers << @stout
    end
  end
  
  def display_team_names
    puts ""
    puts "Brewery team: #{@brewery_team[0].job_title} " +
         "#{@brewery_team[0].name}, " +
         "#{@brewery_team[1].job_title} #{@brewery_team[1].name}, " +
         "and #{@brewery_team[2].job_title} #{@brewery_team[2].name}"
  end
  
  def build_brewery_team
    # add all beers to the beer_lineup like @ipa = IPA.new or something using collaborators
    STAFF_JOBS.each do |job_title|
      hire_staff(job_title)
    end
  end

  def hire_staff(job_title)
    case job_title
    when 'Brewer'
      @brewer = Brewer.new(PEOPLE_NAMES.sample, job_title)
      @brewery_team << @brewer
    when 'Cellar Person'
      @cellar_person = CellarPerson.new(PEOPLE_NAMES.sample, job_title)
      @brewery_team << @cellar_person
    when 'Bartender'
      @bartender = Bartender.new(PEOPLE_NAMES.sample, job_title)
      @brewery_team << @bartender
    end
  end
  
  def brew_beer
    style_choice = nil
    loop do
      puts "What style of beer should we brew? Lager, IPA, or Stout?"
      style_choice = gets.chomp.downcase
      break if %w(lager ipa stout).include?(style_choice)
      puts "That's not a valid beer style!"
    end
    if fv_tank == nil
      case style_choice
      when 'lager' then style_choice = 'Lager'
      when 'ipa' then style_choice = 'IPA'
      when 'stout' then style_choice = 'Stout'
      end  
      puts ""
      puts "Brewing a batch of #{style_choice}."
      @cash_drawer -= ((instance_variable_get("@#{style_choice.downcase}").cost) * 10)
      @fv_tank = [style_choice, 'unfermented wort']
    else
      puts "You can only brew if the tanks are empty!"
    end
  end
  
  def ferment_beer
    puts ""
    puts "Fermenting a batch of #{@fv_tank[0]}"
    @fv_tank[1] = 'fermented beer'
  end

  def package_beer
    if fv_tank && fv_tank[1] == 'fermented beer'
      @cold_box[@fv_tank[0]] += 10
      puts ""
      puts "Packaging 10 cans of #{@fv_tank[0]}"
      @fv_tank[1] = 'empty but dirty'
    else
      puts "You can only package fermented beer!"
    end
  end

  def clean_tanks
    puts "Cleaning tanks"
    @fv_tank = nil
  end
  
  def serve_beer
    #serve up to 3 beers, style is based on highest demand and inventory available
    3.times do
      style = ""
      index = 3
      loop do
        index -= 1
        beer_option = @open_orders.sort_by {|_,qty| qty}[index][0]
        if @open_orders[beer_option] > 0 && @cold_box[beer_option] > 0
          style = beer_option
        end
        break if style || index < 0
      end
      
      if style
        puts "Serving a glass of #{style}"
        @open_orders[style] -= 1
        @cold_box[style] -= 1
        @cash_drawer += (instance_variable_get("@#{style.downcase}")).price
      else
        puts "Can't serve anything!"
      end
    end
  end

end

class Beer
  attr_reader :name, :price, :abv, :cost
  def initialize(name, abv, price, cost)
    @name = name
    @abv = abv
    @price = price
    @cost = cost
  end
end

class Lager < Beer
end

class IPA < Beer
end

class Stout < Beer
end

class Game
  attr_accessor :brewery, :manager
  
  def initialize
    @brewery = Brewery.new('Matz Brew Co')
    @manager = Manager.new('Manager')
  end
  
  def run
    #name_the_manager # Advanced Function
    brewery.build_our_beers
    brewery.display_our_beers
    brewery.build_brewery_team #Advanced Function
    brewery.display_team_names
    pause_before_screen_clear
    loop do 
      new_beer_order
      staff_activities # make beers, clean brewery, pour beers and get money
      display_situation
      break if brewery.cash_drawer >= 1000
    end

    # break if brewery.cash_drawer >= 1000

    # display_winning_message
  end
  
  def new_beer_order
    rand(5).times do
      beer_order = Brewery::BEER_STYLES.sample
      brewery.open_orders[beer_order] += 1
    end
  end
  
  def display_situation
    system 'clear'
    display_cash_drawer
    display_beer_orders
    display_cold_box
    display_tanks
  end
  
  def pause_before_screen_clear
    puts ""
    puts "< press return to continue >"
    STDIN.getch
  end

  def display_cash_drawer
    if brewery.cash_drawer > 0
      puts "The brewery has $#{brewery.cash_drawer}"
    else
      puts "You have no cash!"
    end
  end

  def display_beer_orders
    if brewery.open_orders.values.sum > 0
      puts "Open beer orders: #{brewery.open_orders}"
    else
      puts "There are no open beer orders"
    end
  end
  
  def display_tanks
    puts brewery.fv_tank ? "The tank is full of #{brewery.fv_tank}" : "The tank is empty"
  end
  
  def display_cold_box
    if brewery.cold_box.values.sum > 0
      puts "Beers in cold box: #{brewery.cold_box}"
    else
      puts "The cold box is empty"
    end
  end
  
  def staff_activities
    brewery.brewery_team.each do |staff|
      display_situation
      puts ""
      activity = ""
      loop do
        puts "#{staff.name} can #{staff.jobs}"
        puts "What would you like them to do? "
        activity = gets.chomp
        break if staff.jobs.include?(activity)
        puts "That's not a valid job!"
      end
      case activity.downcase
      when 'b' then brewery.brew_beer
      when 'f' then brewery.ferment_beer
      when 'p' then brewery.package_beer
      when 's' then brewery.serve_beer
      when 'c' then brewery.clean_tanks
      when 'r' then puts "Taking it easy"
      end
      pause_before_screen_clear
    end
  end

end

new_game = Game.new
new_game.run
