module MembershipRequestsHelper
  def render_question(form)
    as = case form.object.question.disposition
    when 'string'
      :string
    when 'text'
      :text
    when 'boolean'
      :radio
    else
      'text'
    end
    label = case form.object.question.disposition
    when 'boolean'
      form.object.question.name + '?'
    else
      form.object.question.name
    end
    form.input :content, as: as, label: label,
      hint: form.object.question.content
  end
end

