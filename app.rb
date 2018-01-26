require "sinatra"
require 'sinatra/activerecord'
require 'sinatra/flash'
require 'sinatra/redirect_with_flash'

enable :sessions
set :session_secret, "My session secret"

helpers do
  include Rack::Utils
  alias_method :h, :escape_html
  def title
    if @title
      "#{@title}"
    else
      "Welcome."
    end
  end
end

class Post < ActiveRecord::Base
  validates :title, presence: true
  validates :body, presence: true
end

get "/" do
  @posts =Post.order("created_at DESC")
  @title = "Welcome"
  erb :"posts/index"
end

get "/posts/create" do
  @title = "Create post"
  @post = Post.new
  erb :"posts/create"
end

post "/posts" do
  @post = Post.new(params[:post])

  if @post.save
    flash[:notice] = "Congrats! Love the new post"
    redirect "posts/#{@post.id}"
  else
    flash[:error] = "Something went wrong. Try again."
    erb :"posts/create"
  end
end

get "/posts/:id" do
  @post = Post.find(params[:id])
  @title = @post.title
  erb :"posts/view"
end

get "/posts/:id/edit" do
  @post = Post.find(params[:id])
  @title = "Edit Form"
  erb :"posts/edit"
end

get "/posts/delete/:id" do
  @post = Post.find(params[:id])
  @title = "Delete Form"
  erb :"posts/delete"
end

put "/posts/:id" do
  @post = Post.find(params[:id])
  @post.update(params[:post])
  redirect "/posts/#{@post.id}"

end

delete "/posts/:id" do
  @post = Post.find(params[:id]).destroy
  redirect to("/")
end