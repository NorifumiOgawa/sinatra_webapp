# frozen_string_literal: true

require 'sinatra'
require 'sinatra/reloader'
require 'securerandom'
require 'pg'

helpers do
  def h(text)
    Rack::Utils.escape_html(text)
  end
end

get '/' do
  # TOPページ
  @page_title = 'TOP'
  memo = Memo.new
  @memo_list = memo.list
  erb :index
end

get '/memo/new' do
  # 新しいメモを作成するページ
  @page_title = 'New memo'
  erb :new
end

get %r{/memo/([0-9a-z-]+)} do |id|
  # メモを表示するページ
  memo = Memo.new
  @content = memo.read(id)[0]
  @page_title = @content['title']
  erb :show
end

post '/memo/' do
  # 新しいメモを生成する
  memo = Memo.new
  memo.save(params: params)
  redirect to('/')
end

get %r{/memo/([0-9a-z-]+)/edit} do |id|
  # 既存のメモを編集するページ
  @page_title = 'Edit memo'
  memo = Memo.new
  @content = memo.read(id)[0]
  erb :edit
end

patch %r{/memo/([0-9a-z-]+)} do |id|
  # 既存のメモを更新する
  memo = Memo.new
  memo.save(id: id, params: params)
  redirect to("/memo/#{id}")
end

delete %r{/memo/([0-9a-z-]+)} do |id|
  # 既存のメモを削除する
  memo = Memo.new
  memo.delete(id)
  redirect to('/')
end

not_found do
  @page_title = '404 not found'
  erb :'404'
end

class Memo
  def initialize
    @conn = PG.connect(dbname: ENV['PGDATABASE'])
  end

  def list
    @conn.exec('SELECT * FROM memo')
  end

  def read(id)
    @conn.exec('SELECT * FROM memo WHERE id=$1', [id])
  end

  def save(id: nil, params: [])
    if id
      @conn.exec('UPDATE memo SET title=$1, body=$2 WHERE id=$3', [params['title'], params['body'], id])
    else
      @conn.exec('INSERT INTO memo (title, body) VALUES ($1, $2)', [params['title'], params['body']])
    end
  end

  def delete(id)
    @conn.exec('DELETE FROM memo WHERE id=$1', [id])
  end
end
