module Thredded
  class AtUsers
    def self.render(content, messageboard)
      at_names = AtNotificationExtractor.new(content).run
      members = messageboard.members_from_list(at_names)

      members.each do |member|
        member_path = Thredded.user_path(member)
        content.gsub!(/@#{member.to_s}/i, %(<a href="#{member_path}">@#{member}</a>))
      end

      content
    end
  end
end
