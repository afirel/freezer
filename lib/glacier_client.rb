require 'fog'
require 'hashing'

class GlacierClient
  include Hashing

  attr_reader :api, :vault_name

  def initialize(vault_name, config = {})
    @api = Fog::AWS::Glacier.new(config)
    @vault_name = vault_name
  end

  def upload(file, description: nil, chunk_size: 1024*1024)
    archive = vault!.archives.create(
      body: file,
      description: description,
      multipart_chunk_size: chunk_size
    )
    {
      archive_id: archive.id,
      size: size_of(file) + 32, # including overhead
      vault: vault_name,
      treehash: tree_hash(file, chunk_size: chunk_size),
      treehash_chunk_size: chunk_size,
      sha256: sha256(file),
      description: description
    }
  end

 # private
  def vault!
    vaults = api.vaults
    if vaults.map(&:id).include?(vault_name)
      vaults.select { |vault| vault.id == vault_name }.first
    else
      api.vaults.create id: vault_name
    end
  end

  def size_of(file)
    File.size(file)
  end

end
