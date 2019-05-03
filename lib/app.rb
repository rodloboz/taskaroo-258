require "sinatra"
require "sinatra/reloader" if development?
require "sqlite3"
require "byebug"

DB = SQLite3::Database.new(File.join(File.dirname(__FILE__), 'db/tasks.db'))
DB.results_as_hash = true
require_relative "models/task"

get "/" do
  redirect "/tasks"
end

get "/tasks" do
  #TODO: Show all tasks
  @tasks = Task.all

  erb :index
end

get "/tasks/new" do
  @task = Task.new

  erb :new
end

get "/tasks/:id/edit" do
  #TODO: Edit task with :id
  @task = Task.find(params[:id])

  erb :edit
end

get "/tasks/:id/delete" do
  #TODO: Delete task with :id
  @task = Task.find(params[:id])
  @task.destroy

  redirect '/tasks'
end

post "/tasks/:id" do
  #TODO: Update task with :id
  @task = Task.find(params[:id])
  @task.update(params[:task])

  redirect "/tasks/#{@task.id}"
end

get "/tasks/:id" do
  #TODO: Show task with :id
  @task = Task.find(params[:id])

  erb :show
end

post "/tasks" do
  #TODO: Create task
  @task = Task.new(params[:task])
  @task.save

  redirect "/tasks/#{@task.id}"
end
