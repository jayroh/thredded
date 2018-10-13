# frozen_string_literal: true

module Thredded
  module IconHelper
    def define_svg_icons(*filenames)
      return if filenames.blank?
      sb = filenames.map do |filename|
        inline_svg_once(filename, id: thredded_icon_id(filename))
      end
      return if sb.compact.blank?
      content_tag :div, safe_join(sb), class: 'thredded--svg-definitions'
    end

    def inline_svg_once(filename, transform_params = {})
      id = transform_params[:id]
      fail 'Must call inline_svg_once with an id.' unless id
      return if @already_inlined_svg_ids&.include?(id)
      record_already_inlined_svg(filename, id)
      inline_svg(filename, transform_params)
    end

    private

    def record_already_inlined_svg(filename, id)
      if filename.is_a?(String) # in case it's an IO or other
        fail "Please use id: #{thredded_icon_id(filename)}" unless id == thredded_icon_id(filename)
      end
      @already_inlined_svg_ids ||= []
      @already_inlined_svg_ids << id
    end

    def thredded_icon_id(svg_filename)
      "thredded-#{File.basename(svg_filename, '.svg').dasherize}-icon"
    end
  end
end
