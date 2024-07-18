#!/bin/bash
PSQL="psql --username=freecodecamp --dbname=salon -t -c"

# drop tables if they exist
# $PSQL "DROP TABLE IF EXISTS customers, appointments, services"

# # create table function 
# CREATE_TABLE() {
#   $PSQL "CREATE TABLE $1()"
# }

# # create tables
# CREATE_TABLE customers
# CREATE_TABLE appointments
# CREATE_TABLE services

# # primary keys
# $PSQL "ALTER TABLE customers ADD COLUMN customer_id SERIAL PRIMARY KEY"
# $PSQL "ALTER TABLE appointments ADD COLUMN appointment_id SERIAL PRIMARY KEY"
# $PSQL "ALTER TABLE services ADD COLUMN service_id SERIAL PRIMARY KEY"

# # customers table
# $PSQL "ALTER TABLE customers ADD COLUMN  phone VARCHAR UNIQUE"
# $PSQL "ALTER TABLE customers ADD COLUMN name VARCHAR"

# # appointments table
# $PSQL "ALTER TABLE appointments ADD COLUMN customer_id INT"
# $PSQL "ALTER TABLE appointments ADD COLUMN service_id INT"
# $PSQL "ALTER TABLE appointments ADD COLUMN time VARCHAR"

# # services table
# $PSQL "ALTER TABLE services ADD COLUMN name VARCHAR"

# # foreign keys
# $PSQL "ALTER TABLE appointments ADD FOREIGN KEY(customer_id) REFERENCES customers(customer_id)"
# $PSQL "ALTER TABLE appointments ADD FOREIGN KEY(service_id) REFERENCES services(service_id)"

# $PSQL "INSERT INTO services(name) VALUES('cut'), ('color'), ('perm'), ('style'), ('trim')"

MAIN_MENU() {
  if [[ $1 ]]
    then
    echo -e "\n$1"
  fi
  # echo -e "\n~~Choose your service:~~\n"
SERVICE_OPTIONS=$($PSQL "SELECT * FROM services ORDER BY service_id")
echo "$SERVICE_OPTIONS" | while read SERVICE_ID BAR SERVICE
do
  echo "$SERVICE_ID) $SERVICE"
done
SELECT_SERVICE
return
}

SELECT_SERVICE() {
  # ask for service
  read SERVICE_ID_SELECTED
  # if service doesn't exist show same menu
  SERVICE_ID=$($PSQL "SELECT service_id FROM services WHERE service_id=$SERVICE_ID_SELECTED")
  if [[ -z $SERVICE_ID ]]
    then
    MAIN_MENU   
    return
  fi
  SERVICE_NAME=$($PSQL "SELECT name FROM services WHERE service_id=$SERVICE_ID_SELECTED" | sed -E 's/^ *| *$//g')
  # ask for phone number
  echo -e "\nEnter your phone number:"
  read CUSTOMER_PHONE
  CUSTOMER_NAME=$($PSQL "SELECT name FROM customers WHERE phone='$CUSTOMER_PHONE'" | sed -E 's/^ *| *$//g')
  if [[ -z $CUSTOMER_NAME ]]
    then
    # if no customer, enter into table, ask for name
    echo -e "\nEnter your name:"
    read CUSTOMER_NAME
    CUSTOMER_RESULT=$($PSQL "INSERT INTO customers(name, phone) VALUES('$CUSTOMER_NAME', '$CUSTOMER_PHONE')")
    CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone='$CUSTOMER_PHONE'")
    else 
    CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone='$CUSTOMER_PHONE'")
    CUSTOMER_NAME=$($PSQL "SELECT name FROM customers WHERE phone='$CUSTOMER_PHONE'" | sed -E 's/^ *| *$//g')
  fi
  echo -e "\nEnter the preferred time:"
  read SERVICE_TIME
  APPOINTMENT_RESULT=$($PSQL "INSERT INTO appointments(customer_id, service_id, time) VALUES($CUSTOMER_ID, $SERVICE_ID, '$SERVICE_TIME')")
  echo -e "\nI have put you down for a $SERVICE_NAME at $SERVICE_TIME, $CUSTOMER_NAME."
  return
}

MAIN_MENU