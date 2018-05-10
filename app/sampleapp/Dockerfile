FROM ruby
RUN mkdir -p /app
WORKDIR /app/
RUN git clone https://github.com/rainc/rubyapp
RUN rm -rf /app/rubyapp/Gemfile.lock
WORKDIR /app/rubyapp
RUN bundle install
CMD rackup -p 4567