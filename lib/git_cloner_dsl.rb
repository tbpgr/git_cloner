# encoding: utf-8
require 'git_cloner_dsl_model'

module GitCloner
  # Dsl
  class Dsl
    attr_accessor :git_cloner

    # String Define
    [:default_output].each do |f|
      define_method f do |value|
        @git_cloner.send("#{f}=", value)
      end
    end

    # Array/Hash/Boolean Define
    [:repos].each do |f|
      define_method f do |value|
        @git_cloner.send("#{f}=", value)
      end
    end

    def initialize
      @git_cloner = GitCloner::DslModel.new
      @git_cloner.default_output = './'
      @git_cloner.repos = []
    end
  end
end
