module SubdomainHelper
  def on_subdomain(subdomain)
    hostname = Upright.configuration.hostname

    if subdomain.present?
      host! "#{subdomain}.#{hostname}"
    else
      host! hostname
    end
  end
end
