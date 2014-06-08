# encoding: utf-8
require 'active_model'

module GitCloner
  # DslModel
  class DslModel
    include ActiveModel::Model

    # default_output place
    attr_accessor :default_output
    validates :default_output, presence: true

    # git repositries
    attr_accessor :repos

  end
end
