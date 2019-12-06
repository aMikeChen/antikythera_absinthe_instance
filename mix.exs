antikythera_dep = {:antikythera, [github: "access-company/antikythera", ref: "9962dc0566d2fb9ac1175c9bb2e5819b206dd34d"]}

try do
  parent_dir = Path.expand("..", __DIR__)
  deps_dir =
    case Path.basename(parent_dir) do
      "deps" -> parent_dir
      _      -> Path.join(__DIR__, "deps")
    end
  mix_common_file_path = Path.join([deps_dir, "antikythera", "mix_common.exs"])
  Code.require_file(mix_common_file_path)

  defmodule AntikytheraAbsintheInstance.Mixfile do
    use Mix.Project

    versions =
      File.read!(Path.join(__DIR__, ".tool-versions"))
      |> String.split("\n", trim: true)
      |> Map.new(fn line -> [n, v] = String.split(line, " ", trim: true); {n, v} end)
    @elixir_version Map.fetch!(versions, "elixir")

    case System.argv() do
      ["deps" <> _ | _] -> :ok
      _                 ->
        otp_version         = Map.fetch!(versions, "erlang")
        otp_version_path    = Path.join([:code.root_dir(), "releases", System.otp_release(), "OTP_VERSION"])
        current_otp_version = File.read!(otp_version_path) |> String.trim_trailing()
        if current_otp_version != otp_version do
          Mix.raise("Incorrect Erlang/OTP version! required: '#{otp_version}', used: '#{current_otp_version}'")
        end
    end

    def project() do
      github_url = "https://github.com/aMikeChen/antikythera_absinthe_instance"
      base_settings = Antikythera.MixCommon.common_project_settings() |> Keyword.replace!(:elixir, @elixir_version)
      [
        app:             :antikythera_absinthe_instance,
        version:         Antikythera.MixCommon.version_with_last_commit_info("0.1.0"),
        start_permanent: Mix.env() == :prod,
        deps:            deps(),
        source_url:      github_url,
        homepage_url:    github_url,
      ] ++ base_settings
    end

    def application() do
      [
        applications: [:antikythera | Antikythera.MixCommon.antikythera_runtime_dependency_applications(deps())],
      ]
    end

    defp deps() do
      [
        unquote(antikythera_dep),

        {:poison , "2.2.0" },
        {:jason  , "1.1.2" },
        {:gettext, "0.17.0"},
        {:croma  , "0.10.2"},

        # Absinthe
        {:absinthe,             "~> 1.4.0"},
        {:absinthe_relay,       "~> 1.4"},
        {:absinthe_antikythera, github: "aMikeChen/absinthe_antikythera"},

        # Database
        {:dodai_client_elixir, [git: "git@github.com:access-company/DodaiClientElixir.git", ref: "5eac32caf90b32740b930d5196b57b61e263260c"]},

        # Tools
        {:exsync          , "0.2.4" , [only: :dev ]},
        {:meck            , "0.8.13", [only: :test]},
        {:websocket_client, "1.3.0" , [only: :test]},
      ]
    end
  end
rescue
  Code.LoadError ->
    defmodule AntikytheraInstanceInitialSetup.Mixfile do
      use Mix.Project

      def project() do
        [
          app:  :just_to_fetch_antikythera_as_a_dependency,
          deps: [unquote(antikythera_dep)],
        ]
      end
    end
end
