# encoding: utf-8
require 'spec_helper'
require 'copier'

describe GitCloner::Copier do
  context :copy do
    TMP_COPY = 'tmp_copy'
    cases = [
      {
        case_no: 1,
        case_title: 'valid case',
        prepare_files: ['from/hoge1.txt', 'from/hoge2.txt'],
        copies: [
          {
            from: 'from',
            to: 'to',
          }
        ],
        expected_files: ['to/hoge1.txt', 'to/hoge2.txt']
      },
      {
        case_no: 2,
        case_title: 'not have from key case',
        prepare_files: ['from/hoge1.txt', 'from/hoge2.txt'],
        copies: [
          {
            to: 'to',
          }
        ],
        expect_error: true
      },
      {
        case_no: 3,
        case_title: 'not have to key case',
        prepare_files: ['from/hoge1.txt', 'from/hoge2.txt'],
        copies: [
          {
            from: 'from',
          }
        ],
        expect_error: true
      },
    ]

    cases.each do |c|
      it "|case_no=#{c[:case_no]}|case_title=#{c[:case_title]}" do
        begin
          case_before c

          # -- given --
          # nothing

          # -- when --
          if c[:expect_error]
            -> { GitCloner::Copier.copy(c[:copies]) }.should raise_error(ArgumentError)
            next
          end
          GitCloner::Copier.copy(c[:copies])

          # -- then --
          c[:expected_files].each { |file|expect(File.exist?(file)).to be_true }
        ensure
          case_after c
        end
      end

      def case_before(c)
        Dir.mkdir(TMP_COPY) unless Dir.exist?(TMP_COPY)
        Dir.chdir(TMP_COPY)
        c[:prepare_files].each do |file|
          dir = File.dirname(file)
          FileUtils.mkdir_p(dir)
          File.open(file, 'w') { |f|f.print file }
        end
      end

      def case_after(c)
        Dir.chdir('../')
        FileUtils.rm_rf(TMP_COPY) if Dir.exist?(TMP_COPY)
      end
    end
  end
end
