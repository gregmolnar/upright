class Upright::Playwright::StorageState
  def initialize(service)
    @service = service
  end

  def exists?
    path.exist?
  end

  def load
    if exists?
      decrypted_json = encryptor.decrypt_and_verify(path.read)
      JSON.parse(decrypted_json)
    end
  end

  def save(state)
    FileUtils.mkdir_p(storage_dir)
    encrypted_data = encryptor.encrypt_and_sign(JSON.generate(state))
    path.write(encrypted_data)
  end

  def clear
    path.delete if exists?
  end

  private
    def storage_dir
      Upright.configuration.storage_state_dir
    end

    def path
      storage_dir.join("#{@service}.enc")
    end

    def encryptor
      key = Rails.application.key_generator.generate_key("playwright_storage_state", 32)
      ActiveSupport::MessageEncryptor.new(key)
    end
end
