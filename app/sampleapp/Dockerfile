FROM ruby
RUN mkdir -p /app
RUN git clone https://github.com/rainc/rubyapp
WORKDIR /app/rubyapp
RUN rm -rf Gemfile.lock
RUN bundle install
CMD rackup -p 4567