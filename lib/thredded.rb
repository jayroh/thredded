require 'thredded/engine'
require 'cancan'
require 'carrierwave'
require 'griddler'
require 'kaminari'
require 'friendly_id'
require 'nested_form'
require 'thredded/email_processor'
require 'thredded/errors'
require 'thredded/at_notifier'
require 'html/pipeline'
require 'html/pipeline/bbcode_filter'
require 'html/pipeline/attached_image_filter'
require 'html/pipeline/at_mention_filter'
require 'thredded/messageboard_user_permissions'
require 'thredded/post_user_permissions'
require 'thredded/private_topic_user_permissions'
require 'thredded/topic_user_permissions'
require 'thredded/search_sql_builder'

module Thredded
  mattr_accessor :user_class,
    :email_incoming_host,
    :email_from,
    :email_outgoing_prefix,
    :user_path,
    :file_storage,
    :asset_root,
    :layout

  self.file_storage = :file # or :fog
  self.asset_root = '' # or fully qualified URI to assets
  self.layout = 'thredded'

  def self.user_class
    if @@user_class.is_a?(Class)
      raise 'Please use a string instead of a class'
    end

    if @@user_class.is_a?(String)
      begin
        Object.const_get(@@user_class)
      rescue NameError
        @@user_class.constantize
      end
    end
  end

  def self.user_path(user)
    if @@user_path.respond_to? :call
      @@user_path.call(user)
    else
      '/'
    end
  end
end
