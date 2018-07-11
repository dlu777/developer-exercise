class Card
  attr_accessor :suit, :name, :value

  def initialize(suit, name, value)
    @suit, @name, @value = suit, name, value
  end
end

class Deck
  attr_accessor :playable_cards
  SUITS = [:hearts, :diamonds, :spades, :clubs]
  NAME_VALUES = {
    :two   => 2,
    :three => 3,
    :four  => 4,
    :five  => 5,
    :six   => 6,
    :seven => 7,
    :eight => 8,
    :nine  => 9,
    :ten   => 10,
    :jack  => 10,
    :queen => 10,
    :king  => 10,
    :ace   => [11, 1]}

  def initialize
    shuffle
  end

  def deal_card
    random = rand(@playable_cards.size)
    @playable_cards.delete_at(random)
  end

  def shuffle
    puts "\nStarting new game, shuffling deck..."
    @playable_cards = []
    SUITS.each do |suit|
      NAME_VALUES.each do |name, value|
        @playable_cards << Card.new(suit, name, value)
      end
    end
  end
end

class Hand
  attr_accessor :cards

  def initialize
    @cards = []
  end

  def value
    result = 0
    rearranged_cards = []
    cards.each do |card|
      case card.name
      when :ace
        rearranged_cards.push(card)
      else
        rearranged_cards.unshift(card)
      end
    end

    rearranged_cards.each do |card|
      case card.name
      when :ace
        if result + 11 > 21
          result += 1
        else
          result += 11
        end
      else
        result += card.value
      end
    end
    result
  end
end

class Game
  attr_accessor :player, :dealer, :deck, :player_turn

  def initialize
    @player = Hand.new
    @dealer = Hand.new
    @deck = Deck.new
    @player_turn = true
    run_game
  end

  def run_game
    initial_deal
    while player_turn
      if player.value == 21
        @player_turn = false
        puts "\nHit enter to continue"
        gets.chomp
        finish_dealer
        break
      end
      print "(H)it or (S)tay? "
      action = gets.chomp.downcase
      case action
      when "h"
        hit(player)
      when "s"
        @player_turn = false
        finish_dealer
      end
    end
    print_results
    end_game
  end

  private

  def initial_deal
    2.times do
      player.cards << deck.deal_card
      dealer.cards << deck.deal_card
    end
    print_update
    check_blackjack(dealer)
    check_blackjack(player)
  end

  def check_blackjack(hand)
    if((hand.cards.first.value == 10 && hand.cards.last.name == :ace) || (hand.cards.first.name == :ace && hand.cards.last.value == 10))
      @player_turn = false
      print_update
      if hand == dealer
        puts "Dealer has blackjack, you lose!"
      else
        puts "You have blackjack, you win!"
      end
      end_game
    end
  end

  def hit(hand)
    new_card = deck.deal_card
    hand.cards << new_card
    if hand == player
      puts "\nYou were dealt the #{new_card.name.capitalize} of #{new_card.suit.capitalize}..."
      print_update
      if player.value > 21
        puts "\nYou bust"
        @player_turn = false
      end
    end
    if hand == dealer
      puts "\nThe dealer was dealt the #{new_card.name.capitalize} of #{new_card.suit.capitalize}..."
      print_update
      if dealer.value > 21
        puts "\nDealer busts"
      end
    end
  end

  def finish_dealer
    print_update
    puts "\nHit enter to continue"
    gets.chomp
    while dealer.value < 17
      hit(dealer)
      puts "\nHit enter to continue"
      gets.chomp
    end
  end

  def print_update
    puts "\n===Dealer's hand==="
    if player_turn
      puts "#{dealer.cards[0].name.capitalize} of #{dealer.cards[0].suit.capitalize}"
      puts "?Hole Card?"
    else
      dealer.cards.each do |card|
        puts "#{card.name.capitalize} of #{card.suit.capitalize}"
      end
    end
    puts "\n===Your hand==="
    player.cards.each do |card|
      puts "#{card.name.capitalize} of #{card.suit.capitalize}"
    end

    dealer_aces_as_one_value = 0
    dealer.cards.each do |card|
      case card.name
      when :ace
        dealer_aces_as_one_value += 1
      else
        dealer_aces_as_one_value += card.value
      end
    end
    player_aces_as_one_value = 0
    player.cards.each do |card|
      case card.name
      when :ace
        player_aces_as_one_value += 1
      else
        player_aces_as_one_value += card.value
      end
    end

    if !player_turn
      if dealer.cards.select{|card| card.name == :ace}.size > 0 && dealer_aces_as_one_value <= 10 && dealer.value < 17
        puts "\n-Dealer has #{dealer_aces_as_one_value} or #{dealer.value}"
      else
        puts "\n-Dealer has #{dealer.value}"
      end
    else
      if dealer.cards[0].name == :ace
        puts "\n-Dealer showing Ace"
      else
        puts "\n-Dealer showing #{dealer.cards[0].value}"
      end
    end

    if player.cards.select{|card| card.name == :ace}.size > 0 && player_aces_as_one_value <= 10 && player_turn
      puts "\n-You have #{player_aces_as_one_value} or #{player.value}"
    else
      puts "-You have #{player.value}"
    end
  end

  def print_results
    if dealer.value > 21
      puts "You win!"
    elsif player.value > 21
      puts "You lose!"
    elsif dealer.value > player.value
      puts "You lose!"
    elsif dealer.value < player.value
      puts "You win!"
    elsif dealer.value == player.value
      puts "Push"
    end
  end

  def end_game
    print "\nPlay again? Y or N? "
    play = gets.chomp.downcase
    case play
    when "y"
      Game.new
    when "n"
      exit
    else
      puts "Invalid response"
      end_game
    end
  end
