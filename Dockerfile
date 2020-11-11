FROM ubuntu:16.04
RUN apt update

RUN apt install -y python-pip sudo apt-transport-https wget lsb-release sudo gnupg 

RUN wget -qO - https://packages.irods.org/irods-signing-key.asc | apt-key add -; \
    echo "deb [arch=amd64] https://packages.irods.org/apt/ $(lsb_release -sc) main" | tee /etc/apt/sources.list.d/renci-irods.list; \
    wget -qO - https://core-dev.irods.org/irods-core-dev-signing-key.asc | apt-key add -; \
    echo "deb [arch=amd64] https://core-dev.irods.org/apt/ $(lsb_release -sc) main" | tee /etc/apt/sources.list.d/renci-irods-core-dev.list; \
    apt-get update

RUN  apt-get install -y irods-database-plugin-postgres
RUN  apt-get install -y postgresql
ADD  ICAT.sql /
SHELL [ "/bin/bash", "-c" ]
RUN  service postgresql start ; su - postgres -c "psql -f /ICAT.sql" ;\
     python /var/lib/irods/scripts/setup_irods.py </var/lib/irods/packaging/lo*  # must have an irods user
RUN  /bin/echo -e "#!/bin/bash\n service postgresql start\n su - postgres -c 'dropdb ICAT ; createdb ICAT'\n python /var/lib/irods/scripts/setup_irods.py </var/lib/irods/packaging/lo*" \
     >/runtime_irods_reinstall.sh ; chmod +x /runtime_irods_reinstall.sh 

ARG  SETTING_PRC_COMMITISH="227-228-zone_user"
RUN  apt install git virtualenv -y
WORKDIR /var/lib/irods
USER irods
RUN  git clone http://github.com/d-w-moore/python-irodsclient
RUN  cd python-irodsclient ;  git checkout "${SETTING_PRC_COMMITISH}"
# -- Ubuntu 16.04 installation won't work without this:
RUN  pip install --upgrade pip
RUN  cd /var/lib/irods/python-irodsclient; pip install --user .
WORKDIR /root
USER root
RUN  apt install -y tmux
#    apt-get install -y 'irods-externals*' irods-runtime=4.2.8 irods-icommands=4.2.8 irods-server=4.2.8 irods-database-plugin-postgres=4.2.8

