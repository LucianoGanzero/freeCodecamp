#!/bin/bash

PSQL="psql -X --username=freecodecamp --dbname=salon --tuples-only -c"
echo -e "\n~~~~ MY SALON ~~~~\n"
  echo -e "Welcome to My Salon, how can i help you?\n"


MAIN_MENU(){
  if [[ $1 ]]
  then
    echo -e "\n$1\n"
  fi
  # get services
  SERVICES=$($PSQL "SELECT service_id, name FROM services ORDER BY service_id")
  # display services
  echo -e "$SERVICES" | while read SERVICE_ID BAR NAME
  do
    echo "$SERVICE_ID) $NAME"
  done
  # ask for service
  read SERVICE_ID_SELECTED
  # if input is not a number
  if [[ ! $SERVICE_ID_SELECTED =~ ^[0-9]+$ ]]
  then
    MAIN_MENU "That's not a valid option."
  else
    # check if service exists
    SERVICE_ID=$($PSQL "SELECT service_id FROM services WHERE service_id = $SERVICE_ID_SELECTED")
    # if doesn't exist
    if [[ -z $SERVICE_ID ]]
    then
      MAIN_MENU "Sorry, that service is not currently available."
    else
      # get service name
      SERVICE_NAME=$($PSQL "SELECT name FROM services WHERE service_id = $SERVICE_ID_SELECTED")
      # get costumers info
      echo -e "\nWhat's your phone number?"
      read CUSTOMER_PHONE
      CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone = '$CUSTOMER_PHONE'")

      # if is not registered
      if [[ -z $CUSTOMER_ID ]]
      then
        # get customers name
        echo -e "\nI dont have a record for that phone number. What's your name?"
        read CUSTOMER_NAME
        # insert new customer
        CUSTOMER_RESULT=$($PSQL "INSERT INTO customers(phone, name) VALUES ('$CUSTOMER_PHONE', '$CUSTOMER_NAME')")
        # get customer id
        CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone='$CUSTOMER_PHONE'")
      fi
      # get name
      CUSTOMER_NAME=$($PSQL "SELECT name FROM customers WHERE phone = '$CUSTOMER_PHONE'")
      # get time
      echo -e "What time would you like your $(echo $SERVICE_NAME | sed -r 's/^ *| *$//g'), $(echo $CUSTOMER_NAME | sed -r 's/^ *| *$//g')?"
      read SERVICE_TIME
      # make appointment
      APPOINTMENT_RESULT=$($PSQL "INSERT INTO appointments(customer_id, service_id, time) VALUES($CUSTOMER_ID, $SERVICE_ID_SELECTED, '$SERVICE_TIME')")
      # message
      echo -e "I have put you down for a $(echo $SERVICE_NAME | sed -r 's/^ *| *$//g') at $SERVICE_TIME, $(echo $CUSTOMER_NAME | sed -r 's/^ *| *$//g')."
    fi
  fi

}

MAIN_MENU