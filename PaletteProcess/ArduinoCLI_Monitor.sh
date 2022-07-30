date="date +%d.%m.%Y"
hour="date +%H.%M.%S"

tempPath="/tmp/ArduinoCLI"
commandPath="$tempPath/output"
logPath="{fileDirAbsPath}/Logs/$($date)"

if [ ! -d "$tempPath" ]
then
  mkdir -p "$tempPath"
fi

if [ ! -d "$commandPath" ]
then
  mkdir -p "$commandPath"
fi

if [ ! -d "$logPath" ]
then
  mkdir -p "$logPath"
fi

logFile="$logPath/$($date) - $($hour)BUILD_$(echo -e "{LogLevel}" | tr a-z A-Z).txt"
compileOutput="$commandPath/BUILD.txt"

arduino-cli compile "{fileDirAbsPath}/" --upload --fqbn {ArduinoBoard} --port {ArduinoPort} --warnings {WarningLevel} --log-level {LogLevel} --log-format 'json' --log-file "$logFile" --no-color --format 'json' > "$compileOutput"

stdout=$(cat $compileOutput | jq -r '.compiler_out')
stderr=$(cat $compileOutput | jq -r '.compiler_err')
stdoutCompileSucess=$(cat $compileOutput | jq -r '.success')

stdoutProgramStorage=$(cat $compileOutput | jq -r '.compiler_out' | sed -n '1 p')
stdoutDinamicMemory=$(cat $compileOutput | jq -r '.compiler_out' | sed -n '2 p')

if [ $stdoutCompileSucess == true ]; then
  echo -e "\n============================================================ ARDUINO-CLI COMPILE STDOUT ============================================================" >> "$logFile"
  echo -e "$stdout" >> "$logFile"
  echo -e " \n[PROGRAM STORAGE]\n$stdoutProgramStorage"
  echo -e " \n\n[DINAMIC MEMORY]\n$stdoutDinamicMemory"
  if [ ! -z "$stderr" ]; then
    echo -e "\n============================================================ ARDUINO-CLI COMPILE WARNINGS ============================================================" >> "$logFile"
    echo -e "$stderr" >> "$logFile"
    echo -e " \n\n\n[WARNINGS]\n$stderr"
  fi
elif [ $stdoutCompileSucess == false ]; then
  if [ ! -z "$stderr" ]; then
    echo -e "\n============================================================ ARDUINO-CLI COMPILE STDERR ============================================================" >> "$logFile"
    echo -e "$stderr" >> "$logFile"
    echo -e " \n\n\n[EXIT CODE]\n$stderr" >&2
    false 1
  fi
fi
## Code finish
