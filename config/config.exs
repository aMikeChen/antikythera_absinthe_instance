use Mix.Config

repo_parent_dir = Path.expand(Path.join([__DIR__, "..", ".."]))
deps_dir =
  case Path.basename(repo_parent_dir) do
    "deps" -> repo_parent_dir
    _      -> Path.expand(Path.join([__DIR__, "..", "deps"]))
  end

antikythera_config_file = Path.join([deps_dir, "antikythera", "config", "config.exs"])
if File.regular?(antikythera_config_file) do
  import_config antikythera_config_file
end

config :antikythera, [
  antikythera_instance_name: :antikythera_absinthe_instance,
]
