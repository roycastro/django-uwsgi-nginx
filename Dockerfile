# Copyright 2013 Thatcher Peskens
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#    http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

FROM debian:latest

MAINTAINER roycastro
RUN echo "root:root" | chpasswd
RUN useradd -ms /bin/bash sshuser


# Install required packages and remove the apt packages cache when done.
RUN apt-get update && \
    apt-get upgrade -y && \ 	
    apt-get install -y \
    	build-essential \
	libncurses5-dev libncursesw5-dev libreadline6-dev \
	libdb-dev libgdbm-dev libsqlite3-dev libssl-dev \
	libbz2-dev libexpat1-dev liblzma-dev zlib1g-dev \
	libxml2-dev libxslt-dev \
    	wget \
	git \
	python3 \
	python3-dev \
	python3-setuptools \
	python3-pip \
	libpq-dev \
	nginx \
	supervisor \
	openssh-server \
	sqlite3 && \
	pip3 install -U pip setuptools && \
   	rm -rf /var/lib/apt/lists/*

RUN wget --quiet -O - https://www.postgresql.org/media/keys/ACCC4CF8.asc | apt-key add - \
 && echo 'deb http://apt.postgresql.org/pub/repos/apt/ trusty-pgdg main' > /etc/apt/sources.list.d/pgdg.list \
 && apt-get update \
 && DEBIAN_FRONTEND=noninteractive apt-get install -y acl \
 postgresql postgresql-client postgresql-contrib \
 && rm -rf /var/lib/apt/lists/*

RUN pip install -U pip 
RUN pip3 install -U pip 

# install uwsgi now because it takes a little while
RUN pip3 install uwsgi
RUN pip3 install --upgrade setuptools
RUN pip install --upgrade setuptools
RUN pip install ez_setup

# setup all the configfiles
RUN echo "daemon off;" >> /etc/nginx/nginx.conf
COPY nginx-app.conf /etc/nginx/sites-available/default
COPY supervisor-app.conf /etc/supervisor/conf.d/

# COPY requirements.txt and RUN pip install BEFORE adding the rest of your code, this will cause Docker's caching mechanism
# to prevent re-installing (all your) dependencies when you made a change a line or two in your app.

COPY app/requirements.txt /home/docker/code/app/
RUN pip3 install -r /home/docker/code/app/requirements.txt

# add (the rest of) our code
#COPY . /home/docker/code/

# install django, normally you would remove this step because your project would already
# be installed in the code/app/ directory
#RUN django-admin.py startproject website /home/docker/code/app/

EXPOSE 80
EXPOSE 22
RUN echo "sshuser:root" | chpasswd
#CMD ["supervisord", "-n"]
