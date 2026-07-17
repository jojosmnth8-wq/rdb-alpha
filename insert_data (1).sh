#!/bin/bash

if [[ $1 == "test" ]]
then
  PSQL="psql --username=postgres --dbname=worldcuptest -t --no-align -c"
else
  PSQL="psql --username=freecodecamp --dbname=worldcup -t --no-align -c"
fi

# Empty tables
echo "$($PSQL "TRUNCATE TABLE games, teams RESTART IDENTITY;")"

# Read data from CSV
cat games.csv | while IFS="," read YEAR ROUND WINNER OPPONENT WGOALS OGOALS
do
  # Skip header
  if [[ $YEAR != "year" ]]
  then
    # Get winner ID
    WINNER_ID=$($PSQL "SELECT team_id FROM teams WHERE name='$WINNER'")

    # Insert winner if not exists
    if [[ -z $WINNER_ID ]]
    then
      echo "Inserting team: $WINNER"
      $PSQL "INSERT INTO teams(name) VALUES('$WINNER')" > /dev/null
      WINNER_ID=$($PSQL "SELECT team_id FROM teams WHERE name='$WINNER'")
    fi

    # Get opponent ID
    OPPONENT_ID=$($PSQL "SELECT team_id FROM teams WHERE name='$OPPONENT'")

    # Insert opponent if not exists
    if [[ -z $OPPONENT_ID ]]
    then
      echo "Inserting team: $OPPONENT"
      $PSQL "INSERT INTO teams(name) VALUES('$OPPONENT')" > /dev/null
      OPPONENT_ID=$($PSQL "SELECT team_id FROM teams WHERE name='$OPPONENT'")
    fi

    # Insert game
    echo "Inserting game: $YEAR $ROUND"

    $PSQL "INSERT INTO games(year, round, winner_id, opponent_id, winner_goals, opponent_goals)
    VALUES($YEAR, '$ROUND', $WINNER_ID, $OPPONENT_ID, $WGOALS, $OGOALS)" > /dev/null
  fi
done

echo "Finished inserting data."