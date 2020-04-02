FROM python

# Install apt-get packages
RUN apt-get update && \
    apt-get install -y curl apt-transport-https ca-certificates locales httpie python3-dev zip jq git \
                       software-properties-common apt-transport-https gnupg2 build-essential file

# Install docker
RUN curl -fsSL https://download.docker.com/linux/$(. /etc/os-release; echo "$ID")/gpg | apt-key add -
RUN add-apt-repository \
   "deb [arch=amd64] https://download.docker.com/linux/$(. /etc/os-release; echo "$ID") \
   $(lsb_release -cs) \
   stable"
RUN apt-get update && apt-get install -y docker-ce                 

# Install pip packages
RUN pip install awscli awsebcli cfn_flip jinja2-cli cfn-lint \
                chalice sceptre ssm-cache requests awsume

# Install aws cli v2
RUN curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip" && \
        unzip awscliv2.zip && \
        sudo ./aws/install

# Install ecs cli
RUN curl -o /usr/local/bin/ecs-cli https://s3.amazonaws.com/amazon-ecs-cli/ecs-cli-linux-amd64-latest && chmod +x /usr/local/bin/ecs-cli

# Install tfenv and terraform
RUN git clone https://github.com/Zordrak/tfenv.git /apps/tfenv && \
        ln -s /apps/tfenv/bin/* /usr/local/bin
RUN tfenv install 0.12.24

# Install Node, NPM, CDK
RUN curl -sL https://deb.nodesource.com/setup_13.x | bash -
RUN apt-get install -y nodejs
RUN npm install -g aws-cdk

# Install brew and brew packages
RUN localedef -i en_US -f UTF-8 en_US.UTF-8
RUN useradd -m -s /bin/bash linuxbrew && \
    echo 'linuxbrew ALL=(ALL) NOPASSWD:ALL' >>/etc/sudoers
USER linuxbrew
RUN sh -c "$(curl -fsSL https://raw.githubusercontent.com/Linuxbrew/install/master/install.sh)"
RUN test -d ~/.linuxbrew && \
    eval $(~/.linuxbrew/bin/brew shellenv) && \
    test -d /home/linuxbrew/.linuxbrew && \
    eval $(/home/linuxbrew/.linuxbrew/bin/brew shellenv) && \
    echo "eval \$($(brew --prefix)/bin/brew shellenv)" >>~/.profile && \
    brew tap aws/tap && \
    brew install aws-sam-cli aws-vault

USER root

WORKDIR /workdir
ENTRYPOINT /bin/bash