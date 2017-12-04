#/bin/bash

check_mraa() {
  echo -e "     ${G}check_mraa...${NC}"
  return 1
}

install_mraa() {
  echo -e "     ${G}install_mraa...${NC}"
}

check_mraa
result=$?
if [[ $result -eq 1 ]]; then install_mraa; else echo -; fi
