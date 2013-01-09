module Spec
  module Support
    module ControllersHelpers

      def authenticated_admin(stubs = {})
        @authenticated_admin ||= mock_admin(stubs)
      end

      def authenticated_user(stubs = {})
        @authenticated_user ||= mock_user(stubs)
      end

      def mock_site(stubs = {})
        @mock_site ||= mock_model(Site, stubs)
      end

      def mock_user(stubs = {})
        @mock_user ||= create(:user, stubs)
      end

      def mock_admin(stubs = {})
        @mock_admin ||= create(:admin, stubs)
      end

      def mock_release(stubs = {})
        @mock_release ||= mock_model(Release, stubs)
      end

      def mock_mail_template(stubs = {})
        @mock_mail_template ||= mock_model(MailTemplate, stubs)
      end

      def mock_mail_letter(stubs = {})
        @mock_mail_letter ||= mock_model(MailLetter, stubs)
      end

      def mock_mail_log(stubs = {})
        @mock_mail_log ||= mock_model(MailLog, stubs)
      end

      def mock_delayed_job(stubs = {})
        @mock_delayed_job ||= mock_model(Delayed::Job, stubs)
      end

      def mock_plan(stubs = {})
        @mock_plan ||= mock_model(Plan, stubs)
      end

      def mock_transaction(stubs = {})
        @mock_transaction ||= mock_model(Transaction, stubs)
      end

      def mock_tweet(stubs = {})
        @mock_tweet ||= mock_model(Tweet, stubs)
      end

    end
  end
end

RSpec.configuration.include(Spec::Support::ControllersHelpers)
