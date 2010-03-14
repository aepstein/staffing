module RequestsHelper
  def render_question(form)
    as = case form.object.question.attributes['format']
    when 'string'
      :string
    when 'text'
      :text
    when 'boolean'
      :radio
    else
      'text'
    end
    form.input :content, :as => as, :label => form.object.question.name,
      :hint => form.object.question.content
  end
end

