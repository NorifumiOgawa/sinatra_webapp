# frozen_string_literal: true

require 'sinatra'
require 'sinatra/reloader'
require 'logger'
require 'json'
require 'securerandom'

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
  @id = id
  memo = Memo.new
  @content = memo.read(id)
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
  @id = id
  memo = Memo.new
  @content = memo.read(id)
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
  def list
    file_list = Dir.glob('*', base: './data/')
    file_list.map! do |file|
      File.open("./data/#{file}") do |f|
        title_text = JSON.parse(f.read)['title']
        title_text = 'NO TITLE' if title_text == ''
        {'title' => title_text, 'file_name' => file}
      end
    end
    file_list
  end

  def read(id)
    memo = ''
    File.open("./data/#{id.gsub(/[\.|\/|\\]+/, '')}") do |f|
      memo = JSON.parse(f.read)
      memo['file_name'] = id
    end
    memo
  end

  def save(id: SecureRandom.uuid, params: [])
    File.open("./data/#{id.gsub(/[\.|\/|\\]+/, '')}", 'w') do |file|
      json = { title: params['title'], body: params['body'] }
      JSON.dump(json, file)
    end
  end

  def delete(id)
    File.delete("./data/#{id.gsub(/[\.|\/|\\]+/, '')}")
  end
end
