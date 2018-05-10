FROM ruby
RUN mkdir -p /app
ARG repourl 
WORKDIR /app/
RUN git clone $repourl
RUN rm -rf /app/rubyapp/Gemfile.lock
WORKDIR /app/rubyapp
RUN bundle install
CMD rackup -p 4567 --host 0.0.0.0