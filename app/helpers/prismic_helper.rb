module PrismicHelper
  require 'prismic'

  ##
  # Setting @ref as the actual ref id being queried, even if it's the master ref.
  # To be used to call the API, for instance: api.form('everything').submit(ref)
  # If we fail to initialize the Prismic API we return the last successful ref
  # stored in Rails cache
  #
  def prismic_ref
    if api.nil?
      @ref = Rails.cache.fetch('prismic_ref')
    else
      master_ref = api.master_ref.ref
      Rails.cache.write('prismic_ref', master_ref)
      @ref ||= preview_ref || experiment_ref || master_ref
    end
  end

  ##
  # Access and initialization of the Prismic::API object.
  #
  def prismic_api
    prismic_url = ENV['PRISMIC_API_URL']
    @api ||= Prismic.api(prismic_url, ENV['PRISMIC_ACCESS_TOKEN'])
  rescue Prismic::API::PrismicWSConnectionError,
         Prismic::API::BadPrismicResponseError,
         Prismic::API::PrismicWSAuthError,
         Net::OpenTimeout => e
    Rails.logger.error e
    @api = nil
  end

  private

  ##
  # Returns the ref of the user's Prismic preview token
  #
  def preview_ref
    preview_token = params[:token]
    if preview_token
      cookies[Prismic::PREVIEW_COOKIE] = { value: preview_token, expires: 30.minutes.from_now }
      preview_token
    elsif request.cookies.key?(Prismic::PREVIEW_COOKIE)
      request.cookies[Prismic::PREVIEW_COOKIE]
    end
  end

  ##
  # Returns the ref for the Prismic experiment the user is part of
  #
  def experiment_ref
    experiments = api.experiments.current
    if experiments
      if request.cookies.key?(Prismic::EXPERIMENTS_COOKIE)
        # If they are already placed into an experiment group use that
        request.cookies[Prismic::EXPERIMENTS_COOKIE]
      else
        # Else assign them randomly to a group
        ref = experiments.variations.sample.ref
        cookies[Prismic::EXPERIMENTS_COOKIE] = { value: ref, expires: 1.year.from_now }
        ref
      end
    else
      # If there are no experiments remove the experiments cookie
      cookies.delete Prismic::EXPERIMENTS_COOKIE
      nil
    end
  end
end
