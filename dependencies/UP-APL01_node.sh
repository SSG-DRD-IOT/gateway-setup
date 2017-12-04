#/bin/bash

check_node() {
  echo -e "     ${G}check_node...${NC}"

  if [ ! -f "/home/upsquared/.nvm/v0.7.12/bin/node" ]; then
    return 0
  fi

  return 1
}

install_node() {
  echo -e "     ${G}install_node...${NC}"
  #wget -qO- https://raw.githubusercontent.com/creationix/nvm/v0.33.6/install.sh | bash
}

