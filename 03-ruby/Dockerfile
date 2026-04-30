FROM ruby:4.0.2

# SQLite depoendencies
RUN apt-get update -qq && apt-get install -y \
    wget \
    gnupg \
    unzip \
    sqlite3 \
    libsqlite3-dev \
    && rm -rf /var/lib/apt/lists/*

# Google Chrome for Selenium
RUN wget -q -O - https://dl-ssl.google.com/linux/linux_signing_key.pub | gpg --dearmor -o /usr/share/keyrings/google-chrome.gpg \
    && echo "deb [arch=amd64 signed-by=/usr/share/keyrings/google-chrome.gpg] http://dl.google.com/linux/chrome/deb/ stable main" > /etc/apt/sources.list.d/google-chrome.list \
    && apt-get update -qq \
    && apt-get install -y google-chrome-stable \
    && rm -rf /var/lib/apt/lists/*

# set working directory in the container
WORKDIR /app

# copy gemfile.lock only if exists and the script
COPY crawler.rb Gemfile Gemfile.lock* ./

# install gem dependencies
RUN bundle install

# make the folder
RUN mkdir -p /app/db

# run with arguments
ENTRYPOINT ["ruby", "crawler.rb"]