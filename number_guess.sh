#!/bin/bash

PSQL="psql -X --username=freecodecamp --dbname=number_guess --tuples-only -c"

RANDOM_NUMBER=$(( RANDOM % 1000 + 1))

echo "Enter your username:"
read USERNAME

USER_ID=$($PSQL "SELECT user_id FROM users WHERE username='$USERNAME'")

# if you're a first-timer

if [[ -z $USER_ID ]]
then
  echo "Welcome, $USERNAME! It looks like this is your first time here."
  INSERT_USERNAME=$($PSQL "INSERT INTO users(username) VALUES('$USERNAME')")
  USER_ID=$($PSQL "SELECT user_id FROM users WHERE username='$USERNAME'")

# if you played some

else
  GAMES_PLAYED=$($PSQL "SELECT COUNT(*) FROM games WHERE user_id=$USER_ID")
  BEST_SCORE=$($PSQL "SELECT MIN(games_played) FROM games WHERE user_id=$USER_ID")
  echo "Welcome back, $USERNAME! You have played $GAMES_PLAYED games, and your best game took $BEST_SCORE guesses."
fi

echo "Guess the secret number between 1 and 1000:"

NUMBER_GUESS=0
COUNT=1

while [[ $NUMBER_GUESS != $RANDOM_NUMBER ]]
do
  read NUMBER_GUESS
  if [[ ! $NUMBER_GUESS =~ ^[0-9]+$ ]]
  then
    echo "That is not an integer, guess again:"
    continue
  else
    if [[ $NUMBER_GUESS > $RANDOM_NUMBER ]]
    then
      echo "It's lower than that, guess again:"
      (( COUNT++ ))
    elif [[ $NUMBER_GUESS < $RANDOM_NUMBER ]]
    then
      echo "It's higher than that, guess again:"
      (( COUNT++ ))
    fi
  fi
done
 
echo "You guessed it in $COUNT tries. The secret number was $RANDOM_NUMBER. Nice job!"
INSERT=$($PSQL "INSERT INTO games(user_id, games_played) VALUES($USER_ID,$COUNT)")
