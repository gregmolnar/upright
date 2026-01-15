module SubdomainHelper
  def on_subdomain(subdomain)
    if subdomain.present?
      host! "#{subdomain}.#{DEFAULT_URL_OPTIONS[:domain]}"
    else
      host! DEFAULT_URL_OPTIONS[:domain]
    end
  end
end
