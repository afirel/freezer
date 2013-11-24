require 'logging'
require 'archive'
require 'package'
require 'json'

class Archiver
  include Logging

  CHUNK_SIZE = 1024*1024

  def self.create(vault)
    self.new(Icer.glacier_client(vault))
  end

  attr_reader :glacier, :packer

  def initialize(glacier, packer)
    @glacier, @packer = *[glacier, packer]
  end

  # * tar+compress directory
  # * encrypt+sign archive
  # * split using split_size
  # * calculate par2 infos
  def freeze_directory!(directory, split_size: 100*(1024**2), par2: true, encrypt: true, sign: true)
    package_name, files = packer.prepare!(directory, split_size: split_size, par2: par2, encrypt: encrypt, sign: sign)

    package = Package.create!(name: package_name)

    files.map do |file|

      description = {
        package: package_name,
        filename: File.basename(file.path),
        directory: directory.path
      }

      json = description.to_json
      raise 'json description is over 1024 chars' if json.size > 1024

      archive_file!(file, package, description: json, delete_after: true)
    end

  end

  def archive_file!(file, package, description: nil, delete_after: false)
    info "archiving #{file}"
    meta = archive_file(file, description)

    archive = Archive.new(meta)
    archive.original_path = file.path
    archive.package = package
    archive.save!

    File.delete file if delete_after
    archive
  end

  # synchronize local journal with remote inventory
  def synchronize
    raise 'not-implemented'
  end

  # very long running operation that tries to stay within free retrieval rate
  # and verifies remote content against local journal checksums
  def verify
    raise 'not-implemented'
  end

  private
  def archive_file(file, description)
    glacier.upload(file, description: description || file.path)
  end

end
