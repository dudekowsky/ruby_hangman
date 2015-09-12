require "yaml"

class Hangman

  def go(ai = false)
    @sought_word = choose_word
    @current_guess = "_" * @sought_word.length
    @lives_left = 10
    @letters_guessed = []
    @false_letters = []
    if ai == true
      return ai_start
    else
      start
    end
  end

  def ai_start
    possible_words = File.readlines("5desk.txt").map{|word| word.strip.downcase}.select{|word| word.length == @current_guess.length}
    until game_over?
      possible_words = sort_out(possible_words).uniq
       puts "already guessed letters: #{@letters_guessed}"
       puts "possible words: #{possible_words}"
       puts "current guess: #{@current_guess}"
      begin
      guess = possible_words.sample[rand(@current_guess.length)]
      end until @letters_guessed.include?(guess) == false
      puts "guessing: #{guess}"
      process_guess(guess)
    end
    puts "sought word was: #{@sought_word}"
    puts "guessed letters were: #{@letters_guessed}"
    puts "lives left: #{@lives_left}"
    if @current_guess == @sought_word
      puts "AI WON! AI UNBEATABLE!"
      return true
    else
      puts "AI LOST. AI WEAK!"
      return false
    end
  end

  def sort_out(possible_words_array)
    current_guess_array = @current_guess.split("")
    possible_words_array.select! do |entry|
      current_guess_array.each_with_index do |char,idx|
        if char == "_"
          true
        else
          if entry[idx] == char
            true
          else
            break
          end
        end
      end
    end
    possible_words_array.select! do |entry|
      @false_letters.each do |false_letter|
        if entry.include?(false_letter)
          false
          break
        else
          true
        end
      end
    end
    return possible_words_array
  end

  def choose_word
    File.readlines("5desk.txt").map{|word| word.strip}.select{|word| word.length >= 5 && word.length <= 12}.sample.downcase
  end

  def start
    welcome_message
    until game_over?
      show_lives_left
      show_current_guess
      show_letters_guessed
      ask_input
    end
    game_over_message
  end

  def game_over_message
    if @sought_word == @current_guess
      puts "You won! The word is: #{@current_guess}"
    else
      puts "You lost! The sought word was: #{@sought_word}"
    end
  end

  def welcome_message
    puts "Welcome to Hangman!"
    puts "You can save your current game at any time with \"save\" and load it with \"load\""
  end

  def game_over?
    unless @lives_left <= 0 || @current_guess == @sought_word
      false
    else
      true
    end
  end

  def show_lives_left
    puts "You have #{@lives_left} lives left!"
  end

  def show_current_guess
    puts "Your current guess is: #{@current_guess}"
  end

  def show_letters_guessed
    print "You already guessed: "
    @letters_guessed.each do |letter|
      print "#{letter}"
    end
    print "\n"
  end

  def save_game
    variables = {sought_word: @sought_word, current_guess: @current_guess, lives_left: @lives_left, letters_guessed: @letters_guessed}
    yaml = YAML::dump(variables)
    File.open("savegame.yaml", "w") do |file|
      file.puts(yaml)
    end
    puts "game saved!"
  end

  def load_game
    file = File.read("savegame.yaml")
    yaml = YAML::load(file)
    @sought_word = yaml[:sought_word]
    @current_guess = yaml[:current_guess]
    @lives_left = yaml[:lives_left]
    @letters_guessed = yaml[:letters_guessed]
    puts "File loaded!"
  end

  def ask_input
    puts "Guess a letter:"
    guess = gets.chomp
    if guess == "save"
      save_game
    elsif guess == "load"
      load_game
    else
      process_guess(guess[0])
    end
  end

  def process_guess(guess)
    if @sought_word.include?(guess) && !@letters_guessed.include?(guess)
      @sought_word.split("").each_with_index do |letter, index|
        @current_guess[index] = letter if letter == guess
      end
    else
      if @letters_guessed.include?(guess)
        puts "You already guessed this! 1 life lost :("
      else
        puts "Letter is not included! 1 life lost :("
        @false_letters << guess
      end
      @lives_left -= 1
    end
    @letters_guessed << guess
  end

end

if ARGV[0].to_s.downcase == "ai"
  ai = true
else
  ai = false
end
Hangman.new.go(ai)
