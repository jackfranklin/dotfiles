require 'fileutils'
require 'open-uri'
require 'json'

class Vim
  def initialize(argv)
    @argv = argv
    @bundles_dir = File.join(File.expand_path("~/dotfiles/vim/vim"), "bundle")
    @bundles = get_bundles
    @reinstall_single = @argv[0]
  end

  def install_plugins
    prepare_file_system
    FileUtils.cd(@bundles_dir)
    process_items
    tidy_up
  end

  private

  def process_items
    @bundles.each do |item|
      name = name_for_url(item)
      if !@reinstall_single.nil? && item.include?(@reinstall_single)
        FileUtils.rm_rf(name)
        clone_item(item)
      else
        unless File.directory?(name)
          clone_item(item)
        end
      end
    end
  end

  def tidy_up
    Dir["*/.git"].each {|f| FileUtils.rm_rf(f) }
    uninstall_old_bundles
  end

  def uninstall_old_bundles
    bundle_names = @bundles.map { |item|
      name_for_url(item)
    }

    folder_names = Dir.glob('*').map { |item|
      item.split("/").last
    }

    to_uninstall = folder_names.select { |folder| !bundle_names.include?(folder) }
    to_uninstall.each do |folder|
      puts "Uninstalling plugin: #{folder}"
      FileUtils.rm_rf(File.expand_path(folder))
    end
  end

  def prepare_file_system
    FileUtils.rm_rf(@bundles_dir) if @reinstall_all
    FileUtils.mkdir_p(@bundles_dir)
  end

  def name_for_url(url)
    url.split("/").last
  end

  def clone_url_for_item(item)
    "git://github.com/#{item}.git"
  end

  def clone_item(item)
    name = name_for_url(item)
    puts "Cloned: #{item}"
    clone_url = clone_url_for_item(item)
    `git clone -q #{clone_url}`
  end

  def get_bundles
    p Dir.pwd
    JSON.parse(IO.read('vim_plugins.json'))
  end
end