end

class Simulation
  attr_accessor :player, :dealer, :deck, :player_turn

  def initialize
    @player = Hand.new
    @dealer = Hand.new
    @deck = Deck.new
    @player_turn = true
    run_simulation
  end

  def run_simulation
    initial_deal
    while player_turn
      if player.value == 21
        @player_turn = false
        puts "\nHit enter to continue"
        gets.chomp
        finish_dealer
        break
      end
      if (player.value < 17 && player.value < dealer.cards[0].value + 10)
        puts "\nHit enter to continue"
        gets.chomp
        hit(player)
      else
        puts "\nYou stay"
        puts "\nHit enter to continue"
        gets.chomp
        @player_turn = false
        finish_dealer
      end
    end
    print_results
    end_game
  end

  private

  def initial_deal
    2.times do
      player.cards << deck.deal_card
      dealer.cards << deck.deal_card
    end
    print_update
    check_blackjack(dealer)
    check_blackjack(player)
  end

  def check_blackjack(hand)
    if((hand.cards.first.value == 10 && hand.cards.last.name == :ace) || (hand.cards.first.name == :ace && hand.cards.last.value == 10))
      @player_turn = false
      print_update
      if hand == dealer
        puts "Dealer has blackjack, you lose!"
      else
        puts "You have blackjack, you win!"
      end
      end_game
    end
  end

  def hit(hand)
    new_card = deck.deal_card
    hand.cards << new_card
    if hand == player
      puts "\nYou were dealt the #{new_card.name.capitalize} of #{new_card.suit.capitalize}..."
      print_update
      if player.value > 21
        puts "\nYou bust"
        @player_turn = false
      end
    end
    if hand == dealer
      puts "\nThe dealer was dealt the #{new_card.name.capitalize} of #{new_card.suit.capitalize}..."
      print_update
      if dealer.value > 21
        puts "\nDealer busts"
      end
    end
  end

  def finish_dealer
    print_update
    puts "\nHit enter to continue"
    gets.chomp
    while dealer.value < 17
      hit(dealer)
      puts "\nHit enter to continue"
      gets.chomp
    end
  end

  def print_update
    puts "\n===Dealer's hand==="
    if player_turn
      puts "#{dealer.cards[0].name.capitalize} of #{dealer.cards[0].suit.capitalize}"
      puts "?Hole Card?"
    else
      dealer.cards.each do |card|
        puts "#{card.name.capitalize} of #{card.suit.capitalize}"
      end
    end
    puts "\n===Your hand==="
    player.cards.each do |card|
      puts "#{card.name.capitalize} of #{card.suit.capitalize}"
    end

    dealer_aces_as_one_value = 0
    dealer.cards.each do |card|
      case card.name
      when :ace
        dealer_aces_as_one_value += 1
      else
        dealer_aces_as_one_value += card.value
      end
    end
    player_aces_as_one_value = 0
    player.cards.each do |card|
      case card.name
      when :ace
        player_aces_as_one_value += 1
      else
        player_aces_as_one_value += card.value
      end
    end

    if !player_turn
      if dealer.cards.select{|card| card.name == :ace}.size > 0 && dealer_aces_as_one_value <= 10 && dealer.value < 17
        puts "\n-Dealer has #{dealer_aces_as_one_value} or #{dealer.value}"
      else
        puts "\n-Dealer has #{dealer.value}"
      end
    else
      if dealer.cards[0].name == :ace
        puts "\n-Dealer showing Ace"
      else
        puts "\n-Dealer showing #{dealer.cards[0].value}"
      end
    end

    if player.cards.select{|card| card.name == :ace}.size > 0 && player_aces_as_one_value <= 10 && player_turn
      puts "\n-You have #{player_aces_as_one_value} or #{player.value}"
    else
      puts "-You have #{player.value}"
    end
  end

  def print_results
    if dealer.value > 21
      puts "You win!"
    elsif player.value > 21
      puts "You lose!"
    elsif dealer.value > player.value
      puts "You lose!"
    elsif dealer.value < player.value
      puts "You win!"
    elsif dealer.value == player.value
      puts "Push"
    end
  end

  def end_game
    print "\nPlay again? Y or N? "
    play = gets.chomp.downcase
    case play
    when "y"
      Simulation.new
    when "n"
      exit
    else
      puts "Invalid response"
      end_game
    end
  end
end

Game.new

# Simulation.new

require 'test/unit'

class CardTest < Test::Unit::TestCase
  def setup
    @card = Card.new(:hearts, :ten, 10)
  end

  def test_card_suit_is_correct
    assert_equal @card.suit, :hearts
  end

  def test_card_name_is_correct
    assert_equal @card.name, :ten
  end
  def test_card_value_is_correct
    assert_equal @card.value, 10
  end
end

class DeckTest < Test::Unit::TestCase
  def setup
    @deck = Deck.new
  end

  def test_new_deck_has_52_playable_cards
    assert_equal @deck.playable_cards.size, 52
  end

  def test_dealt_card_should_not_be_included_in_playable_cards
    card = @deck.deal_card
    assert_equal @deck.playable_cards.include?(card), false
  end

  def test_shuffled_deck_has_52_playable_cards
    @deck.shuffle
    assert_equal @deck.playable_cards.size, 52
  end
end
