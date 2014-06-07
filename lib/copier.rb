# encoding: utf-8

module GitCloner
  # Copier
  class Copier
    class << self
      def copy(copies)
        return if copies.nil?
        copies.each { |copy_dir|copy_target(copy_dir) }
      end

      private

      def copy_target(copy_dir)
        check_copy_dir_from(copy_dir[:from])
        check_copy_dir_to(copy_dir[:to])
        make_copy_dir_if_not_exists(copy_dir[:to])
        copy_target_files(copy_dir[:from], copy_dir[:to])
      end
  
      def check_copy_dir_from(from)
        return if from
        fail ArgumentError, 'invalid repos. copies must have from'
      end
  
      def check_copy_dir_to(to)
        return if to
        fail ArgumentError, 'invalid repos. copies must have from'
      end
  
      def make_copy_dir_if_not_exists(to)
        return if Dir.exist?(File.dirname(to))
        FileUtils.mkdir_p(to)
      end
  
      def copy_target_files(from, to)
        FileUtils.cp_r(from, to)
      end
    end
  end
end
