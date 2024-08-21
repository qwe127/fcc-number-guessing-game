#!/bin/bash

PSQL="psql --username=freecodecamp --dbname=number_guess -t --no-align -c"
NUMBER=$(( $RANDOM % 1000 + 1 ))

NUMBER_GUESS(){  
  echo "Enter your username:"
  read USERNAME

  USERNAME_QUERY=$($PSQL "SELECT DISTINCT(username) FROM users WHERE '$USERNAME' = username")
  BEST_GAME=$($PSQL "SELECT MIN(guesses) FROM games FULL JOIN users USING(user_id) WHERE '$USERNAME' = username")
  GAMES_PLAYED=$($PSQL "SELECT COUNT(*) FROM games FULL JOIN users USING(user_id) WHERE '$USERNAME' = username")
  
  if [[ -z $USERNAME_QUERY ]]
  then
    echo "Welcome, $USERNAME! It looks like this is your first time here."
  else
    echo "Welcome back, $USERNAME_QUERY! You have played $GAMES_PLAYED games, and your best game took $BEST_GAME guesses."
  fi
  
  echo "Guess the secret number between 1 and 1000:"
  GUESSES=1
  read GUESS
  
  while [ $GUESS != $NUMBER ]
  do
    if [[ ! $GUESS =~ ^[0-9]+$ ]]
    then
      echo "That is not an integer, guess again:"
      ((GUESSES++))
      read GUESS
    fi
    
    if [[ $GUESS > $NUMBER ]]
    then
      echo "It's lower than that, guess again:"
      ((GUESSES++))
      read GUESS
    
    elif [[ $GUESS < $NUMBER ]]
    then
      echo "It's higher than that, guess again:"
      ((GUESSES++))
      read GUESS
    fi
  done
  
  GET_USER_ID=$($PSQL "SELECT DISTINCT(user_id) FROM users WHERE username='$USERNAME'")
  if [[ -z $GET_USER_ID ]]
    then
      ADD_USER=$($PSQL "INSERT INTO users(username) VALUES('$USERNAME')")
    fi
  
  GET_NEW_USER_ID=$($PSQL "SELECT DISTINCT(user_id) FROM users WHERE username='$USERNAME'")
  ADD_GAME=$($PSQL "INSERT INTO games(user_id, guesses) VALUES($GET_NEW_USER_ID, $GUESSES)")
  
  echo "You guessed it in $GUESSES tries. The secret number was $NUMBER. Nice job!"
}

NUMBER_GUESS