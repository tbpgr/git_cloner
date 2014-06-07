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
      File.open(GIT_CLONER_FILE, "w") { |f|f.puts(GIT_CLONER_TEMPLATE) }
    end

    #== clone git repositories
    def clone
      dsl = get_dsl
      base_dir = Dir.pwd
      default_output = dsl.git_cloner.default_output
      repos = dsl.git_cloner.repos
      clone_repositories(default_output, repos, base_dir)
    end

    private

    def get_dsl
      src = read_dsl
      dsl = GitCloner::Dsl.new
      dsl.instance_eval src
      dsl
    end

    def read_dsl
      File.open(GIT_CLONER_FILE) { |f|f.read }
    end

    def clone_repositories(default_output, repos, base_dir)
      fail ArgumentError, 'invalid repos. repos must be Array.' unless repos.is_a? Array
      repos.each do |repo|
        fail ArgumentError, 'invalid repos. repos-Array must have Hash' unless repo.is_a?(Hash)
        fail ArgumentError, 'invalid key. Hash must contain :place key' unless repo.key?(:place)
        repo_name = get_repo_name repo[:place]
        output_dir = get_output_dir(repo[:output], default_output)
        make_output_dir(output_dir)
        Dir.chdir(output_dir)
        result = system("git clone #{repo[:place]} --depth=1")
        remove_dot_git_directory repo_name
        show_result_message(result, repo_name)
        Dir.chdir(base_dir)
        next if repo[:copies].nil?
        copy_targets(repo[:copies])
      end
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

    def remove_dot_git_directory(repo_name)
      Dir.chdir("./#{repo_name}")
      FileUtils.rm_rf('.git') if Dir.exist?('.git')
    end

    def show_result_message(result, repo_name)
      if result
        puts("clone #{Dir.pwd}/#{repo_name} complete")
      else
        puts("clone #{Dir.pwd}/#{repo_name} fail")
      end
    end

    def copy_targets(copies)
      copies.each do |cp_dir|
        fail ArgumentError, 'invalid repos. copies must have from' unless cp_dir[:from]
        fail ArgumentError, 'invalid repos. copies must have to' unless cp_dir[:to]
        FileUtils.mkdir_p(cp_dir[:to]) unless Dir.exist? File.dirname(cp_dir[:to])
        FileUtils.cp_r cp_dir[:from], cp_dir[:to]
      end
    end
  end
end
