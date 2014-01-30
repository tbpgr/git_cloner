# encoding: utf-8
require 'git_cloner_dsl'
require "uri"
require 'fileutils'

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
      git_clone(default_output, tmp_repos, base)
    end

    def clone(default_output, repos = [])
      default_output ||= './'
      base = Dir.pwd
      dsl = GitCloner::Dsl.new

      default_output = dsl.git_cloner.default_output
      tmp_repos = dsl.git_cloner.repos
      git_clone(default_output, repos, base)
    end

    private

    def git_clone(default_output, tmp_repos, base)
      fail ArgumentError, 'invalid repos. repos must be Array.' unless tmp_repos.is_a? Array
      tmp_repos.each do |repo|
        fail ArgumentError, 'invalid repos. repos-Array must have Hash' unless repo.is_a? Hash
        fail ArgumentError, 'invalid key. Hash musft contain :place key' unless repo.has_key? :place
        repo_name = get_repo_name repo[:place]
        target = get_output(repo[:output], default_output)
        FileUtils.mkdir_p(target) unless Dir.exists? target
        Dir.chdir(target)
        result = system("git clone #{repo[:place]} --depth=1")
        remove_dot_git_directory repo_name
        show_result_message(result, repo_name)
        Dir.chdir base
        next if repo[:copies].nil?
        copy_targets repo[:copies]
      end
    end

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
      uri.path.gsub(/.*\//, '').gsub('.git', '')
    end

    def get_output(output, default_output)
      require 'test_toolbox'
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
        puts "clone #{Dir.pwd}/#{repo_name} fail"
      end
    end

    def copy_targets(copies)
      copies.each do |cp_dir|
        fail ArgumentError, 'invalid repos. copies must have from' unless cp_dir[:from]
        fail ArgumentError, 'invalid repos. copies must have to' unless cp_dir[:to]
        FileUtils.mkdir_p(cp_dir[:to]) unless Dir.exists? File.dirname(cp_dir[:to])
        FileUtils.cp_r cp_dir[:from], cp_dir[:to]
      end
    end
  end
end
