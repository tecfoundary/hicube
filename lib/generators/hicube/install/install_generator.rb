require 'rails/generators/migration'

module Hicube
  module Generators
    class InstallGenerator < ::Rails::Generators::Base
      include Rails::Generators::Migration

      source_root File.expand_path('../templates', __FILE__)
      desc "add migrations and configurations"

      def self.next_migration_number(path)
        unless @prev_migration_nr
          @prev_migration_nr = Time.now.utc.strftime("%Y%m%d%H%M%S").to_i
        else
          @prev_migration_nr += 1
        end
        @prev_migration_nr.to_s
      end

      def copy_migrations
        copy_migration "generate_hicube_accounts"
        copy_migration "generate_hicube_users"
        copy_migration "generate_hicube_pages"
        # migration_template "generate_hicube_accounts.rb", "db/migrate/generate_hicube_accounts.rb"
        # migration_template "generate_hicube_users.rb", "db/migrate/generate_hicube_users.rb", "--force"
        # migration_template "generate_hicube_pages.rb", "db/migrate/generate_hicube_pages.rb"
        rake "db:migrate"
      end

      def copy_config
        template "sitemap.rb", "config/sitemap.rb"
        append_to_file 'public/robots.txt', "\nSitemap: #{ENV['AWS_ASSET_HOST']}/#{ENV['S3_BUCKET_NAME']}/sitemaps/#{Rails.application.class.to_s.split('::').first}/sitemap.xml.gz"
      end

      # def copy_tasks
      #   template "scheduler.rake", "lib/tasks/scheduler.rake"
      # end
      private

      def copy_migration(filename)
        if self.class.migration_exists?("db/migrate", "#{filename}")
          say_status("skipped", "Migration #{filename}.rb already exists")
        else
          migration_template "#{filename}.rb", "db/migrate/#{filename}.rb"
        end
      end
    end
  end
end
