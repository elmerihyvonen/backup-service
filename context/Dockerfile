FROM mysql:8-debian

#Install Cron
RUN apt-get update && apt-get upgrade -y
RUN apt-get install -y cron \
    nano
RUN apt-get install dos2unix
RUN apt-get install ncftp
RUN apt-get install -y expect

# AWS Cli + S3 Object Storage config + wget & unzip

RUN apt-get install unzip
ADD wgetinstall.sh /opt
RUN dos2unix /opt/wgetinstall.sh
RUN chmod +x /opt/wgetinstall.sh
RUN ./opt/wgetinstall.sh
RUN wget "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip"
RUN unzip awscli-exe-linux-x86_64.zip
RUN ./aws/install

ADD setup.sh /opt
ADD aws_setup.sh /opt
RUN dos2unix /opt/aws_setup.sh
RUN chmod +x /opt/aws_setup.sh
RUN dos2unix /opt/setup.sh
RUN chmod +x /opt/setup.sh
# RUN ./opt/setup.sh

ADD lifecycle-policy.json /

# Add the cron job
ADD dumpcron /etc/cron.d/dump-cron

# Add dump script and give execution rights
ADD dump.sh /opt/dump.sh
RUN dos2unix /opt/dump.sh
RUN dos2unix /etc/cron.d/dump-cron
RUN chmod +x /opt/dump.sh

ADD tar.sh /opt
RUN dos2unix /opt/tar.sh
RUN chmod +x /opt/tar.sh

ADD mysql_config_editor.sh /opt
RUN dos2unix /opt/mysql_config_editor.sh
RUN chmod +x /opt/mysql_config_editor.sh
# RUN ./opt/mysql_config_editor.sh

ADD set_loginpath.sh /opt
RUN dos2unix /opt/set_loginpath.sh
RUN chmod +x /opt/set_loginpath.sh

# Give execution rights on the cron job
RUN chmod 0744 /etc/cron.d/dump-cron

# Create the log file to be able to run tail
RUN touch /var/log/cron.log

# Run the command on container startup
CMD cron && tail -f /var/log/cron.log