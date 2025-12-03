# Function to check whether a file exists, exit if not
check_file_exists() {

  local filepathandname="$1"

  if [ -z "$filepathandname" ]; then
    printf "${RED}❌ No file path provided to check_file_exists. Exiting.${RESET}\n"
    exit 1
  fi

  if [ ! -f "$filepathandname" ]; then
    printf "${RED}❌ File '${filepathandname}' not found. Exiting.${RESET}\n"
    exit 1
  else
    printf "${GREEN}✅ File '${filepathandname}' found. Continue.${RESET}\n"
  fi

}
# Function to check whether a directory exists, exit if not
check_path_exists() {

  local filepath="$1"

  if [ -z "$filepath" ]; then
    printf "${RED}❌ No file path provided to check_file_exists. Exiting.${RESET}\n"
    exit 1
  fi

  if [ ! -d "$filepath" ]; then
    printf "${RED}❌ Path '${filepath}' not found. Exiting.${RESET}\n"
    exit 1
  else
    printf "${GREEN}✅ Path '${filepath}' found. Continue.${RESET}\n"
  fi
}

# Function to see if software is installed
check_tool() {
    if command -v "$1" >/dev/null 2>&1; then
        printf "${GREEN}✅ $1 is installed. Version: $($1 --version | head -n 1)${RESET}\n"
    else
        printf "${RED}❌ $1 is NOT installed. Exiting${RESET}\n"
        exit 1
    fi
}