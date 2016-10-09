class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception

  before_filter :set_locale

  private
	def set_locale
	  I18n.locale = extract_locale_from_params
	end

	# Get locale from parameters passed in
	# i.e. www.ymntranslation.com?lang=es
	def extract_locale_from_params
	  parsed_locale = params[:lang].nil? ? "" : params[:lang].downcase
	  (I18n.available_locales.map(&:to_s).include? parsed_locale) ? parsed_locale  : nil
	end
end
