# encoding: utf-8
require 'git_cloner_dsl'
require "uri"

module GitCloner
  #  GitCloner Core
  class Core
    GIT_CLONER_FILE = "Gitclonerfile"
    GIT_CLONER_TEMPLATE =<<-EOS
# encoding: utf-8

# default_output place
# default_output is required
# default_output allow only String
# default_output's default value => "./"
default_output "./"

# git repositries
# repo allow only Array(in Array, Hash[:place, :output])
# repo's default value => []
repos [
  {
    place: 'https://github.com/tbpgr/rspec_piccolo.git',
    output: './tmp'
  }
]
    EOS

    #== generate Gitclonerfile to current directory.
    def init
      File.open(GIT_CLONER_FILE, "w") {|f|f.puts GIT_CLONER_TEMPLATE}
    end

    #== clone git repositories
    def execute
      dsl = get_dsl
      base = Dir.pwd
      default_output = dsl.git_cloner.default_output
      tmp_repos = dsl.git_cloner.repos
      fail ArgumentError, 'invalid repos. repos must be Array.' unless tmp_repos.is_a? Array
      tmp_repos.each do |repo|
        fail ArgumentError, 'invalid repos. repos-Array must have Hash' unless repo.is_a? Hash
        fail ArgumentError, 'invalid key. Hash must contain :place key' unless repo.has_key? :place
        repo_name = get_repo_name repo[:place]
        target_dir = get_output(repo[:output], default_output)
        FileUtils.mkdir_p(target_dir) unless Dir.exists? target_dir
        Dir.chdir(target_dir)
        result = system("git clone #{repo[:place]} --depth=1")
        remove_dot_git_directory repo_name
        show_result_message(result, repo_name)
        Dir.chdir base
      end
    end

    private

    def get_dsl
      src = read_dsl
      dsl = GitCloner::Dsl.new
      dsl.instance_eval src
      dsl
    end

    def read_dsl
      File.open(GIT_CLONER_FILE) {|f|f.read}
    end

    def get_repo_name(place)
      uri = URI(place)
      p uri.path.gsub(/.*\//, '').gsub('.git', '')
    end

    def get_output(output, default_output)
      output.nil? ? default_output : output
    end

    def remove_dot_git_directory(repo_name)
      Dir.chdir("./#{repo_name}")
      FileUtils.rm_rf('.git') if Dir.exists? '.git'
    end

    def show_result_message(result, repo_name)
      if result
        puts "clone #{Dir.pwd}/#{repo_name} complete"
      else
        pust "clone #{Dir.pwd}/#{repo_name} fail"
      end
    end
  end
end
