#! /bin/bash

if [[ $1 == "test" ]]
then
  PSQL="psql --username=postgres --dbname=worldcuptest -t --no-align -c"
else
  PSQL="psql --username=freecodecamp --dbname=worldcup -t --no-align -c"
fi

# Do not change code above this line. Use the PSQL variable above to query your database.
echo $($PSQL "TRUNCATE teams, games")

cat games.csv | while IFS=',' read YEAR ROUND WINNER OPPONENT WG OG
do
  if [[ $YEAR != 'year' ]]
  then


    #get winner id
    WINNER_ID=$($PSQL "SELECT team_id FROM teams WHERE name='$WINNER'")
    #IF NOT FOUND
    if [[ -z $WINNER_ID ]]
    then
      #insert team
      INSERT_WINNER_RESULT=$($PSQL "INSERT INTO teams(name) VALUES ('$WINNER')")
      if [[ $INSERT_WINNER_RESULT == "INSERT 0 1" ]]
      then
        echo Ganador insertado: $WINNER
      fi
      #get new winner id
      WINNER_ID=$($PSQL "SELECT team_id FROM teams WHERE name='$WINNER'")
    fi


    #get opponent id
    OPPONENT_ID=$($PSQL "SELECT team_id FROM teams WHERE name='$OPPONENT'")
    #IF NOT FOUND
    if [[ -z $OPPONENT_ID ]]
    then
      #insert team
      INSERT_OP_RESULT=$($PSQL "INSERT INTO teams(name) VALUES ('$OPPONENT')")
      if [[ $INSERT_OP_RESULT == "INSERT 0 1" ]]
      then
        echo Oponente insertado: $OPPONENT
      fi
      #get new winner id
      OPPONENT_ID=$($PSQL "SELECT team_id FROM teams WHERE name='$OPPONENT'")
    fi


    #Insertar partido

    INSERT_GAME=$($PSQL "INSERT INTO games(year, round, winner_goals, opponent_goals, winner_id, opponent_id) VALUES($YEAR, '$ROUND', $WG, $OG, $WINNER_ID, $OPPONENT_ID)")
    if [[ $INSERT_GAME=="INSERT 0 1" ]]
    then
      echo Juego insertado: $YEAR $ROUND $WINNER $OPPONENT $WG $OG
    fi
  fi
done