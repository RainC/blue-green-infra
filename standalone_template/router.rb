require 'sinatra'
require "sinatra/basic_auth"

# Specify your authorization logic
authorize do |username, password|
    username == "admin" && password == "rubyrain_admin"
end

# Set protected routes
protect do
    get '/index.html' do
        @page_title = 'Home'
        @page_id = 'index.html'
        erb :'index.html' 
    end
end
