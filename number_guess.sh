#!/bin/bash

PSQL="psql --username=freecodecamp --dbname=number_guess -t --no-align -c"

echo "Enter your username:"
read USERNAME

PLAYER_ROW=$($PSQL "SELECT username, games_played, best_game FROM players WHERE username='$USERNAME'")

if [[ -z $PLAYER_ROW ]]
then
  $PSQL "INSERT INTO players(username, games_played, best_game) VALUES('$USERNAME', 0, 0)" > /dev/null
  echo "Welcome, $USERNAME! It looks like this is your first time here."
else
  USERNAME_DB=$(echo $PLAYER_ROW | awk -F '|' '{print $1}' | xargs)
  GAMES_PLAYED=$(echo $PLAYER_ROW | awk -F '|' '{print $2}' | xargs)
  BEST_GAME=$(echo $PLAYER_ROW | awk -F '|' '{print $3}' | xargs)
  echo "Welcome back, $USERNAME_DB! You have played $GAMES_PLAYED games, and your best game took $BEST_GAME guesses."
fi

SECRET_NUMBER=$((RANDOM % 1000 + 1))
GUESS_COUNT=0

echo "Guess the secret number between 1 and 1000:"
read GUESS

while true
do
  if [[ ! $GUESS =~ ^[0-9]+$ ]]
  then
    echo "That is not an integer, guess again:"
    read GUESS
    continue
  fi

  GUESS_COUNT=$((GUESS_COUNT + 1))

  if [[ $GUESS -eq $SECRET_NUMBER ]]
  then
    break
  elif [[ $GUESS -lt $SECRET_NUMBER ]]
  then
    echo "It's higher than that, guess again:"
    read GUESS
  else
    echo "It's lower than that, guess again:"
    read GUESS
  fi
done

echo "You guessed it in $GUESS_COUNT tries. The secret number was $SECRET_NUMBER. Nice job!"

NEW_GAMES_PLAYED=$($PSQL "SELECT games_played FROM players WHERE username='$USERNAME'" | xargs)
NEW_GAMES_PLAYED=$((NEW_GAMES_PLAYED + 1))

CURRENT_BEST=$($PSQL "SELECT best_game FROM players WHERE username='$USERNAME'" | xargs)

if [[ $CURRENT_BEST -eq 0 || $GUESS_COUNT -lt $CURRENT_BEST ]]
then
  $PSQL "UPDATE players SET games_played=$NEW_GAMES_PLAYED, best_game=$GUESS_COUNT WHERE username='$USERNAME'" > /dev/null
else
  $PSQL "UPDATE players SET games_played=$NEW_GAMES_PLAYED WHERE username='$USERNAME'" > /dev/null
fi
# username validation and welcome logic
# guessing loop logic
# integer validation
# update stats
