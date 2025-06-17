## 実行方法

1. 環境変数ファイルのコピーと書き換え
  ```sh
  cp .env.sample .env
  ```

2. Docker の起動

  ```sh
  docker compose up -d
  ```

## dummy データの投入

1. コンテナに入る

  ```sh
  docker compose exec db bash
  ```

2. sql の実行

  ```sh
  cat /scripts/dummy.sql | psql kensuiou
  ```
  