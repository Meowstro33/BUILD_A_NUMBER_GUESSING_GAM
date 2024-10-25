#!/bin/bash

PSQL="psql --username=freecodecamp --dbname=number_guess -t --no-align -c"

RANDOM_NUMBER=$(( RANDOM % 1000 + 1 ))

echo "Enter your username:"
read USERNAME

USER_RESULT=$($PSQL "SELECT user_id, username, games_played, best_game FROM users WHERE username = '$USERNAME'")
GUESS_COUNT=1

if [[ -z $USER_RESULT ]]
then
  echo "Welcome, $USERNAME! It looks like this is your first time here."
  INSERT_USER=$($PSQL "INSERT INTO users (username, games_played) VALUES ('$USERNAME', 0)")
  
else
  IFS='|' read USER_ID USERNAME GAMES_PLAYED BEST_GAME <<< "$USER_RESULT"
  echo "Welcome back, $USERNAME! You have played $GAMES_PLAYED games, and your best game took $BEST_GAME guesses."
fi

GUESS_NUMBER() {
  
  read GUESS

  if [[ ! $GUESS =~ ^[0-9]+$ ]]
  then
    echo "That is not an integer, guess again:"
    GUESS_NUMBER
    return
  fi

  while [[ $GUESS -ne $RANDOM_NUMBER ]]
  do
    (( GUESS_COUNT++ ))

    if [[ $GUESS -lt $RANDOM_NUMBER ]]
    then
      echo "It's higher than that, guess again:"
    else
      echo "It's lower than that, guess again:"
    fi

    read GUESS
  done
}

echo "Guess the secret number between 1 and 1000:"
GUESS_NUMBER 

if [[ -n $BEST_GAME ]]
then
  NEW_BEST=$(( BEST_GAME < GUESS_COUNT ? BEST_GAME : GUESS_COUNT ))
  UPDATE_NEW_BEST=$($PSQL "UPDATE users SET best_game = $NEW_BEST, games_played = games_played + 1 WHERE username = '$USERNAME'")
else
  UPDATE_NEW_USER=$($PSQL "UPDATE users SET best_game = $GUESS_COUNT, games_played = 1 WHERE username = '$USERNAME'")
fi

echo "You guessed it in $GUESS_COUNT tries. The secret number was $RANDOM_NUMBER. Nice job!"
