Rails.application.routes.draw do
  get 'game', to: 'wordgame#game'
  get 'score', to: 'wordgame#score'
end
