# frozen_string_literal: true

require 'sinatra'
require 'sinatra/reloader'
require 'logger'
require 'json'

helpers do
  def h(text)
    Rack::Utils.escape_html(text)
  end
end

get '/' do
  # TOPページ
  @page_title = 'TOP'
  @memos = []
  memo_lists
  erb :index
end

get %r{/memo/(\d+)} do |file|
  # メモを表示するページ
  File.open("./data/#{file}") do |f|
    @memo = JSON.parse(f.read)
  end
  @filename = file
  erb :show
end

get '/memo/new' do
  # 新しいメモを作成するページ
  @page_title = 'New memo'
  erb :new
end

post '/memo/' do
  # 新しいメモを生成する
  save_memo(params: params)
  redirect to('/')
end

get %r{/memo/(\d+)/edit} do |file|
  # 既存のメモを編集するページ
  File.open("./data/#{file}") do |f|
    @memo = JSON.parse(f.read)
  end
  @filename = file
  erb :edit
end

patch '/memo/' do
  # 既存のメモを更新する
  save_memo(filename: params['filename'], params: params)
  redirect to("/memo/#{params['filename']}")
end

delete '/memo/' do
  # 既存のメモを削除する
  File.delete("./data/#{params['filename']}")
  redirect to('/')
end

def memo_lists
  @file_list = Dir.glob('*', base: './data/')
  @file_list.each do |file|
    File.open("./data/#{file}") do |f|
      hash = JSON.parse(f.read)
      hash['title'] = 'NO TITLE' if hash['title'] == ''
      @memos << hash
    end
  end
end

def save_memo(filename: Time.now.to_i.to_s, params: [])
  File.open("./data/#{filename}", 'w') do |file|
    json = { title: params['title'], body: params['body'] }
    JSON.dump(json, file)
  end
end

not_found do
  @page_title = '404 not Found'
  erb :'404'
end
