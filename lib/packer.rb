require 'logging'
require 'fileutils'

class Packer
  include Logging

  attr_reader :path

  def initialize(path: '/tmp')
    @path = path
    FileUtils.mkdir_p path unless File.directory?(path)
  end

  def prepare!(directory, name: nil, split_size: 100*(1024**2), par2: true, encrypt: true, sign: true)
    raise "directory does not exist" unless File.directory?(directory)
    name ||= File.basename(directory)

    remove_existing(name)

    tar = "/bin/tar cf - \"#{directory}\""
    compress = "/usr/bin/lzma -z --to-stdout -"
    gpg = "/usr/bin/gpg -q -r mail@andreas-brandl.de -e #{"-s "if sign} -"
    split = "/usr/bin/split -b #{split_size} -d -a 4 - \"#{path}/#{name}.tar.lzma.gpg.\""

    pipe = [tar, compress]
    pipe << gpg if encrypt
    pipe << split

    command = pipe.map { |c| "#{c} 2> /dev/null"}.join(" | ")

    info "preparing #{directory}... tar/compress/gpg/split"
    `#{command}`
    raise 'tar failed' unless $? == 0

    info "calculating par2 infos for #{directory}..."
    `/usr/bin/par2create #{pattern(name)} &> /dev/null`

    raise 'par2 failed' unless $? == 0

    [name, archive_files(name)]
  end

  private
  def remove_existing(name)
    existing = archive_files(name)
    unless existing.empty?
      warn "destination might already exist, cleaning up..."
      existing.each { |f| FileUtils.rm_r f }
    end
  end

  def pattern(name)
    "#{path}/#{name}*"
  end

  def archive_files(name)
    Dir.glob(pattern(name)).map { |f| File.new(f) }
  end
end
