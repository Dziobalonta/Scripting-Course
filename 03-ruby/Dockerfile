FROM ruby:4.0.2

# set working directory in the container
WORKDIR /app

# copy gemfile.lock only if exists
COPY crawler.rb Gemfile Gemfile.lock* ./

# install gem dependencies
RUN bundle install

# run the code
CMD ["ruby", "crawler.rb"]