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

# required for python installation
sudo apt-get install -y make build-essential libssl-dev zlib1g-dev libbz2-dev \
libreadline-dev libsqlite3-dev llvm libncurses5-dev xz-utils tk-dev libffi-dev \
liblzma-dev libpq-dev python-openssl python3-dev

# setup pyenv
# Refer README.md for for more details
sudo su ubuntu -c "$(cat << EOF
    echo 'export PATH="/home/ubuntu/.pyenv/bin:/home/ubuntu/.pyenv/shims:\$PATH"' >> /home/ubuntu/.zshrc
    echo 'export PYENV_VERSION=${python_version}' >> /home/ubuntu/.zshrc
    source /home/ubuntu/.zshrc
    curl -L https://pyenv.run | bash
    eval "\$(pyenv init -)"
    pyenv update
    pyenv install ${python_version}
EOF
)"

# setup project
sudo ln -fs /usr/share/zoneinfo/Asia/Kolkata /etc/localtime
sudo dpkg-reconfigure --frontend noninteractive tzdata
sudo mkdir -p ${project_folder}
sudo chown -R ubuntu:ubuntu ${project_folder}
sudo su ubuntu -c "$(cat << EOF
    ssh-keyscan -H github.com >> /home/ubuntu/.ssh/known_hosts
    git clone -b ${git_branch_name} ${git_repo_url} ${project_folder}
    mv /tmp/local_settings.py ${project_folder}/src/config
    echo 'export DB_NAME="${db_name}"' >> ${project_folder}/src/config/.env
    echo 'export DB_USER="${db_user}"' >> ${project_folder}/src/config/.env
    echo 'export DB_PASSWORD="${db_password}"' >> ${project_folder}/src/config/.env
    echo 'export DB_HOST="${db_host}"' >> ${project_folder}/src/config/.env
    echo 'export DB_PORT="${db_port}"' >> ${project_folder}/src/config/.env
    mkdir -p ${project_folder}/logs
    mkdir -p ${project_folder}/static
    source /home/ubuntu/.zshrc
    cd ${project_folder}
    pip install -r requirements/base.txt
    python src/manage.py collectstatic --noinput
    python src/manage.py migrate
    python src/manage.py shell -c "from django.contrib.auth.models import User; User.objects.create_superuser('${admin_username}', '${admin_email}', '${admin_password}')"
EOF
)"

# setup supervisor
sudo apt-get install -y -q --no-remove supervisor
sudo mv /tmp/kb_gunicorn.conf /etc/supervisor/conf.d/
sudo supervisorctl update

# setup nginx
sudo apt-get install -y nginx
sudo mv /tmp/kb_nginx.conf /etc/nginx/sites-available/
sudo rm /etc/nginx/sites-enabled/default
sudo ln -s /etc/nginx/sites-available/kb_nginx.conf /etc/nginx/sites-enabled
PUBLIC_IP=$(curl http://169.254.169.254/latest/meta-data/public-ipv4)
PUBLIC_DNS=$(curl http://169.254.169.254/latest/meta-data/public-hostname)
sudo sed -i -e "s/PUBLIC_IP/\$PUBLIC_IP/g" /etc/nginx/sites-available/kb_nginx.conf
sudo sed -i -e "s/PUBLIC_DNS/\$PUBLIC_DNS/g" /etc/nginx/sites-available/kb_nginx.conf
sudo nginx -t
sudo service nginx reload
