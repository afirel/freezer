require 'fog'

module Hashing
  extend self

  def tree_hash(file, chunk_size: 1024*1024)
    hash = Fog::AWS::Glacier::TreeHash.new
    File.open(file, 'r') do |io|
      while (chunk = io.read(chunk_size)) do
        hash.add_part(chunk)
      end
    end
    hash.hexdigest
  end

  def sha256(file)
    Digest::SHA256.hexdigest(File.read(file))
  end

end
