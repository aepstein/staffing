module MeetingsHelper
  # Generates footnotes for selected attachment
  def footnotes_for_meeting_item_attachments( meeting, meeting_item, options = {} )
    format = options[:format] || :html
    footnotes = meeting_item.attachments.
      map { |a| footnote_for_meeting_item_attachment( meeting, a, options) }.
      join(",")
    case format
    when :html
      content_tag( :sup, footnotes.html_safe )
    else
      footnotes
    end
  end

  def footnote_for_meeting_item_attachment( meeting, attachment, options = {} )
    format = options.delete :format
    index = meeting.attachment_index( attachment )
    case format
    when :html
      ( "[" + link_to( index.to_s, "#footnote-#{index}" ) + "]" ).html_safe
    else
      "[#{index}]"
    end
  end

  def footnotes_for_meeting_attachments( meeting, options = {} )
    format = options[:format] || :html
    attachments = meeting.attachments.values.flatten.
      map { |f|  }
    items = meeting.attachments.values.flatten.map { |attachment|
      footnote_for_meeting_attachment( meeting, attachment, options )
    }.join("\n")
    case format
    when :html
      content_tag( :p, "Attachments" ) +  content_tag( :ol, items.html_safe )
    else
      "Attachments:\n" + items
    end
  end

  def footnote_for_meeting_attachment( meeting, attachment, options = {} )
    linked_attachments = options.delete :linked_attachments
    format = options.delete( :format ) || :html
    index = meeting.attachment_index( attachment )
    case format
    when :html
      anchor = content_tag :a, '', name: "footnote-#{index}"
      link = if linked_attachments.blank? || linked_attachments.include?( attachment )
        link_to attachment_url(attachment), attachment_url(attachment)
      else
        link_to "#{index}_#{attachment.to_s}", attachments["#{index}_#{attachment.to_s(:file)}"].url
      end
      content_tag :li, "#{anchor}#{attachment.description} [#{link}]".html_safe, id: "footnote-#{index}"
    else
      "#{index}. #{attachment.description} [#{attachment_url(attachment)}]"
    end
  end

end

