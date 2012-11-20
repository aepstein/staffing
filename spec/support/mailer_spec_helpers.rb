module MailerSpecHelpers
  def text_part_should_not_match( content )
    mail.parts[0].body.encoded.should_not match(content)
  end

  def html_part_should_not_match( content )
    mail.parts[1].body.encoded.should_not match(content)
  end

  def both_parts_should_not_match( content )
    text_part_should_not_match content
    html_part_should_not_match content
  end

  def text_part_should_match( content )
    mail.parts[0].body.encoded.should match(content)
  end

  def html_part_should_match( content )
    mail.parts[1].body.encoded.should match(content)
  end

  def both_parts_should_match( content )
    text_part_should_match content
    html_part_should_match content
  end
end

