require "sinatra"

use Rack::Session::Cookie, {
  secret: "keep_it_secret_keep_it_safe"
}

@choices = %w(r p s)
@human_score = 0
@computer_score = 0


def get_computer_choice
  @choices[rand(3)]
end

def display_choice(player, choice)
  shape = ""
  shape += player.concat(" chose rock.") if choice.start_with?("r")
  shape += player.concat(" chose paper.") if choice.start_with?("p")
  shape += player.concat(" chose scissors.") if choice.start_with?("s")
  shape
end

def display_scoreboard
  "Player Score: #{@human_score}, Computer Score: #{@computer_score}"
end

def rock_beats_scissors(winner)
"Rock beats scissors"
end

def paper_beats_rock(winner)
  "Paper beats rock, #{winner} wins the round."
end

def scissors_beats_paper(winner)
  "Scissors beats paper, #{winner} wins the round."
end

def update_human_score
  session[:human_score] += 1
end

def update_computer_score
  session[:computer_score] += 1
end

def determine_winner(player_choice, computer_choice)
  if player_choice == computer_choice
    "Tie, choose again."
  elsif player_choice == "r" && computer_choice == "s"
    update_human_score
    rock_beats_paper("player")
  elsif player_choice == "p" && computer_choice == "r"
    paper_beats_rock("player")
    update_human_score
  elsif player_choice == "s" && computer_choice == "p"
    scissors_beats_paper("player")
    update_human_score
  elsif computer_choice == "r" && player_choice == "s"
    rock_beats_paper("computer")
    update_computer_score
  elsif computer_choice == "p" && player_choice == "r"
    paper_beats_rock("computer")
    update_computer_score
  else
    scissors_beats_paper("computer")
    update_computer_score
  end
end

def play_round(player_choice, computer_choice)
  puts display_choice("Player", player_choice)
  puts display_choice("Computer", computer_choice)
  puts determine_winner(player_choice, computer_choice)
end

# Start the game. Good luck!
loop do
  puts display_scoreboard
  play_round(human_choice, computer_choice)
  print "Player wins!" if @human_score == 2
  print "Computer wins!" if @computer_score == 2
  puts
  break if @human_score == 2 || @computer_score == 2
end

get "/" do
  game_summary = nil
  if session[:visit_count].nil?
    session[:player_score] = 0
    session[:computer_score] = 0
    visit_count = 1

    welcome = "Welcome to Rock, Paper, Scissors! Here\'s how to play."
  else
    visit_count = session[:visit_count].to_i
    welcome = "Welcome back!"
  end
  session[:visit_count] = visit_count + 1

  erb :index, locals: {
    welcome: welcome,
    player_score: session[:player_score],
    computer_score: session[:computer_score],
    game_summary: game_summary
  }
end

def method_name

end


post "/" do

end
