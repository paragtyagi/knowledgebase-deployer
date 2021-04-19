#!/bin/bash
set -e

# common
sudo apt-get update
sudo apt-get upgrade -y
sudo apt-get autoclean

# setup zsh
sudo apt-get install -y zsh
sudo su ubuntu -c "$(cat << EOF 
    ssh-keyscan -H github.com >> /home/ubuntu/.ssh/known_hosts
    git clone https://github.com/robbyrussell/oh-my-zsh.git /home/ubuntu/.oh-my-zsh
    cp /home/ubuntu/.oh-my-zsh/templates/zshrc.zsh-template /home/ubuntu/.zshrc
    echo DISABLE_AUTO_UPDATE="true" >> /home/ubuntu/.zshrc
    echo 'PROMPT="%%{\$fg_bold[black]%} %%{\$bg[yellow]%}${instance_name}%%{\$reset_color%} $${ret_status}%%{\$fg_bold[green]%}%p %%{\$fg[cyan]%}%c %%{\$fg_bold[blue]%}$(git_prompt_info)%%{\$fg_bold[blue]%} % %%{\$reset_color%}"' >> /home/ubuntu/.zshrc
    cp /home/ubuntu/.oh-my-zsh/themes/robbyrussell.zsh-theme /home/ubuntu/.oh-my-zsh/custom
EOF
)"
sudo chsh -s /bin/zsh ubuntu

# install postgresql
curl -sL "https://salsa.debian.org/postgresql/postgresql-common/raw/master/pgdg/apt.postgresql.org.sh" | sudo -E bash -
sudo apt-get install -y postgresql-${postgresql_version} postgresql-client-${postgresql_version}

# confs postgresql
sudo mv /tmp/postgresql.conf /etc/postgresql/${postgresql_version}/main/conf.d/postgresql.conf
sudo mv /tmp/pg_hba.conf /etc/postgresql/${postgresql_version}/main/pg_hba.conf
sudo chown postgres:postgres /etc/postgresql/${postgresql_version}/main/conf.d/postgresql.conf
sudo chown postgres:postgres /etc/postgresql/${postgresql_version}/main/pg_hba.conf

# enable autostart
sudo systemctl enable postgresql
sudo systemctl restart postgresql

# create user and DB
sudo su - postgres -c "psql -c 'CREATE USER ${db_user} NOSUPERUSER;'"
sudo su - postgres -c "psql -c 'CREATE DATABASE ${db_name} WITH OWNER ${db_user};'"
sudo su - postgres -c "psql -c \"ALTER USER ${db_user} WITH PASSWORD '${db_password}';\""
