import Config

config :flash_sync_e, FlashSyncE.Repo,
  database: "flash_sync_e_dev",
  username: "postgres",
  password: "postgres",
  hostname: "localhost",
  pool_size: 10

config :flash_sync_e,
  ecto_repos: [FlashSyncE.Repo]
