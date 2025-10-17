#!/usr/bin/env bash

PSQL="psql --username=freecodecamp --dbname=periodic_table -t --no-align -c"

if [[ -z $1 ]]; then
  echo "Please provide an element as an argument."
  exit 0
fi

INPUT="$1"

if [[ $INPUT =~ ^[0-9]+$ ]]; then
  CONDITION="e.atomic_number = $INPUT"
elif [[ $INPUT =~ ^[A-Za-z]{1,2}$ ]]; then
  CONDITION="e.symbol = INITCAP('$INPUT')"
else
  CONDITION="e.name = INITCAP('$INPUT')"
fi

RESULT=$($PSQL "
  SELECT e.atomic_number, e.name, e.symbol, t.type, p.atomic_mass, p.melting_point_celsius, p.boiling_point_celsius
  FROM elements e
  JOIN properties p USING(atomic_number)
  JOIN types t ON p.type_id = t.type_id
  WHERE $CONDITION;
")

if [[ -z $RESULT ]]; then
  echo "I could not find that element in the database."
  exit 0
fi

IFS='|' read -r AN NAME SYMBOL TYPE MASS MP BP <<< "$RESULT"
echo "The element with atomic number $AN is $NAME ($SYMBOL). It's a $TYPE, with a mass of $MASS amu. $NAME has a melting point of $MP celsius and a boiling point of $BP celsius."