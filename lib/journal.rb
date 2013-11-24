require 'archive'
require 'package'

class Journal

  def self.overview
    Package.all.each do |package|
      puts "Package: #{package.name}"
      puts "Archives: #{package.archives.size}"
      package.archives.sort_by { |a| a.original_path }.each do |archive|
        puts <<-EOF
          path: #{archive.original_path}
          details: #{JSON.parse(archive.description)}
          vault: #{archive.vault}
          treehash: #{archive.treehash}
          sha256: #{archive.sha256}

        EOF
      end
    end
  end

end
