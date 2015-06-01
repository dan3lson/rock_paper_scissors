require "sinatra"
require "pry"

use Rack::Session::Cookie, {
  secret: "keep_it_secret_keep_it_safe"
}


def get_computer_choice
  choice = rand(3)
  if choice ==1
    choice = "r"
  elsif choice == 2
    choice = "s"
  else
    choice = "p"
  end
  choice
end

def rock_beats_scissors(rock_chooser, scissors_chooser)
"#{rock_chooser} chose rock, #{scissors_chooser} chose scissors. Rock beats scissors"
end

def paper_beats_rock(paper_chooser, rock_chooser)
  "#{paper_chooser} chose paper, #{rock_chooser} chose rock. Paper beats rock"
end

def scissors_beats_paper(scissors_chooser, paper_chooser)
  "#{scissors_chooser} chose scissors, #{paper_chooser} chose paper. Scissors beats paper"
end

def update_human_score
  session[:player_score] += 1
end

def update_computer_score
  session[:computer_score] += 1
end

def determine_winner(player_choice, computer_choice)
  return_game_info = []
  if player_choice == computer_choice
    return_game_info << "Tie, choose again."
    return_game_info << "Nobody"
  elsif player_choice == "r" && computer_choice == "s"
    return_game_info << rock_beats_scissors("Player", "Computer")
    return_game_info << "Player"
  elsif player_choice == "p" && computer_choice == "r"
    return_game_info << paper_beats_rock("Player", "Computer")
    return_game_info << "Player"
  elsif player_choice == "s" && computer_choice == "p"
    return_game_info << scissors_beats_paper("Player", "Computer")
    return_game_info << "Player"
  elsif computer_choice == "r" && player_choice == "s"
    return_game_info << rock_beats_scissors("Computer", "Player")
    return_game_info << "Computer"
  elsif computer_choice == "p" && player_choice == "r"
    return_game_info << paper_beats_rock("Computer", "Player")
    return_game_info << "Computer"
  else
    return_game_info << scissors_beats_paper("Computer", "Player")
    return_game_info << "Computer"
  end
  if return_game_info[1] == "Player"
    update_human_score
  elsif return_game_info[1] == "Computer"
    update_computer_score
  end
  return_game_info
end

def play_game
  player_choice = params[:player_choice]
  computer_choice = get_computer_choice
  determine_winner(player_choice, computer_choice)
end


def clear_game
  session[:player_score] = 0
  session[:computer_score] = 0
  session[:result] = nil
  session[:summary] = nil
end

def announce_winner
  if session[:player_score] > 1
    game_result = "Player has won the game!"
  elsif session[:computer_score] > 1
    game_result = "Computer has won the game!"
  else
    game_result = nil
  end
  game_result
end

get "/clear" do
  clear_game
  redirect "/"
end

get "/" do
  if session[:have_visited].nil?
    session[:have_visited] = true
    welcome = "Welcome to Rock, Paper, Scissors! Pick which hand you'd like to play."
  else
    welcome = "Welcome back! Pick a hand, any hand"
    session[:player_score] ||= 0
    session[:computer_score] ||= 0
  end
  if_winner = announce_winner
  erb :index, locals: {
    welcome: welcome,
    player_score: session[:player_score],
    computer_score: session[:computer_score],
    summary: session[:summary],
    result: session[:result],
    game_result: if_winner
  }
end

post "/" do
  game_info = play_game
  session[:summary] = game_info[0]
  session[:result] = game_info[1]
  redirect "/"
end
