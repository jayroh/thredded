module Thredded
  class Engine < ::Rails::Engine
    isolate_namespace Thredded

    config.autoload_paths << File.expand_path('../../../app/decorators', __FILE__)
    config.autoload_paths << File.expand_path('../../../app/forms', __FILE__)
    config.autoload_paths << File.expand_path('../../../app/commands', __FILE__)
    config.autoload_paths << File.expand_path('../../../app/jobs', __FILE__)

    config.generators do |g|
      g.test_framework :rspec, fixture: true
      g.fixture_replacement :factory_girl, dir: 'spec/factories'
      g.helper false
    end

    config.to_prepare do
      if Thredded.user_class
        Thredded.user_class.send(:include, Thredded::UserExtender)
      end

      Q.setup do |config|
        config.queue = Thredded.queue_backend
        config.queue_config.inline = Thredded.queue_inline
      end

      ThreadedInMemoryQueue.logger.level = Thredded.queue_memory_log_level
    end

    initializer 'thredded.set_adapter' do
      Thredded.use_adapter! Thredded::Post.connection_config[:adapter]
    end

    initializer 'thredded.setup_assets' do
      Thredded::Engine.config.assets.precompile += %w(
        thredded.js
        thredded.css
        thredded/chosen-sprite.png
        thredded/chosen-sprite@2x.png
        thredded/breadcrumb-chevron.svg
      )
    end

    initializer 'thredded.append_migrations' do |app|
      unless app.root.to_s.match(root.to_s)
        app.config.paths['db/migrate'].concat config.paths['db/migrate'].expanded
      end
    end
  end
end
