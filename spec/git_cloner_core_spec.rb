# encoding: utf-8
require 'spec_helper'
require 'git_cloner_core'

describe GitCloner::Core do
  context :init do
    OUTPUT_DSL_TMP_DIR = 'generate_dsl'
    cases = [
      {
        case_no: 1,
        case_title: 'valid case',
        expected_file: GitCloner::Core::GIT_CLONER_FILE,
        expected_content: GitCloner::Core::GIT_CLONER_TEMPLATE,
      },
    ]

    cases.each do |c|
      it "|case_no=#{c[:case_no]}|case_title=#{c[:case_title]}" do
        begin
          case_before c

          # -- given --
          git_cloner_core = GitCloner::Core.new

          # -- when --
          git_cloner_core.init

          # -- then --
          actual = File.read("./#{c[:expected_file]}")
          expect(actual).to eq(c[:expected_content])
        ensure
          case_after c
        end
      end

      def case_before(c)
        Dir.mkdir(OUTPUT_DSL_TMP_DIR) unless Dir.exist? OUTPUT_DSL_TMP_DIR
        Dir.chdir(OUTPUT_DSL_TMP_DIR)
      end

      def case_after(c)
        Dir.chdir('../')
        FileUtils.rm_rf(OUTPUT_DSL_TMP_DIR) if Dir.exist? OUTPUT_DSL_TMP_DIR
      end
    end
  end

  context :clone do
    OUTPUT_GIT_CLONER_TMP_DIR = 'tmp_git_cloner'
    GIT_CLONER_CASE1 = <<-EOF
# encoding: utf-8
default_output "./"
repos [
  {
    place: "https://github.com/tbpgr/rspec_piccolo.git",
    output: "./tmp",
  },
  {
    place: "https://github.com/tbpgr/denrei.git",
  }
]
    EOF

    RESULT_CASE1 = <<-EOF
# encoding: utf-8
require 'templatable'

class SampleUse
  include Templatable
  template <<-EOS
line1:<%=placeholders[:param1]%>
line2:<%=placeholders[:param2]%>
  EOS

  def manufactured_param1
    # TODO: implement your logic
  end

  def manufactured_param2
    # TODO: implement your logic
  end
end
    EOF

    GIT_CLONER_CASE2 = <<-EOF
# encoding: utf-8
default_output "./"
repos "invalid"
    EOF

    GIT_CLONER_CASE3 = <<-EOF
# encoding: utf-8
default_output "./"
repos ["invalid"]
    EOF

    GIT_CLONER_CASE4 = <<-EOF
# encoding: utf-8
default_output "./"
repos [
  {
    plase: "typo"
  }
]
    EOF

    GIT_CLONER_CASE5 = <<-EOF
# encoding: utf-8
default_output "./"
repos [
  {
    place: "https://github.com/tbpgr/rspec_piccolo.git",
    output: "./tmp",
    copies: [
      {from: "./tmp/rspec_piccolo/lib/rspec_piccolo", to: "./"},
      {from: "./tmp/rspec_piccolo/spec", to: "./sample"}
    ]
  },
  {
    place: "https://github.com/tbpgr/denrei.git",
  }
]
    EOF

    cases = [
      {
        case_no: 1,
        case_title: 'valid case',
        input: GIT_CLONER_CASE1,
        expecteds: ['./tmp/rspec_piccolo', './denrei'],
      },
      {
        case_no: 2,
        case_title: 'invalid repos case(String)',
        input: GIT_CLONER_CASE2,
        has_error: true,
      },
      {
        case_no: 3,
        case_title: 'invalid repos case(Array[Not Hash])',
        input: GIT_CLONER_CASE3,
        has_error: true,
      },
      {
        case_no: 4,
        case_title: 'invalid repos case(Array[Hash] but invalid hash key)',
        input: GIT_CLONER_CASE4,
        has_error: true,
      },
      {
        case_no: 5,
        case_title: 'clone git and copy directories case',
        input: GIT_CLONER_CASE5,
        expecteds: ['./tmp/rspec_piccolo', './denrei', './sample/rspec_piccolo_spec.rb', './sample/spec_helper.rb', './rspec_piccolo'],
      },
    ]

    cases.each do |c|
      it "|case_no=#{c[:case_no]}|case_title=#{c[:case_title]}" do
        begin
          case_before c

          # -- given --
          git_cloner_core = GitCloner::Core.new

          # -- when --
          if c[:has_error]
            lambda { git_cloner_core.clone }.should raise_error(StandardError)
            next
          end
          git_cloner_core.clone

          # -- then --
          c[:expecteds].each do |expected|
            actual_exists = File.exist? expected
            expect(actual_exists).to be_true
          end
        ensure
          case_after c
        end
      end

      def case_before(c)
        Dir.mkdir(OUTPUT_GIT_CLONER_TMP_DIR) unless Dir.exist? OUTPUT_GIT_CLONER_TMP_DIR
        Dir.chdir(OUTPUT_GIT_CLONER_TMP_DIR)
        File.open(GitCloner::Core::GIT_CLONER_FILE, 'w:UTF-8') { |f|f.print c[:input] }
      end

      def case_after(c)
        Dir.chdir('../')
        FileUtils.rm_rf(OUTPUT_GIT_CLONER_TMP_DIR) if Dir.exist? OUTPUT_GIT_CLONER_TMP_DIR
      end
    end
  end
end
