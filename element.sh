#!/bin/bash

PSQL="psql --username=freecodecamp --dbname=periodic_table -t --no-align -c"

# select atomic number if input was a number
if [[ $1 =~ ^[0-9]+$ ]]
then
  ATOMIC_NUMBER=$($PSQL "select atomic_number from elements where atomic_number=$1;") 
# select atomic number if input was a string
elif [[ $1 =~ ^[a-zA-Z]+$ ]]
then
# the ilike keyword ensures the query is case insensitive 
# (e.g. an argument of 'c' or 'C' will both return the atomic number for carbon)
  ATOMIC_NUMBER=$($PSQL "select atomic_number from elements where symbol ilike '$1' or name ilike'$1';")
else
  echo Please provide an element as an argument.
  exit
fi

# checks that atomic number was selected
if [[ -z $ATOMIC_NUMBER ]]
then 
  echo "I could not find that element in the database."
else
  # extract relevant data from 'elements' table
  ELEMENT=$($PSQL "select symbol, name from elements where atomic_number=$ATOMIC_NUMBER;")
  IFS="|" read SYMBOL NAME <<< "$ELEMENT"

  # extract relevant data from 'properties' table
  ELEMENT_PROPERTIES=$($PSQL "select atomic_mass, melting_point_celsius, boiling_point_celsius, type_id from properties where atomic_number=$ATOMIC_NUMBER;")
  # <<< is a Bash "here string" operator. It is used to pass a string as input to a command. The double quotes are necessary to maintain the integrity of the string.
  IFS="|" read ATOMIC_MASS MELTING_POINT BOILING_POINT TYPE_ID <<< "$ELEMENT_PROPERTIES"

  # extract relevant data from 'types' table
  TYPE=$($PSQL "select type from types where type_id=$TYPE_ID;")
  
  # echo statement with facts about the element
  echo -e "The element with atomic number $ATOMIC_NUMBER is $NAME ($SYMBOL). It's a $TYPE, with a mass of $ATOMIC_MASS amu. $NAME has a melting point of $MELTING_POINT celsius and a boiling point of $BOILING_POINT celsius."
fi