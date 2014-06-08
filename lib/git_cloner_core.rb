# encoding: utf-8
require 'git_cloner_dsl'
require 'uri'
require 'fileutils'
require 'copier'

module GitCloner
  #  GitCloner Core
  class Core
    GIT_CLONER_FILE = 'Gitclonerfile'
    GIT_CLONER_TEMPLATE =<<-EOS
# encoding: utf-8

# default_output place
# default_output allow only String
# default_output's default value => "./"
default_output "./"

# git repositries
# repos allow only Array(in Array, Hash[:place, :output, :copies])
# copies is option.
# copies must have Array[Hash{:from, :to}].
# you can copy files or directories.
# repos's default value => []
repos [
  {
    place: 'https://github.com/tbpgr/rspec_piccolo.git',
    output: './tmp',
    copies: [
      {from: "./tmp/rspec_piccolo/lib/rspec_piccolo", to: "./"},
      {from: "./tmp/rspec_piccolo/spec", to: "./sample"}
    ]
  }
]
    EOS

    # == generate Gitclonerfile to current directory.
    def init
      File.open(GIT_CLONER_FILE, 'w') { |f|f.puts(GIT_CLONER_TEMPLATE) }
    end

    # == clone git repositories
    def clone
      settings = read_settings
      base_dir = Dir.pwd
      default_output = settings.default_output
      repos = settings.repos
      clone_repositories(default_output, repos, base_dir)
    end

    private

    def read_settings
      src = read_dsl
      dsl = GitCloner::Dsl.new
      dsl.instance_eval src
      dsl.git_cloner
    end

    def read_dsl
      File.open(GIT_CLONER_FILE) { |f|f.read }
    end

    def clone_repositories(default_output, repos, base_dir)
      check_repos(repos)
      repos.each { |repo|clone_repository(default_output, repo, base_dir) }
    end

    def check_repos(repos)
      return if repos.is_a? Array
      fail ArgumentError, 'invalid repos. repos must be Array.'
    end

    def clone_repository(default_output, repo, base_dir)
      check_repos_hash(repo)
      check_repos_hash_key(repo)
      output_dir = get_output_dir(repo[:output], default_output)
      make_output_dir(output_dir)
      move_to_output_dir(output_dir)
      execute_git_clone(repo[:place])
      back_to_base_dir(base_dir)
      Copier.copy(repo[:copies])
    end

    def check_repos_hash(repo)
      return if repo.is_a?(Hash)
      fail ArgumentError, 'invalid repos. repos-Array must have Hash'
    end

    def check_repos_hash_key(repo)
      return if repo.key?(:place)
      fail ArgumentError, 'invalid key. Hash must contain :place key'
    end

    def get_repo_name(place)
      uri = URI(place)
      uri.path.gsub(/.*\//, '').gsub('.git', '')
    end

    def get_output_dir(output, default_output)
      output.nil? ? default_output : output
    end

    def make_output_dir(output_dir)
      FileUtils.mkdir_p(output_dir) unless Dir.exist?(output_dir)
    end

    def move_to_output_dir(output_dir)
      Dir.chdir(output_dir)
    end

    def execute_git_clone(url)
      result = system("git clone #{url} --depth=1")
      repo_name = get_repo_name(url)
      remove_dot_git_directory repo_name
      show_result_message(result, repo_name)
    end

    def back_to_base_dir(base_dir)
      Dir.chdir(base_dir)
    end

    def remove_dot_git_directory(repo_name)
      Dir.chdir("./#{repo_name}")
      FileUtils.rm_rf('.git') if Dir.exist?('.git')
    end

    def show_result_message(result, repo_name)
      result_msg = result ? 'complete' : 'fail'
      puts("clone #{Dir.pwd}/#{repo_name} #{result_msg}")
    end
  end
end
