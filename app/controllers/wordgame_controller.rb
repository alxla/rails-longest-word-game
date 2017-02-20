class WordgameController < ApplicationController
  def game
  @grid = generate_grid(9)
  @nb_of_games = params[:nb_of_games].to_i + 1
  end

  def score
    p params[:shot]
    p @nb_of_games = params[:nb_of_games].to_i
    p params[:grid]
    p DateTime.parse(params[:start_date].to_s)
    p Time.now
    @result = run_game(params[:shot], params[:grid], DateTime.parse(params[:start_date].to_s), Time.now)
  end

  private

  def generate_grid(grid_size)
    grid = []
    grid_size.times { |_x| grid << ('A'..'Z').to_a[rand(26)] }
    grid
  end

  def correct_english?(word_in_en, word_in_fr)
    word_in_en != word_in_fr
  end

  def in_the_grid?(word, grid)
    word.length <= grid.size
  end

  def in_french(word)
    url = "https://api-platform.systran.net/translation/text/translate?source=en&target=fr&key=5a7409a1-d27a-423b-98da-f763f35343af&input=#{word}"
    data_received = open(url).read
    data = JSON.parse(data_received)
    return data['outputs'][0]['output']
  end

  def grid_compliance(word, grid)
    compliant = 0
    test_grid = grid
    word.upcase.each_char do |letter|
      compliant = compliant && test_grid.include?(letter)
      test_grid.delete(letter)
    end
    compliant
  end

  def your_score_is(start_time, end_time, word_length)
    word_length / (end_time - start_time)
  end

  def run_game(attempt, grid, start_time, end_time)
    game_result = {}
    attempt_fr = in_french(attempt)

    if correct_english?(attempt, attempt_fr) && grid_compliance(attempt, grid)
      game_result[:score] = your_score_is(start_time, end_time, attempt.length)
      game_result[:message] = "well done"
      game_result[:translation] = attempt_fr
    elsif !grid_compliance(attempt, grid)
      game_result[:score] = 0
      game_result[:message] = "not in the grid"
      game_result[:translation] = attempt_fr
    else
      game_result[:score] = 0
      game_result[:translation] = nil
      game_result[:message] = "not an english word"
    end
    game_result[:time] = (end_time - start_time)
    return game_result
  end
end
