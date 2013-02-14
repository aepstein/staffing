module MailerSpecHelpers
  def mail_core
    @mail_core ||= mail.parts.select { |p| p.content_type =~ /^multipart\/alternative/ }.first || mail
  end

  def text_part
    @text_part ||= mail_core.parts.select { |p| p.content_type =~ /^text\/plain/ }.first
  end

  def html_part
    @html_part ||= mail_core.parts.select { |p| p.content_type =~ /^text\/html/ }.first
  end

  def text_part_should_not_match( content )
    text_part.body.encoded.should_not match(content)
  end

  def html_part_should_not_match( content )
    html_part.body.encoded.should_not match(content)
  end

  def both_parts_should_not_match( content )
    text_part_should_not_match content
    html_part_should_not_match content
  end

  def text_part_should_match( content )
    text_part.body.encoded.should match(content)
  end

  def html_part_should_match( content )
    html_part.body.encoded.should match(content)
  end

  def both_parts_should_match( content )
    text_part_should_match content
    html_part_should_match content
  end
end

