module Spec
  module Support
    module RequestsHelpers

      def warden
        request.env['warden']
      end

      def create_admin(options = {})
        options[:accept_invitation] = options[:admin].delete(:accept_invitation) || options[:accept_invitation]
        options[:locked]            = options[:admin].delete(:locked) || options[:locked]

        @current_admin ||= begin
          admin = create(:admin, options[:admin] || {})
          admin.accept_invitation if options[:accept_invitation] == true
          admin.lock! if options[:locked] == true
          admin
        end
      end

      # http://stackoverflow.com/questions/4484435/rails3-how-do-i-visit-a-subdomain-in-a-steakrspec-spec-using-capybara
      def switch_to_subdomain(subdomain = nil)
        subdomain += '.' if subdomain.present?
        if Capybara.current_driver == :rack_test
          Capybara.app_host = "http://#{subdomain}sublimevideo.dev"
        else
          Capybara.app_host = "http://#{subdomain}sublimevideo.dev:#{Capybara.server_port}"
        end
      end

      def go(*subdomain_and_route)
        if subdomain_and_route.one?
          switch_to_subdomain(nil)
          visit *subdomain_and_route
        else
          switch_to_subdomain(subdomain_and_route[0])
          visit subdomain_and_route[1].start_with?("/") ? subdomain_and_route[1] : "/#{subdomain_and_route[1]}"
        end
      end

      def sign_in_as(resource_name, options = {})
        kill_user = options.delete(:kill_user)
        sign_out(kill_user) if @current_user
        options = { resource_name => options }

        resource = case resource_name
        when :user
          go 'my', '/login'
          create_user(options)
        when :admin
          go 'admin', '/login'
          create_admin(options)
        end
        fill_in 'Email',    with: resource.email
        fill_in 'Password', with: options[resource_name][:password] || '123456'
        check   'Remember me' if options[:remember_me] == true
        yield if block_given?
        click_button 'Log In'
        resource
      end

      def sign_out(kill_user = false)
        click_link "logout"
        @current_user = nil #if kill_user
      end

    end
  end
end

RSpec.configuration.include(Spec::Support::RequestsHelpers, type: :request)