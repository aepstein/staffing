module MeetingsHelper
  # Generates footnotes for selected attachment
  def footnotes_for_meeting_item_attachments( meeting, meeting_item, options = {} )
    format = options[:format] || :html
    footnotes = meeting_item.enclosures.
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
    linked_attachments = options[:linked_attachments]
    format = options[:format] || :html
    absolute = options[:absolute] || false
    index = meeting.attachment_index( attachment )
    attachment_description = if attachment.instance_of?(Motion)
      attachment.to_s(:numbered)
    elsif attachment.instance_of?(MotionCommentReport)
      "Comments for #{attachment.motion.to_s(:numbered)}"
    else
      attachment.to_s
    end
    case format
    when :html
      anchor = content_tag :a, '', name: "footnote-#{index}"
      link = if linked_attachments.nil? || linked_attachments.include?( attachment )
        link_path = if attachment.instance_of?( MotionCommentReport )
          [ attachment.motion, :motion_comments ]
        else
          attachment
        end
        link_options = attachment.instance_of?( Attachment ) ? { } : { format: :pdf }
        if absolute
          link_to polymorphic_url(link_path, link_options), polymorphic_url(link_path, link_options)
        else
          link_to polymorphic_path(link_path, link_options), polymorphic_path(link_path, link_options)
        end
      else
        attached_file = meeting.attachment_filename(attachment)
        link_to attached_file, attachments[attached_file].url
      end
      content_tag :li, "#{anchor}#{attachment_description} [#{link}]".html_safe, id: "footnote-#{index}"
    when :pdf
      "#{attachment_description}"
    else
      "#{index}. #{attachment_description} [#{attachment_url(attachment)}]"
    end
  end

end

