set dotenv-load

gleam-day:
  #!/usr/bin/env sh
  export DAY_NUMBER=$(cat ./next_day || echo 1)
  export DAY_NUMBER_STRING=day$(printf %02d $DAY_NUMBER)
  mkdir resources/$DAY_NUMBER_STRING
  touch resources/$DAY_NUMBER_STRING/test_input.txt
  curl --cookie "session=${AOC_SESSION_COOKIE}" -o resources/$DAY_NUMBER_STRING/input.txt https://adventofcode.com/2024/day/$DAY_NUMBER/input
  cat code_templates/template.gleam.tpl | envsubst > src/$DAY_NUMBER_STRING.gleam
  cat code_templates/test_template.gleam.tpl | envsubst > test/${DAY_NUMBER_STRING}_test.gleam
  echo $(($DAY_NUMBER + 1)) > ./next_day
