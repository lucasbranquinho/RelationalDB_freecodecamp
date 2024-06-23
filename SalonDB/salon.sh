#!/bin/bash

PSQL="psql -X --username=freecodecamp --dbname=salon --tuples-only -c"

echo -e "\n~~BeautySpot Salon~~\n"
echo -e "Hi! Welcome to our Salon. How may I help you today?\n"

SERVICE_MENU(){
  if [[ $1 ]]
  then
    echo -e "\n$1"
  fi

  SERVICES_LIST=$($PSQL "SELECT * FROM services;")
  echo "$SERVICES_LIST" | while read SERVICE_ID BAR SERVICE_NAME
  do
    echo -e "$SERVICE_ID) $SERVICE_NAME"
  done

  read SERVICE_ID_SELECTED
}

GET_PHONE_NUMBER(){
  echo -e "\nWhat's your phone number?"
  read CUSTOMER_PHONE
}
SERVICE_MENU

SERVICE_SELECTED=$($PSQL "SELECT name FROM services WHERE service_id = '$SERVICE_ID_SELECTED'")

while [[ -z $SERVICE_SELECTED ]]
do
  SERVICE_MENU "I could not find that service. What would you like today?\n"
  SERVICE_SELECTED=$($PSQL "SELECT name FROM services WHERE service_id = '$SERVICE_ID_SELECTED'")
done

SERVICE_FORMATTED=$(echo $SERVICE_SELECTED | sed 's/ //g')

GET_PHONE_NUMBER

CUSTOMER_NAME=$($PSQL "SELECT name FROM customers WHERE phone='$CUSTOMER_PHONE'")

if [[ -z $CUSTOMER_NAME ]]
then
  echo -e "\nI don't have a record for that phone number, what's your name?"
  read CUSTOMER_NAME
  INSERT_NEW_CUSTOMER=$($PSQL "INSERT INTO customers(phone, name) VALUES('$CUSTOMER_PHONE', '$CUSTOMER_NAME')")
  CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE name='$CUSTOMER_NAME'")
  echo -e "\nWhat time would you like your $SERVICE_FORMATTED, $CUSTOMER_NAME?"
else
  CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE name='$CUSTOMER_NAME'")
  echo -e "\nWhat time would you like your $SERVICE_FORMATTED, $CUSTOMER_NAME?"
fi

read SERVICE_TIME

INSERT_APPOINTMENT=$($PSQL "INSERT INTO appointments(customer_id, service_id, time) VALUES('$CUSTOMER_ID', '$SERVICE_ID_SELECTED', '$SERVICE_TIME')")

echo -e "\nI have put you down for a $SERVICE_FORMATTED at $SERVICE_TIME, $CUSTOMER_NAME."




