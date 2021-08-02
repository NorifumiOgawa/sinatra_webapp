# sinatra_webapp

## ローカルでアプリケーションを立ち上げるための手順

リポジトリをローカルに展開
```
$ git clone https://github.com/NorifumiOgawa/sinatra_webapp.git
$ cd sinatra_webapp
$ git checkout pg
$ bundle install --path vendor/bundle
```

DBの準備
```
$ brew install postgresql
$ psql --version
psql (PostgreSQL) 13.3
$ brew services start postgresql
$ createdb memo_app
$ psql -U {username} memo_app
memo_app=# create table memo (id serial, title varchar(500), body varchar(500));
```

環境変数の準備

~/.zprofile
```
+ export PGDATABASE='memo_app'
```
更新内容を反映
```
$ source ~/.zprofile
```

sinatraを起動
```
$ bundle exec ruby memo.rb
```

ブラウザで `http://localhost:4567/` にアクセスする。


## 削除する手順

DB削除、PostgreSQL停止、アンインストール
```
$ dropdb memo_app
$ brew services stop postgresql
$ brew uninstall postgresql
```

- `~/.zprofile` から `PGDATABASE`の行を削除
- `sinatra_webapp` を削除